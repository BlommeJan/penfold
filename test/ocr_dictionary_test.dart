import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/ink_ocr_service.dart';
import 'package:penfold/services/ocr_dictionary.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tmp;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    InkOcrService.disableMlKit = true;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_ocr_dict_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('ocr_terms schema', () {
    test('v11 migration creates ocr_terms table', () async {
      final database = await AppDatabase.instance.db;
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ocr_terms'",
      );
      expect(tables.length, 1);
    });

    test('addOcrTerm, allOcrTerms, removeOcrTerm', () async {
      final db = AppDatabase.instance;
      await db.addOcrTerm('eigenvalue');
      await db.addOcrTerm('  mitochondria  ');
      await db.addOcrTerm('eigenvalue');

      final terms = await db.allOcrTerms();
      expect(terms, ['eigenvalue', 'mitochondria']);

      await db.removeOcrTerm('eigenvalue');
      expect(await db.allOcrTerms(), ['mitochondria']);
    });

    test('empty terms are ignored', () async {
      final db = AppDatabase.instance;
      await db.addOcrTerm('');
      await db.addOcrTerm('   ');
      expect(await db.allOcrTerms(), isEmpty);
    });
  });

  group('applyOcrDictionary', () {
    test('corrects close OCR misspellings', () {
      const terms = ['eigenvalue', 'mitochondria'];
      expect(
        applyOcrDictionary('the e1genvalue is key', terms),
        'the eigenvalue is key',
      );
      expect(
        applyOcrDictionary('mitocondria power', terms),
        'mitochondria power',
      );
    });

    test('leaves unrelated words unchanged', () {
      const terms = ['eigenvalue'];
      expect(
        applyOcrDictionary('hello world', terms),
        'hello world',
      );
    });

    test('preserves stored casing', () {
      const terms = ['Eigenvalue'];
      expect(
        applyOcrDictionary('eigenvalve', terms),
        'Eigenvalue',
      );
    });
  });

  group('search integration', () {
    test('ocr terms boost notebook FTS body', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-glossary',
        title: 'Glossary NB',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      await db.addOcrTerm('superconductivity');

      final hits = await db.searchNotebooks('superconductivity');
      expect(hits.any((h) => h.notebook.id == nb.id), isTrue);
    });

    test('corrected OCR text is indexed for search', () async {
      final db = AppDatabase.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final nb = Notebook(
        id: 'nb-corrected',
        title: 'Corrected NB',
        coverColor: 0xFF2455C3,
        template: PageTemplate.blank,
        createdAt: now,
        updatedAt: now,
      );
      await db.insertNotebook(nb);
      final page = NotePage(
        id: 'pg-corrected',
        notebookId: nb.id,
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      await db.insertStroke(Stroke(
        id: 'stroke-1',
        pageId: page.id,
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 3,
        points: const [
          StrokePoint(10, 10, 0.5),
          StrokePoint(20, 20, 0.5),
        ],
        z: 1,
      ));
      await db.addOcrTerm('eigenvalue');

      final raw = 'e1genvalue';
      final corrected = applyOcrDictionary(raw, await db.allOcrTerms());
      await db.insertInkIndexForTest(
        id: 'idx-corrected',
        pageId: page.id,
        strokeId: 'stroke-1',
        text: corrected,
      );

      final hits = await db.searchNotebooks('eigenvalue');
      expect(hits.any((h) => h.notebook.id == nb.id), isTrue);
    });
  });
}
