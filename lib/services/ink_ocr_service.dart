import 'dart:async';
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart'
    as mlkit;
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../models/models.dart';
import 'hwr_convert.dart';
import 'ocr_dictionary.dart';

const _uuid = Uuid();

/// BCP-47 language tag for English handwriting (ML Kit base model).
const inkRecognitionLanguageModel = 'en-US';

/// Approximate on-device model size (Google ML Kit docs: ~20 MB per language).
const inkRecognitionModelSizeEstimateMb = 20;

/// Shown while the model downloads on first use (convert-to-text / background OCR).
const inkRecognitionModelDownloadHint =
    'First-time download (~$inkRecognitionModelSizeEstimateMb MB). '
    'Wi‑Fi recommended; may take several minutes on slow connections.';

/// Download / readiness state for the on-device handwriting model.
enum InkModelStatus {
  notReady,
  downloading,
  ready,
  error,
}

/// On-device handwriting OCR queue (ML Kit Digital Ink, no cloud accounts).
class InkOcrService {
  InkOcrService._();
  static final InkOcrService instance = InkOcrService._();

  final _db = AppDatabase.instance;
  final _queue = <_OcrJob>[];
  bool _processing = false;
  mlkit.DigitalInkRecognizer? _recognizer;
  final _modelManager = mlkit.DigitalInkRecognizerModelManager();

  InkModelStatus modelStatus = InkModelStatus.notReady;
  String? modelError;
  final modelStatusNotifier =
      ValueNotifier<InkModelStatus>(InkModelStatus.notReady);

  Future<bool>? _modelEnsureFuture;

  /// When true (unit tests), skips ML Kit and marks strokes failed quietly.
  static bool disableMlKit = false;

  /// When [disableMlKit] is true, selection OCR returns this (v0.2.37 tests).
  static String? testSelectionRecognitionResult;

  /// When [disableMlKit] is true, background stroke OCR returns this.
  static String? testStrokeRecognitionResult;

  Future<void> enqueueStroke(Stroke stroke) async {
    if (stroke.tool != ToolType.pen &&
        stroke.tool != ToolType.highlighter) {
      return;
    }
    if (stroke.points.length < minInkPointsForRecognition) return;

    final entryId = _uuid.v4();
    await _db.insertInkIndexPending(
      id: entryId,
      pageId: stroke.pageId,
      strokeId: stroke.id,
    );
    _queue.add(_OcrJob(entryId: entryId, stroke: stroke.copy()));
    unawaited(_drainQueue());
    unawaited(ensureModelReady());
  }

  /// Ensures the English handwriting model is downloaded and the recognizer is open.
  Future<bool> ensureModelReady() async {
    if (disableMlKit || !_mlKitAvailable) return false;
    if (modelStatus == InkModelStatus.ready) return true;

    _modelEnsureFuture ??= _ensureModelOnce();
    return _modelEnsureFuture!;
  }

  Future<bool> _ensureModelOnce() async {
    try {
      _setModelStatus(InkModelStatus.downloading);
      modelError = null;

      final alreadyDownloaded =
          await _modelManager.isModelDownloaded(inkRecognitionLanguageModel);
      if (!alreadyDownloaded) {
        final ok = await _modelManager.downloadModel(
          inkRecognitionLanguageModel,
          isWifiRequired: false,
        );
        if (!ok) {
          throw StateError('Handwriting model download failed');
        }
      }

      _recognizer ??=
          mlkit.DigitalInkRecognizer(languageCode: inkRecognitionLanguageModel);
      _setModelStatus(InkModelStatus.ready);
      return true;
    } on MissingPluginException catch (e) {
      modelError =
          'Digital Ink plugin missing (${e.message}). Rebuild the release APK.';
      _setModelStatus(InkModelStatus.error);
      _modelEnsureFuture = null;
      return false;
    } catch (e) {
      modelError = e.toString();
      _setModelStatus(InkModelStatus.error);
      _modelEnsureFuture = null;
      return false;
    }
  }

  void _setModelStatus(InkModelStatus status) {
    modelStatus = status;
    modelStatusNotifier.value = status;
  }

  Future<void> _drainQueue() async {
    if (_processing) return;
    _processing = true;
    while (_queue.isNotEmpty) {
      final job = _queue.removeAt(0);
      try {
        final text = await _recognizeStroke(job.stroke);
        if (text != null && text.trim().isNotEmpty) {
          final terms = await _db.allOcrTerms();
          final corrected = applyOcrDictionary(text.trim(), terms);
          await _db.updateInkIndexResult(
            id: job.entryId,
            text: corrected,
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

  /// OCR ink within [bounds] for lasso/selection convert-to-text (v0.2.37).
  Future<String?> recognizeSelection(
    List<Stroke> strokes,
    Rect bounds,
  ) async {
    final ink = strokes.where(isConvertibleInkStroke).toList();
    if (ink.isEmpty || bounds.width <= 0 || bounds.height <= 0) return null;
    if (!hasEnoughInkPoints(ink)) return null;

    String? text;
    if (disableMlKit || !_mlKitAvailable) {
      text = testSelectionRecognitionResult;
    } else {
      if (!await ensureModelReady()) return null;
      text = await _recognizeInk(ink, bounds);
    }

    if (text == null || text.trim().isEmpty) return null;
    final terms = await _db.allOcrTerms();
    return applyOcrDictionary(text.trim(), terms);
  }

  Future<String?> _recognizeStroke(Stroke stroke) async {
    if (disableMlKit || !_mlKitAvailable) {
      return testStrokeRecognitionResult;
    }
    if (!await ensureModelReady()) return null;
    return _recognizeInk([stroke], stroke.bounds);
  }

  Future<String?> _recognizeInk(List<Stroke> strokes, Rect bounds) async {
    final recognizer = _recognizer;
    if (recognizer == null) return null;

    final ink = strokesToMlKitInk(strokes);
    if (ink.strokes.isEmpty) return null;

    final context = mlkit.DigitalInkRecognitionContext(
      writingArea: mlkit.WritingArea(
        width: bounds.width.clamp(1.0, double.infinity),
        height: bounds.height.clamp(1.0, double.infinity),
      ),
    );

    final candidates = await recognizer.recognize(ink, context: context);
    if (candidates.isEmpty) return null;
    return candidates.first.text;
  }

  bool get _mlKitAvailable {
    if (disableMlKit) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
    _setModelStatus(InkModelStatus.notReady);
    _modelEnsureFuture = null;
  }
}

class _OcrJob {
  final String entryId;
  final Stroke stroke;

  const _OcrJob({required this.entryId, required this.stroke});
}
