import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists gesture ink editing preference in SharedPreferences.
class GestureInkService extends ChangeNotifier {
  GestureInkService._();
  static final GestureInkService instance = GestureInkService._();

  static const prefKey = 'gesture_ink_editing_enabled';

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
