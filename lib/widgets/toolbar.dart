import 'package:flutter/material.dart';

import '../canvas/drawing_canvas.dart';
import '../models/models.dart';

const _penColors = [
  Color(0xFF1A1A1A),
  Color(0xFF2455C3),
  Color(0xFFC0392B),
  Color(0xFF1E8449),
  Color(0xFF7D3C98),
];

const _highlighterColors = [
  Color(0xFFFFE100),
  Color(0xFF7CF77C),
  Color(0xFF7CD6F7),
  Color(0xFFF77CE0),
  Color(0xFFFFA94D),
];

const _fillColors = [
  Color(0xFF2455C3),
  Color(0xFFFFE100),
  Color(0xFF7CF77C),
  Color(0xFFF77CE0),
  Color(0xFFFFA94D),
];

/// Top editing toolbar: back (left), drawing tools (center), page actions (right).
class EditorToolbar extends StatelessWidget implements PreferredSizeWidget {
  final ToolState toolState;
  final bool canUndo;
  final bool canRedo;
  final bool hasSelection;
  final bool canPaste;
  final int pageIndex;
  final int pageCount;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onDeleteSelection;
  final VoidCallback? onCopy;
  final VoidCallback? onPaste;
  final VoidCallback onAddPage;
  final VoidCallback onTemplate;
  final VoidCallback onAddImage;
  final VoidCallback? onPageOverview;

