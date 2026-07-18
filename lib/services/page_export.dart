import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../canvas/page_coords.dart';
import '../canvas/painters.dart';
import '../db/app_database.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import 'pdf_page_cache.dart';

/// Export resolution multiplier over canonical page coordinates.
const exportPixelRatio = 2.0;

/// Paints pen and highlighter strokes as vector PDF paths (not raster).
void paintVectorInkOnPdf(
  PdfGraphics canvas,
  PdfPoint pdfSize,
  PageSize pageSize,
  List<Stroke> strokes, {
  PageOrientation orientation = PageOrientation.portrait,
}) {
  final penStrokes = <Stroke>[];
  final highlighterStrokes = <Stroke>[];
  final tapeStrokes = <Stroke>[];
  for (final s in strokes) {
    switch (s.tool) {
      case ToolType.pen:
        penStrokes.add(s);
      case ToolType.highlighter:
        highlighterStrokes.add(s);
      case ToolType.tape:
        tapeStrokes.add(s);
      case ToolType.eraser:
      case ToolType.lasso:
      case ToolType.selection:
      case ToolType.shape:
      case ToolType.fill:
      case ToolType.text:
        break;
    }
  }

  for (final s in penStrokes) {
    _paintPdfPenStroke(canvas, s, pdfSize, pageSize, orientation: orientation);
  }

  if (highlighterStrokes.isNotEmpty) {
    canvas.saveContext();
    canvas.setGraphicState(const PdfGraphicState(
      strokeOpacity: 0.35,
      blendMode: PdfBlendMode.multiply,
    ));
    for (final s in highlighterStrokes) {
      _paintPdfHighlighterStroke(
          canvas, s, pdfSize, pageSize, orientation: orientation);
    }
    canvas.restoreContext();
  }

  if (tapeStrokes.isNotEmpty) {
    for (final s in tapeStrokes) {
      canvas.saveContext();
      canvas.setGraphicState(PdfGraphicState(
        strokeOpacity: s.hidden ? 0.18 : 0.62,
      ));
      _paintPdfTapeStroke(
          canvas, s, pdfSize, pageSize, orientation: orientation);
      canvas.restoreContext();
    }
  }
}

Offset _canonicalToPdf(
  double x,
  double y,
  PdfPoint pdfSize,
  PageSize pageSize, {
  PageOrientation orientation = PageOrientation.portrait,
}) {
  final dims = PageCoords.canonicalSize(pageSize, orientation: orientation);
  return Offset(
    x * pdfSize.x / dims.width,
    pdfSize.y - y * pdfSize.y / dims.height,
  );
}

double _canonicalLenToPdf(
  double canonicalLen,
  PdfPoint pdfSize,
  PageSize pageSize, {
  PageOrientation orientation = PageOrientation.portrait,
}) {
  final dims = PageCoords.canonicalSize(pageSize, orientation: orientation);
  final scaleX = pdfSize.x / dims.width;
  final scaleY = pdfSize.y / dims.height;
  return canonicalLen * (scaleX + scaleY) / 2;
}

PdfColor _strokePdfColor(Stroke s) {
  final argb = s.color;
  return PdfColor.fromInt(0xFF000000 | (argb & 0xFFFFFF));
}

