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
  Matrix4 _gestureStartMatrix = Matrix4.identity();
  bool _gestureActive = false;
  bool _pinchScrollLockHeld = false;

  @override
  void initState() {
    super.initState();
    widget.toolState.addListener(_onToolStateChanged);
  }

  @override
  void didUpdateWidget(covariant PageViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paperSize != widget.paperSize) {
      resetTransform();
    }
    if (oldWidget.zoomEnabled && !widget.zoomEnabled) {
      resetTransform();
      _releasePinchScrollLock();
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
    _releasePinchScrollLock();
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

  /// Pan/zoom gestures run outside the [Transform], so focal points are in
  /// viewport space and must be mapped into paper space for routing.
  Matrix4 get _contentTransform => _transform.value;

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
      contentTransform: _contentTransform,
    );
  }


  void _onPointerDown(PointerDownEvent e) {
    _activePointers[e.pointer] = e.kind;
    // Lock ancestor scroll as soon as a second finger lands so pinch wins
    // over CustomScrollView / PageView before ScaleStart fires.
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
    _gestureStartMatrix = Matrix4.copy(_transform.value);
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

    final focal = d.localFocalPoint;

    if (d.pointerCount >= 2) {
      _holdPinchScrollLock();
      if ((d.scale - 1.0).abs() > 0.001) {
        final newScale = (_gestureStartScale * d.scale).clamp(0.5, 8.0);
        final m = Matrix4.copy(_gestureStartMatrix);
        m.translate(focal.dx, focal.dy);
        m.scale(newScale / _gestureStartScale);
        m.translate(-focal.dx, -focal.dy);
        _transform.value = m;
      }
    } else if (_lastFocal != null) {
      final pan = focal - _lastFocal!;
      final m = Matrix4.copy(_transform.value);
      m.translate(pan.dx, pan.dy);
      _transform.value = m;
    }

    _lastFocal = focal;
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_gestureActive && !_pinchScrollLockHeld) {
      widget.onTransformGestureActive?.call(false);
    }
    _gestureActive = false;
    _lastFocal = null;
    if (_touchPointerCount() < 2) {
      _releasePinchScrollLock();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Per-page scale is disabled; document-level DocumentViewport owns pinch.
    // A nested GestureDetector here would win the arena on paper and block
    // document pinch when fingers are on the page.
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
