import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';

const _uuid = Uuid();

/// On-device handwriting OCR queue (ML Kit, no network).
class InkOcrService {
  InkOcrService._();
  static final InkOcrService instance = InkOcrService._();

  final _db = AppDatabase.instance;
  final _queue = <_OcrJob>[];
  bool _processing = false;
  TextRecognizer? _recognizer;

  /// When true (unit tests), skips ML Kit and marks strokes failed quietly.
  static bool disableMlKit = false;

  Future<void> enqueueStroke(Stroke stroke) async {
    if (stroke.tool != ToolType.pen && stroke.tool != ToolType.highlighter) {
      return;
    }
    if (stroke.points.length < 2) return;

    final entryId = _uuid.v4();
    await _db.insertInkIndexPending(
      id: entryId,
      pageId: stroke.pageId,
      strokeId: stroke.id,
    );
    _queue.add(_OcrJob(entryId: entryId, stroke: stroke.copy()));
    unawaited(_drainQueue());
  }

  Future<void> _drainQueue() async {
    if (_processing) return;
    _processing = true;
    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      try {
        final text = await _recognizeStroke(job.stroke);
        if (text != null && text.trim().isNotEmpty) {
          await _db.updateInkIndexResult(
            id: job.entryId,
            text: text.trim(),
            status: InkIndexStatus.indexed,
          );
        } else {
          await _db.updateInkIndexResult(
            id: job.entryId,
            text: '',
            status: InkIndexStatus.failed,
          );
        }
      } catch (_) {
        await _db.updateInkIndexResult(
          id: job.entryId,
          text: '',
          status: InkIndexStatus.failed,
        );
      }
    }
    _processing = false;
  }

  Future<String?> _recognizeStroke(Stroke stroke) async {
    if (disableMlKit || !_mlKitAvailable) return null;
    final png = await _renderStrokePng(stroke);
    if (png == null) return null;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/penfold_ocr_${stroke.id}.png');
    await file.writeAsBytes(png.bytes, flush: true);

    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(file.path);
      final result = await _recognizer!.processImage(input);
      return result.text;
    } finally {
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  bool get _mlKitAvailable {
    if (disableMlKit) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  Future<_PngImage?> _renderStrokePng(Stroke stroke) async {
    final bounds = stroke.bounds.inflate(stroke.width * 2 + 20);
    if (bounds.width <= 0 || bounds.height <= 0) return null;

    const scale = 2.0;
    final w = (bounds.width * scale).ceil().clamp(32, 640);
    final h = (bounds.height * scale).ceil().clamp(32, 640);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      Paint()..color = Colors.white,
    );

    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = (stroke.width * scale).clamp(2.0, 12.0);

    final pts = stroke.points;
    for (var i = 1; i < pts.length; i++) {
      final a = Offset(
        (pts[i - 1].x - bounds.left) * scale,
        (pts[i - 1].y - bounds.top) * scale,
      );
      final b = Offset(
        (pts[i].x - bounds.left) * scale,
        (pts[i].y - bounds.top) * scale,
      );
      canvas.drawLine(a, b, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    return _PngImage(byteData.buffer.asUint8List(), w, h);
  }

  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}

class _OcrJob {
  final String entryId;
  final Stroke stroke;

  const _OcrJob({required this.entryId, required this.stroke});
}

class _PngImage {
  final Uint8List bytes;
  final int width;
  final int height;

  const _PngImage(this.bytes, this.width, this.height);
}
