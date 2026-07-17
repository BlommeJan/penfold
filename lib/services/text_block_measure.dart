import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../canvas/page_coords.dart';
import '../models/models.dart';

/// Matches [PagePainter._drawTextBlock] text style.
const textBlockLineHeight = 1.25;
const textBlockLetterSpacing = 0.15;

/// Padding around measured glyphs for hit testing (display pixels).
const textBlockBoundsPaddingDisplay = 8.0;

/// Minimum text block size for hit targets (display pixels).
const textBlockMinWidthDisplay = 24.0;
const textBlockMinHeightDisplay = 16.0;

TextStyle textBlockPaintStyle({required double displayFontSize, Color? color}) =>
    TextStyle(
      color: color,
      fontSize: displayFontSize,
      height: textBlockLineHeight,
      letterSpacing: textBlockLetterSpacing,
    );

/// Tight width/height in canonical page units for [text] at [fontSize].
Size measureTextBlockSize({
  required String text,
  required double fontSize,
  required PageSize pageSize,
  required Size displaySize,
  PageOrientation orientation = PageOrientation.portrait,
  double? maxWidthCanonical,
}) {
  if (text.isEmpty) {
    return Size(
      _displayToCanonical(textBlockMinWidthDisplay, displaySize, pageSize,
          orientation: orientation),
      _displayToCanonical(textBlockMinHeightDisplay, displaySize, pageSize,
          orientation: orientation),
    );
  }

  final displayFont = PageCoords.canonicalToDisplayLength(
    fontSize,
    displaySize,
    pageSize,
    orientation: orientation,
  );
  final maxDisplayWidth = maxWidthCanonical != null
      ? PageCoords.canonicalToDisplayLength(
          maxWidthCanonical,
          displaySize,
          pageSize,
          orientation: orientation,
        )
      : displaySize.width * 0.85;

  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: textBlockPaintStyle(displayFontSize: displayFont),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxDisplayWidth);

  final pad = textBlockBoundsPaddingDisplay;
  final w = _displayToCanonical(
    tp.size.width + pad,
    displaySize,
    pageSize,
    orientation: orientation,
  );
  final h = _displayToCanonical(
    tp.size.height + pad,
    displaySize,
    pageSize,
    orientation: orientation,
  );
  return Size(
    math.max(
      _displayToCanonical(textBlockMinWidthDisplay, displaySize, pageSize,
          orientation: orientation),
      w,
    ),
    math.max(
      _displayToCanonical(textBlockMinHeightDisplay, displaySize, pageSize,
          orientation: orientation),
      h,
    ),
  );
}

double _displayToCanonical(
  double displayLen,
  Size displaySize,
  PageSize pageSize, {
  PageOrientation orientation = PageOrientation.portrait,
}) =>
    PageCoords.displayToCanonicalLength(
      displayLen,
      displaySize,
      pageSize,
      orientation: orientation,
    );
