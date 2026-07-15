import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import '../services/ink_ocr_service.dart';
import '../services/stroke_eraser.dart';
import 'draw_gesture_shield.dart';
import 'ink_coalesce.dart';
import 'page_coords.dart';
import 'pointer_routing.dart';
import 'painters.dart';
import 'shape_recognizer.dart';
import 'stroke_smoothing.dart';

const _uuid = Uuid();
const _pasteOffsetMm = 100.0; // 10 mm in canonical 0.1 mm units

enum _SelHandle { none, body, nw, ne, sw, se, rotate }

/// In-memory clipboard for lasso copy/paste.
class ClipboardSelection {
  final List<Stroke> strokes;
  final List<PageImage> images;
  final List<TextBlock> textBlocks;

  const ClipboardSelection({
    this.strokes = const [],
    this.images = const [],
    this.textBlocks = const [],
  });

  bool get isEmpty =>
      strokes.isEmpty && images.isEmpty && textBlocks.isEmpty;
}

ClipboardSelection _clipboard = const ClipboardSelection();

/// Tool configuration shared by the toolbar and the canvas.
class ToolState extends ChangeNotifier {
  ToolType tool = ToolType.pen;
  BrushStyle brushStyle = BrushStyle.pen;
  Color penColor = const Color(0xFF1A1A1A);
  Color highlighterColor = const Color(0xFFFFE100);
  Color tapeColor = const Color(0xFFE8E0D0);
  Color fillColor = const Color(0xFF2455C3);
  double penWidth = 3.0;
  double highlighterWidth = 18.0;
  double tapeWidth = 24.0;
  double eraserRadius = 16.0;
  EraserMode eraserMode = EraserMode.partial;

  /// Palm rejection: when true, only stylus input draws. Finger pans/zooms.
  bool stylusOnly = true;

  /// Chaikin smoothing on ink before stroke commit (default on).
  bool strokeSmoothing = true;

  void set(void Function(ToolState) fn) {
    fn(this);
    notifyListeners();
  }

  Color get activeColor => switch (tool) {
        ToolType.highlighter => highlighterColor,
        ToolType.tape => tapeColor,
        ToolType.fill => fillColor,
        _ => penColor,
      };

  double get activeWidth => switch (tool) {
        ToolType.highlighter => highlighterWidth,
        ToolType.tape => tapeWidth,
        _ => penWidth,
      };
}

// ---- Undo/redo actions ----

abstract class _EditAction {
  Future<void> undo(_CanvasController c);
  Future<void> redo(_CanvasController c);
}

class _AddStroke extends _EditAction {
  final Stroke stroke;
  _AddStroke(this.stroke);
  @override
  Future<void> undo(_CanvasController c) => c.removeStrokes([stroke]);
  @override
  Future<void> redo(_CanvasController c) => c.addStroke(stroke);
}

class _ToggleTapeHidden extends _EditAction {
  final String strokeId;
  final bool before;
  final bool after;

  _ToggleTapeHidden(this.strokeId, this.before, this.after);

  @override
  Future<void> undo(_CanvasController c) =>
      c.setTapeHidden(strokeId, before);

  @override
  Future<void> redo(_CanvasController c) =>
      c.setTapeHidden(strokeId, after);
}

class _RemoveStrokes extends _EditAction {
  final List<Stroke> strokes;
  _RemoveStrokes(this.strokes);
  @override
  Future<void> undo(_CanvasController c) async {
    for (final s in strokes) {
      await c.addStroke(s);
    }
  }

  @override
  Future<void> redo(_CanvasController c) => c.removeStrokes(strokes);
}

class _ErasePartial extends _EditAction {
  final List<Stroke> removed;
  final List<Stroke> added;

  _ErasePartial(this.removed, this.added);

  @override
  Future<void> undo(_CanvasController c) async {
    await c.removeStrokes(added);
    for (final s in removed) {
      await c.addStroke(s);
    }
  }

  @override
  Future<void> redo(_CanvasController c) async {
    await c.removeStrokes(removed);
    for (final s in added) {
      await c.addStroke(s);
    }
  }
}

class _MoveStrokes extends _EditAction {
  final List<String> ids;
  final Offset delta;
  _MoveStrokes(this.ids, this.delta);
  @override
  Future<void> undo(_CanvasController c) => c.moveStrokesById(ids, -delta);
  @override
  Future<void> redo(_CanvasController c) => c.moveStrokesById(ids, delta);
}

class _UpdateTextBlock extends _EditAction {
  final String id;
  final String before;
  final String after;
  _UpdateTextBlock(this.id, this.before, this.after);
  @override
  Future<void> undo(_CanvasController c) => c.setTextBlockText(id, before);
  @override
  Future<void> redo(_CanvasController c) => c.setTextBlockText(id, after);
}

class _SelectionSnapshot {
  final Map<String, List<StrokePoint>> strokes;
  final Map<String, Rect> texts;
  final Map<String, double> textFontSizes;
  final Map<String, double> textRotations;
  final String? imageId;
  final Rect? imageRect;
  final double rotation;

  const _SelectionSnapshot({
    this.strokes = const {},
    this.texts = const {},
    this.textFontSizes = const {},
    this.textRotations = const {},
    this.imageId,
    this.imageRect,
    this.rotation = 0,
  });
}

class _TransformSelection extends _EditAction {
  final _SelectionSnapshot before;
  final _SelectionSnapshot after;
  _TransformSelection(this.before, this.after);
  @override
  Future<void> undo(_CanvasController c) => c.applySelectionSnapshot(before);
  @override
  Future<void> redo(_CanvasController c) => c.applySelectionSnapshot(after);
}

class _AddImage extends _EditAction {
  final PageImage image;
  _AddImage(this.image);
  @override
  Future<void> undo(_CanvasController c) => c.removeImage(image.id);
  @override
  Future<void> redo(_CanvasController c) => c.addImage(image.copy());
}

class _RemoveImage extends _EditAction {
  final PageImage image;
  _RemoveImage(this.image);
  @override
  Future<void> undo(_CanvasController c) => c.addImage(image.copy());
  @override
  Future<void> redo(_CanvasController c) => c.removeImage(image.id);
}

class _TransformImage extends _EditAction {
  final String id;
  final Rect before;
  final Rect after;
  _TransformImage(this.id, this.before, this.after);
  @override
  Future<void> undo(_CanvasController c) => c.setImageRect(id, before);
  @override
  Future<void> redo(_CanvasController c) => c.setImageRect(id, after);
}

class _AddFill extends _EditAction {
  final FilledRegion fill;
  _AddFill(this.fill);
  @override
  Future<void> undo(_CanvasController c) => c.removeFill(fill.id);
  @override
  Future<void> redo(_CanvasController c) => c.addFill(fill.copy());
}

class _RemoveFill extends _EditAction {
  final FilledRegion fill;
  _RemoveFill(this.fill);
  @override
  Future<void> undo(_CanvasController c) => c.addFill(fill.copy());
  @override
  Future<void> redo(_CanvasController c) => c.removeFill(fill.id);
}

class _AddTextBlock extends _EditAction {
  final TextBlock block;
  _AddTextBlock(this.block);
  @override
  Future<void> undo(_CanvasController c) => c.removeTextBlock(block.id);
  @override
  Future<void> redo(_CanvasController c) => c.addTextBlock(block.copy());
}

class _RemoveTextBlock extends _EditAction {
  final TextBlock block;
  _RemoveTextBlock(this.block);
  @override
  Future<void> undo(_CanvasController c) => c.addTextBlock(block.copy());
  @override
  Future<void> redo(_CanvasController c) => c.removeTextBlock(block.id);
}

class _PasteAction extends _EditAction {
  final List<Stroke> strokes;
  final List<PageImage> images;
  final List<TextBlock> textBlocks;
  _PasteAction(this.strokes, this.images, this.textBlocks);
  @override
  Future<void> undo(_CanvasController c) async {
    await c.removeStrokes(strokes);
    for (final i in images) {
      await c.removeImage(i.id);
    }
    await c.removeTextBlocks(textBlocks.map((t) => t.id));
  }

  @override
  Future<void> redo(_CanvasController c) async {
    for (final s in strokes) {
      await c.addStroke(s);
    }
    for (final i in images) {
      await c.addImage(i);
    }
    for (final t in textBlocks) {
      await c.addTextBlock(t);
    }
  }
}

class _CanvasController {
  final NotePage page;
  final List<Stroke> strokes;
  final List<PageImage> images;
  final List<FilledRegion> fills;
  final List<TextBlock> textBlocks;
  final VoidCallback onChanged;
  final _db = AppDatabase.instance;
  int _zCounter;

  final List<_EditAction> _undoStack = [];
  final List<_EditAction> _redoStack = [];

  _CanvasController(
    this.page,
    this.strokes,
    this.images,
    this.fills,
    this.textBlocks,
    this.onChanged,
  ) : _zCounter = _maxZ(strokes, images, fills, textBlocks) + 1;

