import 'dart:ui';

import '../models/models.dart';
import '../services/stroke_smoothing_service.dart';

/// Minimum segment length (canonical 0.1 mm) before Chaikin corner-cutting applies.
///
/// Lower [strength] preserves finer detail (only long segments are smoothed).
/// Higher [strength] smooths shorter segments too.
double smoothingMinSegmentLength(double strength) {
  if (strength <= 0) return double.infinity;
  // strength 0.35 (recommended) ≈ 18 units (~1.8 mm); strength 1.0 ≈ 5 units.
  return (55.0 - strength * 50.0).clamp(5.0, 200.0);
}

/// Chaikin iterations scale with smoothing strength.
int smoothingIterations(double strength) {
  if (strength <= 0) return 0;
  if (strength < 0.66) return 1;
  return 2;
}

double _dist(StrokePoint a, StrokePoint b) =>
    Offset(b.x - a.x, b.y - a.y).distance;

StrokePoint _lerpPoint(StrokePoint a, StrokePoint b, double t) => StrokePoint(
      a.x + (b.x - a.x) * t,
      a.y + (b.y - a.y) * t,
      a.p + (b.p - a.p) * t,
    );

/// Resample [points] to [count] positions evenly by arc length (for blending).
List<StrokePoint> _resampleStrokePoints(List<StrokePoint> points, int count) {
  if (points.isEmpty || count <= 0) return const [];
  if (points.length == 1 || count == 1) {
    return [points.first];
  }

  final lengths = <double>[0];
  for (var i = 1; i < points.length; i++) {
    lengths.add(lengths.last + _dist(points[i - 1], points[i]));
  }
  final total = lengths.last;
  if (total <= 0) {
    return List<StrokePoint>.generate(count, (_) => points.first);
  }

  final out = <StrokePoint>[];
  var seg = 0;
  for (var i = 0; i < count; i++) {
    final target = total * i / (count - 1);
    while (seg + 1 < lengths.length && lengths[seg + 1] < target) {
      seg++;
    }
    if (seg + 1 >= points.length) {
      out.add(points.last);
      continue;
    }
    final segStart = lengths[seg];
    final segLen = lengths[seg + 1] - segStart;
    final t = segLen <= 0 ? 0.0 : ((target - segStart) / segLen).clamp(0.0, 1.0);
    out.add(_lerpPoint(points[seg], points[seg + 1], t));
  }
  return out;
}

List<StrokePoint> _blendStrokePoints(
  List<StrokePoint> original,
  List<StrokePoint> smoothed,
  double blend,
) {
  if (blend <= 0) return List<StrokePoint>.from(original);
  if (blend >= 1) return List<StrokePoint>.from(smoothed);
  final count = original.length > smoothed.length
      ? original.length
      : smoothed.length;
  if (count < 2) return List<StrokePoint>.from(original);
  final a = _resampleStrokePoints(original, count);
  final b = _resampleStrokePoints(smoothed, count);
  final blended = List<StrokePoint>.generate(
    count,
    (i) => _lerpPoint(a[i], b[i], blend),
  );
  if (blended.isNotEmpty) {
    blended[0] = original.first;
    blended[blended.length - 1] = original.last;
  }
  return blended;
}

/// Chaikin corner-cutting smoothing on ink point streams.
///
/// Preserves first/last points. Short segments below [minSegmentLength] are kept
/// verbatim so small handwriting stays readable.
List<StrokePoint> smoothStrokePoints(
  List<StrokePoint> points, {
  double strength = StrokeSmoothingService.defaultStrength,
}) {
  if (points.length < 3 || strength <= 0) {
    return List<StrokePoint>.from(points);
  }

  final minSeg = smoothingMinSegmentLength(strength);
  final iterations = smoothingIterations(strength);
  var result = List<StrokePoint>.from(points);

  for (var iter = 0; iter < iterations; iter++) {
    final smoothed = <StrokePoint>[result.first];
    for (var i = 0; i < result.length - 1; i++) {
      final p0 = result[i];
      final p1 = result[i + 1];
      if (_dist(p0, p1) >= minSeg) {
        smoothed.add(_lerpPoint(p0, p1, 0.75));
        smoothed.add(_lerpPoint(p0, p1, 0.25));
      } else {
        smoothed.add(p1);
      }
    }
    result = smoothed;
  }

  // Subtle default: blend so recommended strength keeps small loops intact.
  final blend = (strength * 0.85).clamp(0.0, 1.0);
  return _blendStrokePoints(points, result, blend);
}

/// Applies smoothing when [enabled]; otherwise returns a copy of [points].
List<StrokePoint> maybeSmoothStrokePoints(
  List<StrokePoint> points, {
  required bool enabled,
  double strength = StrokeSmoothingService.defaultStrength,
}) {
  if (!enabled) return List<StrokePoint>.from(points);
  return smoothStrokePoints(points, strength: strength);
}
