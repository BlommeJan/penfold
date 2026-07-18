import 'package:flutter/material.dart';

import '../canvas/drawing_canvas.dart';
import '../l10n/l10n.dart';
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
  final void Function(BuildContext anchorContext)? onPageMenu;
  final VoidCallback onAddImage;
  final VoidCallback? onPageOverview;
  final VoidCallback? onContents;
  final bool canPrevBookmark;
  final bool canNextBookmark;
  final VoidCallback? onPrevBookmark;
  final VoidCallback? onNextBookmark;
  final VoidCallback? onBack;
  final bool hasPageStrokes;
  final VoidCallback? onEraseAllOnPage;

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
    this.onPageMenu,
    required this.onAddImage,
    this.onPageOverview,
    this.onContents,
    this.canPrevBookmark = false,
    this.canNextBookmark = false,
    this.onPrevBookmark,
    this.onNextBookmark,
    this.onBack,
    this.hasPageStrokes = false,
    this.onEraseAllOnPage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([toolState, ToolbarOrderService.instance]),
      builder: (context, _) {
        final t = toolState;
        final l10n = context.l10n;
        final scheme = Theme.of(context).colorScheme;
        final penFamily = t.tool == ToolType.pen ||
            t.tool == ToolType.shape ||
            t.tool == ToolType.fill;
        final centerTools = _buildCenterTools(context, t, penFamily, l10n);
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
                    tooltip: l10n.toolbarPreviousBookmark,
                    icon: Icons.expand_less_rounded,
                    onPressed: canPrevBookmark ? onPrevBookmark : null,
                  ),
                  _ActionIconButton(
                    tooltip: l10n.toolbarNextBookmark,
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
                                    tooltip: l10n.toolbarConvertToText,
                                    icon: Icons.text_fields_rounded,
                                    onPressed: onConvertToText,
                                  ),
                                _ActionIconButton(
                                  tooltip: l10n.toolbarCopy,
                                  icon: Icons.copy_rounded,
                                  onPressed: onCopy,
                                ),
                                _ActionIconButton(
                                  tooltip: l10n.toolbarDelete,
                                  icon: Icons.delete_outline_rounded,
                                  onPressed: onDeleteSelection,
                                ),
                              ],
                              if (canPaste)
                                _ActionIconButton(
                                  tooltip: l10n.toolbarPaste,
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
                    tooltip: l10n.toolbarUndo,
                    icon: Icons.undo_rounded,
                    onPressed: canUndo ? onUndo : null,
                  ),
                  _ActionIconButton(
                    tooltip: l10n.toolbarRedo,
                    icon: Icons.redo_rounded,
                    onPressed: canRedo ? onRedo : null,
                  ),
                  const _ToolbarDivider(),
                  _ActionIconButton(
                    tooltip: l10n.toolbarAddPage,
                    icon: Icons.note_add_outlined,
                    onPressed: onAddPage,
                  ),
                  _ActionIconButton(
                    tooltip: t.stylusOnly
                        ? l10n.toolbarStylusOnly
                        : l10n.toolbarFingerDrawing,
                    icon: t.stylusOnly
                        ? Icons.do_not_touch_rounded
                        : Icons.touch_app_rounded,
                    onPressed: () =>
                        t.set((s) => s.stylusOnly = !s.stylusOnly),
                    active: t.stylusOnly,
                  ),
                  if (onPageOverview != null)
                    _ActionIconButton(
                      tooltip: l10n.toolbarPageOverview,
                      icon: Icons.dashboard_rounded,
                      onPressed: onPageOverview,
                    ),
                  if (onContents != null)
                    _ActionIconButton(
                      tooltip: l10n.toolbarTableOfContents,
                      icon: Icons.list_alt_rounded,
                      onPressed: onContents,
                    ),
                  if (onPageMenu != null)
                    Builder(
                      builder: (btnContext) => _ActionIconButton(
                        tooltip: l10n.toolbarPageMenu,
                        icon: Icons.settings_rounded,
                        onPressed: () => onPageMenu!(btnContext),
                      ),
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
    AppLocalizations l10n,
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
              tooltip: l10n.toolPen,
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
              tooltip: l10n.toolHighlighter,
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
              tooltip: l10n.toolTape,
              onTap: () => t.set((s) => s.tool = ToolType.tape),
              onTapWhenSelected: () => _showTapeOptions(context, t),
              accent: t.tool == ToolType.tape ? t.tapeColor : null,
            ),
          );
        case ToolbarToolId.eraser:
          widgets.add(
            _ToolButton(
              iconWidget: _EraserIcon(
                size: _kToolbarIconSize,
                color: t.tool == ToolType.eraser
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF6B7280),
              ),
              selected: t.tool == ToolType.eraser,
              tooltip: l10n.toolEraser,
              onTap: () => t.set((s) => s.tool = ToolType.eraser),
              onTapWhenSelected: () => _showEraserOptions(context, t),
            ),
          );
        case ToolbarToolId.selection:
          widgets.add(
            _ToolButton(
              icon: Icons.near_me_rounded,
              selected: t.tool == ToolType.selection,
              tooltip: l10n.toolSelection,
              onTap: () => t.set((s) => s.tool = ToolType.selection),
            ),
          );
        case ToolbarToolId.lasso:
          widgets.add(
            _ToolButton(
              icon: Icons.gesture_rounded,
              selected: t.tool == ToolType.lasso,
              tooltip: l10n.toolLasso,
              onTap: () => t.set((s) => s.tool = ToolType.lasso),
            ),
          );
        case ToolbarToolId.shape:
          widgets.add(
            _ToolButton(
              icon: Icons.interests_rounded,
              selected: t.tool == ToolType.shape,
              tooltip: l10n.toolShape,
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
              tooltip: l10n.toolFill,
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
              tooltip: l10n.toolText,
              onTap: () => t.set((s) => s.tool = ToolType.text),
            ),
          );
        case ToolbarToolId.insertImage:
          widgets.add(
            _ToolButton(
              icon: Icons.image_outlined,
              selected: false,
              tooltip: l10n.toolInsertImage,
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
    final l10n = context.l10n;
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
                    highlighter ? l10n.highlighterOptionsTitle : l10n.penOptionsTitle,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                  ),
                  if (!highlighter) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.brushLabel,
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
                            label: l10n.brushStyleLabel(b),
                            selected: t.brushStyle == b,
                            onSelected: () => t.set((s) => s.brushStyle = b),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.colorLabel,
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
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.tapeOptionsTitle, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(l10n.tapeOptionsHint,
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
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.fillColorTitle, style: Theme.of(ctx).textTheme.titleMedium),
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
            Text(l10n.fillOptionsHint,
                style: Theme.of(ctx).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _showEraserOptions(BuildContext context, ToolState t) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.eraserSizeTitle, style: Theme.of(ctx).textTheme.titleMedium),
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
            Text(l10n.eraserModeTitle, style: Theme.of(ctx).textTheme.titleMedium),
            StatefulBuilder(
              builder: (ctx, setSheet) => SegmentedButton<EraserMode>(
                segments: [
                  ButtonSegment(
                    value: EraserMode.partial,
                    label: Text(l10n.eraserModePixel),
                    icon: const Icon(Icons.grain, size: 18),
                  ),
                  ButtonSegment(
                    value: EraserMode.wholeStroke,
                    label: Text(l10n.eraserModeStroke),
                    icon: const Icon(Icons.content_cut, size: 18),
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
                  ? l10n.eraserModePartialHint
                  : l10n.eraserModeWholeStrokeHint,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            if (onEraseAllOnPage != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: hasPageStrokes
                    ? () async {
                        final confirmed = await showDialog<bool>(
                          context: ctx,
                          builder: (dialogCtx) => AlertDialog(
                            title: Text(l10n.eraseAllOnPageTitle),
                            content: Text(l10n.eraseAllOnPageBody),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, false),
                                child: Text(l10n.actionCancel),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(dialogCtx, true),
                                child: Text(l10n.actionEraseAll),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true && ctx.mounted) {
                          Navigator.pop(ctx);
                          onEraseAllOnPage!();
                        }
                      }
                    : null,
                icon: const Icon(Icons.delete_sweep_outlined),
                label: Text(l10n.eraseAllOnPageButton),
              ),
            ],
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
    final l10n = context.l10n;
    final color = _hsv.toColor();
    return AlertDialog(
      title: Text(l10n.customColorTitle),
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
              label: l10n.hueLabel,
              value: _hsv.hue,
              max: 360,
              onChanged: (v) => setState(() => _hsv = _hsv.withHue(v)),
            ),
            _SliderRow(
              label: l10n.saturationLabel,
              value: _hsv.saturation,
              max: 1,
              onChanged: (v) => setState(() => _hsv = _hsv.withSaturation(v)),
            ),
            _SliderRow(
              label: l10n.brightnessLabel,
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
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, color),
          child: Text(l10n.actionUseColor),
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
  final IconData? icon;
  final Widget? iconWidget;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;
  final VoidCallback? onTapWhenSelected;
  final Color? accent;

  const _ToolButton({
    this.icon,
    this.iconWidget,
    required this.selected,
    required this.tooltip,
    required this.onTap,
    this.onTapWhenSelected,
    this.accent,
  }) : assert(icon != null || iconWidget != null);

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
                  iconWidget ??
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

/// Eraser-shaped toolbar icon (rectangular block with angled top).
class _EraserIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _EraserIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EraserIconPainter(color: color),
      ),
    );
  }
}

