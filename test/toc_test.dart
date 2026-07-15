import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/toc_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_toc_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  Notebook nb() => Notebook(
        id: 'nb-toc',
        title: 'TOC Notebook',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        pageSize: PageSize.a4,
        createdAt: 1,
        updatedAt: 1,
      );

  group('TocService.isHeadingLike', () {
    test('detects ALL CAPS short headings', () {
      expect(TocService.isHeadingLike('CHAPTER ONE'), isTrue);
      expect(
        TocService.isHeadingLike(
          'This introduction explains the background in detail.',
        ),
        isFalse,
      );
    });

    test('detects large font text blocks', () {
      const baseline = 50.4; // A4 portrait default
      expect(
        TocService.isHeadingLike(
          'Overview',
          fontSize: baseline * 1.5,
          baselineFontSize: baseline,
        ),
        isTrue,
      );
      expect(
        TocService.isHeadingLike(
          'Overview',
          fontSize: baseline,
          baselineFontSize: baseline,
        ),
        isTrue,
      );
    });

    test('rejects long body paragraphs', () {
      final long =
          'This is a long paragraph that should not be treated as a heading '
          'because it reads like normal note body text.';
      expect(TocService.isHeadingLike(long), isFalse);
    });

    test('detects short single-line titles', () {
      expect(TocService.isHeadingLike('Methods'), isTrue);
      expect(TocService.isHeadingLike('Results\nMore detail below'), isTrue);
    });
  });

  group('TocService.buildNotebookToc', () {
    test('collects TextBlock headings across pages in order', () async {
      final db = AppDatabase.instance;
      await db.insertNotebook(nb());
      final p0 = NotePage(
        id: 'pg0',
        notebookId: 'nb-toc',
        index: 0,
        template: PageTemplate.lined,
      );
      final p1 = NotePage(
        id: 'pg1',
        notebookId: 'nb-toc',
        index: 1,
        template: PageTemplate.lined,
      );
      await db.insertPage(p0);
      await db.insertPage(p1);

      const baseline = 2100 * 0.024;
      await db.insertTextBlock(TextBlock(
        id: 'tb1',
        pageId: 'pg0',
        x: 100,
        y: 200,
        w: 400,
        h: 60,
        text: 'INTRODUCTION',
        fontSize: baseline,
        color: 0xFF000000,
        z: 1,
      ));
      await db.insertTextBlock(TextBlock(
        id: 'tb2',
        pageId: 'pg1',
        x: 100,
        y: 50,
        w: 400,
        h: 60,
        text: 'Chapter Two',
        fontSize: baseline * 1.5,
        color: 0xFF000000,
        z: 1,
      ));
      await db.insertTextBlock(TextBlock(
        id: 'tb3',
        pageId: 'pg1',
        x: 100,
        y: 300,
        w: 400,
        h: 60,
        text: 'This paragraph is far too long to be considered a heading.',
        fontSize: baseline,
        color: 0xFF000000,
        z: 2,
      ));

      final toc = await TocService.instance.buildNotebookToc('nb-toc');
      expect(toc.length, 2);
      expect(toc[0].title, 'INTRODUCTION');
      expect(toc[0].pageIndex, 0);
      expect(toc[0].source, TocSource.textBlock);
      expect(toc[1].title, 'Chapter Two');
      expect(toc[1].pageIndex, 1);
    });

    test('includes OCR ink_index headings', () async {
      final db = AppDatabase.instance;
      await db.insertNotebook(nb());
      final page = NotePage(
        id: 'pg-ink',
        notebookId: 'nb-toc',
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
          StrokePoint(10, 120, 0.5),
          StrokePoint(20, 130, 0.5),
        ],
        z: 1,
      ));
      await db.insertInkIndexForTest(
        id: 'idx-1',
        pageId: page.id,
        strokeId: 'stroke-1',
        text: 'SUMMARY',
      );

      final toc = await TocService.instance.buildNotebookToc('nb-toc');
      expect(toc.length, 1);
      expect(toc.single.title, 'SUMMARY');
      expect(toc.single.source, TocSource.inkOcr);
      expect(toc.single.pageIndex, 0);
    });

    test('skips sticky notes and dedupes same title on a page', () async {
      final db = AppDatabase.instance;
      await db.insertNotebook(nb());
      final page = NotePage(
        id: 'pg-dedupe',
        notebookId: 'nb-toc',
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      const baseline = 2100 * 0.024;
      await db.insertTextBlock(TextBlock(
        id: 'tb-note',
        pageId: page.id,
        x: 0,
        y: 0,
        w: 100,
        h: 100,
        text: 'REMINDER',
        fontSize: baseline,
        color: 0xFF000000,
        z: 1,
        isNote: true,
      ));
      await db.insertTextBlock(TextBlock(
        id: 'tb-a',
        pageId: page.id,
        x: 0,
        y: 10,
        w: 200,
        h: 40,
        text: 'Goals',
        fontSize: baseline,
        color: 0xFF000000,
        z: 2,
      ));
      await db.insertTextBlock(TextBlock(
        id: 'tb-b',
        pageId: page.id,
        x: 0,
        y: 80,
        w: 200,
        h: 40,
        text: 'goals',
        fontSize: baseline,
        color: 0xFF000000,
        z: 3,
      ));

      final toc = await TocService.instance.buildNotebookToc('nb-toc');
      expect(toc.length, 1);
      expect(toc.single.title, 'Goals');
    });

    test('indexedInkTextOfPage returns only indexed rows', () async {
      final db = AppDatabase.instance;
      await db.insertNotebook(nb());
      final page = NotePage(
        id: 'pg-idx',
        notebookId: 'nb-toc',
        index: 0,
        template: PageTemplate.blank,
      );
      await db.insertPage(page);
      await db.insertStroke(Stroke(
        id: 's1',
        pageId: page.id,
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 2,
        points: const [StrokePoint(1, 1, 0.5)],
        z: 1,
      ));
      await db.insertInkIndexPending(
        id: 'pending-1',
        pageId: page.id,
        strokeId: 's1',
      );
      await db.insertInkIndexForTest(
        id: 'indexed-1',
        pageId: page.id,
        strokeId: 's1',
        text: 'DONE',
      );

      final rows = await db.indexedInkTextOfPage(page.id);
      expect(rows.length, 1);
      expect(rows.single.text, 'DONE');
    });
  });

  test('displayTitle uses first line only', () {
    expect(
      TocService.displayTitle('Heading\nBody text here'),
      'Heading',
    );
  });
}
