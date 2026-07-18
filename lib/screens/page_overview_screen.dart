import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../canvas/painters.dart';
import '../db/app_database.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../services/pdf_page_cache.dart';

class _PagePreviewData {
  final List<Stroke> strokes;
  final List<FilledRegion> fills;
  final List<TextBlock> textBlocks;
  final ui.Image? pdfImage;

  const _PagePreviewData({
    this.strokes = const [],
    this.fills = const [],
    this.textBlocks = const [],
    this.pdfImage,
  });
}

/// Thumbnail grid of all pages; tap to jump, drag to reorder, multi-select delete.
class PageOverviewScreen extends StatefulWidget {
  final Notebook notebook;
  final List<NotePage> pages;
  final void Function(int pageIndex) onPageSelected;

  const PageOverviewScreen({
    super.key,
    required this.notebook,
    required this.pages,
    required this.onPageSelected,
  });

  @override
  State<PageOverviewScreen> createState() => _PageOverviewScreenState();
}

class _PageOverviewScreenState extends State<PageOverviewScreen> {
  final _db = AppDatabase.instance;
  final Map<String, _PagePreviewData> _cache = {};
  Map<String, PageOcrStatus> _ocrStatus = {};
  late List<NotePage> _pages;
  final Set<String> _selectedIds = {};
  bool _loading = true;
  bool _selectMode = false;
  bool _dirty = false;
  int? _dragSourceIndex;

  @override
  void initState() {
    super.initState();
    _pages = List<NotePage>.from(widget.pages);
    _preload();
  }

  Future<void> _preload() async {
    for (final page in _pages) {
      final strokes = await _db.strokesOf(page.id);
      final fills = await _db.fillsOf(page.id);
      final texts = await _db.textBlocksOf(page.id);
      ui.Image? pdfImage;
      final pdfPath = page.pdfImagePath;
      if (pdfPath != null) {
        try {
          final bytes = await File(pdfPath).readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          pdfImage = frame.image;
        } catch (_) {
          pdfImage = null;
        }
      } else if (page.pdfSourcePath != null && page.pdfPageIndex != null) {
        pdfImage = await PdfPageCache.instance.getPage(
          page.pdfSourcePath!,
          page.pdfPageIndex!,
        );
      }
      _cache[page.id] = _PagePreviewData(
        strokes: strokes,
        fills: fills,
        textBlocks: texts,
        pdfImage: pdfImage,
      );
    }
    _ocrStatus = await _db.ocrStatusOfPages(_pages.map((p) => p.id));
    if (mounted) setState(() => _loading = false);
  }

  void _popWithResult() {
    Navigator.pop(context, _dirty ? _pages : null);
  }

  void _enterSelectMode(String pageId) {
    setState(() {
      _selectMode = true;
      _selectedIds.add(pageId);
    });
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String pageId) {
    setState(() {
      if (_selectedIds.contains(pageId)) {
        _selectedIds.remove(pageId);
        if (_selectedIds.isEmpty) {
          _selectMode = false;
        }
      } else {
        _selectedIds.add(pageId);
      }
    });
  }

  Future<void> _persistOrder() async {
    await _db.reorderPages(
      widget.notebook.id,
      _pages.map((p) => p.id).toList(),
    );
    for (var i = 0; i < _pages.length; i++) {
      _pages[i].index = i;
    }
    _dirty = true;
  }

  void _movePage(int from, int to) {
    if (from == to || from < 0 || to < 0 || from >= _pages.length || to >= _pages.length) {
      return;
    }
    setState(() {
      final page = _pages.removeAt(from);
      _pages.insert(to, page);
    });
    _persistOrder();
  }

