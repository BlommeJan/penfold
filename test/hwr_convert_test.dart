import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/hwr_convert.dart';
import 'package:penfold/services/ink_ocr_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Stroke _penStroke(
  String id,
  String pageId, {
  List<StrokePoint>? points,
  int z = 1,
}) =>
    Stroke(
      id: id,
      pageId: pageId,
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 3,
      points: points ??
          const [
            StrokePoint(100, 100, 0.5),
            StrokePoint(200, 120, 0.5),
            StrokePoint(280, 110, 0.5),
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
    tmp = await Directory.systemTemp.createTemp('penfold_hwr_convert_test');
    AppDatabase.overrideDirPath = tmp.path;
    InkOcrService.testSelectionRecognitionResult = null;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('canConvertInkSelection', () {
    test('true when pen ink is selected', () {
      final strokes = [_penStroke('s1', 'pg')];
      expect(canConvertInkSelection({'s1'}, strokes), isTrue);
    });

    test('false when only tape is selected', () {
      final tape = Stroke(
        id: 't1',
        pageId: 'pg',
        tool: ToolType.tape,
        color: 0xFFE8E0D0,
        width: 24,
        points: const [
          StrokePoint(10, 10, 0.5),
          StrokePoint(50, 10, 0.5),
        ],
        z: 1,
      );
      expect(canConvertInkSelection({'t1'}, [tape]), isFalse);
    });

    test('false when selection is empty', () {
      expect(canConvertInkSelection({}, [_penStroke('s1', 'pg')]), isFalse);
    });
  });

  group('inkBoundsForSelection', () {
    test('unions bounds of selected ink strokes', () {
      final s1 = _penStroke(
        's1',
        'pg',
        points: const [
          StrokePoint(10, 10, 0.5),
          StrokePoint(30, 10, 0.5),
        ],
      );
      final s2 = _penStroke(
        's2',
        'pg',
        points: const [
          StrokePoint(50, 40, 0.5),
          StrokePoint(80, 50, 0.5),
        ],
      );
      final b1 = s1.bounds;
      final b2 = s2.bounds;
      final bounds = inkBoundsForSelection({'s1', 's2'}, [s1, s2]);
      expect(bounds, isNotNull);
      expect(bounds!.width, greaterThan(b1.width));
      expect(bounds.height, greaterThan(b1.height));
      expect(bounds.left, lessThanOrEqualTo(b1.left));
      expect(bounds.right, greaterThanOrEqualTo(b2.right));
    });
  });

  group('buildHwrTextBlock', () {
    test('places text at selection bounds', () {
      const bounds = Rect.fromLTWH(100, 200, 180, 40);
      final block = buildHwrTextBlock(
        id: 'tb1',
        pageId: 'pg',
        text: 'Hello',
        bounds: bounds,
        fontSize: 12,
        color: 0xFF000000,
        z: 3,
        measuredSize: const Size(120, 30),
      );
      expect(block.x, 100);
      expect(block.y, 200);
      expect(block.w, 180);
      expect(block.h, 40);
      expect(block.text, 'Hello');
    });
  });

  group('recognizeSelection', () {
    test('returns test hook result with dictionary correction', () async {
      final db = AppDatabase.instance;
      await db.addOcrTerm('eigenvalue');
      InkOcrService.testSelectionRecognitionResult = 'e1genvalue';

      final stroke = _penStroke('s1', 'pg');
      final bounds = inkBoundsForSelection({'s1'}, [stroke])!;
      final text = await InkOcrService.instance.recognizeSelection(
        [stroke],
        bounds,
      );
      expect(text, 'eigenvalue');
    });

    test('returns null when recognition is empty', () async {
      InkOcrService.testSelectionRecognitionResult = null;
      final stroke = _penStroke('s1', 'pg');
      final bounds = stroke.bounds;
      final text = await InkOcrService.instance.recognizeSelection(
        [stroke],
        bounds,
      );
      expect(text, isNull);
    });

    test('ignores non-ink strokes', () async {
      InkOcrService.testSelectionRecognitionResult = 'hello';
      final tape = Stroke(
        id: 't1',
        pageId: 'pg',
        tool: ToolType.tape,
        color: 0xFFE8E0D0,
        width: 24,
        points: const [
          StrokePoint(10, 10, 0.5),
          StrokePoint(50, 10, 0.5),
        ],
        z: 1,
      );
      final text = await InkOcrService.instance.recognizeSelection(
        [tape],
        tape.bounds,
      );
      expect(text, isNull);
    });
  });

  group('text block insert keeps ink', () {
    test('persisted text block does not remove source strokes', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-hwr',
        title: 'HWR NB',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      final page = NotePage(
        id: 'pg-hwr',
        notebookId: nb.id,
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      final stroke = _penStroke('s1', page.id);
      await db.insertStroke(stroke);

      InkOcrService.testSelectionRecognitionResult = 'Hello world';
      final bounds = inkBoundsForSelection({'s1'}, [stroke])!;
      final text = await InkOcrService.instance.recognizeSelection(
        [stroke],
        bounds,
      );
      expect(text, 'Hello world');

      final block = buildHwrTextBlock(
        id: 'tb-hwr',
        pageId: page.id,
        text: text!,
        bounds: bounds,
        fontSize: 12,
        color: 0xFF1A1A1A,
        z: 2,
      );
      await db.insertTextBlock(block);

      final strokesAfter = await db.strokesOf(page.id);
      expect(strokesAfter.length, 1);
      expect(strokesAfter.single.id, 's1');

      final texts = await db.textBlocksOf(page.id);
      expect(texts.length, 1);
      expect(texts.single.text, 'Hello world');
    });
  });
}
