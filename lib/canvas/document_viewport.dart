import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'document_transform.dart';
import 'drawing_canvas.dart';
import 'pointer_routing.dart';

/// Document-level pan/zoom: one transform for the whole notebook scroll/page view.
///
/// Gestures run outside the [Transform], so [isFocalOnPaper] receives viewport-local
/// focal points (same space as scale gesture details).
class DocumentViewport extends StatefulWidget {
  final ToolState toolState;
  final Widget child;
  final Size viewportSize;
  final Rect contentBounds;
  final bool zoomEnabled;
  final bool Function(Offset viewportFocal) isFocalOnPaper;
  final ValueChanged<bool>? onTransformGestureActive;

  const DocumentViewport({
    super.key,
    required this.toolState,
    required this.child,
    required this.viewportSize,
    required this.contentBounds,
    required this.isFocalOnPaper,
    this.zoomEnabled = true,
    this.onTransformGestureActive,
  });

  @override
  State<DocumentViewport> createState() => DocumentViewportState();
}

class DocumentViewportState extends State<DocumentViewport> {
  final TransformationController _transform = TransformationController();
  final Map<int, PointerDeviceKind> _activePointers = {};
  Offset? _lastFocal;
  Offset? _gestureStartFocal;
  double _gestureStartScale = 1;
  Matrix4 _gestureStartMatrix = Matrix4.identity();
  bool _gestureActive = false;
  bool _pinchScrollLockHeld = false;

  Matrix4 get transform => _transform.value;

  double get _currentScale => documentScale(_transform.value);

  @override
  void initState() {
    super.initState();
    widget.toolState.addListener(_onToolStateChanged);
  }

