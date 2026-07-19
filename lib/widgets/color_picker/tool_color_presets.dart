import 'package:flutter/material.dart';

/// Preset ink colors for the pen and shape tools.
const penPresetColors = [
  Color(0xFF1A1A1A),
  Color(0xFF2455C3),
  Color(0xFFC0392B),
  Color(0xFF1E8449),
  Color(0xFF7D3C98),
  Color(0xFFE67E22),
  Color(0xFF16A085),
  Color(0xFF2C3E50),
  Color(0xFF95A5A6),
  Color(0xFFE91E63),
  Color(0xFF795548),
  Color(0xFFFFFFFF),
  Color(0xFF3498DB),
  Color(0xFFF39C12),
  Color(0xFF8E44AD),
];

/// Preset highlighter colors.
const highlighterPresetColors = [
  Color(0xFFFFE100),
  Color(0xFF7CF77C),
  Color(0xFF7CD6F7),
  Color(0xFFF77CE0),
  Color(0xFFFFA94D),
  Color(0xFFFF6B6B),
  Color(0xFFB388FF),
  Color(0xFF80DEEA),
  Color(0xFFFFF59D),
  Color(0xFFA5D6A7),
];

/// Preset fill colors (expanded to match highlighter palette breadth).
const fillPresetColors = [
  Color(0xFF2455C3),
  Color(0xFFFFE100),
  Color(0xFF7CF77C),
  Color(0xFFF77CE0),
  Color(0xFFFFA94D),
  Color(0xFFFF6B6B),
  Color(0xFFB388FF),
  Color(0xFF80DEEA),
  Color(0xFF1A1A1A),
  Color(0xFFFFFFFF),
  Color(0xFF1E8449),
  Color(0xFFC0392B),
];

/// Preset tape colors (simple palette — no custom picker).
const tapePresetColors = [
  Color(0xFFE8E0D0),
  Color(0xFFD4C4A8),
  Color(0xFFC8D8E8),
  Color(0xFFE8C8D0),
  Color(0xFFD0E0C8),
];

bool colorsMatch(Color a, Color b) => a.value == b.value;
