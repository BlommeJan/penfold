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

  void _setActiveCanvas(DrawingCanvasState? state) {
    _activeCanvas = state;
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

  Future<void> _pickTemplate() async {
    final chosen = await showModalBottomSheet<PageTemplate>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    if (_activePage.pdfImagePath != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('PDF pages keep their document background')));
      }
      return;
    }
    await _db.updatePageTemplate(_activePage.id, chosen);
    setState(() => _activePage.template = chosen);
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
      backgroundColor: const Color(0xFFEDF0F4),
      appBar: EditorToolbar(
        toolState: _toolState,
        canUndo: _canUndo,
        canRedo: _canRedo,
        hasSelection: _hasSelection,
        canPaste: _activeCanvas?.canPaste ?? false,
        pageIndex: _visiblePageIndex,
        pageCount: _pages.length,
        onUndo: () => _activeCanvas?.undo(),
        onRedo: () => _activeCanvas?.redo(),
        onDeleteSelection: () => _activeCanvas?.deleteSelection(),
        onCopy: () => _activeCanvas?.copySelection(),
        onPaste: () => _activeCanvas?.pasteClipboard(),
        onAddPage: _addPage,
        onTemplate: _pickTemplate,
        onAddImage: _addImage,
        onPageOverview: _openOverview,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ScrollConfiguration(
              behavior: const PenfoldScrollBehavior(),
              child: CustomScrollView(
                controller: _scrollController,
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
