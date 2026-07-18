import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../services/app_info_service.dart';
import '../services/backup_service.dart';
import '../services/ink_ocr_service.dart';
import '../services/page_complexity_service.dart';
import '../services/page_export.dart';
import '../services/pdf_import.dart';
import '../services/notebook_defaults_service.dart';
import '../services/thumbnail_cache.dart';
import 'notebook_screen.dart';
import 'settings_screen.dart';
import 'trash_screen.dart';
import '../widgets/library_drawer.dart';
import '../widgets/themed_choice_chip.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!InkOcrService.disableMlKit && (Platform.isAndroid || Platform.isIOS)) {
        unawaited(_prefetchHandwritingModel());
      }
    });
  }

  Future<void> _prefetchHandwritingModel() async {
    final ocr = InkOcrService.instance;
    if (ocr.modelStatus == InkModelStatus.ready) return;

    unawaited(ocr.ensureModelReady());

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (ocr.modelStatus == InkModelStatus.downloading) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.handwritingModelDownloadingBackground(
              inkRecognitionModelSizeEstimateMb,
            ),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: l10n.folderNew);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(parentId == null ? l10n.folderNew : l10n.folderNewSubfolder),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionCreate)),
        ],
      ),
    );
    if (ok != true) return;
    final siblings = parentId == null
        ? _topLevelFolders()
        : _allFolders.where((f) => f.parentId == parentId).toList();
    final f = Folder(
      id: _uuid.v4(),
      name: ctrl.text.trim().isEmpty ? l10n.folderNew : ctrl.text.trim(),
      sortOrder: siblings.length,
      parentId: parentId,
    );
    await _db.insertFolder(f);
    _refresh();
  }

  Future<void> _folderMenu(Folder folder) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: Text(l10n.actionRename),
              onTap: () => Navigator.pop(ctx, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l10n.folderNewSubfolder),
              onTap: () => Navigator.pop(ctx, 'subfolder'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.folderMoveToTrash),
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
          title: Text(l10n.folderRename),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.actionCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.actionRename)),
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
          title: Text(l10n.folderMoveToTrashTitle(folder.name)),
          content: Text(l10n.folderMoveToTrashBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.actionCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.folderMoveToTrash)),
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
          leading: Icon(
            Icons.folder_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
    final l10n = context.l10n;
    final tiles = <Widget>[
      ListTile(
        leading: const Icon(Icons.folder_off_outlined),
        title: Text(l10n.libraryUncategorized),
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
    final l10n = context.l10n;
    await NotebookDefaultsService.instance.load();
    final notebookDefaults = NotebookDefaultsService.instance.defaults;
    final titleCtrl = TextEditingController(text: l10n.notebookUntitled);
    var template = notebookDefaults.template;
    var pageSize = notebookDefaults.pageSize;
    var pageTheme = notebookDefaults.backgroundTheme;
    var colorIx = 0;

    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(l10n.notebookNew),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  decoration: InputDecoration(labelText: l10n.notebookTitleLabel),
                ),
                const SizedBox(height: 20),
                Text(l10n.notebookSizeLabel, style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final s in PageSize.values)
                      ThemedChoiceChip(
                        label: l10n.pageSizeLabel(s),
                        selected: pageSize == s,
                        onSelected: () => setDialog(() => pageSize = s),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.notebookPaperLabel, style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in PageTemplate.values)
                      ThemedChoiceChip(
                        label: l10n.pageTemplateShortLabel(t),
                        selected: template == t,
                        onSelected: () => setDialog(() => template = t),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.defaultPageTheme, style: Theme.of(ctx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final theme in PageBackgroundTheme.values)
                      GestureDetector(
                        onTap: () => setDialog(() => pageTheme = theme),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.paperColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: pageTheme == theme ? 3 : 1,
                              color: pageTheme == theme
                                  ? Theme.of(ctx).colorScheme.primary
                                  : Theme.of(ctx).colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.notebookCoverLabel, style: Theme.of(ctx).textTheme.labelLarge),
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
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionCreate),
            ),
          ],
        ),
      ),
    );

    if (created != true) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final n = Notebook(
      id: _uuid.v4(),
      title: titleCtrl.text.trim().isEmpty ? l10n.notebookUntitled : titleCtrl.text.trim(),
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
      backgroundTheme: pageTheme,
    );
    await _db.insertPage(page);
    await _refresh();
    if (mounted) await _open(n);
  }

  Future<void> _importPdf() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.importPdfSnack),
      duration: const Duration(seconds: 2),
    ));
    try {
      final notebook = await PdfImportService.pickAndImport();
      await _refresh();
      if (notebook != null && mounted) _open(notebook);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.importFailed(e.toString()))));
    }
  }

  Future<void> _notebookMenu(Notebook n) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline_rounded),
              title: Text(l10n.actionRename),
              onTap: () => Navigator.pop(ctx, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.notebookMoveToFolder),
              onTap: () => Navigator.pop(ctx, 'folder'),
            ),
            ListTile(
              leading: const Icon(Icons.label_outline_rounded),
              title: Text(l10n.notebookEditTags),
              onTap: () => Navigator.pop(ctx, 'tags'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(l10n.notebookExportWorkbook),
              subtitle: Text(l10n.notebookExportWorkbookSubtitle),
              onTap: () => Navigator.pop(ctx, 'export_workbook'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.notebookMoveToTrash),
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
          title: Text(l10n.notebookRename),
          content: TextField(controller: ctrl, autofocus: true),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.actionCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.actionRename)),
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
    final l10n = context.l10n;
    final pages = await _db.pagesOf(n.id);
    if (pages.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notebookNoPagesToExport)),
      );
      return;
    }

    final blockReason = await PageComplexityService.instance
        .exportBlockReasonForPages(pages.map((p) => p.id), l10n);
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
        SnackBar(content: Text(l10n.notebookExportedAsPdf(n.title))),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.exportFailed(e.toString()))));
    }
  }

  Future<void> _confirmDeleteNotebook(Notebook n) async {
    final l10n = context.l10n;
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.notebookMoveToTrashTitle(n.title)),
        content: Text(l10n.notebookMoveToTrashBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'export'),
            child: Text(l10n.actionExportFirst),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'delete'),
            child: Text(l10n.notebookMoveToTrash),
          ),
        ],
      ),
    );
    if (action == 'export') {
      try {
        await BackupService.instance.exportAndShare();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.notebookBackupExportedReady),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exportFailed(e.toString()))),
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
    final l10n = context.l10n;
    final allTags = await _db.allTags();
    final current = await _db.tagsOfNotebook(n.id);
    final selected = current.map((t) => t.id).toSet();
    final newTagCtrl = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(l10n.notebookTagsFor(n.title)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (allTags.isEmpty)
                  Text(
                    l10n.notebookNoTagsYet,
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
                        decoration: InputDecoration(
                          labelText: l10n.notebookNewTag,
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
                      tooltip: l10n.notebookAddTag,
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
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionSave),
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

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final materialTheme = Theme.of(context);
    final scheme = materialTheme.colorScheme;
    final primary = scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        key: ValueKey('filter-$label-$selected-${materialTheme.brightness}'),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? primary : scheme.onSurface,
        ),
        selectedColor: primary.withOpacity(0.16),
        backgroundColor: scheme.surface,
        side: BorderSide(
          color: selected ? primary : scheme.outline,
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
                color: thumbPath != null ? scheme.surface : null,
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
    final scheme = Theme.of(context).colorScheme;
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
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outline),
              ),
              child: Center(
                child: Icon(Icons.folder_rounded,
                    size: 56, color: scheme.primary),
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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outline),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: TextStyle(fontSize: 15, color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: l10n.librarySearchHint,
          hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
          prefixIcon:
              Icon(Icons.search_rounded, color: scheme.onSurfaceVariant, size: 22),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, color: scheme.onSurfaceVariant),
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
    final l10n = context.l10n;
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
                label: l10n.libraryAll,
                selected: _view == _LibraryView.all,
                onTap: () {
                  setState(() => _view = _LibraryView.all);
                  _refresh();
                },
              ),
              _filterChip(
                label: l10n.libraryUncategorized,
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
                label: Text(l10n.actionBack),
                style: TextButton.styleFrom(
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
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
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
                l10n.libraryBreadcrumb,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
          for (var i = 0; i < crumbs.length; i++) ...[
            Icon(Icons.chevron_right_rounded,
                size: 18, color: scheme.onSurfaceVariant),
            InkWell(
              onTap: () => _goToFolder(crumbs[i].id),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  crumbs[i].name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: i == crumbs.length - 1
                            ? scheme.onSurface
                            : scheme.primary,
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
    final l10n = context.l10n;
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
        ? l10n.libraryNoMatches
        : _currentFolderId != null
            ? l10n.libraryFolderEmpty
            : _selectedTagId != null
                ? l10n.libraryNoNotebooksWithTag
                : _view == _LibraryView.uncategorized
                    ? l10n.libraryNoUncategorizedNotebooks
                    : l10n.libraryNoNotebooksYet;

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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(l10n.appTitle),
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
            tooltip: l10n.tooltipBackupRestore,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          IconButton(
            tooltip: l10n.tooltipTrash,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _openTrash,
          ),
          IconButton(
            tooltip: l10n.tooltipNewNotebook,
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _createNotebook,
          ),
          IconButton(
            tooltip: _currentFolderId == null
                ? l10n.tooltipNewFolder
                : l10n.tooltipNewSubfolder,
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
                l10n.libraryCouldNotLoad(_loadError!),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.65),
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
            tooltip: l10n.tooltipImportPdf,
            onPressed: _importPdf,
            child: const Icon(Icons.picture_as_pdf_outlined),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'new',
            onPressed: _createNotebook,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.notebookNew),
          ),
        ],
      ),
    );
  }
}
