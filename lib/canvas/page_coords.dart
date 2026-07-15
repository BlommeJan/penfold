import 'dart:ui';

import '../models/models.dart';

/// Fixed logical page dimensions in 0.1 mm units (A4 width = 2100 = 210 mm).
class PageCoords {
  PageCoords._();

  static ({int width, int height}) _dims(
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) =>
      orientation == PageOrientation.landscape
          ? (width: pageSize.height, height: pageSize.width)
          : (width: pageSize.width, height: pageSize.height);

  static double effectiveAspect(
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final d = _dims(pageSize, orientation: orientation);
    return d.width / d.height;
  }

  static Size canonicalSize(
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final d = _dims(pageSize, orientation: orientation);
    return Size(d.width.toDouble(), d.height.toDouble());
  }

  static double scaleX(
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) =>
      displaySize.width / _dims(pageSize, orientation: orientation).width;

  static double scaleY(
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) =>
      displaySize.height / _dims(pageSize, orientation: orientation).height;

  static double avgScale(
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) =>
      (scaleX(displaySize, pageSize, orientation: orientation) +
          scaleY(displaySize, pageSize, orientation: orientation)) /
      2;

  static Offset displayToCanonical(
    Offset display,
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final d = _dims(pageSize, orientation: orientation);
    return Offset(
      display.dx * d.width / displaySize.width,
      display.dy * d.height / displaySize.height,
    );
  }

  static Offset canonicalToDisplay(
    Offset canonical,
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final d = _dims(pageSize, orientation: orientation);
    return Offset(
      canonical.dx * displaySize.width / d.width,
      canonical.dy * displaySize.height / d.height,
    );
  }

  static double displayToCanonicalLength(
    double displayLen,
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) =>
      displayLen / avgScale(displaySize, pageSize, orientation: orientation);

  static double canonicalToDisplayLength(
    double canonicalLen,
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) =>
      canonicalLen * avgScale(displaySize, pageSize, orientation: orientation);

  /// Fit the page inside [viewport] with [margin] padding on each side.
  static Size pageDisplaySize(
    Size viewport,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
    double margin = 24,
  }) {
    final maxW = viewport.width - margin * 2;
    final maxH = viewport.height - margin * 2;
    final aspect = effectiveAspect(pageSize, orientation: orientation);
    var w = maxW;
    var h = w / aspect;
    if (h > maxH) {
      h = maxH;
      w = h * aspect;
    }
    return Size(w, h);
  }

  static Rect canonicalRectToDisplay(
    Rect canonical,
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final tl = canonicalToDisplay(
      canonical.topLeft,
      displaySize,
      pageSize,
      orientation: orientation,
    );
    final br = canonicalToDisplay(
      canonical.bottomRight,
      displaySize,
      pageSize,
      orientation: orientation,
    );
    return Rect.fromPoints(tl, br);
  }

  static Rect displayRectToCanonical(
    Rect display,
    Size displaySize,
    PageSize pageSize, {
    PageOrientation orientation = PageOrientation.portrait,
  }) {
    final tl = displayToCanonical(
      display.topLeft,
      displaySize,
      pageSize,
      orientation: orientation,
    );
    final br = displayToCanonical(
      display.bottomRight,
      displaySize,
      pageSize,
      orientation: orientation,
    );
    return Rect.fromPoints(tl, br);
  }
}
