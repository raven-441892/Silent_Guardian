import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'dart:async';

class VolumeListenerService {

  List<String> savedSequence = ["MAX", "MIN", "MAX"]; // temporary
  List<String> currentInput = [];

  double? _previousVolume;

  void startListening(BuildContext context) async {

    VolumeController.instance.showSystemUI = false;

    _previousVolume = await VolumeController.instance.getVolume();

    VolumeController.instance.addListener((volume) {

      if (_previousVolume == null) return;

      if (volume > _previousVolume!) {
        _registerStep("MAX", context);
      } else if (volume < _previousVolume!) {
        _registerStep("MIN", context);
      }

      _previousVolume = volume;
    });
  }

  void _registerStep(String step, BuildContext context) {

    currentInput.add(step);

    // Keep last 5 presses
    if (currentInput.length > 5) {
      currentInput.removeAt(0);
    }

    debugPrint("Current Input: $currentInput");

    _checkSequence(context);
  }

  void _checkSequence(BuildContext context) {

    if (currentInput.length < savedSequence.length) return;

    List<String> lastInput =
    currentInput.sublist(currentInput.length - savedSequence.length);

    if (lastInput.toString() == savedSequence.toString()) {
      _triggerCountdown(context);
    }
  }

  void _triggerCountdown(BuildContext context) {

    int seconds = 3;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (seconds == 0) {
            t.cancel();
            Navigator.pop(context);
            _triggerEmergency(context);
          } else {
            seconds--;
          }
        });

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Emergency Triggered!"),
              content: Text("Sending alert in $seconds seconds..."),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _triggerEmergency(BuildContext context) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(" Emergency Alert Sent (Simulation)"),
        backgroundColor: Colors.red,
      ),
    );

    currentInput.clear();
  }

  void dispose() {
    VolumeController.instance.removeListener();
  }

}
