import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'drawing_canvas.dart';
import 'pointer_routing.dart';

/// Gated pan/zoom wrapper. Stylus draws; fingers pan/zoom per [ToolState].
///
/// Two-finger pinch always zooms (paper, margin, stylus-only, stylus drawing).
class PageViewport extends StatefulWidget {
  final ToolState toolState;
  final Size paperSize;
  final Widget child;
  final bool zoomEnabled;
  final ValueChanged<bool>? onTransformGestureActive;

  const PageViewport({
    super.key,
    required this.toolState,
    required this.paperSize,
    required this.child,
    this.zoomEnabled = true,
    this.onTransformGestureActive,
  });

  @override
  State<PageViewport> createState() => PageViewportState();
}

class PageViewportState extends State<PageViewport> {
  final TransformationController _transform = TransformationController();
  final Map<int, PointerDeviceKind> _activePointers = {};
  Offset? _lastFocal;
  double _gestureStartScale = 1;
  bool _gestureActive = false;

  @override
  void initState() {
    super.initState();
    widget.toolState.addListener(_onToolStateChanged);
  }

  @override
  void didUpdateWidget(covariant PageViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zoomEnabled && !widget.zoomEnabled) {
      resetTransform();
      if (_gestureActive) {
        widget.onTransformGestureActive?.call(false);
      }
      _gestureActive = false;
      _lastFocal = null;
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

  /// Clears tracked pointers and ends any in-flight pan/zoom gesture.
  void resetPointerTracking() {
    _activePointers.clear();
    if (_gestureActive) {
      widget.onTransformGestureActive?.call(false);
    }
    _gestureActive = false;
    _lastFocal = null;
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

    final touches = _touchPointerCount();
    final effectiveTouches = pointerCount > touches ? pointerCount : touches;
    final kind = _dominantTouchKind();

    if (shouldAllowPinchZoom(
      touchPointerCount: effectiveTouches,
      kind: kind,
    )) {
      return true;
    }

    // Single-finger pan: never while stylus is down (stylus is drawing).
    if (_hasStylusPointer()) return false;

    return shouldAllowPanZoom(
      kind: kind,
      localPos: focal,
      paperSize: widget.paperSize,
      stylusOnly: widget.toolState.stylusOnly,
      touchPointerCount: effectiveTouches,
    );
  }

  void _onPointerDown(PointerDownEvent e) {
    _activePointers[e.pointer] = e.kind;
  }

  void _onPointerUp(PointerEvent e) {
    _activePointers.remove(e.pointer);
    if (_activePointers.isEmpty) {
      if (_gestureActive) {
        widget.onTransformGestureActive?.call(false);
      }
      _gestureActive = false;
      _lastFocal = null;
    }
  }

  void _beginGesture(Offset focal) {
    if (!_gestureActive) {
      widget.onTransformGestureActive?.call(true);
    }
    _gestureActive = true;
    _lastFocal = focal;
    _gestureStartScale = _transform.value.getMaxScaleOnAxis();
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

    final m = Matrix4.copy(_transform.value);

    if (d.pointerCount >= 2 && (d.scale - 1.0).abs() > 0.001) {
      final newScale = (_gestureStartScale * d.scale).clamp(0.6, 10.0);
      final delta = newScale / m.getMaxScaleOnAxis();
      m.translate(d.localFocalPoint.dx, d.localFocalPoint.dy);
      m.scale(delta);
      m.translate(-d.localFocalPoint.dx, -d.localFocalPoint.dy);
    }

    if (d.pointerCount == 1 && _lastFocal != null) {
      final pan = d.localFocalPoint - _lastFocal!;
      m.translate(pan.dx, pan.dy);
    }

    _lastFocal = d.localFocalPoint;
    _transform.value = m;
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_gestureActive) {
      widget.onTransformGestureActive?.call(false);
    }
    _gestureActive = false;
    _lastFocal = null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
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
