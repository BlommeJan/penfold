import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

/// Embedded text and layout metadata for one PDF page.
class PdfPageInfo {
  const PdfPageInfo({required this.text, required this.aspect});

  final String text;
  final double aspect;
}

/// Extracts embedded text from PDF content streams (local, offline).
///
/// Parses page trees and FlateDecode streams from PDFs produced by the `pdf`
/// package and typical slide exports.
class PdfTextExtractor {
  PdfTextExtractor._();

  static List<PdfPageInfo> parsePages(String pdfPath) {
    return parsePagesFromBytes(File(pdfPath).readAsBytesSync());
  }

  static List<PdfPageInfo> parsePagesFromBytes(Uint8List bytes) {
    final pdfText = latin1.decode(bytes);
    final streams = _decompressFlateStreams(bytes, pdfText);
    final pageObjects = _orderedPageObjects(pdfText);
    if (pageObjects.isEmpty) return const [];

    return [
      for (final pageObj in pageObjects)
        PdfPageInfo(
          text: _textFromPage(pdfText, pageObj, streams),
          aspect: _aspectFromPageSlice(_objectSlice(pdfText, pageObj)) ??
              (595.27559 / 841.88976),
        ),
    ];
  }

  /// One string per page; index 0 is page 1.
  static List<String> extractPages(String pdfPath) {
    return parsePages(pdfPath).map((p) => p.text).toList();
  }

  static List<String> extractPagesFromBytes(Uint8List bytes) {
    return parsePagesFromBytes(bytes).map((p) => p.text).toList();
  }

  static Map<int, String> _decompressFlateStreams(
    Uint8List bytes,
    String pdfText,
  ) {
    final streams = <int, String>{};
    for (final match in RegExp(r'(\d+) 0 obj').allMatches(pdfText)) {
      final objNum = int.parse(match.group(1)!);
      final objStart = match.start;
      final objEnd = pdfText.indexOf('endobj', objStart);
      if (objEnd < 0) continue;
      final slice = pdfText.substring(objStart, objEnd);
      if (!slice.contains('/Filter/FlateDecode')) continue;

      final lengthMatch = RegExp(r'/Length\s+(\d+)').firstMatch(slice);
      if (lengthMatch == null) continue;
      final length = int.parse(lengthMatch.group(1)!);

      final streamMarker = slice.indexOf('stream');
      if (streamMarker < 0) continue;
      var dataStart = objStart + streamMarker + 'stream'.length;
      while (dataStart < bytes.length &&
          (bytes[dataStart] == 0x0D || bytes[dataStart] == 0x0A)) {
        dataStart++;
      }
      final dataEnd = dataStart + length;
      if (dataEnd > bytes.length) continue;
      try {
        final inflated = ZLibDecoder().decodeBytes(bytes.sublist(dataStart, dataEnd));
        streams[objNum] = latin1.decode(inflated);
      } catch (_) {
        // Skip malformed streams; other pages may still have text.
      }
    }
    return streams;
  }

  static List<int> _orderedPageObjects(String pdfText) {
    final catalog = RegExp(
      r'/Type\s*/Catalog.*?/Pages\s+(\d+)\s+0\s+R',
      dotAll: true,
    ).firstMatch(pdfText);
    if (catalog == null) return _fallbackPageObjects(pdfText);
    return _expandPageTree(pdfText, int.parse(catalog.group(1)!));
  }

  static List<int> _expandPageTree(String pdfText, int objNum) {
    final slice = _objectSlice(pdfText, objNum);
    if (slice.contains('/Type/Pages')) {
      final kids = RegExp(r'/Kids\s*\[([^\]]+)\]').firstMatch(slice);
      if (kids == null) return const [];
      final refs = RegExp(r'(\d+)\s+0\s+R').allMatches(kids.group(1)!);
      return [
        for (final ref in refs)
          ..._expandPageTree(pdfText, int.parse(ref.group(1)!)),
      ];
    }
    if (slice.contains('/Type/Page')) return [objNum];
    return const [];
  }

  static List<int> _fallbackPageObjects(String pdfText) {
    final pages = <int>[];
    final re = RegExp(r'(\d+) 0 obj');
    for (final match in re.allMatches(pdfText)) {
      final objNum = int.parse(match.group(1)!);
      final slice = _objectSlice(pdfText, objNum);
      if (slice.contains('/Type/Page') && !slice.contains('/Type/Pages')) {
        pages.add(objNum);
      }
    }
    pages.sort();
    return pages;
  }