  Future<void> _confirmDelete() async {
    if (_selectedIds.isEmpty) return;
    final l10n = context.l10n;
    if (_selectedIds.length >= _pages.length) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pageOverviewKeepOnePage)),
      );
      return;
    }

    final count = _selectedIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pageOverviewDeleteTitle(count)),
        content: Text(l10n.pageOverviewDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final ids = _selectedIds.toList();
    await _db.deletePagesBatch(widget.notebook.id, ids);
    if (!mounted) return;

    setState(() {
      _pages.removeWhere((p) => ids.contains(p.id));
      for (final id in ids) {
        _cache.remove(id);
        _ocrStatus.remove(id);
      }
      for (var i = 0; i < _pages.length; i++) {
        _pages[i].index = i;
      }
      _selectedIds.clear();
      _selectMode = false;
      _dirty = true;
    });
  }

  int _columnCount(double width) => (width / 108).floor().clamp(4, 8);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final columns = _columnCount(width);
    final selectionCount = _selectedIds.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _popWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: _popWithResult),
          title: Text(_selectMode
              ? l10n.pageOverviewSelected(selectionCount)
              : '${widget.notebook.title}${l10n.pageOverviewPagesSuffix}'),
          actions: [
            if (_selectMode) ...[
              IconButton(
                tooltip: l10n.pageOverviewDeleteSelected,
                onPressed: selectionCount > 0 ? _confirmDelete : null,
                icon: const Icon(Icons.delete_outline),
              ),
              TextButton(
                onPressed: _exitSelectMode,
                child: Text(l10n.actionDone),
              ),
            ] else ...[
              IconButton(
                tooltip: l10n.pageOverviewSelectPages,
                onPressed: () => setState(() => _selectMode = true),
                icon: const Icon(Icons.checklist_rounded),
              ),
            ],
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemCount: _pages.length,
                itemBuilder: (context, i) => _PageTile(
                  key: ValueKey(_pages[i].id),
                  index: i,
                  page: _pages[i],
                  preview: _cache[_pages[i].id] ?? const _PagePreviewData(),
                  ocr: _ocrStatus[_pages[i].id] ?? const PageOcrStatus(),
                  selectMode: _selectMode,
                  selected: _selectedIds.contains(_pages[i].id),
                  isDragSource: _dragSourceIndex == i,
                  isDropTarget: _dragSourceIndex != null && _dragSourceIndex != i,
                  onTap: () {
                    if (_selectMode) {
                      _toggleSelection(_pages[i].id);
                    } else {
                      widget.onPageSelected(i);
                      _popWithResult();
                    }
                  },
                  onLongPress: () => _enterSelectMode(_pages[i].id),
                  onToggleSelect: () => _toggleSelection(_pages[i].id),
                  onDragStarted: () => setState(() => _dragSourceIndex = i),
                  onDragEnded: () => setState(() => _dragSourceIndex = null),
                  onAcceptDrag: (from) => _movePage(from, i),
                ),
              ),
      ),
    );
  }
}

class _PageTile extends StatelessWidget {
  final int index;
  final NotePage page;
  final _PagePreviewData preview;
  final PageOcrStatus ocr;
  final bool selectMode;
  final bool selected;
  final bool isDragSource;
  final bool isDropTarget;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggleSelect;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final void Function(int fromIndex) onAcceptDrag;

