import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'drawing_canvas.dart';
import 'pointer_routing.dart';

/// Gated pan/zoom wrapper. Stylus never moves the canvas; finger behavior
/// depends on [ToolState.stylusOnly] and whether the touch is on the paper.
class PageViewport extends StatefulWidget {
  final ToolState toolState;
  final Size paperSize;
  final Widget child;

  const PageViewport({
    super.key,
    required this.toolState,
    required this.paperSize,
    required this.child,
  });

  @override
  State<PageViewport> createState() => PageViewportState();
}

class PageViewportState extends State<PageViewport> {
  final TransformationController _transform = TransformationController();
  final Map<int, PointerDeviceKind> _activePointers = {};
  Offset? _lastFocal;
  double _gestureStartScale = 1;
  bool _gesturePanning = false;

  @override
  void initState() {
    super.initState();
    widget.toolState.addListener(_onToolStateChanged);
  }

  @override
  void dispose() {
    widget.toolState.removeListener(_onToolStateChanged);
    _transform.dispose();
    super.dispose();
  }

  void _onToolStateChanged() => setState(() {});

  void resetTransform() => _transform.value = Matrix4.identity();

  bool _isStylusKind(PointerDeviceKind k) =>
      k == PointerDeviceKind.stylus ||
      k == PointerDeviceKind.invertedStylus;

  bool _pointerOnPaper(Offset local) {
    final r = Offset.zero & widget.paperSize;
    return r.contains(local);
  }

  bool _mayPanZoom(PointerDeviceKind kind, Offset local) {
    return shouldAllowPanZoom(
      kind: kind,
      localPos: local,
      paperSize: widget.paperSize,
      stylusOnly: widget.toolState.stylusOnly,
    );
  }

  bool _scaleInvolvesStylus() =>
      _activePointers.values.any(_isStylusKind);

  void _onPointerDown(PointerDownEvent e) {
    _activePointers[e.pointer] = e.kind;
  }

  void _onPointerUp(PointerEvent e) {
    _activePointers.remove(e.pointer);
    if (_activePointers.isEmpty) {
      _gesturePanning = false;
      _lastFocal = null;
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (_scaleInvolvesStylus()) return;
    final kind = _dominantKind();
    if (!_mayPanZoom(kind, d.localFocalPoint)) return;
    _gesturePanning = true;
    _lastFocal = d.localFocalPoint;
    _gestureStartScale = _transform.value.getMaxScaleOnAxis();
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (!_gesturePanning || _scaleInvolvesStylus()) return;
    final kind = _dominantKind();
    if (!_mayPanZoom(kind, d.localFocalPoint)) return;

    final m = Matrix4.copy(_transform.value);
    if (d.scale != 1.0) {
      final newScale = (_gestureStartScale * d.scale).clamp(0.6, 10.0);
      final delta = newScale / m.getMaxScaleOnAxis();
      m.translate(d.localFocalPoint.dx, d.localFocalPoint.dy);
      m.scale(delta);
      m.translate(-d.localFocalPoint.dx, -d.localFocalPoint.dy);
    }
    if (_lastFocal != null) {
      final pan = d.localFocalPoint - _lastFocal!;
      m.translate(pan.dx, pan.dy);
    }
    _lastFocal = d.localFocalPoint;
    _transform.value = m;
  }

  void _onScaleEnd(ScaleEndDetails d) {
    _gesturePanning = false;
    _lastFocal = null;
  }

  PointerDeviceKind _dominantKind() {
    if (_activePointers.isEmpty) return PointerDeviceKind.touch;
    return _activePointers.values.first;
  }

  @override
  Widget build(BuildContext context) {
    final viewer = InteractiveViewer(
      transformationController: _transform,
      panEnabled: false,
      scaleEnabled: false,
      minScale: 0.6,
      maxScale: 10,
      child: widget.child,
    );

    // Finger on paper draws; scale/pan here would only compete with ink.
    if (!widget.toolState.stylusOnly) {
      return viewer;
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
        child: viewer,
      ),
    );
  }
}
