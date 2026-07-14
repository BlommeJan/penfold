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

/// Export resolution multiplier over canonical page coordinates.
const exportPixelRatio = 2.0;

enum ExportFormat { png, pdf }

class PageRenderData {
  final NotePage page;
  final List<Stroke> strokes;
  final List<FilledRegion> fills;
  final List<TextBlock> textBlocks;
  final List<PageImage> images;
  final Map<String, ui.Image> decodedImages;
  final ui.Image? pdfImage;

  const PageRenderData({
    required this.page,
    this.strokes = const [],
    this.fills = const [],
    this.textBlocks = const [],
    this.images = const [],
    this.decodedImages = const {},
    this.pdfImage,
  });

  void dispose() {
    pdfImage?.dispose();
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

  PageSize effectivePageSize(NotePage page) {
    if (page.pdfImagePath != null) {
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

  Future<Uint8List> buildPdfBytes(
    List<({ui.Image image, PageSize pageSize})> pages,
  ) async {
    final doc = pw.Document();
    for (final entry in pages) {
      final png = await entry.image.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) continue;
      doc.addPage(
        pw.Page(
          pageFormat: pdfFormatFor(entry.pageSize),
          build: (_) => pw.Image(
            pw.MemoryImage(png.buffer.asUint8List()),
            fit: pw.BoxFit.fill,
          ),
        ),
      );
    }
    return doc.save();
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
  }) async {
    final data = await loadPageData(page);
    try {
      final image = await renderPage(data);
      try {
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
        image.dispose();
      }
    } finally {
      data.dispose();
    }
  }

  Future<void> exportNotebook({
    required List<NotePage> pages,
    required String notebookTitle,
  }) async {
    final rendered = <({ui.Image image, PageSize pageSize})>[];
    try {
      for (final page in pages) {
        final data = await loadPageData(page);
        try {
          final image = await renderPage(data);
          rendered.add((image: image, pageSize: effectivePageSize(page)));
        } finally {
          data.dispose();
        }
      }
      final bytes = await buildPdfBytes(rendered);
      final base = sanitizeFilename(notebookTitle);
      await _shareBytes(
        bytes: bytes,
        filename: '${base}.pdf',
        mimeType: 'application/pdf',
      );
    } finally {
      for (final entry in rendered) {
        entry.image.dispose();
      }
    }
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
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, filename));
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType, name: filename)],
      subject: filename,
    );
  }
}
