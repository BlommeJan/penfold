import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// One URI hyperlink on a PDF page, normalized to 0..1 display fractions
/// (top-left origin, matching Flutter layout).
class PdfPageLink {
  const PdfPageLink({
    required this.url,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final String url;
  final double left;
  final double top;
  final double width;
  final double height;
}

/// Parses URI link annotations from imported PDF pages (local, offline).
class PdfLinkExtractor {
  PdfLinkExtractor._();

  static final _cache = <String, List<PdfPageLink>>{};

  /// [pageIndex] is 1-based (page 1 = first page).
  static List<PdfPageLink> extractPageLinks(String pdfPath, int pageIndex) {
    final key = '$pdfPath#$pageIndex';
    final cached = _cache[key];
    if (cached != null) return cached;

    final links = _parsePageLinks(
      File(pdfPath).readAsBytesSync(),
      pageIndex,
    );
    _cache[key] = links;
    return links;
  }

  static void clearCache() => _cache.clear();

  static List<PdfPageLink> _parsePageLinks(Uint8List bytes, int pageIndex) {
    if (pageIndex < 1) return const [];
    final pdfText = latin1.decode(bytes);
    final pageObjects = _orderedPageObjects(pdfText);
    if (pageIndex > pageObjects.length) return const [];

    final pageObj = pageObjects[pageIndex - 1];
    final pageSlice = _objectSlice(pdfText, pageObj);
    final media = _mediaBox(pageSlice) ?? (width: 595.27559, height: 841.88976);

    final links = <PdfPageLink>[];
    for (final annotRef in _annotObjectRefs(pageSlice)) {
      final annotSlice = _objectSlice(pdfText, annotRef);
      final link = _linkFromAnnot(pdfText, annotSlice, media.width, media.height);
      if (link != null) links.add(link);
    }
    return links;
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

  static ({double width, double height})? _mediaBox(String pageSlice) {
    final match = RegExp(
      r'/MediaBox\s*\[\s*[\d.]+\s+[\d.]+\s+([\d.]+)\s+([\d.]+)\s*\]',
    ).firstMatch(pageSlice);
    if (match == null) return null;
    final width = double.tryParse(match.group(1)!);
    final height = double.tryParse(match.group(2)!);
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }
    return (width: width, height: height);
  }

  static List<int> _annotObjectRefs(String pageSlice) {
    final array = RegExp(r'/Annots\s*\[([^\]]+)\]').firstMatch(pageSlice);
    if (array != null) {
      return [
        for (final ref in RegExp(r'(\d+)\s+0\s+R').allMatches(array.group(1)!))
          int.parse(ref.group(1)!),
      ];
    }
    final single = RegExp(r'/Annots\s+(\d+)\s+0\s+R').firstMatch(pageSlice);
    if (single != null) return [int.parse(single.group(1)!)];
    return const [];
  }

  static PdfPageLink? _linkFromAnnot(
    String pdfText,
    String annotSlice,
    double pageW,
    double pageH,
  ) {
    if (!annotSlice.contains('/Subtype/Link') &&
        !annotSlice.contains('/Subtype /Link')) {
      return null;
    }

    final rectMatch = RegExp(
      r'/Rect\s*\[\s*([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s+([\d.\-]+)\s*\]',
    ).firstMatch(annotSlice);
    if (rectMatch == null) return null;

    final llx = double.parse(rectMatch.group(1)!);
    final lly = double.parse(rectMatch.group(2)!);
    final urx = double.parse(rectMatch.group(3)!);
    final ury = double.parse(rectMatch.group(4)!);

    final url = _uriFromAnnot(pdfText, annotSlice);
    if (url == null || url.isEmpty) return null;

    final width = (urx - llx) / pageW;
    final height = (ury - lly) / pageH;
    if (width <= 0 || height <= 0) return null;

    return PdfPageLink(
      url: url,
      left: llx / pageW,
      top: (pageH - ury) / pageH,
      width: width,
      height: height,
    );
  }

  static String? _uriFromAnnot(String pdfText, String annotSlice) {
    final inlineAction = RegExp(r'/A\s*<<([^>]*)>>', dotAll: true).firstMatch(
      annotSlice,
    );
    if (inlineAction != null) {
      return _uriFromAction(inlineAction.group(1)!);
    }

    final actionRef = RegExp(r'/A\s+(\d+)\s+0\s+R').firstMatch(annotSlice);
    if (actionRef != null) {
      final actionSlice = _objectSlice(pdfText, int.parse(actionRef.group(1)!));
      return _uriFromAction(actionSlice);
    }

    return null;
  }

  static String? _uriFromAction(String actionSlice) {
    if (!actionSlice.contains('/URI') &&
        !actionSlice.contains('/S /URI') &&
        !actionSlice.contains('/S/URI')) {
      return null;
    }

    final literal = RegExp(r'/URI\s*(\((?:\\.|[^\\()])*\))').firstMatch(
      actionSlice,
    );
    if (literal != null) {
      return _decodePdfLiteral(literal.group(1)!);
    }

    final hex = RegExp(r'/URI\s*<([0-9A-Fa-f\s]+)>').firstMatch(actionSlice);
    if (hex != null) {
      return _decodePdfHex(hex.group(1)!);
    }

    return null;
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
