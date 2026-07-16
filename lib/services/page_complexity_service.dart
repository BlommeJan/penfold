import '../db/app_database.dart';
import '../models/models.dart';

/// Stroke-count guardrails and page split helper (v0.2.38).
class PageComplexityService {
  PageComplexityService._();

  static final PageComplexityService instance = PageComplexityService._();

  /// Warn when a page starts getting heavy (OneNote-style bloat guard).
  static const strokeWarningThreshold = 500;

  /// Block PDF/PNG export above this count to avoid OOM from eraser bloat.
  static const strokeExportBlockThreshold = 2000;

  static bool shouldWarn(int strokeCount) =>
      strokeCount >= strokeWarningThreshold;

  static bool shouldBlockExport(int strokeCount) =>
      strokeCount >= strokeExportBlockThreshold;

  static String warningMessage(int strokeCount) =>
      'This page has $strokeCount strokes and may feel slow. '
      'Consider splitting it for better performance.';

  static String exportBlockedMessage(int strokeCount) =>
      'Export blocked: a page has $strokeCount strokes (limit '
      '$strokeExportBlockThreshold). Split heavy pages first.';

  /// Returns a user-facing block reason when any page exceeds the export limit.
  Future<String?> exportBlockReasonForPages(Iterable<String> pageIds) async {
    for (final id in pageIds) {
      final count = await strokeCount(id);
      if (shouldBlockExport(count)) {
        return exportBlockedMessage(count);
      }
    }
    return null;
  }

  Future<int> strokeCount(String pageId) =>
      AppDatabase.instance.countStrokes(pageId);

  /// Duplicate the source page template and move the upper half of strokes (by z)
  /// onto a new page inserted immediately after the source page.
  Future<SplitPageResult> splitPage({
    required String notebookId,
    required String sourcePageId,
    required String newPageId,
  }) async {
    return AppDatabase.instance.splitPage(
      notebookId: notebookId,
      sourcePageId: sourcePageId,
      newPageId: newPageId,
    );
  }
}
