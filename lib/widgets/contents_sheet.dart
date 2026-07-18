import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../services/toc_service.dart';

/// Modal sheet listing auto-detected notebook headings (v0.2.36).
class ContentsSheet extends StatefulWidget {
  final String notebookId;
  final int currentPageIndex;
  final ValueChanged<int> onPageSelected;

  const ContentsSheet({
    super.key,
    required this.notebookId,
    required this.currentPageIndex,
    required this.onPageSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String notebookId,
    required int currentPageIndex,
    required ValueChanged<int> onPageSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => ContentsSheet(
        notebookId: notebookId,
        currentPageIndex: currentPageIndex,
        onPageSelected: onPageSelected,
      ),
    );
  }

  @override
  State<ContentsSheet> createState() => _ContentsSheetState();
}

class _ContentsSheetState extends State<ContentsSheet> {
  late Future<List<TocEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = TocService.instance.buildNotebookToc(widget.notebookId);
  }

  void _jump(TocEntry entry) {
    Navigator.pop(context);
    widget.onPageSelected(entry.pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  l10n.contentsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.contentsSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<TocEntry>>(
                  future: _entries,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = snapshot.data ?? const [];
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.contentsEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final entry = list[i];
                        final onPage = entry.pageIndex == widget.currentPageIndex;
                        return ListTile(
                          leading: Icon(
                            entry.source == TocSource.textBlock
                                ? Icons.text_fields_rounded
                                : Icons.draw_rounded,
                            color: onPage
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          title: Text(entry.title),
                          subtitle: Text(l10n.contentsPageNumber(entry.pageIndex + 1)),
                          trailing: onPage
                              ? Icon(
                                  Icons.my_location_rounded,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => _jump(entry),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
