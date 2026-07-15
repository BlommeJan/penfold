import 'dart:io';
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
import '../models/models.dart';
import 'pdf_page_cache.dart';

/// Export resolution multiplier over canonical page coordinates.
const exportPixelRatio = 2.0;

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

  Future<ui.Image> renderPage(PageRenderData data) async {
    final pageSize = effectivePageSize(data.page);
    final displaySize = PageCoords.canonicalSize(pageSize);
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
      pdfImage: data.pdfImage,
    ).paint(canvas, displaySize);

    InkPainter(
      strokes: data.strokes,
      fills: data.fills,
      textBlocks: data.textBlocks,
      images: data.images,
      decodedImages: data.decodedImages,
      pageSize: pageSize,
      displaySize: displaySize,
      revision: 0,
    ).paint(canvas, displaySize);

    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  PdfPageFormat pdfFormatFor(PageSize pageSize) => PdfPageFormat(
        pageSize.width / 10.0,
        pageSize.height / 10.0,
        marginAll: 0,
      );

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
      ui.Image? image;
      try {
        data = await loadPageData(page);
        image = await renderPage(data);
        await _addImagePageToDoc(doc, image, effectivePageSize(page));
      } finally {
        image?.dispose();
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
      image = await renderPage(data);
      onProgress?.call(1, 1);

      final base = sanitizeFilename(notebookTitle);
      final pageLabel = 'page${pageIndex + 1}';
      if (format == ExportFormat.png) {
        final bytes = await _imageToPng(image);
        await _shareBytes(
          bytes: bytes,
          filename: '${base}_$pageLabel.png',
          mimeType: 'image/png',
        );
      } else {
        final pageSize = effectivePageSize(page);
        final bytes = await buildPdfBytes([(image: image, pageSize: pageSize)]);
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
