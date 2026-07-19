import 'dart:math' as math;
import 'dart:ui';

import '../models/models.dart';
import 'shape_recognizer.dart';

/// Minimum polygon area (canonical units²) for fill hit-testing.
const kMinClosedRegionArea = 100.0;

/// Default closure gap in canonical units when no threshold is supplied.
const kDefaultCloseThresholdCanonical = 80.0;

/// Ray-cast point-in-polygon test in canonical coordinates.
bool pointInPolygon(Offset p, List<Offset> poly) {
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

double polygonAreaAbs(List<Offset> poly) {
  var area = 0.0;
  for (var i = 0; i < poly.length; i++) {
    final j = (i + 1) % poly.length;
    area += poly[i].dx * poly[j].dy - poly[j].dx * poly[i].dy;
  }
  return area.abs() / 2;
}

double strokePathLength(List<StrokePoint> pts) {
  var len = 0.0;
  for (var i = 1; i < pts.length; i++) {
    len += Offset(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y).distance;
  }
  return len;
}

/// Extract a closed polygon from [stroke] for region fill, or null.
List<Offset>? closedPolygonFromStroke(
  Stroke stroke, {
  double? closeThresholdCanonical,
}) {
  final pts = stroke.points;
  if (pts.length < 3) return null;

  final recognized = ShapeRecognizer.recognize(pts);
  if (recognized != null) {
    if (recognized.length < 3) return null;
    final poly =
        recognized.map((p) => Offset(p.x, p.y)).toList(growable: false);
    if (polygonAreaAbs(poly) < kMinClosedRegionArea) return null;
    return poly;
  }

  if (stroke.tool == ToolType.shape) return null;

  final threshold = closeThresholdCanonical ?? kDefaultCloseThresholdCanonical;
  final pathLen = strokePathLength(pts);
  final first = Offset(pts.first.x, pts.first.y);
  final last = Offset(pts.last.x, pts.last.y);
  final endGap = (first - last).distance;
  final closed = endGap <= math.max(threshold, pathLen * 0.18);
  if (!closed) return null;

  final poly = pts.map((p) => Offset(p.x, p.y)).toList(growable: false);
  if (polygonAreaAbs(poly) < kMinClosedRegionArea) return null;
  return poly;
}

/// Innermost closed ink region containing [canonicalPos], or null.
List<Offset>? findClosedRegionAt(
  Offset canonicalPos,
  List<Stroke> strokes, {
  double? closeThresholdCanonical,
}) {
  List<Offset>? best;
  var bestArea = double.infinity;

  for (final s in strokes.reversed) {
    if (s.tool != ToolType.pen &&
        s.tool != ToolType.shape &&
        s.tool != ToolType.highlighter) {
      continue;
    }

    final poly = closedPolygonFromStroke(
      s,
      closeThresholdCanonical: closeThresholdCanonical,
    );
    if (poly == null || poly.length < 3) continue;
    if (!pointInPolygon(canonicalPos, poly)) continue;

    final area = polygonAreaAbs(poly);
    if (area < bestArea) {
      bestArea = area;
      best = poly;
    }
  }
  return best;
}
