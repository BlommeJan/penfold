import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/app_database.dart';
import 'backup_service.dart';

/// Snapshot of on-device Penfold storage (DB path + asset folder sizes).
class YourDataSnapshot {
  const YourDataSnapshot({
    required this.dbPath,
    required this.dbBytes,
    required this.folderBytes,
  });

  final String dbPath;
  final int dbBytes;
  final Map<String, int> folderBytes;
}

/// Reports local storage layout for the Settings "Your data" screen.
class YourDataService {
  YourDataService._();
  static final YourDataService instance = YourDataService._();

  static const trackedFolders = ['images', 'pdf_sources', 'audio', 'thumbnails'];

  Future<Directory> docsDir() async {
    final override = AppDatabase.overrideDirPath;
    if (override != null) return Directory(override);
    return getApplicationDocumentsDirectory();
  }

  Future<YourDataSnapshot> loadSnapshot() async {
    final docs = await docsDir();
    final dbPath = p.join(docs.path, BackupService.dbFileName);
    final dbFile = File(dbPath);
    final dbBytes = dbFile.existsSync() ? dbFile.lengthSync() : 0;

    final folderBytes = <String, int>{};
    for (final name in trackedFolders) {
      folderBytes[name] = _directorySizeBytes(Directory(p.join(docs.path, name)));
    }

    return YourDataSnapshot(
      dbPath: dbPath,
      dbBytes: dbBytes,
      folderBytes: folderBytes,
    );
  }

  static int directorySizeBytes(Directory dir) => _directorySizeBytes(dir);

  static int _directorySizeBytes(Directory dir) {
    if (!dir.existsSync()) return 0;
    var total = 0;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File) total += entity.lengthSync();
    }
    return total;
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
