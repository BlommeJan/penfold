import 'dart:ui' show Offset, PointerDeviceKind, Size;

import 'package:flutter/material.dart' show Matrix4, MatrixUtils;

/// Maps a point from viewport/parent space into paper (pre-transform) space.
///
/// [transform] is the same matrix applied by an ancestor [Transform] (paper →
/// viewport). When identity, [localPos] is returned unchanged.
Offset paperPointFromTransform(Offset localPos, Matrix4 transform) {
  if (_isIdentity(transform)) return localPos;
  return MatrixUtils.transformPoint(Matrix4.inverted(transform), localPos);
}

bool _isIdentity(Matrix4 m) {
  final s = m.storage;
  return s[0] == 1.0 &&
      s[1] == 0.0 &&
      s[2] == 0.0 &&
      s[3] == 0.0 &&
      s[4] == 0.0 &&
      s[5] == 1.0 &&
      s[6] == 0.0 &&
      s[7] == 0.0 &&
      s[8] == 0.0 &&
      s[9] == 0.0 &&
      s[10] == 1.0 &&
      s[11] == 0.0 &&
      s[12] == 0.0 &&
      s[13] == 0.0 &&
      s[14] == 0.0 &&
      s[15] == 1.0;
}

Offset _paperLocal(Offset localPos, Matrix4? contentTransform) {
  if (contentTransform == null || _isIdentity(contentTransform)) {
    return localPos;
  }
  return paperPointFromTransform(localPos, contentTransform);
}

bool _onPaper(Offset localPos, Size paperSize, Matrix4? contentTransform) {
  final paper = _paperLocal(localPos, contentTransform);
  return (Offset.zero & paperSize).contains(paper);
}

/// Maps [paperPos] into the paper rectangle for ink tools (pen, highlighter, etc.).
Offset clampToPaperBounds(Offset paperPos, Size paperSize) {
  final rect = Offset.zero & paperSize;
  return Offset(
    paperPos.dx.clamp(rect.left, rect.right),
    paperPos.dy.clamp(rect.top, rect.bottom),
  );
}

/// True when [paperPos] lies on the paper (already in paper space).
bool isOnPaperBounds(Offset paperPos, Size paperSize) =>
    (Offset.zero & paperSize).contains(paperPos);

/// Returns true when a pointer of [kind] at [localPos] on a paper of
/// [paperSize] should be routed to drawing (unit-testable).
///
/// When [contentTransform] is non-identity, [localPos] is in viewport/parent
/// space and is mapped into paper space before the bounds check. Pass null when
/// [localPos] is already in paper space (e.g. from a [Listener] inside the
/// transform).
bool shouldRouteToDrawing({
  required PointerDeviceKind kind,
  required Offset localPos,
  required Size paperSize,
  required bool stylusOnly,
  required bool stylusActive,
  Matrix4? contentTransform,
}) {
  if (kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus) {
    return true;
  }
  if (kind == PointerDeviceKind.mouse) return true;
  if (stylusActive) return false;
  if (stylusOnly) return false;
  return _onPaper(localPos, paperSize, contentTransform);
}

/// Selection / lasso / text / tape may use finger only when finger-drawing is on.
bool shouldAllowFingerToolManipulation({
  required bool stylusOnly,
  required PointerDeviceKind kind,
}) {
  if (stylusOnly) return false;
  return kind == PointerDeviceKind.touch || kind == PointerDeviceKind.mouse;
}

/// Finger on paper in finger-drawing mode should lock ancestor scroll so
/// strokes are not stolen; pinch zoom uses a separate transform lock.
bool shouldLockScrollForPaperTouch({
  required bool stylusOnly,
  required PointerDeviceKind kind,
  required Offset localPos,
  required Size paperSize,
  Matrix4? contentTransform,
}) {
  if (stylusOnly) return false;
  if (kind != PointerDeviceKind.touch) return false;
  return _onPaper(localPos, paperSize, contentTransform);
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
///
/// When [contentTransform] is set, [localPos] is in viewport space (e.g. scale
/// gesture focal point outside the [Transform] widget).
bool shouldAllowPanZoom({
  required PointerDeviceKind kind,
  required Offset localPos,
  required Size paperSize,
  required bool stylusOnly,
  int touchPointerCount = 1,
  Matrix4? contentTransform,
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
  return !_onPaper(localPos, paperSize, contentTransform);
}