  static int _maxZ(
    List<Stroke> strokes,
    List<PageImage> images,
    List<FilledRegion> fills,
    List<TextBlock> textBlocks,
  ) {
    var z = 0;
    for (final s in strokes) {
      z = math.max(z, s.z);
    }
    for (final i in images) {
      z = math.max(z, i.z);
    }
    for (final f in fills) {
      z = math.max(z, f.z);
    }
    for (final t in textBlocks) {
      z = math.max(z, t.z);
    }
    return z;
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  int nextZ() => _zCounter++;

  Future<void> addStroke(Stroke s) async {
    strokes
      ..add(s)
      ..sort((a, b) => a.z.compareTo(b.z));
    await _db.insertStroke(s);
    onChanged();
  }

  Future<void> removeStrokes(List<Stroke> toRemove) async {
    final ids = toRemove.map((s) => s.id).toSet();
    strokes.removeWhere((s) => ids.contains(s.id));
    await _db.deleteStrokes(ids);
    onChanged();
  }

  Future<void> moveStrokesById(List<String> ids, Offset delta) async {
    for (final s in strokes.where((s) => ids.contains(s.id))) {
      s.translate(delta);
      await _db.updateStrokePoints(s);
    }
    onChanged();
  }

  Future<void> setTapeHidden(String strokeId, bool hidden) async {
    for (final s in strokes) {
      if (s.id == strokeId) {
        s.hidden = hidden;
        await _db.updateStrokeHidden(s);
        break;
      }
    }
    onChanged();
  }

  Future<void> addImage(PageImage img) async {
    images
      ..add(img)
      ..sort((a, b) => a.z.compareTo(b.z));
    await _db.insertImage(img);
    onChanged();
  }

  Future<void> removeImage(String id) async {
    images.removeWhere((i) => i.id == id);
    await _db.deleteImage(id);
    onChanged();
  }

  Future<void> setImageRect(String id, Rect r) async {
    for (final i in images) {
      if (i.id == id) {
        i.rect = r;
        await _db.updateImageRect(i);
        break;
      }
    }
    onChanged();
  }

  Future<void> addFill(FilledRegion f) async {
    fills
      ..add(f)
      ..sort((a, b) => a.z.compareTo(b.z));
    await _db.insertFill(f);
    onChanged();
  }

  Future<void> removeFill(String id) async {
    fills.removeWhere((f) => f.id == id);
    await _db.deleteFill(id);
    onChanged();
  }

  Future<void> addTextBlock(TextBlock t) async {
    textBlocks
      ..add(t)
      ..sort((a, b) => a.z.compareTo(b.z));
    await _db.insertTextBlock(t);
    onChanged();
  }

  Future<void> removeTextBlock(String id) async {
    textBlocks.removeWhere((t) => t.id == id);
    await _db.deleteTextBlock(id);
    onChanged();
  }

  Future<void> removeTextBlocks(Iterable<String> ids) async {
    textBlocks.removeWhere((t) => ids.contains(t.id));
    await _db.deleteTextBlocks(ids);
    onChanged();
  }

  Future<void> setTextBlockText(String id, String text) async {
    for (final t in textBlocks) {
      if (t.id == id) {
        t.text = text;
        await _db.updateTextBlock(t);
        break;
      }
    }
    onChanged();
  }

  _SelectionSnapshot captureSelectionSnapshot({
    required Set<String> strokeIds,
    required Set<String> textIds,
    String? imageId,
    required List<Stroke> strokes,
    required List<TextBlock> texts,
    required List<PageImage> images,
    required double rotation,
  }) {
    final strokeMap = <String, List<StrokePoint>>{};
    for (final s in strokes.where((s) => strokeIds.contains(s.id))) {
      strokeMap[s.id] =
          s.points.map((p) => StrokePoint(p.x, p.y, p.p)).toList();
    }
    final textMap = <String, Rect>{};
    final fontMap = <String, double>{};
    final rotationMap = <String, double>{};
    for (final t in texts.where((t) => textIds.contains(t.id))) {
      textMap[t.id] = t.rect;
      fontMap[t.id] = t.fontSize;
      rotationMap[t.id] = t.rotation;
    }
    Rect? imgRect;
    if (imageId != null) {
      for (final i in images) {
        if (i.id == imageId) {
          imgRect = i.rect;
          break;
        }
      }
    }
    return _SelectionSnapshot(
      strokes: strokeMap,
      texts: textMap,
      textFontSizes: fontMap,
      textRotations: rotationMap,
      imageId: imageId,
      imageRect: imgRect,
      rotation: rotation,
    );
  }

  Future<void> applySelectionSnapshot(_SelectionSnapshot snap) async {
    for (final s in strokes) {
      final pts = snap.strokes[s.id];
      if (pts != null) {
        s.points
          ..clear()
          ..addAll(pts);
        await _db.updateStrokePoints(s);
      }
    }
    for (final t in textBlocks) {
      final r = snap.texts[t.id];
      if (r != null) {
        t.x = r.left;
        t.y = r.top;
        t.w = r.width;
        t.h = r.height;
        final fs = snap.textFontSizes[t.id];
        if (fs != null) t.fontSize = fs;
        final rot = snap.textRotations[t.id];
        if (rot != null) t.rotation = rot;
        await _db.updateTextBlock(t);
      }
    }
    if (snap.imageId != null && snap.imageRect != null) {
      for (final i in images) {
        if (i.id == snap.imageId) {
          i.rect = snap.imageRect!;
          await _db.updateImageRect(i);
          break;
        }
      }
    }
    onChanged();
  }

  void commit(_EditAction a) {
    _undoStack.add(a);
    if (_undoStack.length > 100) _undoStack.removeAt(0);
    _redoStack.clear();
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    final a = _undoStack.removeLast();
    await a.undo(this);
    _redoStack.add(a);
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final a = _redoStack.removeLast();
    await a.redo(this);
    _undoStack.add(a);
  }
}

/// One drawable page. Handles pointer input, palm rejection, all tools.
class DrawingCanvas extends StatefulWidget {
  final NotePage page;
  final ToolState toolState;
  final Size displaySize;
  final PageSize pageSize;
  final ui.Image? pdfImage;
  final void Function(bool canUndo, bool canRedo)? onHistoryChanged;
  final void Function(bool hasSelection)? onSelectionChanged;

  const DrawingCanvas({
    super.key,
    required this.page,
    required this.toolState,
    required this.displaySize,
    required this.pageSize,
    this.pdfImage,
    this.onHistoryChanged,
    this.onSelectionChanged,
  });

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<Stroke> _strokes = [];
  final List<PageImage> _images = [];
  final List<FilledRegion> _fills = [];
  final List<TextBlock> _textBlocks = [];
  final Map<String, ui.Image> _decodedImages = {};
  late _CanvasController _controller;
  bool _loaded = false;
  int _revision = 0;

  String? _selectedImageId;
  bool _draggingImage = false;
  bool _resizingImage = false;
  Rect? _imageRectAtGestureStart;

  Stroke? _current;
  DateTime? _lastInkMoveTime;
  Offset? _lastInkMoveCanon;
  int? _activePointer;
  List<Offset>? _lassoPath;
  List<Offset>? _fillPath;

  final List<Stroke> _erasedThisPass = [];
  final Map<String, Stroke> _partialEraseOriginals = {};
  final Map<String, String> _partialSegmentToRoot = {};
  final Set<String> _partialEraseAddedIds = {};

  final Set<String> _selectedIds = {};
  final Set<String> _selectedFillIds = {};
  final Set<String> _selectedTextIds = {};
  Rect? _selectionBounds;
  Offset _dragAccum = Offset.zero;
  Offset? _lastDragPos;

  DateTime _lastStylusSeen = DateTime.fromMillisecondsSinceEpoch(0);
  bool _stylusActive = false;

  TextEditingController? _textEditCtrl;
  Offset? _textEditPos;
  String? _editingTextId;

  Rect? _marqueeRect;
  Offset? _marqueeStart;
  _SelHandle _activeHandle = _SelHandle.none;
  double _selectionRotation = 0;
  Offset? _transformPivot;
  double _transformStartAngle = 0;
  double _transformStartDist = 1;
  _SelectionSnapshot? _transformBefore;

  PageSize get _pageSize {
    final hasPdf = widget.page.pdfImagePath != null ||
        widget.page.pdfSourcePath != null;
    if (hasPdf) {
      return PageSize.values.firstWhere(
        (ps) => (ps.aspect - widget.page.aspect).abs() < 0.01,
        orElse: () => widget.page.pageSize,
      );
    }
    return widget.page.pageSize;
  }

  PageOrientation get _orientation {
    final hasPdf = widget.page.pdfImagePath != null ||
        widget.page.pdfSourcePath != null;
    return hasPdf ? PageOrientation.portrait : widget.page.orientation;
  }

  Size get _canonicalSize =>
      PageCoords.canonicalSize(_pageSize, orientation: _orientation);

