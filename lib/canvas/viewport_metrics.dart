import 'dart:ui';

/// Body viewport size that stays constant while the keyboard opens when
/// [Scaffold.resizeToAvoidBottomInset] shrinks layout constraints.
Size keyboardStableViewportSize({
  required Size layoutSize,
  required double viewInsetBottom,
}) =>
    Size(layoutSize.width, layoutSize.height + viewInsetBottom);