  const EditorToolbar({
    super.key,
    required this.toolState,
    required this.canUndo,
    required this.canRedo,
    required this.hasSelection,
    this.canPaste = false,
    required this.pageIndex,
    required this.pageCount,
    required this.onUndo,
    required this.onRedo,
    required this.onDeleteSelection,
    this.onCopy,
    this.onPaste,
    required this.onAddPage,
    required this.onTemplate,
    required this.onAddImage,
    this.onPageOverview,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: toolState,
      builder: (context, _) {
        final t = toolState;
        final penFamily = t.tool == ToolType.pen ||
            t.tool == ToolType.shape ||
            t.tool == ToolType.fill;
        return Material(
          color: Colors.white,
          elevation: 0.5,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  const BackButton(),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Undo',
                            icon: const Icon(Icons.undo_rounded),
                            onPressed: canUndo ? onUndo : null,
                          ),
                          IconButton(
                            tooltip: 'Redo',
                            icon: const Icon(Icons.redo_rounded),
                            onPressed: canRedo ? onRedo : null,
                          ),
                          const VerticalDivider(width: 12, indent: 12, endIndent: 12),
                          _ToolButton(
                            icon: Icons.edit_rounded,
                            selected: penFamily && t.tool != ToolType.fill,
                            tooltip: 'Pen',
                            onTap: () => t.set((s) => s.tool = ToolType.pen),
                            onTapWhenSelected: () =>
                                _showPenOptions(context, t, highlighter: false),
                            accent: penFamily && t.tool != ToolType.fill
                                ? t.penColor
                                : null,
                          ),
                          if (penFamily && t.tool != ToolType.fill)
                            _BrushStyleRow(toolState: t),
                          _ToolButton(
                            icon: Icons.brush_rounded,
                            selected: t.tool == ToolType.highlighter,
                            tooltip: 'Highlighter',
                            onTap: () =>
                                t.set((s) => s.tool = ToolType.highlighter),
                            onTapWhenSelected: () =>
                                _showPenOptions(context, t, highlighter: true),
                            accent: t.tool == ToolType.highlighter
                                ? t.highlighterColor
                                : null,
                          ),
                          _ToolButton(
                            icon: Icons.cleaning_services_rounded,
                            selected: t.tool == ToolType.eraser,
                            tooltip: 'Eraser',
                            onTap: () => t.set((s) => s.tool = ToolType.eraser),
                            onTapWhenSelected: () =>
                                _showEraserOptions(context, t),
                          ),
                          _ToolButton(
                            icon: Icons.near_me_rounded,
                            selected: t.tool == ToolType.selection,
                            tooltip: 'Selection',
                            onTap: () =>
                                t.set((s) => s.tool = ToolType.selection),
                          ),
                          _ToolButton(
                            icon: Icons.gesture_rounded,
                            selected: t.tool == ToolType.lasso,
                            tooltip: 'Lasso',
                            onTap: () => t.set((s) => s.tool = ToolType.lasso),
                          ),
                          _ToolButton(
                            icon: Icons.interests_rounded,
                            selected: t.tool == ToolType.shape,
                            tooltip: 'Shape',
                            onTap: () => t.set((s) => s.tool = ToolType.shape),
                            onTapWhenSelected: () =>
                                _showPenOptions(context, t, highlighter: false),
                          ),
                          _ToolButton(
                            icon: Icons.format_color_fill_rounded,
                            selected: t.tool == ToolType.fill,
                            tooltip: 'Fill',
                            onTap: () => t.set((s) => s.tool = ToolType.fill),
                            onTapWhenSelected: () => _showFillOptions(context, t),
                            accent: t.tool == ToolType.fill ? t.fillColor : null,
                          ),
                          _ToolButton(
                            icon: Icons.text_fields_rounded,
                            selected: t.tool == ToolType.text,
                            tooltip: 'Text',
                            onTap: () => t.set((s) => s.tool = ToolType.text),
                          ),
                          _ToolButton(
                            icon: Icons.image_outlined,
                            selected: false,
                            tooltip: 'Insert image',
                            onTap: onAddImage,
                          ),
                          if (hasSelection) ...[
                            const VerticalDivider(
                                width: 12, indent: 12, endIndent: 12),
                            IconButton(
                              tooltip: 'Copy',
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: onCopy,
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: onDeleteSelection,
                            ),
                          ],
                          if (canPaste)
                            IconButton(
                              tooltip: 'Paste',
                              icon: const Icon(Icons.content_paste_rounded),
                              onPressed: onPaste,
                            ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Page settings',
                    icon: const Icon(Icons.tune_rounded),
                    onSelected: (value) {
                      switch (value) {
                        case 'template':
                          onTemplate();
                        default:
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'template',
                        child: ListTile(
                          leading: Icon(Icons.grid_4x4_rounded),
                          title: Text('Page template'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Add page',
                    icon: const Icon(Icons.note_add_outlined),
                    onPressed: onAddPage,
                  ),
                  IconButton(
                    tooltip: t.stylusOnly
                        ? 'Stylus-only (palm rejection)'
                        : 'Finger drawing',
                    icon: Icon(
                      t.stylusOnly
                          ? Icons.do_not_touch_rounded
                          : Icons.touch_app_rounded,
                      color: t.stylusOnly
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () =>
                        t.set((s) => s.stylusOnly = !s.stylusOnly),
                  ),
                  if (onPageOverview != null)
                    IconButton(
                      tooltip: 'Page overview',
                      icon: const Icon(Icons.dashboard_rounded),
                      onPressed: onPageOverview,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8, left: 4),
                    child: Center(
                      child: Text(
                        '${pageIndex + 1}/$pageCount',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPenOptions(BuildContext context, ToolState t,
      {required bool highlighter}) {
    final colors = highlighter ? _highlighterColors : _penColors;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(highlighter ? 'Highlighter' : 'Pen',
                style: Theme.of(ctx).textTheme.titleMedium),
            if (!highlighter) ...[
              const SizedBox(height: 12),
              Text('Brush', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final b in BrushStyle.values)
                    ChoiceChip(
                      label: Text(switch (b) {
                        BrushStyle.pen => 'Pen',
                        BrushStyle.fountainPen => 'Fountain',
                        BrushStyle.pencil => 'Pencil',
                        BrushStyle.marker => 'Marker',
                        BrushStyle.calligraphy => 'Calligraphy',
                      }),
                      selected: t.brushStyle == b,
                      onSelected: (_) => t.set((s) => s.brushStyle = b),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                for (final c in colors)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: GestureDetector(
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
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: (highlighter
                                        ? t.highlighterColor
                                        : t.penColor) ==
                                    c
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
                      value: highlighter ? t.highlighterWidth : t.penWidth,
                      min: highlighter ? 8 : 1,
                      max: highlighter ? 36 : 12,
                      onChanged: (v) {
                        setSheet(() {});
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
            Text('Erases whole strokes it touches',
                style: Theme.of(ctx).textTheme.bodySmall),
          ],
        ),
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

IconData _brushIcon(BrushStyle b) => switch (b) {
      BrushStyle.pen => Icons.edit_rounded,
      BrushStyle.fountainPen => Icons.draw_rounded,
      BrushStyle.pencil => Icons.create_rounded,
      BrushStyle.marker => Icons.brush_rounded,
      BrushStyle.calligraphy => Icons.format_paint_rounded,
    };

/// Compact horizontal brush picker shown when pen/shape is active.
class _BrushStyleRow extends StatelessWidget {
  final ToolState toolState;

  const _BrushStyleRow({required this.toolState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: toolState,
      builder: (context, _) {
        final primary = Theme.of(context).colorScheme.primary;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final b in BrushStyle.values)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Tooltip(
                    message: _brushLabel(b),
                    child: Material(
                      color: toolState.brushStyle == b
                          ? primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => toolState.set((s) => s.brushStyle = b),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            _brushIcon(b),
                            size: 18,
                            color: toolState.brushStyle == b
                                ? primary
                                : Colors.black45,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: selected ? primary.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: selected ? (onTapWhenSelected ?? onTap) : onTap,
            child: Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 22, color: selected ? primary : Colors.black54),
                  const SizedBox(height: 2),
                  Container(
                    height: 3,
                    width: 18,
                    decoration: BoxDecoration(
                      color: selected ? (accent ?? primary) : Colors.transparent,
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