  Offset _toCanonical(Offset display) => PageCoords.displayToCanonical(
        display,
        widget.displaySize,
        _pageSize,
        orientation: _orientation,
      );

  double _toCanonicalLen(double display) =>
      PageCoords.displayToCanonicalLength(
        display,
        widget.displaySize,
        _pageSize,
        orientation: _orientation,
      );

  Offset _toDisplay(Offset canonical) => PageCoords.canonicalToDisplay(
        canonical,
        widget.displaySize,
        _pageSize,
        orientation: _orientation,
      );

  @override
  void initState() {
    super.initState();
    _controller = _CanvasController(
        widget.page, _strokes, _images, _fills, _textBlocks, _bump);
    _load();
    widget.toolState.addListener(_onToolChanged);
  }

  @override
  void didUpdateWidget(covariant DrawingCanvas old) {
    super.didUpdateWidget(old);
    if (old.page.id != widget.page.id) {
      _loaded = false;
      _current = null;
      _activePointer = null;
      _lassoPath = null;
      _fillPath = null;
      _clearSelection();
      _dismissTextEditor();
      _load();
    }
  }

  @override
  void dispose() {
    widget.toolState.removeListener(_onToolChanged);
    _textEditCtrl?.dispose();
    super.dispose();
  }

  void _onToolChanged() {
    final tool = widget.toolState.tool;
    if (tool != ToolType.lasso &&
        tool != ToolType.selection &&
        hasSelection) {
      _clearSelection();
    }
    if (tool != ToolType.text) {
      _commitTextEditIfNeeded();
    }
    _bump();
  }

  Future<void> _load() async {
    final db = AppDatabase.instance;
    final rows = await db.strokesOf(widget.page.id);
    final imgs = await db.imagesOf(widget.page.id);
    final fills = await db.fillsOf(widget.page.id);
    final texts = await db.textBlocksOf(widget.page.id);
    _strokes
      ..clear()
      ..addAll(rows);
    _images
      ..clear()
      ..addAll(imgs);
    _fills
      ..clear()
      ..addAll(fills);
    _textBlocks
      ..clear()
      ..addAll(texts);
    for (final img in _images) {
      await _decode(img.path);
    }
    _controller = _CanvasController(
        widget.page, _strokes, _images, _fills, _textBlocks, _bump);
    _loaded = true;
    _bump();
  }

