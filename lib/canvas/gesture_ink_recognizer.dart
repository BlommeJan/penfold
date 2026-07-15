import 'dart:math' as math;
import 'dart:ui';

import '../models/models.dart';

/// Minimum polyline length (canonical units) for a scratch gesture.
const scratchMinPathLength = 40.0;

/// Maximum polyline length — scratches are short zigzags, not long writing.
const scratchMaxPathLength = 800.0;

/// Horizontal direction reversals required (zigzag).
const scratchMinReversals = 2;

/// Minimum horizontal span relative to path length.
const scratchMinHorizontalSpanRatio = 0.15;

double polylineLengthCanonical(List<Offset> pts) {
  if (pts.length < 2) return 0;
  var len = 0.0;
  for (var i = 1; i < pts.length; i++) {
    len += (pts[i] - pts[i - 1]).distance;
  }
  return len;
}

Rect pathBounds(List<Offset> pts) {
  if (pts.isEmpty) return Rect.zero;
  var minX = pts.first.dx, maxX = pts.first.dx;
  var minY = pts.first.dy, maxY = pts.first.dy;
  for (final p in pts) {
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
    minY = math.min(minY, p.dy);
    maxY = math.max(maxY, p.dy);
  }
  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

int countHorizontalReversals(List<Offset> pts) {
  var reversals = 0;
  int? lastSign;
  for (var i = 1; i < pts.length; i++) {
    final dx = pts[i].dx - pts[i - 1].dx;
    if (dx.abs() < 2) continue;
    final sign = dx > 0 ? 1 : -1;
    if (lastSign != null && sign != lastSign) reversals++;
    lastSign = sign;
  }
  return reversals;
}

/// True when [canonicalPath] looks like a quick scratch-out zigzag.
bool isScratchGesture(List<Offset> canonicalPath) {
  if (canonicalPath.length < 4) return false;

  final len = polylineLengthCanonical(canonicalPath);
  if (len < scratchMinPathLength || len > scratchMaxPathLength) return false;
  if (countHorizontalReversals(canonicalPath) < scratchMinReversals) {
    return false;
  }

  final bounds = pathBounds(canonicalPath);
  if (bounds.width <= 0 || bounds.height <= 0) return false;

  final diagonal = math.sqrt(
    bounds.width * bounds.width + bounds.height * bounds.height,
  );
  if (len > diagonal * 4) return false;

  if (bounds.width / len < scratchMinHorizontalSpanRatio) return false;

  return true;
}

bool pathIntersectsRect(List<Offset> path, Rect rect) {
  if (!pathBounds(path).overlaps(rect)) return false;
  for (final p in path) {
    if (rect.contains(p)) return true;
  }
  for (var i = 1; i < path.length; i++) {
    final mid = Offset.lerp(path[i - 1], path[i], 0.5)!;
    if (rect.contains(mid)) return true;
  }
  return false;
}

/// Returns the topmost indexed stroke whose bounds the scratch crosses.
Stroke? findScratchDeleteTarget({
  required List<Offset> canonicalPath,
  required List<Stroke> strokes,
  required Set<String> indexedStrokeIds,
}) {
  if (!isScratchGesture(canonicalPath)) return null;

  Stroke? best;
  for (final s in strokes) {
    if (!indexedStrokeIds.contains(s.id)) continue;
    if (s.tool == ToolType.tape) continue;
    if (!pathIntersectsRect(canonicalPath, s.bounds)) continue;
    if (best == null || s.z > best.z) best = s;
  }
  return best;
}
