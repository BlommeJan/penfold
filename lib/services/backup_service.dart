import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/app_database.dart';

/// Full-database backup and restore — local zip of SQLite + asset folders.
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const dbFileName = 'penfold.db';
  static const assetDirs = ['pdf_sources', 'images', 'pdf_pages', 'thumbnails'];

  Future<Directory> _docsDir() async {
    final override = AppDatabase.overrideDirPath;
    if (override != null) return Directory(override);
    return getApplicationDocumentsDirectory();
  }

  /// Creates a zip containing [dbFileName] and known asset directories.
  Future<File> createBackupZip({Directory? docsDir, String? zipPath}) async {
    final docs = docsDir ?? await _docsDir();
    final target = zipPath ??
        p.join(
          (await getTemporaryDirectory()).path,
          'penfold-backup-${DateTime.now().toIso8601String().replaceAll(':', '-')}.zip',
        );

    final encoder = ZipFileEncoder();
    encoder.create(target);

    final dbFile = File(p.join(docs.path, dbFileName));
    if (dbFile.existsSync()) {
      encoder.addFile(dbFile, dbFileName);
    }

    for (final name in assetDirs) {
      final dir = Directory(p.join(docs.path, name));
      if (dir.existsSync()) {
        _addDirectoryToZip(encoder, dir, name);
      }
    }

    encoder.close();
    return File(target);
  }

  void _addDirectoryToZip(
    ZipFileEncoder encoder,
    Directory dir,
    String prefix,
  ) {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final rel = p.relative(entity.path, from: dir.path);
      final archivePath = p.join(prefix, rel).replaceAll('\\', '/');
      encoder.addFile(entity, archivePath);
    }
  }

  Future<void> exportAndShare() async {
    final zip = await createBackupZip();
    final result = await Share.shareXFiles(
      [
        XFile(
          zip.path,
          mimeType: 'application/zip',
          name: p.basename(zip.path),
        ),
      ],
      subject: 'Penfold backup',
    );
    if (result.status == ShareResultStatus.unavailable) {
      throw StateError('Share is not available on this device');
    }
  }

  Future<String?> pickBackupZip() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      withData: false,
    );
    return result?.files.single.path;
  }

  /// Saves current DB to backups/, then extracts [zipPath] into documents dir.
  Future<String> restoreFromZip(String zipPath) async {
    final docs = await _docsDir();
    final backupsDir = Directory(p.join(docs.path, 'backups'));
    if (!backupsDir.existsSync()) backupsDir.createSync(recursive: true);

    await AppDatabase.instance.resetForTests();

    final dbFile = File(p.join(docs.path, dbFileName));
    if (dbFile.existsSync()) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      await dbFile.copy(p.join(backupsDir.path, 'pre-restore-$ts.db'));
    }

    _extractZipToDir(zipPath, docs.path);
    return 'Restore complete. Please restart the app to load the restored data.';
  }

  void _extractZipToDir(String zipPath, String destDir) {
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final entry in archive) {
      final name = entry.name.replaceAll('\\', '/');
      if (name.endsWith('/')) continue;
      if (!entry.isFile) continue;
      final outFile = File(p.join(destDir, name));
      outFile.parent.createSync(recursive: true);
      outFile.writeAsBytesSync(entry.content as List<int>);
    }
  }
}
