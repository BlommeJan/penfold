import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/drawing_canvas.dart';
import 'package:penfold/models/models.dart';

void main() {
  group('Lasso rotate handles', () {
    test('lasso tool shows transform handles when selection exists', () {
      expect(
        showsTransformHandlesForTests(
          tool: ToolType.lasso,
          hasSelection: true,
        ),
        isTrue,
      );
      expect(
        showsTransformHandlesForTests(
          tool: ToolType.lasso,
          hasSelection: false,
        ),
        isFalse,
      );
      expect(
        showsTransformHandlesForTests(
          tool: ToolType.pen,
          hasSelection: true,
        ),
        isFalse,
      );
    });

    test('rotate handle sits above inflated selection bounds', () {
      const bounds = Rect.fromLTWH(100, 200, 120, 80);
      final inflated = bounds.inflate(6);
      final rotatePt =
          inflated.center + Offset(0, -inflated.height / 2 - 28);

      expect(
        hitSelectionHandleForTests(pos: rotatePt, displayBounds: bounds),
        SelectionHandleKind.rotate,
      );
      expect(
        hitSelectionHandleForTests(
          pos: rotatePt + const Offset(30, 0),
          displayBounds: bounds,
        ),
        isNot(SelectionHandleKind.rotate),
      );
    });

    test('corner handles hit within 22px radius', () {
      const bounds = Rect.fromLTWH(50, 50, 100, 60);
      final inflated = bounds.inflate(6);

      expect(
        hitSelectionHandleForTests(pos: inflated.topLeft, displayBounds: bounds),
        SelectionHandleKind.nw,
      );
      expect(
        hitSelectionHandleForTests(
            pos: inflated.bottomRight, displayBounds: bounds),
        SelectionHandleKind.se,
      );
      expect(
        hitSelectionHandleForTests(
          pos: inflated.topLeft + const Offset(25, 25),
          displayBounds: bounds,
        ),
        isNot(SelectionHandleKind.nw),
      );
    });

    test('body hit inside selection but not on handles', () {
      const bounds = Rect.fromLTWH(0, 0, 200, 100);
      expect(
        hitSelectionHandleForTests(
          pos: const Offset(100, 50),
          displayBounds: bounds,
        ),
        SelectionHandleKind.body,
      );
    });

    test('rotated selection maps rotate handle in display space', () {
      const bounds = Rect.fromLTWH(100, 100, 80, 40);
      const rotation = math.pi / 4;
      final inflated = bounds.inflate(6);
      final localRotate =
          inflated.center + Offset(0, -inflated.height / 2 - 28);

      final cos = math.cos(rotation);
      final sin = math.sin(rotation);
      final center = inflated.center;
      final dx = localRotate.dx - center.dx;
      final dy = localRotate.dy - center.dy;
      final displayRotate = Offset(
        center.dx + dx * cos - dy * sin,
        center.dy + dx * sin + dy * cos,
      );

      expect(
        hitSelectionHandleForTests(
          pos: displayRotate,
          displayBounds: bounds,
          selectionRotation: rotation,
        ),
        SelectionHandleKind.rotate,
      );
    });

    test('canonical rotation moves point around pivot', () {
      const pivot = Offset(100, 100);
      const point = Offset(150, 100);
      const quarterTurn = math.pi / 2;

      final rotated =
          rotateCanonicalPointForTests(point, pivot, quarterTurn);
      expect(rotated.dx, closeTo(100, 0.001));
      expect(rotated.dy, closeTo(150, 0.001));
    });

    test('unrotateDisplayPointForTests inverts canvas rotation', () {
      const bounds = Rect.fromLTWH(0, 0, 100, 50);
      const rotation = math.pi / 6;
      const original = Offset(80, 20);

      final center = bounds.center;
      final dx = original.dx - center.dx;
      final dy = original.dy - center.dy;
      final cos = math.cos(rotation);
      final sin = math.sin(rotation);
      final rotated = Offset(
        center.dx + dx * cos - dy * sin,
        center.dy + dx * sin + dy * cos,
      );

      final restored =
          unrotateDisplayPointForTests(rotated, bounds, rotation);
      expect(restored.dx, closeTo(original.dx, 0.001));
      expect(restored.dy, closeTo(original.dy, 0.001));
    });
  });
}
