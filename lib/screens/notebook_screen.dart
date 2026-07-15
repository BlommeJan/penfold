import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../canvas/drawing_canvas.dart';
import '../canvas/penfold_scroll_behavior.dart';
import '../db/app_database.dart';
import '../models/models.dart';
import '../services/page_export.dart';
import '../widgets/page_editor.dart';
import '../widgets/toolbar.dart';
import 'page_overview_screen.dart';

const _uuid = Uuid();

class NotebookScreen extends StatefulWidget {
  final Notebook notebook;
  const NotebookScreen({super.key, required this.notebook});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final _db = AppDatabase.instance;
  final _toolState = ToolState();
  final _scrollController = ScrollController();
  final Map<String, GlobalKey<PageEditorState>> _pageKeys = {};

  List<NotePage> _pages = [];
  bool _loading = true;
  bool _canUndo = false;
  bool _canRedo = false;
  bool _hasSelection = false;
  int _visiblePageIndex = 0;
  int _pinchLockCount = 0;

  DrawingCanvasState? _activeCanvas;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _toolState.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pages.isEmpty) return;
    final offset = _scrollController.offset;
    final pageHeight = MediaQuery.of(context).size.height * 0.85;
    final idx = (offset / pageHeight).round().clamp(0, _pages.length - 1);
    if (idx != _visiblePageIndex) {
      setState(() => _visiblePageIndex = idx);
      _setActiveCanvas(_pageKeys[_pages[idx].id]?.currentState?.canvasState);
    }
  }

  Future<void> _load() async {
    var pages = await _db.pagesOf(widget.notebook.id);
    if (pages.isEmpty) {
      final page = NotePage(
        id: _uuid.v4(),
        notebookId: widget.notebook.id,
        index: 0,
        template: widget.notebook.template,
        pageSize: widget.notebook.pageSize,
      );
      await _db.insertPage(page);
      pages = [page];
    }
    _pages = pages;
    for (final pg in _pages) {
      _pageKeys.putIfAbsent(pg.id, GlobalKey<PageEditorState>.new);
    }
    setState(() => _loading = false);
    _db.touchNotebook(widget.notebook.id);
  }

  NotePage get _activePage => _pages[_visiblePageIndex];

  List<int> get _bookmarkedIndices => [
        for (var i = 0; i < _pages.length; i++)
          if (_pages[i].bookmarked) i,
      ];

  bool get _canPrevBookmark =>
      _bookmarkedIndices.any((i) => i < _visiblePageIndex);

  bool get _canNextBookmark =>
      _bookmarkedIndices.any((i) => i > _visiblePageIndex);

  Future<void> _jumpToPrevBookmark() async {
    final prev = _bookmarkedIndices.where((i) => i < _visiblePageIndex);
    if (prev.isEmpty) return;
    await _scrollToPage(prev.last);
  }

  Future<void> _jumpToNextBookmark() async {
    final next = _bookmarkedIndices.where((i) => i > _visiblePageIndex);
    if (next.isEmpty) return;
    await _scrollToPage(next.first);
  }

  void _setActiveCanvas(DrawingCanvasState? state) {
    _activeCanvas = state;
  }

  void _onPageTransformGesture(bool active) {
    setState(() {
      if (active) {
        _pinchLockCount++;
      } else {
        _pinchLockCount = (_pinchLockCount - 1).clamp(0, 999);
      }
    });
  }

  Future<void> _scrollToPage(int index) async {
    if (index < 0 || index >= _pages.length) return;
    final pageHeight = MediaQuery.of(context).size.height * 0.85;
    await _scrollController.animateTo(
      index * pageHeight,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    setState(() => _visiblePageIndex = index);
  }

  Future<void> _addPage() async {
    final page = NotePage(
      id: _uuid.v4(),
      notebookId: widget.notebook.id,
      index: _pages.length,
      template: _activePage.pdfImagePath == null
          ? _activePage.template
          : widget.notebook.template,
      pageSize: widget.notebook.pageSize,
    );
    await _db.insertPage(page);
    _pageKeys[page.id] = GlobalKey<PageEditorState>();
    setState(() => _pages.add(page));
    await _scrollToPage(_pages.length - 1);
  }

  Future<void> _addImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final srcPath = result?.files.single.path;
    if (srcPath == null) return;
    final docs = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(docs.path, 'images'));
    if (!imgDir.existsSync()) imgDir.createSync(recursive: true);
    final dest =
        p.join(imgDir.path, '${_uuid.v4()}${p.extension(srcPath)}');
    await File(srcPath).copy(dest);
    final editor = _pageKeys[_activePage.id]?.currentState;
    await editor?.canvasState?.addImageFromPath(dest);
    setState(() {});
  }

  Future<void> _openPageSettings() async {
    final chosen = await showModalBottomSheet<Object?>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Page template',
                  style: Theme.of(ctx).textTheme.titleSmall),
            ),
            for (final t in PageTemplate.values)
              ListTile(
                leading: Icon(switch (t) {
                  PageTemplate.blank => Icons.crop_portrait_rounded,
                  PageTemplate.lined => Icons.notes_rounded,
                  PageTemplate.grid => Icons.grid_4x4_rounded,
                  PageTemplate.dotted => Icons.apps_rounded,
                  PageTemplate.collegeRuled => Icons.margin_rounded,
                }),
                title: Text(switch (t) {
                  PageTemplate.blank => 'Blank',
                  PageTemplate.lined => 'Lined',
                  PageTemplate.grid => 'Grid',
                  PageTemplate.dotted => 'Dotted',
                  PageTemplate.collegeRuled => 'College ruled',
                }),
                trailing: _activePage.template == t
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(ctx, t),
              ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Page size',
                  style: Theme.of(ctx).textTheme.titleSmall),
            ),
            for (final s in PageSize.values)
              ListTile(
                leading: const Icon(Icons.aspect_ratio_rounded),
                title: Text(s.label),
                trailing: _activePage.pageSize == s
                    ? const Icon(Icons.check_rounded)
                    : null,
                enabled: _activePage.pdfImagePath == null,
                onTap: _activePage.pdfImagePath == null
                    ? () => Navigator.pop(ctx, s)
                    : null,
              ),
            if (_activePage.pdfImagePath != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'PDF pages keep their document dimensions',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.bookmark_outline_rounded),
              title: const Text('Bookmark this page'),
              value: _activePage.bookmarked,
              onChanged: (v) => Navigator.pop(ctx, 'bookmark:$v'),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text('Export',
                  style: Theme.of(ctx).textTheme.titleSmall),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Export page as PNG'),
              onTap: () => Navigator.pop(ctx, 'export_png'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Export page as PDF'),
              onTap: () => Navigator.pop(ctx, 'export_pdf'),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Export notebook as PDF'),
              subtitle: Text('${_pages.length} pages'),
              onTap: () => Navigator.pop(ctx, 'export_notebook_pdf'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen == null || !mounted) return;

    if (chosen is String && chosen.startsWith('bookmark:')) {
      final v = chosen == 'bookmark:true';
      await _db.setPageBookmarked(_activePage.id, v);
      setState(() => _activePage.bookmarked = v);
      return;
    }

    if (chosen is PageTemplate) {
      if (_activePage.pdfImagePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PDF pages keep their document background')));
        return;
      }
      await _db.updatePageTemplate(_activePage.id, chosen);
      setState(() => _activePage.template = chosen);
      return;
    }

    if (chosen is PageSize) {
      if (_activePage.pdfImagePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PDF pages keep their document dimensions')));
        return;
      }
      if (chosen == _activePage.pageSize) return;
      if (await _db.pageHasInk(_activePage.id)) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Change page size?'),
            content: const Text(
              'This page has ink. Changing the size will re-layout the page; '
              'your ink stays in the same position on the page.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Change size'),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
      await _db.updatePageSize(_activePage.id, chosen);
      setState(() => _activePage.pageSize = chosen);
      return;
    }

    switch (chosen) {
      case 'export_png':
        await _exportCurrentPage(ExportFormat.png);
      case 'export_pdf':
        await _exportCurrentPage(ExportFormat.pdf);
      case 'export_notebook_pdf':
        await _exportNotebookPdf();
      default:
        break;
    }
  }

  Future<T?> _withExportProgress<T>({
    required int totalPages,
    required Future<T> Function(ExportProgressCallback onProgress) run,
  }) async {
    if (!mounted) return null;
    final progress = ValueNotifier<(int current, int total)>((0, totalPages));

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: ValueListenableBuilder<(int current, int total)>(
            valueListenable: progress,
            builder: (_, value, __) {
              final label = value.$2 <= 1
                  ? 'Preparing export…'
                  : 'Exporting page ${value.$1} of ${value.$2}…';
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(label),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    try {
      return await run((current, total) {
        progress.value = (current, total);
      });
    } finally {
      progress.dispose();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _exportCurrentPage(ExportFormat format) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _withExportProgress(
        totalPages: 1,
        run: (onProgress) => PageExportService.instance.exportPage(
          page: _activePage,
          notebookTitle: widget.notebook.title,
          pageIndex: _visiblePageIndex,
          format: format,
          onProgress: onProgress,
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(format == ExportFormat.png
            ? 'Page exported as PNG'
            : 'Page exported as PDF'),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _exportNotebookPdf() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _withExportProgress(
        totalPages: _pages.length,
        run: (onProgress) => PageExportService.instance.exportNotebook(
          pages: _pages,
          notebookTitle: widget.notebook.title,
          onProgress: onProgress,
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(
          const SnackBar(content: Text('Notebook exported as PDF')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text('Export failed: $e')));
    }
  }

  void _openOverview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PageOverviewScreen(
          notebook: widget.notebook,
          pages: _pages,
          onPageSelected: _scrollToPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF3),
      appBar: EditorToolbar(
        toolState: _toolState,
        canUndo: _canUndo,
        canRedo: _canRedo,
        hasSelection: _hasSelection,
        canPaste: _activeCanvas?.canPaste ?? false,
        onUndo: () => _activeCanvas?.undo(),
        onRedo: () => _activeCanvas?.redo(),
        onDeleteSelection: () => _activeCanvas?.deleteSelection(),
        onCopy: () => _activeCanvas?.copySelection(),
        onPaste: () => _activeCanvas?.pasteClipboard(),
        onAddPage: _addPage,
        onPageSettings: _openPageSettings,
        onAddImage: _addImage,
        onPageOverview: _openOverview,
        canPrevBookmark: _canPrevBookmark,
        canNextBookmark: _canNextBookmark,
        onPrevBookmark: _jumpToPrevBookmark,
        onNextBookmark: _jumpToNextBookmark,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollConfiguration(
              behavior: const PenfoldScrollBehavior(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: _pinchLockCount > 0
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                slivers: [
                  for (var i = 0; i < _pages.length; i++)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: viewport.height * 0.85,
                        child: PageEditor(
                          key: _pageKeys[_pages[i].id],
                          page: _pages[i],
                          notebook: widget.notebook,
                          toolState: _toolState,
                          viewportSize: Size(
                              viewport.width, viewport.height * 0.85),
                          onCanvasReady: (state) {
                            if (i == _visiblePageIndex) {
                              _setActiveCanvas(state);
                            }
                          },
                          onHistoryChanged: i == _visiblePageIndex
                              ? (u, r) => setState(() {
                                    _canUndo = u;
                                    _canRedo = r;
                                  })
                              : null,
                          onSelectionChanged: i == _visiblePageIndex
                              ? (sel) => setState(() => _hasSelection = sel)
                              : null,
                          onTransformGestureActive: _onPageTransformGesture,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }
}
