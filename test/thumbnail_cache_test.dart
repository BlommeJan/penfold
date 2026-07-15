import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_thumb_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  test('relativePath uses thumbnails/{notebook_id}.png', () {
    expect(
      ThumbnailCache.relativePath('nb-abc'),
      'thumbnails${Platform.pathSeparator}nb-abc.png',
    );
    expect(ThumbnailCache.fileNameFor('nb-abc'), 'nb-abc.png');
  });

  test('pathFor resolves under documents thumbnails folder', () async {
    final path = await ThumbnailCache.instance.pathFor('nb-xyz');
    expect(
      path,
      '${tmp.path}${Platform.pathSeparator}thumbnails${Platform.pathSeparator}nb-xyz.png',
    );
  });

  test('ensureForNotebook writes a PNG file on disk', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(Notebook(
      id: 'nb1',
      title: 'Thumb Test',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      pageSize: PageSize.a4,
      createdAt: 1,
      updatedAt: 1,
    ));
    await db.insertPage(NotePage(
      id: 'pg1',
      notebookId: 'nb1',
      index: 0,
      template: PageTemplate.lined,
      pageSize: PageSize.a4,
    ));

    final file = await ThumbnailCache.instance.ensureForNotebook('nb1');

    expect(file, isNotNull);
    expect(await file!.exists(), isTrue);
    final bytes = await file.readAsBytes();
    expect(bytes.length, greaterThan(8));
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50);
    expect(bytes[2], 0x4E);
    expect(bytes[3], 0x47);

    final again = await ThumbnailCache.instance.ensureForNotebook('nb1');
    expect(again!.path, file.path);
  });

  test('deleteForNotebook removes cached PNG', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(Notebook(
      id: 'nb2',
      title: 'Delete Thumb',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 1,
      updatedAt: 1,
    ));
    await db.insertPage(NotePage(
      id: 'pg2',
      notebookId: 'nb2',
      index: 0,
      template: PageTemplate.blank,
      pageSize: PageSize.a4,
    ));

    final file = await ThumbnailCache.instance.ensureForNotebook('nb2');
    expect(await file!.exists(), isTrue);

    await ThumbnailCache.instance.deleteForNotebook('nb2');
    expect(await ThumbnailCache.instance.exists('nb2'), isFalse);
  });
}
