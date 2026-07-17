import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/ink_ocr_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Stroke _testStroke(String id, String pageId, {int z = 1}) => Stroke(
      id: id,
      pageId: pageId,
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 3,
      points: const [
        StrokePoint(10, 10, 0.5),
        StrokePoint(20, 20, 0.5),
      ],
      z: z,
    );

void main() {
  late Directory tmp;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    InkOcrService.disableMlKit = true;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_ocr_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('ink_index schema', () {
    test('v4 migration creates ink_index table', () async {
      final database = await AppDatabase.instance.db;
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ink_index'",
      );
      expect(tables.length, 1);
    });

    test('indexed ink text appears in notebook search', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-ocr',
        title: 'OCR Notebook',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      final page = NotePage(
        id: 'pg-ocr',
        notebookId: nb.id,
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      await db.insertStroke(_testStroke('stroke-1', page.id));
      await db.insertInkIndexForTest(
        id: 'idx-1',
        pageId: page.id,
        strokeId: 'stroke-1',
        text: 'quantummechanics',
      );

      final hits = await db.searchNotebooks('quantummechanics');
      expect(hits.any((h) => h.notebook.id == nb.id), isTrue);
    });

    test('ocrStatusOfPage counts statuses', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-st',
        title: 'Status NB',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      final page = NotePage(
        id: 'pg-st',
        notebookId: nb.id,
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      await db.insertStroke(_testStroke('s1', page.id));
      await db.insertStroke(_testStroke('s2', page.id, z: 2));
      await db.insertInkIndexForTest(
        id: 'i1',
        pageId: page.id,
        strokeId: 's1',
        text: 'hello',
      );
      await db.insertInkIndexPending(
        id: 'i2',
        pageId: page.id,
        strokeId: 's2',
      );

      final status = await db.ocrStatusOfPage(page.id);
      expect(status.indexed, 1);
      expect(status.pending, 1);
      expect(status.hasInk, isTrue);
    });
  });

  group('model download helpers', () {
    test('download timeout is 120 seconds', () {
      expect(inkRecognitionModelDownloadTimeout.inSeconds, 120);
    });

    test('resetModelEnsure clears downloading state', () {
      final ocr = InkOcrService.instance;
      ocr.modelStatus = InkModelStatus.downloading;
      ocr.resetModelEnsure();
      expect(ocr.modelStatus, InkModelStatus.notReady);
    });
  });
}
