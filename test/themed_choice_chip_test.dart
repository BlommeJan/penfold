import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/notebook_defaults_service.dart';
import 'package:penfold/services/theme_settings_service.dart';
import 'package:penfold/theme/penfold_theme.dart';
import 'package:penfold/widgets/settings/notebook_defaults_section.dart';
import 'package:penfold/widgets/themed_choice_chip.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n_test_harness.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ThemeSettingsService.instance.resetForTests();
    NotebookDefaultsService.instance.resetForTests();
  });

  testWidgets('ThemedChoiceChip stays tappable after theme switch',
      (tester) async {
    var selected = PageSize.a4;
    const labels = {'a4': PageSize.a4, 'a5': PageSize.a5, 'letter': PageSize.letter};

    await tester.pumpWidget(
      wrapWithL10n(
        Material(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  for (final entry in labels.entries)
                    ThemedChoiceChip(
                      label: entry.key,
                      selected: selected == entry.value,
                      onSelected: () => setState(() => selected = entry.value),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('letter'));
    await tester.pumpAndSettle();
    expect(selected, PageSize.letter);

    await tester.pumpWidget(
      wrapWithL10n(
        Theme(
          data: PenfoldTheme.dark,
          child: Material(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    for (final entry in labels.entries)
                      ThemedChoiceChip(
                        label: entry.key,
                        selected: selected == entry.value,
                        onSelected: () =>
                            setState(() => selected = entry.value),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('a5'));
    await tester.pumpAndSettle();
    expect(selected, PageSize.a5);
  });

  testWidgets('NotebookDefaultsSection updates selection after theme switch',
      (tester) async {
    await NotebookDefaultsService.instance.load();

    Future<void> pumpSection(Brightness brightness) async {
      await tester.pumpWidget(
        wrapWithL10n(
          Theme(
            data: brightness == Brightness.light
                ? PenfoldTheme.light
                : PenfoldTheme.dark,
            child: const Scaffold(
              body: SingleChildScrollView(
                child: NotebookDefaultsSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpSection(Brightness.light);

    final a5Chip = find.widgetWithText(ThemedChoiceChip, 'A5');
    expect(a5Chip, findsOneWidget);
    await tester.tap(a5Chip);
    await tester.pumpAndSettle();
    expect(NotebookDefaultsService.instance.defaults.pageSize, PageSize.a5);

    await pumpSection(Brightness.dark);

    final letterChip = find.widgetWithText(ThemedChoiceChip, 'Letter');
    expect(letterChip, findsOneWidget);
    await tester.tap(letterChip);
    await tester.pumpAndSettle();
    expect(
      NotebookDefaultsService.instance.defaults.pageSize,
      PageSize.letter,
    );
  });
}
