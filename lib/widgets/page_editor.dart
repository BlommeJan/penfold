import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../canvas/drawing_canvas.dart';
import '../canvas/page_coords.dart';
import '../canvas/page_viewport.dart';
import '../models/models.dart';

/// One page card in the scrollable notebook: gated viewport + drawing canvas.
class PageEditor extends StatefulWidget {
  final NotePage page;
  final Notebook notebook;
  final ToolState toolState;
  final Size viewportSize;
  final void Function(DrawingCanvasState state)? onCanvasReady;
  final void Function(bool canUndo, bool canRedo)? onHistoryChanged;
  final void Function(bool hasSelection)? onSelectionChanged;

  const PageEditor({
    super.key,
    required this.page,
    required this.notebook,
    required this.toolState,
    required this.viewportSize,
    this.onCanvasReady,
    this.onHistoryChanged,
    this.onSelectionChanged,
  });

  @override
  State<PageEditor> createState() => PageEditorState();
}

class PageEditorState extends State<PageEditor> {
  final _canvasKey = GlobalKey<DrawingCanvasState>();
  final _viewportKey = GlobalKey<PageViewportState>();
  ui.Image? _pdfImage;

  PageSize get _pageSize => widget.page.pdfImagePath != null
      ? PageSize.values.firstWhere(
          (ps) => (ps.aspect - widget.page.aspect).abs() < 0.01,
          orElse: () => widget.page.pageSize,
        )
      : widget.page.pageSize;

  Size get displaySize =>
      PageCoords.pageDisplaySize(widget.viewportSize, _pageSize);

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
    final path = widget.page.pdfImagePath;
    if (path == null) {
      if (mounted) setState(() => _pdfImage = null);
      return;
    }
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) setState(() => _pdfImage = frame.image);
    } catch (_) {
      if (mounted) setState(() => _pdfImage = null);
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
            child: DrawingCanvas(
              key: _canvasKey,
              page: widget.page,
              toolState: widget.toolState,
              displaySize: size,
              pageSize: _pageSize,
              pdfImage: _pdfImage,
              onHistoryChanged: widget.onHistoryChanged,
              onSelectionChanged: widget.onSelectionChanged,
            ),
          ),
        ),
      ),
    );
  }
}