void _paintPdfPenStroke(
  PdfGraphics canvas,
  Stroke s,
  PdfPoint pdfSize,
  PageSize pageSize, {
  PageOrientation orientation = PageOrientation.portrait,
}) {
  final pts = s.points;
  if (pts.isEmpty) return;

  canvas.saveContext();
  final opacity = switch (s.brushStyle) {
    BrushStyle.pencil => 0.6,
    BrushStyle.marker => 0.75,
    _ => 1.0,
  };
  if (opacity < 1.0) {
    canvas.setGraphicState(PdfGraphicState(strokeOpacity: opacity));
  }

  final color = _strokePdfColor(s);
  canvas.setStrokeColor(color);
  final isSquareCap =
      s.brushStyle == BrushStyle.marker;
  canvas.setLineCap(isSquareCap ? PdfLineCap.square : PdfLineCap.round);
  canvas.setLineJoin(PdfLineJoin.round);

  final displayWidth =
      _canonicalLenToPdf(s.width, pdfSize, pageSize, orientation: orientation);

  if (pts.length == 1) {
    final c = _canonicalToPdf(pts[0].x, pts[0].y, pdfSize, pageSize,
        orientation: orientation);
    canvas.setFillColor(color);
    canvas.drawEllipse(c.dx, c.dy, displayWidth / 2, displayWidth / 2);
    canvas.fillPath();
    canvas.restoreContext();
    return;
  }

  if (s.brushStyle == BrushStyle.pencil) {
    final dashScale =
        _canonicalLenToPdf(1, pdfSize, pageSize, orientation: orientation);
    canvas.setLineDashPattern([3 * dashScale, 2 * dashScale]);
    canvas.setLineWidth(displayWidth * 0.8);
    for (var i = 1; i < pts.length; i++) {
      final da = _canonicalToPdf(
          pts[i - 1].x, pts[i - 1].y, pdfSize, pageSize,
          orientation: orientation);
      final db = _canonicalToPdf(pts[i].x, pts[i].y, pdfSize, pageSize,
          orientation: orientation);
      canvas.moveTo(da.dx, da.dy);
      canvas.lineTo(db.dx, db.dy);
      canvas.strokePath();
    }
    canvas.restoreContext();
    return;
  }

  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    final da =
        _canonicalToPdf(a.x, a.y, pdfSize, pageSize, orientation: orientation);
    final db =
        _canonicalToPdf(b.x, b.y, pdfSize, pageSize, orientation: orientation);
    final pressure = ((a.p + b.p) / 2).clamp(0.15, 1.0);
    final velocity = Offset(b.x - a.x, b.y - a.y).distance;
    final velFactor = switch (s.brushStyle) {
      BrushStyle.fountainPen => (1.0 - (velocity / 80).clamp(0.0, 0.35)),
      BrushStyle.calligraphy => (0.65 + (velocity / 120).clamp(0.0, 0.55)),
      _ => 1.0,
    };
    final pressureCurve = switch (s.brushStyle) {
      BrushStyle.fountainPen => (0.25 + 1.1 * pressure * pressure),
      BrushStyle.calligraphy => (0.35 + 0.9 * pressure),
      BrushStyle.marker => (0.85 + 0.25 * pressure),
      _ => (0.45 + 0.75 * pressure),
    };
    var strokeW = displayWidth * pressureCurve * velFactor;
    if (s.brushStyle == BrushStyle.marker) strokeW *= 1.35;
    if (s.brushStyle == BrushStyle.calligraphy) {
      final angle = math.atan2(b.y - a.y, b.x - a.x);
      strokeW *= (0.55 + 0.45 * math.sin(angle).abs());
    }
    canvas.setLineWidth(strokeW);
    canvas.moveTo(da.dx, da.dy);
    canvas.lineTo(db.dx, db.dy);
    canvas.strokePath();
  }
  canvas.restoreContext();
}

void _quadraticBezierOnPdf(
  PdfGraphics canvas,
  double cpx,
  double cpy,
  double endX,
  double endY,
  double startX,
  double startY,
) {
  final cp1x = startX + 2 / 3 * (cpx - startX);
  final cp1y = startY + 2 / 3 * (cpy - startY);
  final cp2x = endX + 2 / 3 * (cpx - endX);
  final cp2y = endY + 2 / 3 * (cpy - endY);
  canvas.curveTo(cp1x, cp1y, cp2x, cp2y, endX, endY);
}

void _paintPdfHighlighterStroke(
  PdfGraphics canvas,
  Stroke s,
  PdfPoint pdfSize,
  PageSize pageSize, {
  PageOrientation orientation = PageOrientation.portrait,
}) {
  final pts = s.points;
  if (pts.isEmpty) return;

  canvas.setStrokeColor(_strokePdfColor(s));
  canvas.setLineCap(PdfLineCap.square);
  canvas.setLineJoin(PdfLineJoin.round);
  final displayWidth =
      _canonicalLenToPdf(s.width, pdfSize, pageSize, orientation: orientation);
  canvas.setLineWidth(displayWidth);

  if (pts.length == 1) {
    final c = _canonicalToPdf(pts[0].x, pts[0].y, pdfSize, pageSize,
        orientation: orientation);
    canvas.setFillColor(_strokePdfColor(s));
    canvas.drawEllipse(c.dx, c.dy, displayWidth / 2, displayWidth / 2);
    canvas.fillPath();
    return;
  }

  final start = _canonicalToPdf(pts[0].x, pts[0].y, pdfSize, pageSize,
      orientation: orientation);
  canvas.moveTo(start.dx, start.dy);
  var prevX = start.dx;
  var prevY = start.dy;
  for (var i = 1; i < pts.length; i++) {
    final a = _canonicalToPdf(pts[i - 1].x, pts[i - 1].y, pdfSize, pageSize,
        orientation: orientation);
    final b = _canonicalToPdf(pts[i].x, pts[i].y, pdfSize, pageSize,
        orientation: orientation);
    final mx = (a.dx + b.dx) / 2;
    final my = (a.dy + b.dy) / 2;
    _quadraticBezierOnPdf(canvas, a.dx, a.dy, mx, my, prevX, prevY);
    prevX = mx;
    prevY = my;
  }
  final last = _canonicalToPdf(pts.last.x, pts.last.y, pdfSize, pageSize,
      orientation: orientation);
  canvas.lineTo(last.dx, last.dy);
  canvas.strokePath();
}

