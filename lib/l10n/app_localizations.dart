import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Penfold'**
  String get appTitle;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionSplit.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get actionSplit;

  /// No description provided for @actionRecover.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get actionRecover;

  /// No description provided for @actionRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get actionRestore;

  /// No description provided for @actionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get actionExport;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying…'**
  String get actionRetrying;

  /// No description provided for @actionExportFirst.
  ///
  /// In en, this message translates to:
  /// **'Export first'**
  String get actionExportFirst;

  /// No description provided for @actionEraseAll.
  ///
  /// In en, this message translates to:
  /// **'Erase all'**
  String get actionEraseAll;

  /// No description provided for @actionChangeSize.
  ///
  /// In en, this message translates to:
  /// **'Change size'**
  String get actionChangeSize;

  /// No description provided for @actionChangeOrientation.
  ///
  /// In en, this message translates to:
  /// **'Change orientation'**
  String get actionChangeOrientation;

  /// No description provided for @actionUseColor.
  ///
  /// In en, this message translates to:
  /// **'Use color'**
  String get actionUseColor;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Penfold'**
  String get libraryTitle;

  /// No description provided for @libraryOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get libraryOverview;

  /// No description provided for @libraryTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get libraryTrash;

  /// No description provided for @librarySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get librarySettings;

  /// No description provided for @libraryFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get libraryFolders;

  /// No description provided for @libraryNoFoldersYet.
  ///
  /// In en, this message translates to:
  /// **'No folders yet'**
  String get libraryNoFoldersYet;

  /// No description provided for @libraryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get libraryAll;

  /// No description provided for @libraryUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get libraryUncategorized;

  /// No description provided for @libraryBreadcrumb.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryBreadcrumb;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notebooks and typed text…'**
  String get librarySearchHint;

  /// No description provided for @libraryNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get libraryNoMatches;

  /// No description provided for @libraryFolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get libraryFolderEmpty;

  /// No description provided for @libraryNoNotebooksWithTag.
  ///
  /// In en, this message translates to:
  /// **'No notebooks with this tag'**
  String get libraryNoNotebooksWithTag;

  /// No description provided for @libraryNoUncategorizedNotebooks.
  ///
  /// In en, this message translates to:
  /// **'No uncategorized notebooks'**
  String get libraryNoUncategorizedNotebooks;

  /// No description provided for @libraryNoNotebooksYet.
  ///
  /// In en, this message translates to:
  /// **'No notebooks yet'**
  String get libraryNoNotebooksYet;

  /// No description provided for @libraryCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load library: {error}'**
  String libraryCouldNotLoad(String error);

  /// No description provided for @tooltipBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get tooltipBackupRestore;

  /// No description provided for @tooltipTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get tooltipTrash;

  /// No description provided for @tooltipNewNotebook.
  ///
  /// In en, this message translates to:
  /// **'New notebook'**
  String get tooltipNewNotebook;

  /// No description provided for @tooltipNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get tooltipNewFolder;

  /// No description provided for @tooltipNewSubfolder.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get tooltipNewSubfolder;

  /// No description provided for @tooltipImportPdf.
  ///
  /// In en, this message translates to:
  /// **'Import PDF'**
  String get tooltipImportPdf;

  /// No description provided for @folderNew.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get folderNew;

  /// No description provided for @folderNewSubfolder.
  ///
  /// In en, this message translates to:
  /// **'New subfolder'**
  String get folderNewSubfolder;

  /// No description provided for @folderRename.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get folderRename;

  /// No description provided for @folderMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get folderMoveToTrash;

  /// No description provided for @folderMoveToTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Move \"{name}\" to Trash?'**
  String folderMoveToTrashTitle(String name);

  /// No description provided for @folderMoveToTrashBody.
  ///
  /// In en, this message translates to:
  /// **'The folder and its notebooks move to Trash for 30 days.'**
  String get folderMoveToTrashBody;

  /// No description provided for @notebookNew.
  ///
  /// In en, this message translates to:
  /// **'New notebook'**
  String get notebookNew;

  /// No description provided for @notebookUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get notebookUntitled;

  /// No description provided for @notebookTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notebookTitleLabel;

  /// No description provided for @notebookSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get notebookSizeLabel;

  /// No description provided for @notebookPaperLabel.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get notebookPaperLabel;

  /// No description provided for @notebookCoverLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get notebookCoverLabel;

  /// No description provided for @notebookRename.
  ///
  /// In en, this message translates to:
  /// **'Rename notebook'**
  String get notebookRename;

  /// No description provided for @notebookMoveToFolder.
  ///
  /// In en, this message translates to:
  /// **'Move to folder'**
  String get notebookMoveToFolder;

  /// No description provided for @notebookEditTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get notebookEditTags;

  /// No description provided for @notebookExportWorkbook.
  ///
  /// In en, this message translates to:
  /// **'Export workbook'**
  String get notebookExportWorkbook;

  /// No description provided for @notebookExportWorkbookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share all pages as PDF'**
  String get notebookExportWorkbookSubtitle;

  /// No description provided for @notebookMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get notebookMoveToTrash;

  /// No description provided for @notebookMoveToTrashTitle.
  ///
  /// In en, this message translates to:
  /// **'Move \"{title}\" to Trash?'**
  String notebookMoveToTrashTitle(String title);

  /// No description provided for @notebookMoveToTrashBody.
  ///
  /// In en, this message translates to:
  /// **'The notebook is hidden from the library for 30 days. Ink and pages stay on this device until Trash is emptied. Export a backup first if you want an extra copy.'**
  String get notebookMoveToTrashBody;

  /// No description provided for @notebookTagsFor.
  ///
  /// In en, this message translates to:
  /// **'Tags for \"{title}\"'**
  String notebookTagsFor(String title);

  /// No description provided for @notebookNoTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Create one below.'**
  String get notebookNoTagsYet;

  /// No description provided for @notebookNewTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get notebookNewTag;

  /// No description provided for @notebookAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get notebookAddTag;

  /// No description provided for @notebookNoPagesToExport.
  ///
  /// In en, this message translates to:
  /// **'This notebook has no pages to export'**
  String get notebookNoPagesToExport;

  /// No description provided for @notebookExportedAsPdf.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" exported as PDF'**
  String notebookExportedAsPdf(String title);

  /// No description provided for @notebookBackupExportedReady.
  ///
  /// In en, this message translates to:
  /// **'Backup exported. You can move to Trash when ready.'**
  String get notebookBackupExportedReady;

  /// No description provided for @importPdfSnack.
  ///
  /// In en, this message translates to:
  /// **'Importing PDF… pages render once, then stay offline.'**
  String get importPdfSnack;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @recoveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Recovery failed: {error}'**
  String recoveryFailed(String error);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @handwritingModelDownloadingBackground.
  ///
  /// In en, this message translates to:
  /// **'Downloading handwriting model (~{sizeMb} MB) in background…'**
  String handwritingModelDownloadingBackground(int sizeMb);

  /// No description provided for @templateBlank.
  ///
  /// In en, this message translates to:
  /// **'Blank'**
  String get templateBlank;

  /// No description provided for @templateLined.
  ///
  /// In en, this message translates to:
  /// **'Lined'**
  String get templateLined;

  /// No description provided for @templateGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get templateGrid;

  /// No description provided for @templateDotted.
  ///
  /// In en, this message translates to:
  /// **'Dotted'**
  String get templateDotted;

  /// No description provided for @templateCollegeRuled.
  ///
  /// In en, this message translates to:
  /// **'College ruled'**
  String get templateCollegeRuled;

  /// No description provided for @templateCollegeShort.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get templateCollegeShort;

  /// No description provided for @pageSizeA4.
  ///
  /// In en, this message translates to:
  /// **'A4'**
  String get pageSizeA4;

  /// No description provided for @pageSizeA5.
  ///
  /// In en, this message translates to:
  /// **'A5'**
  String get pageSizeA5;

  /// No description provided for @pageSizeLetter.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get pageSizeLetter;

  /// No description provided for @orientationPortrait.
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get orientationPortrait;

  /// No description provided for @orientationLandscape.
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get orientationLandscape;

  /// No description provided for @pdfLabel.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfLabel;

  /// No description provided for @settingsSummarySeparator.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get settingsSummarySeparator;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @settingsSectionAppearanceAndPreferences.
  ///
  /// In en, this message translates to:
  /// **'Appearance & Preferences'**
  String get settingsSectionAppearanceAndPreferences;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsAppearanceDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settingsAppearanceDarkMode;

  /// No description provided for @settingsAppearanceDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose light, dark, or match your device (default system)'**
  String get settingsAppearanceDarkModeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsSectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsSectionPreferences;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageLabel;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @settingsSectionToolbar.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get settingsSectionToolbar;

  /// No description provided for @settingsToolbarReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder drawing tools. Undo and redo stay fixed on the right.'**
  String get settingsToolbarReorderHint;

  /// No description provided for @settingsResetToolbarOrder.
  ///
  /// In en, this message translates to:
  /// **'Reset toolbar order'**
  String get settingsResetToolbarOrder;

  /// No description provided for @settingsSectionNotebook.
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get settingsSectionNotebook;

  /// No description provided for @settingsPageTurnMode.
  ///
  /// In en, this message translates to:
  /// **'Page-turn mode'**
  String get settingsPageTurnMode;

  /// No description provided for @settingsPageTurnModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe one page at a time instead of continuous scroll (default off)'**
  String get settingsPageTurnModeSubtitle;

  /// No description provided for @settingsZoomNavigation.
  ///
  /// In en, this message translates to:
  /// **'Zoom navigation'**
  String get settingsZoomNavigation;

  /// No description provided for @settingsZoomNavigationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom and pan on pages (default on)'**
  String get settingsZoomNavigationSubtitle;

  /// No description provided for @settingsSectionDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing'**
  String get settingsSectionDrawing;

  /// No description provided for @settingsStrokeSmoothing.
  ///
  /// In en, this message translates to:
  /// **'Stroke smoothing'**
  String get settingsStrokeSmoothing;

  /// No description provided for @settingsStrokeSmoothingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smooth ink strokes with Chaikin corner-cutting (default on)'**
  String get settingsStrokeSmoothingSubtitle;

  /// No description provided for @settingsStrokeSmoothingStrength.
  ///
  /// In en, this message translates to:
  /// **'Smoothing strength'**
  String get settingsStrokeSmoothingStrength;

  /// No description provided for @settingsStrokeSmoothingStrengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{percent}% — lower keeps finer detail; recommended {recommended}%'**
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended);

  /// No description provided for @settingsFingerDrawing.
  ///
  /// In en, this message translates to:
  /// **'Finger drawing'**
  String get settingsFingerDrawing;

  /// No description provided for @settingsFingerDrawingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draw with finger on paper; when off, only stylus draws (default off)'**
  String get settingsFingerDrawingSubtitle;

  /// No description provided for @settingsGestureInkEditing.
  ///
  /// In en, this message translates to:
  /// **'Gesture ink editing'**
  String get settingsGestureInkEditing;

  /// No description provided for @settingsGestureInkEditingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scratch over OCR-indexed ink to erase it (default on)'**
  String get settingsGestureInkEditingSubtitle;

  /// No description provided for @settingsSectionSpen.
  ///
  /// In en, this message translates to:
  /// **'S Pen'**
  String get settingsSectionSpen;

  /// No description provided for @settingsSpenHint.
  ///
  /// In en, this message translates to:
  /// **'Hold the S Pen side button to temporarily switch tools. Release to restore your previous tool. Works on Samsung devices with barrel-button support.'**
  String get settingsSpenHint;

  /// No description provided for @settingsSpenBarrelAction.
  ///
  /// In en, this message translates to:
  /// **'Barrel button action'**
  String get settingsSpenBarrelAction;

  /// No description provided for @settingsSectionOcrDictionary.
  ///
  /// In en, this message translates to:
  /// **'OCR dictionary'**
  String get settingsSectionOcrDictionary;

  /// No description provided for @settingsOcrDictionaryHint.
  ///
  /// In en, this message translates to:
  /// **'Domain terms for handwriting OCR. Close matches are corrected when ink is indexed, and terms boost notebook search.'**
  String get settingsOcrDictionaryHint;

  /// No description provided for @settingsNoCustomOcrTerms.
  ///
  /// In en, this message translates to:
  /// **'No custom terms yet.'**
  String get settingsNoCustomOcrTerms;

  /// No description provided for @settingsRemoveOcrTerm.
  ///
  /// In en, this message translates to:
  /// **'Remove term'**
  String get settingsRemoveOcrTerm;

  /// No description provided for @settingsAddOcrTerm.
  ///
  /// In en, this message translates to:
  /// **'Add term'**
  String get settingsAddOcrTerm;

  /// No description provided for @settingsAddOcrTermTitle.
  ///
  /// In en, this message translates to:
  /// **'Add OCR term'**
  String get settingsAddOcrTermTitle;

  /// No description provided for @settingsOcrTermLabel.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get settingsOcrTermLabel;

  /// No description provided for @settingsOcrTermHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. eigenvalue, mitochondria'**
  String get settingsOcrTermHint;

  /// No description provided for @settingsSectionYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get settingsSectionYourData;

  /// No description provided for @settingsYourDataHint.
  ///
  /// In en, this message translates to:
  /// **'Penfold stores everything on this device in a single SQLite database and asset folders — no cloud sync. See docs/ARCHITECTURE.md for the full on-device file layout.'**
  String get settingsYourDataHint;

  /// No description provided for @settingsDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get settingsDatabase;

  /// No description provided for @settingsSectionBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get settingsSectionBackupRestore;

  /// No description provided for @settingsBackupRestoreHint.
  ///
  /// In en, this message translates to:
  /// **'Export a zip of penfold.db and asset folders, or restore from a previous backup. Your current database is saved to backups/ before restore.'**
  String get settingsBackupRestoreHint;

  /// No description provided for @settingsExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExportBackup;

  /// No description provided for @settingsExportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Zip penfold.db, PDF sources, images, and legacy PDF pages'**
  String get settingsExportBackupSubtitle;

  /// No description provided for @settingsRecoverFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Recover from backup'**
  String get settingsRecoverFromBackup;

  /// No description provided for @settingsLatestAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Latest auto-backup: {timestamp} ({size})'**
  String settingsLatestAutoBackup(String timestamp, String size);

  /// No description provided for @settingsRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get settingsRestoreBackup;

  /// No description provided for @settingsRestoreBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replace local data from a Penfold backup zip'**
  String get settingsRestoreBackupSubtitle;

  /// No description provided for @settingsRecoverAutoBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover from auto-backup?'**
  String get settingsRecoverAutoBackupTitle;

  /// No description provided for @settingsRecoverAutoBackupBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces your current notebooks and files with the backup from {timestamp}. Your current database will be saved to backups/ before restore.'**
  String settingsRecoverAutoBackupBody(String timestamp);

  /// No description provided for @settingsRestoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get settingsRestoreBackupTitle;

  /// No description provided for @settingsRestoreBackupBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces your current notebooks and files. Your current database will be saved to backups/ before restore.'**
  String get settingsRestoreBackupBody;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local-first handwriting notebook — no accounts, no cloud.'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @spenActionEraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get spenActionEraser;

  /// No description provided for @spenActionLasso.
  ///
  /// In en, this message translates to:
  /// **'Lasso'**
  String get spenActionLasso;

  /// No description provided for @spenActionPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get spenActionPen;

  /// No description provided for @spenActionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get spenActionNone;

  /// No description provided for @toolPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get toolPen;

  /// No description provided for @toolHighlighter.
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get toolHighlighter;

  /// No description provided for @toolTape.
  ///
  /// In en, this message translates to:
  /// **'Tape'**
  String get toolTape;

  /// No description provided for @toolEraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get toolEraser;

  /// No description provided for @toolSelection.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get toolSelection;

  /// No description provided for @toolLasso.
  ///
  /// In en, this message translates to:
  /// **'Lasso'**
  String get toolLasso;

  /// No description provided for @toolShape.
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get toolShape;

  /// No description provided for @toolFill.
  ///
  /// In en, this message translates to:
  /// **'Fill'**
  String get toolFill;

  /// No description provided for @toolText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get toolText;

  /// No description provided for @toolInsertImage.
  ///
  /// In en, this message translates to:
  /// **'Insert image'**
  String get toolInsertImage;

  /// No description provided for @brushPen.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get brushPen;

  /// No description provided for @brushFountain.
  ///
  /// In en, this message translates to:
  /// **'Fountain'**
  String get brushFountain;

  /// No description provided for @brushPencil.
  ///
  /// In en, this message translates to:
  /// **'Pencil'**
  String get brushPencil;

  /// No description provided for @brushMarker.
  ///
  /// In en, this message translates to:
  /// **'Marker'**
  String get brushMarker;

  /// No description provided for @brushCalligraphy.
  ///
  /// In en, this message translates to:
  /// **'Calligraphy'**
  String get brushCalligraphy;

  /// No description provided for @toolbarPreviousBookmark.
  ///
  /// In en, this message translates to:
  /// **'Previous bookmark'**
  String get toolbarPreviousBookmark;

  /// No description provided for @toolbarNextBookmark.
  ///
  /// In en, this message translates to:
  /// **'Next bookmark'**
  String get toolbarNextBookmark;

  /// No description provided for @toolbarConvertToText.
  ///
  /// In en, this message translates to:
  /// **'Convert to text'**
  String get toolbarConvertToText;

  /// No description provided for @toolbarCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get toolbarCopy;

  /// No description provided for @toolbarDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get toolbarDelete;

  /// No description provided for @toolbarPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get toolbarPaste;

  /// No description provided for @toolbarUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get toolbarUndo;

  /// No description provided for @toolbarRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get toolbarRedo;

  /// No description provided for @toolbarAddPage.
  ///
  /// In en, this message translates to:
  /// **'Add page'**
  String get toolbarAddPage;

  /// No description provided for @toolbarStylusOnly.
  ///
  /// In en, this message translates to:
  /// **'Stylus-only (palm rejection)'**
  String get toolbarStylusOnly;

  /// No description provided for @toolbarFingerDrawing.
  ///
  /// In en, this message translates to:
  /// **'Finger drawing'**
  String get toolbarFingerDrawing;

  /// No description provided for @toolbarPageOverview.
  ///
  /// In en, this message translates to:
  /// **'Page overview'**
  String get toolbarPageOverview;

  /// No description provided for @toolbarTableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Table of contents'**
  String get toolbarTableOfContents;

  /// No description provided for @toolbarPageMenu.
  ///
  /// In en, this message translates to:
  /// **'Page menu'**
  String get toolbarPageMenu;

  /// No description provided for @penOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pen'**
  String get penOptionsTitle;

  /// No description provided for @highlighterOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get highlighterOptionsTitle;

  /// No description provided for @brushLabel.
  ///
  /// In en, this message translates to:
  /// **'Brush'**
  String get brushLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @customColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColorTitle;

  /// No description provided for @hueLabel.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hueLabel;

  /// No description provided for @saturationLabel.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturationLabel;

  /// No description provided for @brightnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightnessLabel;

  /// No description provided for @tapeOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tape'**
  String get tapeOptionsTitle;

  /// No description provided for @tapeOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Draw to cover notes; tap tape to reveal or hide again'**
  String get tapeOptionsHint;

  /// No description provided for @fillColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Fill color'**
  String get fillColorTitle;

  /// No description provided for @fillOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Draw a closed loop, or tap inside a shape to fill'**
  String get fillOptionsHint;

  /// No description provided for @eraserSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eraser size'**
  String get eraserSizeTitle;

  /// No description provided for @eraserModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Eraser mode'**
  String get eraserModeTitle;

  /// No description provided for @eraserModePixel.
  ///
  /// In en, this message translates to:
  /// **'Pixel'**
  String get eraserModePixel;

  /// No description provided for @eraserModeStroke.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get eraserModeStroke;

  /// No description provided for @eraserModePartialHint.
  ///
  /// In en, this message translates to:
  /// **'Erases only ink under the eraser circle'**
  String get eraserModePartialHint;

  /// No description provided for @eraserModeWholeStrokeHint.
  ///
  /// In en, this message translates to:
  /// **'Erases whole strokes it touches'**
  String get eraserModeWholeStrokeHint;

  /// No description provided for @eraseAllOnPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase all on page?'**
  String get eraseAllOnPageTitle;

  /// No description provided for @eraseAllOnPageBody.
  ///
  /// In en, this message translates to:
  /// **'This removes every stroke on the current page. You can undo this action.'**
  String get eraseAllOnPageBody;

  /// No description provided for @eraseAllOnPageButton.
  ///
  /// In en, this message translates to:
  /// **'Erase all on page'**
  String get eraseAllOnPageButton;

  /// No description provided for @pageSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Page settings'**
  String get pageSettingsTitle;

  /// No description provided for @pageColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Page color'**
  String get pageColorTitle;

  /// No description provided for @pageThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Page theme'**
  String get pageThemeTitle;

  /// No description provided for @defaultPaperSize.
  ///
  /// In en, this message translates to:
  /// **'Default paper size'**
  String get defaultPaperSize;

  /// No description provided for @defaultPaperType.
  ///
  /// In en, this message translates to:
  /// **'Default paper type'**
  String get defaultPaperType;

  /// No description provided for @defaultPageTheme.
  ///
  /// In en, this message translates to:
  /// **'Default page theme'**
  String get defaultPageTheme;

  /// No description provided for @notebookDefaultsHint.
  ///
  /// In en, this message translates to:
  /// **'Used when you create a new notebook. You can still change choices in the dialog.'**
  String get notebookDefaultsHint;

  /// No description provided for @pageThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get pageThemeLight;

  /// No description provided for @pageThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get pageThemeDark;

  /// No description provided for @pageThemeSepia.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get pageThemeSepia;

  /// No description provided for @pageThemePastelPink.
  ///
  /// In en, this message translates to:
  /// **'Pastel pink'**
  String get pageThemePastelPink;

  /// No description provided for @pageThemePastelBlue.
  ///
  /// In en, this message translates to:
  /// **'Pastel blue'**
  String get pageThemePastelBlue;

  /// No description provided for @pageThemePastelMint.
  ///
  /// In en, this message translates to:
  /// **'Pastel mint'**
  String get pageThemePastelMint;

  /// No description provided for @pageSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get pageSizeTitle;

  /// No description provided for @pageOrientationTitle.
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get pageOrientationTitle;

  /// No description provided for @pageTemplateTitle.
  ///
  /// In en, this message translates to:
  /// **'Page template'**
  String get pageTemplateTitle;

  /// No description provided for @pageBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get pageBookmark;

  /// No description provided for @pageRemoveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get pageRemoveBookmark;

  /// No description provided for @pageAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get pageAudioTitle;

  /// No description provided for @pageSplit.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get pageSplit;

  /// No description provided for @pageExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get pageExportTitle;

  /// No description provided for @pdfPagesKeepBackground.
  ///
  /// In en, this message translates to:
  /// **'PDF pages keep their document background'**
  String get pdfPagesKeepBackground;

  /// No description provided for @pdfPagesKeepDimensions.
  ///
  /// In en, this message translates to:
  /// **'PDF pages keep their document dimensions'**
  String get pdfPagesKeepDimensions;

  /// No description provided for @pdfPagesKeepOrientation.
  ///
  /// In en, this message translates to:
  /// **'PDF pages keep their document orientation'**
  String get pdfPagesKeepOrientation;

  /// No description provided for @exportPageAsPng.
  ///
  /// In en, this message translates to:
  /// **'Export page as PNG'**
  String get exportPageAsPng;

  /// No description provided for @exportPageAsPngSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share image of this page'**
  String get exportPageAsPngSubtitle;

  /// No description provided for @exportPageAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export page as PDF'**
  String get exportPageAsPdf;

  /// No description provided for @exportPageAsPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vector ink, share via system sheet'**
  String get exportPageAsPdfSubtitle;

  /// No description provided for @exportNotebookAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Export notebook as PDF'**
  String get exportNotebookAsPdf;

  /// No description provided for @exportNotebookPageCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String exportNotebookPageCount(int count);

  /// No description provided for @pageAudioAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach audio file'**
  String get pageAudioAttach;

  /// No description provided for @pageAudioAttachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MP3, M4A, WAV, and other local formats'**
  String get pageAudioAttachSubtitle;

  /// No description provided for @pageAudioAttachedToPage.
  ///
  /// In en, this message translates to:
  /// **'Attached to this page'**
  String get pageAudioAttachedToPage;

  /// No description provided for @pageAudioReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace audio file'**
  String get pageAudioReplace;

  /// No description provided for @pageAudioRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove audio'**
  String get pageAudioRemove;

  /// No description provided for @pageAudioPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get pageAudioPlay;

  /// No description provided for @pageAudioPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pageAudioPause;

  /// No description provided for @contentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get contentsTitle;

  /// No description provided for @contentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Headings from typed text and OCR-indexed ink'**
  String get contentsSubtitle;

  /// No description provided for @contentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No headings found yet.\nAdd large or short typed text, or OCR-indexed ink headings.'**
  String get contentsEmpty;

  /// No description provided for @contentsPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String contentsPageNumber(int number);

  /// No description provided for @pageOverviewPagesSuffix.
  ///
  /// In en, this message translates to:
  /// **' — Pages'**
  String get pageOverviewPagesSuffix;

  /// No description provided for @pageOverviewSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String pageOverviewSelected(int count);

  /// No description provided for @pageOverviewDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get pageOverviewDeleteSelected;

  /// No description provided for @pageOverviewSelectPages.
  ///
  /// In en, this message translates to:
  /// **'Select pages'**
  String get pageOverviewSelectPages;

  /// No description provided for @pageOverviewKeepOnePage.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one page'**
  String get pageOverviewKeepOnePage;

  /// No description provided for @pageOverviewDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count, plural, =1{1 page} other{{count} pages}}?'**
  String pageOverviewDeleteTitle(int count);

  /// No description provided for @pageOverviewDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get pageOverviewDeleteBody;

  /// No description provided for @pageOverviewDragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get pageOverviewDragToReorder;

  /// No description provided for @pageOverviewBookmarked.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get pageOverviewBookmarked;

  /// No description provided for @ocrIndexing.
  ///
  /// In en, this message translates to:
  /// **'OCR indexing…'**
  String get ocrIndexing;

  /// No description provided for @ocrHandwritingSearchable.
  ///
  /// In en, this message translates to:
  /// **'Handwriting searchable'**
  String get ocrHandwritingSearchable;

  /// No description provided for @ocrPartial.
  ///
  /// In en, this message translates to:
  /// **'OCR partial'**
  String get ocrPartial;

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Trash: {error}'**
  String trashFailedToLoad(String error);

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @trashSectionFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get trashSectionFolders;

  /// No description provided for @trashSectionNotebooks.
  ///
  /// In en, this message translates to:
  /// **'Notebooks'**
  String get trashSectionNotebooks;

  /// No description provided for @trashDeletionDateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Deletion date unavailable'**
  String get trashDeletionDateUnavailable;

  /// No description provided for @trashExpiresToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get trashExpiresToday;

  /// No description provided for @trashDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day remaining} other{{count} days remaining}}'**
  String trashDaysRemaining(int count);

  /// No description provided for @trashRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get trashRestore;

  /// No description provided for @trashDeleteNotebookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\" permanently?'**
  String trashDeleteNotebookTitle(String title);

  /// No description provided for @trashDeleteNotebookBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the notebook and all pages from this device.'**
  String get trashDeleteNotebookBody;

  /// No description provided for @trashDeleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" permanently?'**
  String trashDeleteFolderTitle(String name);

  /// No description provided for @trashDeleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the folder and its notebooks from this device.'**
  String get trashDeleteFolderBody;

  /// No description provided for @splitPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Split page?'**
  String get splitPageTitle;

  /// No description provided for @splitPageBody.
  ///
  /// In en, this message translates to:
  /// **'Create a new page with the same template and move about half of the {count} strokes onto it.'**
  String splitPageBody(int count);

  /// No description provided for @splitPageNeedStrokes.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 strokes to split this page'**
  String get splitPageNeedStrokes;

  /// No description provided for @splitPageSuccess.
  ///
  /// In en, this message translates to:
  /// **'Page split: {moved} strokes moved, {remaining} remain'**
  String splitPageSuccess(int moved, int remaining);

  /// No description provided for @splitPageFailed.
  ///
  /// In en, this message translates to:
  /// **'Split failed: {error}'**
  String splitPageFailed(String error);

  /// No description provided for @splitPageAction.
  ///
  /// In en, this message translates to:
  /// **'Split page'**
  String get splitPageAction;

  /// No description provided for @changePageSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change page size?'**
  String get changePageSizeTitle;

  /// No description provided for @changePageSizeBody.
  ///
  /// In en, this message translates to:
  /// **'This page has ink. Changing the size will re-layout the page; your ink stays in the same position on the page.'**
  String get changePageSizeBody;

  /// No description provided for @changeOrientationTitle.
  ///
  /// In en, this message translates to:
  /// **'Change orientation?'**
  String get changeOrientationTitle;

  /// No description provided for @changeOrientationBody.
  ///
  /// In en, this message translates to:
  /// **'This page has ink. Changing orientation scales and centers your content to fit the new page bounds.'**
  String get changeOrientationBody;

  /// No description provided for @convertedToText.
  ///
  /// In en, this message translates to:
  /// **'Converted to text: {preview}'**
  String convertedToText(String preview);

  /// No description provided for @couldNotRecognizeHandwriting.
  ///
  /// In en, this message translates to:
  /// **'Could not recognize handwriting'**
  String get couldNotRecognizeHandwriting;

  /// No description provided for @handwritingModelTitle.
  ///
  /// In en, this message translates to:
  /// **'Handwriting model'**
  String get handwritingModelTitle;

  /// No description provided for @handwritingModelDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check network and retry.'**
  String get handwritingModelDownloadFailed;

  /// No description provided for @handwritingModelDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading English handwriting model (~{sizeMb} MB)…'**
  String handwritingModelDownloading(int sizeMb);

  /// No description provided for @handwritingModelReady.
  ///
  /// In en, this message translates to:
  /// **'Model ready.'**
  String get handwritingModelReady;

  /// No description provided for @handwritingModelElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed: {elapsed}'**
  String handwritingModelElapsed(String elapsed);

  /// No description provided for @handwritingModelDownloadHint.
  ///
  /// In en, this message translates to:
  /// **'First-time download (~{sizeMb} MB). Usually finishes in under two minutes on Wi‑Fi.'**
  String handwritingModelDownloadHint(int sizeMb);

  /// No description provided for @pageExportedAsPng.
  ///
  /// In en, this message translates to:
  /// **'Page exported as PNG'**
  String get pageExportedAsPng;

  /// No description provided for @pageExportedAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Page exported as PDF'**
  String get pageExportedAsPdf;

  /// No description provided for @notebookExportedAsPdfSnack.
  ///
  /// In en, this message translates to:
  /// **'Notebook exported as PDF'**
  String get notebookExportedAsPdfSnack;

  /// No description provided for @exportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing export…'**
  String get exportPreparing;

  /// No description provided for @exportProgress.
  ///
  /// In en, this message translates to:
  /// **'Exporting page {current} of {total}…'**
  String exportProgress(int current, int total);

  /// No description provided for @pageComplexityWarning.
  ///
  /// In en, this message translates to:
  /// **'This page has {count} strokes and may feel slow. Consider splitting it for better performance.'**
  String pageComplexityWarning(int count);

  /// No description provided for @pageComplexityExportBlocked.
  ///
  /// In en, this message translates to:
  /// **'Export blocked: a page has {count} strokes (limit {limit}). Split heavy pages first.'**
  String pageComplexityExportBlocked(int count, int limit);

  /// No description provided for @restoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Restore complete. Please restart the app to load the restored data.'**
  String get restoreComplete;

  /// No description provided for @textToolHint.
  ///
  /// In en, this message translates to:
  /// **'Type here…'**
  String get textToolHint;

  /// No description provided for @textToolDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get textToolDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
