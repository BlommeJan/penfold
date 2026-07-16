import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/page_coords.dart';
import 'package:penfold/canvas/pointer_routing.dart';
import 'package:penfold/models/models.dart';

void main() {
  group('PageCoords', () {
    const display = Size(420, 594);
    const pageSize = PageSize.a4;

    test('canonical roundtrip preserves position', () {
      const original = Offset(100, 200);
      final canonical =
          PageCoords.displayToCanonical(original, display, pageSize);
      final back =
          PageCoords.canonicalToDisplay(canonical, display, pageSize);
      expect(back.dx, closeTo(original.dx, 0.01));
      expect(back.dy, closeTo(original.dy, 0.01));
    });

    test('pageDisplaySize respects aspect ratio', () {
      final size = PageCoords.pageDisplaySize(const Size(800, 600), PageSize.a4);
      expect(size.width / size.height, closeTo(PageSize.a4.aspect, 0.01));
      expect(size.width, lessThanOrEqualTo(800 - 48));
      expect(size.height, lessThanOrEqualTo(600 - 48));
    });

    test('landscape pageDisplaySize inverts aspect', () {
      final size = PageCoords.pageDisplaySize(
        const Size(800, 600),
        PageSize.a4,
        orientation: PageOrientation.landscape,
      );
      expect(
        size.width / size.height,
        closeTo(PageSize.a4.height / PageSize.a4.width, 0.01),
      );
    });

    test('PageSize aspect constants', () {
      expect(PageSize.a4.aspect, closeTo(210 / 297, 0.001));
      expect(PageSize.a5.aspect, closeTo(148 / 210, 0.001));
      expect(PageSize.letter.aspect, closeTo(215.9 / 279.4, 0.001));
    });
  });

  group('PageViewport gating', () {
    const paper = Size(400, 560);

    test('stylus always routes to drawing', () {
      expect(
        shouldRouteToDrawing(
          kind: PointerDeviceKind.stylus,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: true,
          stylusActive: false,
        ),
        isTrue,
      );
    });

    test('stylus-only mode blocks finger on paper', () {
      expect(
        shouldRouteToDrawing(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: true,
          stylusActive: false,
        ),
        isFalse,
      );
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: true,
        ),
        isTrue,
      );
    });

    test('finger mode draws on paper, pans on margin', () {
      expect(
        shouldRouteToDrawing(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: false,
          stylusActive: false,
        ),
        isTrue,
      );
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: false,
        ),
        isFalse,
      );
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(450, 280),
          paperSize: paper,
          stylusOnly: false,
        ),
        isTrue,
      );
    });

    test('stylus active blocks finger drawing', () {
      expect(
        shouldRouteToDrawing(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: false,
          stylusActive: true,
        ),
        isFalse,
      );
    });

    test('stylus hover still allows finger pan/zoom', () {
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: true,
        ),
        isTrue,
      );
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.stylus,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: true,
        ),
        isFalse,
      );
    });

    test('two-finger pinch always allows zoom on paper', () {
      expect(
        shouldAllowPinchZoom(
          touchPointerCount: 2,
          kind: PointerDeviceKind.touch,
        ),
        isTrue,
      );
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: false,
          touchPointerCount: 2,
        ),
        isTrue,
      );
      expect(
        shouldAllowPanZoom(
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
          stylusOnly: true,
          touchPointerCount: 2,
        ),
        isTrue,
      );
    });

    test('paper touch scroll lock only in finger drawing mode', () {
      expect(
        shouldLockScrollForPaperTouch(
          stylusOnly: false,
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
        ),
        isTrue,
      );
      expect(
        shouldLockScrollForPaperTouch(
          stylusOnly: false,
          kind: PointerDeviceKind.touch,
          localPos: const Offset(450, 280),
          paperSize: paper,
        ),
        isFalse,
      );
      expect(
        shouldLockScrollForPaperTouch(
          stylusOnly: true,
          kind: PointerDeviceKind.touch,
          localPos: const Offset(200, 280),
          paperSize: paper,
        ),
        isFalse,
      );
      expect(
        shouldLockScrollForPaperTouch(
          stylusOnly: false,
          kind: PointerDeviceKind.stylus,
          localPos: const Offset(200, 280),
          paperSize: paper,
        ),
        isFalse,
      );
    });
  });
}
