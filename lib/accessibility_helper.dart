import 'package:flutter/services.dart';

// Flutter-side helper to communicate with the native accessibility MethodChannel
class AccessibilityHelper {
  static const platform = MethodChannel("accessibility_channel");

  // Opens the Android Accessibility Settings screen so the user can enable the service
  static Future<void> openAccessibilitySettings() async {
    try {
      await platform.invokeMethod("openAccessibilitySettings");
    } catch (e) {
      print("Error opening settings: $e");
    }
  }

  // Returns true if VolumeKeyAccessibilityService is currently enabled on the device
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