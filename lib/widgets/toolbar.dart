import 'package:flutter/material.dart';

import '../canvas/drawing_canvas.dart';
import '../models/models.dart';
import '../services/stroke_eraser.dart';
import '../services/toolbar_order_service.dart';

const _kToolbarIconSize = 22.0;
const _kToolButtonRadius = 12.0;

const _penColors = [
  Color(0xFF1A1A1A),
  Color(0xFF2455C3),
  Color(0xFFC0392B),
  Color(0xFF1E8449),
  Color(0xFF7D3C98),
  Color(0xFFE67E22),
  Color(0xFF16A085),
  Color(0xFF2C3E50),
  Color(0xFF95A5A6),
  Color(0xFFE91E63),
  Color(0xFF795548),
  Color(0xFFFFFFFF),
];

const _highlighterColors = [
  Color(0xFFFFE100),
  Color(0xFF7CF77C),
  Color(0xFF7CD6F7),
  Color(0xFFF77CE0),
  Color(0xFFFFA94D),
  Color(0xFFFF6B6B),
  Color(0xFFB388FF),
  Color(0xFF80DEEA),
  Color(0xFFFFF59D),
  Color(0xFFA5D6A7),
];

/// Brush styles shown in the pen options popup (marker is a style, not a tool).
const _penBrushStyles = [
  BrushStyle.pen,
  BrushStyle.fountainPen,
  BrushStyle.pencil,
  BrushStyle.marker,
  BrushStyle.calligraphy,
];

const _tapeColors = [
  Color(0xFFE8E0D0),
  Color(0xFFD4C4A8),
  Color(0xFFC8D8E8),
  Color(0xFFE8C8D0),
  Color(0xFFD0E0C8),
];

const _fillColors = [
  Color(0xFF2455C3),
  Color(0xFFFFE100),
  Color(0xFF7CF77C),
  Color(0xFFF77CE0),
  Color(0xFFFFA94D),
];

/// Top editing toolbar: back (left), drawing tools (center), actions (right).
class EditorToolbar extends StatelessWidget implements PreferredSizeWidget {
  final ToolState toolState;
  final bool canUndo;
  final bool canRedo;
  final bool hasSelection;
  final bool canPaste;
  final bool canConvertSelectionToText;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onDeleteSelection;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback? onConvertToText;
  final VoidCallback onAddPage;
  final VoidCallback onPageSettings;
  final VoidCallback onAddImage;
  final VoidCallback? onPageOverview;
  final VoidCallback? onContents;
  final bool canPrevBookmark;
  final bool canNextBookmark;
  final VoidCallback? onPrevBookmark;
  final VoidCallback? onNextBookmark;
  final VoidCallback? onBack;

