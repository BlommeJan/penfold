import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists notebook navigation style: continuous scroll (default) vs page-turn.
class PageTurnModeService extends ChangeNotifier {
  PageTurnModeService._();
  static final PageTurnModeService instance = PageTurnModeService._();

  static const prefKey = 'page_turn_mode_enabled';

  bool _enabled = false;
  bool _loaded = false;

  bool get enabled => _enabled;
  bool get isLoaded => _loaded;

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
