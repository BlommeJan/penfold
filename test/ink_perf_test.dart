import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/ink_coalesce.dart';
import 'package:penfold/models/models.dart';
import 'dart:ui';

void main() {
  group('adaptiveInkMinDist', () {
    test('returns slow floor at zero speed', () {
      expect(adaptiveInkMinDist(0), kInkMinDistSlow);
    });

    test('increases with speed', () {
      expect(adaptiveInkMinDist(2000), greaterThan(kInkMinDistCanonical));
    });

    test('clamps at max', () {
      expect(adaptiveInkMinDist(100000), kInkMaxDistCanonical);
    });
  });

  group('shouldAcceptInkPoint', () {
    test('accepts small moves at slow speed', () {
      const last = StrokePoint(0, 0, 0.5);
      expect(
        shouldAcceptInkPoint(
          last: last,
          newCanonical: const Offset(5, 0),
          speedCanonicalPerSec: 100,
        ),
        isTrue,
      );
    });

    test('rejects tiny moves below slow floor', () {
      const last = StrokePoint(0, 0, 0.5);
      expect(
        shouldAcceptInkPoint(
          last: last,
          newCanonical: const Offset(2, 0),
          speedCanonicalPerSec: 0,
        ),
        isFalse,
      );
    });

    test('accepts moves beyond adaptive gap', () {
      const last = StrokePoint(0, 0, 0.5);
      expect(
        shouldAcceptInkPoint(
          last: last,
          newCanonical: const Offset(50, 0),
          speedCanonicalPerSec: 0,
        ),
        isTrue,
      );
    });
  });

  group('shouldAppendFinalInkPoint', () {
    test('appends when release moved from last sample', () {
      const last = StrokePoint(0, 0, 0.5);
      expect(
        shouldAppendFinalInkPoint(
          last: last,
          newCanonical: const Offset(5, 0),
        ),
        isTrue,
      );
    });

    test('skips duplicate release position', () {
      const last = StrokePoint(0, 0, 0.5);
      expect(
        shouldAppendFinalInkPoint(
          last: last,
          newCanonical: const Offset(0.2, 0),
        ),
        isFalse,
      );
    });
  });

  group('coalesceInkPoints', () {
    test('reduces dense samples', () {
      final raw = <({Offset pos, double pressure, Duration t})>[];
      for (var i = 0; i < 100; i++) {
        raw.add((pos: Offset(i.toDouble(), 0), pressure: 0.5, t: Duration(microseconds: i * 1000)));
      }
      final out = coalesceInkPoints(raw);
      expect(out.length, lessThan(raw.length));
      expect(out.length, greaterThan(2));
    });
  });

  group('ink perf harness', () {
    test('fast stroke stays under point budget', () {
      // Simulate 2 s of fast writing at ~5000 canonical units/s.
      const speed = 5000.0;
      const durationSec = 2.0;
      final maxPts = estimateMaxPointsPerSecond(speedCanonicalPerSec: speed);
      final budget = (maxPts * durationSec).ceil();
      expect(budget, lessThan(800),
          reason: 'Fast strokes should stay under ~800 points / 2s');
    });
  });
}