void _paintPdfTapeStroke(
  PdfGraphics canvas,
  Stroke s,
  PdfPoint pdfSize,
  PageSize pageSize, {
  PageOrientation orientation = PageOrientation.portrait,
}) {
  _paintPdfHighlighterStroke(canvas, s, pdfSize, pageSize,
      orientation: orientation);
}

/// True when the PDF byte stream contains vector stroke path operators.
bool pdfBytesContainVectorInk(Uint8List bytes) {
  final latin = latin1.decode(bytes);
  if (_textHasVectorInkOps(latin)) return true;

  const streamToken = 'stream';
  const endToken = 'endstream';
  var searchFrom = 0;
  while (true) {
    final streamStart = latin.indexOf(streamToken, searchFrom);
    if (streamStart < 0) break;
    var dataStart = streamStart + streamToken.length;
    if (dataStart < latin.length && latin[dataStart] == '\r') dataStart++;
    if (dataStart < latin.length && latin[dataStart] == '\n') dataStart++;

    final streamEnd = latin.indexOf(endToken, dataStart);
    if (streamEnd < 0) break;

    final chunk = bytes.sublist(dataStart, streamEnd);
    try {
      if (_textHasVectorInkOps(latin1.decode(zlib.decode(chunk)))) {
        return true;
      }
    } catch (_) {
      if (_textHasVectorInkOps(latin1.decode(chunk))) return true;
    }
    searchFrom = streamEnd + endToken.length;
  }
  return false;
}

bool _textHasVectorInkOps(String text) {
  final hasStrokeColor = RegExp(r'\d+(?:\.\d+)? \d+(?:\.\d+)? \d+(?:\.\d+)? RG')
      .hasMatch(text);
  final hasPath = RegExp(r'\d+(?:\.\d+)? \d+(?:\.\d+)? m').hasMatch(text) &&
      RegExp(r'\d+(?:\.\d+)? \d+(?:\.\d+)? l').hasMatch(text);
  final hasStroke = RegExp(r'(^|\s)S(\s|$)').hasMatch(text);
  return hasStrokeColor && hasPath && hasStroke;
}

enum ExportFormat { png, pdf }

typedef ExportProgressCallback = void Function(int current, int total);

class PageRenderData {
  final NotePage page;
  final List<Stroke> strokes;
  final List<FilledRegion> fills;
  final List<TextBlock> textBlocks;
  final List<PageImage> images;
  final Map<String, ui.Image> decodedImages;
  final ui.Image? pdfImage;
  final bool ownPdfImage;

  const PageRenderData({
    required this.page,
    this.strokes = const [],
    this.fills = const [],
    this.textBlocks = const [],
    this.images = const [],
    this.decodedImages = const {},
    this.pdfImage,
    this.ownPdfImage = false,
  });

  void dispose() {
    if (ownPdfImage) {
      pdfImage?.dispose();
    }
    for (final img in decodedImages.values) {
      img.dispose();
    }
  }
}

/// Renders notebook pages at canonical dimensions and shares/saves exports.
class PageExportService {
  PageExportService._();

  static final PageExportService instance = PageExportService._();

  final _db = AppDatabase.instance;

  bool _hasPdfBackground(NotePage page) =>
      page.pdfImagePath != null || page.pdfSourcePath != null;

  PageSize effectivePageSize(NotePage page) {
    if (_hasPdfBackground(page)) {
      return PageSize.values.firstWhere(
        (ps) => (ps.aspect - page.aspect).abs() < 0.01,
        orElse: () => page.pageSize,
      );
    }
    return page.pageSize;
  }

