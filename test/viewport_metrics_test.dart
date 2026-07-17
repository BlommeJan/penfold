import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/viewport_metrics.dart';

void main() {
  group('keyboardStableViewportSize', () {
    test('adds keyboard inset back to shrunk layout height', () {
      const layout = Size(800, 400);
      final stable = keyboardStableViewportSize(
        layoutSize: layout,
        viewInsetBottom: 336,
      );
      expect(stable, const Size(800, 736));
    });

    test('unchanged when keyboard is closed', () {
      const layout = Size(800, 1200);
      final stable = keyboardStableViewportSize(
        layoutSize: layout,
        viewInsetBottom: 0,
      );
      expect(stable, layout);
    });
  });
}
