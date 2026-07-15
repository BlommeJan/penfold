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
    tmp = await Directory.systemTemp.createTemp('penfold_text_rot_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('TextBlock rotation', () {
    test('row roundtrip preserves rotation', () {
      final block = TextBlock(
        id: 't1',
        pageId: 'pg1',
        x: 10,
        y: 20,
        w: 100,
        h: 50,
        text: 'rotated',
        fontSize: 24,
        color: 0xFF000000,
        z: 0,
        rotation: 1.5707963267948966,
      );
      final back = TextBlock.fromRow(block.toRow());
      expect(back.rotation, closeTo(block.rotation, 0.0001));
      expect(back.x, block.x);
      expect(back.text, block.text);
    });

    test('copy preserves rotation', () {
      final block = TextBlock(
        id: 't1',
        pageId: 'pg1',
        x: 0,
        y: 0,
        w: 80,
        h: 40,
        text: 'hello',
        fontSize: 16,
        color: 0xFF000000,
        z: 1,
        rotation: 0.7853981633974483,
      );
      expect(block.copy().rotation, block.rotation);
    });

    test('fromRow defaults rotation to 0 for legacy rows', () {
      final block = TextBlock.fromRow({
        'id': 't1',
        'page_id': 'pg1',
        'x': 1.0,
        'y': 2.0,
        'w': 3.0,
        'h': 4.0,
        'text': 'legacy',
        'font_size': 12.0,
        'color': 0,
        'z': 0,
        'is_note': 0,
      });
      expect(block.rotation, 0);
    });

    test('axisAlignedBounds expands for rotated rect', () {
      final block = TextBlock(
        id: 't1',
        pageId: 'pg1',
        x: 0,
        y: 0,
        w: 100,
        h: 50,
        text: 'x',
        fontSize: 16,
        color: 0,
        z: 0,
        rotation: 1.5707963267948966,
      );
      final aabb = block.axisAlignedBounds;
      expect(aabb.width, closeTo(block.h, 0.0001));
      expect(aabb.height, closeTo(block.w, 0.0001));
    });
  });

  test('DB v7 migration adds text_blocks.rotation column', () async {
    final dbPath = '${tmp.path}/migrate_v6.db';
    final v6 = await openDatabase(dbPath, version: 6, onCreate: (db, v) async {
      await db.execute('''
        CREATE TABLE notebooks(
          id TEXT PRIMARY KEY, title TEXT, color INTEGER, template INTEGER,
          page_size INTEGER NOT NULL DEFAULT 0, folder_id TEXT,
          created INTEGER, updated INTEGER)''');
      await db.execute('''
        CREATE TABLE pages(
          id TEXT PRIMARY KEY, notebook_id TEXT, idx INTEGER, template INTEGER,
          page_size INTEGER NOT NULL DEFAULT 0, pdf_image TEXT, aspect REAL,
          pdf_source_path TEXT, pdf_page_index INTEGER,
          bookmarked INTEGER NOT NULL DEFAULT 0)''');
      await db.execute('''
        CREATE TABLE text_blocks(
          id TEXT PRIMARY KEY, page_id TEXT, x REAL, y REAL, w REAL, h REAL,
          text TEXT, font_size REAL, color INTEGER, z INTEGER,
          is_note INTEGER NOT NULL DEFAULT 0)''');
      await db.insert('notebooks', {
        'id': 'nb1',
        'title': 'Test',
        'color': 0,
        'template': 0,
        'created': 1,
        'updated': 1,
      });
      await db.insert('pages', {
        'id': 'pg1',
        'notebook_id': 'nb1',
        'idx': 0,
        'template': 0,
        'aspect': 0.707,
      });
      await db.insert('text_blocks', {
        'id': 't1',
        'page_id': 'pg1',
        'x': 10.0,
        'y': 20.0,
        'w': 100.0,
        'h': 50.0,
        'text': 'before migration',
        'font_size': 24.0,
        'color': 0,
        'z': 0,
        'is_note': 0,
      });
    });
    await v6.close();

    await File(dbPath).copy('${tmp.path}/penfold.db');
    await AppDatabase.instance.resetForTests();

    final db = AppDatabase.instance;
    final blocks = await db.textBlocksOf('pg1');
    expect(blocks.length, 1);
    expect(blocks.single.rotation, 0);

    blocks.single.rotation = 0.5;
    await db.updateTextBlock(blocks.single);

    final reloaded = (await db.textBlocksOf('pg1')).single;
    expect(reloaded.rotation, closeTo(0.5, 0.0001));
    expect(reloaded.text, 'before migration');
  });
}
