import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Claims finger drags on the paper immediately so ancestor [ScrollView]s
/// cannot steal strokes in finger-drawing mode.
class DrawGestureShield extends StatelessWidget {
  final Widget child;

  const DrawGestureShield({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: const <Type, GestureRecognizerFactory>{
        _EagerDrawGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_EagerDrawGestureRecognizer>(
          _EagerDrawGestureRecognizer.new,
          _EagerDrawGestureRecognizer.noop,
        ),
      },
      child: child,
    );
  }
}

class _EagerDrawGestureRecognizer extends OneSequenceGestureRecognizer {
  static void noop(_EagerDrawGestureRecognizer _) {}

  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer);
    resolve(GestureDisposition.accepted);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  String get debugDescription => 'draw shield';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}
