import 'package:flutter/material.dart';

/// Shared Penfold brand colors used by light and dark themes.
abstract final class PenfoldColors {
  static const blue = Color(0xFF2455C3);
  static const blueLight = Color(0xFF3D6FD4);
  static const accent = Color(0xFFE8A317);

  static const lightScaffold = Color(0xFFF6F7F9);
  static const lightSurface = Colors.white;
  static const lightOnSurface = Color(0xFF1A1A1A);
  static const lightChipBorder = Color(0xFFE0E4EA);
  static const lightDivider = Color(0xFFE0E4EA);

  static const darkScaffold = Color(0xFF121418);
  static const darkSurface = Color(0xFF1E2229);
  static const darkSurfaceVariant = Color(0xFF2A3039);
  static const darkOnSurface = Color(0xFFE8EAED);
  static const darkOnSurfaceMuted = Color(0xFF9AA3B2);
  static const darkChipBorder = Color(0xFF3A424E);
  static const darkDivider = Color(0xFF2E3540);
}
