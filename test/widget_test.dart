import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/main.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/session_service.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Widget tests run in fake-async, but sqflite does real I/O on an isolate.
/// runAsync lets those futures complete, then we settle the UI.
Future<void> settle(WidgetTester tester) async {
  // Interleave real-async waits (lets sqflite isolate I/O complete) with
  // frame pumps. Deliberately avoids pumpAndSettle: a visible loading
  // spinner animates forever and would make it time out.
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> settleUntil(WidgetTester tester, Finder finder,
    {int maxAttempts = 24}) async {
  for (var i = 0; i < maxAttempts; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    ThumbnailCache.autoGenerate = false;
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_widget_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await SessionService.instance.clear();
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  testWidgets('app boots to empty library', (tester) async {
    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    expect(find.text('Penfold'), findsOneWidget);
    expect(find.text('No notebooks yet'), findsOneWidget);
    expect(find.text('New notebook'), findsOneWidget);
  });

  testWidgets('new notebook dialog opens and creates a notebook',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    await tester.tap(find.text('New notebook'));
    await tester.pumpAndSettle();

    expect(find.text('Create'), findsOneWidget);
    await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Japanese Grammar');
    await tester.tap(find.text('Create'));
    await settle(tester);
    await settleUntil(tester, find.byTooltip('Pen'));

    expect(find.textContaining('Lined'), findsOneWidget);
    expect(find.byTooltip('Pen'), findsOneWidget);

    // It's also persisted.
    final saved =
        await tester.runAsync(() => AppDatabase.instance.notebooks());
    expect(saved!.length, 1);
    expect(saved.single.title, 'Japanese Grammar');
  });

  testWidgets('cold start restores last notebook from session', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.runAsync(() async {
      final db = AppDatabase.instance;
      final notebook = Notebook(
        id: 'nb-cold-start',
        title: 'Resume Me',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      );
      await db.insertNotebook(notebook);
      for (var i = 0; i < 3; i++) {
        await db.insertPage(NotePage(
          id: 'pg-$i',
          notebookId: notebook.id,
          index: i,
          template: PageTemplate.lined,
        ));
      }
      await SessionService.instance.save(
        notebookId: notebook.id,
        pageIndex: 2,
        scrollOffset: 0,
        tool: ToolType.pen,
      );
    });

    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    expect(find.text('No notebooks yet'), findsNothing);
    await settleUntil(tester, find.byTooltip('Pen'));
    expect(find.byTooltip('Pen'), findsOneWidget);
  });

  testWidgets('cold start clears stale session when notebook is missing',
      (tester) async {
    await tester.runAsync(() async {
      await SessionService.instance.save(
        notebookId: 'deleted-notebook',
        pageIndex: 0,
        scrollOffset: 0,
        tool: ToolType.pen,
      );
    });

    await tester.pumpWidget(const PenfoldApp());
    await settleUntil(tester, find.text('No notebooks yet'));

    expect(find.text('No notebooks yet'), findsOneWidget);
    final session = await tester.runAsync(SessionService.instance.load);
    expect(session, isNull);
  });
}
