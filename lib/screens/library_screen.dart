import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import '../services/app_info_service.dart';
import '../services/backup_service.dart';
import '../services/page_complexity_service.dart';
import '../services/page_export.dart';
import '../services/pdf_import.dart';
import '../services/thumbnail_cache.dart';
import 'notebook_screen.dart';
import 'settings_screen.dart';
import 'trash_screen.dart';
import '../widgets/library_drawer.dart';

const _uuid = Uuid();

const _coverColors = [
  0xFF2455C3,
  0xFFD63B3B,
  0xFF1E9E52,
  0xFF8E44C8,
  0xFFE08A12,
  0xFF2E5A8C,
];

enum _LibraryView { all, uncategorized }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _db = AppDatabase.instance;
  final _searchCtrl = TextEditingController();
  List<Notebook> _notebooks = [];
  List<Folder> _allFolders = [];
  List<Folder> _childFolders = [];
  List<Tag> _allTags = [];
  List<SearchResult> _searchResults = [];
  _LibraryView _view = _LibraryView.all;
  String? _currentFolderId;
  String? _selectedTagId;
  bool _loading = true;
  bool _searching = false;
  String? _loadError;
  final Map<String, String> _thumbnailPaths = {};
  int _prefetchGeneration = 0;
  int _trashedNotebookCount = 0;
  int _trashedFolderCount = 0;
  bool _appInfoLoaded = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadAppInfo();
    _refresh();
  }

  Future<void> _loadAppInfo() async {
    await AppInfoService.instance.load();
    if (!mounted) return;
    setState(() => _appInfoLoaded = true);
  }

  @override
  void dispose() {
    _prefetchGeneration++;
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() {
        _searching = false;
        _searchResults = [];
      });
      return;
    }
    _runSearch(q);
  }

  Future<void> _runSearch(String q) async {
    try {
      final results = await _db.searchNotebooks(q);
      if (!mounted) return;
      setState(() {
        _searching = true;
        _searchResults = results;
        _loadError = null;
      });
      final notebooks = results.map((r) => r.notebook).toList();
      await _syncThumbnailPaths(notebooks);
      _schedulePrefetch(notebooks);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.toString());
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final allFolders = await _db.allFolders();
      final allTags = await _db.allTags();
      final trashedNotebooks = await _db.trashedNotebooks();
      final trashedFolders = await _db.trashedFolders();
      final childFolders = _currentFolderId == null
          ? await _db.folders()
          : await _db.folders(parentId: _currentFolderId);
      final List<Notebook> items;
      if (_currentFolderId == null) {
        items = await _db.notebooks(
          folderId: _view == _LibraryView.uncategorized ? '' : null,
        );
      } else {
        items = await _db.notebooks(folderId: _currentFolderId);
      }
      List<Notebook> filtered = items;
      if (_selectedTagId != null) {
        final tagged = await _db.notebooksWithTag(_selectedTagId!);
        final taggedIds = tagged.map((n) => n.id).toSet();
        filtered = items.where((n) => taggedIds.contains(n.id)).toList();
      }
      if (!mounted) return;
      setState(() {
        _allFolders = allFolders;
        _allTags = allTags;
        _childFolders = childFolders;
        _notebooks = filtered;
        _trashedNotebookCount = trashedNotebooks.length;
        _trashedFolderCount = trashedFolders.length;
        _loading = false;
      });
      await _syncThumbnailPaths(filtered);
      _schedulePrefetch(filtered);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = e.toString();
      });
    }
  }

  Future<void> _syncThumbnailPaths(List<Notebook> notebooks) async {
    final cache = ThumbnailCache.instance;
    final paths = <String, String>{};
    for (final n in notebooks) {
      if (await cache.exists(n.id)) {
        paths[n.id] = await cache.pathFor(n.id);
      }
    }
    if (!mounted) return;
    setState(() => _thumbnailPaths
      ..clear()
      ..addAll(paths));
  }

  void _schedulePrefetch(List<Notebook> notebooks) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_prefetchMissingThumbnails(notebooks));
    });
  }

  Future<void> _prefetchMissingThumbnails(List<Notebook> notebooks) async {
    final gen = _prefetchGeneration;
    final cache = ThumbnailCache.instance;
    for (final n in notebooks) {
      if (!mounted || gen != _prefetchGeneration) return;
      final route = ModalRoute.of(context);
      if (route == null || !route.isCurrent) return;
      if (_thumbnailPaths.containsKey(n.id)) continue;
      try {
        final file = await cache.ensureForNotebook(n.id);
        if (file != null && mounted && gen == _prefetchGeneration) {
          setState(() => _thumbnailPaths[n.id] = file.path);
        }
      } catch (_) {
        // Library may be disposed or DB reset during background prefetch.
      }
    }
  }

  Folder? _folderById(String id) {
    for (final f in _allFolders) {
      if (f.id == id) return f;
    }
    return null;
  }

  List<Folder> _breadcrumb() {
    final path = <Folder>[];
    var id = _currentFolderId;
    while (id != null) {
      final folder = _folderById(id);
      if (folder == null) break;
      path.insert(0, folder);
      id = folder.parentId;
    }
    return path;
  }

  List<Folder> _topLevelFolders() =>
      _allFolders.where((f) => f.parentId == null).toList();

  void _openFolder(String folderId) {
    setState(() {
      _currentFolderId = folderId;
      _view = _LibraryView.all;
    });
    _refresh();
  }

  void _goToRoot() {
    setState(() {
      _currentFolderId = null;
    });
    _refresh();
  }

  void _goToFolder(String? folderId) {
    setState(() => _currentFolderId = folderId);
    _refresh();
  }

  Future<void> _open(Notebook n) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NotebookScreen(notebook: n)),
    );
    _refresh();
  }

  Future<void> _openTrash() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TrashScreen()),
    );
    _refresh();
  }

  Future<void> _createFolder({String? parentId}) async {
    final ctrl = TextEditingController(text: 'New folder');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null ? 'New folder' : 'New subfolder'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create')),
        ],
      ),
    );
    if (ok != true) return;
    final siblings = parentId == null
        ? _topLevelFolders()
        : _allFolders.where((f) => f.parentId == parentId).toList();
    final f = Folder(
      id: _uuid.v4(),
      name: ctrl.text.trim().isEmpty ? 'New folder' : ctrl.text.trim(),
      sortOrder: siblings.length,
      parentId: parentId,
    );
    await _db.insertFolder(f);
    _refresh();
  }

  Future<void> _folderMenu(Folder folder) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(ctx, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: const Text('New subfolder'),
              onTap: () => Navigator.pop(ctx, 'subfolder'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Move to Trash'),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'rename') {
      final ctrl = TextEditingController(text: folder.name);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rename folder'),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Rename')),
          ],
        ),
      );
      if (ok == true) {
        await _db.renameFolder(folder.id, ctrl.text.trim());
        _refresh();
      }
    } else if (action == 'subfolder') {
      await _createFolder(parentId: folder.id);
    } else if (action == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Move "${folder.name}" to Trash?'),
          content: const Text(
            'The folder and its notebooks move to Trash for 30 days.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Move to Trash')),
          ],
        ),
      );
      if (ok == true) {
        if (_currentFolderId == folder.id) {
          _goToFolder(folder.parentId);
        }
        await _db.softDeleteFolder(folder.id);
        _refresh();
      }
    }
  }

  void _addFolderTiles(
    List<Widget> tiles,
    List<Folder> folders, {
    required int depth,
  }) {
    for (final folder in folders) {
      tiles.add(
        ListTile(
          leading: Icon(Icons.folder_outlined, color: Colors.grey.shade700),
          title: Text('${'  ' * depth}${folder.name}'),
          onTap: () => Navigator.pop(context, folder.id),
        ),
      );
      final children =
          _allFolders.where((f) => f.parentId == folder.id).toList();
      if (children.isNotEmpty) {
        _addFolderTiles(tiles, children, depth: depth + 1);
      }
    }
  }

  Future<void> _moveToFolder(Notebook n) async {
    final tiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.folder_off_outlined),
        title: const Text('Uncategorized'),
        onTap: () => Navigator.pop(context, ''),
      ),
    ];
    _addFolderTiles(tiles, _topLevelFolders(), depth: 0);

    final chosen = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(shrinkWrap: true, children: tiles),
      ),
    );
    if (chosen == null) return;
    await _db.moveNotebookToFolder(n.id, chosen.isEmpty ? null : chosen);
    _refresh();
  }

  Future<void> _createNotebook() async {
    final titleCtrl = TextEditingController(text: 'Untitled');
    var template = PageTemplate.lined;
    var pageSize = PageSize.a4;
    var colorIx = 0;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('New notebook'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 20),
                Text('Size', style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final s in PageSize.values)
                      _themedChoiceChip(
                        label: s.label,
                        selected: pageSize == s,
                        onSelected: () => setDialog(() => pageSize = s),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Paper', style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in PageTemplate.values)
                      _themedChoiceChip(
                        label: switch (t) {
                          PageTemplate.blank => 'Blank',
                          PageTemplate.lined => 'Lined',
                          PageTemplate.grid => 'Grid',
                          PageTemplate.dotted => 'Dotted',
                          PageTemplate.collegeRuled => 'College',
                        },
                        selected: template == t,
                        onSelected: () => setDialog(() => template = t),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Cover', style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 0; i < _coverColors.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setDialog(() => colorIx = i),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(_coverColors[i]),
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 3,
                                color: colorIx == i
                                    ? Theme.of(ctx).colorScheme.primary
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (created != true) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final n = Notebook(
      id: _uuid.v4(),
      title: titleCtrl.text.trim().isEmpty ? 'Untitled' : titleCtrl.text.trim(),
      coverColor: _coverColors[colorIx],
      template: template,
      pageSize: pageSize,
      folderId: _currentFolderId,
      createdAt: now,
      updatedAt: now,
    );
    await _db.insertNotebook(n);
    final page = NotePage(
      id: _uuid.v4(),
      notebookId: n.id,
      index: 0,
      template: template,
      pageSize: pageSize,
    );
    await _db.insertPage(page);
    await _refresh();
    if (mounted) await _open(n);
  }

  Future<void> _importPdf() async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(
      content: Text('Importing PDF… pages render once, then stay offline.'),
      duration: Duration(seconds: 2),
    ));
    try {
      final notebook = await PdfImportService.pickAndImport();
      await _refresh();
      if (notebook != null && mounted) _open(notebook);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  Future<void> _notebookMenu(Notebook n) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(ctx, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Move to folder'),
              onTap: () => Navigator.pop(ctx, 'folder'),
            ),
            ListTile(
              leading: const Icon(Icons.label_outline_rounded),
              title: const Text('Edit tags'),
              onTap: () => Navigator.pop(ctx, 'tags'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Export workbook'),
              subtitle: const Text('Share all pages as PDF'),
              onTap: () => Navigator.pop(ctx, 'export_workbook'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Move to Trash'),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (action == 'folder') {
      await _moveToFolder(n);
    } else if (action == 'tags') {
      await _editNotebookTags(n);
    } else if (action == 'export_workbook') {
      await _exportWorkbook(n);
    } else if (action == 'rename') {
      final ctrl = TextEditingController(text: n.title);
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Rename notebook'),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Rename')),
          ],
        ),
      );
      if (ok == true) {
        await _db.renameNotebook(n.id, ctrl.text.trim());
        _refresh();
      }
    } else if (action == 'delete') {
      await _confirmDeleteNotebook(n);
    }
  }

  Future<void> _exportWorkbook(Notebook n) async {
    final pages = await _db.pagesOf(n.id);
    if (pages.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This notebook has no pages to export')),
      );
      return;
    }

    final blockReason = await PageComplexityService.instance
        .exportBlockReasonForPages(pages.map((p) => p.id));
    if (blockReason != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(blockReason)));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      await withExportProgressDialog(
        context: context,
        totalPages: pages.length,
        run: (onProgress) => PageExportService.instance.exportNotebook(
          pages: pages,
          notebookTitle: n.title,
          onProgress: onProgress,
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('"${n.title}" exported as PDF')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _confirmDeleteNotebook(Notebook n) async {
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Move "${n.title}" to Trash?'),
        content: const Text(
          'The notebook is hidden from the library for 30 days. '
          'Ink and pages stay on this device until Trash is emptied. '
          'Export a backup first if you want an extra copy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'export'),
            child: const Text('Export first'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: const Text('Move to Trash'),
          ),
        ],
      ),
    );
    if (action == 'export') {
      try {
        await BackupService.instance.exportAndShare();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup exported. You can move to Trash when ready.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Export failed: $e')),
          );
        }
      }
      return;
    }
    if (action == 'delete') {
      await _db.softDeleteNotebook(n.id);
      await ThumbnailCache.instance.deleteForNotebook(n.id);
      _refresh();
    }
  }

  Future<void> _editNotebookTags(Notebook n) async {
    final allTags = await _db.allTags();
    final current = await _db.tagsOfNotebook(n.id);
    final selected = current.map((t) => t.id).toSet();
    final newTagCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text('Tags for "${n.title}"'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allTags.isEmpty)
                  Text(
                    'No tags yet. Create one below.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in allTags)
                        FilterChip(
                          label: Text(tag.name),
                          selected: selected.contains(tag.id),
                          onSelected: (on) {
                            setDialog(() {
                              if (on) {
                                selected.add(tag.id);
                              } else {
                                selected.remove(tag.id);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: newTagCtrl,
                        decoration: const InputDecoration(
                          labelText: 'New tag',
                          isDense: true,
                        ),
                        onSubmitted: (_) async {
                          final name = newTagCtrl.text.trim();
                          if (name.isEmpty) return;
                          final tag = Tag(id: _uuid.v4(), name: name);
                          await _db.createTag(tag);
                          setDialog(() {
                            allTags.add(tag);
                            selected.add(tag.id);
                            newTagCtrl.clear();
                          });
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add tag',
                      icon: const Icon(Icons.add_rounded),
                      onPressed: () async {
                        final name = newTagCtrl.text.trim();
                        if (name.isEmpty) return;
                        final tag = Tag(id: _uuid.v4(), name: name);
                        await _db.createTag(tag);
                        setDialog(() {
                          allTags.add(tag);
                          selected.add(tag.id);
                          newTagCtrl.clear();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await _db.setNotebookTags(n.id, selected.toList());
      _refresh();
    }
  }

  Widget _themedChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outline.withOpacity(0.35),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? primary : const Color(0xFF4A4A4A),
        ),
        selectedColor: primary.withOpacity(0.16),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? primary : const Color(0xFFE0E4EA),
          width: selected ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _notebookCard(Notebook n) {
    final cover = Color(n.coverColor);
    final thumbPath = _thumbnailPaths[n.id];
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _open(n),
      onLongPress: () => _notebookMenu(n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: thumbPath != null ? Colors.white : null,
                gradient: thumbPath == null
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cover,
                          Color.lerp(cover, Colors.black, 0.12)!,
                        ],
                      )
                    : null,
                image: thumbPath != null
                    ? DecorationImage(
                        image: FileImage(File(thumbPath)),
                        fit: BoxFit.cover,
                      )
                    : null,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cover.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.22),
                          Colors.black.withOpacity(0.12),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            n.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _folderCard(Folder folder) {
    return GestureDetector(
      onTap: () => _openFolder(folder.id),
      onLongPress: () => _folderMenu(folder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECF2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD5DCE6)),
              ),
              child: const Center(
                child: Icon(Icons.folder_rounded,
                    size: 56, color: Color(0xFF2455C3)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            folder.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E4EA)),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search notebooks and typed text…',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.grey.shade600, size: 22),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade600),
                  onPressed: () => _searchCtrl.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        ),
      ),
    );
  }

  Widget _headerRow() {
    final folderChips = _currentFolderId == null
        ? _topLevelFolders()
        : _childFolders;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_currentFolderId == null) ...[
              _filterChip(
                label: 'All',
                selected: _view == _LibraryView.all,
                onTap: () {
                  setState(() => _view = _LibraryView.all);
                  _refresh();
                },
              ),
              _filterChip(
                label: 'Uncategorized',
                selected: _view == _LibraryView.uncategorized,
                onTap: () {
                  setState(() => _view = _LibraryView.uncategorized);
                  _refresh();
                },
              ),
            ] else
              TextButton.icon(
                onPressed: () {
                  final parent = _folderById(_currentFolderId!)?.parentId;
                  _goToFolder(parent);
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2455C3),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            if (!_searching && folderChips.isNotEmpty) ...[
              const SizedBox(width: 8),
              for (final f in folderChips)
                _filterChip(
                  label: f.name,
                  selected: _currentFolderId == f.id,
                  onTap: () => _openFolder(f.id),
                ),
            ],
            if (!_searching && _allTags.isNotEmpty) ...[
              const SizedBox(width: 8),
              for (final tag in _allTags)
                _filterChip(
                  label: tag.name,
                  selected: _selectedTagId == tag.id,
                  onTap: () {
                    setState(() {
                      _selectedTagId =
                          _selectedTagId == tag.id ? null : tag.id;
                    });
                    _refresh();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _breadcrumbBar() {
    final crumbs = _breadcrumb();
    if (crumbs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          InkWell(
            onTap: _goToRoot,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Library',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF2455C3),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          for (var i = 0; i < crumbs.length; i++) ...[
            Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.grey.shade500),
            InkWell(
              onTap: () => _goToFolder(crumbs[i].id),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  crumbs[i].name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: i == crumbs.length - 1
                            ? const Color(0xFF1A1A1A)
                            : const Color(0xFF2455C3),
                        fontWeight: i == crumbs.length - 1
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayNotebooks = _searching
        ? _searchResults.map((r) => r.notebook).toList()
        : _notebooks;
    final showFolders = !_searching && _currentFolderId != null
        ? _childFolders
        : (!_searching && _currentFolderId == null && _view == _LibraryView.all
            ? _topLevelFolders()
            : <Folder>[]);
    final itemCount = showFolders.length + displayNotebooks.length;
    final emptyMessage = _searching
        ? 'No matches'
        : _currentFolderId != null
            ? 'This folder is empty'
            : _selectedTagId != null
                ? 'No notebooks with this tag'
                : _view == _LibraryView.uncategorized
                    ? 'No uncategorized notebooks'
                    : 'No notebooks yet';

    return Scaffold(
      drawer: LibraryDrawer(
        folders: _allFolders,
        currentFolderId: _currentFolderId,
        trashCount: _trashedNotebookCount + _trashedFolderCount,
        onOverview: () {
          Navigator.pop(context);
          _goToRoot();
        },
        onOpenTrash: () {
          Navigator.pop(context);
          _openTrash();
        },
        onOpenSettings: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
        onFolderSelected: (id) {
          Navigator.pop(context);
          _openFolder(id);
        },
      ),
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text('Penfold'),
            if (_appInfoLoaded) ...[
              const SizedBox(width: 8),
              Text(
                AppInfoService.instance.versionLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Backup & Restore',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Trash',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _openTrash,
          ),
          IconButton(
            tooltip: 'New notebook',
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _createNotebook,
          ),
          IconButton(
            tooltip: _currentFolderId == null ? 'New folder' : 'New subfolder',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _createFolder(parentId: _currentFolderId),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _searchField(),
          ),
          if (!_searching) ...[
            _breadcrumbBar(),
            _headerRow(),
          ],
          if (_loadError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Could not load library: $_loadError',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : itemCount == 0
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _searching
                                  ? Icons.search_off_rounded
                                  : Icons.menu_book_rounded,
                              size: 56,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(emptyMessage,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, i) {
                          if (i < showFolders.length) {
                            return _folderCard(showFolders[i]);
                          }
                          final nbIndex = i - showFolders.length;
                          if (_searching) {
                            final r = _searchResults[nbIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _notebookCard(r.notebook)),
                                if (r.snippet.isNotEmpty)
                                  Text(
                                    r.snippet.replaceAll(RegExp('<[^>]*>'), ''),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            );
                          }
                          return _notebookCard(displayNotebooks[nbIndex]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'pdf',
            tooltip: 'Import PDF',
            onPressed: _importPdf,
            child: const Icon(Icons.picture_as_pdf_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'new',
            onPressed: _createNotebook,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New notebook'),
          ),
        ],
      ),
    );
  }
}
