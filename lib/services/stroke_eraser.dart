import 'dart:math' as math;
import 'dart:ui';

import 'package:penfold/models/models.dart';

/// How the eraser interacts with strokes.
enum EraserMode {
  /// Delete any stroke the eraser touches (legacy behavior).
  wholeStroke,

  /// Clip strokes at the eraser circle, keeping unerased segments.
  partial,
}

/// Result of partially erasing one stroke.
class PartialEraseResult {
  final Stroke original;
  final List<Stroke> segments;

  const PartialEraseResult({required this.original, required this.segments});
}

/// Clip [stroke] at a circular eraser zone; returns remaining point sequences.
///
/// Each inner list has at least two points (single-point remnants are dropped).
List<List<StrokePoint>> clipStrokePoints(
  List<StrokePoint> points,
  Offset center,
  double hitRadius,
) {
  if (points.isEmpty) return const [];
  if (points.length == 1) {
    final p = Offset(points[0].x, points[0].y);
    if ((p - center).distance <= hitRadius) return const [];
    return [points];
  }

  final segments = <List<StrokePoint>>[];
  var current = <StrokePoint>[];

  void flush() {
    if (current.length >= 2) {
      segments.add(List.of(current));
    }
    current = [];
  }

  bool inside(StrokePoint pt) =>
      (Offset(pt.x, pt.y) - center).distance <= hitRadius;

  StrokePoint lerp(StrokePoint a, StrokePoint b, double t) => StrokePoint(
        a.x + (b.x - a.x) * t,
        a.y + (b.y - a.y) * t,
        a.p + (b.p - a.p) * t,
      );

  for (var i = 0; i < points.length; i++) {
    final pt = points[i];
    final ptInside = inside(pt);

    if (i == 0) {
      if (!ptInside) current.add(pt);
      continue;
    }

    final prev = points[i - 1];
    final prevInside = inside(prev);
    final a = Offset(prev.x, prev.y);
    final b = Offset(pt.x, pt.y);
    final ts = _segmentCircleIntersectionTs(a, b, center, hitRadius);

    if (prevInside && ptInside) {
      // Fully inside — skip segment.
      continue;
    }

    if (!prevInside && !ptInside && ts.isEmpty) {
      // Fully outside, no chord through circle.
      if (current.isEmpty) current.add(prev);
      current.add(pt);
      continue;
    }

    // Boundary crossing or chord through circle.
    final splitTs = <double>[0.0, ...ts, 1.0]..sort();
    for (var s = 0; s < splitTs.length - 1; s++) {
      final t0 = splitTs[s];
      final t1 = splitTs[s + 1];
      if (t1 - t0 < 1e-9) continue;
      final mid = (t0 + t1) / 2;
      final midPt = Offset(
        a.dx + (b.dx - a.dx) * mid,
        a.dy + (b.dy - a.dy) * mid,
      );
      if ((midPt - center).distance > hitRadius) {
        final p0 = lerp(prev, pt, t0);
        final p1 = lerp(prev, pt, t1);
        if (current.isEmpty || current.last != p0) {
          if (current.isEmpty && t0 > 0) {
            // Start fresh from interpolated boundary.
          }
          current.add(p0);
        }
        current.add(p1);
      } else {
        flush();
      }
    }
  }

  flush();
  return segments;
}

/// Partially erase [stroke] at [center] with screen-space [eraserRadius].
/// Returns `null` when nothing changes.
PartialEraseResult? partialEraseStroke(
  Stroke stroke,
  Offset center,
  double eraserRadius,
) {
  final hitR = eraserRadius + stroke.width / 2;
  if (!stroke.bounds.inflate(hitR).contains(center)) return null;

  final clipped = clipStrokePoints(stroke.points, center, hitR);
  if (clipped.length == 1 &&
      clipped.first.length == stroke.points.length &&
      _pointsEqual(clipped.first, stroke.points)) {
    return null;
  }

  // No change if everything erased.
  if (clipped.isEmpty) {
    return PartialEraseResult(original: stroke, segments: const []);
  }

  // No change if identical single segment.
  if (clipped.length == 1 &&
      clipped.first.length == stroke.points.length &&
      _pointsEqual(clipped.first, stroke.points)) {
    return null;
  }

  final segments = clipped
      .map(
        (pts) => Stroke(
          id: '', // caller assigns
          pageId: stroke.pageId,
          tool: stroke.tool,
          brushStyle: stroke.brushStyle,
          color: stroke.color,
          width: stroke.width,
          points: pts,
          z: stroke.z,
        ),
      )
      .toList();

  return PartialEraseResult(original: stroke, segments: segments);
}

bool _pointsEqual(List<StrokePoint> a, List<StrokePoint> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].x != b[i].x || a[i].y != b[i].y) return false;
  }
  return true;
}

/// Intersection parameters along segment A→B with circle (center, radius).
List<double> _segmentCircleIntersectionTs(
  Offset a,
  Offset b,
  Offset center,
  double radius,
) {
  final d = b - a;
  final f = a - center;
  final a2 = d.dx * d.dx + d.dy * d.dy;
  if (a2 < 1e-12) return const [];

  final b2 = 2 * (f.dx * d.dx + f.dy * d.dy);
  final c2 = f.dx * f.dx + f.dy * f.dy - radius * radius;
  final disc = b2 * b2 - 4 * a2 * c2;
  if (disc < 0) return const [];

  final sq = math.sqrt(disc);
  final results = <double>[];
  for (final t in [(-b2 - sq) / (2 * a2), (-b2 + sq) / (2 * a2)]) {
    if (t >= 0 && t <= 1) results.add(t);
  }
  results.sort();
  return results;
}
