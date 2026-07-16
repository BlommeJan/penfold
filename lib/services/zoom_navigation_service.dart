import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists pinch/pan zoom on notebook pages (default on).
class ZoomNavigationService extends ChangeNotifier {
  ZoomNavigationService._();
  static final ZoomNavigationService instance = ZoomNavigationService._();

  static const prefKey = 'zoom_navigation_enabled';

  bool _enabled = true;
  bool _loaded = false;

  bool get enabled => _enabled;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(prefKey) ?? true;
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
    _enabled = true;
    _loaded = false;
  }
}
