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
    tmp = await Directory.systemTemp.createTemp('penfold_tape_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook notebook() => Notebook(
        id: 'nb1',
        title: 'Study',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage page() => NotePage(
        id: 'pg1',
        notebookId: 'nb1',
        index: 0,
        template: PageTemplate.lined,
      );

  Stroke tapeStroke({String id = 'tape1', bool hidden = false, int z = 0}) =>
      Stroke(
        id: id,
        pageId: 'pg1',
        tool: ToolType.tape,
        color: 0xFFE8E0D0,
        width: 24,
        points: const [
          StrokePoint(100, 100, 0.8),
          StrokePoint(300, 120, 0.8),
        ],
        z: z,
        hidden: hidden,
      );

  test('insert and load tape stroke with hidden flag', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(notebook());
    await db.insertPage(page());

    final stroke = tapeStroke(hidden: false);
    await db.insertStroke(stroke);

    final loaded = await db.strokesOf('pg1');
    expect(loaded.length, 1);
    expect(loaded.first.tool, ToolType.tape);
    expect(loaded.first.hidden, isFalse);
    expect(loaded.first.color, 0xFFE8E0D0);
  });

  test('stroke row roundtrip preserves tape tool and hidden', () async {
    final original = tapeStroke(hidden: true);
    final row = original.toRow();
    expect(row['tool'], ToolType.tape.index);
    expect(row['hidden'], 1);

    final back = Stroke.fromRow(row);
    expect(back.tool, ToolType.tape);
    expect(back.hidden, isTrue);
    expect(back.points.length, 2);
  });

  test('updateStrokeHidden toggles reveal state in database', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(notebook());
    await db.insertPage(page());

    final stroke = tapeStroke();
    await db.insertStroke(stroke);

    stroke.hidden = true;
    await db.updateStrokeHidden(stroke);

    final loaded = await db.strokesOf('pg1');
    expect(loaded.single.hidden, isTrue);

    stroke.hidden = false;
    await db.updateStrokeHidden(stroke);

    final reloaded = await db.strokesOf('pg1');
    expect(reloaded.single.hidden, isFalse);
  });

  test('schema migration adds hidden column to strokes', () async {
    final dbPath = '${tmp.path}/penfold.db';
    final v8 = await openDatabase(dbPath, version: 8, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE strokes(
          id TEXT PRIMARY KEY,
          page_id TEXT NOT NULL,
          tool INTEGER NOT NULL,
          brush_style INTEGER NOT NULL DEFAULT 0,
          color INTEGER NOT NULL,
          width REAL NOT NULL,
          points TEXT NOT NULL,
          z INTEGER NOT NULL
        )''');
      await db.insert('strokes', {
        'id': 'legacy',
        'page_id': 'pg1',
        'tool': ToolType.pen.index,
        'brush_style': 0,
        'color': 0xFF000000,
        'width': 3.0,
        'points': '[[1,2,0.5]]',
        'z': 0,
      });
    });
    await v8.close();

    final db = AppDatabase.instance;
    final database = await db.db;
    final info = await database.rawQuery('PRAGMA table_info(strokes)');
    expect(info.any((c) => c['name'] == 'hidden'), isTrue);

    final rows =
        await database.query('strokes', where: 'id = ?', whereArgs: ['legacy']);
    expect(rows.single['hidden'], 0);
  });
}
