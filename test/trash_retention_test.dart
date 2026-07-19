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
    tmp = await Directory.systemTemp.createTemp('penfold_trash_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook _notebook({String id = 'nb1', String? folderId}) => Notebook(
        id: id,
        title: 'Trash test',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        folderId: folderId,
        createdAt: 1,
        updatedAt: 1,
      );

  Folder _folder({String id = 'f1'}) => Folder(
        id: id,
        name: 'Folder',
        sortOrder: 0,
      );

  test('purgeTrash removes notebooks past retention window', () async {
    final db = AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insertNotebook(_notebook());
    await db.softDeleteNotebook('nb1');

    final database = await db.db;
    await database.update(
      'notebooks',
      {'deleted_at': now - AppDatabase.trashRetention.inMilliseconds - 1000},
      where: 'id = ?',
      whereArgs: ['nb1'],
    );

    await db.purgeTrash(nowMs: now);

    final rows =
        await database.query('notebooks', where: 'id = ?', whereArgs: ['nb1']);
    expect(rows, isEmpty);
  });

  test('restoreNotebook clears deleted flag and orphaned folder', () async {
    final db = AppDatabase.instance;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insertFolder(_folder());
    await db.insertNotebook(_notebook(id: 'nb2', folderId: 'f1'));
    await db.softDeleteNotebook('nb2');

    final database = await db.db;
    await database.update(
      'folders',
      {'deleted_at': now},
      where: 'id = ?',
      whereArgs: ['f1'],
    );

    await db.restoreNotebook('nb2');

    final rows =
        await database.query('notebooks', where: 'id = ?', whereArgs: ['nb2']);
    expect(rows.single['deleted_at'], isNull);
    expect(rows.single['folder_id'], isNull);
  });

  test('emptyTrash permanently removes all trashed notebooks and folders',
      () async {
    final db = AppDatabase.instance;
    await db.insertFolder(_folder(id: 'f1'));
    await db.insertNotebook(_notebook(id: 'nb1', folderId: 'f1'));
    await db.insertNotebook(_notebook(id: 'nb2'));
    await db.softDeleteFolder('f1');
    await db.softDeleteNotebook('nb2');

    await db.emptyTrash();

    final database = await db.db;
    expect(await db.trashedNotebooks(), isEmpty);
    expect(await db.trashedFolders(), isEmpty);
    expect(
      await database.query('notebooks', where: 'id IN (?, ?)', whereArgs: ['nb1', 'nb2']),
      isEmpty,
    );
    expect(
      await database.query('folders', where: 'id = ?', whereArgs: ['f1']),
      isEmpty,
    );
  });
}