  static String _objectSlice(String pdfText, int objNum) {
    final start = pdfText.indexOf('$objNum 0 obj');
    if (start < 0) return '';
    final end = pdfText.indexOf('endobj', start);
    if (end < 0) return pdfText.substring(start);
    return pdfText.substring(start, end);
  }

  static double? _aspectFromPageSlice(String slice) {
    final match = RegExp(
      r'/MediaBox\s*\[\s*[\d.]+\s+[\d.]+\s+([\d.]+)\s+([\d.]+)\s*\]',
    ).firstMatch(slice);
    if (match == null) return null;
    final width = double.tryParse(match.group(1)!);
    final height = double.tryParse(match.group(2)!);
    if (width == null || height == null || height == 0) return null;
    return width / height;
  }

  static String _textFromPage(
    String pdfText,
    int pageObj,
    Map<int, String> streams,
  ) {
    final slice = _objectSlice(pdfText, pageObj);
    final contentRefs = _contentObjectRefs(slice);
    final buffer = StringBuffer();
    for (final ref in contentRefs) {
      final stream = streams[ref];
      if (stream != null) buffer.write(_textFromContentStream(stream));
    }
    return buffer.toString().trim();
  }

  static List<int> _contentObjectRefs(String pageSlice) {
    final array = RegExp(r'/Contents\s*\[([^\]]+)\]').firstMatch(pageSlice);
    if (array != null) {
      return [
        for (final ref in RegExp(r'(\d+)\s+0\s+R').allMatches(array.group(1)!))
          int.parse(ref.group(1)!),
      ];
    }
    final single = RegExp(r'/Contents\s+(\d+)\s+0\s+R').firstMatch(pageSlice);
    if (single != null) return [int.parse(single.group(1)!)];
    return const [];
  }

  static String _textFromContentStream(String content) {
    final buffer = StringBuffer();
    for (final match
        in RegExp(r'\((?:\\.|[^\\()])*\)').allMatches(content)) {
      buffer.write(_decodePdfLiteral(match.group(0)!));
    }
    for (final match in RegExp(r'<([0-9A-Fa-f\s]+)>').allMatches(content)) {
      buffer.write(_decodePdfHex(match.group(1)!));
    }
    return buffer.toString();
  }

  static String _decodePdfLiteral(String raw) {
    final inner = raw.substring(1, raw.length - 1);
    final out = StringBuffer();
    for (var i = 0; i < inner.length; i++) {
      final ch = inner[i];
      if (ch != r'\') {
        out.write(ch);
        continue;
      }
      if (i + 1 >= inner.length) break;
      final next = inner[++i];
      switch (next) {
        case 'n':
          out.write('\n');
        case 'r':
          out.write('\r');
        case 't':
          out.write('\t');
        case 'b':
          out.write('\b');
        case 'f':
          out.write('\f');
        case '(':
          out.write('(');
        case ')':
          out.write(')');
        case '\\':
          out.write(r'\');
        default:
          if (next.codeUnitAt(0) >= 0x30 && next.codeUnitAt(0) <= 0x37) {
            final end = (i + 2 < inner.length &&
                    inner[i + 1].codeUnitAt(0) >= 0x30 &&
                    inner[i + 1].codeUnitAt(0) <= 0x37 &&
                    inner[i + 2].codeUnitAt(0) >= 0x30 &&
                    inner[i + 2].codeUnitAt(0) <= 0x37)
                ? i + 2
                : (i + 1 < inner.length &&
                        inner[i + 1].codeUnitAt(0) >= 0x30 &&
                        inner[i + 1].codeUnitAt(0) <= 0x37)
                    ? i + 1
                    : i;
            final octal = inner.substring(i, end + 1);
            i = end;
            out.writeCharCode(int.parse(octal, radix: 8) & 0xFF);
          } else {
            out.write(next);
          }
      }
    }
    return out.toString();
  }

  static String _decodePdfHex(String hex) {
    final cleaned = hex.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return '';
    final padded = cleaned.length.isOdd ? '${cleaned}0' : cleaned;
    final bytes = <int>[];
    for (var i = 0; i < padded.length; i += 2) {
      bytes.add(int.parse(padded.substring(i, i + 2), radix: 16));
    }
    return utf8.decode(bytes, allowMalformed: true);
  }
}
