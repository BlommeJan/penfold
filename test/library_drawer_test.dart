import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/widgets/library_drawer.dart';

void main() {
  testWidgets('LibraryDrawer shows overview and trash count', (tester) async {
    final folders = [
      Folder(id: 'f1', name: 'Work', sortOrder: 0),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: LibraryDrawer(
          folders: folders,
          currentFolderId: null,
          trashCount: 3,
          onOverview: () {},
          onOpenTrash: () {},
          onOpenSettings: () {},
          onFolderSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Trash'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });
}
