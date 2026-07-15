import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stable IDs for reorderable center-toolbar tools (undo/redo excluded).
abstract final class ToolbarToolId {
  static const pen = 'pen';
  static const highlighter = 'highlighter';
  static const eraser = 'eraser';
  static const selection = 'selection';
  static const lasso = 'lasso';
  static const shape = 'shape';
  static const fill = 'fill';
  static const text = 'text';
  static const insertImage = 'insert_image';

  static const defaultOrder = [
    pen,
    highlighter,
    eraser,
    selection,
    lasso,
    shape,
    fill,
    text,
    insertImage,
  ];

  static const labels = {
    pen: 'Pen',
    highlighter: 'Highlighter',
    eraser: 'Eraser',
    selection: 'Selection',
    lasso: 'Lasso',
    shape: 'Shape',
    fill: 'Fill',
    text: 'Text',
    insertImage: 'Insert image',
  };

  static const icons = {
    pen: Icons.edit_rounded,
    highlighter: Icons.brush_rounded,
    eraser: Icons.cleaning_services_rounded,
    selection: Icons.near_me_rounded,
    lasso: Icons.gesture_rounded,
    shape: Icons.interests_rounded,
    fill: Icons.format_color_fill_rounded,
    text: Icons.text_fields_rounded,
    insertImage: Icons.image_outlined,
  };

  static bool isKnown(String id) => defaultOrder.contains(id);
}

/// Persists center-toolbar tool order in SharedPreferences.
class ToolbarOrderService extends ChangeNotifier {
  ToolbarOrderService._();
  static final ToolbarOrderService instance = ToolbarOrderService._();

  static const prefKey = 'toolbar_tool_order';

  List<String> _order = List<String>.from(ToolbarToolId.defaultOrder);
  bool _loaded = false;

  List<String> get order => List.unmodifiable(_order);
  bool get isLoaded => _loaded;

  /// Merges [saved] with [ToolbarToolId.defaultOrder]: keeps saved positions for
  /// known tools, appends any new defaults missing from saved.
  static List<String> normalizeOrder(List<String>? saved) {
    if (saved == null || saved.isEmpty) {
      return List<String>.from(ToolbarToolId.defaultOrder);
    }
    final known = saved.where(ToolbarToolId.isKnown).toList();
    for (final id in ToolbarToolId.defaultOrder) {
      if (!known.contains(id)) known.add(id);
    }
    return known;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _order = normalizeOrder(prefs.getStringList(prefKey));
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveOrder(List<String> newOrder) async {
    final normalized = normalizeOrder(newOrder);
    _order = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(prefKey, normalized);
    notifyListeners();
  }

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _order = List<String>.from(ToolbarToolId.defaultOrder);
    _loaded = false;
  }
}
