import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class RecorderService {
  final _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  String? _currentPath;

  Future<bool> hasPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _recorder.openRecorder();
      _isInitialized = true;
    }
  }

  Future<void> start() async {
    await _ensureInitialized();

    final dir = await getApplicationDocumentsDirectory();
    _currentPath = p.join(
      dir.path,
      'memo_${DateTime.now().millisecondsSinceEpoch}.aac',
    );

    await _recorder.startRecorder(
      toFile: _currentPath,
      codec: Codec.aacADTS,
      bitRate: 128000,
      sampleRate: 44100,
    );
  }

  Future<String?> stop() async {
    if (!_isInitialized) return null;
    await _recorder.stopRecorder();
    return _currentPath;
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }
}