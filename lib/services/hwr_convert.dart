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

/// Build a [TextBlock] from OCR output; position at ink top-left, size hugs glyphs.
TextBlock buildHwrTextBlock({
  required String id,
  required String pageId,
  required String text,
  required Rect inkBounds,
  required Size textSize,
  required double fontSize,
  required int color,
  required int z,
}) {
  return TextBlock(
    id: id,
    pageId: pageId,
    x: inkBounds.left,
    y: inkBounds.top,
    w: textSize.width,
    h: textSize.height,
    text: text,
    fontSize: fontSize,
    color: color,
    z: z,
  );
}

/// OCR text segment with bounds used for merging handwriting runs.
class InkTextSegment {
  final String text;
  final Rect bounds;

  const InkTextSegment({required this.text, required this.bounds});
}

/// Default maximum horizontal gap (in canonical units) to merge segments.
const double defaultInkMergeGap = 28;

/// Merge adjacent OCR segments on the same line when the horizontal gap is small.
List<InkTextSegment> mergeInkTextSegments(
  List<InkTextSegment> segments, {
  double maxGap = defaultInkMergeGap,
}) {
  if (segments.length <= 1) return List<InkTextSegment>.from(segments);
  final sorted = [...segments]
    ..sort((a, b) {
      final ay = a.bounds.top;
      final by = b.bounds.top;
      if ((ay - by).abs() > 4) return ay.compareTo(by);
      return a.bounds.left.compareTo(b.bounds.left);
    });

  final merged = <InkTextSegment>[];
  var current = sorted.first;
  for (final next in sorted.skip(1)) {
    if (_canMergeSegments(current, next, maxGap)) {
      final gap = next.bounds.left - current.bounds.right;
      final lineHeight =
          math.max(current.bounds.height, next.bounds.height).clamp(1.0, 9999);
      final joiner = gap > lineHeight * 0.35 ? ' ' : '';
      current = InkTextSegment(
        text: '${current.text}$joiner${next.text}',
        bounds: current.bounds.expandToInclude(next.bounds),
      );
    } else {
      merged.add(current);
      current = next;
    }
  }
  merged.add(current);
  return merged;
}

bool _canMergeSegments(
  InkTextSegment a,
  InkTextSegment b,
  double maxGap,
) {
  final gap = b.bounds.left - a.bounds.right;
  if (gap < 0 || gap > maxGap) return false;

  final overlap =
      math.min(a.bounds.bottom, b.bounds.bottom) - math.max(a.bounds.top, b.bounds.top);
  if (overlap <= 0) return false;
  final minHeight = math.min(a.bounds.height, b.bounds.height).clamp(1.0, 9999);
  return overlap / minHeight >= 0.4;
}
