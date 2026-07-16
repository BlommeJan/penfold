import 'dart:io';
import 'dart:ui';

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
    tmp = await Directory.systemTemp.createTemp('penfold_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
      id: 'nb1',
      title: 'Physics',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 1,
      updatedAt: 1);

  NotePage pg({String id = 'pg1'}) => NotePage(
      id: id, notebookId: 'nb1', index: 0, template: PageTemplate.lined);

  Stroke stroke({String id = 's1', int z = 0}) => Stroke(
        id: id,
        pageId: 'pg1',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 3,
        points: const [StrokePoint(1, 2, 0.5), StrokePoint(3, 4, 0.8)],
        z: z,
      );

  test('notebook + page + stroke full lifecycle', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertStroke(stroke());
    await db.insertStroke(stroke(id: 's2', z: 1));

    expect((await db.notebooks()).length, 1);
    expect((await db.pagesOf('nb1')).length, 1);
    final strokes = await db.strokesOf('pg1');
    expect(strokes.length, 2);
    expect(strokes.first.z, 0); // z-ordered
    expect(strokes.first.points.length, 2);

    await db.deleteStrokes(['s1']);
    expect((await db.strokesOf('pg1')).length, 1);
  });

  test('cascade delete: removing notebook removes pages, strokes, images',
      () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertStroke(stroke());
    await db.insertImage(PageImage(
        id: 'img1',
        pageId: 'pg1',
        path: '/tmp/a.png',
        x: 0,
        y: 0,
        w: 100,
        h: 100,
        z: 0));

    await db.deleteNotebook('nb1');
    expect((await db.pagesOf('nb1')).length, 0);
    expect((await db.strokesOf('pg1')).length, 0);
    expect((await db.imagesOf('pg1')).length, 0);
  });

  test('stroke point update persists (lasso move)', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    final s = stroke();
    await db.insertStroke(s);
    s.translate(const Offset(10, 10));
    await db.updateStrokePoints(s);
    final back = (await db.strokesOf('pg1')).single;
    expect(back.points.first.x, 11);
    expect(back.points.first.y, 12);
  });

  test('image rect update persists (move/resize)', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    final img = PageImage(
        id: 'img1',
        pageId: 'pg1',
        path: '/tmp/a.png',
        x: 0,
        y: 0,
        w: 100,
        h: 50,
        z: 0);
    await db.insertImage(img);
    img.rect = const Rect.fromLTWH(20, 30, 200, 100);
    await db.updateImageRect(img);
    final back = (await db.imagesOf('pg1')).single;
    expect(back.rect, const Rect.fromLTWH(20, 30, 200, 100));
  });

  test('template update persists', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.updatePageTemplate('pg1', PageTemplate.dotted);
    final back = (await db.pagesOf('nb1')).single;
    expect(back.template, PageTemplate.dotted);
  });

  test('soft delete hides notebook from library but keeps pages', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    await db.insertStroke(stroke());

    await db.softDeleteNotebook('nb1');
    expect((await db.notebooks()).length, 0);
    expect((await db.trashedNotebooks()).length, 1);
    expect((await db.pagesOf('nb1')).length, 1);
    expect((await db.strokesOf('pg1')).length, 1);
  });
}
