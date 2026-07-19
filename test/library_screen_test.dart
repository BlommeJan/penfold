import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/main.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/app_info_service.dart';
import 'package:penfold/services/session_service.dart';
import 'package:penfold/services/theme_settings_service.dart';
import 'package:penfold/services/thumbnail_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> seedLibraryFixtures(AppDatabase db) async {
  await db.insertFolder(Folder(id: 'f1', name: 'Work', sortOrder: 0));
  await db.insertNotebook(
    Notebook(
      id: 'nb-in-folder',
      title: 'Project Notes',
      coverColor: 0xFF2455C3,
      template: PageTemplate.lined,
      pageSize: PageSize.a4,
      folderId: 'f1',
      createdAt: 1,
      updatedAt: 1,
    ),
  );
  await db.insertNotebook(
    Notebook(
      id: 'nb-loose',
      title: 'Loose Leaf',
      coverColor: 0xFFD63B3B,
      template: PageTemplate.lined,
      pageSize: PageSize.a4,
      createdAt: 2,
      updatedAt: 2,
    ),
  );
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
    PackageInfo.setMockInitialValues(
      appName: 'Penfold',
      packageName: 'com.itsbryce.penfold',
      version: '0.3.4',
      buildNumber: '1',
      buildSignature: '',
    );
    AppInfoService.instance.resetForTests();
    ThemeSettingsService.instance.resetForTests();
    tmp = await Directory.systemTemp.createTemp('penfold_library_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await SessionService.instance.clear();
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  testWidgets('library shows All and Overview segmented control',
      (tester) async {
    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    expect(
      find.byWidgetPredicate((widget) => widget is SegmentedButton),
      findsOneWidget,
    );
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
  });

  testWidgets('Overview root shows folders and uncategorized notebooks only',
      (tester) async {
    await tester.runAsync(() => seedLibraryFixtures(AppDatabase.instance));

    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    await tester.tap(find.text('Overview'));
    await settle(tester);

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Loose Leaf'), findsOneWidget);
    expect(find.text('Project Notes'), findsNothing);
  });

  testWidgets('All mode shows every notebook with folder subtitle',
      (tester) async {
    await tester.runAsync(() => seedLibraryFixtures(AppDatabase.instance));

    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    await tester.tap(find.text('All'));
    await settle(tester);

    expect(find.text('Project Notes'), findsOneWidget);
    expect(find.text('Loose Leaf'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('search finds notebooks by title in Overview mode',
      (tester) async {
    await tester.runAsync(() => seedLibraryFixtures(AppDatabase.instance));

    await tester.pumpWidget(const PenfoldApp());
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'Project');
    await settle(tester);

    expect(find.text('Project Notes'), findsWidgets);
    expect(find.text('Loose Leaf'), findsNothing);
  });
}
