import 'package:flutter/material.dart';

import '../services/backup_service.dart';
import '../services/toolbar_order_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _busy = false;
  List<String> _toolOrder = List<String>.from(ToolbarToolId.defaultOrder);
  bool _orderLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadToolOrder();
  }

  Future<void> _loadToolOrder() async {
    await ToolbarOrderService.instance.load();
    if (!mounted) return;
    setState(() {
      _toolOrder = List<String>.from(ToolbarOrderService.instance.order);
      _orderLoaded = true;
    });
  }

  Future<void> _saveToolOrder(List<String> order) async {
    await ToolbarOrderService.instance.saveOrder(order);
    if (!mounted) return;
    setState(() => _toolOrder = List<String>.from(order));
  }

  Future<void> _resetToolOrder() async {
    await _saveToolOrder(ToolbarToolId.defaultOrder);
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      await BackupService.instance.exportAndShare();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final zipPath = await BackupService.instance.pickBackupZip();
    if (zipPath == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore backup?'),
        content: const Text(
          'This replaces your current notebooks and files. '
          'Your current database will be saved to backups/ before restore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final message = await BackupService.instance.restoreFromZip(zipPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    'Toolbar',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Drag to reorder drawing tools. Undo and redo stay fixed on the right.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_orderLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _toolOrder.length,
                    onReorder: (oldIndex, newIndex) {
                      final next = List<String>.from(_toolOrder);
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = next.removeAt(oldIndex);
                      next.insert(newIndex, item);
                      _saveToolOrder(next);
                    },
                    itemBuilder: (context, index) {
                      final id = _toolOrder[index];
                      final label = ToolbarToolId.labels[id] ?? id;
                      final icon = ToolbarToolId.icons[id] ?? Icons.help_outline;
                      return ListTile(
                        key: ValueKey(id),
                        leading: Icon(icon),
                        title: Text(label),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle_rounded),
                        ),
                      );
                    },
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetToolOrder,
                    child: const Text('Reset toolbar order'),
                  ),
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Backup & Restore',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: const Text('Export backup'),
                  subtitle: const Text(
                    'Zip penfold.db, PDF sources, images, and legacy PDF pages',
                  ),
                  onTap: _export,
                ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Restore backup'),
                  subtitle: const Text(
                    'Replace local data from a Penfold backup zip',
                  ),
                  onTap: _restore,
                ),
              ],
            ),
    );
  }
}
