import '../models/models.dart';
import '../services/page_complexity_service.dart';
import '../services/spen_button_service.dart';
import '../services/toolbar_order_service.dart';
import 'app_localizations.dart';

/// Localized labels for enums and toolbar IDs (no BuildContext required).
extension AppLocalizationsLabels on AppLocalizations {
  String pageTemplateLabel(PageTemplate template) => switch (template) {
        PageTemplate.blank => templateBlank,
        PageTemplate.lined => templateLined,
        PageTemplate.grid => templateGrid,
        PageTemplate.dotted => templateDotted,
        PageTemplate.collegeRuled => templateCollegeRuled,
      };

  String pageTemplateShortLabel(PageTemplate template) => switch (template) {
        PageTemplate.blank => templateBlank,
        PageTemplate.lined => templateLined,
        PageTemplate.grid => templateGrid,
        PageTemplate.dotted => templateDotted,
        PageTemplate.collegeRuled => templateCollegeShort,
      };

  String pageSizeLabel(PageSize pageSize) => switch (pageSize) {
        PageSize.a4 => pageSizeA4,
        PageSize.a5 => pageSizeA5,
        PageSize.letter => pageSizeLetter,
      };

  String pageOrientationLabel(PageOrientation orientation) =>
      switch (orientation) {
        PageOrientation.portrait => orientationPortrait,
        PageOrientation.landscape => orientationLandscape,
      };

  String pageBackgroundThemeLabel(PageBackgroundTheme theme) =>
      switch (theme) {
        PageBackgroundTheme.light => pageThemeLight,
        PageBackgroundTheme.dark => pageThemeDark,
        PageBackgroundTheme.sepia => pageThemeSepia,
        PageBackgroundTheme.pastelPink => pageThemePastelPink,
        PageBackgroundTheme.pastelBlue => pageThemePastelBlue,
        PageBackgroundTheme.pastelMint => pageThemePastelMint,
      };

  String toolbarToolLabel(String id) => switch (id) {
        ToolbarToolId.pen => toolPen,
        ToolbarToolId.highlighter => toolHighlighter,
        ToolbarToolId.tape => toolTape,
        ToolbarToolId.eraser => toolEraser,
        ToolbarToolId.selection => toolSelection,
        ToolbarToolId.lasso => toolLasso,
        ToolbarToolId.shape => toolShape,
        ToolbarToolId.fill => toolFill,
        ToolbarToolId.text => toolText,
        ToolbarToolId.insertImage => toolInsertImage,
        _ => id,
      };

  String brushStyleLabel(BrushStyle style) => switch (style) {
        BrushStyle.pen => brushPen,
        BrushStyle.fountainPen => brushFountain,
        BrushStyle.pencil => brushPencil,
        BrushStyle.marker => brushMarker,
        BrushStyle.calligraphy => brushCalligraphy,
      };

  String spenBarrelActionLabel(SpenBarrelAction action) => switch (action) {
        SpenBarrelAction.eraser => spenActionEraser,
        SpenBarrelAction.lasso => spenActionLasso,
        SpenBarrelAction.pen => spenActionPen,
        SpenBarrelAction.none => spenActionNone,
      };

  String pageSettingsSummary(NotePage page, {required bool isPdfPage}) {
    if (isPdfPage) {
      return '$pdfLabel$settingsSummarySeparator${pageOrientationLabel(page.orientation)}';
    }
    return '${pageTemplateLabel(page.template)}$settingsSummarySeparator'
        '${pageSizeLabel(page.pageSize)}$settingsSummarySeparator'
        '${pageOrientationLabel(page.orientation)}';
  }

  String pageComplexityWarningMessage(int strokeCount) =>
      pageComplexityWarning(strokeCount);

  String pageComplexityExportBlockedMessage(int strokeCount) =>
      pageComplexityExportBlocked(
        strokeCount,
        PageComplexityService.strokeExportBlockThreshold,
      );
}
