import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/gesture_ink_recognizer.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/gesture_ink_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Stroke _horizontalStroke({
  String id = 's1',
  String pageId = 'p1',
  int z = 1,
}) =>
    Stroke(
      id: id,
      pageId: pageId,
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 4,
      points: const [
        StrokePoint(20, 50, 0.5),
        StrokePoint(120, 50, 0.5),
      ],
      z: z,
    );

List<Offset> _scratchOverWord() => const [
      Offset(25, 48),
      Offset(45, 52),
      Offset(30, 48),
      Offset(55, 52),
      Offset(35, 48),
      Offset(70, 52),
      Offset(40, 48),
    ];

List<Offset> _smoothWriteLine() => const [
      Offset(20, 50),
      Offset(40, 50),
      Offset(60, 50),
      Offset(80, 50),
      Offset(100, 50),
      Offset(120, 50),
    ];

void main() {
  late Directory tmp;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GestureInkService.instance.resetForTests();
    tmp = await Directory.systemTemp.createTemp('penfold_gesture_ink_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('isScratchGesture', () {
    test('detects zigzag scratch', () {
      expect(isScratchGesture(_scratchOverWord()), isTrue);
    });

    test('rejects smooth horizontal writing', () {
      expect(isScratchGesture(_smoothWriteLine()), isFalse);
    });

    test('rejects too-short path', () {
      expect(
        isScratchGesture(const [
          Offset(0, 0),
          Offset(5, 2),
          Offset(2, 0),
        ]),
        isFalse,
      );
    });
  });

  group('findScratchDeleteTarget', () {
    test('returns indexed stroke under scratch', () {
      final stroke = _horizontalStroke();
      final target = findScratchDeleteTarget(
        canonicalPath: _scratchOverWord(),
        strokes: [stroke],
        indexedStrokeIds: {stroke.id},
      );
      expect(target?.id, stroke.id);
    });

    test('ignores non-indexed strokes', () {
      final stroke = _horizontalStroke();
      final target = findScratchDeleteTarget(
        canonicalPath: _scratchOverWord(),
        strokes: [stroke],
        indexedStrokeIds: {},
      );
      expect(target, isNull);
    });

    test('ignores pending-index strokes', () {
      final stroke = _horizontalStroke();
      final target = findScratchDeleteTarget(
        canonicalPath: _scratchOverWord(),
        strokes: [stroke],
        indexedStrokeIds: {'other-id'},
      );
      expect(target, isNull);
    });

    test('picks topmost z when multiple overlap', () {
      final low = _horizontalStroke(id: 'low', z: 1);
      final high = _horizontalStroke(id: 'high', z: 5);
      final target = findScratchDeleteTarget(
        canonicalPath: _scratchOverWord(),
        strokes: [low, high],
        indexedStrokeIds: {low.id, high.id},
      );
      expect(target?.id, high.id);
    });

    test('returns null for normal writing over indexed ink', () {
      final stroke = _horizontalStroke();
      final target = findScratchDeleteTarget(
        canonicalPath: _smoothWriteLine(),
        strokes: [stroke],
        indexedStrokeIds: {stroke.id},
      );
      expect(target, isNull);
    });
  });

  group('indexedStrokeIdsOfPage', () {
    test('returns only indexed stroke ids', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-gi',
        title: 'Gesture NB',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      final page = NotePage(
        id: 'pg-gi',
        notebookId: nb.id,
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      await db.insertStroke(_horizontalStroke(id: 'indexed', pageId: page.id));
      await db.insertStroke(_horizontalStroke(id: 'plain', pageId: page.id));
      await db.insertInkIndexForTest(
        id: 'idx-1',
        pageId: page.id,
        strokeId: 'indexed',
        text: 'hello',
      );
      await db.insertInkIndexPending(
        id: 'idx-pending',
        pageId: page.id,
        strokeId: 'plain',
      );

      final ids = await db.indexedStrokeIdsOfPage(page.id);
      expect(ids, {'indexed'});
    });
  });

  group('GestureInkService', () {
    test('defaults to enabled', () async {
      await GestureInkService.instance.load();
      expect(GestureInkService.instance.enabled, isTrue);
    });

    test('persists disabled state', () async {
      await GestureInkService.instance.load();
      await GestureInkService.instance.setEnabled(false);
      GestureInkService.instance.resetForTests();
      await GestureInkService.instance.load();
      expect(GestureInkService.instance.enabled, isFalse);
    });
  });
}
