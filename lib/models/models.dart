import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

enum ToolType {
  pen,
  highlighter,
  eraser,
  lasso,
  selection,
  shape,
  fill,
  text,
  tape,
}

enum BrushStyle { pen, fountainPen, pencil, marker, calligraphy }

enum PageTemplate { blank, lined, grid, dotted, collegeRuled }

/// Per-page orientation (v0.2.22). Portrait keeps canonical width × height;
/// landscape swaps them for display and export.
enum PageOrientation {
  portrait,
  landscape;

  double aspectOf(PageSize pageSize) => switch (this) {
        PageOrientation.portrait => pageSize.aspect,
        PageOrientation.landscape => pageSize.height / pageSize.width,
      };

  String get label => switch (this) {
        PageOrientation.portrait => 'Portrait',
        PageOrientation.landscape => 'Landscape',
      };
}

/// Canonical page dimensions in 0.1 mm units.
enum PageSize {
  a4(2100, 2970),
  a5(1480, 2100),
  letter(2159, 2794);

  const PageSize(this.width, this.height);
  final int width;
  final int height;

  double get aspect => width / height;

  String get label => switch (this) {
        PageSize.a4 => 'A4',
        PageSize.a5 => 'A5',
        PageSize.letter => 'Letter',
      };
}

class Folder {
  final String id;
  String name;
  int sortOrder;
  String? parentId;

  Folder({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.parentId,
  });

  Map<String, Object?> toRow() => {
        'id': id,
        'name': name,
        'sort_order': sortOrder,
        'parent_id': parentId,
      };

  static Folder fromRow(Map<String, Object?> r) => Folder(
        id: r['id'] as String,
        name: r['name'] as String,
        sortOrder: r['sort_order'] as int,
        parentId: r['parent_id'] as String?,
      );
}

class Notebook {
  final String id;
  String title;
  int coverColor;
  PageTemplate template;
  PageSize pageSize;
  String? folderId;
  final int createdAt;
  int updatedAt;

