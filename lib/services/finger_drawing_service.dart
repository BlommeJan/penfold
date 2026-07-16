import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists finger-drawing (non-stylus ink) preference in SharedPreferences.
///
/// When enabled, touch on paper draws ink; when disabled, only stylus draws
/// and fingers pan/zoom (default: stylus-only / finger drawing off).
class FingerDrawingService extends ChangeNotifier {
  FingerDrawingService._();
  static final FingerDrawingService instance = FingerDrawingService._();

  static const prefKey = 'finger_drawing_enabled';

  bool _enabled = false;
  bool _loaded = false;

  bool get enabled => _enabled;
  bool get isLoaded => _loaded;

  /// Inverse of [ToolState.stylusOnly].
  bool get stylusOnly => !_enabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(prefKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, value);
    notifyListeners();
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _enabled = false;
    _loaded = false;
  }
}
