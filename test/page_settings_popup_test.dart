import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:penfold/models/models.dart';
import 'package:penfold/services/page_complexity_service.dart';
import 'package:penfold/widgets/page_settings_popup.dart';

void main() {
  NotePage samplePage({
    PageTemplate template = PageTemplate.lined,
    PageSize pageSize = PageSize.a4,
    PageOrientation orientation = PageOrientation.portrait,
    String? pdfImagePath,
  }) =>
      NotePage(
        id: 'pg1',
        notebookId: 'nb1',
        index: 0,
        template: template,
        pageSize: pageSize,
        orientation: orientation,
        pdfImagePath: pdfImagePath,
      );

  test('pageSettingsSummary includes template size orientation', () {
    final page = samplePage();
    expect(
      pageSettingsSummary(page, isPdfPage: false),
      'Lined · A4 · Portrait',
    );
  });

  test('pageSettingsSummary for PDF pages', () {
    final page = samplePage(
      pdfImagePath: '/tmp/page.png',
      orientation: PageOrientation.landscape,
    );
    expect(
      pageSettingsSummary(page, isPdfPage: true),
      'PDF · Landscape',
    );
  });

  test('isPdfBackgroundPage detects pdf paths', () {
    expect(isPdfBackgroundPage(samplePage()), isFalse);
    expect(
      isPdfBackgroundPage(samplePage(pdfImagePath: '/x.png')),
      isTrue,
    );
  });

  test('shouldBlockExport at threshold', () {
    expect(
      PageComplexityService.shouldBlockExport(
        PageComplexityService.strokeExportBlockThreshold - 1,
      ),
      isFalse,
    );
    expect(
      PageComplexityService.shouldBlockExport(
        PageComplexityService.strokeExportBlockThreshold,
      ),
      isTrue,
    );
  });

}
