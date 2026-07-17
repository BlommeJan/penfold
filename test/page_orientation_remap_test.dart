import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/page_coords.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/page_orientation_remap.dart';

void main() {
  test('orientationFitTransform centers and scales into new bounds', () {
    const bounds = Rect.fromLTRB(100, 100, 500, 900);
    const newSize = Size(2970, 2100);
    final fit = orientationFitTransform(
      contentBounds: bounds,
      newSize: newSize,
    );
    expect(fit.scale, greaterThan(0));

    final corners = [
      bounds.topLeft,
      bounds.topRight,
      bounds.bottomLeft,
      bounds.bottomRight,
    ];
    for (final c in corners) {
      final p = remapCanonicalPoint(c, fit.scale, fit.translation);
      expect(p.dx, inInclusiveRange(0, newSize.width));
      expect(p.dy, inInclusiveRange(0, newSize.height));
    }

    final mappedCenter =
        remapCanonicalPoint(bounds.center, fit.scale, fit.translation);
    expect(mappedCenter.dx, closeTo(newSize.width / 2, 1));
    expect(mappedCenter.dy, closeTo(newSize.height / 2, 1));
  });

  test('remapPageContent fits tall portrait ink into landscape', () {
    final strokes = [
      Stroke(
        id: 's1',
        pageId: 'pg1',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 10,
        points: const [
          StrokePoint(200, 100, 0.5),
          StrokePoint(300, 2800, 0.5),
        ],
        z: 0,
      ),
    ];
    final result = remapPageContent(
      pageSize: PageSize.a4,
      from: PageOrientation.portrait,
      to: PageOrientation.landscape,
      strokes: strokes,
      fills: const [],
      images: const [],
      texts: const [],
    );
    expect(result, isNotNull);
    final landscape =
        PageCoords.canonicalSize(PageSize.a4, orientation: PageOrientation.landscape);
    for (final pt in result!.strokes.single.points) {
      expect(pt.x, inInclusiveRange(0, landscape.width));
      expect(pt.y, inInclusiveRange(0, landscape.height));
    }
    expect(result.strokes.single.width, closeTo(10 * result.scale, 0.01));
  });
}
