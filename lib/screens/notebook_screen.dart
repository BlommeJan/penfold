import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../canvas/document_viewport.dart';
import '../canvas/drawing_canvas.dart';
import '../canvas/page_coords.dart';
import '../canvas/viewport_metrics.dart';
import '../canvas/penfold_scroll_behavior.dart';
import '../canvas/pointer_routing.dart';
import '../db/app_database.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../services/finger_drawing_service.dart';
import '../services/page_complexity_service.dart';
import '../services/page_export.dart';
import '../services/page_turn_mode_service.dart';
import '../services/session_service.dart';
import '../services/spen_button_service.dart';
import '../services/stroke_smoothing_service.dart';
import '../services/thumbnail_cache.dart';
import '../services/ink_ocr_service.dart';
import '../services/zoom_navigation_service.dart';
import '../widgets/contents_sheet.dart';
import '../widgets/page_editor.dart';
import '../widgets/page_settings_popup.dart';
import '../widgets/toolbar.dart';
import 'library_screen.dart';
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

class _NotebookScreenState extends State<NotebookScreen>
    with WidgetsBindingObserver {
  final _db = AppDatabase.instance;
  final _toolState = ToolState();
  final _scrollController = ScrollController();
  late final PageController _pageController;
  final Map<String, GlobalKey<PageEditorState>> _pageKeys = {};
  final _documentViewportKey = GlobalKey<DocumentViewportState>();

  List<NotePage> _pages = [];
  bool _loading = true;
  bool _pageTurnEnabled = false;
  bool _zoomNavigationEnabled = true;
  bool _canUndo = false;
  bool _canRedo = false;
  bool _hasSelection = false;
  bool _activePageHasStrokes = false;
  int _visiblePageIndex = 0;
  int _pinchLockCount = 0;
  int _paperFingerLockCount = 0;
  bool _documentZoomed = false;
  Size _stableDocumentViewport = Size.zero;
  Timer? _sessionSaveTimer;
  final Set<String> _complexityWarnedOnOpen = {};
  bool _syncingFingerDrawing = false;
  Orientation? _lastDeviceOrientation;

  DrawingCanvasState? _activeCanvas;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _scrollController.addListener(_onScroll);
    _toolState.addListener(_onToolStateChanged);
    _syncStrokeSmoothing();
    StrokeSmoothingService.instance.addListener(_onStrokeSmoothingChanged);
    _syncPageTurnMode();
    PageTurnModeService.instance.addListener(_onPageTurnModeChanged);
    _syncZoomNavigation();
    ZoomNavigationService.instance.addListener(_onZoomNavigationChanged);
    _syncFingerDrawing();
    FingerDrawingService.instance.addListener(_onFingerDrawingChanged);
    _syncSpenButton();
    SpenButtonService.instance.addListener(_onSpenButtonChanged);
    unawaited(SpenButtonService.instance.startListening());
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.orientationOf(context);
    if (_lastDeviceOrientation != null &&
        _lastDeviceOrientation != orientation) {
      _resetDocumentTransform();
      for (final key in _pageKeys.values) {
        key.currentState?.resetViewportTransform();
      }
      setState(() {});
    }
    _lastDeviceOrientation = orientation;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _sessionSaveTimer?.cancel();
        unawaited(_persistSession());
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _popToLibrary() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const LibraryScreen()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionSaveTimer?.cancel();
    unawaited(_persistSession());
    _toolState.removeListener(_onToolStateChanged);
    StrokeSmoothingService.instance.removeListener(_onStrokeSmoothingChanged);
    PageTurnModeService.instance.removeListener(_onPageTurnModeChanged);
    ZoomNavigationService.instance.removeListener(_onZoomNavigationChanged);
    FingerDrawingService.instance.removeListener(_onFingerDrawingChanged);
    SpenButtonService.instance.removeListener(_onSpenButtonChanged);
    SpenButtonService.instance.stopListening();
    _toolState.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onToolStateChanged() {
    _scheduleSessionSave();
    if (_syncingFingerDrawing) return;
    final fingerEnabled = !_toolState.stylusOnly;
    if (FingerDrawingService.instance.enabled != fingerEnabled) {
      unawaited(FingerDrawingService.instance.setEnabled(fingerEnabled));
    }
  }

  void _onFingerDrawingChanged() {
    if (!mounted) return;
    _applyFingerDrawingFromService();
  }

  void _applyFingerDrawingFromService() {
    final stylusOnly = FingerDrawingService.instance.stylusOnly;
    if (_toolState.stylusOnly == stylusOnly) return;
    _syncingFingerDrawing = true;
    _toolState.set((s) => s.stylusOnly = stylusOnly);
    _syncingFingerDrawing = false;
    for (final key in _pageKeys.values) {
      key.currentState?.canvasState?.resetPointerSession();
    }
  }

  Future<void> _syncFingerDrawing() async {
    if (!FingerDrawingService.instance.isLoaded) {
      await FingerDrawingService.instance.load();
    }
    if (!mounted) return;
    _applyFingerDrawingFromService();
  }

  void _resetScrollAndPointerState() {
    for (final key in _pageKeys.values) {
      key.currentState?.resetPointerTracking();
    }
    if (_paperFingerLockCount != 0 || _pinchLockCount != 0) {
      setState(() {
        _paperFingerLockCount = 0;
        _pinchLockCount = 0;
      });
    }
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
    _resetDocumentTransform();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncViewportToVisiblePage();
    });
  }

  void _onZoomNavigationChanged() {
    if (!mounted) return;
    final enabled = ZoomNavigationService.instance.enabled;
    if (enabled == _zoomNavigationEnabled) return;
    setState(() => _zoomNavigationEnabled = enabled);
    if (!enabled) {
      _resetDocumentTransform();
    }
  }

  Future<void> _syncPageTurnMode() async {
    if (!PageTurnModeService.instance.isLoaded) {
      await PageTurnModeService.instance.load();
    }
    if (!mounted) return;
    setState(() => _pageTurnEnabled = PageTurnModeService.instance.enabled);
  }

  Future<void> _syncZoomNavigation() async {
    if (!ZoomNavigationService.instance.isLoaded) {
      await ZoomNavigationService.instance.load();
    }
    if (!mounted) return;
    setState(
      () => _zoomNavigationEnabled = ZoomNavigationService.instance.enabled,
    );
  }

  /// Unified per-page slot height for scroll and page-turn modes.
  double _pageSlotHeight(Size viewport) => viewport.height;

  Size _pageSlotViewport(Size viewport) =>
      Size(viewport.width, _pageSlotHeight(viewport));

  Size _documentViewportFromLayout(BoxConstraints constraints) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return keyboardStableViewportSize(
      layoutSize: Size(constraints.maxWidth, constraints.maxHeight),
      viewInsetBottom: viewInsets.bottom,
    );
  }

  Size get _documentViewport =>
      _stableDocumentViewport.width > 0 && _stableDocumentViewport.height > 0
          ? _stableDocumentViewport
          : MediaQuery.sizeOf(context);

  void _resetDocumentTransform() {
    _documentViewportKey.currentState?.resetTransform();
    _documentViewportKey.currentState?.resetPointerTracking();
    _resetScrollAndPointerState();
    if (_documentZoomed) {
      setState(() => _documentZoomed = false);
    }
  }

  /// Untransformed bounds of the scroll/page-turn body for pan clamping.
  Rect _documentContentBounds(Size viewport) {
    final slotViewport = _pageSlotViewport(viewport);
    if (_pageTurnEnabled || _pages.isEmpty) {
      return Offset.zero & slotViewport;
    }
    const bottomPadding = 24.0;
    final height = _pages.length * slotViewport.height + bottomPadding;
    return Rect.fromLTWH(0, 0, slotViewport.width, height);
  }

  /// Bounds of the visible page paper — used to center/fit when zooming out.
  Rect _documentFitCenterBounds(Size viewport) {
    final slotViewport = _pageSlotViewport(viewport);
    if (_pages.isEmpty) {
      return Offset.zero & slotViewport;
    }
    if (_pageTurnEnabled) {
      final idx = _visiblePageIndex.clamp(0, _pages.length - 1);
      final paper = _paperRectInSlot(_pages[idx], slotViewport);
      return paper;
    }
    final pageHeight = slotViewport.height;
    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    final pageIndex =
        (scrollOffset / pageHeight).floor().clamp(0, _pages.length - 1);
    final paper = _paperRectInSlot(_pages[pageIndex], slotViewport);
    return Rect.fromLTWH(
      paper.left,
      pageIndex * pageHeight + paper.top,
      paper.width,
      paper.height,
    );
  }

  Rect _paperRectInSlot(NotePage page, Size slotViewport) {
    final displaySize = PageCoords.pageDisplaySize(
      slotViewport,
      page.pageSize,
      orientation: page.orientation,
    );
    return Rect.fromCenter(
      center: Offset(slotViewport.width / 2, slotViewport.height / 2),
      width: displaySize.width,
      height: displaySize.height,
    );
  }

  bool _isFocalOnPaper(Offset viewportFocal) {
    if (_pages.isEmpty) return false;
    final viewport = _documentViewport;
    final slotViewport = _pageSlotViewport(viewport);
    final pageHeight = _pageSlotHeight(viewport);
    final transform =
        _documentViewportKey.currentState?.transform ?? Matrix4.identity();
    final pre = paperPointFromTransform(viewportFocal, transform);

    if (_pageTurnEnabled) {
      final idx = _visiblePageIndex.clamp(0, _pages.length - 1);
      return _paperRectInSlot(_pages[idx], slotViewport).contains(pre);
    }

    final scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    final contentY = pre.dy + scrollOffset;
    final pageIndex = (contentY / pageHeight).floor();
    if (pageIndex < 0 || pageIndex >= _pages.length) return false;
    final slotLocal = Offset(pre.dx, contentY - pageIndex * pageHeight);
    return _paperRectInSlot(_pages[pageIndex], slotViewport).contains(slotLocal);
  }

  Widget _wrapDocumentViewport(Widget child, Size viewport) {
    return DocumentViewport(
      key: _documentViewportKey,
      toolState: _toolState,
      viewportSize: viewport,
      contentBounds: _documentContentBounds(viewport),
      fitCenterBounds: _documentFitCenterBounds(viewport),
      scrollController: _pageTurnEnabled ? null : _scrollController,
      zoomEnabled: _zoomNavigationEnabled,
      isFocalOnPaper: _isFocalOnPaper,
      onTransformGestureActive: _onPageTransformGesture,
      onZoomChanged: _onDocumentZoomChanged,
      child: child,
    );
  }

  void _onDocumentZoomChanged(bool zoomed) {
    if (_documentZoomed == zoomed) return;
    setState(() => _documentZoomed = zoomed);
  }

  /// When zoomed, paint the full document (no lazy clip) so pan never shows seams.
  bool get _expandDocumentPaint =>
      _documentZoomed || _pinchLockCount > 0;

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
    final pageHeight = _pageSlotHeight(_documentViewport);
    final idx = (offset / pageHeight).round().clamp(0, _pages.length - 1);
    if (idx != _visiblePageIndex) {
      _resetScrollAndPointerState();
      setState(() => _visiblePageIndex = idx);
      _setActiveCanvas(_pageKeys[_pages[idx].id]?.currentState?.canvasState);
      unawaited(_maybeWarnPageComplexity(_pages[idx].id, onOpen: true));
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
      _resetDocumentTransform();
      _syncViewportToVisiblePage(
        scrollOffset: widget.initialScrollOffset,
      );
      unawaited(_maybeWarnPageComplexity(_pages[_visiblePageIndex].id, onOpen: true));
    });
  }

  Future<void> _maybeWarnPageComplexity(String pageId,
      {required bool onOpen}) async {
    final count = await PageComplexityService.instance.strokeCount(pageId);
    if (!PageComplexityService.shouldWarn(count)) return;
    if (onOpen && _complexityWarnedOnOpen.contains(pageId)) return;
    if (onOpen) _complexityWarnedOnOpen.add(pageId);
    _showComplexitySnackBar(count);
  }

  void _onActivePageStrokeCount(int count) {
    if (_activePageHasStrokes != (count > 0)) {
      setState(() => _activePageHasStrokes = count > 0);
    }
    if (!PageComplexityService.shouldWarn(count)) return;
    _showComplexitySnackBar(count);
  }

  Future<void> _eraseAllOnActivePage() async {
    await _activeCanvas?.eraseAllStrokesOnPage();
  }

  void _showComplexitySnackBar(int count) {
    if (!mounted) return;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pageComplexityWarning(count)),
        action: SnackBarAction(
          label: l10n.splitPageAction,
          onPressed: () => unawaited(_splitActivePage()),
        ),
      ),
    );
  }

  Future<void> _splitActivePage() async {
    final l10n = context.l10n;
    final pageId = _activePage.id;
    final count = await PageComplexityService.instance.strokeCount(pageId);
    if (count < 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.splitPageNeedStrokes),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.splitPageTitle),
        content: Text(l10n.splitPageBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionSplit),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final newPageId = _uuid.v4();
    try {
      final result = await PageComplexityService.instance.splitPage(
        notebookId: widget.notebook.id,
        sourcePageId: pageId,
        newPageId: newPageId,
      );
      if (!mounted) return;
      await _pageKeys[pageId]?.currentState?.canvasState?.reloadFromDatabase();
      final pages = await _db.pagesOf(widget.notebook.id);
      await _applyPagesUpdate(pages);
      final newIdx = pages.indexWhere((p) => p.id == newPageId);
      if (newIdx >= 0) {
        await _scrollToPage(newIdx);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.splitPageSuccess(
            result.movedStrokeCount,
            result.remainingStrokeCount,
          )),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.splitPageFailed(e.toString()))),
      );
    }
  }

  void _onVisiblePageChanged(int index) {
    if (index == _visiblePageIndex) return;
    _resetScrollAndPointerState();
    setState(() => _visiblePageIndex = index);
    _setActiveCanvas(_pageKeys[_pages[index].id]?.currentState?.canvasState);
    _scheduleSessionSave();
    unawaited(_maybeWarnPageComplexity(_pages[index].id, onOpen: true));
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
    final viewport = _documentViewport;
    final pageHeight = _pageSlotHeight(viewport);
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
    if (!mounted || state == null) return;
    setState(() {
      _canUndo = state.canUndo;
      _canRedo = state.canRedo;
      _hasSelection = state.hasSelection;
      _activePageHasStrokes = state.hasStrokes;
    });
  }

  Future<void> _convertSelectionToText() async {
    final ocr = InkOcrService.instance;
    if (!InkOcrService.disableMlKit &&
        (Platform.isAndroid || Platform.isIOS) &&
        ocr.modelStatus != InkModelStatus.ready) {
      if (!mounted) return;
      final ready = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _InkModelDownloadDialog(ocr: ocr),
      );
      if (!mounted) return;
      if (ready != true) {
        if (ocr.modelError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ocr.modelError!)),
          );
        }
        return;
      }
    }

    final text = await _activeCanvas?.convertSelectionToText();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (text != null && text.isNotEmpty) {
      final preview =
          text.length > 48 ? '${text.substring(0, 48)}…' : text;
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.convertedToText(preview))),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(context.l10n.couldNotRecognizeHandwriting)),
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

  void _onPaperFingerActive(bool active) {
    setState(() {
      if (active) {
        _paperFingerLockCount++;
      } else {
        _paperFingerLockCount = (_paperFingerLockCount - 1).clamp(0, 999);
      }
    });
  }

  bool get _scrollLocked =>
      _pinchLockCount > 0 || _paperFingerLockCount > 0;

  Future<void> _scrollToPage(int index) async {
    if (index < 0 || index >= _pages.length) return;
    _resetScrollAndPointerState();
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
      unawaited(_maybeWarnPageComplexity(_pages[index].id, onOpen: true));
      return;
    }
    final pageHeight = _pageSlotHeight(_documentViewport);
    await _scrollController.animateTo(
      index * pageHeight,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    setState(() => _visiblePageIndex = index);
    unawaited(_maybeWarnPageComplexity(_pages[index].id, onOpen: true));
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

  Future<String?> _exportBlockReason({String? pageId, List<String>? pageIds}) {
    final ids = pageId != null ? [pageId] : pageIds ?? [];
    return PageComplexityService.instance
        .exportBlockReasonForPages(ids, context.l10n);
  }

  Future<void> _openPageTemplateSettings() async {
    final chosen = await showPageTemplatePicker(
      context: context,
      page: _activePage,
      isPdfPage: _isPdfPage(_activePage),
    );
    await _handlePageActionResult(chosen);
  }

  Future<void> _openPageSizeSettings() async {
    final chosen = await showPageSizePicker(
      context: context,
      page: _activePage,
      isPdfPage: _isPdfPage(_activePage),
    );
    await _handlePageActionResult(chosen);
  }

  Future<void> _openPageOrientationSettings() async {
    final chosen = await showPageOrientationPicker(
      context: context,
      page: _activePage,
      isPdfPage: _isPdfPage(_activePage),
    );
    await _handlePageActionResult(chosen);
  }

  Future<void> _openPageExportMenu() async {
    final chosen = await showPageExportPicker(
      context: context,
      notebookPageCount: _pages.length,
    );
    await _handlePageActionResult(chosen);
  }

  Future<void> _openPageAudioSettings() async {
    await showPageAudioSheet(
      context: context,
      page: _activePage,
      onAudioChanged: (path) {
        _activePage.audioPath = path;
      },
    );
  }

  Future<void> _togglePageBookmark() async {
    final next = !_activePage.bookmarked;
    await _db.setPageBookmarked(_activePage.id, next);
    if (!mounted) return;
    setState(() => _activePage.bookmarked = next);
  }

  Future<void> _showEditorPageMenu(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    if (box == null || !mounted) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final action = await showEditorPageMenu(
      context: context,
      position: position,
      bookmarked: _activePage.bookmarked,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case EditorPageMenuAction.pageSettings:
        await _openPageTemplateSettings();
      case EditorPageMenuAction.pageSize:
        await _openPageSizeSettings();
      case EditorPageMenuAction.orientation:
        await _openPageOrientationSettings();
      case EditorPageMenuAction.contents:
        await _openContents();
      case EditorPageMenuAction.bookmark:
        await _togglePageBookmark();
      case EditorPageMenuAction.audio:
        await _openPageAudioSettings();
      case EditorPageMenuAction.split:
        await _splitActivePage();
      case EditorPageMenuAction.export:
        await _openPageExportMenu();
    }
  }

  Future<void> _handlePageActionResult(Object? chosen) async {
    if (chosen == null || !mounted) return;
    final l10n = context.l10n;

    if (chosen is PageTemplate) {
      if (_activePage.pdfImagePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.pdfPagesKeepBackground)));
        return;
      }
      await _db.updatePageTemplate(_activePage.id, chosen);
      setState(() => _activePage.template = chosen);
      return;
    }

    if (chosen is PageSize) {
      if (_isPdfPage(_activePage)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.pdfPagesKeepDimensions)));
        return;
      }
      if (chosen == _activePage.pageSize) return;
      if (await _db.pageHasInk(_activePage.id)) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.changePageSizeTitle),
            content: Text(l10n.changePageSizeBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.actionChangeSize),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
      await _db.updatePageSize(_activePage.id, chosen);
      setState(() => _activePage.pageSize = chosen);
      _resetDocumentTransform();
      return;
    }

    if (chosen is PageOrientation) {
      if (_isPdfPage(_activePage)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.pdfPagesKeepOrientation)));
        return;
      }
      if (chosen == _activePage.orientation) return;
      if (await _db.pageHasInk(_activePage.id)) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.changeOrientationTitle),
            content: Text(l10n.changeOrientationBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.actionChangeOrientation),
              ),
            ],
          ),
        );
        if (ok != true || !mounted) return;
      }
      final aspect = chosen.aspectOf(_activePage.pageSize);
      await _db.updatePageOrientationAndRemapContent(
        page: _activePage,
        to: chosen,
      );
      setState(() {
        _activePage.orientation = chosen;
        _activePage.aspect = aspect;
      });
      await _pageKeys[_activePage.id]
          ?.currentState
          ?.canvasState
          ?.reloadFromDatabase();
      _resetDocumentTransform();
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

  Future<void> _exportCurrentPage(ExportFormat format) async {
    final l10n = context.l10n;
    final blockReason =
        await _exportBlockReason(pageId: _activePage.id);
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
            ? l10n.pageExportedAsPng
            : l10n.pageExportedAsPdf),
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))));
    }
  }

  Future<void> _exportNotebookPdf() async {
    final l10n = context.l10n;
    final blockReason = await _exportBlockReason(
      pageIds: _pages.map((p) => p.id).toList(),
    );
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
        totalPages: _pages.length,
        run: (onProgress) => PageExportService.instance.exportNotebook(
          pages: _pages,
          notebookTitle: widget.notebook.title,
          onProgress: onProgress,
        ),
      );
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.notebookExportedAsPdfSnack)));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.exportFailed(e.toString()))));
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

  Widget _pageEditorAt(int i, Size slotViewport) {
    return PageEditor(
      key: _pageKeys[_pages[i].id],
      page: _pages[i],
      notebook: widget.notebook,
      toolState: _toolState,
      viewportSize: slotViewport,
      zoomEnabled: false,
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
      onStrokeCountChanged: i == _visiblePageIndex
          ? _onActivePageStrokeCount
          : null,
      onTransformGestureActive: _onPageTransformGesture,
      onPaperFingerActive: _onPaperFingerActive,
    );
  }

  Widget _buildScrollBody(Size viewport) {
    final slotViewport = _pageSlotViewport(viewport);
    final pageHeight = slotViewport.height;
    final contentHeight = _documentContentBounds(viewport).height;
    final expandPaint = _expandDocumentPaint;
    return _wrapDocumentViewport(
      ScrollConfiguration(
        behavior: const PenfoldScrollBehavior(),
        child: CustomScrollView(
          controller: _scrollController,
          // Avoid pre-transform viewport clipping that shows white seams when
          // Transform scales/pans the scroll body.
          clipBehavior: expandPaint ? Clip.none : Clip.hardEdge,
          cacheExtent: expandPaint ? contentHeight : null,
          physics: _scrollLocked
              ? const NeverScrollableScrollPhysics()
              : const AlwaysScrollableScrollPhysics(),
          slivers: [
            for (var i = 0; i < _pages.length; i++)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: pageHeight,
                  child: _pageEditorAt(i, slotViewport),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
      viewport,
    );
  }

  Widget _buildPageTurnBody(Size viewport) {
    final slotViewport = _pageSlotViewport(viewport);
    final expandPaint = _expandDocumentPaint;
    return _wrapDocumentViewport(
      PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        clipBehavior: expandPaint ? Clip.none : Clip.hardEdge,
        physics: _scrollLocked
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: _onVisiblePageChanged,
        itemCount: _pages.length,
        itemBuilder: (context, i) => _pageEditorAt(i, slotViewport),
      ),
      viewport,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _popToLibrary();
      },
      child: Scaffold(
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
          onPageMenu: _showEditorPageMenu,
          onAddImage: _addImage,
          onPageOverview: _openOverview,
          onContents: _openContents,
          canPrevBookmark: _canPrevBookmark,
          canNextBookmark: _canNextBookmark,
          onPrevBookmark: _jumpToPrevBookmark,
          onNextBookmark: _jumpToNextBookmark,
          onBack: _popToLibrary,
          hasPageStrokes: _activePageHasStrokes,
          onEraseAllOnPage: _eraseAllOnActivePage,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final viewport = _documentViewportFromLayout(constraints);
                  _stableDocumentViewport = viewport;
                  return _pageTurnEnabled
                      ? _buildPageTurnBody(viewport)
                      : _buildScrollBody(viewport);
                },
              ),
      ),
    );
  }
}

