import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/backup_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_backup_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  test('createBackupZip includes penfold.db', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(Notebook(
      id: 'nb1',
      title: 'Backup Test',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 1,
      updatedAt: 1,
    ));

    final zipPath = '${tmp.path}${Platform.pathSeparator}backup.zip';
    final zip = await BackupService.instance.createBackupZip(
      docsDir: tmp,
      zipPath: zipPath,
    );

    expect(await zip.exists(), isTrue);

    final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    final names = archive.map((e) => e.name).toList();
    expect(names, contains(BackupService.dbFileName));
  });

  test('createBackupZip includes asset directories when present', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(Notebook(
      id: 'nb2',
      title: 'Assets',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 1,
      updatedAt: 1,
    ));

    final imagesDir = Directory('${tmp.path}${Platform.pathSeparator}images');
    imagesDir.createSync(recursive: true);
    await File('${imagesDir.path}${Platform.pathSeparator}photo.png')
        .writeAsBytes([1, 2, 3]);

    final zipPath = '${tmp.path}${Platform.pathSeparator}backup2.zip';
    final zip = await BackupService.instance.createBackupZip(
      docsDir: tmp,
      zipPath: zipPath,
    );

    final archive = ZipDecoder().decodeBytes(await zip.readAsBytes());
    final names = archive.map((e) => e.name).toList();
    expect(names.any((n) => n.startsWith('images/')), isTrue);
  });

  test('createAutoBackup writes zip under backups/', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(Notebook(
      id: 'nb-auto',
      title: 'Auto',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 1,
      updatedAt: 1,
    ));

    final zip = await BackupService.instance.createAutoBackup();
    expect(zip, isNotNull);
    expect(await zip!.exists(), isTrue);
    expect(p.basename(zip.path), startsWith(BackupService.autoBackupPrefix));

    final latest = await BackupService.instance.latestAutoBackup();
    expect(latest, isNotNull);
    expect(latest!.file.path, zip.path);
  });

  test('createAutoBackupIfDue skips when recent backup exists', () async {
    final db = AppDatabase.instance;
    await db.insertNotebook(Notebook(
      id: 'nb-due',
      title: 'Due',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 1,
      updatedAt: 1,
    ));

    final first = await BackupService.instance.createAutoBackupIfDue();
    expect(first, isNotNull);

    final second = await BackupService.instance.createAutoBackupIfDue();
    expect(second, isNull);
  });
}
