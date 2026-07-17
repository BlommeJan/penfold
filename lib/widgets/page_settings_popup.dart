import 'package:flutter/material.dart';

import '../models/models.dart';
import 'page_audio_settings.dart';

/// Whether a page uses an imported PDF background (size/orientation locked).
bool isPdfBackgroundPage(NotePage page) =>
    page.pdfImagePath != null || page.pdfSourcePath != null;

String pageTemplateLabel(PageTemplate template) => switch (template) {
      PageTemplate.blank => 'Blank',
      PageTemplate.lined => 'Lined',
      PageTemplate.grid => 'Grid',
      PageTemplate.dotted => 'Dotted',
      PageTemplate.collegeRuled => 'College ruled',
    };

IconData pageTemplateIcon(PageTemplate template) => switch (template) {
      PageTemplate.blank => Icons.crop_portrait_rounded,
      PageTemplate.lined => Icons.notes_rounded,
      PageTemplate.grid => Icons.grid_4x4_rounded,
      PageTemplate.dotted => Icons.apps_rounded,
      PageTemplate.collegeRuled => Icons.margin_rounded,
    };

/// One-line summary for page settings (gear menu / tests).
String pageSettingsSummary(NotePage page, {required bool isPdfPage}) {
  if (isPdfPage) {
    return 'PDF · ${page.orientation.label}';
  }
  return '${pageTemplateLabel(page.template)} · ${page.pageSize.label} · ${page.orientation.label}';
}

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
  return showMenu<EditorPageMenuAction>(
    context: context,
    position: position,
    items: [
      const PopupMenuItem(
        value: EditorPageMenuAction.pageSettings,
        child: ListTile(
          leading: Icon(Icons.tune_rounded),
          title: Text('Page settings'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: EditorPageMenuAction.pageSize,
        child: ListTile(
          leading: Icon(Icons.aspect_ratio_rounded),
          title: Text('Page size'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: EditorPageMenuAction.orientation,
        child: ListTile(
          leading: Icon(Icons.screen_rotation_rounded),
          title: Text('Orientation'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: EditorPageMenuAction.contents,
        child: ListTile(
          leading: Icon(Icons.list_alt_rounded),
          title: Text('Table of contents'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        value: EditorPageMenuAction.bookmark,
        child: ListTile(
          leading: Icon(
            bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          ),
          title: Text(bookmarked ? 'Remove bookmark' : 'Bookmark'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: EditorPageMenuAction.audio,
        child: ListTile(
          leading: Icon(Icons.mic_none_rounded),
          title: Text('Audio'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: EditorPageMenuAction.split,
        child: ListTile(
          leading: Icon(Icons.call_split_rounded),
          title: Text('Split'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem(
        value: EditorPageMenuAction.export,
        child: ListTile(
          leading: Icon(Icons.upload_rounded),
          title: Text('Export'),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ],
  );
}

Future<Object?> showPageTemplatePicker({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
}) {
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
              'Page template',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          for (final t in PageTemplate.values)
            ListTile(
              leading: Icon(pageTemplateIcon(t)),
              title: Text(pageTemplateLabel(t)),
              trailing:
                  page.template == t ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.pop(ctx, t),
            ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'PDF pages keep their document background',
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
              'Page size',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          for (final s in PageSize.values)
            ListTile(
              leading: const Icon(Icons.aspect_ratio_rounded),
              title: Text(s.label),
              trailing:
                  page.pageSize == s ? const Icon(Icons.check_rounded) : null,
              enabled: !isPdfPage,
              onTap: !isPdfPage ? () => Navigator.pop(ctx, s) : null,
            ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'PDF pages keep their document dimensions',
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
              'Orientation',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          for (final o in PageOrientation.values)
            ListTile(
              leading: Icon(o == PageOrientation.portrait
                  ? Icons.crop_portrait_rounded
                  : Icons.crop_landscape_rounded),
              title: Text(o.label),
              trailing:
                  page.orientation == o ? const Icon(Icons.check_rounded) : null,
              enabled: !isPdfPage,
              onTap: !isPdfPage ? () => Navigator.pop(ctx, o) : null,
            ),
          if (isPdfPage)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'PDF pages keep their document orientation',
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
            child: Text('Export', style: Theme.of(ctx).textTheme.titleMedium),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Export page as PNG'),
            subtitle: const Text('Share image of this page'),
            onTap: () => Navigator.pop(ctx, 'export_png'),
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: const Text('Export page as PDF'),
            subtitle: const Text('Vector ink, share via system sheet'),
            onTap: () => Navigator.pop(ctx, 'export_pdf'),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Export notebook as PDF'),
            subtitle: Text('$notebookPageCount pages'),
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
            child: Text('Audio', style: Theme.of(ctx).textTheme.titleMedium),
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

/// Legacy entry point — opens template picker only.
Future<Object?> showPageSettingsPopup({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
  required int notebookPageCount,
  required ValueChanged<String?> onAudioChanged,
}) =>
    showPageTemplatePicker(
      context: context,
      page: page,
      isPdfPage: isPdfPage,
    );
