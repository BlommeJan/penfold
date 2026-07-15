import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/models.dart';

/// Pen or highlighter stroke eligible for handwriting OCR conversion.
bool isConvertibleInkStroke(Stroke stroke) =>
    stroke.tool == ToolType.pen || stroke.tool == ToolType.highlighter;

/// Whether the current selection contains ink that can be converted to text.
bool canConvertInkSelection(Set<String> selectedIds, Iterable<Stroke> strokes) =>
    selectedIds.isNotEmpty &&
    strokes.any(
      (s) => selectedIds.contains(s.id) && isConvertibleInkStroke(s),
    );

/// Combined bounds of convertible ink in the selection (canonical coords).
Rect? inkBoundsForSelection(Set<String> selectedIds, Iterable<Stroke> strokes) {
  Rect? bounds;
  for (final s in strokes) {
    if (selectedIds.contains(s.id) && isConvertibleInkStroke(s)) {
      bounds = bounds == null ? s.bounds : bounds.expandToInclude(s.bounds);
    }
  }
  return bounds;
}

/// Build a [TextBlock] from OCR output at [bounds]; original ink is kept separately.
TextBlock buildHwrTextBlock({
  required String id,
  required String pageId,
  required String text,
  required Rect bounds,
  required double fontSize,
  required int color,
  required int z,
  Size? measuredSize,
}) {
  final w = measuredSize?.width ?? bounds.width;
  final h = measuredSize?.height ?? bounds.height;
  return TextBlock(
    id: id,
    pageId: pageId,
    x: bounds.left,
    y: bounds.top,
    w: math.max(bounds.width, w),
    h: math.max(bounds.height, h),
    text: text,
    fontSize: fontSize,
    color: color,
    z: z,
  );
}
