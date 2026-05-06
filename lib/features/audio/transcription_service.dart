import 'package:speech_to_text/speech_to_text.dart';

class TranscriptionService {
  final _stt = SpeechToText();
  bool _ready = false;

  Future<bool> init() async {
    _ready = await _stt.initialize(
      onError: (e) => print('STT error: $e'),
    );
    return _ready;
  }

  void listen({required void Function(String) onResult}) {
    if (!_ready) return;
    _stt.listen(
      onResult: (r) => onResult(r.recognizedWords),
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void stop() => _stt.stop();
}