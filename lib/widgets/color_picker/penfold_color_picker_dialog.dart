import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/l10n.dart';

enum _ColorPickerMode { hsv, rgb, hex }

/// Rich color picker dialog with HSV wheel, RGB sliders, and hex input tabs.
class PenfoldColorPickerDialog extends StatefulWidget {
  final Color initial;

  const PenfoldColorPickerDialog({super.key, required this.initial});

  @override
  State<PenfoldColorPickerDialog> createState() =>
      _PenfoldColorPickerDialogState();
}

class _PenfoldColorPickerDialogState extends State<PenfoldColorPickerDialog> {
  late HSVColor _hsv;
  late TextEditingController _hexController;
  _ColorPickerMode _mode = _ColorPickerMode.hsv;
  bool _hexValid = true;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
    _hexController = TextEditingController(text: _formatHex(_color));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _color => _hsv.toColor();

  String _formatHex(Color color) {
    final rgb = color.value & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _applyHsv(HSVColor hsv) {
    setState(() {
      _hsv = hsv;
      _hexValid = true;
      _hexController.text = _formatHex(_color);
      _hexController.selection = TextSelection.collapsed(
        offset: _hexController.text.length,
      );
    });
  }

  void _applyColor(Color color) {
    _applyHsv(HSVColor.fromColor(color));
  }

  void _onHexSubmitted(String value) {
    final parsed = _parseHex(value);
    setState(() {
      _hexValid = parsed != null;
      if (parsed != null) {
        _hsv = HSVColor.fromColor(parsed);
        _hexController.text = _formatHex(parsed);
      }
    });
  }

  Color? _parseHex(String raw) {
    var text = raw.trim();
    if (text.startsWith('#')) text = text.substring(1);
    if (text.length != 6) return null;
    final value = int.tryParse(text, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.customColorTitle),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<_ColorPickerMode>(
              segments: [
                ButtonSegment(
                  value: _ColorPickerMode.hsv,
                  label: Text(l10n.colorPickerModeHsv),
                ),
                ButtonSegment(
                  value: _ColorPickerMode.rgb,
                  label: Text(l10n.colorPickerModeRgb),
                ),
                ButtonSegment(
                  value: _ColorPickerMode.hex,
                  label: Text(l10n.colorPickerModeHex),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
              },
            ),
            const SizedBox(height: 16),
            switch (_mode) {
              _ColorPickerMode.hsv => _HsvPicker(
                  hsv: _hsv,
                  onChanged: _applyHsv,
                  hueLabel: l10n.hueLabel,
                  saturationLabel: l10n.saturationLabel,
                  brightnessLabel: l10n.brightnessLabel,
                ),
              _ColorPickerMode.rgb => _RgbPicker(
                  color: _color,
                  onChanged: _applyColor,
                  redLabel: l10n.redLabel,
                  greenLabel: l10n.greenLabel,
                  blueLabel: l10n.blueLabel,
                ),
              _ColorPickerMode.hex => _HexPicker(
                  controller: _hexController,
                  isValid: _hexValid,
                  onSubmitted: _onHexSubmitted,
                  hexLabel: l10n.hexLabel,
                  hexHint: l10n.hexHint,
                ),
            },
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _hexValid ? () => Navigator.pop(context, _color) : null,
          child: Text(l10n.actionUseColor),
        ),
      ],
    );
  }
}

class _HsvPicker extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> onChanged;
  final String hueLabel;
  final String saturationLabel;
  final String brightnessLabel;

  const _HsvPicker({
    required this.hsv,
    required this.onChanged,
    required this.hueLabel,
    required this.saturationLabel,
    required this.brightnessLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HueWheel(
          hue: hsv.hue,
          onChanged: (hue) => onChanged(hsv.withHue(hue)),
        ),
        const SizedBox(height: 12),
        _SaturationValueSquare(
          hue: hsv.hue,
          saturation: hsv.saturation,
          value: hsv.value,
          onChanged: (s, v) => onChanged(hsv.withSaturation(s).withValue(v)),
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: hueLabel,
          value: hsv.hue,
          max: 360,
          onChanged: (v) => onChanged(hsv.withHue(v)),
        ),
        _SliderRow(
          label: saturationLabel,
          value: hsv.saturation,
          max: 1,
          onChanged: (v) => onChanged(hsv.withSaturation(v)),
        ),
        _SliderRow(
          label: brightnessLabel,
          value: hsv.value,
          max: 1,
          onChanged: (v) => onChanged(hsv.withValue(v)),
        ),
      ],
    );
  }
}

class _HueWheel extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HueWheel({required this.hue, required this.onChanged});

  static const _size = 160.0;
  static const _stroke = 22.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: GestureDetector(
        onPanDown: (d) => _updateHue(d.localPosition),
        onPanUpdate: (d) => _updateHue(d.localPosition),
        child: CustomPaint(
          painter: _HueWheelPainter(
            hue: hue,
            strokeWidth: _stroke,
          ),
          size: const Size(_size, _size),
        ),
      ),
    );
  }

  void _updateHue(Offset local) {
    final center = Offset(_size / 2, _size / 2);
    final delta = local - center;
    final angle = math.atan2(delta.dy, delta.dx);
    final degrees = (angle * 180 / math.pi + 360) % 360;
    onChanged(degrees);
  }
}

