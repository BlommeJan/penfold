import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/stroke_eraser.dart';

void main() {
  Stroke horizontalLine({
    String id = 's1',
    ToolType tool = ToolType.pen,
    BrushStyle brushStyle = BrushStyle.pen,
  }) =>
      Stroke(
        id: id,
        pageId: 'p1',
        tool: tool,
        brushStyle: brushStyle,
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

  group('finalizePartialSegments', () {
    test('drops micro-fragments with too few points', () {
      final clipped = [
        [const StrokePoint(0, 0, 0.5), const StrokePoint(1, 0, 0.5)],
        [
          const StrokePoint(10, 0, 0.5),
          const StrokePoint(20, 0, 0.5),
          const StrokePoint(30, 0, 0.5),
        ],
      ];
      final out = finalizePartialSegments(clipped);
      expect(out.length, 1);
      expect(out.first.length, 3);
    });

    test('caps fragments to two longest segments', () {
      final clipped = [
        [
          const StrokePoint(0, 0, 0.5),
          const StrokePoint(10, 0, 0.5),
          const StrokePoint(20, 0, 0.5),
        ],
        [
          const StrokePoint(30, 0, 0.5),
          const StrokePoint(40, 0, 0.5),
          const StrokePoint(50, 0, 0.5),
        ],
        [
          const StrokePoint(60, 0, 0.5),
          const StrokePoint(70, 0, 0.5),
          const StrokePoint(80, 0, 0.5),
        ],
      ];
      final out = finalizePartialSegments(clipped);
      expect(out.length, kMaxPartialEraseFragments);
      expect(segmentPolylineLength(out.first), greaterThanOrEqualTo(20));
    });
  });

  group('shouldWholeStrokeErase', () {
    test('highlighter uses whole-stroke erase', () {
      expect(
        shouldWholeStrokeErase(horizontalLine(tool: ToolType.highlighter)),
        isTrue,
      );
    });

    test('tape uses whole-stroke erase', () {
      expect(
        shouldWholeStrokeErase(horizontalLine(tool: ToolType.tape)),
        isTrue,
      );
    });

    test('marker brush uses whole-stroke erase', () {
      expect(
        shouldWholeStrokeErase(
          horizontalLine(brushStyle: BrushStyle.marker),
        ),
        isTrue,
      );
    });

    test('pen ink allows partial erase', () {
      expect(shouldWholeStrokeErase(horizontalLine()), isFalse);
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

    test('splits pen stroke into at most two segments', () {
      final s = horizontalLine();
      final r = partialEraseStroke(s, const Offset(50, 50), 12)!;
      expect(r.segments.length, lessThanOrEqualTo(kMaxPartialEraseFragments));
      for (final seg in r.segments) {
        expect(seg.points.length, greaterThanOrEqualTo(2));
        expect(seg.tool, ToolType.pen);
        expect(seg.color, s.color);
        expect(seg.width, s.width);
      }
    });

    test('whole-erases highlighter without splitting', () {
      final s = horizontalLine(tool: ToolType.highlighter);
      final r = partialEraseStroke(s, const Offset(50, 50), 12)!;
      expect(r.segments, isEmpty);
    });

    test('whole-erases marker brush without splitting', () {
      final s = horizontalLine(brushStyle: BrushStyle.marker);
      final r = partialEraseStroke(s, const Offset(50, 50), 12)!;
      expect(r.segments, isEmpty);
    });

    test('repeated partial erase does not explode fragment count', () {
      var current = horizontalLine();
      var totalSegments = 1;
      for (final center in [
        const Offset(25, 50),
        const Offset(50, 50),
        const Offset(75, 50),
      ]) {
        final r = partialEraseStroke(current, center, 10);
        if (r == null) continue;
        if (r.segments.isEmpty) {
          totalSegments = 0;
          break;
        }
        totalSegments = r.segments.length;
        final seg = r.segments.first;
        current = Stroke(
          id: 'seg',
          pageId: seg.pageId,
          tool: seg.tool,
          brushStyle: seg.brushStyle,
          color: seg.color,
          width: seg.width,
          points: List.of(seg.points),
          z: seg.z,
        );
      }
      expect(totalSegments, lessThanOrEqualTo(kMaxPartialEraseFragments));
    });
  });

  group('EraserMode', () {
    test('has whole and partial variants', () {
      expect(EraserMode.values, contains(EraserMode.wholeStroke));
      expect(EraserMode.values, contains(EraserMode.partial));
    });
  });
}
