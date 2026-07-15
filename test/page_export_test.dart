import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/page_export.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_export_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  test('renderPage produces canonical-size image', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: _uuid.v4(),
      title: 'Export Test',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      createdAt: 0,
      updatedAt: 0,
    );
    await db.insertNotebook(notebook);
    final page = NotePage(
      id: _uuid.v4(),
      notebookId: notebook.id,
      index: 0,
      template: PageTemplate.grid,
      pageSize: PageSize.a4,
    );
    await db.insertPage(page);

    final data = await PageExportService.instance.loadPageData(page);
    ui.Image? image;
    try {
      image = await PageExportService.instance.renderPage(data);
      expect(image.width, PageSize.a4.width * exportPixelRatio);
      expect(image.height, PageSize.a4.height * exportPixelRatio);
    } finally {
      image?.dispose();
      data.dispose();
    }
  });

  test('buildPdfBytes returns non-empty PDF', () async {
    final pageSize = PageSize.a4;
    final displaySize = Size(pageSize.width.toDouble(), pageSize.height.toDouble());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Offset.zero & displaySize,
      Paint()..color = const Color(0xFFFFFFFF),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (displaySize.width * exportPixelRatio).round(),
      (displaySize.height * exportPixelRatio).round(),
    );
    try {
      final bytes = await PageExportService.instance.buildPdfBytes([
        (image: image, pageSize: pageSize),
      ]);
      expect(bytes.length, greaterThan(100));
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    } finally {
      image.dispose();
    }
  });

  test('buildNotebookPdfBytes returns multi-page PDF incrementally', () async {
    final db = AppDatabase.instance;
    final notebook = Notebook(
      id: _uuid.v4(),
      title: 'Multi Export',
      coverColor: 0xFF2455C3,
      template: PageTemplate.blank,
      createdAt: 0,
      updatedAt: 0,
    );
    await db.insertNotebook(notebook);

    final pages = <NotePage>[];
    for (var i = 0; i < 3; i++) {
      final page = NotePage(
        id: _uuid.v4(),
        notebookId: notebook.id,
        index: i,
        template: PageTemplate.blank,
        pageSize: PageSize.a5,
      );
      await db.insertPage(page);
      pages.add(page);
    }

    var lastProgress = (0, 0);
    final bytes = await PageExportService.instance.buildNotebookPdfBytes(
      pages: pages,
      onProgress: (current, total) => lastProgress = (current, total),
    );
    expect(bytes.length, greaterThan(100));
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(lastProgress, (3, 3));
  });
}