  const _PageTile({
    super.key,
    required this.index,
    required this.page,
    required this.preview,
    required this.ocr,
    required this.selectMode,
    required this.selected,
    required this.isDragSource,
    required this.isDropTarget,
    required this.onTap,
    required this.onLongPress,
    required this.onToggleSelect,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onAcceptDrag,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overlaySurface = scheme.surface.withOpacity(0.92);
    final hasPdf =
        page.pdfImagePath != null || page.pdfSourcePath != null;
    final ps = hasPdf
        ? PageSize.values.firstWhere(
            (s) => (s.aspect - page.aspect).abs() < 0.01,
            orElse: () => page.pageSize,
          )
        : page.pageSize;
    final orient = hasPdf ? PageOrientation.portrait : page.orientation;

    final thumbnail = Opacity(
      opacity: isDragSource ? 0.35 : 1,
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: page.backgroundTheme.paperColor,
                borderRadius: BorderRadius.circular(6),
                border: selected
                    ? Border.all(color: const Color(0xFF2455C3), width: 2)
                    : isDropTarget
                        ? Border.all(
                            color: const Color(0xFF2455C3).withOpacity(0.45),
                            width: 2,
                          )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: PageThumbnailPainter(
                        template: page.template,
                        pageSize: ps,
                        orientation: orient,
                        backgroundTheme: page.backgroundTheme,
                        strokes: preview.strokes,
                        fills: preview.fills,
                        textBlocks: preview.textBlocks,
                        pdfImage: preview.pdfImage,
                      ),
                      child: const SizedBox.expand(),
                    ),
                    if (page.bookmarked)
                      const Positioned(
                        left: 4,
                        bottom: 4,
                        child: _BookmarkBadge(),
                      ),
                    if (ocr.hasInk)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: _OcrBadge(status: ocr),
                      ),
                    if (selectMode)
                      Positioned(
                        left: 4,
                        top: 4,
                        child: _SelectCheckbox(
                          selected: selected,
                          onChanged: onToggleSelect,
                        ),
                      )
                    else
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Draggable<int>(
                          data: index,
                          feedback: Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 72,
                              height: 96,
                              child: _MiniThumbnail(
                                page: page,
                                preview: preview,
                                pageSize: ps,
                                orientation: orient,
                              ),
                            ),
                          ),
                          childWhenDragging: const SizedBox(
                            width: 28,
                            height: 28,
                          ),
                          onDragStarted: onDragStarted,
                          onDragEnd: (_) => onDragEnded(),
                          child: Tooltip(
                            message: context.l10n.pageOverviewDragToReorder,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: overlaySurface,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.drag_handle_rounded,
                                size: 16,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${index + 1}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );

    final tile = GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: thumbnail,
    );

    if (selectMode) return tile;

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onAcceptDrag(details.data),
      builder: (context, candidateData, rejectedData) => tile,
    );
  }
}

class _MiniThumbnail extends StatelessWidget {
  final NotePage page;
  final _PagePreviewData preview;
  final PageSize pageSize;
  final PageOrientation orientation;

  const _MiniThumbnail({
    required this.page,
    required this.preview,
    required this.pageSize,
    required this.orientation,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CustomPaint(
        painter: PageThumbnailPainter(
          template: page.template,
          pageSize: pageSize,
          orientation: orientation,
          backgroundTheme: page.backgroundTheme,
          strokes: preview.strokes,
          fills: preview.fills,
          textBlocks: preview.textBlocks,
          pdfImage: preview.pdfImage,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SelectCheckbox extends StatelessWidget {
  final bool selected;
  final VoidCallback onChanged;

  const _SelectCheckbox({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onChanged,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary
              : scheme.surface.withOpacity(0.92),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline,
            width: 1.5,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _BookmarkBadge extends StatelessWidget {
  const _BookmarkBadge();

  @override
  Widget build(BuildContext context) {
    final overlaySurface =
        Theme.of(context).colorScheme.surface.withOpacity(0.92);
    return Tooltip(
      message: context.l10n.pageOverviewBookmarked,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: overlaySurface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.bookmark_rounded,
          size: 14,
          color: Color(0xFFE67E22),
        ),
      ),
    );
  }
}

class _OcrBadge extends StatelessWidget {
  final PageOcrStatus status;

  const _OcrBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    late final IconData icon;
    late final Color color;
    late final String tip;
    if (status.hasPending) {
      icon = Icons.hourglass_top_rounded;
      color = const Color(0xFFE67E22);
      tip = l10n.ocrIndexing;
    } else if (status.isComplete) {
      icon = Icons.search_rounded;
      color = const Color(0xFF1E8449);
      tip = l10n.ocrHandwritingSearchable;
    } else {
      icon = Icons.text_fields_outlined;
      color = const Color(0xFF7F8C8D);
      tip = l10n.ocrPartial;
    }

    final overlaySurface =
        Theme.of(context).colorScheme.surface.withOpacity(0.92);
    return Tooltip(
      message: tip,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: overlaySurface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
