import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/widgets.dart' as pw;
import 'package:penfold/services/pdf_link_extractor.dart';
import 'package:penfold/services/pdf_link_launcher.dart';
import 'package:penfold/widgets/pdf_link_overlay.dart';

Future<File> _writeLinkedPdf(
  Directory dir, {
  required String url,
  String filename = 'linked.pdf',
}) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (ctx) => pw.UrlLink(
        destination: url,
        child: pw.Container(
          width: 200,
          height: 40,
          child: pw.Text('Tap link'),
        ),
      ),
    ),
  );
  final file = File(p.join(dir.path, filename));
  await file.writeAsBytes(await pdf.save());
  return file;
}

Future<File> _writeNamedLinkPdf(Directory dir) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (ctx) => pw.Link(
        destination: 'page2',
        child: pw.Container(
          width: 120,
          height: 30,
          child: pw.Text('Internal'),
        ),
      ),
    ),
  );
  final file = File(p.join(dir.path, 'internal.pdf'));
  await file.writeAsBytes(await pdf.save());
  return file;
}

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('penfold_pdf_links_test');
    PdfLinkExtractor.clearCache();
    PdfLinkLauncher.launchOverride = null;
  });

  tearDown(() async {
    PdfLinkExtractor.clearCache();
    PdfLinkLauncher.launchOverride = null;
    await tmp.delete(recursive: true);
  });

  group('PdfLinkExtractor', () {
    test('parses URI link annotation from pdf package output', () async {
      const url = 'https://penfold.example/hyperlink-test';
      final pdfFile = await _writeLinkedPdf(tmp, url: url);

      final links = PdfLinkExtractor.extractPageLinks(pdfFile.path, 1);

      expect(links.length, 1);
      expect(links.single.url, url);
      expect(links.single.left, greaterThanOrEqualTo(0));
      expect(links.single.top, greaterThanOrEqualTo(0));
      expect(links.single.width, greaterThan(0));
      expect(links.single.height, greaterThan(0));
      expect(
        links.single.left + links.single.width,
        lessThanOrEqualTo(1.01),
      );
      expect(
        links.single.top + links.single.height,
        lessThanOrEqualTo(1.01),
      );
    });

    test('returns empty list for pages without URI links', () async {
      final pdf = pw.Document();
      pdf.addPage(pw.Page(build: (ctx) => pw.Text('No links here')));
      final file = File(p.join(tmp.path, 'plain.pdf'));
      await file.writeAsBytes(await pdf.save());

      final links = PdfLinkExtractor.extractPageLinks(file.path, 1);

      expect(links, isEmpty);
    });

    test('skips internal named links (GoTo)', () async {
      final pdfFile = await _writeNamedLinkPdf(tmp);

      final links = PdfLinkExtractor.extractPageLinks(pdfFile.path, 1);

      expect(links, isEmpty);
    });

    test('caches parsed links per source page', () async {
      const url = 'https://penfold.example/cache';
      final pdfFile = await _writeLinkedPdf(tmp, url: url);

      final first = PdfLinkExtractor.extractPageLinks(pdfFile.path, 1);
      final second = PdfLinkExtractor.extractPageLinks(pdfFile.path, 1);

      expect(identical(first, second), isTrue);
    });
  });

  group('PdfLinkOverlay', () {
    testWidgets('finger tap launches URL via PdfLinkLauncher', (tester) async {
      String? launched;
      PdfLinkLauncher.launchOverride = (url) async {
        launched = url;
        return true;
      };

      const url = 'https://penfold.example/tap';
      const links = [
        PdfPageLink(
          url: url,
          left: 0.1,
          top: 0.2,
          width: 0.3,
          height: 0.1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: PdfLinkOverlay(
                links: links,
                displaySize: const Size(400, 600),
              ),
            ),
          ),
        ),
      );

      await tester.tapAt(const Offset(120, 150));
      await tester.pump();

      expect(launched, url);
    });

    testWidgets('stylus pointer does not launch URL', (tester) async {
      String? launched;
      PdfLinkLauncher.launchOverride = (url) async {
        launched = url;
        return true;
      };

      const links = [
        PdfPageLink(
          url: 'https://penfold.example/stylus',
          left: 0,
          top: 0,
          width: 0.5,
          height: 0.5,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 600,
              child: PdfLinkOverlay(
                links: links,
                displaySize: const Size(400, 600),
              ),
            ),
          ),
        ),
      );

      await tester.startGesture(
        const Offset(80, 80),
        kind: PointerDeviceKind.stylus,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      expect(launched, isNull);
    });
  });
}
