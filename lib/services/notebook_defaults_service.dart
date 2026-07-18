import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// User defaults applied when creating new notebooks and blank pages.
class NotebookDefaults {
  final PageSize pageSize;
  final PageTemplate template;
  final PageBackgroundTheme backgroundTheme;

  const NotebookDefaults({
    this.pageSize = PageSize.a4,
    this.template = PageTemplate.lined,
    this.backgroundTheme = PageBackgroundTheme.light,
  });

  NotebookDefaults copyWith({
    PageSize? pageSize,
    PageTemplate? template,
    PageBackgroundTheme? backgroundTheme,
  }) =>
      NotebookDefaults(
        pageSize: pageSize ?? this.pageSize,
        template: template ?? this.template,
        backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      );
}

/// Persists default notebook paper size, type, and page theme.
class NotebookDefaultsService extends ChangeNotifier {
  NotebookDefaultsService._();
  static final NotebookDefaultsService instance = NotebookDefaultsService._();

  static const pageSizeKey = 'notebook_default_page_size';
  static const templateKey = 'notebook_default_template';
  static const backgroundThemeKey = 'notebook_default_background_theme';

  NotebookDefaults _defaults = const NotebookDefaults();
  bool _loaded = false;

  NotebookDefaults get defaults => _defaults;
  bool get isLoaded => _loaded;

  PageSize get pageSize => _defaults.pageSize;
  PageTemplate get template => _defaults.template;
  PageBackgroundTheme get backgroundTheme => _defaults.backgroundTheme;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _defaults = NotebookDefaults(
      pageSize: PageSize.values[
          (prefs.getInt(pageSizeKey) ?? PageSize.a4.index)
              .clamp(0, PageSize.values.length - 1)],
      template: PageTemplate.values[
          (prefs.getInt(templateKey) ?? PageTemplate.lined.index)
              .clamp(0, PageTemplate.values.length - 1)],
      backgroundTheme: PageBackgroundTheme.fromIndex(
        prefs.getInt(backgroundThemeKey) ?? PageBackgroundTheme.light.index,
      ),
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDefaults(NotebookDefaults value) async {
    _defaults = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(pageSizeKey, value.pageSize.index);
    await prefs.setInt(templateKey, value.template.index);
    await prefs.setInt(backgroundThemeKey, value.backgroundTheme.index);
    notifyListeners();
  }

  Future<void> setPageSize(PageSize value) =>
      setDefaults(_defaults.copyWith(pageSize: value));

  Future<void> setTemplate(PageTemplate value) =>
      setDefaults(_defaults.copyWith(template: value));

  Future<void> setBackgroundTheme(PageBackgroundTheme value) =>
      setDefaults(_defaults.copyWith(backgroundTheme: value));

  /// Test hook: reset in-memory state without touching disk.
  @visibleForTesting
  void resetForTests() {
    _defaults = const NotebookDefaults();
    _loaded = false;
  }
}
