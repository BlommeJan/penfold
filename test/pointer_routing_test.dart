import 'dart:ui';

import 'package:flutter/material.dart' show Matrix4;
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/pointer_routing.dart';

void main() {
  group('paperPointFromTransform', () {
    test('identity leaves point unchanged', () {
      const p = Offset(120, 200);
      expect(paperPointFromTransform(p, Matrix4.identity()), p);
    });

    test('scale maps viewport focal back to paper space', () {
      final transform = Matrix4.identity()..scale(2.0);
      expect(
        paperPointFromTransform(const Offset(100, 140), transform),
        const Offset(50, 70),
      );
    });

    test('translate+scale inverts zoomed viewport hit', () {
      final transform = Matrix4.identity()
        ..translate(40.0, 60.0)
        ..scale(2.0);
      // Viewport (140, 160) → paper (50, 50) after undoing translate+scale.
      expect(
        paperPointFromTransform(const Offset(140, 160), transform),
        const Offset(50, 50),
      );
    });
  });

  group('pointer routing matrix', () {
    const paper = Size(400, 560);
    const onPaper = Offset(200, 280);
    const margin = Offset(450, 280);

    group('stylus-only off (finger drawing on)', () {
      const stylusOnly = false;

      test('finger on paper draws and locks scroll', () {
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
            stylusActive: false,
          ),
          isTrue,
        );
        expect(
          shouldAllowFingerToolManipulation(
            stylusOnly: stylusOnly,
            kind: PointerDeviceKind.touch,
          ),
          isTrue,
        );
        expect(
          shouldLockScrollForPaperTouch(
            stylusOnly: stylusOnly,
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
          ),
          isTrue,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
          ),
          isFalse,
        );
      });

      test('finger on margin pans without scroll lock', () {
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: margin,
            paperSize: paper,
            stylusOnly: stylusOnly,
            stylusActive: false,
          ),
          isFalse,
        );
        expect(
          shouldLockScrollForPaperTouch(
            stylusOnly: stylusOnly,
            kind: PointerDeviceKind.touch,
            localPos: margin,
            paperSize: paper,
          ),
          isFalse,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: margin,
            paperSize: paper,
            stylusOnly: stylusOnly,
          ),
          isTrue,
        );
      });

      test('stylus proximity blocks finger ink but not two-finger zoom', () {
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
            stylusActive: true,
          ),
          isFalse,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
            touchPointerCount: 2,
          ),
          isTrue,
        );
      });
    });

    group('stylus-only on (finger drawing off)', () {
      const stylusOnly = true;

      test('finger on paper pans without drawing or scroll lock', () {
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
            stylusActive: false,
          ),
          isFalse,
        );
        expect(
          shouldLockScrollForPaperTouch(
            stylusOnly: stylusOnly,
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
          ),
          isFalse,
        );
        expect(
          shouldAllowFingerToolManipulation(
            stylusOnly: stylusOnly,
            kind: PointerDeviceKind.touch,
          ),
          isFalse,
          reason: 'selection/shape/text must not steal finger scroll',
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
          ),
          isTrue,
        );
      });

      test('finger on margin pans', () {
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: margin,
            paperSize: paper,
            stylusOnly: stylusOnly,
          ),
          isTrue,
        );
      });

      test('stylus always draws regardless of proximity', () {
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.stylus,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
            stylusActive: false,
          ),
          isTrue,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.stylus,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
          ),
          isFalse,
        );
      });
    });

    test('two-finger pinch zooms in both modes on paper', () {
      for (final stylusOnly in [true, false]) {
        expect(
          shouldAllowPinchZoom(
            touchPointerCount: 2,
            kind: PointerDeviceKind.touch,
          ),
          isTrue,
          reason: 'pinch allowed when stylusOnly=$stylusOnly',
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: onPaper,
            paperSize: paper,
            stylusOnly: stylusOnly,
            touchPointerCount: 2,
          ),
          isTrue,
          reason: 'pan/zoom on paper with 2 fingers when stylusOnly=$stylusOnly',
        );
      }
    });

    group('zoomed viewport coordinates', () {
      late Matrix4 zoom2x;

      setUp(() {
        zoom2x = Matrix4.identity()..scale(2.0);
      });

      test('finger on visible paper draws when viewport focal looks off-paper', () {
        // Paper center (200, 280) appears at viewport (400, 560) when scaled 2×.
        const viewportFocal = Offset(400, 560);
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: viewportFocal,
            paperSize: paper,
            stylusOnly: false,
            stylusActive: false,
            contentTransform: zoom2x,
          ),
          isTrue,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: viewportFocal,
            paperSize: paper,
            stylusOnly: false,
            contentTransform: zoom2x,
          ),
          isFalse,
        );
        expect(
          shouldLockScrollForPaperTouch(
            stylusOnly: false,
            kind: PointerDeviceKind.touch,
            localPos: viewportFocal,
            paperSize: paper,
            contentTransform: zoom2x,
          ),
          isTrue,
        );
      });

      test('finger on zoomed margin still pans', () {
        // Viewport (900, 280) → paper (450, 140), outside 400-wide paper.
        const zoomedMargin = Offset(900, 280);
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: zoomedMargin,
            paperSize: paper,
            stylusOnly: false,
            stylusActive: false,
            contentTransform: zoom2x,
          ),
          isFalse,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: zoomedMargin,
            paperSize: paper,
            stylusOnly: false,
            contentTransform: zoom2x,
          ),
          isTrue,
        );
      });

      test('two-finger pinch on zoomed paper still zooms', () {
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: const Offset(400, 560),
            paperSize: paper,
            stylusOnly: false,
            touchPointerCount: 2,
            contentTransform: zoom2x,
          ),
          isTrue,
        );
      });

      test('stylus-only finger on zoomed paper pans instead of drawing', () {
        const viewportFocal = Offset(400, 560);
        expect(
          shouldRouteToDrawing(
            kind: PointerDeviceKind.touch,
            localPos: viewportFocal,
            paperSize: paper,
            stylusOnly: true,
            stylusActive: false,
            contentTransform: zoom2x,
          ),
          isFalse,
        );
        expect(
          shouldAllowPanZoom(
            kind: PointerDeviceKind.touch,
            localPos: viewportFocal,
            paperSize: paper,
            stylusOnly: true,
            contentTransform: zoom2x,
          ),
          isTrue,
        );
      });
    });
  });
}
