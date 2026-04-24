import 'package:flutter/services.dart';

class VolumeListenerService {
  static const MethodChannel _volumeChannel = MethodChannel('volume_channel');
  static const MethodChannel _panicChannel = MethodChannel('panic_trigger_channel');

  // Hardcoded: Up → Down → Up
  final List<String> _input = [];

  VolumeListenerService() {
    _startListening();
  }

  void _startListening() {
    _volumeChannel.setMethodCallHandler((call) async {
      if (call.method == "volumeUp") {
        _register("UP");
      } else if (call.method == "volumeDown") {
        _register("DOWN");
      }
    });
  }

  void _register(String step) {
    _input.add(step);
    if (_input.length > 3) _input.removeAt(0);

    // Check for Up → Down → Up
    if (_input.length == 3 &&
        _input[0] == "UP" &&
        _input[1] == "DOWN" &&
        _input[2] == "UP") {
      _input.clear();
      print("🚨 Volume sequence matched — triggering panic");
      _panicChannel.invokeMethod("TRIGGER");
    }
  }
}