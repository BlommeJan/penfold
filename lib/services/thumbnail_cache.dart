import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../canvas/painters.dart';
import '../db/app_database.dart';
import '../models/models.dart';
import 'pdf_page_cache.dart';

/// On-disk PNG thumbnails for library notebook covers (`thumbnails/{id}.png`).
class ThumbnailCache {
  ThumbnailCache._();
  static final ThumbnailCache instance = ThumbnailCache._();

  static const dirName = 'thumbnails';
  static const thumbWidth = 360;
  static const thumbHeight = 480;

  /// When false, [ensureForNotebook] is a no-op (widget tests).
  static bool autoGenerate = true;

  final _db = AppDatabase.instance;
  final _inFlight = <String, Future<File?>>{};

  Future<Directory> _docsDir() async {
    final override = AppDatabase.overrideDirPath;
    if (override != null) return Directory(override);
    return getApplicationDocumentsDirectory();
  }

  static String fileNameFor(String notebookId) => '$notebookId.png';

  /// Relative path under the documents directory.
  static String relativePath(String notebookId) =>
      p.join(dirName, fileNameFor(notebookId));

  Future<Directory> thumbnailsDirectory() async {
    final docs = await _docsDir();
    final dir = Directory(p.join(docs.path, dirName));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<String> pathFor(String notebookId) async {
    final dir = await thumbnailsDirectory();
    return p.join(dir.path, fileNameFor(notebookId));
  }

  Future<bool> exists(String notebookId) async {
    return File(await pathFor(notebookId)).existsSync();
  }

  Future<File?> ensureForNotebook(String notebookId) async {
    if (!autoGenerate) return null;

    final existing = await pathFor(notebookId);
    final file = File(existing);
    if (file.existsSync()) return file;

    final pending = _inFlight[notebookId];
    if (pending != null) return pending;

    final task = _generate(notebookId);
    _inFlight[notebookId] = task;
    try {
      return await task;
    } finally {
      _inFlight.remove(notebookId);
    }
  }

  Future<void> ensureMissingForNotebooks(Iterable<String> notebookIds) async {
    for (final id in notebookIds) {
      await ensureForNotebook(id);
    }
  }

  Future<void> deleteForNotebook(String notebookId) async {
    final path = await pathFor(notebookId);
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  Future<File?> _generate(String notebookId) async {
    final pages = await _db.pagesOf(notebookId);
    if (pages.isEmpty) return null;

    final page = pages.first;
    final strokes = await _db.strokesOf(page.id);
    final fills = await _db.fillsOf(page.id);
    final texts = await _db.textBlocksOf(page.id);
    final pdfImage = await _loadPdfImage(page);

    final hasPdf =
        page.pdfImagePath != null || page.pdfSourcePath != null;
    final pageSize = hasPdf
        ? PageSize.values.firstWhere(
            (s) => (s.aspect - page.aspect).abs() < 0.01,
            orElse: () => page.pageSize,
          )
        : page.pageSize;
    final orientation =
        hasPdf ? PageOrientation.portrait : page.orientation;

    ui.Image? image;
    try {
      image = await _renderThumbnail(
        template: page.template,
        pageSize: pageSize,
        orientation: orientation,
        backgroundTheme: page.backgroundTheme,
        strokes: strokes,
        fills: fills,
        textBlocks: texts,
        pdfImage: pdfImage,
      );
      final bytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return null;

      final outPath = await pathFor(notebookId);
      final out = File(outPath);
      await out.parent.create(recursive: true);
      await out.writeAsBytes(bytes.buffer.asUint8List());
      return out;
    } finally {
      image?.dispose();
      pdfImage?.dispose();
    }
  }

  Future<ui.Image?> _loadPdfImage(NotePage page) async {
    final pdfPath = page.pdfImagePath;
    if (pdfPath != null) {
      try {
        final bytes = await File(pdfPath).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      } catch (_) {
        return null;
      }
    }
    if (page.pdfSourcePath != null && page.pdfPageIndex != null) {
      return PdfPageCache.instance.getPage(
        page.pdfSourcePath!,
        page.pdfPageIndex!,
      );
    }
    return null;
  }

  Future<ui.Image> _renderThumbnail({
    required PageTemplate template,
    required PageSize pageSize,
    required PageOrientation orientation,
    PageBackgroundTheme backgroundTheme = PageBackgroundTheme.light,
    required List<Stroke> strokes,
    required List<FilledRegion> fills,
    required List<TextBlock> textBlocks,
    ui.Image? pdfImage,
  }) async {
    const w = thumbWidth;
    const h = thumbHeight;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    );
    PageThumbnailPainter(
      template: template,
      pageSize: pageSize,
      orientation: orientation,
      backgroundTheme: backgroundTheme,
      strokes: strokes,
      fills: fills,
      textBlocks: textBlocks,
      pdfImage: pdfImage,
    ).paint(canvas, Size(w.toDouble(), h.toDouble()));
    final picture = recorder.endRecording();
    return picture.toImage(w, h);
  }
}
