import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../canvas/drawing_canvas.dart';
import '../canvas/page_coords.dart';
import '../canvas/page_viewport.dart';
import '../models/models.dart';
import '../services/pdf_link_extractor.dart';
import '../services/pdf_page_cache.dart';
import 'pdf_link_overlay.dart';

/// One page card in the scrollable notebook: gated viewport + drawing canvas.
class PageEditor extends StatefulWidget {
  final NotePage page;
  final Notebook notebook;
  final ToolState toolState;
  final Size viewportSize;
  final void Function(DrawingCanvasState state)? onCanvasReady;
  final void Function(bool canUndo, bool canRedo)? onHistoryChanged;
  final void Function(bool hasSelection)? onSelectionChanged;
  final void Function(int strokeCount)? onStrokeCountChanged;
  final ValueChanged<bool>? onTransformGestureActive;
  final ValueChanged<bool>? onPaperFingerActive;

  const PageEditor({
    super.key,
    required this.page,
    required this.notebook,
    required this.toolState,
    required this.viewportSize,
    this.onCanvasReady,
    this.onHistoryChanged,
    this.onSelectionChanged,
    this.onStrokeCountChanged,
    this.onTransformGestureActive,
    this.onPaperFingerActive,
  });

  @override
  State<PageEditor> createState() => PageEditorState();
}

class PageEditorState extends State<PageEditor> {
  final _canvasKey = GlobalKey<DrawingCanvasState>();
  final _viewportKey = GlobalKey<PageViewportState>();
  ui.Image? _pdfImage;
  bool _pdfLoading = false;
  List<PdfPageLink> _pdfLinks = const [];

  bool get _hasPdfBackground =>
      widget.page.pdfImagePath != null || widget.page.pdfSourcePath != null;

  PageSize get _pageSize {
    if (!_hasPdfBackground) return widget.page.pageSize;
    final storedAspect =
        widget.page.orientation.aspectOf(widget.page.pageSize);
    if ((storedAspect - widget.page.aspect).abs() < 0.02) {
      return widget.page.pageSize;
    }
    return layoutFromAspect(widget.page.aspect).pageSize;
  }

  PageOrientation get _orientation {
    if (!_hasPdfBackground) return widget.page.orientation;
    final storedAspect =
        widget.page.orientation.aspectOf(_pageSize);
    if ((storedAspect - widget.page.aspect).abs() < 0.02) {
      return widget.page.orientation;
    }
    return widget.page.aspect > 1.0
        ? PageOrientation.landscape
        : PageOrientation.portrait;
  }

  Size get displaySize => PageCoords.pageDisplaySize(
        widget.viewportSize,
        _pageSize,
        orientation: _orientation,
      );

  DrawingCanvasState? get canvasState => _canvasKey.currentState;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(covariant PageEditor old) {
    super.didUpdateWidget(old);
    if (old.page.id != widget.page.id) {
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
    final legacyPath = widget.page.pdfImagePath;
    final lazySource = widget.page.pdfSourcePath;
    final lazyIndex = widget.page.pdfPageIndex;

    if (legacyPath == null && lazySource == null) {
      if (mounted) setState(() {
        _pdfImage = null;
        _pdfLinks = const [];
        _pdfLoading = false;
      });
      return;
    }

    if (mounted) setState(() => _pdfLoading = true);

    try {
      ui.Image? image;
      var links = const <PdfPageLink>[];
      if (legacyPath != null) {
        final bytes = await File(legacyPath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        image = frame.image;
      } else if (lazySource != null && lazyIndex != null) {
        image = await PdfPageCache.instance.getPage(lazySource, lazyIndex);
        links = PdfLinkExtractor.extractPageLinks(lazySource, lazyIndex);
      }
      if (mounted) {
        setState(() {
          _pdfImage = image;
          _pdfLinks = links;
          _pdfLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pdfImage = null;
          _pdfLinks = const [];
          _pdfLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = displaySize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _canvasKey.currentState;
      if (state != null) widget.onCanvasReady?.call(state);
    });

    return Center(
      child: RepaintBoundary(
        child: PageViewport(
          key: _viewportKey,
          toolState: widget.toolState,
          paperSize: size,
          onTransformGestureActive: widget.onTransformGestureActive,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DrawingCanvas(
                  key: _canvasKey,
                  page: widget.page,
                  toolState: widget.toolState,
                  displaySize: size,
                  pageSize: _pageSize,
                  pdfImage: _pdfImage,
                  onHistoryChanged: widget.onHistoryChanged,
                  onSelectionChanged: widget.onSelectionChanged,
                  onStrokeCountChanged: widget.onStrokeCountChanged,
                  onPaperFingerActive: widget.onPaperFingerActive,
                ),
                if (_pdfLinks.isNotEmpty)
                  PdfLinkOverlay(links: _pdfLinks, displaySize: size),
                if (_pdfLoading && _pdfImage == null && _hasPdfBackground)
                  const ColoredBox(
                    color: Color(0xFFF4F6F9),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
