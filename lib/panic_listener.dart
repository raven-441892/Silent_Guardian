import 'package:flutter/services.dart';

class PanicListener {
  static const EventChannel _channel =
  EventChannel('panic_trigger_channel');

  static void startListening(Function onTriggered) {
    _channel.receiveBroadcastStream().listen((event) {
      if (event == "TRIGGER") {
        onTriggered();
      }
    });
  }
}