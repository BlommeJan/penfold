import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/theme_settings_service.dart';

/// Appearance setting: choose system, light, or dark theme.
///
/// Drop into Settings under an Appearance section header — no local state
/// required; listens to [ThemeSettingsService] directly.
class DarkModeSwitch extends StatelessWidget {
  const DarkModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ThemeSettingsService.instance;
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) {
        if (!service.isLoaded) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final l10n = context.l10n;
        final selected = service.themeMode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: Text(l10n.settingsAppearanceDarkMode),
              subtitle: Text(l10n.settingsAppearanceDarkModeSubtitle),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined, size: 18),
                    label: Text(l10n.themeSystem),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined, size: 18),
                    label: Text(l10n.themeLight),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined, size: 18),
                    label: Text(l10n.themeDark),
                  ),
                ],
                selected: {selected},
                onSelectionChanged: (selection) {
                  service.setThemeMode(selection.first);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
