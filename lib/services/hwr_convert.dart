import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;

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

/// Minimum points per stroke for ML Kit digital ink recognition.
const minInkPointsForRecognition = 2;

/// Whether [strokes] contain enough points for digital ink recognition.
bool hasEnoughInkPoints(Iterable<Stroke> strokes) =>
    strokes.any((s) => s.points.length >= minInkPointsForRecognition);

/// Millisecond timestamps for ML Kit when stroke points lack time data.
List<int> syntheticInkTimestamps(
  int count, {
  int msPerPoint = 16,
  int baseMs = 0,
}) =>
    List.generate(count, (i) => baseMs + i * msPerPoint);

/// Convert Penfold strokes to ML Kit [mlkit.Ink] for on-device recognition.
mlkit.Ink strokesToMlKitInk(List<Stroke> strokes, {int timeBaseMs = 0}) {
  final mlStrokes = <mlkit.Stroke>[];
  var strokeIndex = 0;
  for (final stroke in strokes) {
    if (stroke.points.length < minInkPointsForRecognition) continue;
    final mlStroke = mlkit.Stroke();
    final baseMs = timeBaseMs + strokeIndex * 1000;
    final times = syntheticInkTimestamps(stroke.points.length, baseMs: baseMs);
    mlStroke.points = [
      for (var i = 0; i < stroke.points.length; i++)
        mlkit.StrokePoint(
          x: stroke.points[i].x,
          y: stroke.points[i].y,
          t: times[i],
        ),
    ];
    mlStrokes.add(mlStroke);
    strokeIndex++;
  }
  final ink = mlkit.Ink();
  ink.strokes = mlStrokes;
  return ink;
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
