import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/drawing_canvas.dart';
import 'package:penfold/canvas/painters.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'l10n_test_harness.dart';
import 'widget_test.dart' show settle;

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
    tmp = await Directory.systemTemp.createTemp('penfold_erase_all_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('eraseAllStrokesOnPage', () {
    testWidgets('clears strokes and supports undo', (tester) async {
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
        await db.insertStroke(Stroke(
          id: 's1',
          pageId: 'pg1',
          tool: ToolType.pen,
          color: 0xFF000000,
          width: 3,
          points: const [StrokePoint(10, 10, 0.5)],
          z: 0,
        ));
        return pg;
      });
      if (page == null) fail('seed failed');

      final key = GlobalKey<DrawingCanvasState>();
      await tester.pumpWidget(_canvasHarness(page: page, key: key));
      await settle(tester);

      expect(key.currentState!.hasStrokes, isTrue);

      await tester.runAsync(() async {
        await key.currentState!.eraseAllStrokesOnPage();
      });
      await tester.pump();

      expect(key.currentState!.hasStrokes, isFalse);

      await tester.runAsync(() async {
        await key.currentState!.undo();
      });
      await tester.pump();

      expect(key.currentState!.hasStrokes, isTrue);
    });
  });

  group('BrushPreviewPainter', () {
    test('repaints when center or radius changes', () {
      final a = BrushPreviewPainter(
        center: const Offset(10, 10),
        radius: 8,
      );
      final b = BrushPreviewPainter(
        center: const Offset(20, 10),
        radius: 8,
      );
      final c = BrushPreviewPainter(
        center: const Offset(10, 10),
        radius: 12,
      );
      expect(a.shouldRepaint(b), isTrue);
      expect(a.shouldRepaint(c), isTrue);
      expect(a.shouldRepaint(a), isFalse);
    });
  });
}
