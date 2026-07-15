import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_page_reorder_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb1',
        title: 'Reorder',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage pg({required String id, required int index}) => NotePage(
        id: id,
        notebookId: 'nb1',
        index: index,
        template: PageTemplate.lined,
      );

  Future<void> seedPages(AppDatabase db) async {
    await db.insertNotebook(nb());
    await db.insertPage(pg(id: 'p0', index: 0));
    await db.insertPage(pg(id: 'p1', index: 1));
    await db.insertPage(pg(id: 'p2', index: 2));
    await db.insertPage(pg(id: 'p3', index: 3));
  }

  test('reorderPages updates idx in transaction', () async {
    final db = AppDatabase.instance;
    await seedPages(db);

    await db.reorderPages('nb1', ['p3', 'p1', 'p0', 'p2']);

    final pages = await db.pagesOf('nb1');
    expect(pages.map((p) => p.id).toList(), ['p3', 'p1', 'p0', 'p2']);
    expect(pages.map((p) => p.index).toList(), [0, 1, 2, 3]);
  });

  test('deletePagesBatch removes pages and compacts idx', () async {
    final db = AppDatabase.instance;
    await seedPages(db);
    await db.insertStroke(Stroke(
      id: 's1',
      pageId: 'p1',
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 2,
      points: const [StrokePoint(1, 1, 0.5)],
      z: 0,
    ));
    await db.insertTextBlock(TextBlock(
      id: 't1',
      pageId: 'p2',
      x: 0,
      y: 0,
      w: 100,
      h: 20,
      text: 'hello',
      fontSize: 14,
      color: 0xFF000000,
      z: 0,
    ));

    await db.deletePagesBatch('nb1', ['p1', 'p2']);

    expect((await db.pagesOf('nb1')).map((p) => p.id).toList(), ['p0', 'p3']);
    expect((await db.pagesOf('nb1')).map((p) => p.index).toList(), [0, 1]);
    expect(await db.strokesOf('p1'), isEmpty);
    expect(await db.textBlocksOf('p2'), isEmpty);
  });

  test('deletePagesBatch refreshes search index', () async {
    final db = AppDatabase.instance;
    await seedPages(db);
    await db.insertTextBlock(TextBlock(
      id: 't1',
      pageId: 'p0',
      x: 0,
      y: 0,
      w: 100,
      h: 20,
      text: 'findme',
      fontSize: 14,
      color: 0xFF000000,
      z: 0,
    ));
    await db.insertTextBlock(TextBlock(
      id: 't2',
      pageId: 'p1',
      x: 0,
      y: 0,
      w: 100,
      h: 20,
      text: 'removeme',
      fontSize: 14,
      color: 0xFF000000,
      z: 0,
    ));

    await db.deletePagesBatch('nb1', ['p1']);

    final hits = await db.searchNotebooks('removeme');
    expect(hits, isEmpty);
    final kept = await db.searchNotebooks('findme');
    expect(kept, isNotEmpty);
  });

  test('reorderPages is no-op for empty id list', () async {
    final db = AppDatabase.instance;
    await seedPages(db);

    await db.reorderPages('nb1', []);

    final pages = await db.pagesOf('nb1');
    expect(pages.map((p) => p.id).toList(), ['p0', 'p1', 'p2', 'p3']);
  });
}
