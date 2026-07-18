import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Persists the user's UI language choice and notifies [MaterialApp] to rebuild.
///
/// Selectable locales mirror [AppLocalizations.supportedLocales], so adding
/// `app_de.arb` (etc.) and re-running gen-l10n automatically exposes new choices.
class LocaleSettingsService extends ChangeNotifier {
  LocaleSettingsService._();
  static final LocaleSettingsService instance = LocaleSettingsService._();

  static const prefKey = 'app_locale_language_code';

  Locale? _locale;
  bool _loaded = false;

  Locale? get locale => _locale;
  bool get isLoaded => _loaded;

  static List<Locale> get selectableLocales =>
      AppLocalizations.supportedLocales;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(prefKey);
    if (code != null) {
      final match = selectableLocales.where((l) => l.languageCode == code);
      _locale = match.isNotEmpty ? match.first : null;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, locale.languageCode);
    notifyListeners();
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _locale = null;
    _loaded = false;
  }
}
