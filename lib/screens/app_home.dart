import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import '../services/session_service.dart';
import 'library_screen.dart';
import 'notebook_screen.dart';

/// Resolves cold-start route: last notebook when session exists, else library.
class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  bool _loading = true;
  Widget _screen = const LibraryScreen();

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final session = await SessionService.instance.load();
    Widget screen = const LibraryScreen();

    final notebookId = session?.notebookId;
    if (notebookId != null) {
      final notebook = await AppDatabase.instance.notebookById(notebookId);
      if (notebook != null) {
        screen = NotebookScreen(
          notebook: notebook,
          initialPageIndex: session!.pageIndex,
          initialScrollOffset: session.scrollOffset,
          initialTool: session.tool,
        );
      } else {
        await SessionService.instance.clear();
      }
    }

    if (!mounted) return;
    setState(() {
      _screen = screen;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _screen;
  }
}
