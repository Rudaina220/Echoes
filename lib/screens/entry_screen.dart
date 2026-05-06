import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/db_provider.dart';

class EntryScreen extends ConsumerStatefulWidget {
  const EntryScreen({super.key});

  @override
  ConsumerState<EntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends ConsumerState<EntryScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  bool _isSaving = false;
  bool _isLocating = false;

  double? _latitude;
  double? _longitude;
  // 'none' | 'current' | 'map'
  String _locationMode = 'none';

  final List<File> _selectedImages = [];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }


  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await _getCurrentPosition();
      if (pos == null) return;

      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _locationMode = 'current';
      });
    } on TimeoutException {
      _showSnack('Location timed out. Try again in the open.');
    } catch (e) {
      _showSnack('Could not get location: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<Position?> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack('Location services are disabled.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack('Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack('Location permission permanently denied. Enable it in settings.');
      return null;
    }

    Position? pos = await Geolocator.getLastKnownPosition();
    pos ??= await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );

    return pos;
  }

  Future<void> _pickLocationFromMap() async {
    setState(() => _isLocating = true);

    try {
      final pos = await _getCurrentPosition();

      final picked = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
          builder: (_) => MapPickerScreen(
            initialLocation: (_latitude != null && _longitude != null)
                ? LatLng(_latitude!, _longitude!)
                : (pos != null
                ? LatLng(pos.latitude, pos.longitude)
                : const LatLng(30.0444, 31.2357)),
          ),
        ),
      );

      if (!mounted || picked == null) return;

      setState(() {
        _latitude = picked.latitude;
        _longitude = picked.longitude;
        _locationMode = 'map';
      });
    } catch (e) {
      _showSnack('Could not open map: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _clearLocation() => setState(() {
    _latitude = null;
    _longitude = null;
    _locationMode = 'none';
  });

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> picked = await _picker.pickMultiImage(
          imageQuality: 60,
          maxWidth: 1080,
          maxHeight: 1080,
        );
        if (!mounted) return;
        if (picked.isEmpty) return;
        setState(() => _selectedImages.addAll(picked.map((x) => File(x.path))));
      } else {
        final XFile? picked = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 60,
          maxWidth: 1080,
          maxHeight: 1080,
        );
        if (!mounted) return;
        if (picked == null) return;
        setState(() => _selectedImages.add(File(picked.path)));
      }
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('photo_access_denied') || msg.contains('camera_access_denied')) {
        _showSnack('Permission denied — enable it in your phone settings.');
      } else {
        _showSnack('Could not pick image: $msg');
      }
    }
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<String>> _persistImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(p.join(dir.path, 'memory_images'));
    await imageDir.create(recursive: true);

    final paths = <String>[];
    for (final file in _selectedImages) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(file.path)}';
      final dest = File(p.join(imageDir.path, fileName));
      await file.copy(dest.path);
      paths.add(dest.path);
    }
    return paths;
  }

  Future<void> _saveMemory() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final savedPaths = await _persistImages();
      await ref.read(databaseProvider).insertMemory(
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        imagePaths: savedPaths.isEmpty ? null : savedPaths,
      );

      if (!mounted) return;
      _showSnack('Memory saved');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to save memory: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _noteController,
                maxLines: 5,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Memory',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Please enter a memory' : null,
              ),
              const SizedBox(height: 20),

              Text('Location', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: _isLocating
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.my_location, size: 16),
                      label: const Text('Use current'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _locationMode == 'current'
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      onPressed: _isLocating ? null : _useCurrentLocation,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text('Choose from map'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _locationMode == 'map'
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                      ),
                      onPressed: _isLocating ? null : _pickLocationFromMap,
                    ),
                  ),
                ],
              ),

              if (_latitude != null && _longitude != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 180,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(_latitude!, _longitude!),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.echoes',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_latitude!, _longitude!),
                              width: 60,
                              height: 60,
                              child: const Icon(
                                Icons.location_pin,
                                size: 40,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.pinkAccent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickLocationFromMap,
                      child: const Text('Change'),
                    ),
                    IconButton(
                      onPressed: _clearLocation,
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              _ImageSection(
                images: _selectedImages,
                onAdd: _showImageSourceSheet,
                onRemove: _removeImage,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMemory,
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Add Memory'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({
    super.key,
    required this.initialLocation,
  });

  final LatLng initialLocation;

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _pickedLocation),
            child: const Text('Done'),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.initialLocation,
          initialZoom: 15,
          onTap: (_, point) {
            setState(() => _pickedLocation = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.echoes',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _pickedLocation,
                width: 70,
                height: 70,
                child: const Icon(
                  Icons.location_pin,
                  size: 42,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, _pickedLocation),
            icon: const Icon(Icons.check),
            label: Text(
              'Use ${_pickedLocation.latitude.toStringAsFixed(5)}, '
                  '${_pickedLocation.longitude.toStringAsFixed(5)}',
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  final List<File> images;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Photos', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text('Add photos'),
            ),
          ],
        ),
        if (images.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No photos added',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      images[i],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}