  Future<ui.Image?> _decode(String path) async {
    if (_decodedImages.containsKey(path)) return _decodedImages[path];
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _decodedImages[path] = frame.image;
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  Future<void> addImageFromPath(String path) async {
    final decoded = await _decode(path);
    if (decoded == null) return;
    final aspect = decoded.width / decoded.height;
    final w = _canonicalSize.width * 0.45;
    final h = w / aspect;
    final img = PageImage(
      id: _uuid.v4(),
      pageId: widget.page.id,
      path: path,
      x: (_canonicalSize.width - w) / 2,
      y: (_canonicalSize.height - h) / 2,
      w: w,
      h: h,
      z: _controller.nextZ(),
    );
    await _controller.addImage(img);
    _controller.commit(_AddImage(img.copy()));
    widget.toolState.set((s) => s.tool = ToolType.lasso);
    _selectedImageId = img.id;
    _notifySelection();
    _bump();
  }

  void _bump() {
    if (!mounted) return;
    setState(() => _revision++);
    widget.onHistoryChanged?.call(_controller.canUndo, _controller.canRedo);
  }

  Future<void> undo() async {
    await _controller.undo();
    _clearSelection();
  }

  Future<void> redo() async {
    await _controller.redo();
    _clearSelection();
  }

  Future<void> deleteSelection() async {
    if (_selectedImageId != null) {
      PageImage? img;
      for (final i in _images) {
        if (i.id == _selectedImageId) {
          img = i;
          break;
        }
      }
      if (img != null) {
        final snapshot = img.copy();
        await _controller.removeImage(img.id);
        _controller.commit(_RemoveImage(snapshot));
      }
      _clearSelection();
      return;
    }
    if (_selectedIds.isEmpty &&
        _selectedFillIds.isEmpty &&
        _selectedTextIds.isEmpty) {
      return;
    }
    final doomedStrokes = _strokes
        .where((s) => _selectedIds.contains(s.id))
        .map((s) => s.copy())
        .toList();
    final doomedFills = _fills
        .where((f) => _selectedFillIds.contains(f.id))
        .map((f) => f.copy())
        .toList();
    final doomedTexts = _textBlocks
        .where((t) => _selectedTextIds.contains(t.id))
        .map((t) => t.copy())
        .toList();
    await _controller.removeStrokes(
        _strokes.where((s) => _selectedIds.contains(s.id)).toList());
    for (final f in _fills.where((f) => _selectedFillIds.contains(f.id))) {
      await _controller.removeFill(f.id);
    }
    await _controller.removeTextBlocks(_selectedTextIds);
    if (doomedStrokes.isNotEmpty) {
      _controller.commit(_RemoveStrokes(doomedStrokes));
    }
    for (final f in doomedFills) {
      _controller.commit(_RemoveFill(f));
    }
    for (final t in doomedTexts) {
      _controller.commit(_RemoveTextBlock(t));
    }
    _clearSelection();
  }

  void copySelection() {
    if (!hasSelection) return;
    final strokes = _strokes
        .where((s) => _selectedIds.contains(s.id))
        .map((s) => s.copy())
        .toList();
    final images = <PageImage>[];
    if (_selectedImageId != null) {
      for (final i in _images) {
        if (i.id == _selectedImageId) {
          images.add(i.copy());
          break;
        }
      }
    }
    final texts = _textBlocks
        .where((t) => _selectedTextIds.contains(t.id))
        .map((t) => t.copy())
        .toList();
    _clipboard = ClipboardSelection(
        strokes: strokes, images: images, textBlocks: texts);
  }

  Future<void> pasteClipboard() async {
    if (_clipboard.isEmpty) return;
    const offset = Offset(_pasteOffsetMm, _pasteOffsetMm);
    final newStrokes = <Stroke>[];
    final newImages = <PageImage>[];
    final newTexts = <TextBlock>[];

    for (final s in _clipboard.strokes) {
      final copy = Stroke(
        id: _uuid.v4(),
        pageId: widget.page.id,
        tool: s.tool,
        brushStyle: s.brushStyle,
        color: s.color,
        width: s.width,
        points: s.points.map((p) => p.translated(offset)).toList(),
        z: _controller.nextZ(),
      );
      newStrokes.add(copy);
      await _controller.addStroke(copy);
    }
    for (final i in _clipboard.images) {
      final copy = PageImage(
        id: _uuid.v4(),
        pageId: widget.page.id,
        path: i.path,
        x: i.x + offset.dx,
        y: i.y + offset.dy,
        w: i.w,
        h: i.h,
        z: _controller.nextZ(),
      );
      newImages.add(copy);
      await _controller.addImage(copy);
    }
    for (final t in _clipboard.textBlocks) {
      final copy = TextBlock(
        id: _uuid.v4(),
        pageId: widget.page.id,
        x: t.x + offset.dx,
        y: t.y + offset.dy,
        w: t.w,
        h: t.h,
        text: t.text,
        fontSize: t.fontSize,
        color: t.color,
        z: _controller.nextZ(),
        isNote: t.isNote,
        rotation: t.rotation,
      );
      newTexts.add(copy);
      await _controller.addTextBlock(copy);
    }
    _controller.commit(_PasteAction(newStrokes, newImages, newTexts));
    _clearSelection();
    for (final s in newStrokes) {
      _selectedIds.add(s.id);
    }
    for (final t in newTexts) {
      _selectedTextIds.add(t.id);
    }
    if (newImages.isNotEmpty) _selectedImageId = newImages.first.id;
    _recomputeSelectionBounds();
    _notifySelection();
    _bump();
  }

  bool get hasSelection =>
      _selectedIds.isNotEmpty ||
      _selectedImageId != null ||
      _selectedFillIds.isNotEmpty ||
      _selectedTextIds.isNotEmpty;

  bool get canPaste => !_clipboard.isEmpty;

  void _notifySelection() =>
      widget.onSelectionChanged?.call(hasSelection);

  void _clearSelection() {
    _selectedIds.clear();
    _selectedFillIds.clear();
    _selectedTextIds.clear();
    _selectionBounds = null;
    _selectionRotation = 0;
    _dragAccum = Offset.zero;
    _selectedImageId = null;
    _draggingImage = false;
    _resizingImage = false;
    _imageRectAtGestureStart = null;
    _marqueeRect = null;
    _marqueeStart = null;
    _activeHandle = _SelHandle.none;
    _transformBefore = null;
    _notifySelection();
    _bump();
  }

  void _recomputeSelectionBounds() {
    Rect? bounds;
    for (final s in _strokes.where((s) => _selectedIds.contains(s.id))) {
      bounds = bounds == null ? s.bounds : bounds.expandToInclude(s.bounds);
    }
    for (final t in _textBlocks.where((t) => _selectedTextIds.contains(t.id))) {
      final textOnly = _selectedTextIds.length == 1 &&
          _selectedIds.isEmpty &&
          _selectedImageId == null;
      final b = textOnly ? t.rect : t.axisAlignedBounds;
      bounds = bounds == null ? b : bounds.expandToInclude(b);
    }
    if (_selectedImageId != null) {
      for (final img in _images) {
        if (img.id == _selectedImageId) {
          bounds =
              bounds == null ? img.rect : bounds.expandToInclude(img.rect);
          break;
        }
      }
    }
    _selectionBounds = bounds;
    if (_selectedTextIds.length == 1 &&
        _selectedIds.isEmpty &&
        _selectedImageId == null) {
      for (final t in _textBlocks) {
        if (_selectedTextIds.contains(t.id)) {
          _selectionRotation = t.rotation;
          break;
        }
      }
    }
  }

  bool _isStylus(PointerEvent e) =>
      e.kind == PointerDeviceKind.stylus ||
      e.kind == PointerDeviceKind.invertedStylus;

  bool _mayDraw(PointerEvent e) {
    final tool = widget.toolState.tool;
    final manipulatesWithFinger = tool == ToolType.selection ||
        tool == ToolType.lasso ||
        tool == ToolType.text ||
        tool == ToolType.tape;
    if (manipulatesWithFinger &&
        e.kind == PointerDeviceKind.touch &&
        (Offset.zero & widget.displaySize).contains(e.localPosition)) {
      return true;
    }
    return shouldRouteToDrawing(
      kind: e.kind,
      localPos: e.localPosition,
      paperSize: widget.displaySize,
      stylusOnly: widget.toolState.stylusOnly,
      stylusActive: _stylusActive,
    );
  }

  double _pressure(PointerEvent e) {
    if (e.pressureMax == e.pressureMin) return 0.6;
    final p =
        (e.pressure - e.pressureMin) / (e.pressureMax - e.pressureMin);
    return p.clamp(0.05, 1.0);
  }

  void _onPointerHover(PointerHoverEvent e) {
    if (_isStylus(e)) {
      _lastStylusSeen = DateTime.now();
      _stylusActive = true;
    }
  }

  void _onPointerDown(PointerDownEvent e) {
    if (_isStylus(e)) {
      _lastStylusSeen = DateTime.now();
      _stylusActive = true;
    }
    if (_activePointer != null) return;
    if (!_mayDraw(e)) return;
    if (!_loaded) return;

    final tool = widget.toolState.tool;
    final pos = e.localPosition;
    final cPos = _toCanonical(pos);
    _activePointer = e.pointer;

    final effectiveTool =
        e.kind == PointerDeviceKind.invertedStylus ? ToolType.eraser : tool;

    switch (effectiveTool) {
      case ToolType.pen:
      case ToolType.highlighter:
      case ToolType.shape:
        _current = Stroke(
          id: _uuid.v4(),
          pageId: widget.page.id,
          tool: effectiveTool == ToolType.highlighter
              ? ToolType.highlighter
              : ToolType.pen,
          brushStyle: widget.toolState.brushStyle,
          color: widget.toolState.activeColor.value,
          width: _toCanonicalLen(widget.toolState.activeWidth),
          points: [StrokePoint(cPos.dx, cPos.dy, _pressure(e))],
          z: _controller.nextZ(),
        );
        _lastInkMoveTime = DateTime.now();
        _lastInkMoveCanon = cPos;
        _bump();
      case ToolType.tape:
        final hitTape = _hitTapeStrokeAt(pos);
        if (hitTape != null) {
          _activePointer = null;
          unawaited(_toggleTapeHidden(hitTape));
          return;
        }
        _current = Stroke(
          id: _uuid.v4(),
          pageId: widget.page.id,
          tool: ToolType.tape,
          color: widget.toolState.tapeColor.value,
          width: _toCanonicalLen(widget.toolState.tapeWidth),
          points: [StrokePoint(cPos.dx, cPos.dy, _pressure(e))],
          z: _controller.nextZ(),
        );
        _lastInkMoveTime = DateTime.now();
        _lastInkMoveCanon = cPos;
        _bump();
      case ToolType.fill:
        _fillPath = [pos];
        _bump();
      case ToolType.text:
        final existing = _hitTextBlock(pos);
        if (existing != null) {
          _startTextEdit(existing: existing);
        } else {
          _startTextEdit(canonicalPos: cPos);
        }
        _activePointer = null;
        return;
      case ToolType.eraser:
        _erasedThisPass.clear();
        _partialEraseOriginals.clear();
        _partialSegmentToRoot.clear();
        _partialEraseAddedIds.clear();
        _eraseAt(cPos);
      case ToolType.lasso:
        final selImg = _selectedImage();
        final displayRect = selImg != null
            ? PageCoords.canonicalRectToDisplay(
                selImg.rect, widget.displaySize, _pageSize,
                orientation: _orientation)
            : null;
        if (displayRect != null &&
            (displayRect.bottomRight - pos).distance < 22) {
          _resizingImage = true;
          _imageRectAtGestureStart = selImg!.rect;
          _lastDragPos = pos;
          break;
        }
        if (displayRect != null && displayRect.inflate(4).contains(pos)) {
          _draggingImage = true;
          _imageRectAtGestureStart = selImg!.rect;
          _lastDragPos = pos;
          break;
        }
        if (_selectionBounds != null && hasSelection) {
          final handle = _hitSelectionHandle(pos);
          if (handle != _SelHandle.none) {
            _activeHandle = handle;
            _transformBefore = _captureSelectionSnapshot();
            final displayBounds = PageCoords.canonicalRectToDisplay(
                _selectionBounds!, widget.displaySize, _pageSize,
                orientation: _orientation);
            final inflated = displayBounds.inflate(6);
            _transformPivot = _toCanonical(inflated.center);
            if (handle == _SelHandle.rotate) {
              _transformStartAngle = math.atan2(
                  pos.dy - inflated.center.dy, pos.dx - inflated.center.dx);
            } else if (handle == _SelHandle.nw ||
                handle == _SelHandle.ne ||
                handle == _SelHandle.sw ||
                handle == _SelHandle.se) {
              _transformStartDist = (pos - inflated.center)
                  .distance
                  .clamp(1.0, double.infinity);
            }
            _lastDragPos = pos;
            if (handle == _SelHandle.body) _dragAccum = Offset.zero;
            break;
          }
        }
        PageImage? hit;
        for (final img in _images.reversed) {
          final r = PageCoords.canonicalRectToDisplay(
              img.rect, widget.displaySize, _pageSize,
              orientation: _orientation);
          if (r.contains(pos)) {
            hit = img;
            break;
          }
        }
        if (hit != null) {
          _clearSelection();
          _selectedImageId = hit.id;
          _notifySelection();
          _bump();
          break;
        }
        _clearSelection();
        _lassoPath = [pos];
        _bump();
      case ToolType.selection:
        _handleSelectionDown(pos);
    }
  }

  void _handleSelectionDown(Offset pos) {
    final handle = _hitSelectionHandle(pos);
    if (handle != _SelHandle.none && hasSelection) {
      _activeHandle = handle;
      _transformBefore = _captureSelectionSnapshot();
      final displayBounds = PageCoords.canonicalRectToDisplay(
          _selectionBounds!, widget.displaySize, _pageSize,
          orientation: _orientation);
      final inflated = displayBounds.inflate(6);
      _transformPivot = _toCanonical(inflated.center);
      if (handle == _SelHandle.rotate) {
        _transformStartAngle =
            math.atan2(pos.dy - inflated.center.dy, pos.dx - inflated.center.dx);
      } else if (handle == _SelHandle.nw ||
          handle == _SelHandle.ne ||
          handle == _SelHandle.sw ||
          handle == _SelHandle.se) {
        _transformStartDist =
            (pos - inflated.center).distance.clamp(1.0, double.infinity);
      }
      _lastDragPos = pos;
      return;
    }

    final hitStroke = _hitStrokeAt(pos);
    if (hitStroke != null) {
      _selectStroke(hitStroke);
      _activeHandle = _SelHandle.body;
      _transformBefore = _captureSelectionSnapshot();
      _lastDragPos = pos;
      _dragAccum = Offset.zero;
      return;
    }

    final hitText = _hitTextBlock(pos);
    if (hitText != null) {
      _selectText(hitText);
      _activeHandle = _SelHandle.body;
      _transformBefore = _captureSelectionSnapshot();
      _lastDragPos = pos;
      _dragAccum = Offset.zero;
      return;
    }

    PageImage? hitImg;
    for (final img in _images.reversed) {
      final r = PageCoords.canonicalRectToDisplay(
          img.rect, widget.displaySize, _pageSize,
          orientation: _orientation);
      if (r.contains(pos)) {
        hitImg = img;
        break;
      }
    }
    if (hitImg != null) {
      _clearSelection();
      _selectedImageId = hitImg.id;
      _selectionBounds = hitImg.rect;
      _notifySelection();
      _activeHandle = _SelHandle.body;
      _transformBefore = _captureSelectionSnapshot();
      _lastDragPos = pos;
      _bump();
      return;
    }

    _clearSelection();
    _marqueeStart = pos;
    _marqueeRect = Rect.fromLTWH(pos.dx, pos.dy, 0, 0);
    _bump();
  }

  void _startTextEdit({Offset? canonicalPos, TextBlock? existing}) {
    _dismissTextEditor(commit: false);
    if (existing != null) {
      _editingTextId = existing.id;
      _textEditPos = Offset(existing.x, existing.y);
      _textEditCtrl = TextEditingController(text: existing.text);
    } else if (canonicalPos != null) {
      _editingTextId = null;
      _textEditPos = canonicalPos;
      _textEditCtrl = TextEditingController();
    }
    _bump();
  }

  Future<void> _commitTextEditIfNeeded() async {
    if (_textEditCtrl == null) return;
    await _commitTextEdit();
  }

  Future<void> _commitTextEdit() async {
    final ctrl = _textEditCtrl;
    final pos = _textEditPos;
    if (ctrl == null || pos == null) return;
    final text = ctrl.text.trim();
    if (text.isEmpty) {
      _dismissTextEditor(commit: false);
      return;
    }
    final fontSize = _defaultTextFontSize();
    final measured = _measureTextBlock(text, fontSize);
    final editId = _editingTextId;
    if (editId != null) {
      for (final block in _textBlocks) {
        if (block.id == editId) {
          final before = block.text;
          block.text = text;
          block.w = measured.width;
          block.h = measured.height;
          if (before != text) {
            await _controller.setTextBlockText(editId, text);
            await AppDatabase.instance.updateTextBlock(block);
            _controller.commit(_UpdateTextBlock(editId, before, text));
          }
          break;
        }
      }
    } else {
      final block = TextBlock(
        id: _uuid.v4(),
        pageId: widget.page.id,
        x: pos.dx,
        y: pos.dy,
        w: measured.width,
        h: measured.height,
        text: text,
        fontSize: fontSize,
        color: widget.toolState.penColor.value,
        z: _controller.nextZ(),
      );
      await _controller.addTextBlock(block);
      _controller.commit(_AddTextBlock(block.copy()));
    }
    _dismissTextEditor(commit: false);
    _bump();
  }

  double _defaultTextFontSize() => _canonicalSize.width * 0.024;

  Size _measureTextBlock(String text, double fontSize) {
    final displayFont = PageCoords.canonicalToDisplayLength(
        fontSize, widget.displaySize, _pageSize,
        orientation: _orientation);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: displayFont,
          height: 1.25,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: widget.displaySize.width * 0.85);
    final pad = _toCanonicalLen(12);
    return Size(
      math.max(_toCanonicalLen(40), tp.size.width + pad),
      math.max(_toCanonicalLen(24), tp.size.height + pad),
    );
  }