  @override
  void didUpdateWidget(covariant DocumentViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoomEnabled && !widget.zoomEnabled) {
      resetTransform();
      _releasePinchScrollLock();
      if (_gestureActive) {
        widget.onTransformGestureActive?.call(false);
      }
      _gestureActive = false;
      _lastFocal = null;
      _gestureStartFocal = null;
    } else if (widget.zoomEnabled &&
        (oldWidget.viewportSize != widget.viewportSize ||
            oldWidget.contentBounds != widget.contentBounds)) {
      _applyClampedTransform(_transform.value);
    }
  }

  @override
  void dispose() {
    widget.toolState.removeListener(_onToolStateChanged);
    _transform.dispose();
    super.dispose();
  }

  void _onToolStateChanged() => setState(() {});

  void resetTransform() => _transform.value = Matrix4.identity();

  void resetPointerTracking() {
    _activePointers.clear();
    if (_gestureActive) {
      widget.onTransformGestureActive?.call(false);
    }
    _releasePinchScrollLock();
    _gestureActive = false;
    _lastFocal = null;
    _gestureStartFocal = null;
  }

  void _applyClampedTransform(Matrix4 matrix) {
    _transform.value = clampDocumentTransform(
      matrix: normalizeDocumentTransform(matrix),
      viewportSize: widget.viewportSize,
      contentBounds: widget.contentBounds,
    );
  }

  bool _isStylusKind(PointerDeviceKind k) =>
      k == PointerDeviceKind.stylus ||
      k == PointerDeviceKind.invertedStylus;

  int _touchPointerCount() =>
      _activePointers.values.where((k) => !_isStylusKind(k)).length;

  bool _hasStylusPointer() =>
      _activePointers.values.any(_isStylusKind);

  PointerDeviceKind _dominantTouchKind() {
    for (final kind in _activePointers.values) {
      if (!_isStylusKind(kind)) return kind;
    }
    return PointerDeviceKind.touch;
  }

  bool _allowsGesture({required Offset focal, required int pointerCount}) {
    if (!widget.zoomEnabled) return false;

    // Two-finger pinch always zooms, including on paper in finger-drawing mode.
    if (pointerCount >= 2) return true;

    final touches = _touchPointerCount();
    final effectiveTouches = pointerCount > touches ? pointerCount : touches;
    final kind = _dominantTouchKind();

    if (shouldAllowPinchZoom(
      touchPointerCount: effectiveTouches,
      kind: kind,
    )) {
      return true;
    }

    if (_hasStylusPointer()) return false;

    if (widget.toolState.stylusOnly) {
      return kind == PointerDeviceKind.touch ||
          kind == PointerDeviceKind.trackpad ||
          kind == PointerDeviceKind.mouse;
    }
    if (kind == PointerDeviceKind.mouse) return true;

    // At ~1× vertical scroll owns navigation; single-finger pan only on margins.
    if (_currentScale <= kDocumentZoomedPanThreshold) {
      return !widget.isFocalOnPaper(focal);
    }

    // Zoomed in: two-finger pan works everywhere; single-finger stays margin-only
    // so finger-drawing on paper is preserved.
    return !widget.isFocalOnPaper(focal);
  }

  void _onPointerDown(PointerDownEvent e) {
    _activePointers[e.pointer] = e.kind;
    if (widget.zoomEnabled &&
        _touchPointerCount() >= 2 &&
        shouldAllowPinchZoom(
          touchPointerCount: _touchPointerCount(),
          kind: _dominantTouchKind(),
        )) {
      _holdPinchScrollLock();
    }
  }

  void _onPointerUp(PointerEvent e) {
    _activePointers.remove(e.pointer);
    if (_activePointers.isEmpty) {
      if (_gestureActive) {
        widget.onTransformGestureActive?.call(false);
      }
      _releasePinchScrollLock();
      _gestureActive = false;
      _lastFocal = null;
      _gestureStartFocal = null;
    } else if (_touchPointerCount() < 2) {
      _releasePinchScrollLock();
    }
  }

  void _holdPinchScrollLock() {
    if (_pinchScrollLockHeld) return;
    _pinchScrollLockHeld = true;
    widget.onTransformGestureActive?.call(true);
  }

  void _releasePinchScrollLock() {
    if (!_pinchScrollLockHeld) return;
    _pinchScrollLockHeld = false;
    widget.onTransformGestureActive?.call(false);
  }

  void _beginGesture(Offset focal) {
    if (!_gestureActive && !_pinchScrollLockHeld) {
      widget.onTransformGestureActive?.call(true);
    }
    _gestureActive = true;
    _lastFocal = focal;
    _gestureStartFocal = focal;
    _gestureStartMatrix = Matrix4.copy(_transform.value);
    _gestureStartScale = _currentScale;
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (!_allowsGesture(focal: d.localFocalPoint, pointerCount: d.pointerCount)) {
      return;
    }
    _beginGesture(d.localFocalPoint);
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (!_gestureActive) {
      if (!_allowsGesture(
        focal: d.localFocalPoint,
        pointerCount: d.pointerCount,
      )) {
        return;
      }
      _beginGesture(d.localFocalPoint);
    }

    if (!_gestureActive) return;
    if (!_allowsGesture(
      focal: d.localFocalPoint,
      pointerCount: d.pointerCount,
    )) {
      return;
    }

    final focal = d.localFocalPoint;
    final startFocal = _gestureStartFocal ?? focal;

    if (d.pointerCount >= 2) {
      _holdPinchScrollLock();
      _applyClampedTransform(
        documentPinchFromStart(
          gestureStartMatrix: _gestureStartMatrix,
          gestureStartFocal: startFocal,
          currentFocal: focal,
          gestureStartScale: _gestureStartScale,
          cumulativeScale: d.scale,
        ),
      );
    } else if (_lastFocal != null) {
      _applyClampedTransform(
        documentPan(_transform.value, focal - _lastFocal!),
      );
    }

    _lastFocal = focal;
  }

  void _onScaleEnd(ScaleEndDetails d) {
    // Snap to 1× when the pinch landed near identity so scroll resumes cleanly.
    if (_currentScale >= kDocumentFitCenterScaleMax &&
        _currentScale <= kDocumentSnapScaleMax) {
      resetTransform();
    } else {
      _applyClampedTransform(_transform.value);
    }

    if (_gestureActive && !_pinchScrollLockHeld) {
      widget.onTransformGestureActive?.call(false);
    }
    _gestureActive = false;
    _lastFocal = null;
    _gestureStartFocal = null;
    if (_touchPointerCount() < 2) {
      _releasePinchScrollLock();
    }
  }

  void _onDoubleTap() => resetTransform();

  @override
  Widget build(BuildContext context) {
    if (!widget.zoomEnabled) {
      return widget.child;
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        onDoubleTap: _onDoubleTap,
        child: AnimatedBuilder(
          animation: _transform,
          builder: (context, child) => Transform(
            transform: _transform.value,
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
