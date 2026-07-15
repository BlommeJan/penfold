import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
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
    tmp = await Directory.systemTemp.createTemp('penfold_tags_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook notebook({String id = 'nb1', String? folderId}) => Notebook(
        id: id,
        title: 'Notebook $id',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        folderId: folderId,
        createdAt: 1,
        updatedAt: 1,
      );

  test('createTag and allTags', () async {
    final db = AppDatabase.instance;
    final tag = Tag(id: _uuid.v4(), name: 'School');
    await db.createTag(tag);

    final tags = await db.allTags();
    expect(tags.length, 1);
    expect(tags.first.name, 'School');
  });

  test('deleteTag removes tag and notebook associations', () async {
    final db = AppDatabase.instance;
    final tag = Tag(id: 'tag1', name: 'Work');
    await db.createTag(tag);
    await db.insertNotebook(notebook());
    await db.setNotebookTags('nb1', ['tag1']);

    await db.deleteTag('tag1');

    expect(await db.allTags(), isEmpty);
    expect(await db.tagsOfNotebook('nb1'), isEmpty);
  });

  test('tagsOfNotebook and setNotebookTags', () async {
    final db = AppDatabase.instance;
    final t1 = Tag(id: 't1', name: 'Math');
    final t2 = Tag(id: 't2', name: 'Physics');
    await db.createTag(t1);
    await db.createTag(t2);
    await db.insertNotebook(notebook());

    await db.setNotebookTags('nb1', ['t1', 't2']);
    final tags = await db.tagsOfNotebook('nb1');
    expect(tags.map((t) => t.name).toList(), ['Math', 'Physics']);

    await db.setNotebookTags('nb1', ['t2']);
    final updated = await db.tagsOfNotebook('nb1');
    expect(updated.length, 1);
    expect(updated.first.name, 'Physics');
  });

  test('notebooksWithTag filters by tag', () async {
    final db = AppDatabase.instance;
    final t1 = Tag(id: 't1', name: 'Exam');
    await db.createTag(t1);
    await db.insertNotebook(notebook(id: 'nb1'));
    await db.insertNotebook(notebook(id: 'nb2'));
    await db.insertNotebook(notebook(id: 'nb3'));
    await db.setNotebookTags('nb1', ['t1']);
    await db.setNotebookTags('nb3', ['t1']);

    final tagged = await db.notebooksWithTag('t1');
    expect(tagged.map((n) => n.id).toSet(), {'nb1', 'nb3'});
  });

  test('tag filter intersects with folder context', () async {
    final db = AppDatabase.instance;
    final folder = Folder(id: 'f1', name: 'Classes', sortOrder: 0);
    final tag = Tag(id: 't1', name: 'Review');
    await db.insertFolder(folder);
    await db.createTag(tag);
    await db.insertNotebook(notebook(id: 'nb1', folderId: 'f1'));
    await db.insertNotebook(notebook(id: 'nb2'));
    await db.setNotebookTags('nb1', ['t1']);
    await db.setNotebookTags('nb2', ['t1']);

    final inFolder = await db.notebooks(folderId: 'f1');
    final tagged = await db.notebooksWithTag('t1');
    final taggedIds = tagged.map((n) => n.id).toSet();
    final filtered =
        inFolder.where((n) => taggedIds.contains(n.id)).toList();

    expect(filtered.length, 1);
    expect(filtered.first.id, 'nb1');
  });
}