  void _dismissTextEditor({bool commit = true}) {
    if (commit && _textEditCtrl != null) {
      unawaited(_commitTextEdit());
      return;
    }
    _textEditCtrl?.dispose();
    _textEditCtrl = null;
    _textEditPos = null;
    _editingTextId = null;
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (e.pointer != _activePointer) return;
    if (_isStylus(e)) _lastStylusSeen = DateTime.now();
    final pos = e.localPosition;
    final cPos = _toCanonical(pos);
    final tool = widget.toolState.tool;

    if (_current != null) {
      final last = _current!.points.last;
      final now = DateTime.now();
      final speed = _lastInkMoveCanon != null && _lastInkMoveTime != null
          ? inkSpeedCanonicalPerSec(
              _lastInkMoveCanon!, cPos, now.difference(_lastInkMoveTime!))
          : 0.0;
      if (!shouldAcceptInkPoint(
        last: last,
        newCanonical: cPos,
        speedCanonicalPerSec: speed,
      )) {
        return;
      }
      _lastInkMoveTime = now;
      _lastInkMoveCanon = cPos;
      _current!.points.add(StrokePoint(cPos.dx, cPos.dy, _pressure(e)));
      _bump();
      return;
    }

    switch (tool) {
      case ToolType.fill:
        if (_fillPath != null) {
          _fillPath!.add(pos);
          _bump();
        }
      case ToolType.eraser:
        _eraseAt(cPos);
      case ToolType.lasso:
        final selImg = _selectedImage();
        if (_resizingImage && selImg != null && _lastDragPos != null) {
          final displayRect = PageCoords.canonicalRectToDisplay(
              selImg.rect, widget.displaySize, _pageSize,
              orientation: _orientation);
          final aspect = selImg.w / selImg.h;
          final newW = math.max(
              _toCanonicalLen(40),
              _toCanonicalLen(pos.dx - displayRect.left));
          selImg.rect = Rect.fromLTWH(selImg.x, selImg.y, newW, newW / aspect);
          _lastDragPos = pos;
          _bump();
        } else if (_draggingImage && selImg != null && _lastDragPos != null) {
          final delta = _toCanonical(pos - _lastDragPos!);
          _lastDragPos = pos;
          selImg.rect = selImg.rect.shift(delta);
          _bump();
        } else if (_activeHandle != _SelHandle.none) {
          _handleSelectionMove(pos);
        } else if (_lassoPath != null) {
          _lassoPath!.add(pos);
          _bump();
        }
      case ToolType.selection:
        _handleSelectionMove(pos);
      default:
        break;
    }
  }

  void _handleSelectionMove(Offset pos) {
    if (_marqueeStart != null) {
      final start = _marqueeStart!;
      _marqueeRect = Rect.fromPoints(start, pos);
      _bump();
      return;
    }
    if (_activeHandle == _SelHandle.none || _lastDragPos == null) return;

    if (_activeHandle == _SelHandle.body) {
      final delta = _toCanonical(pos - _lastDragPos!);
      _lastDragPos = pos;
      _dragAccum += delta;
      for (final s in _strokes.where((s) => _selectedIds.contains(s.id))) {
        s.translate(delta);
      }
      for (final t in _textBlocks.where((t) => _selectedTextIds.contains(t.id))) {
        t.x += delta.dx;
        t.y += delta.dy;
      }
      final selImg = _selectedImage();
      if (selImg != null) {
        selImg.rect = selImg.rect.shift(delta);
      }
      _selectionBounds = _selectionBounds?.shift(delta);
      _bump();
      return;
    }

    if (_selectionBounds == null || _transformPivot == null) return;
    final displayBounds = PageCoords.canonicalRectToDisplay(
        _selectionBounds!, widget.displaySize, _pageSize,
        orientation: _orientation);
    final center = displayBounds.inflate(6).center;

    if (_activeHandle == _SelHandle.rotate) {
      final angle =
          math.atan2(pos.dy - center.dy, pos.dx - center.dx) - _transformStartAngle;
      _applyRotation(angle);
      _bump();
      return;
    }

    final dist = (pos - center).distance.clamp(1.0, double.infinity);
    final scale = dist / _transformStartDist;
    _applyScale(scale);
    _bump();
  }

