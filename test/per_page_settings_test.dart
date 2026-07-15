import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/page_coords.dart';
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
    tmp = await Directory.systemTemp.createTemp('penfold_per_page_settings_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb1',
        title: 'Settings',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage pg({PageSize pageSize = PageSize.a4}) => NotePage(
        id: 'pg1',
        notebookId: 'nb1',
        index: 0,
        template: PageTemplate.lined,
        pageSize: pageSize,
      );

  Stroke stroke() => Stroke(
        id: 's1',
        pageId: 'pg1',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 3,
        points: const [StrokePoint(100, 200, 0.5)],
        z: 0,
      );

  test('page size update persists', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    await db.updatePageSize('pg1', PageSize.a5);
    final back = (await db.pagesOf('nb1')).single;
    expect(back.pageSize, PageSize.a5);
  });

  test('pageHasInk detects strokes, text, and images', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    expect(await db.pageHasInk('pg1'), isFalse);

    await db.insertStroke(stroke());
    expect(await db.pageHasInk('pg1'), isTrue);

    await db.deleteStrokes(['s1']);
    expect(await db.pageHasInk('pg1'), isFalse);

    await db.insertTextBlock(TextBlock(
      id: 'tb1',
      pageId: 'pg1',
      text: 'Hello',
      x: 10,
      y: 20,
      w: 100,
      h: 30,
      fontSize: 16,
      color: 0xFF000000,
      z: 0,
    ));
    expect(await db.pageHasInk('pg1'), isTrue);

    await db.deleteTextBlock('tb1');
    expect(await db.pageHasInk('pg1'), isFalse);

    await db.insertImage(PageImage(
      id: 'img1',
      pageId: 'pg1',
      path: '/tmp/a.png',
      x: 0,
      y: 0,
      w: 100,
      h: 100,
      z: 0,
    ));
    expect(await db.pageHasInk('pg1'), isTrue);
  });

  test('size change keeps canonical ink coords', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg(pageSize: PageSize.a4));
    await db.insertStroke(stroke());

    const display = Size(400, 566);
    const canonical = Offset(100, 200);
    final a4Display = PageCoords.canonicalToDisplay(
      canonical,
      display,
      PageSize.a4,
    );

    await db.updatePageSize('pg1', PageSize.a5);
    final a5Display = PageCoords.canonicalToDisplay(
      canonical,
      display,
      PageSize.a5,
    );

    expect(a4Display, isNot(equals(a5Display)));
    final back = (await db.strokesOf('pg1')).single;
    expect(back.points.single.x, 100);
    expect(back.points.single.y, 200);
  });

  test('template and page size are independent per page', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    await db.updatePageTemplate('pg1', PageTemplate.grid);
    await db.updatePageSize('pg1', PageSize.letter);

    final back = (await db.pagesOf('nb1')).single;
    expect(back.template, PageTemplate.grid);
    expect(back.pageSize, PageSize.letter);
  });
}
