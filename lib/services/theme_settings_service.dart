import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Persists and broadcasts the app-wide [ThemeMode] (system / light / dark).
class ThemeSettingsService extends ChangeNotifier {
  ThemeSettingsService._();
  static final ThemeSettingsService instance = ThemeSettingsService._();

  static const prefKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _parseThemeMode(prefs.getString(prefKey)) ?? ThemeMode.system;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, mode.name);
    notifyListeners();
  }

  String labelFor(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.themeLight;
      case ThemeMode.dark:
        return l10n.themeDark;
    }
  }

  String currentLabel(AppLocalizations l10n) => labelFor(l10n, _themeMode);

  static ThemeMode? _parseThemeMode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == raw) return mode;
    }
    return null;
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _themeMode = ThemeMode.system;
    _loaded = false;
  }
}