  Future<void> _onPointerUp(PointerEvent e) async {
    if (e.pointer != _activePointer) return;
    _activePointer = null;
    if (!_isStylus(e)) {
      _stylusActive = DateTime.now().difference(_lastStylusSeen) <
          const Duration(milliseconds: 300);
    }

    final tool = widget.toolState.tool;

    if (_current != null) {
      var stroke = _current!;
      _current = null;

      stroke.points = maybeSmoothStrokePoints(
        stroke.points,
        enabled: widget.toolState.strokeSmoothing,
      );

      if (tool == ToolType.shape) {
        final snapped = ShapeRecognizer.recognize(stroke.points);
        if (snapped != null) stroke.points = snapped;
      }

      await _controller.addStroke(stroke);
      _controller.commit(_AddStroke(stroke.copy()));
      if (stroke.tool != ToolType.tape) {
        unawaited(InkOcrService.instance.enqueueStroke(stroke));
      }
      _bump();
      return;
    }

    if (tool == ToolType.fill && _fillPath != null) {
      final path = _fillPath!;
      _fillPath = null;
      if (path.length >= 2) {
        final totalLen = _polylineLength(path);
        final closed =
            path.length >= 3 && (path.first - path.last).distance < 30;
        if (totalLen < 24 && path.length <= 3) {
          await _fillAtTap(path.first);
        } else if (closed) {
          await _commitFill(path);
        }
      }
      _bump();
      return;
    }

    if (tool == ToolType.eraser) {
      if (_partialEraseOriginals.isNotEmpty) {
        final added = _strokes
            .where((s) => _partialEraseAddedIds.contains(s.id))
            .map((s) => s.copy())
            .toList();
        _controller.commit(_ErasePartial(
          _partialEraseOriginals.values.map((s) => s.copy()).toList(),
          added,
        ));
        _partialEraseOriginals.clear();
        _partialSegmentToRoot.clear();
        _partialEraseAddedIds.clear();
        widget.onHistoryChanged
            ?.call(_controller.canUndo, _controller.canRedo);
        return;
      }
      if (_erasedThisPass.isNotEmpty) {
        _controller.commit(_RemoveStrokes(List.of(_erasedThisPass)));
        _erasedThisPass.clear();
        widget.onHistoryChanged
            ?.call(_controller.canUndo, _controller.canRedo);
        return;
      }
    }

    if (tool == ToolType.lasso) {
      if (_draggingImage || _resizingImage) {
        final selImg = _selectedImage();
        if (selImg != null && _imageRectAtGestureStart != null) {
          final before = _imageRectAtGestureStart!;
          final after = selImg.rect;
          if (before != after) {
            await AppDatabase.instance.updateImageRect(selImg);
            _controller.commit(_TransformImage(selImg.id, before, after));
            widget.onHistoryChanged
                ?.call(_controller.canUndo, _controller.canRedo);
          }
        }
        _draggingImage = false;
        _resizingImage = false;
        _imageRectAtGestureStart = null;
        return;
      }
      if (_activeHandle != _SelHandle.none) {
        await _finishSelectionTransform();
        _activeHandle = _SelHandle.none;
        _transformBefore = null;
        _lastDragPos = null;
        _dragAccum = Offset.zero;
      } else if (_lassoPath != null && _lassoPath!.length > 2) {
        _selectFromLasso(_lassoPath!);
        _lassoPath = null;
        _notifySelection();
        _bump();
      } else {
        _lassoPath = null;
        _bump();
      }
      return;
    }

    if (tool == ToolType.selection) {
      if (_marqueeRect != null) {
        if (_marqueeRect!.width.abs() > 4 ||
            _marqueeRect!.height.abs() > 4) {
          _selectFromMarquee(_marqueeRect!);
        }
        _marqueeRect = null;
        _marqueeStart = null;
        _notifySelection();
        _bump();
        return;
      }
      if (_activeHandle != _SelHandle.none) {
        await _finishSelectionTransform();
        _activeHandle = _SelHandle.none;
        _transformBefore = null;
        _lastDragPos = null;
        _dragAccum = Offset.zero;
      }
    }
  }

  double _polylineLength(List<Offset> path) {
    var len = 0.0;
    for (var i = 1; i < path.length; i++) {
      len += (path[i] - path[i - 1]).distance;
    }
    return len;
  }

  Future<void> _fillAtTap(Offset displayPos) async {
    final cPos = _toCanonical(displayPos);
    final polygon = _findClosedRegionAt(cPos);
    if (polygon == null) return;
    final pathJson =
        jsonEncode(polygon.map((o) => [o.dx, o.dy]).toList());
    final fill = FilledRegion(
      id: _uuid.v4(),
      pageId: widget.page.id,
      color: widget.toolState.fillColor.value,
      pathJson: pathJson,
      z: _controller.nextZ(),
    );
    await _controller.addFill(fill);
    _controller.commit(_AddFill(fill.copy()));
    _bump();
  }

  /// Finds the innermost closed ink loop containing [canonicalPos].
  List<Offset>? _findClosedRegionAt(Offset canonicalPos) {
    for (final s in _strokes.reversed) {
      if (s.tool != ToolType.pen && s.tool != ToolType.shape) continue;
      final poly = _closedPolygonFromStroke(s);
      if (poly == null || poly.length < 3) continue;
      if (_pointInCanonicalPolygon(canonicalPos, poly)) return poly;
    }
    return null;
  }

  List<Offset>? _closedPolygonFromStroke(Stroke s) {
    final pts = s.points;
    if (pts.length < 3) return null;
    final displayClose = _toCanonicalLen(30);
    final first = Offset(pts.first.x, pts.first.y);
    final last = Offset(pts.last.x, pts.last.y);
    final closed = (first - last).distance <= displayClose;
    if (!closed && s.tool != ToolType.shape) return null;
    return pts.map((p) => Offset(p.x, p.y)).toList();
  }

