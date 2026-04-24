import 'package:flutter/services.dart';

class AccessibilityHelper {
  static const platform = MethodChannel("accessibility_channel");

  static Future<void> openAccessibilitySettings() async {
    try {
      await platform.invokeMethod("openAccessibilitySettings");
    } catch (e) {
      print("Error opening settings: $e");
    }
  }

  static Future<bool> isAccessibilityEnabled() async {
    try {
      final bool enabled = await platform.invokeMethod("isAccessibilityEnabled");
      return enabled;
    } catch (e) {
      print("Error checking accessibility: $e");
      return false;
    }
  }
}