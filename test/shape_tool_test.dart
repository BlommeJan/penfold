import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/drawing_canvas.dart';
import 'package:penfold/canvas/painters.dart';
import 'package:penfold/models/models.dart';

void main() {
  group('shape tool', () {
    test('shape strokes are visible on the ink layer', () {
      final stroke = Stroke(
        id: 's1',
        pageId: 'pg1',
        tool: ToolType.shape,
        color: 0xFF000000,
        width: 3,
        points: const [
          StrokePoint(0, 0, 1),
          StrokePoint(100, 0, 1),
          StrokePoint(100, 80, 1),
          StrokePoint(0, 80, 1),
          StrokePoint(0, 0, 1),
        ],
        z: 1,
      );

      expect(inkStrokeVisibleOnCanvas(stroke), isTrue);
    });

    test('pen strokes remain visible on the ink layer', () {
      final stroke = Stroke(
        id: 's2',
        pageId: 'pg1',
        tool: ToolType.pen,
        color: 0xFF000000,
        width: 3,
        points: const [StrokePoint(0, 0, 1), StrokePoint(50, 50, 1)],
        z: 1,
      );

      expect(inkStrokeVisibleOnCanvas(stroke), isTrue);
    });

    test('fill tool is not drawn as ink', () {
      expect(
        inkStrokeVisibleOnCanvas(
          Stroke(
            id: 's3',
            pageId: 'pg1',
            tool: ToolType.fill,
            color: 0xFF2455C3,
            width: 3,
            points: const [StrokePoint(0, 0, 1)],
            z: 1,
          ),
        ),
        isFalse,
      );
    });

    test('shape mode toggles back to pen via ToolState', () {
      final toolState = ToolState();
      toolState.set((s) => s.tool = ToolType.shape);
      expect(toolState.tool, ToolType.shape);

      toolState.set((s) => s.tool = ToolType.pen);
      expect(toolState.tool, ToolType.pen);
    });
  });
}
