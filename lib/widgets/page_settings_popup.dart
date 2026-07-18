import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import 'page_audio_settings.dart';
import 'settings/notebook_defaults_section.dart';

/// Whether a page uses an imported PDF background (size/orientation locked).
bool isPdfBackgroundPage(NotePage page) =>
    page.pdfImagePath != null || page.pdfSourcePath != null;

IconData pageTemplateIcon(PageTemplate template) => switch (template) {
      PageTemplate.blank => Icons.crop_portrait_rounded,
      PageTemplate.lined => Icons.notes_rounded,
      PageTemplate.grid => Icons.grid_4x4_rounded,
      PageTemplate.dotted => Icons.apps_rounded,
      PageTemplate.collegeRuled => Icons.margin_rounded,
    };

/// Gear menu actions anchored near the toolbar settings icon.
enum EditorPageMenuAction {
  pageSettings,
  pageSize,
  orientation,
  contents,
  bookmark,
  audio,
  split,
  export,
}

/// Small popup menu anchored near the gear icon.
Future<EditorPageMenuAction?> showEditorPageMenu({
  required BuildContext context,
  required RelativeRect position,
  required bool bookmarked,
}) {
  final l10n = context.l10n;
  return showMenu<EditorPageMenuAction>(
    context: context,
    position: position,
    items: [
      PopupMenuItem(
        value: EditorPageMenuAction.pageSettings,
        child: ListTile(
          leading: const Icon(Icons.tune_rounded),
          title: Text(l10n.pageSettingsTitle),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.pageSize,
        child: ListTile(
          leading: const Icon(Icons.aspect_ratio_rounded),
          title: Text(l10n.pageSizeTitle),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.orientation,
        child: ListTile(
          leading: const Icon(Icons.screen_rotation_rounded),
          title: Text(l10n.pageOrientationTitle),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.contents,
        child: ListTile(
          leading: const Icon(Icons.list_alt_rounded),
          title: Text(l10n.toolbarTableOfContents),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.bookmark,
        child: ListTile(
          leading: Icon(
            bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          ),
          title: Text(bookmarked ? l10n.pageRemoveBookmark : l10n.pageBookmark),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.audio,
        child: ListTile(
          leading: const Icon(Icons.mic_none_rounded),
          title: Text(l10n.pageAudioTitle),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.split,
        child: ListTile(
          leading: const Icon(Icons.call_split_rounded),
          title: Text(l10n.pageSplit),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.export,
        child: ListTile(
          leading: const Icon(Icons.upload_rounded),
          title: Text(l10n.pageExportTitle),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ],
  );
}

Future<Object?> showPageSettingsSheet({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
}) {
  final l10n = context.l10n;
  var template = page.template;
  var backgroundTheme = page.backgroundTheme;

  return showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  l10n.pageSettingsTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.pageTemplateTitle,
                  style: Theme.of(ctx).textTheme.labelLarge,
                ),
              ),
              for (final t in PageTemplate.values)
                ListTile(
                  leading: Icon(pageTemplateIcon(t)),
                  title: Text(l10n.pageTemplateLabel(t)),
                  trailing: template == t
                      ? const Icon(Icons.check_rounded)
                      : null,
                  enabled: !isPdfPage,
                  onTap: !isPdfPage
                      ? () {
                          setSheet(() => template = t);
                          Navigator.pop(ctx, template);
                        }
                      : null,
                ),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l10n.pageColorTitle,
                  style: Theme.of(ctx).textTheme.labelLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: PageBackgroundThemePickerRow(
                  selected: backgroundTheme,
                  enabled: !isPdfPage,
                  onSelected: (theme) {
                    setSheet(() => backgroundTheme = theme);
                    Navigator.pop(ctx, theme);
                  },
                ),
              ),
              if (isPdfPage)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    l10n.pdfPagesKeepBackground,
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<Object?> showPageBackgroundThemePicker({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              l10n.pageColorTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PageBackgroundThemePickerRow(
              selected: page.backgroundTheme,
              enabled: !isPdfPage,
              onSelected: (theme) => Navigator.pop(ctx, theme),
            ),
          ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.pdfPagesKeepBackground,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<Object?> showPageTemplatePicker({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              l10n.pageTemplateTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          for (final t in PageTemplate.values)
            ListTile(
              leading: Icon(pageTemplateIcon(t)),
              title: Text(l10n.pageTemplateLabel(t)),
              trailing:
                  page.template == t ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(ctx, t),
            ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.pdfPagesKeepBackground,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<Object?> showPageSizePicker({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              l10n.pageSizeTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          for (final s in PageSize.values)
            ListTile(
              leading: const Icon(Icons.aspect_ratio_rounded),
              title: Text(l10n.pageSizeLabel(s)),
              trailing:
                  page.pageSize == s ? const Icon(Icons.check_rounded) : null,
              enabled: !isPdfPage,
              onTap: !isPdfPage ? () => Navigator.pop(ctx, s) : null,
            ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.pdfPagesKeepDimensions,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<Object?> showPageOrientationPicker({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              l10n.pageOrientationTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          for (final o in PageOrientation.values)
            ListTile(
              leading: Icon(o == PageOrientation.portrait
                  ? Icons.crop_portrait_rounded
                  : Icons.crop_landscape_rounded),
              title: Text(l10n.pageOrientationLabel(o)),
              trailing:
                  page.orientation == o ? const Icon(Icons.check_rounded) : null,
              enabled: !isPdfPage,
              onTap: !isPdfPage ? () => Navigator.pop(ctx, o) : null,
            ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                l10n.pdfPagesKeepOrientation,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    ),
  );
}

Future<Object?> showPageExportPicker({
  required BuildContext context,
  required int notebookPageCount,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<Object?>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(l10n.pageExportTitle, style: Theme.of(ctx).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(l10n.exportPageAsPng),
            subtitle: Text(l10n.exportPageAsPngSubtitle),
            onTap: () => Navigator.pop(ctx, 'export_png'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(l10n.exportPageAsPdf),
            subtitle: Text(l10n.exportPageAsPdfSubtitle),
            onTap: () => Navigator.pop(ctx, 'export_pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(l10n.exportNotebookAsPdf),
            subtitle: Text(l10n.exportNotebookPageCount(notebookPageCount)),
            onTap: () => Navigator.pop(ctx, 'export_notebook_pdf'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showPageAudioSheet({
  required BuildContext context,
  required NotePage page,
  required ValueChanged<String?> onAudioChanged,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(l10n.pageAudioTitle, style: Theme.of(ctx).textTheme.titleMedium),
          ),
          PageAudioSettings(
            pageId: page.id,
            audioPath: page.audioPath,
            onAudioChanged: onAudioChanged,
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

/// Legacy entry point — opens combined page settings sheet.
Future<Object?> showPageSettingsPopup({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
  required int notebookPageCount,
  required ValueChanged<String?> onAudioChanged,
}) =>
    showPageSettingsSheet(
      context: context,
      page: page,
      isPdfPage: isPdfPage,
    );
