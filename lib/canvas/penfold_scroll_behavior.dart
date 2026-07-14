import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Scroll behavior that never lets stylus / inverted stylus drag the page list.
/// Finger, mouse, and trackpad scrolling still work while the pen hovers or draws.
class PenfoldScrollBehavior extends MaterialScrollBehavior {
  const PenfoldScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
