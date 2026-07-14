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

/// Returns true when pan/zoom should be allowed for this pointer.
bool shouldAllowPanZoom({
  required PointerDeviceKind kind,
  required Offset localPos,
  required Size paperSize,
  required bool stylusOnly,
}) {
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