class _InkModelDownloadDialog extends StatefulWidget {
  const _InkModelDownloadDialog({required this.ocr});

  final InkOcrService ocr;

  @override
  State<_InkModelDownloadDialog> createState() => _InkModelDownloadDialogState();
}

class _InkModelDownloadDialogState extends State<_InkModelDownloadDialog> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    unawaited(_startDownload());
  }

  Future<void> _startDownload() async {
    final ready = await widget.ocr.ensureModelReady();
    if (!mounted) return;
    if (ready) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _retrying = false);
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    final ready = await widget.ocr.retryModelDownload();
    if (!mounted) return;
    if (ready) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _retrying = false);
  }

  String _formatElapsed(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.handwritingModelTitle),
      content: ValueListenableBuilder<InkModelStatus>(
        valueListenable: widget.ocr.modelStatusNotifier,
        builder: (context, status, _) {
          final statusLine = switch (status) {
            InkModelStatus.error =>
              widget.ocr.modelError ?? l10n.handwritingModelDownloadFailed,
            InkModelStatus.downloading ||
            InkModelStatus.notReady =>
              l10n.handwritingModelDownloading(inkRecognitionModelSizeEstimateMb),
            InkModelStatus.ready => l10n.handwritingModelReady,
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status != InkModelStatus.error)
                const LinearProgressIndicator(),
              if (status == InkModelStatus.error)
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 32,
                ),
              const SizedBox(height: 16),
              Text(statusLine),
              const SizedBox(height: 8),
              Text(
                l10n.handwritingModelElapsed(_formatElapsed(_elapsed)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.handwritingModelDownloadHint(inkRecognitionModelSizeEstimateMb),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (widget.ocr.modelStatus == InkModelStatus.error) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: _retrying ? null : _retry,
            child: Text(_retrying ? l10n.actionRetrying : l10n.actionRetry),
          ),
        ],
      ],
    );
  }
}
