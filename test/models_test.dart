import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'dart:ui';

void main() {
  group('Stroke', () {
    Stroke make() => Stroke(
          id: 's1',
          pageId: 'p1',
          tool: ToolType.pen,
          color: 0xFF112233,
          width: 3.5,
          points: const [
            StrokePoint(10, 20, 0.5),
            StrokePoint(30, 40, 0.9),
            StrokePoint(15, 60, 0.7),
          ],
          z: 7,
        );

    test('points JSON roundtrip preserves data', () {
      final s = make();
      final decoded = Stroke.decodePoints(s.encodePoints());
      expect(decoded.length, 3);
      expect(decoded[1].x, 30);
      expect(decoded[1].y, 40);
      expect(decoded[1].p, 0.9);
    });

    test('row roundtrip preserves everything', () {
      final s = make();
      final back = Stroke.fromRow(s.toRow());
      expect(back.id, s.id);
      expect(back.tool, ToolType.pen);
      expect(back.color, 0xFF112233);
      expect(back.width, 3.5);
      expect(back.z, 7);
      expect(back.points.length, 3);
    });

    test('bounds contain all points padded by width', () {
      final b = make().bounds;
      expect(b.left, lessThanOrEqualTo(10));
      expect(b.right, greaterThanOrEqualTo(30));
      expect(b.top, lessThanOrEqualTo(20));
      expect(b.bottom, greaterThanOrEqualTo(60));
    });

    test('translate shifts all points', () {
      final s = make()..translate(const Offset(5, -5));
      expect(s.points.first.x, 15);
      expect(s.points.first.y, 15);
      expect(s.points.first.p, 0.5); // pressure untouched
    });
  });

  group('PageImage', () {
    test('rect get/set roundtrip', () {
      final img = PageImage(
          id: 'i1', pageId: 'p1', path: '/x.png', x: 1, y: 2, w: 3, h: 4, z: 0);
      expect(img.rect, const Rect.fromLTWH(1, 2, 3, 4));
      img.rect = const Rect.fromLTWH(10, 20, 30, 40);
      expect(img.x, 10);
      expect(img.h, 40);
      final back = PageImage.fromRow(img.toRow());
      expect(back.rect, img.rect);
    });
  });

  group('Notebook / NotePage', () {
    test('row roundtrips', () {
      final n = Notebook(
          id: 'n1',
          title: 'Test',
          coverColor: 0xFF123456,
          template: PageTemplate.grid,
          createdAt: 1,
          updatedAt: 2);
      final nb = Notebook.fromRow(n.toRow());
      expect(nb.template, PageTemplate.grid);

      final pg = NotePage(
          id: 'p1',
          notebookId: 'n1',
          index: 3,
          template: PageTemplate.dotted,
          pdfImagePath: '/a.png',
          aspect: 1.5);
      final back = NotePage.fromRow(pg.toRow());
      expect(back.pdfImagePath, '/a.png');
      expect(back.aspect, 1.5);
      expect(back.index, 3);
    });
  });
}
