import '../db/app_database.dart';
import '../models/models.dart';

/// Stroke-count guardrails and page split helper (v0.2.38).
class PageComplexityService {
  PageComplexityService._();

  static final PageComplexityService instance = PageComplexityService._();

  /// Warn when a page reaches this many strokes (OneNote-style page bloat guard).
  static const strokeWarningThreshold = 2000;

  static bool shouldWarn(int strokeCount) =>
      strokeCount >= strokeWarningThreshold;

  static String warningMessage(int strokeCount) =>
      'This page has $strokeCount strokes. Consider splitting it for better performance.';

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
