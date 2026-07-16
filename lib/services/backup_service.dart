import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../db/app_database.dart';

/// Metadata for an on-device auto-backup zip.
class AutoBackupInfo {
  const AutoBackupInfo({
    required this.file,
    required this.createdAt,
    required this.bytes,
  });

  final File file;
  final DateTime createdAt;
  final int bytes;
}

/// Full-database backup and restore — local zip of SQLite + asset folders.
class BackupService {
  BackupService._();
  static final BackupService instance = BackupService._();

  static const dbFileName = 'penfold.db';
  static const assetDirs = ['pdf_sources', 'images', 'pdf_pages', 'thumbnails', 'audio'];
  static const backupsDirName = 'backups';
  static const autoBackupPrefix = 'auto-backup-';
  static const maxAutoBackups = 3;
  static const autoBackupMinInterval = Duration(hours: 24);

  Future<Directory> _docsDir() async {
    final override = AppDatabase.overrideDirPath;
    if (override != null) return Directory(override);
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> _backupsDir() async {
    final docs = await _docsDir();
    final dir = Directory(p.join(docs.path, backupsDirName));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
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

  /// Writes an auto-backup zip under `backups/` and prunes older copies.
  Future<File?> createAutoBackup() async {
    final docs = await _docsDir();
    final dbFile = File(p.join(docs.path, dbFileName));
    if (!dbFile.existsSync()) return null;

    final backups = await _backupsDir();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final target = p.join(backups.path, '$autoBackupPrefix$stamp.zip');
    final zip = await createBackupZip(docsDir: docs, zipPath: target);
    await _pruneAutoBackups(backups);
    return zip;
  }

  /// Creates an auto-backup when the last one is older than [autoBackupMinInterval].
  Future<File?> createAutoBackupIfDue() async {
    final latest = await latestAutoBackup();
    if (latest != null &&
        DateTime.now().difference(latest.createdAt) < autoBackupMinInterval) {
      return null;
    }
    return createAutoBackup();
  }

  Future<void> _pruneAutoBackups(Directory backups) async {
    final files = backups
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith(autoBackupPrefix))
        .toList()
      ..sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
    for (var i = maxAutoBackups; i < files.length; i++) {
      await files[i].delete();
    }
  }

  Future<AutoBackupInfo?> latestAutoBackup() async {
    final backups = await _backupsDir();
    final files = backups
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith(autoBackupPrefix))
        .toList()
      ..sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
    if (files.isEmpty) return null;
    final file = files.first;
    return AutoBackupInfo(
      file: file,
      createdAt: file.lastModifiedSync(),
      bytes: await file.length(),
    );
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
    final backupsDir = await _backupsDir();

    await AppDatabase.instance.resetForTests();

    final dbFile = File(p.join(docs.path, dbFileName));
    if (dbFile.existsSync()) {
      final ts = DateTime.now().millisecondsSinceEpoch;
      await dbFile.copy(p.join(backupsDir.path, 'pre-restore-$ts.db'));
    }

    _extractZipToDir(zipPath, docs.path);
    return 'Restore complete. Please restart the app to load the restored data.';
  }

  Future<String> restoreFromLatestAutoBackup() async {
    final latest = await latestAutoBackup();
    if (latest == null) {
      throw StateError('No auto-backup found on this device');
    }
    return restoreFromZip(latest.file.path);
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
