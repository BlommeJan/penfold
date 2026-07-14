import 'dart:ui';

import '../models/models.dart';

/// Minimum gap between ink samples in canonical 0.1 mm units at low speed.
const double kInkMinDistCanonical = 12; // ~1.2 display px at typical scale

/// Maximum gap allowed when moving very fast (reduces point count).
const double kInkMaxDistCanonical = 80; // ~8 mm

/// Adaptive minimum distance before accepting a new ink sample.
///
/// [speedCanonicalPerSec] is stroke speed in canonical units per second.
/// Faster strokes use a larger gap to keep point count bounded without
/// visible stair-stepping on typical Tab displays.
double adaptiveInkMinDist(double speedCanonicalPerSec) {
  if (speedCanonicalPerSec <= 0) return kInkMinDistCanonical;
  // Scale gap with speed; clamp to sane bounds.
  final scaled = kInkMinDistCanonical + speedCanonicalPerSec * 0.004;
  return scaled.clamp(kInkMinDistCanonical, kInkMaxDistCanonical);
}

/// Returns true when [newCanonical] is far enough from [last] to record.
bool shouldAcceptInkPoint({
  required StrokePoint last,
  required Offset newCanonical,
  required double speedCanonicalPerSec,
}) {
  final dist =
      Offset(newCanonical.dx - last.x, newCanonical.dy - last.y).distance;
  return dist >= adaptiveInkMinDist(speedCanonicalPerSec);
}

/// Estimate speed from two canonical positions and elapsed [dt].
double inkSpeedCanonicalPerSec(Offset from, Offset to, Duration dt) {
  if (dt.inMicroseconds <= 0) return 0;
  final dist = (to - from).distance;
  return dist / (dt.inMicroseconds / 1e6);
}

/// Build a coalesced point list from raw move events (for tests/benchmarks).
List<StrokePoint> coalesceInkPoints(
  List<({Offset pos, double pressure, Duration t})> raw,
) {
  if (raw.isEmpty) return const [];
  final out = <StrokePoint>[
    StrokePoint(raw.first.pos.dx, raw.first.pos.dy, raw.first.pressure),
  ];
  for (var i = 1; i < raw.length; i++) {
    final prev = raw[i - 1];
    final cur = raw[i];
    final last = out.last;
    final speed = inkSpeedCanonicalPerSec(prev.pos, cur.pos, cur.t - prev.t);
    if (shouldAcceptInkPoint(
      last: last,
      newCanonical: cur.pos,
      speedCanonicalPerSec: speed,
    )) {
      out.add(StrokePoint(cur.pos.dx, cur.pos.dy, cur.pressure));
    }
  }
  return out;
}

/// Rough upper bound on points per second after coalescing (benchmark helper).
int estimateMaxPointsPerSecond({double speedCanonicalPerSec = 5000}) {
  final minDist = adaptiveInkMinDist(speedCanonicalPerSec);
  return (speedCanonicalPerSec / minDist).ceil();
}