  Notebook({
    required this.id,
    required this.title,
    required this.coverColor,
    required this.template,
    this.pageSize = PageSize.a4,
    this.folderId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toRow() => {
        'id': id,
        'title': title,
        'color': coverColor,
        'template': template.index,
        'page_size': pageSize.index,
        'folder_id': folderId,
        'created': createdAt,
        'updated': updatedAt,
      };

  static Notebook fromRow(Map<String, Object?> r) => Notebook(
        id: r['id'] as String,
        title: r['title'] as String,
        coverColor: r['color'] as int,
        template: PageTemplate.values[r['template'] as int],
        pageSize: PageSize.values[(r['page_size'] as int?) ?? 0],
        folderId: r['folder_id'] as String?,
        createdAt: r['created'] as int,
        updatedAt: r['updated'] as int,
      );
}

class NotePage {
  final String id;
  final String notebookId;
  int index;
  PageTemplate template;
  PageSize pageSize;
  PageOrientation orientation;

  /// If non-null, this page is a rendered PDF page: path to a PNG background.
  final String? pdfImagePath;

  /// Lazy PDF: path to source PDF file on device.
  final String? pdfSourcePath;

  /// 1-based page index inside [pdfSourcePath].
  final int? pdfPageIndex;

  bool bookmarked;

  /// Aspect ratio (width / height) of the page.
  double aspect;

  NotePage({
    required this.id,
    required this.notebookId,
    required this.index,
    required this.template,
    this.pageSize = PageSize.a4,
    this.orientation = PageOrientation.portrait,
    this.pdfImagePath,
    this.pdfSourcePath,
    this.pdfPageIndex,
    this.bookmarked = false,
    double? aspect,
  }) : aspect = aspect ?? orientation.aspectOf(pageSize);

  Map<String, Object?> toRow() => {
        'id': id,
        'notebook_id': notebookId,
        'idx': index,
        'template': template.index,
        'page_size': pageSize.index,
        'orientation': orientation.index,
        'pdf_image': pdfImagePath,
        'pdf_source_path': pdfSourcePath,
        'pdf_page_index': pdfPageIndex,
        'bookmarked': bookmarked ? 1 : 0,
        'aspect': aspect,
      };

  static NotePage fromRow(Map<String, Object?> r) {
    final ps = PageSize.values[(r['page_size'] as int?) ?? 0];
    final orient =
        PageOrientation.values[(r['orientation'] as int?) ?? 0];
    return NotePage(
      id: r['id'] as String,
      notebookId: r['notebook_id'] as String,
      index: r['idx'] as int,
      template: PageTemplate.values[r['template'] as int],
      pageSize: ps,
      orientation: orient,
      pdfImagePath: r['pdf_image'] as String?,
      pdfSourcePath: r['pdf_source_path'] as String?,
      pdfPageIndex: r['pdf_page_index'] as int?,
      bookmarked: (r['bookmarked'] as int?) == 1,
      aspect: (r['aspect'] as num?)?.toDouble() ?? orient.aspectOf(ps),
    );
  }
}

class PageImage {
  final String id;
  final String pageId;
  final String path;
  double x, y, w, h;
  final int z;

  PageImage({
    required this.id,
    required this.pageId,
    required this.path,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.z,
  });

  Rect get rect => Rect.fromLTWH(x, y, w, h);

  set rect(Rect r) {
    x = r.left;
    y = r.top;
    w = r.width;
    h = r.height;
  }

  Map<String, Object?> toRow() => {
        'id': id,
        'page_id': pageId,
        'path': path,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
        'z': z,
      };

  static PageImage fromRow(Map<String, Object?> r) => PageImage(
        id: r['id'] as String,
        pageId: r['page_id'] as String,
        path: r['path'] as String,
        x: (r['x'] as num).toDouble(),
        y: (r['y'] as num).toDouble(),
        w: (r['w'] as num).toDouble(),
        h: (r['h'] as num).toDouble(),
        z: r['z'] as int,
      );

  PageImage copy() => PageImage(
      id: id, pageId: pageId, path: path, x: x, y: y, w: w, h: h, z: z);
}

class FilledRegion {
  final String id;
  final String pageId;
  final int color;
  final String pathJson;
  final int z;

  FilledRegion({
    required this.id,
    required this.pageId,
    required this.color,
    required this.pathJson,
    required this.z,
  });

  Map<String, Object?> toRow() => {
        'id': id,
        'page_id': pageId,
        'color': color,
        'path_json': pathJson,
        'z': z,
      };

  static FilledRegion fromRow(Map<String, Object?> r) => FilledRegion(
        id: r['id'] as String,
        pageId: r['page_id'] as String,
        color: r['color'] as int,
        pathJson: r['path_json'] as String,
        z: r['z'] as int,
      );

  FilledRegion copy() => FilledRegion(
        id: id,
        pageId: pageId,
        color: color,
        pathJson: pathJson,
        z: z,
      );
}

class TextBlock {
  final String id;
  final String pageId;
  double x, y, w, h;
  String text;
  double fontSize;
  int color;
  final int z;
  bool isNote;
  double rotation;

  TextBlock({
    required this.id,
    required this.pageId,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.z,
    this.isNote = false,
    this.rotation = 0,
  });

  Rect get rect => Rect.fromLTWH(x, y, w, h);

  /// Axis-aligned bounds after applying [rotation] around [rect] center.
  Rect get axisAlignedBounds {
    if (rotation == 0) return rect;
    final corners = _rotatedCorners();
    var minX = corners.first.dx, maxX = corners.first.dx;
    var minY = corners.first.dy, maxY = corners.first.dy;
    for (final c in corners.skip(1)) {
      minX = math.min(minX, c.dx);
      maxX = math.max(maxX, c.dx);
      minY = math.min(minY, c.dy);
      maxY = math.max(maxY, c.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  bool containsCanonicalPoint(Offset p) {
    if (rotation == 0) return rect.contains(p);
    final center = rect.center;
    final dx = p.dx - center.dx;
    final dy = p.dy - center.dy;
    final cos = math.cos(-rotation);
    final sin = math.sin(-rotation);
    final lx = dx * cos - dy * sin;
    final ly = dx * sin + dy * cos;
    return lx >= -w / 2 && lx <= w / 2 && ly >= -h / 2 && ly <= h / 2;
  }

  List<Offset> _rotatedCorners() {
    final center = rect.center;
    final cos = math.cos(rotation);
    final sin = math.sin(rotation);
    final corners = [
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ];
    return corners
        .map((c) {
          final dx = c.dx - center.dx;
          final dy = c.dy - center.dy;
          return Offset(
            center.dx + dx * cos - dy * sin,
            center.dy + dx * sin + dy * cos,
          );
        })
        .toList(growable: false);
  }

  Map<String, Object?> toRow() => {
        'id': id,
        'page_id': pageId,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
        'text': text,
        'font_size': fontSize,
        'color': color,
        'z': z,
        'is_note': isNote ? 1 : 0,
        'rotation': rotation,
      };

  static TextBlock fromRow(Map<String, Object?> r) => TextBlock(
        id: r['id'] as String,
        pageId: r['page_id'] as String,
        x: (r['x'] as num).toDouble(),
        y: (r['y'] as num).toDouble(),
        w: (r['w'] as num).toDouble(),
        h: (r['h'] as num).toDouble(),
        text: r['text'] as String,
        fontSize: (r['font_size'] as num).toDouble(),
        color: r['color'] as int,
        z: r['z'] as int,
        isNote: (r['is_note'] as int?) == 1,
        rotation: (r['rotation'] as num?)?.toDouble() ?? 0,
      );

  TextBlock copy() => TextBlock(
        id: id,
        pageId: pageId,
        x: x,
        y: y,
        w: w,
        h: h,
        text: text,
        fontSize: fontSize,
        color: color,
        z: z,
        isNote: isNote,
        rotation: rotation,
      );
}

class StrokePoint {
  final double x;
  final double y;
  final double p; // pressure 0..1

  const StrokePoint(this.x, this.y, this.p);

  StrokePoint translated(Offset d) => StrokePoint(x + d.dx, y + d.dy, p);
}

class Stroke {
  final String id;
  final String pageId;
  final ToolType tool;
  final BrushStyle brushStyle;
  final int color;
  final double width;
  List<StrokePoint> points;
  final int z;
  /// When false (default), tape covers content; true = revealed (tap toggles).
  bool hidden;

  Stroke({
    required this.id,
    required this.pageId,
    required this.tool,
    this.brushStyle = BrushStyle.pen,
    required this.color,
    required this.width,
    required this.points,
    required this.z,
    this.hidden = false,
  });

  String encodePoints() =>
      jsonEncode(points.map((e) => [e.x, e.y, e.p]).toList());

  static List<StrokePoint> decodePoints(String s) {
    final raw = jsonDecode(s) as List;
    return raw
        .map((e) => StrokePoint((e[0] as num).toDouble(),
            (e[1] as num).toDouble(), (e[2] as num).toDouble()))
        .toList();
  }

  Map<String, Object?> toRow() => {
        'id': id,
        'page_id': pageId,
        'tool': tool.index,
        'brush_style': brushStyle.index,
        'color': color,
        'width': width,
        'points': encodePoints(),
        'z': z,
        'hidden': hidden ? 1 : 0,
      };

  static Stroke fromRow(Map<String, Object?> r) => Stroke(
        id: r['id'] as String,
        pageId: r['page_id'] as String,
        tool: ToolType.values[r['tool'] as int],
        brushStyle: BrushStyle.values[(r['brush_style'] as int?) ?? 0],
        color: r['color'] as int,
        width: (r['width'] as num).toDouble(),
        points: decodePoints(r['points'] as String),
        z: r['z'] as int,
        hidden: (r['hidden'] as int?) == 1,
      );

  Rect get bounds {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.x, maxX = points.first.x;
    double minY = points.first.y, maxY = points.first.y;
    for (final pt in points) {
      minX = math.min(minX, pt.x);
      maxX = math.max(maxX, pt.x);
      minY = math.min(minY, pt.y);
      maxY = math.max(maxY, pt.y);
    }
    final pad = width;
    return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
  }

  void translate(Offset d) {
    points = points.map((pt) => pt.translated(d)).toList();
  }

  Stroke copy() => Stroke(
        id: id,
        pageId: pageId,
        tool: tool,
        brushStyle: brushStyle,
        color: color,
        width: width,
        points: List.of(points),
        z: z,
        hidden: hidden,
      );
}

class Tag {
  final String id;
  String name;

  Tag({required this.id, required this.name});

  Map<String, Object?> toRow() => {'id': id, 'name': name};

  static Tag fromRow(Map<String, Object?> r) => Tag(
        id: r['id'] as String,
        name: r['name'] as String,
      );
}

class SearchResult {
  final Notebook notebook;
  final String snippet;

  SearchResult({required this.notebook, required this.snippet});
}

/// OCR indexing status for ink strokes (v0.2.8+).
enum InkIndexStatus {
  pending,
  indexed,
  failed;

  int get dbValue => index;

  static InkIndexStatus fromDb(int v) {
    if (v < 0 || v >= InkIndexStatus.values.length) {
      return InkIndexStatus.failed;
    }
    return InkIndexStatus.values[v];
  }
}

class InkIndexEntry {
  final String id;
  final String pageId;
  final String? strokeId;
  final String text;
  final InkIndexStatus status;
  final int? indexedAt;

  InkIndexEntry({
    required this.id,
    required this.pageId,
    this.strokeId,
    required this.text,
    required this.status,
    this.indexedAt,
  });

  Map<String, Object?> toRow() => {
        'id': id,
        'page_id': pageId,
        'stroke_id': strokeId,
        'text': text,
        'status': status.dbValue,
        'indexed_at': indexedAt,
      };

  static InkIndexEntry fromRow(Map<String, Object?> r) => InkIndexEntry(
        id: r['id'] as String,
        pageId: r['page_id'] as String,
        strokeId: r['stroke_id'] as String?,
        text: r['text'] as String,
        status: InkIndexStatus.fromDb(r['status'] as int),
        indexedAt: r['indexed_at'] as int?,
      );
}

/// Per-page OCR indexing summary for overview badges.
class PageOcrStatus {
  final int indexed;
  final int pending;
  final int failed;

  const PageOcrStatus({
    this.indexed = 0,
    this.pending = 0,
    this.failed = 0,
  });

  bool get hasInk => indexed + pending + failed > 0;
  bool get isComplete => pending == 0 && failed == 0 && indexed > 0;
  bool get hasPending => pending > 0;
}
