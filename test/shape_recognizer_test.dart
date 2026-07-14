import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/shape_recognizer.dart';
import 'package:penfold/models/models.dart';

List<StrokePoint> _noisy(List<StrokePoint> pts, double amp, int seed) {
  final r = math.Random(seed);
  return pts
      .map((p) => StrokePoint(p.x + (r.nextDouble() - 0.5) * amp,
          p.y + (r.nextDouble() - 0.5) * amp, 1))
      .toList();
}

void main() {
  group('ShapeRecognizer', () {
    test('recognizes a wobbly straight line as a 2-point line', () {
      final pts = <StrokePoint>[
        for (var i = 0; i <= 50; i++)
          StrokePoint(100 + i * 6.0, 200 + i * 2.0, 1),
      ];
      final out = ShapeRecognizer.recognize(_noisy(pts, 3, 1));
      expect(out, isNotNull);
      expect(out!.length, 2);
      // Endpoints near the input endpoints.
      expect((out.first.x - 100).abs(), lessThan(10));
      expect((out.last.x - 400).abs(), lessThan(10));
    });

    test('recognizes a hand-drawn rectangle and axis-snaps it', () {
      final pts = <StrokePoint>[];
      // top edge, right edge, bottom edge, left edge
      for (var i = 0; i <= 20; i++) {
        pts.add(StrokePoint(100 + i * 10.0, 100, 1));
      }
      for (var i = 0; i <= 15; i++) {
        pts.add(StrokePoint(300, 100 + i * 10.0, 1));
      }
      for (var i = 0; i <= 20; i++) {
        pts.add(StrokePoint(300 - i * 10.0, 250, 1));
      }
      for (var i = 0; i <= 15; i++) {
        pts.add(StrokePoint(100, 250 - i * 10.0, 1));
      }
      final out = ShapeRecognizer.recognize(_noisy(pts, 6, 2));
      expect(out, isNotNull);
      expect(out!.length, 5); // 4 corners + closing point
      // Axis-snapped: all x are ~100 or ~300, all y ~100 or ~250.
      for (final p in out) {
        expect(
            (p.x - 100).abs() < 12 || (p.x - 300).abs() < 12, isTrue,
            reason: 'x=${p.x} not near 100/300');
        expect(
            (p.y - 100).abs() < 12 || (p.y - 250).abs() < 12, isTrue,
            reason: 'y=${p.y} not near 100/250');
      }
    });

    test('recognizes a rough circle and snaps to a perfect circle', () {
      final pts = <StrokePoint>[
        for (var i = 0; i <= 60; i++)
          StrokePoint(300 + 90 * math.cos(2 * math.pi * i / 60),
              300 + 92 * math.sin(2 * math.pi * i / 60), 1),
      ];
      final out = ShapeRecognizer.recognize(_noisy(pts, 8, 3));
      expect(out, isNotNull);
      expect(out!.length, greaterThan(30)); // ellipse point ring
      // All output points equidistant from center (perfect circle snap).
      // The ring closes on itself, so drop the duplicated last point
      // before computing the centroid (it would bias the center).
      final ring = out.sublist(0, out.length - 1);
      final cx = ring.map((p) => p.x).reduce((a, b) => a + b) / ring.length;
      final cy = ring.map((p) => p.y).reduce((a, b) => a + b) / ring.length;
      final radii = out
          .map((p) =>
              math.sqrt(math.pow(p.x - cx, 2) + math.pow(p.y - cy, 2)))
          .toList();
      final minR = radii.reduce(math.min);
      final maxR = radii.reduce(math.max);
      expect(maxR - minR, lessThan(2.0));
    });

    test('recognizes a triangle', () {
      final pts = <StrokePoint>[];
      const a = (100.0, 300.0), b = (300.0, 300.0), c = (200.0, 120.0);
      void edge((double, double) p1, (double, double) p2) {
        for (var i = 0; i <= 20; i++) {
          final t = i / 20;
          pts.add(StrokePoint(
              p1.$1 + (p2.$1 - p1.$1) * t, p1.$2 + (p2.$2 - p1.$2) * t, 1));
        }
      }

      edge(a, b);
      edge(b, c);
      edge(c, a);
      final out = ShapeRecognizer.recognize(_noisy(pts, 5, 4));
      expect(out, isNotNull);
      expect(out!.length, 4); // 3 vertices + close
    });

    test('leaves an open scribble alone', () {
      final r = math.Random(5);
      final pts = <StrokePoint>[
        for (var i = 0; i < 80; i++)
          StrokePoint(100 + i * 4.0 + r.nextDouble() * 60,
              200 + math.sin(i / 3) * 80 + r.nextDouble() * 60, 1),
      ];
      // Open + not straight -> null (keep raw ink).
      final out = ShapeRecognizer.recognize(pts);
      expect(out, isNull);
    });

    test('ignores tiny strokes (dots)', () {
      final pts = [
        const StrokePoint(10, 10, 1),
        const StrokePoint(11, 11, 1),
        const StrokePoint(12, 10, 1),
        const StrokePoint(11, 9, 1),
      ];
      expect(ShapeRecognizer.recognize(pts), isNull);
    });
  });
}
