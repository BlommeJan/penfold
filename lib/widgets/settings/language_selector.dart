import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/locale_settings_service.dart';

/// Dropdown to pick the app UI language; persists via [LocaleSettingsService].
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  String _languageName(AppLocalizations l10n, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.languageEnglish;
      case 'de':
        return l10n.languageGerman;
      case 'fr':
        return l10n.languageFrench;
      case 'nl':
        return l10n.languageDutch;
      case 'ko':
        return l10n.languageKorean;
      case 'pl':
        return l10n.languagePolish;
      case 'es':
        return l10n.languageSpanish;
      case 'it':
        return l10n.languageItalian;
      case 'uk':
        return l10n.languageUkrainian;
      case 'sv':
        return l10n.languageSwedish;
      case 'nb':
        return l10n.languageNorwegian;
      case 'fi':
        return l10n.languageFinnish;
      case 'da':
        return l10n.languageDanish;
      case 'pt':
        return l10n.languagePortuguese;
      default:
        return locale.languageCode;
    }
  }

  Locale _effectiveLocale(Locale? persisted, Locale fallback) {
    final choices = LocaleSettingsService.selectableLocales;
    if (persisted != null && choices.contains(persisted)) {
      return persisted;
    }
    if (choices.contains(fallback)) {
      return fallback;
    }
    return choices.first;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = LocaleSettingsService.instance;

    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        if (!service.isLoaded) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final current = _effectiveLocale(
          service.locale,
          Localizations.localeOf(context),
        );
        final choices = LocaleSettingsService.selectableLocales;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: DropdownButtonFormField<Locale>(
            key: ValueKey('language-${Theme.of(context).brightness}'),
            value: current,
            dropdownColor: Theme.of(context).colorScheme.surface,
            decoration: InputDecoration(
              labelText: l10n.settingsLanguageLabel,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final locale in choices)
                DropdownMenuItem(
                  value: locale,
                  child: Text(_languageName(l10n, locale)),
                ),
            ],
            onChanged: (locale) {
              if (locale != null) {
                service.setLocale(locale);
              }
            },
          ),
        );
      },
    );
  }
}
