import 'package:flutter/material.dart';

import '../canvas/drawing_canvas.dart';
import '../l10n/l10n.dart';
import '../models/models.dart';
import '../services/stroke_eraser.dart';
import '../services/toolbar_order_service.dart';
import 'color_picker/color_swatch_widgets.dart';
import 'color_picker/penfold_color_picker_dialog.dart';
import 'color_picker/tool_color_presets.dart';
import 'themed_choice_chip.dart';

const _kToolbarIconSize = 22.0;
const _kToolButtonRadius = 12.0;

/// Brush styles shown in the pen options popup (marker is a style, not a tool).
const _penBrushStyles = [
  BrushStyle.pen,
  BrushStyle.fountainPen,
  BrushStyle.pencil,
  BrushStyle.marker,
  BrushStyle.calligraphy,
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
        final centerTools = _buildCenterTools(context, t, l10n);
        return Material(
          color: scheme.surface,
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
          final penLinked = t.tool == ToolType.pen || t.tool == ToolType.shape;
          widgets.add(
            _ToolButton(
              icon: Icons.edit_rounded,
              selected: penLinked,
              tooltip: l10n.toolPen,
              onTap: () => t.set((s) => s.tool = ToolType.pen),
              onTapWhenSelected: () =>
                  _showPenOptions(context, t, highlighter: false),
              accent: penLinked ? t.penColor : null,
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
                    : Theme.of(context).colorScheme.onSurfaceVariant,
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
              onTapWhenSelected: () => t.set((s) => s.tool = ToolType.pen),
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
    final presetColors =
        highlighter ? highlighterPresetColors : penPresetColors;
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
                          ThemedChoiceChip(
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
                  ColorSwatchRow(
                    presetColors: presetColors,
                    customColors: customColors,
                    activeColor: activeColor,
                    onColorSelected: (c) {
                      t.set((s) {
                        if (highlighter) {
                          s.highlighterColor = c;
                        } else {
                          s.penColor = c;
                        }
                      });
                      Navigator.pop(ctx);
                    },
                    onAddCustomColor: () async {
                      final picked = await showPenfoldColorPicker(
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
                for (final c in tapePresetColors)
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
            StatefulBuilder(
              builder: (ctx, setSheet) => Row(
                children: [
                  const Icon(Icons.opacity_rounded, size: 20),
                  Expanded(
                    child: Slider(
                      value: t.tapeOpacity,
                      min: 0.25,
                      max: 1.0,
                      onChanged: (v) {
                        setSheet(() {});
                        t.set((s) => s.tapeOpacity = v);
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return ListenableBuilder(
          listenable: t,
          builder: (ctx, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fillColorTitle,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.colorLabel,
                    style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ColorSwatchRow(
                    presetColors: fillPresetColors,
                    customColors: t.customFillColors,
                    activeColor: t.fillColor,
                    onColorSelected: (c) {
                      t.set((s) => s.fillColor = c);
                      Navigator.pop(ctx);
                    },
                    onAddCustomColor: () async {
                      final picked = await showPenfoldColorPicker(
                        ctx,
                        initial: t.fillColor,
                      );
                      if (picked == null || !ctx.mounted) return;
                      t.set((s) {
                        s.fillColor = picked;
                        s.addCustomFillColor(picked);
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.fillOptionsHint,
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
    final outline = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 1,
        height: 28,
        color: outline.withOpacity(0.45),
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
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: _kToolbarIconSize),
        color: active
            ? primary
            : enabled
                ? scheme.onSurface
                : scheme.onSurface.withOpacity(0.38),
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
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
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
                        color: selected ? primary : scheme.onSurfaceVariant,
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
