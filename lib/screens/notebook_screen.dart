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
import '../services/page_turn_mode_service.dart';
import '../services/session_service.dart';
import '../services/spen_button_service.dart';
import '../services/stroke_smoothing_service.dart';
import '../services/thumbnail_cache.dart';
import '../widgets/contents_sheet.dart';
import '../widgets/page_audio_settings.dart';
import '../widgets/page_editor.dart';
import '../widgets/toolbar.dart';
import 'page_overview_screen.dart';

const _uuid = Uuid();

class NotebookScreen extends StatefulWidget {
  final Notebook notebook;
  final int? initialPageIndex;
  final double? initialScrollOffset;
  final ToolType? initialTool;

  const NotebookScreen({
    super.key,
    required this.notebook,
    this.initialPageIndex,
    this.initialScrollOffset,
    this.initialTool,
  });

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final _db = AppDatabase.instance;
  final _toolState = ToolState();
  final _scrollController = ScrollController();
  late final PageController _pageController;
  final Map<String, GlobalKey<PageEditorState>> _pageKeys = {};

  List<NotePage> _pages = [];
  bool _loading = true;
  bool _pageTurnEnabled = false;
  bool _canUndo = false;
  bool _canRedo = false;
  bool _hasSelection = false;
  int _visiblePageIndex = 0;
  int _pinchLockCount = 0;
  Timer? _sessionSaveTimer;

