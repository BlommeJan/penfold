import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

enum _SearchBackend { none, fts4, fts5 }

/// Single local SQLite database. No accounts. No network. Your data stays
/// on this device, in one inspectable .db file.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  _SearchBackend _searchBackend = _SearchBackend.none;
  static const _schemaVersion = 5;

  /// Test hook: when set, the database lives here instead of the app
  /// documents directory (used by unit tests with sqflite_common_ffi).
  static String? overrideDirPath;

  /// Test hook: close and forget the cached handle so the next access
  /// opens a fresh database (e.g. in a new temp directory).
  Future<void> resetForTests() async {
    await _db?.close();
    _db = null;
    _searchBackend = _SearchBackend.none;
  }

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dirPath =
        overrideDirPath ?? (await getApplicationDocumentsDirectory()).path;
    _db = await openDatabase(
      p.join(dirPath, 'penfold.db'),
      version: _schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
    await _detectSearchBackend(_db!);
    return _db!;
  }

  Future<void> _onCreate(Database db, int v) async {
    await db.execute('''
      CREATE TABLE folders(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        parent_id TEXT REFERENCES folders(id)
      )''');
    await db.execute('''
      CREATE TABLE notebooks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        color INTEGER NOT NULL,
        template INTEGER NOT NULL,
        page_size INTEGER NOT NULL DEFAULT 0,
        folder_id TEXT REFERENCES folders(id),
        created INTEGER NOT NULL,
        updated INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE pages(
        id TEXT PRIMARY KEY,
        notebook_id TEXT NOT NULL REFERENCES notebooks(id) ON DELETE CASCADE,
        idx INTEGER NOT NULL,
        template INTEGER NOT NULL,
        page_size INTEGER NOT NULL DEFAULT 0,
        pdf_image TEXT,
        pdf_source_path TEXT,
        pdf_page_index INTEGER,
        aspect REAL NOT NULL DEFAULT 0.7070707
      )''');
    await db.execute('''
      CREATE TABLE strokes(
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
        tool INTEGER NOT NULL,
        brush_style INTEGER NOT NULL DEFAULT 0,
        color INTEGER NOT NULL,
        width REAL NOT NULL,
        points TEXT NOT NULL,
        z INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE page_images(
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
        path TEXT NOT NULL,
        x REAL NOT NULL,
        y REAL NOT NULL,
        w REAL NOT NULL,
        h REAL NOT NULL,
        z INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE fills(
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
        color INTEGER NOT NULL,
        path_json TEXT NOT NULL,
        z INTEGER NOT NULL
      )''');
    await db.execute('''
      CREATE TABLE text_blocks(
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
        x REAL NOT NULL,
        y REAL NOT NULL,
        w REAL NOT NULL,
        h REAL NOT NULL,
        text TEXT NOT NULL,
        font_size REAL NOT NULL,
        color INTEGER NOT NULL,
        z INTEGER NOT NULL,
        is_note INTEGER NOT NULL DEFAULT 0
      )''');
    await db.execute('CREATE INDEX idx_pages_nb ON pages(notebook_id, idx)');
    await db.execute('CREATE INDEX idx_strokes_pg ON strokes(page_id, z)');
    await db.execute('CREATE INDEX idx_images_pg ON page_images(page_id, z)');
    await db.execute('CREATE INDEX idx_fills_pg ON fills(page_id, z)');
    await db.execute('CREATE INDEX idx_text_pg ON text_blocks(page_id, z)');
    await db.execute(
        'CREATE INDEX idx_folders_parent ON folders(parent_id, sort_order)');
    await _createInkIndex(db);
    await _createFts(db);
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await _addColumnIfMissing(
          db, 'notebooks', 'page_size', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfMissing(db, 'notebooks', 'folder_id', 'TEXT');
      await _addColumnIfMissing(
          db, 'pages', 'page_size', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'strokes', 'brush_style', 'INTEGER NOT NULL DEFAULT 0');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS folders(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          sort_order INTEGER NOT NULL
        )''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS fills(
          id TEXT PRIMARY KEY,
          page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
          color INTEGER NOT NULL,
          path_json TEXT NOT NULL,
          z INTEGER NOT NULL
        )''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS text_blocks(
          id TEXT PRIMARY KEY,
          page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
          x REAL NOT NULL,
          y REAL NOT NULL,
          w REAL NOT NULL,
          h REAL NOT NULL,
          text TEXT NOT NULL,
          font_size REAL NOT NULL,
          color INTEGER NOT NULL,
          z INTEGER NOT NULL,
          is_note INTEGER NOT NULL DEFAULT 0
        )''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_fills_pg ON fills(page_id, z)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_text_pg ON text_blocks(page_id, z)');
      await _createFts(db);
      await _rebuildFts(db);
    }
    if (oldV < 3) {
      await _addColumnIfMissing(db, 'folders', 'parent_id', 'TEXT');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_folders_parent ON folders(parent_id, sort_order)');
    }
    if (oldV < 4) {
      await _createInkIndex(db);
      await _rebuildFts(db);
    }
    if (oldV < 5) {
      await _addColumnIfMissing(db, 'pages', 'pdf_source_path', 'TEXT');
      await _addColumnIfMissing(db, 'pages', 'pdf_page_index', 'INTEGER');
    }
  }

  Future<void> _createInkIndex(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ink_index(
        id TEXT PRIMARY KEY,
        page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
        stroke_id TEXT REFERENCES strokes(id) ON DELETE CASCADE,
        text TEXT NOT NULL DEFAULT '',
        status INTEGER NOT NULL DEFAULT 0,
        indexed_at INTEGER
      )''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ink_page ON ink_index(page_id, status)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ink_stroke ON ink_index(stroke_id)');
  }

  Future<bool> _hasTable(Database db, String name) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [name],
    );
    return rows.isNotEmpty;
  }

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    if (!info.any((row) => row['name'] == column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<void> _createFts(Database db) async {
    if (await _tryCreateFts5(db)) {
      _searchBackend = _SearchBackend.fts5;
      return;
    }
    if (await _tryCreateFts4(db)) {
      _searchBackend = _SearchBackend.fts4;
      return;
    }
    _searchBackend = _SearchBackend.none;
  }

  Future<bool> _tryCreateFts5(Database db) async {
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts5(
          notebook_id UNINDEXED,
          title,
          body,
          tokenize='porter'
        )''');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _tryCreateFts4(Database db) async {
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE IF NOT EXISTS search_index USING fts4(
          notebook_id,
          title,
          body,
          notindexed=notebook_id
        )''');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _detectSearchBackend(Database db) async {
    final rows = await db.rawQuery(
      "SELECT sql FROM sqlite_master WHERE type='table' AND name='search_index'",
    );
    if (rows.isEmpty) {
      _searchBackend = _SearchBackend.none;
      return;
    }
    final sql = (rows.first['sql'] as String?)?.toLowerCase() ?? '';
    if (sql.contains('fts5')) {
      _searchBackend = _SearchBackend.fts5;
    } else if (sql.contains('fts4')) {
      _searchBackend = _SearchBackend.fts4;
    } else {
      _searchBackend = _SearchBackend.none;
    }
  }

  Future<void> _rebuildFts(Database db) async {
    if (_searchBackend == _SearchBackend.none) return;
    await db.delete('search_index');
    final notebooks = await db.query('notebooks');
    for (final nb in notebooks) {
      await _indexNotebook(db, nb['id'] as String, nb['title'] as String);
    }
  }

  Future<void> _indexNotebook(Database db, String id, String title) async {
    if (_searchBackend == _SearchBackend.none) return;
    final pages =
        await db.query('pages', where: 'notebook_id = ?', whereArgs: [id]);
    final pageIds = pages.map((p) => p['id'] as String).toList();
    var body = '';
    if (pageIds.isNotEmpty) {
      final placeholders = List.filled(pageIds.length, '?').join(',');
      final texts = await db.query('text_blocks',
          where: 'page_id IN ($placeholders)', whereArgs: pageIds);
      body = texts.map((t) => t['text'] as String).join(' ');
      if (await _hasTable(db, 'ink_index')) {
        final ink = await db.query('ink_index',
            where: 'page_id IN ($placeholders) AND status = ?',
            whereArgs: [...pageIds, InkIndexStatus.indexed.dbValue]);
        if (ink.isNotEmpty) {
          final inkText = ink.map((r) => r['text'] as String).join(' ');
          body = body.isEmpty ? inkText : '$body $inkText';
        }
      }
    }
    await db.insert('search_index', {
      'notebook_id': id,
      'title': title,
      'body': body,
    });
  }

  Future<void> refreshSearchIndex(String notebookId) async {
    final database = await db;
    final nb = await database
        .query('notebooks', where: 'id = ?', whereArgs: [notebookId]);
    if (nb.isEmpty || _searchBackend == _SearchBackend.none) return;
    await database.delete('search_index',
        where: 'notebook_id = ?', whereArgs: [notebookId]);
    await _indexNotebook(
        database, notebookId, nb.first['title'] as String);
  }

  // ---- Folders ----

  Future<List<Folder>> folders({String? parentId}) async {
    final database = await db;
    final rows = parentId == null
        ? await database.query('folders',
            where: 'parent_id IS NULL',
            orderBy: 'sort_order ASC, name ASC')
        : await database.query('folders',
            where: 'parent_id = ?',
            whereArgs: [parentId],
            orderBy: 'sort_order ASC, name ASC');
    return rows.map(Folder.fromRow).toList();
  }

  Future<List<Folder>> allFolders() async {
    final rows = await (await db)
        .query('folders', orderBy: 'sort_order ASC, name ASC');
    return rows.map(Folder.fromRow).toList();
  }

  Future<void> insertFolder(Folder f) async {
    await (await db).insert('folders', f.toRow());
  }

  Future<void> renameFolder(String id, String name) async {
    await (await db)
        .update('folders', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFolder(String id) async {
    final database = await db;
    final children = await database.query('folders',
        where: 'parent_id = ?', whereArgs: [id]);
    final folder = await database
        .query('folders', where: 'id = ?', whereArgs: [id], limit: 1);
    final parentId =
        folder.isEmpty ? null : folder.first['parent_id'] as String?;

    for (final child in children) {
      await database.update('folders', {'parent_id': parentId},
          where: 'id = ?', whereArgs: [child['id']]);
    }
    await database.update('notebooks', {'folder_id': parentId},
        where: 'folder_id = ?', whereArgs: [id]);
    await database.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveNotebookToFolder(String notebookId, String? folderId) async {
    await (await db).update('notebooks', {'folder_id': folderId},
        where: 'id = ?', whereArgs: [notebookId]);
  }

  // ---- Notebooks ----

  Future<List<Notebook>> notebooks({String? folderId}) async {
    final database = await db;
    final rows = folderId == null
        ? await database.query('notebooks', orderBy: 'updated DESC')
        : folderId == ''
            ? await database.query('notebooks',
                where: 'folder_id IS NULL', orderBy: 'updated DESC')
            : await database.query('notebooks',
                where: 'folder_id = ?',
                whereArgs: [folderId],
                orderBy: 'updated DESC');
    return rows.map(Notebook.fromRow).toList();
  }

  Future<List<SearchResult>> searchNotebooks(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    final database = await db;
    if (_searchBackend == _SearchBackend.none) {
      return _searchNotebooksLike(database, trimmed);
    }
    try {
      return await _searchNotebooksFts(database, trimmed);
    } catch (_) {
      return _searchNotebooksLike(database, trimmed);
    }
  }

  /// FTS MATCH query: quote each token so punctuation does not break parsing.
  String _ftsMatchQuery(String raw) {
    final terms = raw
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty);
    if (terms.isEmpty) return '';
    return terms.map((t) => '"${t.replaceAll('"', '""')}"').join(' ');
  }

  Future<List<SearchResult>> _searchNotebooksFts(
    Database database,
    String query,
  ) async {
    final match = _ftsMatchQuery(query);
    if (match.isEmpty) return [];

    final String sql;
    switch (_searchBackend) {
      case _SearchBackend.fts5:
        // FTS5: `rank` is a built-in auxiliary column; snippet col 1 = title.
        sql = '''
          SELECT notebook_id,
                 snippet(search_index, 1, '<b>', '</b>', '…', 32) AS snip
          FROM search_index
          WHERE search_index MATCH ?
          ORDER BY rank
        ''';
      case _SearchBackend.fts4:
        // FTS4 has no `rank` column; snippet() column index 1 = title.
        sql = '''
          SELECT notebook_id,
                 snippet(search_index, 1, '<b>', '</b>', '…', 32) AS snip
          FROM search_index
          WHERE search_index MATCH ?
        ''';
      case _SearchBackend.none:
        return _searchNotebooksLike(database, query);
    }

    final rows = await database.rawQuery(sql, [match]);
    final results = <SearchResult>[];
    for (final row in rows) {
      final id = row['notebook_id'] as String;
      final nbRows =
          await database.query('notebooks', where: 'id = ?', whereArgs: [id]);
      if (nbRows.isEmpty) continue;
      results.add(SearchResult(
        notebook: Notebook.fromRow(nbRows.first),
        snippet: row['snip'] as String? ?? nbRows.first['title'] as String,
      ));
    }
    return results;
  }

  Future<List<SearchResult>> _searchNotebooksLike(
      Database database, String query) async {
    final like = '%${query.replaceAll('%', '').replaceAll('_', '')}%';
    final titleRows = await database.query('notebooks',
        where: 'title LIKE ?', whereArgs: [like], orderBy: 'updated DESC');
    final textRows = await database.rawQuery('''
      SELECT DISTINCT p.notebook_id AS notebook_id, tb.text AS text
      FROM text_blocks tb
      JOIN pages p ON p.id = tb.page_id
      WHERE tb.text LIKE ?
    ''', [like]);

    final byId = <String, SearchResult>{};
    for (final row in titleRows) {
      final nb = Notebook.fromRow(row);
      byId[nb.id] = SearchResult(notebook: nb, snippet: nb.title);
    }
    for (final row in textRows) {
      final id = row['notebook_id'] as String;
      if (byId.containsKey(id)) continue;
      final nbRows =
          await database.query('notebooks', where: 'id = ?', whereArgs: [id]);
      if (nbRows.isEmpty) continue;
      final text = row['text'] as String;
      byId[id] = SearchResult(
        notebook: Notebook.fromRow(nbRows.first),
        snippet: text.length > 48 ? '${text.substring(0, 48)}…' : text,
      );
    }
    return byId.values.toList();
  }

  Future<void> insertNotebook(Notebook n) async {
    final database = await db;
    await database.insert('notebooks', n.toRow());
    await _indexNotebook(database, n.id, n.title);
  }

  Future<void> touchNotebook(String id) async {
    await (await db).update(
        'notebooks', {'updated': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> renameNotebook(String id, String title) async {
    final database = await db;
    await database.update('notebooks', {'title': title},
        where: 'id = ?', whereArgs: [id]);
    await refreshSearchIndex(id);
  }

  Future<void> deleteNotebook(String id) async {
    final database = await db;
    if (_searchBackend != _SearchBackend.none) {
      await database.delete('search_index',
          where: 'notebook_id = ?', whereArgs: [id]);
    }
    await database.delete('notebooks', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Pages ----

  Future<List<NotePage>> pagesOf(String notebookId) async {
    final rows = await (await db).query('pages',
        where: 'notebook_id = ?', whereArgs: [notebookId], orderBy: 'idx ASC');
    return rows.map(NotePage.fromRow).toList();
  }

  Future<void> insertPage(NotePage page) async {
    await (await db).insert('pages', page.toRow());
  }

  Future<void> deletePage(String id) async {
    await (await db).delete('pages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updatePageTemplate(String id, PageTemplate t) async {
    await (await db).update('pages', {'template': t.index},
        where: 'id = ?', whereArgs: [id]);
  }

  // ---- Strokes ----

  Future<List<Stroke>> strokesOf(String pageId) async {
    final rows = await (await db).query('strokes',
        where: 'page_id = ?', whereArgs: [pageId], orderBy: 'z ASC');
    return rows.map(Stroke.fromRow).toList();
  }

  Future<void> insertStroke(Stroke s) async {
    await (await db).insert('strokes', s.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateStrokePoints(Stroke s) async {
    await (await db).update('strokes', {'points': s.encodePoints()},
        where: 'id = ?', whereArgs: [s.id]);
  }

  // ---- Images ----

  Future<List<PageImage>> imagesOf(String pageId) async {
    final rows = await (await db).query('page_images',
        where: 'page_id = ?', whereArgs: [pageId], orderBy: 'z ASC');
    return rows.map(PageImage.fromRow).toList();
  }

  Future<void> insertImage(PageImage img) async {
    await (await db).insert('page_images', img.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateImageRect(PageImage img) async {
    await (await db).update('page_images',
        {'x': img.x, 'y': img.y, 'w': img.w, 'h': img.h},
        where: 'id = ?', whereArgs: [img.id]);
  }

  Future<void> deleteImage(String id) async {
    await (await db).delete('page_images', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteStrokes(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');
    await (await db).delete('strokes',
        where: 'id IN ($placeholders)', whereArgs: ids.toList());
  }

  // ---- Fills ----

  Future<List<FilledRegion>> fillsOf(String pageId) async {
    final rows = await (await db).query('fills',
        where: 'page_id = ?', whereArgs: [pageId], orderBy: 'z ASC');
    return rows.map(FilledRegion.fromRow).toList();
  }

  Future<void> insertFill(FilledRegion f) async {
    await (await db).insert('fills', f.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteFill(String id) async {
    await (await db).delete('fills', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteFills(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final placeholders = List.filled(ids.length, '?').join(',');
    await (await db).delete('fills',
        where: 'id IN ($placeholders)', whereArgs: ids.toList());
  }

  // ---- Text blocks ----

  Future<List<TextBlock>> textBlocksOf(String pageId) async {
    final rows = await (await db).query('text_blocks',
        where: 'page_id = ?', whereArgs: [pageId], orderBy: 'z ASC');
    return rows.map(TextBlock.fromRow).toList();
  }

  Future<void> insertTextBlock(TextBlock t) async {
    final database = await db;
    await database.insert('text_blocks', t.toRow(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    final page = await database
        .query('pages', where: 'id = ?', whereArgs: [t.pageId]);
    if (page.isNotEmpty) {
      await refreshSearchIndex(page.first['notebook_id'] as String);
    }
  }

  Future<void> updateTextBlock(TextBlock t) async {
    final database = await db;
    await database.update(
        'text_blocks',
        {
          'x': t.x,
          'y': t.y,
          'w': t.w,
          'h': t.h,
          'text': t.text,
          'font_size': t.fontSize,
          'color': t.color,
        },
        where: 'id = ?',
        whereArgs: [t.id]);
    final page = await database
        .query('pages', where: 'id = ?', whereArgs: [t.pageId]);
    if (page.isNotEmpty) {
      await refreshSearchIndex(page.first['notebook_id'] as String);
    }
  }

  Future<void> deleteTextBlock(String id) async {
    final database = await db;
    final rows =
        await database.query('text_blocks', where: 'id = ?', whereArgs: [id]);
    await database.delete('text_blocks', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) {
      final page = await database.query('pages',
          where: 'id = ?', whereArgs: [rows.first['page_id']]);
      if (page.isNotEmpty) {
        await refreshSearchIndex(page.first['notebook_id'] as String);
      }
    }
  }

  Future<void> deleteTextBlocks(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final database = await db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await database.query('text_blocks',
        where: 'id IN ($placeholders)', whereArgs: ids.toList());
    await database.delete('text_blocks',
        where: 'id IN ($placeholders)', whereArgs: ids.toList());
    if (rows.isNotEmpty) {
      final page = await database.query('pages',
          where: 'id = ?', whereArgs: [rows.first['page_id']]);
      if (page.isNotEmpty) {
        await refreshSearchIndex(page.first['notebook_id'] as String);
      }
    }
  }

  // ---- Ink OCR index (v0.2.8) ----

  Future<void> insertInkIndexPending({
    required String id,
    required String pageId,
    required String strokeId,
  }) async {
    await (await db).insert('ink_index', {
      'id': id,
      'page_id': pageId,
      'stroke_id': strokeId,
      'text': '',
      'status': InkIndexStatus.pending.dbValue,
    });
  }

  Future<void> updateInkIndexResult({
    required String id,
    required String text,
    required InkIndexStatus status,
  }) async {
    final database = await db;
    final rows = await database.query('ink_index',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return;
    await database.update(
      'ink_index',
      {
        'text': text,
        'status': status.dbValue,
        'indexed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    final pageId = rows.first['page_id'] as String;
    final page = await database
        .query('pages', where: 'id = ?', whereArgs: [pageId], limit: 1);
    if (page.isNotEmpty) {
      await refreshSearchIndex(page.first['notebook_id'] as String);
    }
  }

  Future<PageOcrStatus> ocrStatusOfPage(String pageId) async {
    final rows = await (await db).query('ink_index',
        columns: ['status'], where: 'page_id = ?', whereArgs: [pageId]);
    var indexed = 0, pending = 0, failed = 0;
    for (final r in rows) {
      switch (InkIndexStatus.fromDb(r['status'] as int)) {
        case InkIndexStatus.pending:
          pending++;
        case InkIndexStatus.indexed:
          indexed++;
        case InkIndexStatus.failed:
          failed++;
      }
    }
    return PageOcrStatus(indexed: indexed, pending: pending, failed: failed);
  }

  Future<Map<String, PageOcrStatus>> ocrStatusOfPages(
      Iterable<String> pageIds) async {
    final ids = pageIds.toList();
    if (ids.isEmpty) return {};
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await (await db).query('ink_index',
        columns: ['page_id', 'status'],
        where: 'page_id IN ($placeholders)',
        whereArgs: ids);
    final map = <String, PageOcrStatus>{};
    for (final id in ids) {
      map[id] = const PageOcrStatus();
    }
    for (final r in rows) {
      final pageId = r['page_id'] as String;
      final cur = map[pageId] ?? const PageOcrStatus();
      switch (InkIndexStatus.fromDb(r['status'] as int)) {
        case InkIndexStatus.pending:
          map[pageId] = PageOcrStatus(
            indexed: cur.indexed,
            pending: cur.pending + 1,
            failed: cur.failed,
          );
        case InkIndexStatus.indexed:
          map[pageId] = PageOcrStatus(
            indexed: cur.indexed + 1,
            pending: cur.pending,
            failed: cur.failed,
          );
        case InkIndexStatus.failed:
          map[pageId] = PageOcrStatus(
            indexed: cur.indexed,
            pending: cur.pending,
            failed: cur.failed + 1,
          );
      }
    }
    return map;
  }

  /// Test hook: insert indexed ink text directly (bypasses ML Kit).
  Future<void> insertInkIndexForTest({
    required String id,
    required String pageId,
    required String strokeId,
    required String text,
  }) async {
    final database = await db;
    await database.insert('ink_index', {
      'id': id,
      'page_id': pageId,
      'stroke_id': strokeId,
      'text': text,
      'status': InkIndexStatus.indexed.dbValue,
      'indexed_at': DateTime.now().millisecondsSinceEpoch,
    });
    final page = await database
        .query('pages', where: 'id = ?', whereArgs: [pageId], limit: 1);
    if (page.isNotEmpty) {
      await refreshSearchIndex(page.first['notebook_id'] as String);
    }
  }
}
