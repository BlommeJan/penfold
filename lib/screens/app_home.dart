import 'dart:async';

import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../services/backup_service.dart';
import '../services/session_service.dart';
import 'library_screen.dart';

/// Cold start always opens the library. Session is kept for in-notebook restore
/// but does not auto-navigate on launch.
class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (AppDatabase.overrideDirPath == null) {
      unawaited(BackupService.instance.createAutoBackupIfDue());
      unawaited(AppDatabase.instance.purgeTrash());
    }
    _prepare();
  }

  Future<void> _prepare() async {
    final session = await SessionService.instance.load();
    final notebookId = session?.notebookId;
    if (notebookId != null) {
      final notebook = await AppDatabase.instance.notebookById(notebookId);
      if (notebook == null) {
        await SessionService.instance.clear();
      }
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const LibraryScreen();
  }
}
