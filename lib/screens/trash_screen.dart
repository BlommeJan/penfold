import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../models/models.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _db = AppDatabase.instance;
  bool _loading = true;
  String? _error;
  List<Notebook> _notebooks = const [];
  List<Folder> _folders = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notebooks = await _db.trashedNotebooks();
      final folders = await _db.trashedFolders();
      if (!mounted) return;
      setState(() {
        _notebooks = notebooks;
        _folders = folders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int _daysRemaining(int deletedAtMs) {
    final deletedAt = DateTime.fromMillisecondsSinceEpoch(deletedAtMs);
    final elapsed = DateTime.now().difference(deletedAt).inDays;
    final remaining = AppDatabase.trashRetention.inDays - elapsed;
    return remaining.clamp(0, AppDatabase.trashRetention.inDays);
  }

  String _subtitleForDeletedAt(int? deletedAtMs) {
    if (deletedAtMs == null) return 'Deletion date unavailable';
    final remaining = _daysRemaining(deletedAtMs);
    if (remaining == 0) return 'Expires today';
    return '$remaining days remaining';
  }

  Future<void> _restoreNotebook(Notebook notebook) async {
    await _db.restoreNotebook(notebook.id);
    await _load();
  }

  Future<void> _deleteNotebook(Notebook notebook) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${notebook.title}" permanently?'),
        content: const Text(
          'This removes the notebook and all pages from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _db.deleteNotebook(notebook.id);
      await _load();
    }
  }

  Future<void> _restoreFolder(Folder folder) async {
    await _db.restoreFolder(folder.id);
    await _load();
  }

  Future<void> _deleteFolder(Folder folder) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${folder.name}" permanently?'),
        content: const Text(
          'This removes the folder and its notebooks from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _db.deleteFolderPermanently(folder.id);
      await _load();
    }
  }

  Widget _sectionTitle(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );

  Widget _trashTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onRestore,
    required VoidCallback onDelete,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Restore',
            icon: const Icon(Icons.restore_rounded),
            onPressed: onRestore,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trash')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Failed to load Trash: $_error'))
              : (_folders.isEmpty && _notebooks.isEmpty)
                  ? const Center(child: Text('Trash is empty'))
                  : ListView(
                      children: [
                        if (_folders.isNotEmpty) ...[
                          _sectionTitle('Folders'),
                          for (final folder in _folders)
                            _trashTile(
                              icon: Icons.folder_outlined,
                              title: folder.name,
                              subtitle:
                                  _subtitleForDeletedAt(folder.deletedAt),
                              onRestore: () => _restoreFolder(folder),
                              onDelete: () => _deleteFolder(folder),
                            ),
                        ],
                        if (_notebooks.isNotEmpty) ...[
                          _sectionTitle('Notebooks'),
                          for (final notebook in _notebooks)
                            _trashTile(
                              icon: Icons.menu_book_outlined,
                              title: notebook.title,
                              subtitle:
                                  _subtitleForDeletedAt(notebook.deletedAt),
                              onRestore: () => _restoreNotebook(notebook),
                              onDelete: () => _deleteNotebook(notebook),
                            ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
    );
  }
}
