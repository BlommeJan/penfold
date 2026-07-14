import 'dart:collection';
import 'dart:ui' as ui;

import 'package:pdfx/pdfx.dart';

/// LRU cache of decoded PDF page bitmaps (max [maxEntries]).
class PdfPageCache {
  PdfPageCache._();
  static final PdfPageCache instance = PdfPageCache._();

  static const maxEntries = 4;
  final _cache = LinkedHashMap<String, ui.Image>();

  String _key(String sourcePath, int pageIndex) => '$sourcePath#$pageIndex';

  Future<ui.Image?> getPage(String sourcePath, int pageIndex) async {
    final key = _key(sourcePath, pageIndex);
    final existing = _cache.remove(key);
    if (existing != null) {
      _cache[key] = existing;
      return existing;
    }

    final image = await _renderPage(sourcePath, pageIndex);
    if (image != null) {
      _evictIfNeeded();
      _cache[key] = image;
    }
    return image;
  }

  void prefetch(String sourcePath, int pageIndex) {
    if (_cache.containsKey(_key(sourcePath, pageIndex))) return;
    getPage(sourcePath, pageIndex);
  }

  void _evictIfNeeded() {
    while (_cache.length >= maxEntries) {
      final oldest = _cache.keys.first;
      _cache.remove(oldest)?.dispose();
    }
  }

  Future<ui.Image?> _renderPage(String sourcePath, int pageIndex) async {
    PdfDocument? doc;
    PdfPage? page;
    try {
      doc = await PdfDocument.openFile(sourcePath);
      page = await doc.getPage(pageIndex);
      final rendered = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      if (rendered == null) return null;
      final codec = await ui.instantiateImageCodec(rendered.bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    } finally {
      await page?.close();
      await doc?.close();
    }
  }

  void clear() {
    for (final img in _cache.values) {
      img.dispose();
    }
    _cache.clear();
  }
}
