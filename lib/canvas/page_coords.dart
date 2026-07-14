import 'dart:ui';

import '../models/models.dart';

/// Fixed logical page dimensions in 0.1 mm units (A4 width = 2100 = 210 mm).
class PageCoords {
  PageCoords._();

  static Size canonicalSize(PageSize pageSize) =>
      Size(pageSize.width.toDouble(), pageSize.height.toDouble());

  static double scaleX(Size displaySize, PageSize pageSize) =>
      displaySize.width / pageSize.width;

  static double scaleY(Size displaySize, PageSize pageSize) =>
      displaySize.height / pageSize.height;

  static double avgScale(Size displaySize, PageSize pageSize) =>
      (scaleX(displaySize, pageSize) + scaleY(displaySize, pageSize)) / 2;

  static Offset displayToCanonical(
    Offset display,
    Size displaySize,
    PageSize pageSize,
  ) {
    return Offset(
      display.dx * pageSize.width / displaySize.width,
      display.dy * pageSize.height / displaySize.height,
    );
  }

  static Offset canonicalToDisplay(
    Offset canonical,
    Size displaySize,
    PageSize pageSize,
  ) {
    return Offset(
      canonical.dx * displaySize.width / pageSize.width,
      canonical.dy * displaySize.height / pageSize.height,
    );
  }

  static double displayToCanonicalLength(
    double displayLen,
    Size displaySize,
    PageSize pageSize,
  ) =>
      displayLen / avgScale(displaySize, pageSize);

  static double canonicalToDisplayLength(
    double canonicalLen,
    Size displaySize,
    PageSize pageSize,
  ) =>
      canonicalLen * avgScale(displaySize, pageSize);

  /// Fit the page inside [viewport] with [margin] padding on each side.
  static Size pageDisplaySize(
    Size viewport,
    PageSize pageSize, {
    double margin = 24,
  }) {
    final maxW = viewport.width - margin * 2;
    final maxH = viewport.height - margin * 2;
    final aspect = pageSize.aspect;
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
    PageSize pageSize,
  ) {
    final tl = canonicalToDisplay(canonical.topLeft, displaySize, pageSize);
    final br = canonicalToDisplay(canonical.bottomRight, displaySize, pageSize);
    return Rect.fromPoints(tl, br);
  }

  static Rect displayRectToCanonical(
    Rect display,
    Size displaySize,
    PageSize pageSize,
  ) {
    final tl = displayToCanonical(display.topLeft, displaySize, pageSize);
    final br = displayToCanonical(display.bottomRight, displaySize, pageSize);
    return Rect.fromPoints(tl, br);
  }
}
