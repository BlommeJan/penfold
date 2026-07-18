import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/models.dart';
import '../../services/notebook_defaults_service.dart';
import 'settings_section.dart';

/// Preferences pickers for default notebook paper size, type, and page theme.
class NotebookDefaultsSection extends StatefulWidget {
  const NotebookDefaultsSection({super.key});

  @override
  State<NotebookDefaultsSection> createState() =>
      _NotebookDefaultsSectionState();
}

class _NotebookDefaultsSectionState extends State<NotebookDefaultsSection> {
  final _service = NotebookDefaultsService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onDefaultsChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onDefaultsChanged);
    super.dispose();
  }

  void _onDefaultsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final defaults = _service.defaults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSubsection(title: l10n.settingsSectionPreferences),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.notebookDefaultsHint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SettingsSubsection(title: l10n.defaultPaperSize),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final size in PageSize.values)
                _ChoiceChip(
                  label: l10n.pageSizeLabel(size),
                  selected: defaults.pageSize == size,
                  onSelected: () => _service.setPageSize(size),
                ),
            ],
          ),
        ),
        SettingsSubsection(title: l10n.defaultPaperType),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final template in PageTemplate.values)
                _ChoiceChip(
                  label: l10n.pageTemplateShortLabel(template),
                  selected: defaults.template == template,
                  onSelected: () => _service.setTemplate(template),
                ),
            ],
          ),
        ),
        SettingsSubsection(title: l10n.defaultPageTheme),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final theme in PageBackgroundTheme.values)
                _ThemeSwatch(
                  theme: theme,
                  label: l10n.pageBackgroundThemeLabel(theme),
                  selected: defaults.backgroundTheme == theme,
                  onTap: () => _service.setBackgroundTheme(theme),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final PageBackgroundTheme theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.paperColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: selected ? 2.5 : 1,
                  color: selected ? scheme.primary : scheme.outlineVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared swatch row for per-page theme pickers.
class PageBackgroundThemePickerRow extends StatelessWidget {
  const PageBackgroundThemePickerRow({
    super.key,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final PageBackgroundTheme selected;
  final ValueChanged<PageBackgroundTheme> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final theme in PageBackgroundTheme.values)
          Opacity(
            opacity: enabled ? 1 : 0.45,
            child: _ThemeSwatch(
              theme: theme,
              label: l10n.pageBackgroundThemeLabel(theme),
              selected: selected == theme,
              onTap: enabled ? () => onSelected(theme) : () {},
            ),
          ),
      ],
    );
  }
}
