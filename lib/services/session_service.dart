import '../db/app_database.dart';
import '../models/models.dart';

/// Persists last-open notebook, page, scroll, and tool in SQLite.
class SessionService {
  SessionService._();
  static final SessionService instance = SessionService._();

  final _db = AppDatabase.instance;

  Future<PenfoldSession?> load() => _db.loadSession();

  Future<void> save({
    required String notebookId,
    required int pageIndex,
    required double scrollOffset,
    required ToolType tool,
  }) =>
      _db.saveSession(
        notebookId: notebookId,
        pageIndex: pageIndex,
        scrollOffset: scrollOffset,
        tool: tool,
      );

  Future<void> clear() => _db.clearSession();
}
