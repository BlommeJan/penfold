import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../services/backup_service.dart';
import '../services/page_turn_mode_service.dart';
import '../services/spen_button_service.dart';
import '../services/stroke_smoothing_service.dart';
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
  List<String> _ocrTerms = [];
  bool _ocrTermsLoaded = false;
  bool _strokeSmoothing = true;
  bool _strokeSmoothingLoaded = false;
  bool _pageTurnMode = false;
  bool _pageTurnModeLoaded = false;
  SpenBarrelAction _spenAction = SpenBarrelAction.eraser;
  bool _spenLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadToolOrder();
    _loadOcrTerms();
    _loadStrokeSmoothing();
    _loadPageTurnMode();
    _loadSpenAction();
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

  Future<void> _loadStrokeSmoothing() async {
    await StrokeSmoothingService.instance.load();
    if (!mounted) return;
    setState(() {
      _strokeSmoothing = StrokeSmoothingService.instance.enabled;
      _strokeSmoothingLoaded = true;
    });
  }

  Future<void> _setStrokeSmoothing(bool value) async {
    await StrokeSmoothingService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _strokeSmoothing = value);
  }

  Future<void> _loadPageTurnMode() async {
    await PageTurnModeService.instance.load();
    if (!mounted) return;
    setState(() {
      _pageTurnMode = PageTurnModeService.instance.enabled;
      _pageTurnModeLoaded = true;
    });
  }

  Future<void> _setPageTurnMode(bool value) async {
    await PageTurnModeService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _pageTurnMode = value);
  }

  Future<void> _loadSpenAction() async {
    await SpenButtonService.instance.load();
    if (!mounted) return;
    setState(() {
      _spenAction = SpenButtonService.instance.action;
      _spenLoaded = true;
    });
  }

  Future<void> _setSpenAction(SpenBarrelAction value) async {
    await SpenButtonService.instance.setAction(value);
    if (!mounted) return;
    setState(() => _spenAction = value);
  }

  Future<void> _loadOcrTerms() async {
    final terms = await AppDatabase.instance.allOcrTerms();
    if (!mounted) return;
    setState(() {
      _ocrTerms = terms;
      _ocrTermsLoaded = true;
    });
  }

  Future<void> _addOcrTerm() async {
    final controller = TextEditingController();
    final term = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add OCR term'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Term',
            hintText: 'e.g. eigenvalue, mitochondria',
          ),
          textCapitalization: TextCapitalization.none,
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (term == null) return;

    final normalized = term.trim();
    if (normalized.isEmpty) return;

    await AppDatabase.instance.addOcrTerm(normalized);
    await _loadOcrTerms();
  }

  Future<void> _removeOcrTerm(String term) async {
    await AppDatabase.instance.removeOcrTerm(term);
    await _loadOcrTerms();
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
                    'Notebook',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (!_pageTurnModeLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SwitchListTile(
                    secondary: const Icon(Icons.view_carousel_outlined),
                    title: const Text('Page-turn mode'),
                    subtitle: const Text(
                      'Swipe one page at a time instead of continuous scroll (default off)',
                    ),
                    value: _pageTurnMode,
                    onChanged: _setPageTurnMode,
                  ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Drawing',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (!_strokeSmoothingLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SwitchListTile(
                    secondary: const Icon(Icons.draw_rounded),
                    title: const Text('Stroke smoothing'),
                    subtitle: const Text(
                      'Smooth ink strokes with Chaikin corner-cutting (default on)',
                    ),
                    value: _strokeSmoothing,
                    onChanged: _setStrokeSmoothing,
                  ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'S Pen',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Hold the S Pen side button to temporarily switch tools. '
                    'Release to restore your previous tool. Works on Samsung '
                    'devices with barrel-button support.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (!_spenLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: DropdownButtonFormField<SpenBarrelAction>(
                      value: _spenAction,
                      decoration: const InputDecoration(
                        labelText: 'Barrel button action',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final action in SpenBarrelAction.values)
                          DropdownMenuItem(
                            value: action,
                            child: Text(action.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) _setSpenAction(value);
                      },
                    ),
                  ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'OCR dictionary',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Domain terms for handwriting OCR. Close matches are corrected '
                    'when ink is indexed, and terms boost notebook search.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_ocrTermsLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_ocrTerms.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'No custom terms yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                else
                  ..._ocrTerms.map(
                    (term) => ListTile(
                      key: ValueKey(term),
                      title: Text(term),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove term',
                        onPressed: () => _removeOcrTerm(term),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addOcrTerm,
                      icon: const Icon(Icons.add),
                      label: const Text('Add term'),
                    ),
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
