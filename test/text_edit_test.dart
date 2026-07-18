import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/drawing_canvas.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n_test_harness.dart';
import 'widget_test.dart' show settle;

Widget _canvasHarness({
  required NotePage page,
  required ToolState toolState,
  required GlobalKey<DrawingCanvasState> key,
}) {
  const viewport = Size(400, 560);
  return wrapWithL10n(
    Scaffold(
      body: DrawingCanvas(
        key: key,
        page: page,
        toolState: toolState,
        displaySize: viewport,
        pageSize: page.pageSize,
      ),
    ),
  );
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
    tmp = await Directory.systemTemp.createTemp('penfold_text_edit_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('text tool commit', () {
    testWidgets('checkmark commits typed text like keyboard Done',
        (tester) async {
      final page = await tester.runAsync(() async {
        final db = AppDatabase.instance;
        await db.insertNotebook(Notebook(
          id: 'nb1',
          title: 'T',
          coverColor: 0xFF2455C3,
          template: PageTemplate.lined,
          createdAt: 1,
          updatedAt: 1,
        ));
        final pg = NotePage(
          id: 'pg1',
          notebookId: 'nb1',
          index: 0,
          template: PageTemplate.lined,
          pageSize: PageSize.a4,
        );
        await db.insertPage(pg);
        return pg;
      });
      if (page == null) fail('seed failed');

      final key = GlobalKey<DrawingCanvasState>();
      final toolState = ToolState()
        ..tool = ToolType.text
        ..stylusOnly = false;
      await tester.pumpWidget(_canvasHarness(
        page: page,
        toolState: toolState,
        key: key,
      ));
      await settle(tester);

      await tester.tapAt(const Offset(120, 160));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello Penfold');
      await tester.tap(find.byTooltip('Done'));
      await settle(tester);

      expect(find.byType(TextField), findsNothing);
      expect(key.currentState!.textBlockCountForTests, 1);
      expect(key.currentState!.textBlockTextsForTests, ['Hello Penfold']);

      final saved = await tester.runAsync(
          () => AppDatabase.instance.textBlocksOf('pg1'));
      expect(saved!.single.text, 'Hello Penfold');
    });
  });
}
