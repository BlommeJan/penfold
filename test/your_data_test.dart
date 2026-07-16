import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:penfold/db/app_database.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/screens/settings_screen.dart';
import 'package:penfold/services/app_info_service.dart';
import 'package:penfold/services/gesture_ink_service.dart';
import 'package:penfold/services/page_turn_mode_service.dart';
import 'package:penfold/services/spen_button_service.dart';
import 'package:penfold/services/stroke_smoothing_service.dart';
import 'package:penfold/services/toolbar_order_service.dart';
import 'package:penfold/services/your_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late Directory tmp;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Penfold',
      packageName: 'com.itsbryce.penfold',
      version: '0.2.62',
      buildNumber: '1',
      buildSignature: '',
    );
    AppInfoService.instance.resetForTests();
    ToolbarOrderService.instance.resetForTests();
    StrokeSmoothingService.instance.resetForTests();
    GestureInkService.instance.resetForTests();
    PageTurnModeService.instance.resetForTests();
    SpenButtonService.instance.resetForTests();
    tmp = await Directory.systemTemp.createTemp('penfold_your_data_test');
    AppDatabase.overrideDirPath = tmp.path;
  });

  tearDown(() async {
    await AppDatabase.instance.resetForTests();
    await tmp.delete(recursive: true);
  });

  group('YourDataService', () {
    test('loadSnapshot reports db path and size', () async {
      final db = AppDatabase.instance;
      await db.insertNotebook(Notebook(
        id: 'nb1',
        title: 'Data',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      ));

      final snapshot = await YourDataService.instance.loadSnapshot();
      expect(snapshot.dbPath, endsWith('penfold.db'));
      expect(snapshot.dbBytes, greaterThan(0));
    });

    test('loadSnapshot sums tracked folder sizes', () async {
      for (final name in YourDataService.trackedFolders) {
        final dir = Directory('${tmp.path}${Platform.pathSeparator}$name');
        dir.createSync(recursive: true);
        await File('${dir.path}${Platform.pathSeparator}file.bin')
            .writeAsBytes(List<int>.filled(100, 1));
      }

      final snapshot = await YourDataService.instance.loadSnapshot();
      for (final name in YourDataService.trackedFolders) {
        expect(snapshot.folderBytes[name], 100);
      }
    });

    test('directorySizeBytes returns zero for missing folder', () {
      final missing = Directory('${tmp.path}${Platform.pathSeparator}missing');
      expect(YourDataService.directorySizeBytes(missing), 0);
    });

    test('formatBytes uses human-readable units', () {
      expect(YourDataService.formatBytes(512), '512 B');
      expect(YourDataService.formatBytes(2048), '2.0 KB');
      expect(YourDataService.formatBytes(5 * 1024 * 1024), '5.0 MB');
    });
  });

  testWidgets('Settings shows Your data section with storage info', (tester) async {
    final db = AppDatabase.instance;
    await tester.runAsync(() async {
      await db.insertNotebook(Notebook(
        id: 'nb-ui',
        title: 'UI',
        coverColor: 0xFF2455C3,
        template: PageTemplate.lined,
        createdAt: 1,
        updatedAt: 1,
      ));

      final imagesDir = Directory('${tmp.path}${Platform.pathSeparator}images');
      imagesDir.createSync(recursive: true);
      await File('${imagesDir.path}${Platform.pathSeparator}pic.png')
          .writeAsBytes([1, 2, 3, 4]);
    });

    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await settle(tester);

    final listView = find.byType(ListView);
    Future<void> scrollTo(Finder target) async {
      for (var i = 0; i < 24; i++) {
        if (target.evaluate().isNotEmpty) return;
        await tester.drag(listView, const Offset(0, -400));
        await settle(tester);
      }
    }

    await scrollTo(find.text('Your data'));
    expect(find.text('Your data'), findsOneWidget);
    expect(find.textContaining('docs/ARCHITECTURE.md'), findsOneWidget);

    await scrollTo(find.text('Database'));
    expect(find.text('Database'), findsOneWidget);
    await scrollTo(find.text('images'));
    expect(find.text('images'), findsOneWidget);

    await scrollTo(find.text('thumbnails'));
    expect(find.text('pdf_sources'), findsOneWidget);
    expect(find.text('audio'), findsOneWidget);
    expect(find.text('thumbnails'), findsOneWidget);

    await scrollTo(find.text('Export backup'));
    expect(find.text('Export backup'), findsOneWidget);
    await scrollTo(find.text('Restore backup'));
    expect(find.text('Restore backup'), findsOneWidget);

    await scrollTo(find.text('About'));
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Penfold'), findsWidgets);
    expect(find.textContaining('Version v0.2.62'), findsOneWidget);
    expect(
      find.textContaining('Local-first handwriting notebook'),
      findsOneWidget,
    );
  });
}
