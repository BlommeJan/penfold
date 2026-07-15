import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'pdf_page_cache.dart';
import 'pdf_text_extractor.dart';

const _uuid = Uuid();

/// Imports a PDF fully offline with lazy per-page rendering.
class PdfImportService {
  /// Test hook: when set, PDF sources copy here instead of app documents.
  static String? overrideDocsDirPath;

  /// Returns the created notebook, or null if the user cancelled.
  static Future<Notebook?> pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return importFromPath(path);
  }

  static Future<Notebook> importFromPath(String path) async {
    final parsedPages = PdfTextExtractor.parsePages(path);
    final pageCount = parsedPages.length;
    if (pageCount == 0) {
      throw StateError('PDF has no pages: $path');
    }

    final docsDir = overrideDocsDirPath != null
        ? Directory(overrideDocsDirPath!)
        : await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(docsDir.path, 'pdf_sources'));
    if (!pdfDir.existsSync()) pdfDir.createSync(recursive: true);

    final now = DateTime.now().millisecondsSinceEpoch;
    final notebook = Notebook(
      id: _uuid.v4(),
      title: p.basenameWithoutExtension(path),
      coverColor: 0xFFB23B3B,
      template: PageTemplate.blank,
      pageSize: PageSize.a4,
      createdAt: now,
      updatedAt: now,
    );
    final db = AppDatabase.instance;
    await db.insertNotebook(notebook);

    final storedPdf = File(p.join(pdfDir.path, '${notebook.id}.pdf'));
    await File(path).copy(storedPdf.path);

    final pageIds = <String>[];
    for (var i = 0; i < pageCount; i++) {
      final pageId = _uuid.v4();
      pageIds.add(pageId);
      await db.insertPage(NotePage(
        id: pageId,
        notebookId: notebook.id,
        index: i,
        template: PageTemplate.blank,
        pageSize: PageSize.a4,
        pdfSourcePath: storedPdf.path,
        pdfPageIndex: i + 1,
        aspect: parsedPages[i].aspect,
      ));
      await db.insertPdfPageText(pageIds[i], parsedPages[i].text);
    }
    await db.refreshSearchIndex(notebook.id);

    // Warm first page for immediate open (pdfx render path).
    PdfPageCache.instance.prefetch(storedPdf.path, 1);
    return notebook;
  }
}