  Future<PageRenderData> loadPageData(NotePage page) async {
    final strokes = await _db.strokesOf(page.id);
    final fills = await _db.fillsOf(page.id);
    final texts = await _db.textBlocksOf(page.id);
    final images = await _db.imagesOf(page.id);

    ui.Image? pdfImage;
    var ownPdfImage = false;
    final legacyPath = page.pdfImagePath;
    final lazySource = page.pdfSourcePath;
    final lazyIndex = page.pdfPageIndex;

    if (legacyPath != null) {
      try {
        final bytes = await File(legacyPath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        pdfImage = frame.image;
        ownPdfImage = true;
      } catch (_) {
        pdfImage = null;
      }
    } else if (lazySource != null && lazyIndex != null) {
      try {
        pdfImage = await PdfPageCache.instance.getPage(lazySource, lazyIndex);
      } catch (_) {
        pdfImage = null;
      }
    }

    final decodedImages = <String, ui.Image>{};
    for (final img in images) {
      final decoded = await _decodeImage(img.path);
      if (decoded != null) {
        decodedImages[img.path] = decoded;
      }
    }

    return PageRenderData(
      page: page,
      strokes: strokes,
      fills: fills,
      textBlocks: texts,
      images: images,
      decodedImages: decodedImages,
      pdfImage: pdfImage,
      ownPdfImage: ownPdfImage,
    );
  }

  Future<ui.Image?> _decodeImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  PageOrientation effectiveOrientation(NotePage page) {
    if (_hasPdfBackground(page)) return PageOrientation.portrait;
    return page.orientation;
  }

  Future<ui.Image> renderPage(PageRenderData data) async {
    final pageSize = effectivePageSize(data.page);
    final orientation = effectiveOrientation(data.page);
    final displaySize =
        PageCoords.canonicalSize(pageSize, orientation: orientation);
    final width = (displaySize.width * exportPixelRatio).round();
    final height = (displaySize.height * exportPixelRatio).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
    canvas.scale(exportPixelRatio);

    PagePainter(
      template: data.page.template,
      pageSize: pageSize,
      orientation: orientation,
      pdfImage: data.pdfImage,
    ).paint(canvas, displaySize);

    InkPainter(
      strokes: data.strokes,
      fills: data.fills,
      textBlocks: data.textBlocks,
      images: data.images,
      decodedImages: data.decodedImages,
      pageSize: pageSize,
      orientation: orientation,
      displaySize: displaySize,
      revision: 0,
    ).paint(canvas, displaySize);

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  /// Renders background, fills, images, and text — ink strokes are vector in PDF.
  Future<ui.Image> renderPageRasterLayer(PageRenderData data) async {
    final pageSize = effectivePageSize(data.page);
    final orientation = effectiveOrientation(data.page);
    final displaySize =
        PageCoords.canonicalSize(pageSize, orientation: orientation);
    final width = (displaySize.width * exportPixelRatio).round();
    final height = (displaySize.height * exportPixelRatio).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
    canvas.scale(exportPixelRatio);

    PagePainter(
      template: data.page.template,
      pageSize: pageSize,
      orientation: orientation,
      pdfImage: data.pdfImage,
    ).paint(canvas, displaySize);

    InkPainter(
      strokes: const [],
      fills: data.fills,
      textBlocks: data.textBlocks,
      images: data.images,
      decodedImages: data.decodedImages,
      pageSize: pageSize,
      orientation: orientation,
      displaySize: displaySize,
      revision: 0,
    ).paint(canvas, displaySize);

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  PdfPageFormat pdfFormatFor(
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final dims = PageCoords.canonicalSize(pageSize, orientation: orientation);
    return PdfPageFormat(
      dims.width / 10.0,
      dims.height / 10.0,
      marginAll: 0,
    );
  }

  Future<void> _addImagePageToDoc(
    pw.Document doc,
    ui.Image image,
    PageSize pageSize,
  ) async {
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) {
      throw StateError('Failed to encode page image as PNG');
    }
    doc.addPage(
      pw.Page(
        pageFormat: pdfFormatFor(pageSize),
        build: (_) => pw.Image(
          pw.MemoryImage(png.buffer.asUint8List()),
          fit: pw.BoxFit.fill,
        ),
      ),
    );
  }

  /// Adds a page with raster background/fills/images/text and vector ink strokes.
  Future<void> _addVectorPageToDoc(
    pw.Document doc,
    PageRenderData data,
    PageSize pageSize,
    PageOrientation orientation,
  ) async {
    final format = pdfFormatFor(pageSize, orientation: orientation);
    ui.Image? rasterImage;
    try {
      rasterImage = await renderPageRasterLayer(data);
      final png = await rasterImage.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) {
        throw StateError('Failed to encode raster layer as PNG');
      }
      final rasterBytes = png.buffer.asUint8List();
      doc.addPage(
        pw.Page(
          pageFormat: format,
          build: (_) => pw.CustomPaint(
            foregroundPainter: (canvas, size) {
              paintVectorInkOnPdf(
                canvas,
                size,
                pageSize,
                data.strokes,
                orientation: orientation,
              );
            },
            child: pw.Image(
              pw.MemoryImage(rasterBytes),
              fit: pw.BoxFit.fill,
            ),
          ),
        ),
      );
    } finally {
      rasterImage?.dispose();
    }
  }

  Future<Uint8List> buildPdfBytes(
    List<({ui.Image image, PageSize pageSize})> pages,
  ) async {
    final doc = pw.Document();
    for (final entry in pages) {
      await _addImagePageToDoc(doc, entry.image, entry.pageSize);
    }
    return doc.save();
  }

  /// Builds a multi-page PDF one page at a time to avoid holding all bitmaps in memory.
  Future<Uint8List> buildNotebookPdfBytes({
    required List<NotePage> pages,
    ExportProgressCallback? onProgress,
  }) async {
    final doc = pw.Document();
    final total = pages.length;
    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      PageRenderData? data;
      try {
        data = await loadPageData(page);
        await _addVectorPageToDoc(
          doc,
          data,
          effectivePageSize(page),
          effectiveOrientation(page),
        );
      } finally {
        data?.dispose();
        await _yieldToEventLoop();
      }
      onProgress?.call(i + 1, total);
    }
    return doc.save();
  }

