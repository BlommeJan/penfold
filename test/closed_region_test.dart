import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/closed_region.dart';
import 'package:penfold/models/models.dart';

Stroke _rectangleStroke({
  required String id,
  double x = 100,
  double y = 100,
  double size = 200,
  int z = 1,
}) {
  return Stroke(
    id: id,
    pageId: 'page',
    tool: ToolType.shape,
    color: 0xFF000000,
    width: 3,
    z: z,
    points: [
      StrokePoint(x, y, 1),
      StrokePoint(x + size, y, 1),
      StrokePoint(x + size, y + size, 1),
      StrokePoint(x, y + size, 1),
      StrokePoint(x, y, 1),
    ],
  );
}

void main() {
  group('pointInPolygon', () {
    test('detects inside and outside for axis-aligned square', () {
      const poly = [
        Offset(0, 0),
        Offset(100, 0),
        Offset(100, 100),
        Offset(0, 100),
      ];
      expect(pointInPolygon(const Offset(50, 50), poly), isTrue);
      expect(pointInPolygon(const Offset(150, 50), poly), isFalse);
    });
  });

  group('closedPolygonFromStroke', () {
    test('returns polygon for closed shape stroke', () {
      final poly = closedPolygonFromStroke(_rectangleStroke(id: 's1'));
      expect(poly, isNotNull);
      expect(poly!.length, greaterThanOrEqualTo(4));
      expect(polygonAreaAbs(poly), greaterThan(kMinClosedRegionArea));
    });

    test('returns null for open pen stroke', () {
      final stroke = Stroke(
        id: 'open',
        pageId: 'page',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 3,
        z: 1,
        points: [
          StrokePoint(0, 0, 1),
          StrokePoint(200, 0, 1),
          StrokePoint(200, 50, 1),
        ],
      );
      expect(closedPolygonFromStroke(stroke), isNull);
    });

    test('recognizes nearly-closed freehand rectangle', () {
      final pts = <StrokePoint>[];
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
      pts.add(StrokePoint(102, 101, 1));

      final stroke = Stroke(
        id: 'freehand',
        pageId: 'page',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 3,
        z: 1,
        points: pts,
      );

      final poly = closedPolygonFromStroke(stroke);
      expect(poly, isNotNull);
      expect(pointInPolygon(const Offset(200, 175), poly!), isTrue);
    });
  });

  group('findClosedRegionAt', () {
    test('returns innermost region when shapes are nested', () {
      final outer = _rectangleStroke(id: 'outer', x: 50, y: 50, size: 300);
      final inner = _rectangleStroke(id: 'inner', x: 120, y: 120, size: 80);
      final poly = findClosedRegionAt(const Offset(160, 160), [outer, inner]);
      expect(poly, isNotNull);
      expect(polygonAreaAbs(poly!), lessThan(polygonAreaAbs(
          closedPolygonFromStroke(outer)!)));
      expect(pointInPolygon(const Offset(160, 160), poly), isTrue);
    });

    test('returns null when tap is outside all closed strokes', () {
      final outer = _rectangleStroke(id: 'outer');
      expect(
        findClosedRegionAt(const Offset(10, 10), [outer]),
        isNull,
      );
    });

    test('prefers topmost stroke when regions overlap same area', () {
      final lower = _rectangleStroke(id: 'lower', z: 1);
      final upper = Stroke(
        id: 'upper',
        pageId: 'page',
        tool: ToolType.shape,
        color: 0xFF000000,
        width: 3,
        z: 2,
        points: lower.points,
      );
      final poly = findClosedRegionAt(const Offset(200, 200), [lower, upper]);
      expect(poly, isNotNull);
      expect(pointInPolygon(const Offset(200, 200), poly!), isTrue);
    });
  });
}
