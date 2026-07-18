import 'package:flutter/material.dart';

/// Per-page paper background palette (not app UI theme).
enum PageBackgroundTheme {
  light,
  dark,
  sepia,
  pastelPink,
  pastelBlue,
  pastelMint;

  static PageBackgroundTheme fromIndex(int index) {
    if (index < 0 || index >= values.length) return light;
    return values[index];
  }

  /// Paper fill color.
  Color get paperColor => switch (this) {
        light => const Color(0xFFFFFFFF),
        dark => const Color(0xFF2A2A2A),
        sepia => const Color(0xFFF4ECD8),
        pastelPink => const Color(0xFFFFF0F3),
        pastelBlue => const Color(0xFFF0F7FF),
        pastelMint => const Color(0xFFF0FFF4),
      };

  /// Ruled / grid line color.
  Color get lineColor => switch (this) {
        light => const Color(0xFFD9E2EC),
        dark => const Color(0xFF454545),
        sepia => const Color(0xFFD4C4A8),
        pastelPink => const Color(0xFFE8C4CF),
        pastelBlue => const Color(0xFFC4D9E8),
        pastelMint => const Color(0xFFC4E8D0),
      };

  /// College-ruled margin accent.
  Color get marginColor => switch (this) {
        light => const Color(0xFFE8B4B4),
        dark => const Color(0xFF6B4545),
        sepia => const Color(0xFFD4A0A0),
        pastelPink => const Color(0xFFE8A0B0),
        pastelBlue => const Color(0xFFA0B8D4),
        pastelMint => const Color(0xFFA0D4B0),
      };

  /// Dotted template dot color.
  Color get dotColor => switch (this) {
        light => const Color(0xFFC3CFDD),
        dark => const Color(0xFF555555),
        sepia => const Color(0xFFC4B898),
        pastelPink => const Color(0xFFD8B8C4),
        pastelBlue => const Color(0xFFB8C8D8),
        pastelMint => const Color(0xFFB8D8C4),
      };
}
