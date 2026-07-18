import 'package:flutter/material.dart';

/// Consistent section header styling for the settings screen.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    this.subtitle,
    this.showDividerBefore = false,
    this.topPadding = 20,
  });

  final String title;
  final String? subtitle;
  final bool showDividerBefore;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showDividerBefore) const Divider(height: 32),
        Padding(
          padding: EdgeInsets.fromLTRB(16, showDividerBefore ? 0 : topPadding, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(subtitle!, style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}

/// Smaller subsection header within a settings group.
class SettingsSubsection extends StatelessWidget {
  const SettingsSubsection({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
