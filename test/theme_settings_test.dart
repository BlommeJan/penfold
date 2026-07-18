import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/services/theme_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeSettingsService.instance.resetForTests();
  });

  group('ThemeSettingsService', () {
    test('defaults to system theme', () async {
      await ThemeSettingsService.instance.load();
      expect(ThemeSettingsService.instance.themeMode, ThemeMode.system);
    });

    test('save and load roundtrip', () async {
      await ThemeSettingsService.instance.setThemeMode(ThemeMode.dark);
      ThemeSettingsService.instance.resetForTests();
      await ThemeSettingsService.instance.load();
      expect(ThemeSettingsService.instance.themeMode, ThemeMode.dark);
    });

    test('load respects stored preference', () async {
      SharedPreferences.setMockInitialValues({
        ThemeSettingsService.prefKey: ThemeMode.light.name,
      });
      ThemeSettingsService.instance.resetForTests();
      await ThemeSettingsService.instance.load();
      expect(ThemeSettingsService.instance.themeMode, ThemeMode.light);
    });
  });
}
