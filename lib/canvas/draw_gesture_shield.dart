import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Legacy scroll-block recognizer. Prefer [shouldLockScrollForPaperTouch] plus
/// ancestor scroll lock — claiming the gesture arena blocks pinch-to-zoom when
/// the 16 ms accept timer fires before the second finger lands.
///
/// When used, only accepts after single-finger movement past touch slop so
/// two-finger pinch can win the arena.
class DrawGestureShield extends StatelessWidget {
  final Widget child;

  const DrawGestureShield({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: const <Type, GestureRecognizerFactory>{
        _DrawShieldRecognizer:
            GestureRecognizerFactoryWithHandlers<_DrawShieldRecognizer>(
          _DrawShieldRecognizer.new,
          _DrawShieldRecognizer.noop,
        ),
      },
      child: child,
    );
  }
}

class _DrawShieldRecognizer extends OneSequenceGestureRecognizer {
  static void noop(_DrawShieldRecognizer _) {}

  static const double _acceptSlop = 18;

  final Set<int> _tracked = {};
  final Map<int, Offset> _downPositions = {};
  bool _resolved = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.touch &&
        event.kind != PointerDeviceKind.mouse) {
      resolve(GestureDisposition.rejected);
      _resolved = true;
      return;
    }

    startTrackingPointer(event.pointer);
    _tracked.add(event.pointer);
    _downPositions[event.pointer] = event.position;

    if (_tracked.length >= 2) {
      _rejectIfPending();
    }
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent && _tracked.length >= 2) {
      _rejectIfPending();
      return;
    }

    if (!_resolved &&
        _tracked.length == 1 &&
        event is PointerMoveEvent &&
        _downPositions.isNotEmpty) {
      final origin = _downPositions.values.first;
      if ((event.position - origin).distance >= _acceptSlop) {
        resolve(GestureDisposition.accepted);
        _resolved = true;
      }
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _tracked.remove(event.pointer);
      _downPositions.remove(event.pointer);
      stopTrackingPointer(event.pointer);
      if (_tracked.isEmpty) {
        _resolved = false;
      }
    }
  }

  void _rejectIfPending() {
    if (!_resolved) {
      resolve(GestureDisposition.rejected);
      _resolved = true;
    }
  }

  @override
  String get debugDescription => 'draw shield';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _tracked.clear();
    _downPositions.clear();
    _resolved = false;
  }
}
