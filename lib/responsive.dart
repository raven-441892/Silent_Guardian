import 'package:flutter/material.dart';

class R {
  static late MediaQueryData _mq;

  static void init(BuildContext context) {
    _mq = MediaQuery.of(context);
  }

  static double get width => _mq.size.width;
  static double get height => _mq.size.height;

  // Font sizes
  static double get fontSmall => (width * 0.032).clamp(11, 14);
  static double get fontMedium => (width * 0.038).clamp(13, 16);
  static double get fontLarge => (width * 0.048).clamp(16, 20);
  static double get fontTitle => (width * 0.056).clamp(18, 24);

  // Spacing
  static double get spacingSmall => (height * 0.012).clamp(8, 16);
  static double get spacingMedium => (height * 0.02).clamp(14, 24);
  static double get spacingLarge => (height * 0.04).clamp(24, 40);

  // Padding
  static double get paddingHorizontal => (width * 0.05).clamp(16, 24);
  static double get paddingVertical => (height * 0.02).clamp(12, 24);

  // Button
  static double get buttonHeight => (height * 0.065).clamp(48, 58);

  // Border radius
  static double get radius => (width * 0.03).clamp(10, 14);
}