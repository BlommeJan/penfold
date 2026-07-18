import 'package:flutter/material.dart';

/// Choice chip with explicit theme colors and a brightness [Key] so chips
/// repaint and stay tappable after light/dark theme switches.
class ThemedChoiceChip extends StatelessWidget {
  const ThemedChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ChoiceChip(
      key: ValueKey('themed-chip-$label-$selected-${theme.brightness}'),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: scheme.primaryContainer,
      backgroundColor: scheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outline.withOpacity(0.35),
      ),
    );
  }
}
