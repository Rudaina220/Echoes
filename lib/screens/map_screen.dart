import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../db/database.dart';
import '../db/db_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoriesAsync = ref.watch(memoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Map')),
      body: memoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (memories) {
          // Only memories that have a saved location
          final located = memories
              .where((m) => m.latitude != null && m.longitude != null)
              .toList();

          // Default center: Cairo. If there are located memories, center on the first.
          final center = located.isNotEmpty
              ? LatLng(located.first.latitude!, located.first.longitude!)
              : const LatLng(30.0444, 31.2357);

          return FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: located.length == 1 ? 14 : 10,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.echoes',
              ),
              MarkerLayer(
                markers: located
                    .map(
                      (m) => Marker(
                    point: LatLng(m.latitude!, m.longitude!),
                    width: 200,
                    height: 80,
                    child: _MemoryMarker(memory: m),
                  ),
                )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MemoryMarker extends StatelessWidget {
  const _MemoryMarker({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    final images = _parseImagePaths(memory.imagePaths);
    final hasImage = images.isNotEmpty;

    return GestureDetector(
      onTap: () => _showMemorySheet(context, memory, images),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: hasImage
                  ? Image.file(File(images.first), fit: BoxFit.cover)
                  : const Icon(Icons.photo_camera_back,
                  color: Colors.white, size: 24),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              memory.title,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Classic pin point
          Container(
            width: 2,
            height: 8,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }

  void _showMemorySheet(
      BuildContext context, Memory memory, List<String> images) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MemorySheet(memory: memory, imagePaths: images),
    );
  }
}

class _MemorySheet extends StatelessWidget {
  const _MemorySheet({required this.memory, required this.imagePaths});

  final Memory memory;
  final List<String> imagePaths;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(memory.title,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(memory.note,
              style: Theme.of(context).textTheme.bodyMedium),
          if (imagePaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imagePaths.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imagePaths[i]),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '📍 ${memory.latitude!.toStringAsFixed(5)}, ${memory.longitude!.toStringAsFixed(5)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

List<String> _parseImagePaths(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw.split(',').where((s) => s.isNotEmpty).toList();
}