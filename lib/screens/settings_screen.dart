import 'package:flutter/material.dart';

import '../db/app_database.dart';
import '../l10n/l10n.dart';
import '../services/app_info_service.dart';
import '../services/backup_service.dart';
import '../services/finger_drawing_service.dart';
import '../services/gesture_ink_service.dart';
import '../services/your_data_service.dart';
import '../services/page_turn_mode_service.dart';
import '../services/spen_button_service.dart';
import '../services/stroke_smoothing_service.dart';
import '../services/toolbar_order_service.dart';
import '../services/zoom_navigation_service.dart';

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
  bool _gestureInkEditing = true;
  bool _gestureInkEditingLoaded = false;
  bool _fingerDrawing = false;
  bool _fingerDrawingLoaded = false;
  bool _pageTurnMode = false;
  bool _pageTurnModeLoaded = false;
  bool _zoomNavigation = true;
  bool _zoomNavigationLoaded = false;
  SpenBarrelAction _spenAction = SpenBarrelAction.eraser;
  bool _spenLoaded = false;
  YourDataSnapshot? _yourData;
  bool _yourDataLoaded = false;
  AutoBackupInfo? _latestAutoBackup;
  bool _autoBackupLoaded = false;
  bool _appInfoLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadToolOrder();
    _loadOcrTerms();
    _loadStrokeSmoothing();
    _loadGestureInkEditing();
    _loadFingerDrawing();
    _loadPageTurnMode();
    _loadZoomNavigation();
    _loadSpenAction();
    _loadYourData();
    _loadAutoBackup();
  }

  Future<void> _loadAppInfo() async {
    await AppInfoService.instance.load();
    if (!mounted) return;
    setState(() => _appInfoLoaded = true);
  }

  Future<void> _loadAutoBackup() async {
    final latest = await BackupService.instance.latestAutoBackup();
    if (!mounted) return;
    setState(() {
      _latestAutoBackup = latest;
      _autoBackupLoaded = true;
    });
  }

  Future<void> _loadYourData() async {
    final snapshot = await YourDataService.instance.loadSnapshot();
    if (!mounted) return;
    setState(() {
      _yourData = snapshot;
      _yourDataLoaded = true;
    });
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

  Future<void> _loadGestureInkEditing() async {
    await GestureInkService.instance.load();
    if (!mounted) return;
    setState(() {
      _gestureInkEditing = GestureInkService.instance.enabled;
      _gestureInkEditingLoaded = true;
    });
  }

  Future<void> _setGestureInkEditing(bool value) async {
    await GestureInkService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _gestureInkEditing = value);
  }

  Future<void> _loadFingerDrawing() async {
    await FingerDrawingService.instance.load();
    if (!mounted) return;
    setState(() {
      _fingerDrawing = FingerDrawingService.instance.enabled;
      _fingerDrawingLoaded = true;
    });
  }

  Future<void> _setFingerDrawing(bool value) async {
    await FingerDrawingService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _fingerDrawing = value);
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

  Future<void> _loadZoomNavigation() async {
    await ZoomNavigationService.instance.load();
    if (!mounted) return;
    setState(() {
      _zoomNavigation = ZoomNavigationService.instance.enabled;
      _zoomNavigationLoaded = true;
    });
  }

  Future<void> _setZoomNavigation(bool value) async {
    await ZoomNavigationService.instance.setEnabled(value);
    if (!mounted) return;
    setState(() => _zoomNavigation = value);
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
    final l10n = context.l10n;
    final controller = TextEditingController();
    final term = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsAddOcrTermTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.settingsOcrTermLabel,
            hintText: l10n.settingsOcrTermHint,
          ),
          textCapitalization: TextCapitalization.none,
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l10n.actionAdd),
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
          SnackBar(content: Text(context.l10n.backupFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recoverFromAutoBackup() async {
    final latest = _latestAutoBackup;
    if (latest == null) return;

    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRecoverAutoBackupTitle),
        content: Text(
          l10n.settingsRecoverAutoBackupBody(
            _formatBackupTime(latest.createdAt),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionRecover),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final message =
          await BackupService.instance.restoreFromLatestAutoBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.restoreComplete),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.recoveryFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatBackupTime(DateTime time) {
    final local = time.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  Future<void> _restore() async {
    final zipPath = await BackupService.instance.pickBackupZip();
    if (zipPath == null || !mounted) return;

    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRestoreBackupTitle),
        content: Text(l10n.settingsRestoreBackupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionRestore),
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
            content: Text(context.l10n.restoreComplete),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.restoreFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Text(
                    l10n.settingsSectionToolbar,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.settingsToolbarReorderHint,
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
                      final label = l10n.toolbarToolLabel(id);
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
                    child: Text(l10n.settingsResetToolbarOrder),
                  ),
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.settingsSectionNotebook,
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
                    title: Text(l10n.settingsPageTurnMode),
                    subtitle: Text(l10n.settingsPageTurnModeSubtitle),
                    value: _pageTurnMode,
                    onChanged: _setPageTurnMode,
                  ),
                if (!_zoomNavigationLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SwitchListTile(
                    secondary: const Icon(Icons.zoom_in_map_outlined),
                    title: Text(l10n.settingsZoomNavigation),
                    subtitle: Text(l10n.settingsZoomNavigationSubtitle),
                    value: _zoomNavigation,
                    onChanged: _setZoomNavigation,
                  ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.settingsSectionDrawing,
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
                    title: Text(l10n.settingsStrokeSmoothing),
                    subtitle: Text(l10n.settingsStrokeSmoothingSubtitle),
                    value: _strokeSmoothing,
                    onChanged: _setStrokeSmoothing,
                  ),
                if (!_fingerDrawingLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SwitchListTile(
                    secondary: const Icon(Icons.touch_app_outlined),
                    title: Text(l10n.settingsFingerDrawing),
                    subtitle: Text(l10n.settingsFingerDrawingSubtitle),
                    value: _fingerDrawing,
                    onChanged: _setFingerDrawing,
                  ),
                if (!_gestureInkEditingLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SwitchListTile(
                    secondary: const Icon(Icons.backspace_outlined),
                    title: Text(l10n.settingsGestureInkEditing),
                    subtitle: Text(l10n.settingsGestureInkEditingSubtitle),
                    value: _gestureInkEditing,
                    onChanged: _setGestureInkEditing,
                  ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.settingsSectionSpen,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.settingsSpenHint,
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
                      decoration: InputDecoration(
                        labelText: l10n.settingsSpenBarrelAction,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final action in SpenBarrelAction.values)
                          DropdownMenuItem(
                            value: action,
                            child: Text(l10n.spenBarrelActionLabel(action)),
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
                    l10n.settingsSectionOcrDictionary,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.settingsOcrDictionaryHint,
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
                      l10n.settingsNoCustomOcrTerms,
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
                        tooltip: l10n.settingsRemoveOcrTerm,
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
                      label: Text(l10n.settingsAddOcrTerm),
                    ),
                  ),
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.settingsSectionYourData,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.settingsYourDataHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                if (!_yourDataLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.storage_outlined),
                    title: Text(l10n.settingsDatabase),
                    subtitle: SelectableText(
                      '${_yourData!.dbPath}\n'
                      '${YourDataService.formatBytes(_yourData!.dbBytes)}',
                    ),
                  ),
                  for (final name in YourDataService.trackedFolders)
                    ListTile(
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(name),
                      trailing: Text(
                        YourDataService.formatBytes(
                          _yourData!.folderBytes[name] ?? 0,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.settingsSectionBackupRestore,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.settingsBackupRestoreHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: Text(l10n.settingsExportBackup),
                  subtitle: Text(l10n.settingsExportBackupSubtitle),
                  onTap: _export,
                ),
                if (!_autoBackupLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_latestAutoBackup != null)
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: Text(l10n.settingsRecoverFromBackup),
                    subtitle: Text(
                      l10n.settingsLatestAutoBackup(
                        _formatBackupTime(_latestAutoBackup!.createdAt),
                        YourDataService.formatBytes(_latestAutoBackup!.bytes),
                      ),
                    ),
                    onTap: _recoverFromAutoBackup,
                  ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(l10n.settingsRestoreBackup),
                  subtitle: Text(l10n.settingsRestoreBackupSubtitle),
                  onTap: _restore,
                ),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l10n.settingsSectionAbout,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (!_appInfoLoaded)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(AppInfoService.instance.appName),
                    subtitle: Text(
                      '${l10n.settingsVersion(AppInfoService.instance.versionLabel)}\n'
                      '${l10n.settingsAboutSubtitle}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    isThreeLine: true,
                  ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