  Future<void> _yieldToEventLoop() async {
    await Future<void>.delayed(Duration.zero);
  }

  String sanitizeFilename(String name) {
    final cleaned = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
    return cleaned.isEmpty ? 'notebook' : cleaned;
  }

  Future<void> exportPage({
    required NotePage page,
    required String notebookTitle,
    required int pageIndex,
    required ExportFormat format,
    ExportProgressCallback? onProgress,
  }) async {
    onProgress?.call(0, 1);
    PageRenderData? data;
    ui.Image? image;
    try {
      data = await loadPageData(page);
      onProgress?.call(1, 1);

      final base = sanitizeFilename(notebookTitle);
      final pageLabel = 'page${pageIndex + 1}';
      if (format == ExportFormat.png) {
        image = await renderPage(data);
        final bytes = await _imageToPng(image);
        await _shareBytes(
          bytes: bytes,
          filename: '${base}_$pageLabel.png',
          mimeType: 'image/png',
        );
      } else {
        final pageSize = effectivePageSize(page);
        final doc = pw.Document();
        await _addVectorPageToDoc(
          doc,
          data,
          pageSize,
          effectiveOrientation(page),
        );
        final bytes = await doc.save();
        await _shareBytes(
          bytes: bytes,
          filename: '${base}_$pageLabel.pdf',
          mimeType: 'application/pdf',
        );
      }
    } finally {
      image?.dispose();
      data?.dispose();
    }
  }

  Future<void> exportNotebook({
    required List<NotePage> pages,
    required String notebookTitle,
    ExportProgressCallback? onProgress,
  }) async {
    if (pages.isEmpty) {
      throw StateError('Notebook has no pages to export');
    }
    final bytes = await buildNotebookPdfBytes(
      pages: pages,
      onProgress: onProgress,
    );
    final base = sanitizeFilename(notebookTitle);
    await _shareBytes(
      bytes: bytes,
      filename: '${base}.pdf',
      mimeType: 'application/pdf',
    );
  }

  Future<Uint8List> _imageToPng(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode page image as PNG');
    }
    return byteData.buffer.asUint8List();
  }

  Future<void> _shareBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, filename));
      await file.writeAsBytes(bytes, flush: true);
      final result = await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType, name: filename)],
        subject: filename,
      );
      if (result.status == ShareResultStatus.unavailable) {
        throw StateError('Share is not available on this device');
      }
    } on StateError {
      rethrow;
    } catch (e) {
      throw StateError('Failed to share export: $e');
    }
  }
}

/// Shows a blocking progress dialog while [run] exports one or more pages.
Future<T?> withExportProgressDialog<T>({
  required BuildContext context,
  required int totalPages,
  required Future<T> Function(ExportProgressCallback onProgress) run,
}) async {
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
            final l10n = AppLocalizations.of(dialogContext);
            final label = value.$2 <= 1
                ? l10n.exportPreparing
                : l10n.exportProgress(value.$1, value.$2);
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
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