class _HueWheelPainter extends CustomPainter {
  final double hue;
  final double strokeWidth;

  _HueWheelPainter({required this.hue, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const colors = [
      Color(0xFFFF0000),
      Color(0xFFFFFF00),
      Color(0xFF00FF00),
      Color(0xFF00FFFF),
      Color(0xFF0000FF),
      Color(0xFFFF00FF),
      Color(0xFFFF0000),
    ];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(colors: colors).createShader(rect);
    canvas.drawCircle(center, radius, paint);

    final radians = hue * math.pi / 180;
    final thumb = center +
        Offset(math.cos(radians), math.sin(radians)) * radius;
    canvas.drawCircle(
      thumb,
      strokeWidth * 0.38,
      Paint()
        ..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor()
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      thumb,
      strokeWidth * 0.38,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _HueWheelPainter oldDelegate) =>
      oldDelegate.hue != hue || oldDelegate.strokeWidth != strokeWidth;
}

class _SaturationValueSquare extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final void Function(double saturation, double value) onChanged;

  const _SaturationValueSquare({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  static const _size = 160.0;

  @override
  Widget build(BuildContext context) {
    final base = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _size,
        height: _size,
        child: GestureDetector(
          onPanDown: (d) => _update(d.localPosition),
          onPanUpdate: (d) => _update(d.localPosition),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: base),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.transparent],
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black],
                  ),
                ),
              ),
              CustomPaint(
                painter: _SaturationValueThumbPainter(
                  saturation: saturation,
                  value: value,
                  color: HSVColor.fromAHSV(1, hue, saturation, value).toColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _update(Offset local) {
    final s = (local.dx / _size).clamp(0.0, 1.0);
    final v = (1 - local.dy / _size).clamp(0.0, 1.0);
    onChanged(s, v);
  }
}

class _SaturationValueThumbPainter extends CustomPainter {
  final double saturation;
  final double value;
  final Color color;

  _SaturationValueThumbPainter({
    required this.saturation,
    required this.value,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final x = saturation * size.width;
    final y = (1 - value) * size.height;
    canvas.drawCircle(
      Offset(x, y),
      8,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(x, y),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValueThumbPainter oldDelegate) =>
      oldDelegate.saturation != saturation ||
      oldDelegate.value != value ||
      oldDelegate.color != color;
}

class _RgbPicker extends StatelessWidget {
  final Color color;
  final ValueChanged<Color> onChanged;
  final String redLabel;
  final String greenLabel;
  final String blueLabel;

  const _RgbPicker({
    required this.color,
    required this.onChanged,
    required this.redLabel,
    required this.greenLabel,
    required this.blueLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SliderRow(
          label: redLabel,
          value: color.red.toDouble(),
          max: 255,
          activeColor: Colors.red,
          onChanged: (v) => onChanged(Color.fromARGB(
            255,
            v.round(),
            color.green,
            color.blue,
          )),
        ),
        _SliderRow(
          label: greenLabel,
          value: color.green.toDouble(),
          max: 255,
          activeColor: Colors.green,
          onChanged: (v) => onChanged(Color.fromARGB(
            255,
            color.red,
            v.round(),
            color.blue,
          )),
        ),
        _SliderRow(
          label: blueLabel,
          value: color.blue.toDouble(),
          max: 255,
          activeColor: Colors.blue,
          onChanged: (v) => onChanged(Color.fromARGB(
            255,
            color.red,
            color.green,
            v.round(),
          )),
        ),
      ],
    );
  }
}

class _HexPicker extends StatelessWidget {
  final TextEditingController controller;
  final bool isValid;
  final ValueChanged<String> onSubmitted;
  final String hexLabel;
  final String hexHint;

  const _HexPicker({
    required this.controller,
    required this.isValid,
    required this.onSubmitted,
    required this.hexLabel,
    required this.hexHint,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hexLabel,
        hintText: hexHint,
        errorText: isValid ? null : hexHint,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.tag_rounded),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'monospace',
            letterSpacing: 1.2,
          ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[#0-9A-Fa-f]')),
        LengthLimitingTextInputFormatter(7),
      ],
      textCapitalization: TextCapitalization.characters,
      onChanged: onSubmitted,
      onSubmitted: onSubmitted,
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;
  final Color? activeColor;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(0, max),
            min: 0,
            max: max,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// Shows [PenfoldColorPickerDialog] and returns the picked color, or null.
Future<Color?> showPenfoldColorPicker(
  BuildContext context, {
  required Color initial,
}) {
  return showDialog<Color>(
    context: context,
    builder: (ctx) => PenfoldColorPickerDialog(initial: initial),
  );
}
