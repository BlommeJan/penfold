import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'pdf_page_cache.dart';

const _uuid = Uuid();

/// Imports a PDF fully offline with lazy per-page rendering.
class PdfImportService {
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
    final doc = await PdfDocument.openFile(path);
    final pageCount = doc.pagesCount;
    final docsDir = await getApplicationDocumentsDirectory();
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

    double? firstAspect;
    for (var i = 1; i <= pageCount; i++) {
      if (i == 1) {
        final page = await doc.getPage(i);
        firstAspect = page.width / page.height;
        await page.close();
      }
      await db.insertPage(NotePage(
        id: _uuid.v4(),
        notebookId: notebook.id,
        index: i - 1,
        template: PageTemplate.blank,
        pageSize: PageSize.a4,
        pdfSourcePath: storedPdf.path,
        pdfPageIndex: i,
        aspect: firstAspect ?? PageSize.a4.aspect,
      ));
    }
    await doc.close();

    // Warm first page for immediate open.
    if (pageCount > 0) {
      PdfPageCache.instance.prefetch(storedPdf.path, 1);
    }
    return notebook;
  }
}
