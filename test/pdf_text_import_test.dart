import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/pdf_import.dart';
import 'package:penfold/services/pdf_text_extractor.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<File> _writeSamplePdf(Directory dir, {required List<String> pageTexts}) async {
  final pdf = pw.Document();
  for (final text in pageTexts) {
    pdf.addPage(pw.Page(build: (ctx) => pw.Text(text)));
  }
  final file = File(p.join(dir.path, 'sample.pdf'));
  await file.writeAsBytes(await pdf.save());
  return file;
}

void main() {
  late Directory tmp;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_pdf_text_test');
    AppDatabase.overrideDirPath = tmp.path;
    PdfImportService.overrideDocsDirPath = tmp.path;
  });

  tearDown(() async {
    PdfImportService.overrideDocsDirPath = null;
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('PdfTextExtractor', () {
    test('extracts embedded text per page from pdf package output', () async {
      final pdfFile = await _writeSamplePdf(
        tmp,
        pageTexts: const ['PenfoldSearchTerm', 'SecondPageKeyword'],
      );

      final pages = PdfTextExtractor.extractPages(pdfFile.path);

      expect(pages.length, 2);
      expect(pages[0], contains('PenfoldSearchTerm'));
      expect(pages[1], contains('SecondPageKeyword'));
    });

    test('returns empty strings for pages without text', () async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(build: (ctx) => pw.SizedBox()));
      final file = File(p.join(tmp.path, 'blank.pdf'));
      await file.writeAsBytes(await pdf.save());

      final pages = PdfTextExtractor.extractPages(file.path);

      expect(pages.length, 1);
      expect(pages.single, isEmpty);
    });
  });

  group('pdf_page_text schema', () {
    test('v13 migration creates pdf_page_text table', () async {
      final database = await AppDatabase.instance.db;
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='pdf_page_text'",
      );
      expect(tables.length, 1);
    });

    test('embedded PDF text is searchable before OCR ink index', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-pdf-text',
        title: 'Imported Slides',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      final page = NotePage(
        id: 'pg-pdf-text',
        notebookId: nb.id,
        index: 0,
        template: PageTemplate.blank,
        pdfSourcePath: '/tmp/sample.pdf',
        pdfPageIndex: 1,
      );
      await db.insertPage(page);
      await db.insertPdfPageText(page.id, 'quantumfieldtheory lecture notes');
      await db.refreshSearchIndex(nb.id);

      final hits = await db.searchNotebooks('quantumfieldtheory');
      expect(hits.any((h) => h.notebook.id == nb.id), isTrue);
    });
  });

  group('PdfImportService', () {
    test('import indexes embedded PDF text into FTS immediately', () async {
      final pdfFile = await _writeSamplePdf(
        tmp,
        pageTexts: const ['UniqueImportKeywordXyz'],
      );

      final notebook = await PdfImportService.importFromPath(pdfFile.path);

      final hits = await AppDatabase.instance.searchNotebooks('UniqueImportKeywordXyz');
      expect(hits.any((h) => h.notebook.id == notebook.id), isTrue);

      final pages = await AppDatabase.instance.pagesOf(notebook.id);
      expect(pages.length, 1);
      expect(pages.single.pdfSourcePath, isNotNull);
    });
  });
}
