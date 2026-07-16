import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/document_transform.dart';

void main() {
  group('clampDocumentTransform', () {
    const viewport = Size(800, 1200);
    const content = Rect.fromLTWH(0, 0, 800, 3600);

    test('clears translation near 1× so scroll owns vertical navigation', () {
      final matrix = documentMatrixFromScaleTranslation(
        1.0,
        const Offset(120, 400),
      );
      final clamped = clampDocumentTransform(
        matrix: matrix,
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(clamped), closeTo(1.0, 0.001));
      expect(documentTranslation(clamped), Offset.zero);
    });

    test('clamps pan when zoomed in so content stays reachable', () {
      final matrix = documentMatrixFromScaleTranslation(
        3.0,
        const Offset(-99999, -99999),
      );
      final clamped = clampDocumentTransform(
        matrix: matrix,
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(clamped), closeTo(3.0, 0.001));
      final t = documentTranslation(clamped);
      expect(t.dx, greaterThan(-99999.0));
      expect(t.dy, greaterThan(-99999.0));
      expect(t.dx, greaterThanOrEqualTo(-1600 - kDocumentBoundaryMargin));
      expect(t.dy, greaterThanOrEqualTo(-9600 - kDocumentBoundaryMargin));
    });

    test('allows zoom out to minimum scale', () {
      final matrix = documentMatrixFromScaleTranslation(0.25, Offset.zero);
      final clamped = clampDocumentTransform(
        matrix: matrix,
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(clamped), closeTo(0.25, 0.001));
    });
  });

  group('documentScaleAroundFocal', () {
    test('zooms around focal and preserves focal point', () {
      const focal = Offset(400, 600);
      final start = documentMatrixFromScaleTranslation(1.0, Offset.zero);
      final zoomed = documentScaleAroundFocal(
        matrix: start,
        focal: focal,
        scaleFactor: 2.0,
      );
      expect(documentScale(zoomed), closeTo(2.0, 0.001));
      expect(transformPoint(zoomed, focal), focal);
    });
  });

  group('documentPan', () {
    test('translates content in viewport space', () {
      final start = documentMatrixFromScaleTranslation(2.0, Offset.zero);
      final panned = documentPan(start, const Offset(30, 40));
      expect(documentTranslation(panned), const Offset(30, 40));
    });
  });
}
