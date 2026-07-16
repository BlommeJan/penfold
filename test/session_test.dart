import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/session_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_session_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  test('SessionService save and load roundtrip', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: 'nb-svc',
      title: 'Service Test',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 1,
      updatedAt: 1,
    );
    await db.insertNotebook(notebook);

    await SessionService.instance.save(
      notebookId: notebook.id,
      pageIndex: 5,
      scrollOffset: 128.25,
      tool: ToolType.eraser,
    );

    final session = await SessionService.instance.load();
    expect(session, isNotNull);
    expect(session!.notebookId, notebook.id);
    expect(session.pageIndex, 5);
    expect(session.scrollOffset, closeTo(128.25, 0.01));
    expect(session.tool, ToolType.eraser);
  });

  test('SessionService clear removes stored session', () async {
    await SessionService.instance.save(
      notebookId: 'nb1',
      pageIndex: 2,
      scrollOffset: 10,
      tool: ToolType.pen,
    );
    await SessionService.instance.clear();
    expect(await SessionService.instance.load(), isNull);
  });

  test('session survives simulated restart (persist then reload)', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: 'nb-restart',
      title: 'Restart Test',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 1,
      updatedAt: 1,
    );
    await db.insertNotebook(notebook);

    await SessionService.instance.save(
      notebookId: notebook.id,
      pageIndex: 7,
      scrollOffset: 0,
      tool: ToolType.highlighter,
    );

    await db.resetForTests();
    AppDatabase.overrideDirPath = tmp.path;

    final restored = await SessionService.instance.load();
    expect(restored, isNotNull);
    expect(restored!.notebookId, notebook.id);
    expect(restored.pageIndex, 7);
    expect(restored.tool, ToolType.highlighter);
  });

  test('saveSession and loadSession roundtrip', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: 'nb-session',
      title: 'Session Test',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 1,
      updatedAt: 1,
    );
    await db.insertNotebook(notebook);

    await db.saveSession(
      notebookId: notebook.id,
      pageIndex: 3,
      scrollOffset: 420.5,
      tool: ToolType.highlighter,
    );

    final session = await db.loadSession();
    expect(session, isNotNull);
    expect(session!.notebookId, notebook.id);
    expect(session.pageIndex, 3);
    expect(session.scrollOffset, closeTo(420.5, 0.01));
    expect(session.tool, ToolType.highlighter);
  });

  test('notebookById returns notebook or null', () async {
    final db = AppDatabase.instance;
    expect(await db.notebookById('missing'), isNull);

    final notebook = Notebook(
      id: 'nb-lookup',
      title: 'Lookup',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 1,
      updatedAt: 1,
    );
    await db.insertNotebook(notebook);
    final found = await db.notebookById('nb-lookup');
    expect(found?.title, 'Lookup');
  });

  test('clearSession removes stored session', () async {
    final db = AppDatabase.instance;
    await db.saveSession(
      notebookId: 'nb1',
      pageIndex: 0,
      scrollOffset: 0,
      tool: ToolType.pen,
    );
    await db.clearSession();
    expect(await db.loadSession(), isNull);
  });

  test('schema v12 migration creates session table', () async {
    final dbPath = '${tmp.path}/migrate_v11.db';
    final v11 = await openDatabase(
      dbPath,
      version: 11,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE notebooks(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            color INTEGER NOT NULL,
            template INTEGER NOT NULL,
            page_size INTEGER NOT NULL DEFAULT 0,
            folder_id TEXT,
            created INTEGER NOT NULL,
            updated INTEGER NOT NULL
          )''');
      },
    );
    await v11.close();

    AppDatabase.overrideDirPath = tmp.path;
    await AppDatabase.instance.resetForTests();
    final db = await AppDatabase.instance.db;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='session'",
    );
    expect(tables, isNotEmpty);
    await AppDatabase.instance.resetForTests();
  });
}
