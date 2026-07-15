import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/screens/notebook_screen.dart';
import 'package:penfold/services/page_turn_mode_service.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    ThumbnailCache.autoGenerate = false;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PageTurnModeService.instance.resetForTests();
    tmp = await Directory.systemTemp.createTemp('penfold_page_turn_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('PageTurnModeService', () {
    test('defaults to scroll mode (disabled)', () async {
      await PageTurnModeService.instance.load();
      expect(PageTurnModeService.instance.enabled, isFalse);
    });

    test('save and load roundtrip', () async {
      await PageTurnModeService.instance.setEnabled(true);
      PageTurnModeService.instance.resetForTests();
      await PageTurnModeService.instance.load();
      expect(PageTurnModeService.instance.enabled, isTrue);
    });

    test('load respects stored preference', () async {
      SharedPreferences.setMockInitialValues({
        PageTurnModeService.prefKey: true,
      });
      PageTurnModeService.instance.resetForTests();
      await PageTurnModeService.instance.load();
      expect(PageTurnModeService.instance.enabled, isTrue);
    });
  });

  group('NotebookScreen navigation mode', () {
    Future<Notebook> seedNotebook() async {
      final db = AppDatabase.instance;
      final notebook = Notebook(
        id: 'nb-page-turn',
        title: 'Page Turn Test',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      );
      await db.insertNotebook(notebook);
      final page = NotePage(
        id: 'pg-1',
        notebookId: notebook.id,
        index: 0,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
      );
      await db.insertPage(page);
      return notebook;
    }

    testWidgets('scroll mode uses CustomScrollView by default',
        (tester) async {
      final notebook = (await tester.runAsync(seedNotebook))!;
      await PageTurnModeService.instance.load();

      await tester.pumpWidget(
        MaterialApp(
          home: NotebookScreen(notebook: notebook),
        ),
      );
      await settle(tester);

      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(PageView), findsNothing);
    });

    testWidgets('page-turn mode uses PageView', (tester) async {
      SharedPreferences.setMockInitialValues({
        PageTurnModeService.prefKey: true,
      });
      PageTurnModeService.instance.resetForTests();
      await PageTurnModeService.instance.load();

      final notebook = (await tester.runAsync(seedNotebook))!;

      await tester.pumpWidget(
        MaterialApp(
          home: NotebookScreen(notebook: notebook),
        ),
      );
      await settle(tester);

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(CustomScrollView), findsNothing);
    });
  });
}
