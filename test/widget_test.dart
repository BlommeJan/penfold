import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/main.dart';
import 'package:penfold/services/thumbnail_cache.dart';
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

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    ThumbnailCache.autoGenerate = false;
  });

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_widget_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
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

    // Notebook was created and opened; settings gear is rightmost in toolbar.
    expect(find.byTooltip('Page settings'), findsOneWidget);

    // It's also persisted.
    final saved =
        await tester.runAsync(() => AppDatabase.instance.notebooks());
    expect(saved!.length, 1);
    expect(saved.single.title, 'Japanese Grammar');
  });
}
