import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../l10n/l10n.dart';
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

  String _subtitleForDeletedAt(AppLocalizations l10n, int? deletedAtMs) {
    if (deletedAtMs == null) return l10n.trashDeletionDateUnavailable;
    final remaining = _daysRemaining(deletedAtMs);
    if (remaining == 0) return l10n.trashExpiresToday;
    return l10n.trashDaysRemaining(remaining);
  }

  Future<void> _restoreNotebook(Notebook notebook) async {
    await _db.restoreNotebook(notebook.id);
    await _load();
  }

  Future<void> _deleteNotebook(Notebook notebook) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashDeleteNotebookTitle(notebook.title)),
        content: Text(l10n.trashDeleteNotebookBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
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
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashDeleteFolderTitle(folder.name)),
        content: Text(l10n.trashDeleteFolderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _db.deleteFolderPermanently(folder.id);
      await _load();
    }
  }

  bool get _hasTrashItems => _folders.isNotEmpty || _notebooks.isNotEmpty;

  Future<void> _deleteAll() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trashDeleteAllConfirmTitle),
        content: Text(l10n.trashDeleteAllConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.trashDeleteAll),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _db.emptyTrash();
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
    required AppLocalizations l10n,
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
            tooltip: l10n.trashRestore,
            icon: const Icon(Icons.restore_rounded),
            onPressed: onRestore,
          ),
          IconButton(
            tooltip: l10n.actionDelete,
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashTitle),
        actions: [
          if (!_loading && _error == null && _hasTrashItems)
            TextButton(
              onPressed: _deleteAll,
              child: Text(
                l10n.trashDeleteAll,
                style: TextStyle(color: scheme.error),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(l10n.trashFailedToLoad(_error!)))
              : (_folders.isEmpty && _notebooks.isEmpty)
                  ? Center(child: Text(l10n.trashEmpty))
                  : ListView(
                      children: [
                        if (_folders.isNotEmpty) ...[
                          _sectionTitle(l10n.trashSectionFolders),
                          for (final folder in _folders)
                            _trashTile(
                              l10n: l10n,
                              icon: Icons.folder_outlined,
                              title: folder.name,
                              subtitle:
                                  _subtitleForDeletedAt(l10n, folder.deletedAt),
                              onRestore: () => _restoreFolder(folder),
                              onDelete: () => _deleteFolder(folder),
                            ),
                        ],
                        if (_notebooks.isNotEmpty) ...[
                          _sectionTitle(l10n.trashSectionNotebooks),
                          for (final notebook in _notebooks)
                            _trashTile(
                              l10n: l10n,
                              icon: Icons.menu_book_outlined,
                              title: notebook.title,
                              subtitle: _subtitleForDeletedAt(
                                l10n,
                                notebook.deletedAt,
                              ),
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
