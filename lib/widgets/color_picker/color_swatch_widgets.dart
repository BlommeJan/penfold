import 'package:flutter/material.dart';

import 'tool_color_presets.dart';

/// Circular color swatch with selection ring.
class ColorSwatchButton extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ColorSwatchButton({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final needsBorder = color.computeLuminance() > 0.85;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: selected ? 3 : 1,
            color: selected
                ? primary
                : needsBorder
                    ? Theme.of(context).colorScheme.outline
                    : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

/// "+" swatch that opens the custom color picker.
class AddColorSwatchButton extends StatelessWidget {
  final VoidCallback onTap;

  const AddColorSwatchButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline.withOpacity(0.5)),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 20,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Preset + custom swatches with optional custom-color "+" button.
class ColorSwatchRow extends StatelessWidget {
  final List<Color> presetColors;
  final List<Color> customColors;
  final Color activeColor;
  final ValueChanged<Color> onColorSelected;
  final Future<void> Function()? onAddCustomColor;

  const ColorSwatchRow({
    super.key,
    required this.presetColors,
    required this.customColors,
    required this.activeColor,
    required this.onColorSelected,
    this.onAddCustomColor,
  });

  @override
  Widget build(BuildContext context) {
    final allColors = [...presetColors, ...customColors];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in allColors)
          ColorSwatchButton(
            color: c,
            selected: colorsMatch(activeColor, c),
            onTap: () => onColorSelected(c),
          ),
        if (onAddCustomColor != null)
          AddColorSwatchButton(
            onTap: () => onAddCustomColor!(),
          ),
      ],
    );
  }
}
