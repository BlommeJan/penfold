import 'dart:ui';

import 'package:flutter/material.dart' show Matrix4, MatrixUtils;

/// Minimum document zoom (see multiple pages when zoomed out).
const double kDocumentMinScale = 0.25;

/// Maximum document zoom.
const double kDocumentMaxScale = 8.0;

/// Near 1× on gesture end, snap back to identity so scroll resumes.
const double kDocumentSnapScaleMax = 1.02;

/// Near 1× during clamp, clear translation so scroll owns vertical navigation.
const double kDocumentUnitScaleMax = 1.02;

/// Above this scale, two-finger pan navigates the zoomed document.
const double kDocumentZoomedPanThreshold = 1.02;

/// Extra pan slack beyond content edges (InteractiveViewer-style).
const double kDocumentBoundaryMargin = 48.0;

double documentScale(Matrix4 matrix) => matrix.getMaxScaleOnAxis();

Offset documentTranslation(Matrix4 matrix) {
  final t = matrix.getTranslation();
  return Offset(t.x, t.y);
}

Matrix4 documentMatrixFromScaleTranslation(double scale, Offset translation) =>
    Matrix4.identity()
      ..scale(scale)
      ..translate(translation.dx / scale, translation.dy / scale);

/// Clamps uniform scale + translation so content stays reachable in [viewportSize].
///
/// When scale is near 1×, translation is cleared so [CustomScrollView] owns
/// vertical navigation.
Matrix4 clampDocumentTransform({
  required Matrix4 matrix,
  required Size viewportSize,
  required Rect contentBounds,
  double boundaryMargin = kDocumentBoundaryMargin,
}) {
  final scale = documentScale(matrix).clamp(kDocumentMinScale, kDocumentMaxScale);
  final translation = documentTranslation(matrix);

  if (scale <= kDocumentUnitScaleMax) {
    return documentMatrixFromScaleTranslation(scale, Offset.zero);
  }

  final contentW = contentBounds.width * scale;
  final contentH = contentBounds.height * scale;

  double minTx;
  double maxTx;
  if (contentW <= viewportSize.width) {
    final centered =
        (viewportSize.width - contentW) / 2 + contentBounds.left * scale;
    minTx = centered;
    maxTx = centered;
  } else {
    minTx = viewportSize.width - (contentBounds.right * scale);
    maxTx = -contentBounds.left * scale;
  }

  double minTy;
  double maxTy;
  if (contentH <= viewportSize.height) {
    final centered =
        (viewportSize.height - contentH) / 2 + contentBounds.top * scale;
    minTy = centered;
    maxTy = centered;
  } else {
    minTy = viewportSize.height - (contentBounds.bottom * scale);
    maxTy = -contentBounds.top * scale;
  }

  minTx -= boundaryMargin;
  maxTx += boundaryMargin;
  minTy -= boundaryMargin;
  maxTy += boundaryMargin;

  final clampedTx = translation.dx.clamp(minTx, maxTx);
  final clampedTy = translation.dy.clamp(minTy, maxTy);

  return documentMatrixFromScaleTranslation(
    scale,
    Offset(clampedTx, clampedTy),
  );
}

/// Incremental scale around [focal] applied to [matrix].
Matrix4 documentScaleAroundFocal({
  required Matrix4 matrix,
  required Offset focal,
  required double scaleFactor,
}) {
  if ((scaleFactor - 1.0).abs() < 0.0001) return matrix;
  final m = Matrix4.copy(matrix);
  m.translate(focal.dx, focal.dy);
  m.scale(scaleFactor);
  m.translate(-focal.dx, -focal.dy);
  return m;
}

/// Incremental pan applied to [matrix]; [delta] is in viewport pixels.
Matrix4 documentPan(Matrix4 matrix, Offset delta) {
  if (delta == Offset.zero) return matrix;
  final scale = documentScale(matrix);
  final m = Matrix4.copy(matrix);
  m.translate(delta.dx / scale, delta.dy / scale);
  return m;
}

/// Test hook: apply uniform scale from gesture-start values.
Matrix4 documentPinchFromStart({
  required Matrix4 gestureStartMatrix,
  required Offset gestureStartFocal,
  required Offset currentFocal,
  required double gestureStartScale,
  required double cumulativeScale,
}) {
  final newScale =
      (gestureStartScale * cumulativeScale).clamp(kDocumentMinScale, kDocumentMaxScale);
  var m = Matrix4.copy(gestureStartMatrix);
  m.translate(
    currentFocal.dx - gestureStartFocal.dx,
    currentFocal.dy - gestureStartFocal.dy,
  );
  m.translate(gestureStartFocal.dx, gestureStartFocal.dy);
  m.scale(newScale / gestureStartScale);
  m.translate(-gestureStartFocal.dx, -gestureStartFocal.dy);
  return m;
}

/// Legacy alias for tests.
Matrix4 documentPinchMatrix({
  required Matrix4 gestureStartMatrix,
  required Offset gestureStartFocal,
  required Offset currentFocal,
  required double gestureStartScale,
  required double cumulativeScale,
}) =>
    documentPinchFromStart(
      gestureStartMatrix: gestureStartMatrix,
      gestureStartFocal: gestureStartFocal,
      currentFocal: currentFocal,
      gestureStartScale: gestureStartScale,
      cumulativeScale: cumulativeScale,
    );

/// Roundtrip helper for tests.
Offset transformPoint(Matrix4 matrix, Offset point) =>
    MatrixUtils.transformPoint(matrix, point);
