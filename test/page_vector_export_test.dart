import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/page_export.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

Stroke _penStroke(String pageId, List<List<double>> points) => Stroke(
      id: _uuid.v4(),
      pageId: pageId,
      tool: ToolType.pen,
      color: 0xFF000000,
      width: 40,
      points: points
          .map((p) => StrokePoint(p[0], p[1], p.length > 2 ? p[2] : 0.8))
          .toList(),
      z: 0,
    );

Stroke _highlighterStroke(String pageId, List<List<double>> points) => Stroke(
      id: _uuid.v4(),
      pageId: pageId,
      tool: ToolType.highlighter,
      color: 0xFFFFFF00,
      width: 80,
      points: points
          .map((p) => StrokePoint(p[0], p[1], p.length > 2 ? p[2] : 0.8))
          .toList(),
      z: 1,
    );

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_vector_export_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  test('vector PDF contains stroke path operators', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: _uuid.v4(),
      title: 'Vector Export',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 0,
      updatedAt: 0,
    );
    await db.insertNotebook(notebook);
    final page = NotePage(
      id: _uuid.v4(),
      notebookId: notebook.id,
      index: 0,
      template: PageTemplate.lined,
      pageSize: PageSize.a4,
    );
    await db.insertPage(page);
    await db.insertStroke(_penStroke(page.id, [
      [400, 400],
      [800, 600],
      [1200, 500],
    ]));
    await db.insertStroke(_highlighterStroke(page.id, [
      [500, 900],
      [1500, 950],
      [1800, 1100],
    ]));

    final bytes = await PageExportService.instance.buildNotebookPdfBytes(
      pages: [page],
    );

    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(pdfBytesContainVectorInk(bytes), isTrue);
  });

  test('multi-page vector PDF with strokes on each page', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: _uuid.v4(),
      title: 'Multi Vector',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 0,
      updatedAt: 0,
    );
    await db.insertNotebook(notebook);

    final pages = <NotePage>[];
    for (var i = 0; i < 2; i++) {
      final page = NotePage(
        id: _uuid.v4(),
        notebookId: notebook.id,
        index: i,
        template: PageTemplate.blank,
        pageSize: PageSize.a5,
      );
      await db.insertPage(page);
      await db.insertStroke(_penStroke(page.id, [
        [200 + i * 50, 300],
        [600 + i * 50, 700],
      ]));
      pages.add(page);
    }

    final bytes = await PageExportService.instance.buildNotebookPdfBytes(
      pages: pages,
    );

    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(pdfBytesContainVectorInk(bytes), isTrue);
    final pageCount = RegExp(r'/Type\s*/Page[^s]').allMatches(
      String.fromCharCodes(bytes),
    ).length;
    expect(pageCount, greaterThanOrEqualTo(2));
  });
}
