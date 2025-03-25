import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  Future<bool> initializeSpeech() async {
    try {
      return await _speech.initialize();
    } catch (e) {
      print("Error initializing speech recognition: $e");
      return false;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    try {
      await _speech.listen(onResult: (result) {
        onResult(result.recognizedWords);
      });
    } catch (e) {
      print("Error starting listening: $e");
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      print("Error stopping listening: $e");
    }
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<bool> isSpeechAvailable() async {
    return await _speech.isAvailable;
  }
}
