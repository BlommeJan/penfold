import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists stroke-smoothing preference in SharedPreferences.
class StrokeSmoothingService extends ChangeNotifier {
  StrokeSmoothingService._();
  static final StrokeSmoothingService instance = StrokeSmoothingService._();

  static const prefKey = 'stroke_smoothing_enabled';
  static const prefKeyStrength = 'stroke_smoothing_strength';

  /// Recommended default: light smoothing that preserves small handwriting.
  static const defaultStrength = 0.35;
  static const recommendedStrength = defaultStrength;

  bool _enabled = true;
  double _strength = defaultStrength;
  bool _loaded = false;

  bool get enabled => _enabled;
  double get strength => _strength;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(prefKey) ?? true;
    _strength = prefs.getDouble(prefKeyStrength) ?? defaultStrength;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, value);
    notifyListeners();
  }

  Future<void> setStrength(double value) async {
    _strength = value.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefKeyStrength, _strength);
    notifyListeners();
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _enabled = true;
    _strength = defaultStrength;
    _loaded = false;
  }
}