class _EraserIconPainter extends CustomPainter {
  final Color color;

  _EraserIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // GoodNotes-style: thick pink rubber block, short grey ferrule, slight tilt.
    canvas.save();
    canvas.translate(w * 0.50, h * 0.52);
    canvas.rotate(-0.35);

    final bodyW = w * 0.62;
    final bodyH = h * 0.38;
    final sleeveH = h * 0.22;
    final r = Radius.circular(w * 0.08);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(0, -sleeveH * 0.35), width: bodyW, height: bodyH),
      r,
    );
    final sleeveRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, bodyH * 0.42),
        width: bodyW * 0.92,
        height: sleeveH,
      ),
      Radius.circular(w * 0.05),
    );

    canvas.drawRRect(
      bodyRect,
      Paint()..color = const Color(0xFFFF8A9A),
    );
    canvas.drawRRect(
      sleeveRect,
      Paint()..color = const Color(0xFFB0B6C0),
    );

    // Soft top bevel so the pink block reads at 22px.
    canvas.drawLine(
      Offset(-bodyW * 0.38, -bodyH * 0.55 - sleeveH * 0.35),
      Offset(bodyW * 0.38, -bodyH * 0.55 - sleeveH * 0.35),
      Paint()
        ..color = const Color(0xFFFFCDD4)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    final outline = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(bodyRect, outline);
    canvas.drawRRect(sleeveRect, outline);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EraserIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
