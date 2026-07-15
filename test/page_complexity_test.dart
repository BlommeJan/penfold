import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/page_complexity_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_page_complexity_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb-pc',
        title: 'Complexity',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage pg({String id = 'pg1', int index = 0}) => NotePage(
        id: id,
        notebookId: 'nb-pc',
        index: index,
        template: PageTemplate.grid,
        pageSize: PageSize.a5,
        orientation: PageOrientation.landscape,
      );

  Stroke stroke(String id, int z) => Stroke(
        id: id,
        pageId: 'pg1',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 2,
        points: [StrokePoint(z.toDouble(), z.toDouble(), 0.5)],
        z: z,
      );

  group('PageComplexityService', () {
    test('shouldWarn at and above threshold', () {
      expect(PageComplexityService.shouldWarn(1999), isFalse);
      expect(PageComplexityService.shouldWarn(2000), isTrue);
      expect(PageComplexityService.shouldWarn(2500), isTrue);
    });

    test('warningMessage includes stroke count', () {
      expect(
        PageComplexityService.warningMessage(2000),
        contains('2000'),
      );
    });
  });

  test('countStrokes returns stroke total for page', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertStroke(stroke('s1', 0));
    await db.insertStroke(stroke('s2', 1));

    expect(await db.countStrokes('pg1'), 2);
    expect(await PageComplexityService.instance.strokeCount('pg1'), 2);
  });

  test('splitPage moves upper half and duplicates template', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertPage(pg(id: 'pg2', index: 1));

    for (var i = 0; i < 6; i++) {
      await db.insertStroke(stroke('s$i', i));
    }

    final newPageId = _uuid.v4();
    final result = await PageComplexityService.instance.splitPage(
      notebookId: 'nb-pc',
      sourcePageId: 'pg1',
      newPageId: newPageId,
    );

    expect(result.movedStrokeCount, 3);
    expect(result.remainingStrokeCount, 3);
    expect(result.newPage.template, PageTemplate.grid);
    expect(result.newPage.pageSize, PageSize.a5);
    expect(result.newPage.orientation, PageOrientation.landscape);

    final pages = await db.pagesOf('nb-pc');
    expect(pages.length, 3);
    expect(pages.map((p) => p.id).toList(), ['pg1', newPageId, 'pg2']);
    expect(pages[1].index, 1);
    expect(pages[2].index, 2);

    final sourceStrokes = await db.strokesOf('pg1');
    final newStrokes = await db.strokesOf(newPageId);
    expect(sourceStrokes.map((s) => s.id).toList(), ['s0', 's1', 's2']);
    expect(newStrokes.map((s) => s.id).toList(), ['s3', 's4', 's5']);
  });

  test('splitPage updates ink_index page_id for moved strokes', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertStroke(stroke('s0', 0));
    await db.insertStroke(stroke('s1', 1));
    await db.insertStroke(stroke('s2', 2));
    await db.insertStroke(stroke('s3', 3));

    await db.insertInkIndexPending(
      id: 'ix0',
      pageId: 'pg1',
      strokeId: 's0',
    );
    await db.insertInkIndexPending(
      id: 'ix3',
      pageId: 'pg1',
      strokeId: 's3',
    );
    await db.updateInkIndexResult(
      id: 'ix0',
      text: 'Alpha',
      status: InkIndexStatus.indexed,
    );
    await db.updateInkIndexResult(
      id: 'ix3',
      text: 'Delta',
      status: InkIndexStatus.indexed,
    );

    final newPageId = _uuid.v4();
    await PageComplexityService.instance.splitPage(
      notebookId: 'nb-pc',
      sourcePageId: 'pg1',
      newPageId: newPageId,
    );

    final sourceInk = await db.indexedInkTextOfPage('pg1');
    final newInk = await db.indexedInkTextOfPage(newPageId);
    expect(sourceInk.map((e) => e.strokeId).toList(), ['s0']);
    expect(newInk.map((e) => e.strokeId).toList(), ['s3']);
  });

  test('splitPage requires at least two strokes', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertStroke(stroke('s0', 0));

    expect(
      () => PageComplexityService.instance.splitPage(
        notebookId: 'nb-pc',
        sourcePageId: 'pg1',
        newPageId: _uuid.v4(),
      ),
      throwsStateError,
    );
  });
}
