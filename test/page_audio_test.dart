import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/page_audio_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_page_audio_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb1',
        title: 'Audio',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        createdAt: 1,
        updatedAt: 1,
      );

  NotePage pg() => NotePage(
        id: 'pg1',
        notebookId: 'nb1',
        index: 0,
        template: PageTemplate.lined,
      );

  test('schema v14 adds pages.audio_path column', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    final database = await db.db;
    final info = await database.rawQuery('PRAGMA table_info(pages)');
    final names = info.map((r) => r['name'] as String).toList();
    expect(names, contains('audio_path'));
  });

  test('updatePageAudioPath persists and clears', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    const path = '/data/audio/test.m4a';
    await db.updatePageAudioPath('pg1', path);
    var page = (await db.pagesOf('nb1')).single;
    expect(page.audioPath, path);

    await db.updatePageAudioPath('pg1', null);
    page = (await db.pagesOf('nb1')).single;
    expect(page.audioPath, isNull);
  });

  test('copyAudioFile stores under audio/ in documents', () async {
    final srcDir = Directory('${tmp.path}${Platform.pathSeparator}src');
    srcDir.createSync();
    final src = File('${srcDir.path}${Platform.pathSeparator}clip.mp3');
    await src.writeAsBytes([1, 2, 3, 4]);

    final stored = await PageAudioService.instance.copyAudioFile(
      src.path,
      docsOverride: tmp.path,
    );

    expect(stored.startsWith('${tmp.path}${Platform.pathSeparator}audio'), isTrue);
    expect(File(stored).existsSync(), isTrue);
    expect(await File(stored).readAsBytes(), [1, 2, 3, 4]);
  });

  test('attachToPage copies file and updates database', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    final srcDir = Directory('${tmp.path}${Platform.pathSeparator}pick');
    srcDir.createSync();
    final src = File('${srcDir.path}${Platform.pathSeparator}lecture.wav');
    await src.writeAsBytes([9, 8, 7]);

    final stored = await PageAudioService.instance.attachToPage(
      pageId: 'pg1',
      sourcePath: src.path,
      docsOverride: tmp.path,
    );

    expect(stored, isNotNull);
    expect(File(stored!).existsSync(), isTrue);

    final page = (await db.pagesOf('nb1')).single;
    expect(page.audioPath, stored);
  });

  test('attachToPage replaces prior file', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    final pick = Directory('${tmp.path}${Platform.pathSeparator}pick2');
    pick.createSync();
    final first = File('${pick.path}${Platform.pathSeparator}a.mp3');
    final second = File('${pick.path}${Platform.pathSeparator}b.mp3');
    await first.writeAsBytes([1]);
    await second.writeAsBytes([2]);

    final path1 = await PageAudioService.instance.attachToPage(
      pageId: 'pg1',
      sourcePath: first.path,
      docsOverride: tmp.path,
    );
    final path2 = await PageAudioService.instance.attachToPage(
      pageId: 'pg1',
      sourcePath: second.path,
      existingPath: path1,
      docsOverride: tmp.path,
    );

    expect(path2, isNot(equals(path1)));
    expect(File(path1!).existsSync(), isFalse);
    expect(File(path2!).existsSync(), isTrue);
    expect((await db.pagesOf('nb1')).single.audioPath, path2);
  });

  test('removeFromPage clears db and deletes file', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(nb());
    await db.insertPage(pg());

    final pick = Directory('${tmp.path}${Platform.pathSeparator}pick3');
    pick.createSync();
    final src = File('${pick.path}${Platform.pathSeparator}c.m4a');
    await src.writeAsBytes([5]);

    final stored = await PageAudioService.instance.attachToPage(
      pageId: 'pg1',
      sourcePath: src.path,
      docsOverride: tmp.path,
    );

    await PageAudioService.instance.removeFromPage(
      pageId: 'pg1',
      currentPath: stored,
    );

    expect((await db.pagesOf('nb1')).single.audioPath, isNull);
    expect(File(stored!).existsSync(), isFalse);
  });

  test('NotePage round-trips audioPath through toRow/fromRow', () {
    final page = NotePage(
      id: 'p',
      notebookId: 'n',
      index: 0,
      template: PageTemplate.blank,
      audioPath: '/audio/x.mp3',
    );
    final row = page.toRow();
    expect(row['audio_path'], '/audio/x.mp3');
    final back = NotePage.fromRow(row);
    expect(back.audioPath, '/audio/x.mp3');
  });
}
