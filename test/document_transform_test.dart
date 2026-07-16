import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/canvas/document_transform.dart';

void main() {
  group('clampDocumentTransform', () {
    const viewport = Size(800, 1200);
    const content = Rect.fromLTWH(0, 0, 800, 3600);

    test('preserves translation near 1× for scroll fold/unfold', () {
      final matrix = documentMatrixFromScaleTranslation(
        1.0,
        const Offset(0, -1200),
      );
      final clamped = clampDocumentTransform(
        matrix: matrix,
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(clamped), closeTo(1.0, 0.001));
      expect(documentTranslation(clamped), const Offset(0, -1200));
    });

    test('centers content when zoomed out below 1×', () {
      final matrix = documentMatrixFromScaleTranslation(0.5, Offset.zero);
      final clamped = clampDocumentTransform(
        matrix: matrix,
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(clamped), closeTo(0.5, 0.001));
      final t = documentTranslation(clamped);
      expect(t.dx, closeTo(200, 0.5));
      expect(t.dy, closeTo(-300, 0.5));
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

    test('never moves content fully outside viewport after clamp', () {
      for (final scale in [0.25, 0.5, 0.99, 1.0, 1.5, 2.0, 4.0, 8.0]) {
        for (final tx in [-50000.0, -800.0, 0.0, 400.0, 50000.0]) {
          for (final ty in [-50000.0, -3600.0, 0.0, 600.0, 50000.0]) {
            final matrix = documentMatrixFromScaleTranslation(
              scale,
              Offset(tx, ty),
            );
            final clamped = clampDocumentTransform(
              matrix: matrix,
              viewportSize: viewport,
              contentBounds: content,
            );
            expect(
              documentContentIntersectsViewport(
                matrix: clamped,
                viewportSize: viewport,
                contentBounds: content,
              ),
              isTrue,
              reason: 'scale=$scale tx=$tx ty=$ty',
            );
          }
        }
      }
    });
  });

  group('documentContentIntersectsViewport', () {
    const viewport = Size(800, 1200);
    const content = Rect.fromLTWH(0, 0, 800, 3600);

    test('2× zoom around center keeps content visible', () {
      const focal = Offset(400, 600);
      final start = documentMatrixFromScaleTranslation(1.0, Offset.zero);
      final zoomed = clampDocumentTransform(
        matrix: documentScaleAroundFocal(
          matrix: start,
          focal: focal,
          scaleFactor: 2.0,
        ),
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(zoomed), closeTo(2.0, 0.001));
      expect(
        documentContentIntersectsViewport(
          matrix: zoomed,
          viewportSize: viewport,
          contentBounds: content,
        ),
        isTrue,
      );
      expect(transformPoint(zoomed, focal), focal);
    });

    test('0.5× zoom out keeps content centered and visible', () {
      final matrix = documentMatrixFromScaleTranslation(0.5, Offset.zero);
      final clamped = clampDocumentTransform(
        matrix: matrix,
        viewportSize: viewport,
        contentBounds: content,
      );
      expect(documentScale(clamped), closeTo(0.5, 0.001));
      expect(
        documentContentIntersectsViewport(
          matrix: clamped,
          viewportSize: viewport,
          contentBounds: content,
        ),
        isTrue,
      );
      final contentRect = documentContentRectInViewport(
        matrix: clamped,
        contentBounds: content,
      );
      expect(contentRect.center.dx, closeTo(viewport.width / 2, 1.0));
    });
  });

  group('normalizeDocumentTransform', () {
    test('strips rotation drift leaving scale and translation', () {
      final skewed = Matrix4.identity()
        ..translate(40.0, 60.0)
        ..rotateZ(0.15)
        ..scale(2.0);
      final normalized = normalizeDocumentTransform(skewed);
      expect(documentScale(normalized), closeTo(2.0, 0.001));
      expect(documentTranslation(normalized).dx, closeTo(40.0, 0.5));
      expect(documentTranslation(normalized).dy, closeTo(60.0, 0.5));
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
