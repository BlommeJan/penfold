import '../db/app_database.dart';
import '../models/models.dart';

/// Detects heading-like text and builds a notebook table of contents (v0.2.36).
class TocService {
  TocService._();

  static final TocService instance = TocService._();

  static const maxHeadingLength = 80;
  static const shortLineMaxLength = 50;
  static const largeFontMultiplier = 1.35;
  static const minCapsLetters = 3;
  static const minCapsRatio = 0.85;

  /// Default body text size in canonical units (matches `drawing_canvas`).
  static double baselineFontSizeForPage(
    PageSize pageSize,
    PageOrientation orientation,
  ) {
    final w = orientation == PageOrientation.portrait
        ? pageSize.width.toDouble()
        : pageSize.height.toDouble();
    return w * 0.024;
  }

  /// Heuristic: short line, large font, or mostly ALL CAPS.
  static bool isHeadingLike(
    String text, {
    double? fontSize,
    double? baselineFontSize,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > maxHeadingLength) return false;

    final line = trimmed.split(RegExp(r'\r?\n')).first.trim();
    if (line.isEmpty) return false;

    if (_isAllCaps(line)) return true;

    if (fontSize != null &&
        baselineFontSize != null &&
        baselineFontSize > 0 &&
        fontSize >= baselineFontSize * largeFontMultiplier) {
      return true;
    }

    if (line.length <= shortLineMaxLength && !_looksLikeBodySentence(line)) {
      return true;
    }

    return false;
  }

  static bool _isAllCaps(String line) {
    final letters = line.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.length < minCapsLetters) return false;
    final upper = letters.replaceAll(RegExp(r'[^A-Z]'), '').length;
    return upper / letters.length >= minCapsRatio;
  }

  static bool _looksLikeBodySentence(String line) {
    if (line.length > 40 && line.endsWith('.')) return true;
    if (line.length > 60) return true;
    return false;
  }

  static String displayTitle(String text) {
    final line = text.trim().split(RegExp(r'\r?\n')).first.trim();
    return line.isEmpty ? text.trim() : line;
  }

  Future<List<TocEntry>> buildNotebookToc(String notebookId) async {
    final db = AppDatabase.instance;
    final pages = await db.pagesOf(notebookId);
    final entries = <TocEntry>[];

    for (var i = 0; i < pages.length; i++) {
      final page = pages[i];
      final baseline = baselineFontSizeForPage(page.pageSize, page.orientation);

      final textBlocks = await db.textBlocksOf(page.id);
      for (final block in textBlocks) {
        if (block.isNote) continue;
        if (!isHeadingLike(
          block.text,
          fontSize: block.fontSize,
          baselineFontSize: baseline,
        )) {
          continue;
        }
        entries.add(TocEntry(
          title: displayTitle(block.text),
          pageId: page.id,
          pageIndex: i,
          sortY: block.y,
          source: TocSource.textBlock,
        ));
      }

      final strokes = await db.strokesOf(page.id);
      final strokeTop = {
        for (final s in strokes) s.id: s.bounds.top,
      };

      final inkRows = await db.indexedInkTextOfPage(page.id);
      for (final row in inkRows) {
        if (!isHeadingLike(row.text)) continue;
        final y = row.strokeId != null
            ? strokeTop[row.strokeId] ?? 0.0
            : 0.0;
        entries.add(TocEntry(
          title: displayTitle(row.text),
          pageId: page.id,
          pageIndex: i,
          sortY: y,
          source: TocSource.inkOcr,
        ));
      }
    }

    entries.sort((a, b) {
      final byPage = a.pageIndex.compareTo(b.pageIndex);
      if (byPage != 0) return byPage;
      final byY = a.sortY.compareTo(b.sortY);
      if (byY != 0) return byY;
      return a.title.compareTo(b.title);
    });

    return _dedupeEntries(entries);
  }

  static List<TocEntry> _dedupeEntries(List<TocEntry> entries) {
    final seen = <String>{};
    final out = <TocEntry>[];
    for (final e in entries) {
      final key =
          '${e.pageId}:${e.title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ')}';
      if (seen.add(key)) out.add(e);
    }
    return out;
  }
}
