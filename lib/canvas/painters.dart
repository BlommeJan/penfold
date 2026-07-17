import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/models.dart';
import 'page_coords.dart';

/// Paints the page background: white paper + template pattern,
/// or the rendered PDF page image when present.
class PagePainter extends CustomPainter {
  final PageTemplate template;
  final PageSize pageSize;
  final PageOrientation orientation;
  final ui.Image? pdfImage;

  PagePainter({
    required this.template,
    required this.pageSize,
    this.orientation = PageOrientation.portrait,
    this.pdfImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paper = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, paper);

    if (pdfImage != null) {
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: pdfImage!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
      return;
    }

    final line = Paint()
      ..color = const Color(0xFFD9E2EC)
      ..strokeWidth = 1;

    // Template spacing in canonical 0.1 mm, converted to display pixels.
    final lineSpacing = PageCoords.canonicalToDisplayLength(
        70, size, pageSize, orientation: orientation); // 7 mm
    final gridSpacing = PageCoords.canonicalToDisplayLength(
        50, size, pageSize, orientation: orientation); // 5 mm
    final marginLeft = PageCoords.canonicalToDisplayLength(
        250, size, pageSize, orientation: orientation); // 25 mm
    final marginSide = PageCoords.canonicalToDisplayLength(
        100, size, pageSize, orientation: orientation); // 10 mm

    switch (template) {
      case PageTemplate.blank:
        break;
      case PageTemplate.lined:
        for (var y = lineSpacing * 2; y < size.height; y += lineSpacing) {
          canvas.drawLine(
              Offset(marginSide, y), Offset(size.width - marginSide, y), line);
        }
      case PageTemplate.collegeRuled:
        final marginPaint = Paint()
          ..color = const Color(0xFFE8B4B4)
          ..strokeWidth = 1;
        canvas.drawLine(
            Offset(marginLeft, 0), Offset(marginLeft, size.height), marginPaint);
        for (var y = lineSpacing * 2; y < size.height; y += lineSpacing) {
          canvas.drawLine(
              Offset(marginLeft, y), Offset(size.width - marginSide, y), line);
        }
      case PageTemplate.grid:
        for (var y = gridSpacing; y < size.height; y += gridSpacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
        }
        for (var x = gridSpacing; x < size.width; x += gridSpacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
        }
      case PageTemplate.dotted:
        final dot = Paint()..color = const Color(0xFFC3CFDD);
        for (var y = gridSpacing; y < size.height; y += gridSpacing) {
          for (var x = gridSpacing; x < size.width; x += gridSpacing) {
            canvas.drawCircle(Offset(x, y), 1.4, dot);
          }
        }
    }
  }

  @override
  bool shouldRepaint(PagePainter old) =>
      old.template != template ||
      old.pageSize != pageSize ||
      old.orientation != orientation ||
      old.pdfImage != pdfImage;
}

