import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import '../canvas/page_coords.dart';
import '../models/models.dart';

/// Margin used when fitting content into the new page bounds (8% inset).
const kOrientationFitMargin = 0.92;

/// Result of computing a uniform scale + translation that fits [contentBounds]
/// into [newSize], centered, with [margin].
({double scale, Offset translation}) orientationFitTransform({
  required Rect contentBounds,
  required Size newSize,
  double margin = kOrientationFitMargin,
}) {
  final w = math.max(contentBounds.width, 1.0);
  final h = math.max(contentBounds.height, 1.0);
  final scale = math.min(
    (newSize.width * margin) / w,
    (newSize.height * margin) / h,
  );
  final newCenter = Offset(newSize.width / 2, newSize.height / 2);
  final translation = newCenter - contentBounds.center * scale;
  return (scale: scale, translation: translation);
}

Offset remapCanonicalPoint(Offset p, double scale, Offset translation) =>
    Offset(p.dx * scale, p.dy * scale) + translation;

/// Union bounds of strokes, fills, images, and text in canonical space.
Rect? contentBoundsCanonical({
  required List<Stroke> strokes,
  required List<FilledRegion> fills,
  required List<PageImage> images,
  required List<TextBlock> texts,
}) {
  Rect? bounds;

  void expand(Rect r) {
    if (r.width <= 0 && r.height <= 0 && r.left == 0 && r.top == 0) {
      return;
    }
    bounds = bounds == null ? r : bounds!.expandToInclude(r);
  }

  for (final s in strokes) {
    if (s.points.isEmpty) continue;
    expand(s.bounds);
  }
  for (final f in fills) {
    final pts = decodeFillPoints(f.pathJson);
    if (pts.isEmpty) continue;
    var minX = pts.first.dx, maxX = pts.first.dx;
    var minY = pts.first.dy, maxY = pts.first.dy;
    for (final p in pts) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    expand(Rect.fromLTRB(minX, minY, maxX, maxY));
  }
  for (final img in images) {
    expand(img.rect);
  }
  for (final t in texts) {
    expand(t.axisAlignedBounds);
  }
  return bounds;
}

List<Offset> decodeFillPoints(String pathJson) {
  final raw = jsonDecode(pathJson) as List;
  return raw
      .map((e) => Offset((e[0] as num).toDouble(), (e[1] as num).toDouble()))
      .toList();
}

String encodeFillPoints(List<Offset> pts) =>
    jsonEncode(pts.map((o) => [o.dx, o.dy]).toList());

/// Pure remapping that returns new model instances (stroke width is final).
({
  List<Stroke> strokes,
  List<FilledRegion> fills,
  List<PageImage> images,
  List<TextBlock> texts,
  double scale,
})? remapPageContent({
  required PageSize pageSize,
  required PageOrientation from,
  required PageOrientation to,
  required List<Stroke> strokes,
  required List<FilledRegion> fills,
  required List<PageImage> images,
  required List<TextBlock> texts,
  double margin = kOrientationFitMargin,
}) {
  if (from == to) return null;
  final bounds = contentBoundsCanonical(
    strokes: strokes,
    fills: fills,
    images: images,
    texts: texts,
  );
  if (bounds == null) return null;

  final newSize = PageCoords.canonicalSize(pageSize, orientation: to);
  final fit = orientationFitTransform(
    contentBounds: bounds,
    newSize: newSize,
    margin: margin,
  );
  final scale = fit.scale;
  final translation = fit.translation;

  Offset map(Offset p) => remapCanonicalPoint(p, scale, translation);

  final newStrokes = [
    for (final s in strokes)
      Stroke(
        id: s.id,
        pageId: s.pageId,
        tool: s.tool,
        brushStyle: s.brushStyle,
        color: s.color,
        width: s.width * scale,
        points: [
          for (final pt in s.points)
            StrokePoint(
              pt.x * scale + translation.dx,
              pt.y * scale + translation.dy,
              pt.p,
            ),
        ],
        z: s.z,
        hidden: s.hidden,
      ),
  ];

  final newFills = [
    for (final f in fills)
      FilledRegion(
        id: f.id,
        pageId: f.pageId,
        color: f.color,
        pathJson: encodeFillPoints([
          for (final p in decodeFillPoints(f.pathJson)) map(p),
        ]),
        z: f.z,
      ),
  ];

  final newImages = [
    for (final img in images)
      PageImage(
        id: img.id,
        pageId: img.pageId,
        path: img.path,
        x: map(Offset(img.x, img.y)).dx,
        y: map(Offset(img.x, img.y)).dy,
        w: img.w * scale,
        h: img.h * scale,
        z: img.z,
      ),
  ];

  final newTexts = [
    for (final t in texts)
      TextBlock(
        id: t.id,
        pageId: t.pageId,
        x: map(Offset(t.x, t.y)).dx,
        y: map(Offset(t.x, t.y)).dy,
        w: t.w * scale,
        h: t.h * scale,
        text: t.text,
        fontSize: t.fontSize * scale,
        color: t.color,
        z: t.z,
        isNote: t.isNote,
        rotation: t.rotation,
      ),
  ];

  return (
    strokes: newStrokes,
    fills: newFills,
    images: newImages,
    texts: newTexts,
    scale: scale,
  );
}