  bool _pointInCanonicalPolygon(Offset p, List<Offset> poly) {
    var inside = false;
    for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final pi = poly[i], pj = poly[j];
      if ((pi.dy > p.dy) != (pj.dy > p.dy) &&
          p.dx <
              (pj.dx - pi.dx) * (p.dy - pi.dy) / (pj.dy - pi.dy) + pi.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  Future<void> _commitFill(List<Offset> displayPath) async {
    if (displayPath.length < 3) return;
    final first = displayPath.first;
    final last = displayPath.last;
    if ((first - last).distance > 30) return;

    final canonical = displayPath.map(_toCanonical).toList();
    final pathJson = jsonEncode(
        canonical.map((o) => [o.dx, o.dy]).toList());
    final fill = FilledRegion(
      id: _uuid.v4(),
      pageId: widget.page.id,
      color: widget.toolState.fillColor.value,
      pathJson: pathJson,
      z: _controller.nextZ(),
    );
    await _controller.addFill(fill);
    _controller.commit(_AddFill(fill.copy()));
    _bump();
  }

  void _eraseAt(Offset canonicalPos) {
    if (widget.toolState.eraserMode == EraserMode.partial) {
      unawaited(_erasePartialAt(canonicalPos));
      return;
    }
    final r = _toCanonicalLen(widget.toolState.eraserRadius);
    final doomed = <Stroke>[];
    for (final s in _strokes) {
      if (!s.bounds.inflate(r).contains(canonicalPos)) continue;
      if (_strokeHit(s, canonicalPos, r)) doomed.add(s);
    }
    if (doomed.isEmpty) return;
    for (final s in doomed) {
      _erasedThisPass.add(s.copy());
    }
    _controller.removeStrokes(doomed);
  }

  Future<void> _erasePartialAt(Offset canonicalPos) async {
    final r = _toCanonicalLen(widget.toolState.eraserRadius);
    final candidates = List<Stroke>.from(_strokes);
    var changed = false;
    for (final s in candidates) {
      if (!s.bounds.inflate(r).contains(canonicalPos)) continue;
      if (!_strokeHit(s, canonicalPos, r)) continue;

      final result = partialEraseStroke(s, canonicalPos, r);
      if (result == null) continue;

      final rootId = _partialSegmentToRoot[s.id] ?? s.id;
      _partialEraseOriginals.putIfAbsent(rootId, () => s.copy());

      await _controller.removeStrokes([s]);
      _partialEraseAddedIds.remove(s.id);
      _partialSegmentToRoot.remove(s.id);

      final newSegs = <Stroke>[];
      for (final seg in result.segments) {
        final ns = Stroke(
          id: _uuid.v4(),
          pageId: seg.pageId,
          tool: seg.tool,
          brushStyle: seg.brushStyle,
          color: seg.color,
          width: seg.width,
          points: List.of(seg.points),
          z: seg.z,
        );
        newSegs.add(ns);
        _partialEraseAddedIds.add(ns.id);
        _partialSegmentToRoot[ns.id] = rootId;
      }
      for (final ns in newSegs) {
        await _controller.addStroke(ns);
      }
      changed = true;
    }
    if (changed) _bump();
  }

  bool _strokeHit(Stroke s, Offset p, double radius) {
    final pts = s.points;
    final hitR = radius + s.width / 2;
    if (pts.length == 1) {
      return Offset(pts[0].x - p.dx, pts[0].y - p.dy).distance <= hitR;
    }
    for (var i = 1; i < pts.length; i++) {
      final a = Offset(pts[i - 1].x, pts[i - 1].y);
      final b = Offset(pts[i].x, pts[i].y);
      if (_distToSegment(p, a, b) <= hitR) return true;
    }
    return false;
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    return (p - (a + Offset(ab.dx * t, ab.dy * t))).distance;
  }

  void _selectFromLasso(List<Offset> displayPath) {
    _selectedIds.clear();
    _selectedTextIds.clear();
    Rect? bounds;
    for (final s in _strokes) {
      var inside = 0;
      for (final pt in s.points) {
        final d = _toDisplay(Offset(pt.x, pt.y));
        if (_pointInPolygon(d, displayPath)) inside++;
      }
      if (inside > s.points.length * 0.5) {
        _selectedIds.add(s.id);
        bounds = bounds == null ? s.bounds : bounds.expandToInclude(s.bounds);
      }
    }
    for (final t in _textBlocks) {
      final center = _toDisplay(Offset(t.x + t.w / 2, t.y + t.h / 2));
      if (_pointInPolygon(center, displayPath)) {
        _selectedTextIds.add(t.id);
        bounds = bounds == null ? t.rect : bounds.expandToInclude(t.rect);
      }
    }
    _selectionBounds = bounds;
  }

  PageImage? _selectedImage() {
    if (_selectedImageId == null) return null;
    for (final i in _images) {
      if (i.id == _selectedImageId) return i;
    }
    return null;
  }

  bool _pointInPolygon(Offset p, List<Offset> poly) {
    var inside = false;
    for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final pi = poly[i], pj = poly[j];
      if ((pi.dy > p.dy) != (pj.dy > p.dy) &&
          p.dx <
              (pj.dx - pi.dx) * (p.dy - pi.dy) / (pj.dy - pi.dy) + pi.dx) {
        inside = !inside;
      }
    }
    return inside;
  }

  _SelectionSnapshot _captureSelectionSnapshot() =>
      _controller.captureSelectionSnapshot(
        strokeIds: _selectedIds,
        textIds: _selectedTextIds,
        imageId: _selectedImageId,
        strokes: _strokes,
        texts: _textBlocks,
        images: _images,
        rotation: _selectionRotation,
      );

  void _restoreFromSnapshot(_SelectionSnapshot snap) {
    for (final s in _strokes) {
      final pts = snap.strokes[s.id];
      if (pts != null) {
        s.points =
            pts.map((p) => StrokePoint(p.x, p.y, p.p)).toList();
      }
    }
    for (final t in _textBlocks) {
      final r = snap.texts[t.id];
      if (r != null) {
        t.x = r.left;
        t.y = r.top;
        t.w = r.width;
        t.h = r.height;
        final fs = snap.textFontSizes[t.id];
        if (fs != null) t.fontSize = fs;
        final rot = snap.textRotations[t.id];
        if (rot != null) t.rotation = rot;
      }
    }
    if (snap.imageId != null && snap.imageRect != null) {
      for (final i in _images) {
        if (i.id == snap.imageId) {
          i.rect = snap.imageRect!;
          break;
        }
      }
    }
    _selectionRotation = snap.rotation;
  }

  Rect? _displaySelectionBounds() {
    if (_selectionBounds == null) return null;
    return PageCoords.canonicalRectToDisplay(
            _selectionBounds!, widget.displaySize, _pageSize,
            orientation: _orientation)
        .inflate(6);
  }

  _SelHandle _hitSelectionHandle(Offset pos) {
    final r = _displaySelectionBounds();
    if (r == null) return _SelHandle.none;
    const hitR = 22.0;
    final localPos = _selectionRotation == 0
        ? pos
        : _unrotateDisplayPoint(pos, r, _selectionRotation);
    final rotatePt = r.center + Offset(0, -r.height / 2 - 28);
    if ((localPos - rotatePt).distance < hitR) return _SelHandle.rotate;
    final corners = <_SelHandle, Offset>{
      _SelHandle.nw: r.topLeft,
      _SelHandle.ne: r.topRight,
      _SelHandle.sw: r.bottomLeft,
      _SelHandle.se: r.bottomRight,
    };
    for (final entry in corners.entries) {
      if ((localPos - entry.value).distance < hitR) return entry.key;
    }
    if (r.contains(localPos)) return _SelHandle.body;
    return _SelHandle.none;
  }

  Offset _unrotateDisplayPoint(Offset pos, Rect r, double rotation) {
    final center = r.center;
    final dx = pos.dx - center.dx;
    final dy = pos.dy - center.dy;
    final cos = math.cos(-rotation);
    final sin = math.sin(-rotation);
    return Offset(
      center.dx + dx * cos - dy * sin,
      center.dy + dx * sin + dy * cos,
    );
  }

  Stroke? _hitStrokeAt(Offset displayPos) {
    final cPos = _toCanonical(displayPos);
    final hitR = _toCanonicalLen(12);
    for (final s in _strokes.reversed) {
      if (_strokeHit(s, cPos, hitR)) return s;
    }
    return null;
  }

  Stroke? _hitTapeStrokeAt(Offset displayPos) {
    final cPos = _toCanonical(displayPos);
    final hitR = _toCanonicalLen(14);
    for (final s in _strokes.reversed) {
      if (s.tool != ToolType.tape) continue;
      if (_strokeHit(s, cPos, hitR)) return s;
    }
    return null;
  }

  Future<void> _toggleTapeHidden(Stroke stroke) async {
    final before = stroke.hidden;
    final after = !before;
    await _controller.setTapeHidden(stroke.id, after);
    _controller.commit(_ToggleTapeHidden(stroke.id, before, after));
    widget.onHistoryChanged?.call(_controller.canUndo, _controller.canRedo);
    _bump();
  }

  TextBlock? _hitTextBlock(Offset displayPos) {
    final cPos = _toCanonical(displayPos);
    for (final t in _textBlocks.reversed) {
      if (t.containsCanonicalPoint(cPos)) return t;
    }
    return null;
  }

  void _selectStroke(Stroke stroke) {
    _clearSelection();
    _selectedIds.add(stroke.id);
    _selectionBounds = stroke.bounds;
    _notifySelection();
    _bump();
  }

  void _selectText(TextBlock block) {
    _clearSelection();
    _selectedTextIds.add(block.id);
    _selectionBounds = block.rect;
    _selectionRotation = block.rotation;
    _notifySelection();
    _bump();
  }

  void _selectFromMarquee(Rect displayRect) {
    final normalized = Rect.fromPoints(
      displayRect.topLeft,
      displayRect.bottomRight,
    );
    _selectedIds.clear();
    _selectedTextIds.clear();
    _selectedFillIds.clear();
    _selectedImageId = null;
    Rect? bounds;
    final canonicalRect = PageCoords.displayRectToCanonical(
        normalized, widget.displaySize, _pageSize,
        orientation: _orientation);
    for (final s in _strokes) {
      if (canonicalRect.overlaps(s.bounds)) {
        _selectedIds.add(s.id);
        bounds = bounds == null ? s.bounds : bounds.expandToInclude(s.bounds);
      }
    }
    for (final t in _textBlocks) {
      if (canonicalRect.overlaps(t.axisAlignedBounds)) {
        _selectedTextIds.add(t.id);
        bounds = bounds == null ? t.axisAlignedBounds : bounds.expandToInclude(t.axisAlignedBounds);
      }
    }
    for (final img in _images) {
      if (canonicalRect.overlaps(img.rect)) {
        _selectedImageId = img.id;
        bounds = bounds == null ? img.rect : bounds.expandToInclude(img.rect);
        break;
      }
    }
    _selectionBounds = bounds;
  }

  void _applyRotation(double delta) {
    if (_transformBefore == null || _transformPivot == null) return;
    _restoreFromSnapshot(_transformBefore!);
    final pivot = _transformPivot!;
    final cos = math.cos(delta);
    final sin = math.sin(delta);

    Offset rotatePoint(Offset p) {
      final dx = p.dx - pivot.dx;
      final dy = p.dy - pivot.dy;
      return Offset(
        pivot.dx + dx * cos - dy * sin,
        pivot.dy + dx * sin + dy * cos,
      );
    }

    for (final s in _strokes.where((s) => _selectedIds.contains(s.id))) {
      s.points = s.points
          .map((p) {
            final rp = rotatePoint(Offset(p.x, p.y));
            return StrokePoint(rp.dx, rp.dy, p.p);
          })
          .toList();
    }
    for (final t in _textBlocks.where((t) => _selectedTextIds.contains(t.id))) {
      final baseRect = _transformBefore!.texts[t.id];
      if (baseRect == null) continue;
      final baseRot = _transformBefore!.textRotations[t.id] ?? 0;
      final newCenter = rotatePoint(baseRect.center);
      t.x = newCenter.dx - baseRect.width / 2;
      t.y = newCenter.dy - baseRect.height / 2;
      t.w = baseRect.width;
      t.h = baseRect.height;
      t.rotation = baseRot + delta;
    }
    final selImg = _selectedImage();
    if (selImg != null && _transformBefore!.imageRect != null) {
      final r = _transformBefore!.imageRect!;
      final rotated = [
        rotatePoint(r.topLeft),
        rotatePoint(r.topRight),
        rotatePoint(r.bottomRight),
        rotatePoint(r.bottomLeft),
      ];
      var minX = rotated.first.dx, maxX = rotated.first.dx;
      var minY = rotated.first.dy, maxY = rotated.first.dy;
      for (final c in rotated.skip(1)) {
        minX = math.min(minX, c.dx);
        maxX = math.max(maxX, c.dx);
        minY = math.min(minY, c.dy);
        maxY = math.max(maxY, c.dy);
      }
      selImg.rect = Rect.fromLTRB(minX, minY, maxX, maxY);
    }
    _selectionRotation = _transformBefore!.rotation + delta;
    _recomputeSelectionBounds();
  }

  void _applyScale(double factor) {
    if (_transformBefore == null || _transformPivot == null) return;
    _restoreFromSnapshot(_transformBefore!);
    final pivot = _transformPivot!;
    final clamped = factor.clamp(0.2, 5.0);

    Offset scalePoint(Offset p) => Offset(
          pivot.dx + (p.dx - pivot.dx) * clamped,
          pivot.dy + (p.dy - pivot.dy) * clamped,
        );

    for (final s in _strokes.where((s) => _selectedIds.contains(s.id))) {
      s.points = s.points
          .map((p) {
            final sp = scalePoint(Offset(p.x, p.y));
            return StrokePoint(sp.dx, sp.dy, p.p);
          })
          .toList();
    }
    for (final t in _textBlocks.where((t) => _selectedTextIds.contains(t.id))) {
      final scaled = [
        scalePoint(Offset(t.x, t.y)),
        scalePoint(Offset(t.x + t.w, t.y + t.h)),
      ];
      t.x = math.min(scaled[0].dx, scaled[1].dx);
      t.y = math.min(scaled[0].dy, scaled[1].dy);
      t.w = (scaled[1].dx - scaled[0].dx).abs();
      t.h = (scaled[1].dy - scaled[0].dy).abs();
      final baseFs = _transformBefore!.textFontSizes[t.id] ?? t.fontSize;
      t.fontSize = (baseFs * clamped).clamp(8.0, 256.0);
    }
    final selImg = _selectedImage();
    if (selImg != null && _transformBefore!.imageRect != null) {
      final r = _transformBefore!.imageRect!;
      final tl = scalePoint(r.topLeft);
      final br = scalePoint(r.bottomRight);
      selImg.rect = Rect.fromPoints(tl, br);
    }
    _recomputeSelectionBounds();
  }

  Future<void> _finishSelectionTransform() async {
    final before = _transformBefore;
    if (before == null) return;
    final after = _captureSelectionSnapshot();
    if (_snapshotsEqual(before, after)) return;

    for (final s in _strokes.where((s) => _selectedIds.contains(s.id))) {
      await AppDatabase.instance.updateStrokePoints(s);
    }
    for (final t in _textBlocks.where((t) => _selectedTextIds.contains(t.id))) {
      await AppDatabase.instance.updateTextBlock(t);
    }
    final selImg = _selectedImage();
    if (selImg != null) {
      await AppDatabase.instance.updateImageRect(selImg);
    }
    _controller.commit(_TransformSelection(before, after));
    widget.onHistoryChanged?.call(_controller.canUndo, _controller.canRedo);
  }

  bool _snapshotsEqual(_SelectionSnapshot a, _SelectionSnapshot b) {
    if ((a.rotation - b.rotation).abs() > 0.0001) return false;
    if (a.imageId != b.imageId) return false;
    if (a.imageRect != b.imageRect) return false;
    if (a.strokes.length != b.strokes.length) return false;
    if (a.texts.length != b.texts.length) return false;
    for (final id in a.strokes.keys) {
      final ap = a.strokes[id]!;
      final bp = b.strokes[id];
      if (bp == null || ap.length != bp.length) return false;
      for (var i = 0; i < ap.length; i++) {
        if (ap[i].x != bp[i].x || ap[i].y != bp[i].y) return false;
      }
    }
    for (final id in a.texts.keys) {
      if (a.texts[id] != b.texts[id]) return false;
      if (a.textFontSizes[id] != b.textFontSizes[id]) return false;
      if ((a.textRotations[id] ?? 0) != (b.textRotations[id] ?? 0)) {
        return false;
      }
    }
    return true;
  }

  List<Stroke> get strokesForThumbnail => List.unmodifiable(_strokes);

  @override
  Widget build(BuildContext context) {
    final canvas = Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      onPointerHover: _onPointerHover,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.displaySize.width,
        height: widget.displaySize.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: PagePainter(
                  template: widget.page.template,
                  pageSize: _pageSize,
                  orientation: _orientation,
                  pdfImage: widget.pdfImage,
                ),
              ),
            ),
            RepaintBoundary(
              child: CustomPaint(
                painter: InkPainter(
                  strokes: _strokes,
                  current: _current,
                  selectedIds: _selectedIds,
                  lassoPath: _lassoPath ?? _fillPath,
                  selectionBounds: _selectionBounds,
                  showTransformHandles: hasSelection &&
                      (widget.toolState.tool == ToolType.selection ||
                          widget.toolState.tool == ToolType.lasso),
                  selectionRotation: _selectionRotation,
                  marqueeRect: _marqueeRect,
                  images: _images,
                  decodedImages: _decodedImages,
                  selectedImageId: _selectedImageId,
                  fills: _fills,
                  textBlocks: _textBlocks,
                  pageSize: _pageSize,
                  orientation: _orientation,
                  displaySize: widget.displaySize,
                  revision: _revision,
                ),
              ),
            ),
            if (_textEditCtrl != null && _textEditPos != null)
              Positioned(
                left: _toDisplay(_textEditPos!).dx,
                top: _toDisplay(_textEditPos!).dy,
                width: PageCoords.canonicalToDisplayLength(
                  _editingTextId != null
                      ? (_textBlocks
                              .where((t) => t.id == _editingTextId)
                              .map((t) => t.w)
                              .firstOrNull ??
                          _canonicalSize.width * 0.4)
                      : _canonicalSize.width * 0.4,
                  widget.displaySize,
                  _pageSize,
                  orientation: _orientation,
                ),
                child: Material(
                  elevation: 2,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditCtrl,
                          autofocus: true,
                          minLines: 1,
                          maxLines: 6,
                          style: TextStyle(
                            fontSize: PageCoords.canonicalToDisplayLength(
                              _defaultTextFontSize(),
                              widget.displaySize,
                              _pageSize,
                              orientation: _orientation,
                            ),
                            height: 1.25,
                          ),
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Type here…',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(8),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _commitTextEdit(),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Done',
                        icon: const Icon(Icons.check_rounded),
                        onPressed: _commitTextEdit,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.toolState.stylusOnly) return canvas;
    return DrawGestureShield(child: canvas);
  }
}

/// Test hook: reset clipboard between tests.
void resetClipboardForTests() {
  _clipboard = const ClipboardSelection();
}

/// Test hook: read clipboard state.
ClipboardSelection get clipboardForTests => _clipboard;

/// Test hook: selection handle kinds for hit-test geometry tests.
enum SelectionHandleKind { none, body, nw, ne, sw, se, rotate }

/// Test hook: map internal handle enum to test-visible kind.
SelectionHandleKind selectionHandleKindForTests(_SelHandle handle) =>
    switch (handle) {
      _SelHandle.none => SelectionHandleKind.none,
      _SelHandle.body => SelectionHandleKind.body,
      _SelHandle.nw => SelectionHandleKind.nw,
      _SelHandle.ne => SelectionHandleKind.ne,
      _SelHandle.sw => SelectionHandleKind.sw,
      _SelHandle.se => SelectionHandleKind.se,
      _SelHandle.rotate => SelectionHandleKind.rotate,
    };

/// Test hook: hit-test transform handles in display space.
SelectionHandleKind hitSelectionHandleForTests({
  required Offset pos,
  required Rect displayBounds,
  double selectionRotation = 0,
}) {
  const hitR = 22.0;
  final inflated = displayBounds.inflate(6);
  final localPos = selectionRotation == 0
      ? pos
      : unrotateDisplayPointForTests(pos, inflated, selectionRotation);
  final rotatePt = inflated.center + Offset(0, -inflated.height / 2 - 28);
  if ((localPos - rotatePt).distance < hitR) {
    return SelectionHandleKind.rotate;
  }
  final corners = <SelectionHandleKind, Offset>{
    SelectionHandleKind.nw: inflated.topLeft,
    SelectionHandleKind.ne: inflated.topRight,
    SelectionHandleKind.sw: inflated.bottomLeft,
    SelectionHandleKind.se: inflated.bottomRight,
  };
  for (final entry in corners.entries) {
    if ((localPos - entry.value).distance < hitR) return entry.key;
  }
  if (inflated.contains(localPos)) return SelectionHandleKind.body;
  return SelectionHandleKind.none;
}

/// Test hook: undo display-space rotation for handle hit testing.
Offset unrotateDisplayPointForTests(Offset pos, Rect r, double rotation) {
  final center = r.center;
  final dx = pos.dx - center.dx;
  final dy = pos.dy - center.dy;
  final cos = math.cos(-rotation);
  final sin = math.sin(-rotation);
  return Offset(
    center.dx + dx * cos - dy * sin,
    center.dy + dx * sin + dy * cos,
  );
}

/// Test hook: rotate a canonical point around a pivot by [delta] radians.
Offset rotateCanonicalPointForTests(Offset p, Offset pivot, double delta) {
  final dx = p.dx - pivot.dx;
  final dy = p.dy - pivot.dy;
  final cos = math.cos(delta);
  final sin = math.sin(delta);
  return Offset(
    pivot.dx + dx * cos - dy * sin,
    pivot.dy + dx * sin + dy * cos,
  );
}

/// Test hook: whether lasso/selection tools show transform handles.
bool showsTransformHandlesForTests({
  required ToolType tool,
  required bool hasSelection,
}) =>
    hasSelection &&
    (tool == ToolType.selection || tool == ToolType.lasso);
