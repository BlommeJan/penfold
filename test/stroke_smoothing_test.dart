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

    test('preserves endpoints', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 50, 0.6),
        StrokePoint(100, 0, 0.7),
      ];
      final out = smoothStrokePoints(pts);
      expect(out.first.x, pts.first.x);
      expect(out.first.y, pts.first.y);
      expect(out.last.x, pts.last.x);
      expect(out.last.y, pts.last.y);
    });

    test('rounds sharp corners', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(50, 0, 0.5),
        StrokePoint(50, 50, 0.5),
      ];
      final out = smoothStrokePoints(pts);
      expect(out.length, greaterThan(pts.length));
      final mid = out[out.length ~/ 2];
      expect(mid.y, lessThan(50));
      expect(mid.y, greaterThan(0));
    });

    test('interpolates pressure', () {
      const pts = [
        StrokePoint(0, 0, 0.2),
        StrokePoint(100, 0, 0.8),
        StrokePoint(200, 0, 1.0),
      ];
      final out = smoothStrokePoints(pts);
      for (final p in out) {
        expect(p.p, inInclusiveRange(0.2, 1.0));
      }
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
      final out = maybeSmoothStrokePoints(pts, enabled: true);
      expect(out.length, greaterThan(pts.length));
    });
  });

  group('StrokeSmoothingService', () {
    test('defaults to enabled', () async {
      await StrokeSmoothingService.instance.load();
      expect(StrokeSmoothingService.instance.enabled, isTrue);
    });

    test('save and load roundtrip', () async {
      await StrokeSmoothingService.instance.setEnabled(false);
      StrokeSmoothingService.instance.resetForTests();
      await StrokeSmoothingService.instance.load();
      expect(StrokeSmoothingService.instance.enabled, isFalse);
    });

    test('load respects stored preference', () async {
      SharedPreferences.setMockInitialValues({
        StrokeSmoothingService.prefKey: false,
      });
      StrokeSmoothingService.instance.resetForTests();
      await StrokeSmoothingService.instance.load();
      expect(StrokeSmoothingService.instance.enabled, isFalse);
    });
  });

  group('corner geometry', () {
    test('right-angle corner gets intermediate points along both legs', () {
      const pts = [
        StrokePoint(0, 0, 0.5),
        StrokePoint(100, 0, 0.5),
        StrokePoint(100, 100, 0.5),
      ];
      final out = smoothStrokePoints(pts);
      expect(out.length, greaterThan(pts.length));
      expect(out.any((p) => p.y == 0 && p.x > 0 && p.x < 100), isTrue);
      expect(out.any((p) => p.x == 100 && p.y > 0 && p.y < 100), isTrue);
    });
  });
}