  DrawingCanvasState? _activeCanvas;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _scrollController.addListener(_onScroll);
    _toolState.addListener(_scheduleSessionSave);
    _syncStrokeSmoothing();
    StrokeSmoothingService.instance.addListener(_onStrokeSmoothingChanged);
    _syncPageTurnMode();
    PageTurnModeService.instance.addListener(_onPageTurnModeChanged);
    _syncSpenButton();
    SpenButtonService.instance.addListener(_onSpenButtonChanged);
    unawaited(SpenButtonService.instance.startListening());
    _load();
  }

  @override
  void dispose() {
    _sessionSaveTimer?.cancel();
    unawaited(_persistSession());
    _toolState.removeListener(_scheduleSessionSave);
    StrokeSmoothingService.instance.removeListener(_onStrokeSmoothingChanged);
    PageTurnModeService.instance.removeListener(_onPageTurnModeChanged);
    SpenButtonService.instance.removeListener(_onSpenButtonChanged);
    SpenButtonService.instance.stopListening();
    _toolState.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onStrokeSmoothingChanged() {
    _toolState.set(
      (s) => s.strokeSmoothing = StrokeSmoothingService.instance.enabled,
    );
  }

  void _onPageTurnModeChanged() {
    if (!mounted) return;
    final enabled = PageTurnModeService.instance.enabled;
    if (enabled == _pageTurnEnabled) return;
    setState(() => _pageTurnEnabled = enabled);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncViewportToVisiblePage();
    });
  }

  Future<void> _syncPageTurnMode() async {
    if (!PageTurnModeService.instance.isLoaded) {
      await PageTurnModeService.instance.load();
    }
    if (!mounted) return;
    setState(() => _pageTurnEnabled = PageTurnModeService.instance.enabled);
  }

  Future<void> _syncStrokeSmoothing() async {
    if (!StrokeSmoothingService.instance.isLoaded) {
      await StrokeSmoothingService.instance.load();
    }
    if (!mounted) return;
    _toolState.set(
      (s) => s.strokeSmoothing = StrokeSmoothingService.instance.enabled,
    );
  }

  void _onSpenButtonChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _syncSpenButton() async {
    if (!SpenButtonService.instance.isLoaded) {
      await SpenButtonService.instance.load();
    }
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
    _scheduleSessionSave();
  }

  void _scheduleSessionSave() {
    _sessionSaveTimer?.cancel();
    _sessionSaveTimer = Timer(const Duration(milliseconds: 500), () {
      unawaited(_persistSession());
    });
  }

  Future<void> _persistSession() async {
    if (_loading || _pages.isEmpty) return;
    // Tests use overrideDirPath; skip async session writes during widget tests.
    if (AppDatabase.overrideDirPath != null) return;
    final offset = _pageTurnEnabled
        ? 0.0
        : (_scrollController.hasClients ? _scrollController.offset : 0.0);
    await SessionService.instance.save(
      notebookId: widget.notebook.id,
      pageIndex: _visiblePageIndex,
      scrollOffset: offset,
      tool: _toolState.tool,
    );
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
    if (widget.initialTool != null) {
      _toolState.set((s) => s.tool = widget.initialTool!);
    }
    final initialIdx = widget.initialPageIndex;
    if (initialIdx != null && initialIdx >= 0 && initialIdx < _pages.length) {
      _visiblePageIndex = initialIdx;
    }
    setState(() => _loading = false);
    _db.touchNotebook(widget.notebook.id);
    unawaited(ThumbnailCache.instance.ensureForNotebook(widget.notebook.id));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncViewportToVisiblePage(
        scrollOffset: widget.initialScrollOffset,
      );
    });
  }

  void _onVisiblePageChanged(int index) {
    if (index == _visiblePageIndex) return;
    setState(() => _visiblePageIndex = index);
    _setActiveCanvas(_pageKeys[_pages[index].id]?.currentState?.canvasState);
    _scheduleSessionSave();
  }

  void _syncViewportToVisiblePage({double? scrollOffset}) {
    if (_pages.isEmpty) return;
    final idx = _visiblePageIndex.clamp(0, _pages.length - 1);
    if (_pageTurnEnabled) {
      if (_pageController.hasClients) {
        final current = _pageController.page?.round() ?? _pageController.initialPage;
        if (current != idx) {
          _pageController.jumpToPage(idx);
        }
      }
      _setActiveCanvas(_pageKeys[_pages[idx].id]?.currentState?.canvasState);
      return;
    }
    if (!_scrollController.hasClients) return;
    final pageHeight = MediaQuery.of(context).size.height * 0.85;
    if (scrollOffset != null && scrollOffset > 0) {
      _scrollController.jumpTo(
        scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    } else {
      _scrollController.jumpTo(idx * pageHeight);
    }
    _setActiveCanvas(_pageKeys[_pages[idx].id]?.currentState?.canvasState);
  }

  NotePage get _activePage => _pages[_visiblePageIndex];

  bool _isPdfPage(NotePage page) =>
      page.pdfImagePath != null || page.pdfSourcePath != null;

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

  Future<void> _convertSelectionToText() async {
    final text = await _activeCanvas?.convertSelectionToText();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (text != null && text.isNotEmpty) {
      final preview =
          text.length > 48 ? '${text.substring(0, 48)}…' : text;
      messenger.showSnackBar(
        SnackBar(content: Text('Converted to text: $preview')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not recognize handwriting')),
      );
    }
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
    if (_pageTurnEnabled) {
      if (_pageController.hasClients) {
        await _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
      setState(() => _visiblePageIndex = index);
      _setActiveCanvas(_pageKeys[_pages[index].id]?.currentState?.canvasState);
      return;
    }
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

  Future<void> _openContents() async {
    await ContentsSheet.show(
      context,
      notebookId: widget.notebook.id,
      currentPageIndex: _visiblePageIndex,
      onPageSelected: _scrollToPage,
    );
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
                enabled: !_isPdfPage(_activePage),
                onTap: !_isPdfPage(_activePage)
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('Orientation',
                  style: Theme.of(ctx).textTheme.titleSmall),
            ),
            for (final o in PageOrientation.values)
              ListTile(
                leading: Icon(o == PageOrientation.portrait
                    ? Icons.crop_portrait_rounded
                    : Icons.crop_landscape_rounded),
                title: Text(o.label),
                trailing: _activePage.orientation == o
                    ? const Icon(Icons.check_rounded)
                    : null,
                enabled: !_isPdfPage(_activePage),
                onTap: !_isPdfPage(_activePage)
                    ? () => Navigator.pop(ctx, o)
                    : null,
              ),
            if (_isPdfPage(_activePage))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'PDF pages keep their document orientation',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('Table of contents'),
              subtitle: const Text('Jump to headings in this notebook'),
              onTap: () => Navigator.pop(ctx, 'contents'),
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.bookmark_outline_rounded),
              title: const Text('Bookmark this page'),
              value: _activePage.bookmarked,
              onChanged: (v) => Navigator.pop(ctx, 'bookmark:$v'),
            ),
            PageAudioSettings(
              pageId: _activePage.id,
              audioPath: _activePage.audioPath,
              onAudioChanged: (path) {
                _activePage.audioPath = path;
              },
            ),
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

    if (chosen == 'contents') {
      await _openContents();
      return;
    }

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
      if (_isPdfPage(_activePage)) {
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

    if (chosen is PageOrientation) {
      if (_isPdfPage(_activePage)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PDF pages keep their document orientation')));
        return;
      }
      if (chosen == _activePage.orientation) return;
      if (await _db.pageHasInk(_activePage.id)) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Change orientation?'),
            content: const Text(
              'This page has ink. Changing orientation re-layouts the page; '
              'your ink stays in the same canonical position.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Change orientation'),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
      final aspect = chosen.aspectOf(_activePage.pageSize);
      await _db.updatePageOrientation(_activePage.id, chosen, aspect);
      setState(() {
        _activePage.orientation = chosen;
        _activePage.aspect = aspect;
      });
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

  void _openOverview() async {
    final updated = await Navigator.of(context).push<List<NotePage>>(
      MaterialPageRoute(
        builder: (_) => PageOverviewScreen(
          notebook: widget.notebook,
          pages: _pages,
          onPageSelected: _scrollToPage,
        ),
      ),
    );
    if (updated == null || !mounted) return;
    await _applyPagesUpdate(updated);
  }

  Future<void> _applyPagesUpdate(List<NotePage> pages) async {
    final oldVisibleId = _pages[_visiblePageIndex].id;
    final newIds = pages.map((p) => p.id).toSet();
    for (final id in _pageKeys.keys.toList()) {
      if (!newIds.contains(id)) {
        _pageKeys.remove(id);
      }
    }
    for (final page in pages) {
      _pageKeys.putIfAbsent(page.id, GlobalKey<PageEditorState>.new);
    }
    final newIdx = pages.indexWhere((p) => p.id == oldVisibleId);
    final nextVisible = newIdx >= 0
        ? newIdx
        : _visiblePageIndex.clamp(0, pages.length - 1);
    setState(() {
      _pages = pages;
      _visiblePageIndex = nextVisible;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncViewportToVisiblePage();
    });
  }

  Widget _pageEditorAt(int i, Size viewportSize) {
    return PageEditor(
      key: _pageKeys[_pages[i].id],
      page: _pages[i],
      notebook: widget.notebook,
      toolState: _toolState,
      viewportSize: viewportSize,
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
    );
  }

  Widget _buildScrollBody(Size viewport) {
    final pageHeight = viewport.height * 0.85;
    return ScrollConfiguration(
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
                height: pageHeight,
                child: _pageEditorAt(
                  i,
                  Size(viewport.width, pageHeight),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildPageTurnBody(Size viewport) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: _pinchLockCount > 0
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      onPageChanged: _onVisiblePageChanged,
      itemCount: _pages.length,
      itemBuilder: (context, i) => _pageEditorAt(i, viewport),
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
        canConvertSelectionToText:
            _activeCanvas?.canConvertSelectionToText ?? false,
        onUndo: () => _activeCanvas?.undo(),
        onRedo: () => _activeCanvas?.redo(),
        onDeleteSelection: () => _activeCanvas?.deleteSelection(),
        onCopy: () => _activeCanvas?.copySelection(),
        onPaste: () => _activeCanvas?.pasteClipboard(),
        onConvertToText: _convertSelectionToText,
        onAddPage: _addPage,
        onPageSettings: _openPageSettings,
        onAddImage: _addImage,
        onPageOverview: _openOverview,
        onContents: _openContents,
        canPrevBookmark: _canPrevBookmark,
        canNextBookmark: _canNextBookmark,
        onPrevBookmark: _jumpToPrevBookmark,
        onNextBookmark: _jumpToNextBookmark,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pageTurnEnabled
              ? _buildPageTurnBody(viewport)
              : _buildScrollBody(viewport),
    );
  }
}
