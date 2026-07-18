import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/stroke_smoothing.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/stroke_smoothing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StrokeSmoothingService.instance.resetForTests();
  });

  group('smoothStrokePoints', () {
    test('returns copy when fewer than three points', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(10, 0, 0.6),
      ];
      final out = smoothStrokePoints(pts);
      expect(out, pts);
      expect(identical(out, pts), isFalse);
    });

    test('returns copy when strength is zero', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 0, 0.5),
        StrokePoint(50, 50, 0.5),
      ];
      final out = smoothStrokePoints(pts, strength: 0);
      expect(out, pts);
    });

    test('preserves endpoints', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 50, 0.6),
        StrokePoint(100, 0, 0.7),
      ];
      final out = smoothStrokePoints(pts, strength: 1.0);
      expect(out.first.x, closeTo(pts.first.x, 0.01));
      expect(out.first.y, closeTo(pts.first.y, 0.01));
      expect(out.last.x, closeTo(pts.last.x, 0.01));
      expect(out.last.y, closeTo(pts.last.y, 0.01));
    });

    test('rounds sharp corners at high strength', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 0, 0.5),
        StrokePoint(50, 50, 0.5),
      ];
      final out = smoothStrokePoints(pts, strength: 1.0);
      expect(out.length, greaterThan(pts.length));
      final mid = out[out.length ~/ 2];
      expect(mid.y, lessThan(50));
      expect(mid.y, greaterThan(0));
    });

    test('preserves small handwriting at recommended strength', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(4, 1, 0.5),
        StrokePoint(8, 0, 0.5),
        StrokePoint(12, 1, 0.5),
      ];
      final out = smoothStrokePoints(
        pts,
        strength: StrokeSmoothingService.recommendedStrength,
      );
      final maxY = out.map((p) => p.y).reduce((a, b) => a > b ? a : b);
      expect(maxY, lessThan(2.5),
          reason: 'Small loops should not be collapsed inward');
    });

    test('interpolates pressure', () {
      const pts = [
        StrokePoint(0, 0, 0.2),
        StrokePoint(100, 0, 0.8),
        StrokePoint(200, 0, 1.0),
      ];
      final out = smoothStrokePoints(pts, strength: 0.8);
      for (final p in out) {
        expect(p.p, inInclusiveRange(0.2, 1.0));
      }
    });
  });

  group('smoothingMinSegmentLength', () {
    test('increases threshold as strength decreases', () {
      expect(
        smoothingMinSegmentLength(0.2),
        greaterThan(smoothingMinSegmentLength(0.8)),
      );
    });
  });

  group('maybeSmoothStrokePoints', () {
    test('passes through when disabled', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 50, 0.6),
        StrokePoint(100, 0, 0.7),
      ];
      final out = maybeSmoothStrokePoints(pts, enabled: false);
      expect(out, pts);
    });

    test('smooths when enabled', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 0, 0.5),
        StrokePoint(50, 50, 0.5),
      ];
      final out = maybeSmoothStrokePoints(pts, enabled: true, strength: 1.0);
      expect(out.length, greaterThan(pts.length));
    });
  });

  group('StrokeSmoothingService', () {
    test('defaults to enabled with recommended strength', () async {
      await StrokeSmoothingService.instance.load();
      expect(StrokeSmoothingService.instance.enabled, isTrue);
      expect(
        StrokeSmoothingService.instance.strength,
        StrokeSmoothingService.recommendedStrength,
      );
    });

    test('save and load roundtrip', () async {
      await StrokeSmoothingService.instance.setEnabled(false);
      await StrokeSmoothingService.instance.setStrength(0.6);
      StrokeSmoothingService.instance.resetForTests();
      await StrokeSmoothingService.instance.load();
      expect(StrokeSmoothingService.instance.enabled, isFalse);
      expect(StrokeSmoothingService.instance.strength, 0.6);
    });

    test('load respects stored preference', () async {
      SharedPreferences.setMockInitialValues({
        StrokeSmoothingService.prefKey: false,
        StrokeSmoothingService.prefKeyStrength: 0.15,
      });
      StrokeSmoothingService.instance.resetForTests();
      await StrokeSmoothingService.instance.load();
      expect(StrokeSmoothingService.instance.enabled, isFalse);
      expect(StrokeSmoothingService.instance.strength, 0.15);
    });
  });

  group('corner geometry', () {
    test('right-angle corner gets intermediate points along both legs', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(100, 0, 0.5),
        StrokePoint(100, 100, 0.5),
      ];
      final out = smoothStrokePoints(pts, strength: 1.0);
      expect(out.length, greaterThan(pts.length));
      expect(
        out.any((p) => p.x > 20 && p.x < 80 && p.y > 0 && p.y < 80),
        isTrue,
        reason: 'Corner should gain interior curve points',
      );
    });
  });
}
