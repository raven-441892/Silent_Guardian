import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

class VolumeListenerService {
  static const MethodChannel _channel = MethodChannel('volume_channel');

  List<String> savedSequence = ["MAX", "MIN", "MAX"]; // Later load from storage
  List<String> currentInput = [];

  VolumeListenerService() {
    _startListening();
  }

  void _startListening() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "volumeUp") {
        _registerStep("MAX");
      } else if (call.method == "volumeDown") {
        _registerStep("MIN");
      }
    });
  }

  void _registerStep(String step) {
    currentInput.add(step);

    if (currentInput.length > 5) {
      currentInput.removeAt(0);
    }

    print("Current Input: $currentInput");

    _checkSequence();
  }

  void _checkSequence() {
    if (currentInput.length < savedSequence.length) return;

    final lastInput =
    currentInput.sublist(currentInput.length - savedSequence.length);

    if (const ListEquality().equals(lastInput, savedSequence)) {
      _triggerEmergency();
    }
  }


  void _triggerEmergency() {
    print("EMERGENCY TRIGGERED");

    // TODO:
    // - Start countdown activity
    // - Send SMS
    // - Trigger backend
    // - Send notification

    currentInput.clear();
  }
}