  const EditorToolbar({
    super.key,
    required this.toolState,
    required this.canUndo,
    required this.canRedo,
    required this.hasSelection,
    this.canPaste = false,
    this.canConvertSelectionToText = false,
    required this.onUndo,
    required this.onRedo,
    required this.onDeleteSelection,
    this.onCopy,
    this.onPaste,
    this.onConvertToText,
    required this.onAddPage,
    required this.onPageSettings,
    required this.onAddImage,
    this.onPageOverview,
    this.onContents,
    this.canPrevBookmark = false,
    this.canNextBookmark = false,
    this.onPrevBookmark,
    this.onNextBookmark,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([toolState, ToolbarOrderService.instance]),
      builder: (context, _) {
        final t = toolState;
        final scheme = Theme.of(context).colorScheme;
        final penFamily = t.tool == ToolType.pen ||
            t.tool == ToolType.shape ||
            t.tool == ToolType.fill;
        final centerTools = _buildCenterTools(context, t, penFamily);
        return Material(
          color: Colors.white,
          elevation: 0.5,
          shadowColor: scheme.primary.withOpacity(0.08),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  // Left: navigation only (GoodNotes pattern — no undo here).
                  onBack != null
                      ? BackButton(onPressed: onBack)
                      : const BackButton(),
                  _ActionIconButton(
                    tooltip: 'Previous bookmark',
                    icon: Icons.expand_less_rounded,
                    onPressed: canPrevBookmark ? onPrevBookmark : null,
                  ),
                  _ActionIconButton(
                    tooltip: 'Next bookmark',
                    icon: Icons.expand_more_rounded,
                    onPressed: canNextBookmark ? onNextBookmark : null,
                  ),
                  const _ToolbarDivider(),
                  // Center: drawing tools, centered in remaining space.
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...centerTools,
                            if (hasSelection || canPaste) ...[
                              const _ToolbarDivider(),
                              if (hasSelection) ...[
                                if (canConvertSelectionToText)
                                  _ActionIconButton(
                                    tooltip: 'Convert to text',
                                    icon: Icons.text_fields_rounded,
                                    onPressed: onConvertToText,
                                  ),
                                _ActionIconButton(
                                  tooltip: 'Copy',
                                  icon: Icons.copy_rounded,
                                  onPressed: onCopy,
                                ),
                                _ActionIconButton(
                                  tooltip: 'Delete',
                                  icon: Icons.delete_outline_rounded,
                                  onPressed: onDeleteSelection,
                                ),
                              ],
                              if (canPaste)
                                _ActionIconButton(
                                  tooltip: 'Paste',
                                  icon: Icons.content_paste_rounded,
                                  onPressed: onPaste,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const _ToolbarDivider(),
                  // Right: history + page actions (undo lives here, not by back).
                  _ActionIconButton(
                    tooltip: 'Undo',
                    icon: Icons.undo_rounded,
                    onPressed: canUndo ? onUndo : null,
                  ),
                  _ActionIconButton(
                    tooltip: 'Redo',
                    icon: Icons.redo_rounded,
                    onPressed: canRedo ? onRedo : null,
                  ),
                  const _ToolbarDivider(),
                  _ActionIconButton(
                    tooltip: 'Add page',
                    icon: Icons.note_add_outlined,
                    onPressed: onAddPage,
                  ),
                  _ActionIconButton(
                    tooltip: t.stylusOnly
                        ? 'Stylus-only (palm rejection)'
                        : 'Finger drawing',
                    icon: t.stylusOnly
                        ? Icons.do_not_touch_rounded
                        : Icons.touch_app_rounded,
                    onPressed: () =>
                        t.set((s) => s.stylusOnly = !s.stylusOnly),
                    active: t.stylusOnly,
                  ),
                  if (onPageOverview != null)
                    _ActionIconButton(
                      tooltip: 'Page overview',
                      icon: Icons.dashboard_rounded,
                      onPressed: onPageOverview,
                    ),
                  if (onContents != null)
                    _ActionIconButton(
                      tooltip: 'Table of contents',
                      icon: Icons.list_alt_rounded,
                      onPressed: onContents,
                    ),
                  _ActionIconButton(
                    tooltip: 'Page settings',
                    icon: Icons.settings_rounded,
                    onPressed: onPageSettings,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCenterTools(
    BuildContext context,
    ToolState t,
    bool penFamily,
  ) {
    final order = ToolbarOrderService.instance.order;
    final widgets = <Widget>[];

    for (var i = 0; i < order.length; i++) {
      final id = order[i];
      final prevId = i > 0 ? order[i - 1] : null;
      if (prevId == ToolbarToolId.eraser &&
          id != ToolbarToolId.pen &&
          id != ToolbarToolId.highlighter &&
          id != ToolbarToolId.tape &&
          id != ToolbarToolId.eraser) {
        widgets.add(const _ToolbarDivider());
      }

      switch (id) {
        case ToolbarToolId.pen:
          widgets.add(
            _ToolButton(
              icon: Icons.edit_rounded,
              selected: penFamily && t.tool != ToolType.fill,
              tooltip: 'Pen',
              onTap: () => t.set((s) => s.tool = ToolType.pen),
              onTapWhenSelected: () =>
                  _showPenOptions(context, t, highlighter: false),
              accent: penFamily && t.tool != ToolType.fill ? t.penColor : null,
            ),
          );
        case ToolbarToolId.highlighter:
          widgets.add(
            _ToolButton(
              icon: Icons.brush_rounded,
              selected: t.tool == ToolType.highlighter,
              tooltip: 'Highlighter',
              onTap: () => t.set((s) => s.tool = ToolType.highlighter),
              onTapWhenSelected: () =>
                  _showPenOptions(context, t, highlighter: true),
              accent:
                  t.tool == ToolType.highlighter ? t.highlighterColor : null,
            ),
          );
        case ToolbarToolId.tape:
          widgets.add(
            _ToolButton(
              icon: Icons.visibility_off_outlined,
              selected: t.tool == ToolType.tape,
              tooltip: 'Tape',
              onTap: () => t.set((s) => s.tool = ToolType.tape),
              onTapWhenSelected: () => _showTapeOptions(context, t),
              accent: t.tool == ToolType.tape ? t.tapeColor : null,
            ),
          );
        case ToolbarToolId.eraser:
          widgets.add(
            _ToolButton(
              icon: Icons.cleaning_services_rounded,
              selected: t.tool == ToolType.eraser,
              tooltip: 'Eraser',
              onTap: () => t.set((s) => s.tool = ToolType.eraser),
              onTapWhenSelected: () => _showEraserOptions(context, t),
            ),
          );
        case ToolbarToolId.selection:
          widgets.add(
            _ToolButton(
              icon: Icons.near_me_rounded,
              selected: t.tool == ToolType.selection,
              tooltip: 'Selection',
              onTap: () => t.set((s) => s.tool = ToolType.selection),
            ),
          );
        case ToolbarToolId.lasso:
          widgets.add(
            _ToolButton(
              icon: Icons.gesture_rounded,
              selected: t.tool == ToolType.lasso,
              tooltip: 'Lasso',
              onTap: () => t.set((s) => s.tool = ToolType.lasso),
            ),
          );
        case ToolbarToolId.shape:
          widgets.add(
            _ToolButton(
              icon: Icons.interests_rounded,
              selected: t.tool == ToolType.shape,
              tooltip: 'Shape',
              onTap: () => t.set((s) => s.tool = ToolType.shape),
              onTapWhenSelected: () =>
                  _showPenOptions(context, t, highlighter: false),
            ),
          );
        case ToolbarToolId.fill:
          widgets.add(
            _ToolButton(
              icon: Icons.format_color_fill_rounded,
              selected: t.tool == ToolType.fill,
              tooltip: 'Fill',
              onTap: () => t.set((s) => s.tool = ToolType.fill),
              onTapWhenSelected: () => _showFillOptions(context, t),
              accent: t.tool == ToolType.fill ? t.fillColor : null,
            ),
          );
        case ToolbarToolId.text:
          widgets.add(
            _ToolButton(
              icon: Icons.text_fields_rounded,
              selected: t.tool == ToolType.text,
              tooltip: 'Text',
              onTap: () => t.set((s) => s.tool = ToolType.text),
            ),
          );
        case ToolbarToolId.insertImage:
          widgets.add(
            _ToolButton(
              icon: Icons.image_outlined,
              selected: false,
              tooltip: 'Insert image',
              onTap: onAddImage,
            ),
          );
        default:
          final neverId = id;
          assert(false, 'Unknown toolbar tool id: $neverId');
      }
    }

    return widgets;
  }

  void _showPenOptions(BuildContext context, ToolState t,
      {required bool highlighter}) {
    final presetColors = highlighter ? _highlighterColors : _penColors;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return ListenableBuilder(
          listenable: t,
          builder: (ctx, _) {
            final customColors =
                highlighter ? t.customHighlighterColors : t.customPenColors;
            final allColors = [...presetColors, ...customColors];
            final activeColor =
                highlighter ? t.highlighterColor : t.penColor;
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlighter ? 'Highlighter' : 'Pen',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                  ),
                  if (!highlighter) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Brush',
                      style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final b in _penBrushStyles)
                          _ThemedChoiceChip(
                            label: _brushLabel(b),
                            selected: t.brushStyle == b,
                            onSelected: () => t.set((s) => s.brushStyle = b),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Color',
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final c in allColors)
                        _ColorSwatch(
                          color: c,
                          selected: _colorsMatch(activeColor, c),
                          onTap: () {
                            t.set((s) {
                              if (highlighter) {
                                s.highlighterColor = c;
                              } else {
                                s.penColor = c;
                              }
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                      _AddColorSwatch(
                        onTap: () async {
                          final picked = await _showCustomColorPicker(
                            ctx,
                            initial: activeColor,
                          );
                          if (picked == null || !ctx.mounted) return;
                          t.set((s) {
                            if (highlighter) {
                              s.highlighterColor = picked;
                              s.addCustomHighlighterColor(picked);
                            } else {
                              s.penColor = picked;
                              s.addCustomPenColor(picked);
                            }
                          });
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.line_weight_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                      Expanded(
                        child: Slider(
                          value: highlighter ? t.highlighterWidth : t.penWidth,
                          min: highlighter ? 8 : 1,
                          max: highlighter ? 36 : 12,
                          onChanged: (v) {
                            t.set((s) {
                              if (highlighter) {
                                s.highlighterWidth = v;
                              } else {
                                s.penWidth = v;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Color?> _showCustomColorPicker(
    BuildContext context, {
    required Color initial,
  }) {
    return showDialog<Color>(
      context: context,
      builder: (ctx) => _CustomColorPickerDialog(initial: initial),
    );
  }

  void _showTapeOptions(BuildContext context, ToolState t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tape', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Draw to cover notes; tap tape to reveal or hide again',
                style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final c in _tapeColors)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () {
                        t.set((s) => s.tapeColor = c);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: t.tapeColor == c
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx, setSheet) => Row(
                children: [
                  const Icon(Icons.line_weight_rounded, size: 20),
                  Expanded(
                    child: Slider(
                      value: t.tapeWidth,
                      min: 12,
                      max: 48,
                      onChanged: (v) {
                        setSheet(() {});
                        t.set((s) => s.tapeWidth = v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFillOptions(BuildContext context, ToolState t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fill color', style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final c in _fillColors)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
                      onTap: () {
                        t.set((s) => s.fillColor = c);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: t.fillColor == c
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Draw a closed loop, or tap inside a shape to fill',
                style: Theme.of(ctx).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showEraserOptions(BuildContext context, ToolState t) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Eraser size', style: Theme.of(ctx).textTheme.titleMedium),
            StatefulBuilder(
              builder: (ctx, setSheet) => Slider(
                value: t.eraserRadius,
                min: 6,
                max: 48,
                onChanged: (v) {
                  setSheet(() {});
                  t.set((s) => s.eraserRadius = v);
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('Eraser mode', style: Theme.of(ctx).textTheme.titleMedium),
            StatefulBuilder(
              builder: (ctx, setSheet) => SegmentedButton<EraserMode>(
                segments: const [
                  ButtonSegment(
                    value: EraserMode.partial,
                    label: Text('Pixel'),
                    icon: Icon(Icons.grain, size: 18),
                  ),
                  ButtonSegment(
                    value: EraserMode.wholeStroke,
                    label: Text('Stroke'),
                    icon: Icon(Icons.content_cut, size: 18),
                  ),
                ],
                selected: {t.eraserMode},
                onSelectionChanged: (sel) {
                  setSheet(() {});
                  t.set((s) => s.eraserMode = sel.first);
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.eraserMode == EraserMode.partial
                  ? 'Erases only ink under the eraser circle'
                  : 'Erases whole strokes it touches',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle vertical separator between toolbar groups.
class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 1,
        height: 28,
        color: const Color(0xFFE0E4EA),
      ),
    );
  }
}

/// Right-side action icon with optional active tint.
class _ActionIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool active;

  const _ActionIconButton({
    required this.tooltip,
    required this.icon,
    this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: _kToolbarIconSize),
        color: active
            ? primary
            : enabled
                ? const Color(0xFF4A4A4A)
                : const Color(0xFFB8BEC8),
        style: active
            ? IconButton.styleFrom(
                backgroundColor: primary.withOpacity(0.10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kToolButtonRadius),
                ),
              )
            : null,
        onPressed: onPressed,
      ),
    );
  }
}

String _brushLabel(BrushStyle b) => switch (b) {
      BrushStyle.pen => 'Pen',
      BrushStyle.fountainPen => 'Fountain',
      BrushStyle.pencil => 'Pencil',
      BrushStyle.marker => 'Marker',
      BrushStyle.calligraphy => 'Calligraphy',
    };

bool _colorsMatch(Color a, Color b) => a.value == b.value;

/// Choice chip with theme-aware contrast (fixes white-on-white in light theme).
class _ThemedChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _ThemedChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
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

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorSwatch({
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
                    ? const Color(0xFFD0D4DC)
                    : Colors.transparent,
          ),
        ),
      ),
    );
  }
}

class _AddColorSwatch extends StatelessWidget {
  final VoidCallback onTap;

  const _AddColorSwatch({required this.onTap});

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
        child: Icon(Icons.add_rounded, size: 20, color: scheme.onSurfaceVariant),
      ),
    );
  }
}

class _CustomColorPickerDialog extends StatefulWidget {
  final Color initial;

  const _CustomColorPickerDialog({required this.initial});

  @override
  State<_CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<_CustomColorPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _hsv.toColor();
    return AlertDialog(
      title: const Text('Custom color'),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: scheme.outline),
              ),
            ),
            const SizedBox(height: 16),
            _SliderRow(
              label: 'Hue',
              value: _hsv.hue,
              max: 360,
              onChanged: (v) => setState(() => _hsv = _hsv.withHue(v)),
            ),
            _SliderRow(
              label: 'Saturation',
              value: _hsv.saturation,
              max: 1,
              onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
            ),
            _SliderRow(
              label: 'Brightness',
              value: _hsv.value,
              max: 1,
              onChanged: (v) => setState(() => _hsv = _hsv.withValue(v)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, color),
          child: const Text('Use color'),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
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
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback? onTapWhenSelected;
  final Color? accent;

  const _ToolButton({
    required this.icon,
    required this.selected,
    required this.tooltip,
    required this.onTap,
    this.onTapWhenSelected,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: selected ? primary.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(_kToolButtonRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(_kToolButtonRadius),
            onTap: selected ? (onTapWhenSelected ?? onTap) : onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: selected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(_kToolButtonRadius),
                      border: Border.all(
                        color: primary.withOpacity(0.22),
                        width: 1,
                      ),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: _kToolbarIconSize,
                    color: selected ? primary : const Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      color:
                          selected ? (accent ?? primary) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
