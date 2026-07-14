import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/stroke_eraser.dart';
import 'dart:ui';

void main() {
  Stroke horizontalLine() => Stroke(
        id: 's1',
        pageId: 'p1',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 4,
        points: const [
          StrokePoint(0, 50, 0.5),
          StrokePoint(100, 50, 0.5),
        ],
        z: 1,
      );

  group('clipStrokePoints', () {
    test('miss returns original points', () {
      final pts = horizontalLine().points;
      final out = clipStrokePoints(pts, const Offset(200, 200), 10);
      expect(out.length, 1);
      expect(out.first.length, 2);
    });

    test('full erase returns empty', () {
      final pts = horizontalLine().points;
      final out = clipStrokePoints(pts, const Offset(50, 50), 55);
      expect(out, isEmpty);
    });

    test('middle erase splits into two segments', () {
      final pts = horizontalLine().points;
      final out = clipStrokePoints(pts, const Offset(50, 50), 12);
      expect(out.length, 2);
      expect(out[0].first.x, lessThan(50));
      expect(out[1].last.x, greaterThan(50));
    });
  });

  group('partialEraseStroke', () {
    test('returns null on miss', () {
      final s = horizontalLine();
      expect(
        partialEraseStroke(s, const Offset(500, 500), 10),
        isNull,
      );
    });

    test('removes stroke entirely when fully erased', () {
      final s = horizontalLine();
      final r = partialEraseStroke(s, const Offset(50, 50), 55)!;
      expect(r.original.id, 's1');
      expect(r.segments, isEmpty);
    });

    test('splits stroke into segments', () {
      final s = horizontalLine();
      final r = partialEraseStroke(s, const Offset(50, 50), 12)!;
      expect(r.segments.length, 2);
      for (final seg in r.segments) {
        expect(seg.points.length, greaterThanOrEqualTo(2));
        expect(seg.tool, ToolType.pen);
        expect(seg.color, s.color);
        expect(seg.width, s.width);
      }
    });
  });

  group('EraserMode', () {
    test('has whole and partial variants', () {
      expect(EraserMode.values, contains(EraserMode.wholeStroke));
      expect(EraserMode.values, contains(EraserMode.partial));
    });
  });
}
