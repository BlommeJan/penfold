import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';

const _uuid = Uuid();

/// Imports a PDF fully offline: each page is rendered once to a PNG in app
/// storage and becomes an annotatable page background. No upload, no account.
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
    final docsDir = await getApplicationDocumentsDirectory();
    final imgDir = Directory(p.join(docsDir.path, 'pdf_pages'));
    if (!imgDir.existsSync()) imgDir.createSync(recursive: true);

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

    for (var i = 1; i <= doc.pagesCount; i++) {
      final page = await doc.getPage(i);
      // 2x render for crisp zooming without exploding memory.
      final img = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: PdfPageImageFormat.png,
      );
      final aspect = page.width / page.height;
      await page.close();
      if (img == null) continue;

      final file = File(p.join(imgDir.path, '${notebook.id}_$i.png'));
      await file.writeAsBytes(img.bytes);

      await db.insertPage(NotePage(
        id: _uuid.v4(),
        notebookId: notebook.id,
        index: i - 1,
        template: PageTemplate.blank,
        pageSize: PageSize.a4,
        pdfImagePath: file.path,
        aspect: aspect,
      ));
    }
    await doc.close();
    return notebook;
  }
}
