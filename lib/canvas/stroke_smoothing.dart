import '../models/models.dart';

/// Chaikin corner-cutting smoothing on ink point streams.
///
/// Preserves first/last points and interpolates pressure between neighbors.
List<StrokePoint> smoothStrokePoints(
  List<StrokePoint> points, {
  int iterations = 1,
}) {
  if (points.length < 3 || iterations <= 0) {
    return List<StrokePoint>.from(points);
  }

  var result = List<StrokePoint>.from(points);
  for (var iter = 0; iter < iterations; iter++) {
    final smoothed = <StrokePoint>[result.first];
    for (var i = 0; i < result.length - 1; i++) {
      final p0 = result[i];
      final p1 = result[i + 1];
      smoothed.add(StrokePoint(
        0.75 * p0.x + 0.25 * p1.x,
        0.75 * p0.y + 0.25 * p1.y,
        0.75 * p0.p + 0.25 * p1.p,
      ));
      smoothed.add(StrokePoint(
        0.25 * p0.x + 0.75 * p1.x,
        0.25 * p0.y + 0.75 * p1.y,
        0.25 * p0.p + 0.75 * p1.p,
      ));
    }
    smoothed.add(result.last);
    result = smoothed;
  }
  return result;
}

/// Applies smoothing when [enabled]; otherwise returns a copy of [points].
List<StrokePoint> maybeSmoothStrokePoints(
  List<StrokePoint> points, {
  required bool enabled,
  int iterations = 1,
}) {
  if (!enabled) return List<StrokePoint>.from(points);
  return smoothStrokePoints(points, iterations: iterations);
}
