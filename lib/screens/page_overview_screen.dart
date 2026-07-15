import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../canvas/painters.dart';
import '../db/app_database.dart';
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

/// Thumbnail grid of all pages; tap to jump back to a page in the notebook.
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _preload();
  }

  Future<void> _preload() async {
    for (final page in widget.pages) {
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
    _ocrStatus = await _db.ocrStatusOfPages(widget.pages.map((p) => p.id));
    if (mounted) setState(() => _loading = false);
  }

  int _columnCount(double width) => (width / 108).floor().clamp(4, 8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = _columnCount(width);

    return Scaffold(
      backgroundColor: const Color(0xFFEDF0F4),
      appBar: AppBar(
        title: Text('${widget.notebook.title} — Pages'),
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
              itemCount: widget.pages.length,
              itemBuilder: (context, i) {
                final page = widget.pages[i];
                final preview = _cache[page.id] ?? const _PagePreviewData();
                final ocr = _ocrStatus[page.id] ?? const PageOcrStatus();
                final hasPdf = page.pdfImagePath != null ||
                    page.pdfSourcePath != null;
                final ps = hasPdf
                    ? PageSize.values.firstWhere(
                        (s) => (s.aspect - page.aspect).abs() < 0.01,
                        orElse: () => page.pageSize,
                      )
                    : page.pageSize;
                final orient =
                    hasPdf ? PageOrientation.portrait : page.orientation;
                return GestureDetector(
                  onTap: () {
                    widget.onPageSelected(i);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${i + 1}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _BookmarkBadge extends StatelessWidget {
  const _BookmarkBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Bookmarked',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
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
    late final IconData icon;
    late final Color color;
    late final String tip;
    if (status.hasPending) {
      icon = Icons.hourglass_top_rounded;
      color = const Color(0xFFE67E22);
      tip = 'OCR indexing…';
    } else if (status.isComplete) {
      icon = Icons.search_rounded;
      color = const Color(0xFF1E8449);
      tip = 'Handwriting searchable';
    } else {
      icon = Icons.text_fields_outlined;
      color = const Color(0xFF7F8C8D);
      tip = 'OCR partial';
    }

    return Tooltip(
      message: tip,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}
