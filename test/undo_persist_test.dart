import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/drawing_canvas.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/screens/notebook_screen.dart';
import 'package:penfold/services/page_turn_mode_service.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n_test_harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Stroke _testStroke(String pageId, String id) => Stroke(
      id: id,
      pageId: pageId,
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 3,
      points: const [StrokePoint(10, 10, 0.5), StrokePoint(50, 50, 0.8)],
      z: 0,
    );

Widget _canvasHarness({
  required NotePage page,
  required GlobalKey<DrawingCanvasState> key,
}) {
  const viewport = Size(400, 560);
  final toolState = ToolState();
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
    PageTurnModeService.instance.resetForTests();
    resetPageUndoStoreForTests();
    resetClipboardForTests();
    tmp = await Directory.systemTemp.createTemp('penfold_undo_persist_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    resetPageUndoStoreForTests();
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('DrawingCanvas undo store', () {
    testWidgets('restores undo stack after widget dispose', (tester) async {
      final page = await tester.runAsync(() async {
        final db = AppDatabase.instance;
        final notebook = Notebook(
          id: 'nb-undo',
          title: 'Undo',
          coverColor: 0xFF2455C3,
          template: PageTemplate.lined,
          createdAt: 1,
          updatedAt: 1,
        );
        await db.insertNotebook(notebook);
        final pg = NotePage(
          id: 'pg-undo',
          notebookId: notebook.id,
          index: 0,
          template: PageTemplate.lined,
          pageSize: PageSize.a4,
        );
        await db.insertPage(pg);
        return pg;
      });
      if (page == null) fail('seed failed');

      final key = GlobalKey<DrawingCanvasState>();
      await tester.pumpWidget(_canvasHarness(page: page, key: key));
      await settle(tester);

      await tester.runAsync(() async {
        await key.currentState!.addUndoableStrokeForTests(
          _testStroke(page.id, 's1'),
        );
      });
      await tester.pump();
      expect(key.currentState!.canUndo, isTrue);
      expect(pageUndoStoreHasHistoryForTests(page.id), isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      final key2 = GlobalKey<DrawingCanvasState>();
      await tester.pumpWidget(_canvasHarness(page: page, key: key2));
      await settle(tester);

      expect(key2.currentState!.canUndo, isTrue);
      expect(key2.currentState!.strokeCountForTests, 1);
      await tester.runAsync(() async {
        await key2.currentState!.undo();
      });
      await tester.pump();
      expect(key2.currentState!.canUndo, isFalse);
      expect(key2.currentState!.strokeCountForTests, 0);
    });
  });

  group('NotebookScreen page switch', () {
    Future<Notebook> seedTwoPages() async {
      final db = AppDatabase.instance;
      final notebook = Notebook(
        id: 'nb-switch',
        title: 'Switch',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      );
      await db.insertNotebook(notebook);
      await db.insertPage(NotePage(
        id: 'pg-a',
        notebookId: notebook.id,
        index: 0,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
      ));
      await db.insertPage(NotePage(
        id: 'pg-b',
        notebookId: notebook.id,
        index: 1,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
      ));
      return notebook;
    }

    testWidgets('scroll mode keeps undo after switching pages', (tester) async {
      final notebook = (await tester.runAsync(seedTwoPages))!;
      await PageTurnModeService.instance.load();

      await tester.pumpWidget(
        wrapWithL10n(NotebookScreen(notebook: notebook)),
      );
      await settle(tester);

      final firstCanvas =
          tester.state<DrawingCanvasState>(find.byType(DrawingCanvas).first);
      await tester.runAsync(() async {
        await firstCanvas.addUndoableStrokeForTests(_testStroke('pg-a', 's-a'));
      });
      await tester.pump();
      expect(firstCanvas.canUndo, isTrue);

      final pageHeight = tester.getSize(find.byType(CustomScrollView)).height;
      await tester.drag(find.byType(CustomScrollView), Offset(0, -pageHeight));
      await settle(tester);

      await tester.drag(find.byType(CustomScrollView), Offset(0, pageHeight));
      await settle(tester);

      final canvasAgain =
          tester.state<DrawingCanvasState>(find.byType(DrawingCanvas).first);
      expect(canvasAgain.canUndo, isTrue);

      await tester.tap(find.byTooltip('Undo'));
      await settle(tester);
      expect(canvasAgain.strokeCountForTests, 0);
    });

    testWidgets('page-turn mode keeps undo after switching pages',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        PageTurnModeService.prefKey: true,
      });
      PageTurnModeService.instance.resetForTests();
      await PageTurnModeService.instance.load();

      final notebook = (await tester.runAsync(seedTwoPages))!;

      await tester.pumpWidget(
        wrapWithL10n(NotebookScreen(notebook: notebook)),
      );
      await settle(tester);

      final firstCanvas =
          tester.state<DrawingCanvasState>(find.byType(DrawingCanvas).first);
      await tester.runAsync(() async {
        await firstCanvas.addUndoableStrokeForTests(_testStroke('pg-a', 's-a'));
      });
      await tester.pump();
      expect(firstCanvas.canUndo, isTrue);

      await tester.drag(find.byType(PageView), const Offset(0, -400));
      await settle(tester);

      await tester.drag(find.byType(PageView), const Offset(0, 400));
      await settle(tester);

      final canvasAgain =
          tester.state<DrawingCanvasState>(find.byType(DrawingCanvas).first);
      expect(canvasAgain.canUndo, isTrue);
      await tester.runAsync(() async {
        await canvasAgain.undo();
      });
      await tester.pump();
      expect(canvasAgain.strokeCountForTests, 0);
    });
  });
}
