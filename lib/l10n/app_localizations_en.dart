// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionBack => 'Back';

  @override
  String get actionDone => 'Done';

  @override
  String get actionSplit => 'Split';

  @override
  String get actionRecover => 'Recover';

  @override
  String get actionRestore => 'Restore';

  @override
  String get actionExport => 'Export';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionRetrying => 'Retrying…';

  @override
  String get actionExportFirst => 'Export first';

  @override
  String get actionEraseAll => 'Erase all';

  @override
  String get actionChangeSize => 'Change size';

  @override
  String get actionChangeOrientation => 'Change orientation';

  @override
  String get actionUseColor => 'Use color';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Overview';

  @override
  String get libraryTrash => 'Trash';

  @override
  String get librarySettings => 'Settings';

  @override
  String get libraryFolders => 'Folders';

  @override
  String get libraryNoFoldersYet => 'No folders yet';

  @override
  String get libraryAll => 'All';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Uncategorized';

  @override
  String get libraryBreadcrumb => 'Library';

  @override
  String get librarySearchHint =>
      'Search notebooks, tags, folders, and typed text…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'No matches';

  @override
  String get libraryFolderEmpty => 'This folder is empty';

  @override
  String get libraryNoNotebooksWithTag => 'No notebooks with this tag';

  @override
  String get libraryNoUncategorizedNotebooks => 'No uncategorized notebooks';

  @override
  String get libraryNoNotebooksYet => 'No notebooks yet';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Could not load library: $error';
  }

  @override
  String get tooltipBackupRestore => 'Backup & Restore';

  @override
  String get tooltipTrash => 'Trash';

  @override
  String get tooltipNewNotebook => 'New notebook';

  @override
  String get tooltipNewFolder => 'New folder';

  @override
  String get tooltipNewSubfolder => 'New subfolder';

  @override
  String get tooltipImportPdf => 'Import PDF';

  @override
  String get folderNew => 'New folder';

  @override
  String get folderNewSubfolder => 'New subfolder';

  @override
  String get folderRename => 'Rename folder';

  @override
  String get folderMoveToTrash => 'Move to Trash';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Move \"$name\" to Trash?';
  }

  @override
  String get folderMoveToTrashBody =>
      'The folder and its notebooks move to Trash for 30 days.';

  @override
  String get notebookNew => 'New notebook';

  @override
  String get notebookUntitled => 'Untitled';

  @override
  String get notebookTitleLabel => 'Title';

  @override
  String get notebookSizeLabel => 'Size';

  @override
  String get notebookPaperLabel => 'Paper';

  @override
  String get notebookCoverLabel => 'Cover';

  @override
  String get notebookRename => 'Rename notebook';

  @override
  String get notebookMoveToFolder => 'Move to folder';

  @override
  String get notebookEditTags => 'Edit tags';

  @override
  String get notebookExportWorkbook => 'Export workbook';

  @override
  String get notebookExportWorkbookSubtitle => 'Share all pages as PDF';

  @override
  String get notebookMoveToTrash => 'Move to Trash';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Move \"$title\" to Trash?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'The notebook is hidden from the library for 30 days. Ink and pages stay on this device until Trash is emptied. Export a backup first if you want an extra copy.';

  @override
  String notebookTagsFor(String title) {
    return 'Tags for \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'No tags yet. Create one below.';

  @override
  String get notebookNewTag => 'New tag';

  @override
  String get notebookAddTag => 'Add tag';

  @override
  String get notebookNoPagesToExport => 'This notebook has no pages to export';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" exported as PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Backup exported. You can move to Trash when ready.';

  @override
  String get importPdfSnack =>
      'Importing PDF… pages render once, then stay offline.';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Recovery failed: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Downloading handwriting model (~$sizeMb MB) in background…';
  }

  @override
  String get templateBlank => 'Blank';

  @override
  String get templateLined => 'Lined';

  @override
  String get templateGrid => 'Grid';

  @override
  String get templateDotted => 'Dotted';

  @override
  String get templateCollegeRuled => 'College ruled';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Portrait';

  @override
  String get orientationLandscape => 'Landscape';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Appearance & Preferences';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get settingsAppearanceDarkMode => 'Dark mode';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Choose light, dark, or match your device (default system)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsSectionPreferences => 'Preferences';

  @override
  String get settingsLanguageLabel => 'App language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get languageFrench => 'French';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get settingsSectionToolbar => 'Toolbar';

  @override
  String get settingsToolbarReorderHint =>
      'Drag to reorder drawing tools. Undo and redo stay fixed on the right.';

  @override
  String get settingsResetToolbarOrder => 'Reset toolbar order';

  @override
  String get settingsSectionNotebook => 'Notebook';

  @override
  String get settingsPageTurnMode => 'Page-turn mode';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Swipe one page at a time instead of continuous scroll (default off)';

  @override
  String get settingsZoomNavigation => 'Zoom navigation';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Pinch to zoom and pan on pages (default on)';

  @override
  String get settingsSectionDrawing => 'Drawing';

  @override
  String get settingsStrokeSmoothing => 'Stroke smoothing';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Smooth ink strokes with Chaikin corner-cutting (default on)';

  @override
  String get settingsStrokeSmoothingStrength => 'Smoothing strength';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — lower keeps finer detail; recommended $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Finger drawing';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Draw with finger on paper; when off, only stylus draws (default off)';

  @override
  String get settingsGestureInkEditing => 'Gesture ink editing';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Scratch over OCR-indexed ink to erase it (default on)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Hold the S Pen side button to temporarily switch tools. Release to restore your previous tool. Works on Samsung devices with barrel-button support.';

  @override
  String get settingsSpenBarrelAction => 'Barrel button action';

  @override
  String get settingsSectionOcrDictionary => 'OCR dictionary';

  @override
  String get settingsOcrDictionaryHint =>
      'Domain terms for handwriting OCR. Close matches are corrected when ink is indexed, and terms boost notebook search.';

  @override
  String get settingsNoCustomOcrTerms => 'No custom terms yet.';

  @override
  String get settingsRemoveOcrTerm => 'Remove term';

  @override
  String get settingsAddOcrTerm => 'Add term';

  @override
  String get settingsAddOcrTermTitle => 'Add OCR term';

  @override
  String get settingsOcrTermLabel => 'Term';

  @override
  String get settingsOcrTermHint => 'e.g. eigenvalue, mitochondria';

  @override
  String get settingsSectionYourData => 'Your data';

  @override
  String get settingsYourDataHint =>
      'Your notes live on this device in a SQLite database and asset folders — not in a cloud account. No sync server, no telemetry. Export or back up whenever you choose. See docs/ARCHITECTURE.md for the on-device file layout.';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsSectionBackupRestore => 'Backup & Restore';

  @override
  String get settingsBackupRestoreHint =>
      'Export a zip of penfold.db and asset folders, or restore from a previous backup. Your current database is saved to backups/ before restore.';

  @override
  String get settingsExportBackup => 'Export backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Zip penfold.db, PDF sources, images, and legacy PDF pages';

  @override
  String get settingsRecoverFromBackup => 'Recover from backup';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Latest auto-backup: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Restore backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Replace local data from a Penfold backup zip';

  @override
  String get settingsRecoverAutoBackupTitle => 'Recover from auto-backup?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'This replaces your current notebooks and files with the backup from $timestamp. Your current database will be saved to backups/ before restore.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Restore backup?';

  @override
  String get settingsRestoreBackupBody =>
      'This replaces your current notebooks and files. Your current database will be saved to backups/ before restore.';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String get settingsAboutSubtitle =>
      'Your notes stay on your device — no account, works offline, no cloud sync.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get spenActionEraser => 'Eraser';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Pen';

  @override
  String get spenActionNone => 'None';

  @override
  String get toolPen => 'Pen';

  @override
  String get toolHighlighter => 'Highlighter';

  @override
  String get toolTape => 'Tape';

  @override
  String get toolEraser => 'Eraser';

  @override
  String get toolSelection => 'Selection';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Shape';

  @override
  String get toolFill => 'Fill';

  @override
  String get toolText => 'Text';

  @override
  String get toolInsertImage => 'Insert image';

  @override
  String get brushPen => 'Pen';

  @override
  String get brushFountain => 'Fountain';

  @override
  String get brushPencil => 'Pencil';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Calligraphy';

  @override
  String get toolbarPreviousBookmark => 'Previous bookmark';

  @override
  String get toolbarNextBookmark => 'Next bookmark';

  @override
  String get toolbarConvertToText => 'Convert to text';

  @override
  String get toolbarCopy => 'Copy';

  @override
  String get toolbarDelete => 'Delete';

  @override
  String get toolbarPaste => 'Paste';

  @override
  String get toolbarUndo => 'Undo';

  @override
  String get toolbarRedo => 'Redo';

  @override
  String get toolbarAddPage => 'Add page';

  @override
  String get toolbarStylusOnly => 'Stylus-only (palm rejection)';

  @override
  String get toolbarFingerDrawing => 'Finger drawing';

  @override
  String get toolbarPageOverview => 'Page overview';

  @override
  String get toolbarTableOfContents => 'Table of contents';

  @override
  String get toolbarPageMenu => 'Page menu';

  @override
  String get penOptionsTitle => 'Pen';

  @override
  String get highlighterOptionsTitle => 'Highlighter';

  @override
  String get brushLabel => 'Brush';

  @override
  String get colorLabel => 'Color';

  @override
  String get customColorTitle => 'Custom color';

  @override
  String get hueLabel => 'Hue';

  @override
  String get saturationLabel => 'Saturation';

  @override
  String get brightnessLabel => 'Brightness';

  @override
  String get colorPickerModeHsv => 'HSV';

  @override
  String get colorPickerModeRgb => 'RGB';

  @override
  String get colorPickerModeHex => 'Hex';

  @override
  String get redLabel => 'Red';

  @override
  String get greenLabel => 'Green';

  @override
  String get blueLabel => 'Blue';

  @override
  String get hexLabel => 'Hex';

  @override
  String get hexHint => '#RRGGBB';

  @override
  String get tapeOptionsTitle => 'Tape';

  @override
  String get tapeOptionsHint => 'Draw to cover notes; tap tape to remove it';

  @override
  String get fillColorTitle => 'Fill color';

  @override
  String get fillOptionsHint =>
      'Draw a closed loop, or tap inside a shape to fill';

  @override
  String get eraserSizeTitle => 'Eraser size';

  @override
  String get eraserModeTitle => 'Eraser mode';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Stroke';

  @override
  String get eraserModePartialHint => 'Erases only ink under the eraser circle';

  @override
  String get eraserModeWholeStrokeHint => 'Erases whole strokes it touches';

  @override
  String get eraseAllOnPageTitle => 'Erase all on page?';

  @override
  String get eraseAllOnPageBody =>
      'This removes every stroke on the current page. You can undo this action.';

  @override
  String get eraseAllOnPageButton => 'Erase all on page';

  @override
  String get pageSettingsTitle => 'Page settings';

  @override
  String get pageColorTitle => 'Page color';

  @override
  String get pageThemeTitle => 'Page theme';

  @override
  String get defaultPaperSize => 'Default paper size';

  @override
  String get defaultPaperType => 'Default paper type';

  @override
  String get defaultPageTheme => 'Default page theme';

  @override
  String get notebookDefaultsHint =>
      'Used when you create a new notebook. You can still change choices in the dialog.';

  @override
  String get pageThemeLight => 'Light';

  @override
  String get pageThemeDark => 'Dark';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastel pink';

  @override
  String get pageThemePastelBlue => 'Pastel blue';

  @override
  String get pageThemePastelMint => 'Pastel mint';

  @override
  String get pageSizeTitle => 'Page size';

  @override
  String get pageOrientationTitle => 'Orientation';

  @override
  String get pageTemplateTitle => 'Page template';

  @override
  String get pageBookmark => 'Bookmark';

  @override
  String get pageRemoveBookmark => 'Remove bookmark';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Split';

  @override
  String get pageExportTitle => 'Export';

  @override
  String get pdfPagesKeepBackground =>
      'PDF pages keep their document background';

  @override
  String get pdfPagesKeepDimensions =>
      'PDF pages keep their document dimensions';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF pages keep their document orientation';

  @override
  String get exportPageAsPng => 'Export page as PNG';

  @override
  String get exportPageAsPngSubtitle => 'Share image of this page';

  @override
  String get exportPageAsPdf => 'Export page as PDF';

  @override
  String get exportPageAsPdfSubtitle => 'Vector ink, share via system sheet';

  @override
  String get exportNotebookAsPdf => 'Export notebook as PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Attach audio file';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV, and other local formats';

  @override
  String get pageAudioAttachedToPage => 'Attached to this page';

  @override
  String get pageAudioReplace => 'Replace audio file';

  @override
  String get pageAudioRemove => 'Remove audio';

  @override
  String get pageAudioPlay => 'Play';

  @override
  String get pageAudioPause => 'Pause';

  @override
  String get contentsTitle => 'Contents';

  @override
  String get contentsSubtitle => 'Headings from typed text and OCR-indexed ink';

  @override
  String get contentsEmpty =>
      'No headings found yet.\nAdd large or short typed text, or OCR-indexed ink headings.';

  @override
  String contentsPageNumber(int number) {
    return 'Page $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Pages';

  @override
  String pageOverviewSelected(int count) {
    return '$count selected';
  }

  @override
  String get pageOverviewDeleteSelected => 'Delete selected';

  @override
  String get pageOverviewSelectPages => 'Select pages';

  @override
  String get pageOverviewKeepOnePage => 'Keep at least one page';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return 'Delete $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'This cannot be undone.';

  @override
  String get pageOverviewDragToReorder => 'Drag to reorder';

  @override
  String get pageOverviewBookmarked => 'Bookmarked';

  @override
  String get ocrIndexing => 'OCR indexing…';

  @override
  String get ocrHandwritingSearchable => 'Handwriting searchable';

  @override
  String get ocrPartial => 'OCR partial';

  @override
  String get trashTitle => 'Trash';

  @override
  String trashFailedToLoad(String error) {
    return 'Failed to load Trash: $error';
  }

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get trashSectionFolders => 'Folders';

  @override
  String get trashSectionNotebooks => 'Notebooks';

  @override
  String get trashDeletionDateUnavailable => 'Deletion date unavailable';

  @override
  String get trashExpiresToday => 'Expires today';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days remaining',
      one: '1 day remaining',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restore';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Delete \"$title\" permanently?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'This removes the notebook and all pages from this device.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Delete \"$name\" permanently?';
  }

  @override
  String get trashDeleteFolderBody =>
      'This removes the folder and its notebooks from this device.';

  @override
  String get splitPageTitle => 'Split page?';

  @override
  String splitPageBody(int count) {
    return 'Create a new page with the same template and move about half of the $count strokes onto it.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Need at least 2 strokes to split this page';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Page split: $moved strokes moved, $remaining remain';
  }

  @override
  String splitPageFailed(String error) {
    return 'Split failed: $error';
  }

  @override
  String get splitPageAction => 'Split page';

  @override
  String get changePageSizeTitle => 'Change page size?';

  @override
  String get changePageSizeBody =>
      'This page has ink. Changing the size will re-layout the page; your ink stays in the same position on the page.';

  @override
  String get changeOrientationTitle => 'Change orientation?';

  @override
  String get changeOrientationBody =>
      'This page has ink. Changing orientation scales and centers your content to fit the new page bounds.';

  @override
  String convertedToText(String preview) {
    return 'Converted to text: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => 'Could not recognize handwriting';

  @override
  String get handwritingModelTitle => 'Handwriting model';

  @override
  String get handwritingModelDownloadFailed =>
      'Download failed. Check network and retry.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Downloading English handwriting model (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Model ready.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Elapsed: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'First-time download (~$sizeMb MB). Usually finishes in under two minutes on Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Page exported as PNG';

  @override
  String get pageExportedAsPdf => 'Page exported as PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Notebook exported as PDF';

  @override
  String get exportPreparing => 'Preparing export…';

  @override
  String exportProgress(int current, int total) {
    return 'Exporting page $current of $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'This page has $count strokes and may feel slow. Consider splitting it for better performance.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Export blocked: a page has $count strokes (limit $limit). Split heavy pages first.';
  }

  @override
  String get restoreComplete =>
      'Restore complete. Please restart the app to load the restored data.';

  @override
  String get textToolHint => 'Type here…';

  @override
  String get textToolDone => 'Done';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languagePolish => 'Polish';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageUkrainian => 'Ukrainian';

  @override
  String get languageSwedish => 'Swedish';

  @override
  String get languageNorwegian => 'Norwegian';

  @override
  String get languageFinnish => 'Finnish';

  @override
  String get languageDanish => 'Danish';

  @override
  String get languagePortuguese => 'Portuguese';
}
