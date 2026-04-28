import 'package:flutter/services.dart';

// Listens for panic trigger events from native side
class PanicListener {

  // Event channel for communication with platform code
  static const EventChannel _channel =
  EventChannel('panic_trigger_channel');

  // Start listening for panic trigger
  static void startListening(Function onTriggered) {
    _channel.receiveBroadcastStream().listen((event) {

      // If trigger signal received
      if (event == "TRIGGER") {
        onTriggered();    // Execute callback
      }
    });
  }
}