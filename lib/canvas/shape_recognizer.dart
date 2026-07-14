import 'dart:math' as math;
import 'dart:ui';

import '../models/models.dart';

/// Turns a rough hand-drawn stroke into a clean geometric shape,
/// the way GoodNotes' shape tool snaps your scribble.
///
/// Recognizes: straight line, triangle, rectangle (axis-snapped when close),
/// ellipse/circle. Returns null if nothing matches (caller keeps raw ink).
class ShapeRecognizer {
  static List<StrokePoint>? recognize(List<StrokePoint> pts) {
    if (pts.length < 4) return null;

    final path = _pathLength(pts);
    if (path < 20) return null;

    final first = Offset(pts.first.x, pts.first.y);
    final last = Offset(pts.last.x, pts.last.y);
    final endGap = (last - first).distance;

    // --- Straight line: endpoints far apart, path barely longer than chord.
    if (endGap / path > 0.90) {
      return _line(first, last);
    }

    // --- Closed shapes: ends meet (relative to size).
    final closed = endGap < math.max(30, path * 0.18);
    if (!closed) return null;

    final simplified = _rdp(pts, epsilon: math.max(8, path * 0.022));
    // Drop duplicated closing vertex if present.
    final verts = List<Offset>.from(
        simplified.map((e) => Offset(e.x, e.y)));
    if (verts.length >= 2 && (verts.last - verts.first).distance < 25) {
      verts.removeLast();
    }

    final area = _polygonArea(verts).abs();
    final perimeter = _perimeter(verts, close: true);
    if (perimeter <= 0 || area < 100) return null;

    // Distinct corners win first: RDP can't reduce a circle to <=4 vertices
    // (arc sagitta always exceeds epsilon), so 3-4 corners is a real polygon.
    if (verts.length == 3) return _polygon(verts);
    if (verts.length == 4) return _rectangleOrQuad(verts);

    // 5+ corners: could be a circle. Normalize raw points to the
    // bounding-box ellipse; a true ellipse keeps every normalized radius
    // near 1. (Circularity 4πA/P² can't do this — a square scores 0.785.)
    double minX = pts.first.x, maxX = pts.first.x;
    double minY = pts.first.y, maxY = pts.first.y;
    for (final p in pts) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    final cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
    final rx = (maxX - minX) / 2, ry = (maxY - minY) / 2;
    if (rx > 15 && ry > 15) {
      var dev = 0.0;
      for (final p in pts) {
        final nx = (p.x - cx) / rx;
        final ny = (p.y - cy) / ry;
        dev += (math.sqrt(nx * nx + ny * ny) - 1).abs();
      }
      dev /= pts.length;
      if (dev < 0.18) return _ellipse(pts);
    }

    // 5-8 corners, not round: keep as a cleaned polygon. More: raw ink.
    if (verts.length <= 8) return _polygon(verts);

    return null;
  }

  // ---------- shape builders ----------

  static List<StrokePoint> _line(Offset a, Offset b) =>
      [StrokePoint(a.dx, a.dy, 1), StrokePoint(b.dx, b.dy, 1)];

  static List<StrokePoint> _polygon(List<Offset> verts) {
    final out = <StrokePoint>[];
    for (final v in verts) {
      out.add(StrokePoint(v.dx, v.dy, 1));
    }
    out.add(StrokePoint(verts.first.dx, verts.first.dy, 1)); // close
    return out;
  }

  static List<StrokePoint> _rectangleOrQuad(List<Offset> verts) {
    // If all four edges are near horizontal/vertical, snap to the
    // axis-aligned bounding box (the common case when sketching a box).
    var axisAligned = true;
    for (var i = 0; i < 4; i++) {
      final a = verts[i];
      final b = verts[(i + 1) % 4];
      final ang = (math.atan2((b.dy - a.dy).abs(), (b.dx - a.dx).abs()));
      // angle from horizontal in [0, pi/2]; near 0 or near pi/2 is fine
      final offAxis = math.min(ang, math.pi / 2 - ang);
      if (offAxis > 0.30) {
        axisAligned = false;
        break;
      }
    }
    if (axisAligned) {
      double minX = verts.first.dx, maxX = verts.first.dx;
      double minY = verts.first.dy, maxY = verts.first.dy;
      for (final v in verts) {
        minX = math.min(minX, v.dx);
        maxX = math.max(maxX, v.dx);
        minY = math.min(minY, v.dy);
        maxY = math.max(maxY, v.dy);
      }
      return _polygon([
        Offset(minX, minY),
        Offset(maxX, minY),
        Offset(maxX, maxY),
        Offset(minX, maxY),
      ]);
    }
    return _polygon(verts);
  }

  static List<StrokePoint> _ellipse(List<StrokePoint> pts) {
    double minX = pts.first.x, maxX = pts.first.x;
    double minY = pts.first.y, maxY = pts.first.y;
    for (final p in pts) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    final cx = (minX + maxX) / 2, cy = (minY + maxY) / 2;
    var rx = (maxX - minX) / 2, ry = (maxY - minY) / 2;
    // Snap near-circles to perfect circles.
    if ((rx - ry).abs() / math.max(rx, ry) < 0.18) {
      final r = (rx + ry) / 2;
      rx = r;
      ry = r;
    }
    final out = <StrokePoint>[];
    const steps = 72;
    for (var i = 0; i <= steps; i++) {
      final t = 2 * math.pi * i / steps;
      out.add(StrokePoint(cx + rx * math.cos(t), cy + ry * math.sin(t), 1));
    }
    return out;
  }

  // ---------- geometry helpers ----------

  static double _pathLength(List<StrokePoint> pts) {
    var len = 0.0;
    for (var i = 1; i < pts.length; i++) {
      len += Offset(pts[i].x - pts[i - 1].x, pts[i].y - pts[i - 1].y).distance;
    }
    return len;
  }

  static double _perimeter(List<Offset> v, {required bool close}) {
    var len = 0.0;
    for (var i = 1; i < v.length; i++) {
      len += (v[i] - v[i - 1]).distance;
    }
    if (close && v.length > 2) len += (v.first - v.last).distance;
    return len;
  }

  static double _polygonArea(List<Offset> v) {
    var a = 0.0;
    for (var i = 0; i < v.length; i++) {
      final j = (i + 1) % v.length;
      a += v[i].dx * v[j].dy - v[j].dx * v[i].dy;
    }
    return a / 2;
  }

  /// Ramer–Douglas–Peucker simplification.
  static List<StrokePoint> _rdp(List<StrokePoint> pts,
      {required double epsilon}) {
    if (pts.length < 3) return List.of(pts);
    var maxDist = 0.0;
    var index = 0;
    final a = Offset(pts.first.x, pts.first.y);
    final b = Offset(pts.last.x, pts.last.y);
    for (var i = 1; i < pts.length - 1; i++) {
      final d = _pointToSegment(Offset(pts[i].x, pts[i].y), a, b);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (maxDist > epsilon) {
      final left = _rdp(pts.sublist(0, index + 1), epsilon: epsilon);
      final right = _rdp(pts.sublist(index), epsilon: epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    }
    return [pts.first, pts.last];
  }

  static double _pointToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
    if (len2 == 0) return (p - a).distance;
    var t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
    t = t.clamp(0.0, 1.0);
    final proj = a + Offset(ab.dx * t, ab.dy * t);
    return (p - proj).distance;
  }
}
