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
    tmp = await Directory.systemTemp.createTemp('penfold_page_orientation_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb1',
        title: 'Orient',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage pg({PageOrientation orientation = PageOrientation.portrait}) =>
      NotePage(
        id: 'pg1',
        notebookId: 'nb1',
        index: 0,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        orientation: orientation,
      );

  test('orientation persists in database', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    await db.updatePageOrientation(
      'pg1',
      PageOrientation.landscape,
      PageOrientation.landscape.aspectOf(PageSize.a4),
    );
    final back = (await db.pagesOf('nb1')).single;
    expect(back.orientation, PageOrientation.landscape);
    expect(back.aspect, closeTo(PageSize.a4.height / PageSize.a4.width, 0.001));
  });

  test('landscape swaps canonical dimensions in PageCoords', () {
    final portrait = PageCoords.canonicalSize(PageSize.a4);
    final landscape =
        PageCoords.canonicalSize(PageSize.a4, orientation: PageOrientation.landscape);

    expect(portrait.width, PageSize.a4.width.toDouble());
    expect(portrait.height, PageSize.a4.height.toDouble());
    expect(landscape.width, PageSize.a4.height.toDouble());
    expect(landscape.height, PageSize.a4.width.toDouble());
  });

  test('landscape pageDisplaySize uses inverted aspect', () {
    const viewport = Size(800, 600);
    final portrait =
        PageCoords.pageDisplaySize(viewport, PageSize.a4);
    final landscape = PageCoords.pageDisplaySize(
      viewport,
      PageSize.a4,
      orientation: PageOrientation.landscape,
    );

    expect(portrait.width / portrait.height, closeTo(PageSize.a4.aspect, 0.01));
    expect(
      landscape.width / landscape.height,
      closeTo(PageSize.a4.height / PageSize.a4.width, 0.01),
    );
    expect(landscape.width, greaterThan(portrait.width));
    expect(landscape.height, lessThan(portrait.height));
  });

  test('canonical roundtrip works in landscape', () {
    const display = Size(594, 420);
    const original = Offset(120, 80);
    final canonical = PageCoords.displayToCanonical(
      original,
      display,
      PageSize.a4,
      orientation: PageOrientation.landscape,
    );
    final back = PageCoords.canonicalToDisplay(
      canonical,
      display,
      PageSize.a4,
      orientation: PageOrientation.landscape,
    );
    expect(back.dx, closeTo(original.dx, 0.01));
    expect(back.dy, closeTo(original.dy, 0.01));
  });

  test('NotePage row roundtrip includes orientation', () {
    final page = NotePage(
      id: 'p1',
      notebookId: 'nb1',
      index: 0,
      template: PageTemplate.blank,
      pageSize: PageSize.a5,
      orientation: PageOrientation.landscape,
    );
    final back = NotePage.fromRow(page.toRow());
    expect(back.orientation, PageOrientation.landscape);
    expect(back.aspect, closeTo(PageOrientation.landscape.aspectOf(PageSize.a5), 0.001));
  });

  test('orientation change remaps ink to fit new bounds', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());
    // Near bottom of portrait A4 (height 2970) — would be off landscape page.
    await db.insertStroke(Stroke(
      id: 's1',
      pageId: 'pg1',
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 3,
      points: const [
        StrokePoint(200, 2800, 0.5),
        StrokePoint(400, 2900, 0.5),
      ],
      z: 0,
    ));

    final page = (await db.pagesOf('nb1')).single;
    await db.updatePageOrientationAndRemapContent(
      page: page,
      to: PageOrientation.landscape,
    );

    final back = (await db.pagesOf('nb1')).single;
    expect(back.orientation, PageOrientation.landscape);

    final stroke = (await db.strokesOf('pg1')).single;
    final landscape =
        PageCoords.canonicalSize(PageSize.a4, orientation: PageOrientation.landscape);
    for (final pt in stroke.points) {
      expect(pt.x, inInclusiveRange(0, landscape.width));
      expect(pt.y, inInclusiveRange(0, landscape.height));
    }
    expect(stroke.points.first.x, isNot(200));
  });
}
