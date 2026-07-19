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
    tmp = await Directory.systemTemp.createTemp('penfold_library_view_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook notebook({
    required String id,
    String title = 'Notebook',
    String? folderId,
  }) =>
      Notebook(
        id: id,
        title: title,
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        folderId: folderId,
        createdAt: 1,
        updatedAt: 1,
      );

  Future<void> seedLibrary(AppDatabase db) async {
    await db.insertFolder(Folder(id: 'f1', name: 'Work', sortOrder: 0));
    await db.insertFolder(
      Folder(id: 'f2', name: 'Nested', sortOrder: 0, parentId: 'f1'),
    );
    await db.insertNotebook(notebook(id: 'root', title: 'Root note'));
    await db.insertNotebook(
      notebook(id: 'work', title: 'Work note', folderId: 'f1'),
    );
    await db.insertNotebook(
      notebook(id: 'nested', title: 'Nested note', folderId: 'f2'),
    );
  }

  test('All view uses every active notebook', () async {
    final db = AppDatabase.instance;
    await seedLibrary(db);

    final all = await db.notebooks();
    expect(all.map((n) => n.id).toList(), containsAll(['root', 'work', 'nested']));
    expect(all.length, 3);
  });

  test('Overview root shows only uncategorized notebooks', () async {
    final db = AppDatabase.instance;
    await seedLibrary(db);

    final uncategorized = await db.notebooks(folderId: '');
    expect(uncategorized.map((n) => n.id).toList(), ['root']);
  });

  test('Overview root lists top-level folders only', () async {
    final db = AppDatabase.instance;
    await seedLibrary(db);

    final topLevel = await db.folders();
    expect(topLevel.map((f) => f.id).toList(), ['f1']);
  });

  test('Overview inside folder lists child folders and folder notebooks',
      () async {
    final db = AppDatabase.instance;
    await seedLibrary(db);

    final childFolders = await db.folders(parentId: 'f1');
    expect(childFolders.map((f) => f.id).toList(), ['f2']);

    final inFolder = await db.notebooks(folderId: 'f1');
    expect(inFolder.map((n) => n.id).toList(), ['work']);
  });

  test('tag filter intersects with view-specific notebook lists', () async {
    final db = AppDatabase.instance;
    await seedLibrary(db);
    await db.createTag(Tag(id: 't1', name: 'School'));
    await db.setNotebookTags('root', ['t1']);
    await db.setNotebookTags('work', ['t1']);

    final taggedIds =
        (await db.notebooksWithTag('t1')).map((n) => n.id).toSet();
    final uncategorized =
        (await db.notebooks(folderId: '')).where((n) => taggedIds.contains(n.id));
    expect(uncategorized.map((n) => n.id).toList(), ['root']);

    final allTagged =
        (await db.notebooks()).where((n) => taggedIds.contains(n.id));
    expect(allTagged.map((n) => n.id).toList(), containsAll(['root', 'work']));
    expect(allTagged.length, 2);
  });
}
