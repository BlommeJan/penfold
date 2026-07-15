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
    tmp = await Directory.systemTemp.createTemp('penfold_bookmarks_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb1',
        title: 'Bookmarks',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage pg({required String id, required int index, bool bookmarked = false}) =>
      NotePage(
        id: id,
        notebookId: 'nb1',
        index: index,
        template: PageTemplate.lined,
        bookmarked: bookmarked,
      );

  test('bookmarkedPageIndices returns bookmarked pages in order', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg(id: 'p0', index: 0));
    await db.insertPage(pg(id: 'p1', index: 1, bookmarked: true));
    await db.insertPage(pg(id: 'p2', index: 2));
    await db.insertPage(pg(id: 'p3', index: 3, bookmarked: true));
    await db.insertPage(pg(id: 'p4', index: 4, bookmarked: true));

    expect(await db.bookmarkedPageIndices('nb1'), [1, 3, 4]);
  });

  test('setPageBookmarked persists and pagesOf loads bookmarked field', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg(id: 'p0', index: 0));
    await db.insertPage(pg(id: 'p1', index: 1));

    await db.setPageBookmarked('p1', true);
    expect(await db.bookmarkedPageIndices('nb1'), [1]);

    final pages = await db.pagesOf('nb1');
    expect(pages[0].bookmarked, isFalse);
    expect(pages[1].bookmarked, isTrue);

    await db.setPageBookmarked('p1', false);
    expect(await db.bookmarkedPageIndices('nb1'), isEmpty);
    expect((await db.pagesOf('nb1'))[1].bookmarked, isFalse);
  });

  test('bookmarkedPageIndices is empty when no bookmarks', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg(id: 'p0', index: 0));
    await db.insertPage(pg(id: 'p1', index: 1));

    expect(await db.bookmarkedPageIndices('nb1'), isEmpty);
  });
}
