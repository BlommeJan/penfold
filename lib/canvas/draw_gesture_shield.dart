import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Claims single-finger drags on the paper so ancestor [ScrollView]s cannot
/// steal strokes in finger-drawing mode. Yields for 2+ fingers so ancestor
/// pinch-to-zoom can win the gesture arena.
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

  final Set<int> _tracked = {};
  Timer? _acceptTimer;
  bool _accepted = false;
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

    if (_tracked.length >= 2) {
      _cancelAcceptTimer();
      if (!_resolved) {
        resolve(GestureDisposition.rejected);
        _resolved = true;
      }
      return;
    }

    _cancelAcceptTimer();
    _acceptTimer = Timer(const Duration(milliseconds: 16), () {
      if (_tracked.length == 1 && !_resolved) {
        resolve(GestureDisposition.accepted);
        _accepted = true;
        _resolved = true;
      } else if (_tracked.length >= 2 && !_resolved) {
        resolve(GestureDisposition.rejected);
        _resolved = true;
      }
    });
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent && _tracked.length >= 2) {
      _cancelAcceptTimer();
      if (!_resolved) {
        resolve(GestureDisposition.rejected);
        _resolved = true;
      }
      return;
    }

    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _tracked.remove(event.pointer);
      stopTrackingPointer(event.pointer);
      if (_tracked.isEmpty) {
        _cancelAcceptTimer();
        _accepted = false;
        _resolved = false;
      }
    }
  }

  void _cancelAcceptTimer() {
    _acceptTimer?.cancel();
    _acceptTimer = null;
  }

  @override
  String get debugDescription => 'draw shield';

  @override
  void didStopTrackingLastPointer(int pointer) {
    _cancelAcceptTimer();
    _tracked.clear();
    _accepted = false;
    _resolved = false;
  }

  @override
  void dispose() {
    _cancelAcceptTimer();
    super.dispose();
  }
}
