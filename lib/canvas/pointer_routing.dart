import 'dart:ui';

/// Returns true when a pointer of [kind] at [localPos] on a paper of
/// [paperSize] should be routed to drawing (unit-testable).
bool shouldRouteToDrawing({
  required PointerDeviceKind kind,
  required Offset localPos,
  required Size paperSize,
  required bool stylusOnly,
  required bool stylusActive,
}) {
  if (kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus) {
    return true;
  }
  if (kind == PointerDeviceKind.mouse) return true;
  if (stylusActive) return false;
  if (stylusOnly) return false;
  return (Offset.zero & paperSize).contains(localPos);
}

/// Two-finger pinch always routes to zoom (never to drawing).
bool shouldAllowPinchZoom({
  required int touchPointerCount,
  required PointerDeviceKind kind,
}) {
  if (kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus) {
    return false;
  }
  return touchPointerCount >= 2;
}

/// Returns true when pan/zoom should be allowed for this pointer.
///
/// [touchPointerCount] includes all active non-stylus pointers; when >= 2,
/// pinch zoom is always allowed (on paper, margin, stylus-only mode).
bool shouldAllowPanZoom({
  required PointerDeviceKind kind,
  required Offset localPos,
  required Size paperSize,
  required bool stylusOnly,
  int touchPointerCount = 1,
}) {
  if (shouldAllowPinchZoom(
    touchPointerCount: touchPointerCount,
    kind: kind,
  )) {
    return true;
  }

  if (kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus) {
    return false;
  }
  if (stylusOnly) {
    return kind == PointerDeviceKind.touch ||
        kind == PointerDeviceKind.trackpad ||
        kind == PointerDeviceKind.mouse;
  }
  if (kind == PointerDeviceKind.mouse) return true;
  return !(Offset.zero & paperSize).contains(localPos);
}
