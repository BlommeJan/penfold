import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/pointer_routing.dart';

void main() {
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
  });
}
