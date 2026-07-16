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

/// One-line summary for the top-right page info chip.
String pageSettingsSummary(NotePage page, {required bool isPdfPage}) {
  if (isPdfPage) {
    return 'PDF · ${page.orientation.label}';
  }
  return '${pageTemplateLabel(page.template)} · ${page.pageSize.label} · ${page.orientation.label}';
}

/// Compact chip on the document canvas; tap opens [showPageSettingsPopup].
class PageInfoChip extends StatelessWidget {
  final NotePage page;
  final bool isPdfPage;
  final VoidCallback onTap;

  const PageInfoChip({
    super.key,
    required this.page,
    required this.isPdfPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withOpacity(0.92),
      elevation: 2,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPdfPage
                    ? Icons.picture_as_pdf_outlined
                    : pageTemplateIcon(page.template),
                size: 16,
                color: scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                pageSettingsSummary(page, isPdfPage: isPdfPage),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scrollable page settings sheet (template, size, orientation, export, etc.).
Future<Object?> showPageSettingsPopup({
  required BuildContext context,
  required NotePage page,
  required bool isPdfPage,
  required int notebookPageCount,
  required ValueChanged<String?> onAudioChanged,
}) {
  return showModalBottomSheet<Object?>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final maxHeight = MediaQuery.sizeOf(ctx).height * 0.88;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: _PageSettingsSheetBody(
              page: page,
              isPdfPage: isPdfPage,
              notebookPageCount: notebookPageCount,
              onAudioChanged: onAudioChanged,
            ),
          ),
        ),
      );
    },
  );
}

class _PageSettingsSheetBody extends StatelessWidget {
  final NotePage page;
  final bool isPdfPage;
  final int notebookPageCount;
  final ValueChanged<String?> onAudioChanged;

  const _PageSettingsSheetBody({
    required this.page,
    required this.isPdfPage,
    required this.notebookPageCount,
    required this.onAudioChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Page settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text('Page template',
              style: Theme.of(context).textTheme.titleSmall),
        ),
        for (final t in PageTemplate.values)
          ListTile(
            leading: Icon(pageTemplateIcon(t)),
            title: Text(pageTemplateLabel(t)),
            trailing: page.template == t
                ? const Icon(Icons.check_rounded)
                : null,
            onTap: () => Navigator.pop(context, t),
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child:
              Text('Page size', style: Theme.of(context).textTheme.titleSmall),
        ),
        for (final s in PageSize.values)
          ListTile(
            leading: const Icon(Icons.aspect_ratio_rounded),
            title: Text(s.label),
            trailing: page.pageSize == s ? const Icon(Icons.check_rounded) : null,
            enabled: !isPdfPage,
            onTap: !isPdfPage ? () => Navigator.pop(context, s) : null,
          ),
        if (isPdfPage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'PDF pages keep their document dimensions',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text('Orientation',
              style: Theme.of(context).textTheme.titleSmall),
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
            onTap: !isPdfPage ? () => Navigator.pop(context, o) : null,
          ),
        if (isPdfPage)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'PDF pages keep their document orientation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.list_alt_rounded),
          title: const Text('Table of contents'),
          subtitle: const Text('Jump to headings in this notebook'),
          onTap: () => Navigator.pop(context, 'contents'),
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(Icons.bookmark_outline_rounded),
          title: const Text('Bookmark this page'),
          value: page.bookmarked,
          onChanged: (v) => Navigator.pop(context, 'bookmark:$v'),
        ),
        PageAudioSettings(
          pageId: page.id,
          audioPath: page.audioPath,
          onAudioChanged: onAudioChanged,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.call_split_rounded),
          title: const Text('Split page'),
          subtitle: const Text(
            'Duplicate template and move half the ink to a new page',
          ),
          onTap: () => Navigator.pop(context, 'split_page'),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text('Export', style: Theme.of(context).textTheme.titleSmall),
        ),
        ListTile(
          leading: const Icon(Icons.image_outlined),
          title: const Text('Export page as PNG'),
          subtitle: const Text('Share image of this page'),
          onTap: () => Navigator.pop(context, 'export_png'),
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf_outlined),
          title: const Text('Export page as PDF'),
          subtitle: const Text('Vector ink, share via system sheet'),
          onTap: () => Navigator.pop(context, 'export_pdf'),
        ),
        ListTile(
          leading: const Icon(Icons.menu_book_outlined),
          title: const Text('Export notebook as PDF'),
          subtitle: Text('$notebookPageCount pages'),
          onTap: () => Navigator.pop(context, 'export_notebook_pdf'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
