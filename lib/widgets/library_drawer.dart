import 'package:flutter/material.dart';

import '../models/models.dart';

class LibraryDrawer extends StatelessWidget {
  final List<Folder> folders;
  final String? currentFolderId;
  final int trashCount;
  final VoidCallback onOverview;
  final VoidCallback onOpenTrash;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onFolderSelected;

  const LibraryDrawer({
    super.key,
    required this.folders,
    required this.currentFolderId,
    required this.trashCount,
    required this.onOverview,
    required this.onOpenTrash,
    required this.onOpenSettings,
    required this.onFolderSelected,
  });

  List<Folder> _childrenOf(String? parentId) => folders
      .where((f) => f.parentId == parentId && !f.isDeleted)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<Widget> _folderTiles(String? parentId, int depth) {
    final tiles = <Widget>[];
    for (final folder in _childrenOf(parentId)) {
      tiles.add(
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(folder.name),
          selected: currentFolderId == folder.id,
          contentPadding: EdgeInsets.only(left: 16 + depth * 16, right: 16),
          onTap: () => onFolderSelected(folder.id),
        ),
      );
      tiles.addAll(_folderTiles(folder.id, depth + 1));
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    final folderTiles = _folderTiles(null, 0);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Penfold',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Overview'),
              selected: currentFolderId == null,
              onTap: onOverview,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text('Trash'),
              trailing: trashCount > 0 ? Text('$trashCount') : null,
              onTap: onOpenTrash,
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: onOpenSettings,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Folders',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (folderTiles.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text('No folders yet'),
              )
            else
              ...folderTiles,
          ],
        ),
      ),
    );
  }
}