/// Paints committed strokes + the in-progress stroke + selection overlay.
class InkPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? current;
  final Set<String> selectedIds;
  final List<Offset>? lassoPath;
  final Rect? selectionBounds;
  final List<PageImage> images;
  final Map<String, ui.Image> decodedImages;
  final String? selectedImageId;
  final List<FilledRegion> fills;
  final List<TextBlock> textBlocks;
  final PageSize pageSize;
  final PageOrientation orientation;
  final Size displaySize;

  final bool showTransformHandles;
  final double selectionRotation;
  final Rect? marqueeRect;

  InkPainter({
    required this.strokes,
    this.current,
    this.selectedIds = const {},
    this.lassoPath,
    this.selectionBounds,
    this.images = const [],
    this.decodedImages = const {},
    this.selectedImageId,
    this.fills = const [],
    this.textBlocks = const [],
    this.showTransformHandles = false,
    this.selectionRotation = 0,
    this.marqueeRect,
    required this.pageSize,
    this.orientation = PageOrientation.portrait,
    required this.displaySize,
    required int revision,
  }) : _revision = revision;

  final int _revision;

  Offset _toDisplay(double x, double y) => PageCoords.canonicalToDisplay(
        Offset(x, y),
        displaySize,
        pageSize,
        orientation: orientation,
      );

  @override
  void paint(Canvas canvas, Size size) {
    // Keep ink visually inside the paper even when stroke caps or legacy
    // points sit slightly outside the clamped centerline.
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    for (final fill in fills) {
      _drawFill(canvas, fill);
    }

    for (final img in images) {
      final decoded = decodedImages[img.path];
      if (decoded == null) continue;
      final rect = PageCoords.canonicalRectToDisplay(
          img.rect, displaySize, pageSize, orientation: orientation);
      paintImage(
        canvas: canvas,
        rect: rect,
        image: decoded,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.medium,
      );
    }

    for (final tb in textBlocks) {
      _drawTextBlock(canvas, tb);
    }

    for (final s in strokes) {
      if (s.tool == ToolType.tape) continue;
      _drawStroke(canvas, s, dim: false);
    }
    if (current != null && current!.tool != ToolType.tape) {
      _drawStroke(canvas, current!, dim: false);
    }

    for (final s in strokes) {
      if (s.tool != ToolType.tape) continue;
      _drawTapeStroke(canvas, s);
    }
    if (current != null && current!.tool == ToolType.tape) {
      _drawTapeStroke(canvas, current!);
    }

    canvas.restore();

    if (selectedIds.isNotEmpty) {
      for (final s in strokes.where((s) => selectedIds.contains(s.id))) {
        final b = PageCoords.canonicalRectToDisplay(
            s.bounds, displaySize, pageSize, orientation: orientation);
        canvas.drawRect(
            b,
            Paint()
              ..color = const Color(0x182455C3)
              ..style = PaintingStyle.fill);
      }
    }

    if (selectionBounds != null) {
      final b = PageCoords.canonicalRectToDisplay(
          selectionBounds!, displaySize, pageSize, orientation: orientation);
      final inflated = b.inflate(6);
      if (showTransformHandles) {
        _drawTransformHandles(canvas, inflated, selectionRotation);
      } else {
        _drawDashedRect(canvas, inflated);
      }
    }

    if (marqueeRect != null) {
      final paint = Paint()
        ..color = const Color(0x662455C3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(marqueeRect!, paint);
      _drawDashedRect(canvas, marqueeRect!);
    }

    if (selectedImageId != null) {
      PageImage? img;
      for (final i in images) {
        if (i.id == selectedImageId) {
          img = i;
          break;
        }
      }
      if (img != null) {
        final rect =
            PageCoords.canonicalRectToDisplay(
                img.rect, displaySize, pageSize, orientation: orientation);
        _drawDashedRect(canvas, rect.inflate(3));
        final handle = rect.bottomRight;
        canvas.drawCircle(
            handle,
            9,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill);
        canvas.drawCircle(
            handle,
            9,
            Paint()
              ..color = const Color(0xFF2455C3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2);
      }
    }

    if (lassoPath != null && lassoPath!.length > 1) {
      final p = Path()..moveTo(lassoPath!.first.dx, lassoPath!.first.dy);
      for (final o in lassoPath!.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(
          p,
          Paint()
            ..color = const Color(0xFF2455C3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
    }
  }

  void _drawFill(Canvas canvas, FilledRegion fill) {
    final raw = jsonDecode(fill.pathJson) as List;
    if (raw.isEmpty) return;
    final path = Path();
    final first = raw.first as List;
    final start = _toDisplay((first[0] as num).toDouble(),
        (first[1] as num).toDouble());
    path.moveTo(start.dx, start.dy);
    for (final pt in raw.skip(1)) {
      final p = pt as List;
      final d = _toDisplay((p[0] as num).toDouble(), (p[1] as num).toDouble());
      path.lineTo(d.dx, d.dy);
    }
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..color = Color(fill.color)
          ..style = PaintingStyle.fill);
  }

  void _drawTextBlock(Canvas canvas, TextBlock tb) {
    final rect = PageCoords.canonicalRectToDisplay(
        tb.rect, displaySize, pageSize, orientation: orientation);
    final center = rect.center;

    canvas.save();
    if (tb.rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(tb.rotation);
      canvas.translate(-center.dx, -center.dy);
    }

    if (tb.isNote) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          Paint()..color = const Color(0xFFFFF9E6));
    }
    final fontSize = PageCoords.canonicalToDisplayLength(
        tb.fontSize, displaySize, pageSize, orientation: orientation);
    final tp = TextPainter(
      text: TextSpan(
        text: tb.text,
        style: TextStyle(
          color: Color(tb.color),
          fontSize: fontSize,
          height: 1.25,
          letterSpacing: 0.15,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width);
    tp.paint(canvas, rect.topLeft);
    canvas.restore();
  }

  void _drawTapeStroke(Canvas canvas, Stroke s) {
    final base = Color(s.color);
    final covering = !s.hidden;
    final color = covering ? base.withOpacity(0.62) : base.withOpacity(0.18);
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final pts = s.points;
    if (pts.isEmpty) return;

    final displayWidth = PageCoords.canonicalToDisplayLength(
        s.width, displaySize, pageSize, orientation: orientation);
    paint.strokeWidth = displayWidth;

    if (pts.length == 1) {
      final c = _toDisplay(pts[0].x, pts[0].y);
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(c, displayWidth / 2, paint);
      if (!covering) {
        _drawTapeRevealOutline(canvas, pts, displayWidth);
      }
      return;
    }

    final path = Path()
      ..moveTo(_toDisplay(pts[0].x, pts[0].y).dx,
          _toDisplay(pts[0].x, pts[0].y).dy);
    for (var i = 1; i < pts.length; i++) {
      final a = _toDisplay(pts[i - 1].x, pts[i - 1].y);
      final b = _toDisplay(pts[i].x, pts[i].y);
      final mx = (a.dx + b.dx) / 2;
      final my = (a.dy + b.dy) / 2;
      path.quadraticBezierTo(a.dx, a.dy, mx, my);
    }
    final last = _toDisplay(pts.last.x, pts.last.y);
    path.lineTo(last.dx, last.dy);
    canvas.drawPath(path, paint);

    if (!covering) {
      _drawTapeRevealOutline(canvas, pts, displayWidth);
    }
  }

  void _drawTapeRevealOutline(
      Canvas canvas, List<StrokePoint> pts, double displayWidth) {
    final outline = Paint()
      ..color = const Color(0xFF8A8F98).withOpacity(0.55)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 1; i < pts.length; i++) {
      final a = _toDisplay(pts[i - 1].x, pts[i - 1].y);
      final b = _toDisplay(pts[i].x, pts[i].y);
      canvas.drawLine(a, b, outline);
    }
  }

  void _drawStroke(Canvas canvas, Stroke s, {required bool dim}) {
    final isHighlighter = s.tool == ToolType.highlighter;
    final base = Color(s.color);
    final opacity = switch (s.brushStyle) {
      BrushStyle.pencil => 0.6,
      BrushStyle.marker => 0.75,
      _ => 1.0,
    };
    final color = isHighlighter
        ? base.withOpacity(0.35)
        : base.withOpacity(opacity);

    final paint = Paint()
      ..color = color
      ..strokeCap = isHighlighter || s.brushStyle == BrushStyle.marker
          ? StrokeCap.square
          : StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final pts = s.points;
    if (pts.isEmpty) return;

    final displayWidth = PageCoords.canonicalToDisplayLength(
        s.width, displaySize, pageSize, orientation: orientation);

    if (pts.length == 1) {
      final c = _toDisplay(pts[0].x, pts[0].y);
      paint
        ..style = PaintingStyle.fill
        ..strokeWidth = 0;
      canvas.drawCircle(c, displayWidth / 2, paint);
      return;
    }

    if (isHighlighter) {
      paint.strokeWidth = displayWidth;
      final path = Path()
        ..moveTo(_toDisplay(pts[0].x, pts[0].y).dx,
            _toDisplay(pts[0].x, pts[0].y).dy);
      for (var i = 1; i < pts.length; i++) {
        final a = _toDisplay(pts[i - 1].x, pts[i - 1].y);
        final b = _toDisplay(pts[i].x, pts[i].y);
        final mx = (a.dx + b.dx) / 2;
        final my = (a.dy + b.dy) / 2;
        path.quadraticBezierTo(a.dx, a.dy, mx, my);
      }
      final last = _toDisplay(pts.last.x, pts.last.y);
      path.lineTo(last.dx, last.dy);
      canvas.drawPath(path, paint);
      return;
    }

    for (var i = 1; i < pts.length; i++) {
      final a = pts[i - 1];
      final b = pts[i];
      final da = _toDisplay(a.x, a.y);
      final db = _toDisplay(b.x, b.y);
      final pressure = ((a.p + b.p) / 2).clamp(0.15, 1.0);
      final velocity = Offset(b.x - a.x, b.y - a.y).distance;
      final velFactor = switch (s.brushStyle) {
        BrushStyle.fountainPen =>
          (1.0 - (velocity / 80).clamp(0.0, 0.35)),
        BrushStyle.calligraphy =>
          (0.65 + (velocity / 120).clamp(0.0, 0.55)),
        _ => 1.0,
      };
      final pressureCurve = switch (s.brushStyle) {
        BrushStyle.fountainPen => (0.25 + 1.1 * pressure * pressure),
        BrushStyle.calligraphy => (0.35 + 0.9 * pressure),
        BrushStyle.marker => (0.85 + 0.25 * pressure),
        _ => (0.45 + 0.75 * pressure),
      };
      var strokeW = displayWidth * pressureCurve * velFactor;
      if (s.brushStyle == BrushStyle.marker) strokeW *= 1.35;
      if (s.brushStyle == BrushStyle.calligraphy) {
        final angle = math.atan2(b.y - a.y, b.x - a.x);
        strokeW *= (0.55 + 0.45 * math.sin(angle).abs());
      }
      paint.strokeWidth = strokeW;

      if (s.brushStyle == BrushStyle.pencil) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = displayWidth * 0.8;
        _drawPencilSegment(canvas, da, db, paint);
      } else if (s.brushStyle == BrushStyle.marker) {
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(da, db, paint);
      } else {
        canvas.drawLine(da, db, paint);
      }
    }
  }

  void _drawPencilSegment(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 3.0;
    const gap = 2.0;
    final delta = b - a;
    final len = delta.distance;
    if (len == 0) return;
    final dir = delta / len;
    var dist = 0.0;
    while (dist < len) {
      final end = (dist + dash).clamp(0.0, len);
      final p1 = a + dir * dist;
      final p2 = a + dir * end;
      canvas.drawLine(p1, p2, paint);
      dist = end + gap;
    }
  }

  void _drawTransformHandles(Canvas canvas, Rect r, double rotation) {
    canvas.save();
    final center = r.center;
    if (rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);
    }
    _drawDashedRect(canvas, r);
    final corners = [
      r.topLeft,
      r.topRight,
      r.bottomLeft,
      r.bottomRight,
    ];
    for (final c in corners) {
      _drawHandle(canvas, c);
    }
    final rotatePt = center + Offset(0, -r.height / 2 - 28);
    final line = Paint()
      ..color = const Color(0xFF2455C3)
      ..strokeWidth = 1.5;
    canvas.drawLine(center, rotatePt, line);
    _drawHandle(canvas, rotatePt, filled: true);
    canvas.restore();
  }

  void _drawHandle(Canvas canvas, Offset pt, {bool filled = false}) {
    canvas.drawCircle(
        pt,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
    canvas.drawCircle(
        pt,
        7,
        Paint()
          ..color = const Color(0xFF2455C3)
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  void _drawDashedRect(Canvas canvas, Rect r) {
    final paint = Paint()
      ..color = const Color(0xFF2455C3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 7.0, gap = 5.0;
    final path = Path()..addRect(r);
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final end = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, end), paint);
        dist = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(InkPainter old) => old._revision != _revision;
}

/// Circle outline at the stylus cursor showing brush or eraser radius.
class BrushPreviewPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  BrushPreviewPainter({
    required this.center,
    required this.radius,
    this.color = const Color(0x992455C3),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(BrushPreviewPainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.color != color;
}

/// Lightweight thumbnail painter for page overview grid.
class PageThumbnailPainter extends CustomPainter {
  final PageTemplate template;
  final PageSize pageSize;
  final PageOrientation orientation;
  final List<Stroke> strokes;
  final List<FilledRegion> fills;
  final List<TextBlock> textBlocks;
  final ui.Image? pdfImage;

  PageThumbnailPainter({
    required this.template,
    required this.pageSize,
    this.orientation = PageOrientation.portrait,
    required this.strokes,
    this.fills = const [],
    this.textBlocks = const [],
    this.pdfImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF5F7FA),
    );
    final pageAspect =
        PageCoords.effectiveAspect(pageSize, orientation: orientation);
    final targetAspect = size.width / size.height;
    Rect pageRect;
    if (pageAspect > targetAspect) {
      final h = size.width / pageAspect;
      pageRect = Rect.fromLTWH(0, (size.height - h) / 2, size.width, h);
    } else {
      final w = size.height * pageAspect;
      pageRect = Rect.fromLTWH((size.width - w) / 2, 0, w, size.height);
    }
    canvas.save();
    canvas.clipRRect(
        RRect.fromRectAndRadius(pageRect, const Radius.circular(2)));
    PagePainter(
      template: template,
      pageSize: pageSize,
      orientation: orientation,
      pdfImage: pdfImage,
    ).paint(canvas, pageRect.size);
    final ink = InkPainter(
      strokes: strokes,
      fills: fills,
      textBlocks: textBlocks,
      pageSize: pageSize,
      orientation: orientation,
      displaySize: pageRect.size,
      revision: 0,
    );
    canvas.translate(pageRect.left, pageRect.top);
    ink.paint(canvas, pageRect.size);
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(pageRect, const Radius.circular(2)),
      Paint()
        ..color = const Color(0x22000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(PageThumbnailPainter old) =>
      old.template != template ||
      old.pageSize != pageSize ||
      old.orientation != orientation ||
      old.strokes != strokes ||
      old.fills != fills ||
      old.textBlocks != textBlocks ||
      old.pdfImage != pdfImage;
}
