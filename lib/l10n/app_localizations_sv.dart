// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Avbryt';

  @override
  String get actionCreate => 'Skapa';

  @override
  String get actionRename => 'Byt namn';

  @override
  String get actionSave => 'Spara';

  @override
  String get actionDelete => 'Radera';

  @override
  String get actionAdd => 'Lägg till';

  @override
  String get actionBack => 'Tillbaka';

  @override
  String get actionDone => 'Klar';

  @override
  String get actionSplit => 'Dela';

  @override
  String get actionRecover => 'Återhämta';

  @override
  String get actionRestore => 'Återställ';

  @override
  String get actionExport => 'Exportera';

  @override
  String get actionRetry => 'Försök igen';

  @override
  String get actionRetrying => 'Försöker igen…';

  @override
  String get actionExportFirst => 'Exportera först';

  @override
  String get actionEraseAll => 'Radera allt';

  @override
  String get actionChangeSize => 'Ändra storlek';

  @override
  String get actionChangeOrientation => 'Ändra orientering';

  @override
  String get actionUseColor => 'Använd färg';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Översikt';

  @override
  String get libraryTrash => 'Papperskorg';

  @override
  String get librarySettings => 'Inställningar';

  @override
  String get libraryFolders => 'Mappar';

  @override
  String get libraryNoFoldersYet => 'Inga mappar ännu';

  @override
  String get libraryAll => 'Alla';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Okategoriserade';

  @override
  String get libraryBreadcrumb => 'Bibliotek';

  @override
  String get librarySearchHint => 'Sök i anteckningsböcker och inmatad text…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Inga träffar';

  @override
  String get libraryFolderEmpty => 'Den här mappen är tom';

  @override
  String get libraryNoNotebooksWithTag =>
      'Inga anteckningsböcker med den här taggen';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Inga okategoriserade anteckningsböcker';

  @override
  String get libraryNoNotebooksYet => 'Inga anteckningsböcker ännu';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Kunde inte ladda biblioteket: $error';
  }

  @override
  String get tooltipBackupRestore => 'Säkerhetskopiera och återställ';

  @override
  String get tooltipTrash => 'Papperskorg';

  @override
  String get tooltipNewNotebook => 'Ny anteckningsbok';

  @override
  String get tooltipNewFolder => 'Ny mapp';

  @override
  String get tooltipNewSubfolder => 'Ny undermapp';

  @override
  String get tooltipImportPdf => 'Importera PDF';

  @override
  String get folderNew => 'Ny mapp';

  @override
  String get folderNewSubfolder => 'Ny undermapp';

  @override
  String get folderRename => 'Byt namn på mapp';

  @override
  String get folderMoveToTrash => 'Flytta till papperskorgen';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Flytta \"$name\" till papperskorgen?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Mappen och dess anteckningsböcker flyttas till papperskorgen i 30 dagar.';

  @override
  String get notebookNew => 'Ny anteckningsbok';

  @override
  String get notebookUntitled => 'Namnlös';

  @override
  String get notebookTitleLabel => 'Titel';

  @override
  String get notebookSizeLabel => 'Storlek';

  @override
  String get notebookPaperLabel => 'Papper';

  @override
  String get notebookCoverLabel => 'Omslag';

  @override
  String get notebookRename => 'Byt namn på anteckningsbok';

  @override
  String get notebookMoveToFolder => 'Flytta till mapp';

  @override
  String get notebookEditTags => 'Redigera taggar';

  @override
  String get notebookExportWorkbook => 'Exportera anteckningsbok';

  @override
  String get notebookExportWorkbookSubtitle => 'Dela alla sidor som PDF';

  @override
  String get notebookMoveToTrash => 'Flytta till papperskorgen';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Flytta \"$title\" till papperskorgen?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Anteckningsboken döljs i biblioteket i 30 dagar. Bläck och sidor finns kvar på enheten tills papperskorgen töms. Exportera en säkerhetskopia först om du vill ha en extra kopia.';

  @override
  String notebookTagsFor(String title) {
    return 'Taggar för \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'Inga taggar ännu. Skapa en nedan.';

  @override
  String get notebookNewTag => 'Ny tagg';

  @override
  String get notebookAddTag => 'Lägg till tagg';

  @override
  String get notebookNoPagesToExport =>
      'Den här anteckningsboken har inga sidor att exportera';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" exporterades som PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Säkerhetskopia exporterad. Du kan flytta till papperskorgen när du är redo.';

  @override
  String get importPdfSnack =>
      'Importerar PDF… sidorna renderas en gång och finns sedan offline.';

  @override
  String importFailed(String error) {
    return 'Import misslyckades: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Export misslyckades: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Säkerhetskopiering misslyckades: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Återhämtning misslyckades: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Återställning misslyckades: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Laddar ner handskriftsmodell (~$sizeMb MB) i bakgrunden…';
  }

  @override
  String get templateBlank => 'Tom';

  @override
  String get templateLined => 'Linjerat';

  @override
  String get templateGrid => 'Rutnät';

  @override
  String get templateDotted => 'Prickat';

  @override
  String get templateCollegeRuled => 'College-linjerat';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Stående';

  @override
  String get orientationLandscape => 'Liggande';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get settingsSectionLanguage => 'Språk';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Utseende och preferenser';

  @override
  String get settingsSectionAppearance => 'Utseende';

  @override
  String get settingsAppearanceDarkMode => 'Mörkt läge';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Välj ljust, mörkt eller följ enheten (systemstandard)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Ljust';

  @override
  String get themeDark => 'Mörkt';

  @override
  String get settingsSectionPreferences => 'Preferenser';

  @override
  String get settingsLanguageLabel => 'Appspråk';

  @override
  String get languageEnglish => 'Engelska';

  @override
  String get languageGerman => 'Tyska';

  @override
  String get languageFrench => 'Franska';

  @override
  String get languageDutch => 'Nederländska';

  @override
  String get settingsSectionToolbar => 'Verktygsfält';

  @override
  String get settingsToolbarReorderHint =>
      'Dra för att ordna om ritverktyg. Ångra och gör om står kvar till höger.';

  @override
  String get settingsResetToolbarOrder => 'Återställ ordning i verktygsfältet';

  @override
  String get settingsSectionNotebook => 'Anteckningsbok';

  @override
  String get settingsPageTurnMode => 'Bläddringsläge';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Svep en sida i taget i stället för kontinuerlig rullning (av som standard)';

  @override
  String get settingsZoomNavigation => 'Zoomnavigering';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Nyp för att zooma och panorera på sidor (på som standard)';

  @override
  String get settingsSectionDrawing => 'Ritande';

  @override
  String get settingsStrokeSmoothing => 'Streckutjämning';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Utjämna bläckstreck med Chaikin-utjämning (på som standard)';

  @override
  String get settingsStrokeSmoothingStrength => 'Utjämningsstyrka';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent % — lägre behåller mer detalj; rekommenderat $recommended %';
  }

  @override
  String get settingsFingerDrawing => 'Rita med fingret';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Rita med fingret på papperet; när av ritar bara pennan (av som standard)';

  @override
  String get settingsGestureInkEditing => 'Gestredigering av bläck';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Stryk över OCR-indexerat bläck för att sudda ut det (på som standard)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Håll ned sidoknappen på S Pen för att tillfälligt byta verktyg. Släpp för att återgå till föregående verktyg. Fungerar på Samsung-enheter med stöd för sidoknapp.';

  @override
  String get settingsSpenBarrelAction => 'Sidoknappsåtgärd';

  @override
  String get settingsSectionOcrDictionary => 'OCR-ordlista';

  @override
  String get settingsOcrDictionaryHint =>
      'Domäntermer för handskrifts-OCR. Nära matchningar korrigeras när bläck indexeras, och termer förbättrar sökning i anteckningsböcker.';

  @override
  String get settingsNoCustomOcrTerms => 'Inga anpassade termer ännu.';

  @override
  String get settingsRemoveOcrTerm => 'Ta bort term';

  @override
  String get settingsAddOcrTerm => 'Lägg till term';

  @override
  String get settingsAddOcrTermTitle => 'Lägg till OCR-term';

  @override
  String get settingsOcrTermLabel => 'Term';

  @override
  String get settingsOcrTermHint => 't.ex. egenvärde, mitokondrier';

  @override
  String get settingsSectionYourData => 'Dina data';

  @override
  String get settingsYourDataHint =>
      'Penfold lagrar allt på den här enheten i en SQLite-databas och resursmappar — ingen molnsynkronisering. Se docs/ARCHITECTURE.md för den fullständiga fillayouten på enheten.';

  @override
  String get settingsDatabase => 'Databas';

  @override
  String get settingsSectionBackupRestore => 'Säkerhetskopiera och återställ';

  @override
  String get settingsBackupRestoreHint =>
      'Exportera en zip med penfold.db och resursmappar, eller återställ från en tidigare säkerhetskopia. Din nuvarande databas sparas i backups/ före återställning.';

  @override
  String get settingsExportBackup => 'Exportera säkerhetskopia';

  @override
  String get settingsExportBackupSubtitle =>
      'Zip:a penfold.db, PDF-källor, bilder och äldre PDF-sidor';

  @override
  String get settingsRecoverFromBackup => 'Återställ från säkerhetskopia';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Senaste autosäkerhetskopia: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Återställ säkerhetskopia';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Ersätt lokala data från en Penfold-säkerhetskopia i zip-format';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Återställ från autosäkerhetskopia?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Detta ersätter dina nuvarande anteckningsböcker och filer med säkerhetskopian från $timestamp. Din nuvarande databas sparas i backups/ före återställning.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Återställ säkerhetskopia?';

  @override
  String get settingsRestoreBackupBody =>
      'Detta ersätter dina nuvarande anteckningsböcker och filer. Din nuvarande databas sparas i backups/ före återställning.';

  @override
  String get settingsSectionAbout => 'Om';

  @override
  String get settingsAboutSubtitle =>
      'Handskriftsanteckningsbok — lokalt lagrad, inga konton, inget moln.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get spenActionEraser => 'Suddgummi';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Penna';

  @override
  String get spenActionNone => 'Ingen';

  @override
  String get toolPen => 'Penna';

  @override
  String get toolHighlighter => 'Överstrykningspenna';

  @override
  String get toolTape => 'Tejp';

  @override
  String get toolEraser => 'Suddgummi';

  @override
  String get toolSelection => 'Markering';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Form';

  @override
  String get toolFill => 'Fyll';

  @override
  String get toolText => 'Text';

  @override
  String get toolInsertImage => 'Infoga bild';

  @override
  String get brushPen => 'Penna';

  @override
  String get brushFountain => 'Reservoarpenna';

  @override
  String get brushPencil => 'Blyerts';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Kalligrafi';

  @override
  String get toolbarPreviousBookmark => 'Föregående bokmärke';

  @override
  String get toolbarNextBookmark => 'Nästa bokmärke';

  @override
  String get toolbarConvertToText => 'Konvertera till text';

  @override
  String get toolbarCopy => 'Kopiera';

  @override
  String get toolbarDelete => 'Radera';

  @override
  String get toolbarPaste => 'Klistra in';

  @override
  String get toolbarUndo => 'Ångra';

  @override
  String get toolbarRedo => 'Gör om';

  @override
  String get toolbarAddPage => 'Lägg till sida';

  @override
  String get toolbarStylusOnly => 'Endast penna (handloavsvisning)';

  @override
  String get toolbarFingerDrawing => 'Rita med fingret';

  @override
  String get toolbarPageOverview => 'Sidöversikt';

  @override
  String get toolbarTableOfContents => 'Innehållsförteckning';

  @override
  String get toolbarPageMenu => 'Sidmeny';

  @override
  String get penOptionsTitle => 'Penna';

  @override
  String get highlighterOptionsTitle => 'Överstrykningspenna';

  @override
  String get brushLabel => 'Pennstil';

  @override
  String get colorLabel => 'Färg';

  @override
  String get customColorTitle => 'Anpassad färg';

  @override
  String get hueLabel => 'Nyans';

  @override
  String get saturationLabel => 'Mättnad';

  @override
  String get brightnessLabel => 'Ljusstyrka';

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
  String get tapeOptionsTitle => 'Tejp';

  @override
  String get tapeOptionsHint =>
      'Rita för att täcka anteckningar; tryck på tejpen för att visa eller dölja igen';

  @override
  String get fillColorTitle => 'Fyllningsfärg';

  @override
  String get fillOptionsHint =>
      'Rita en sluten form, eller tryck inuti en form för att fylla';

  @override
  String get eraserSizeTitle => 'Suddgummistolek';

  @override
  String get eraserModeTitle => 'Suddgummiläge';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Streck';

  @override
  String get eraserModePartialHint =>
      'Raderar bara bläck under suddgummiets yta';

  @override
  String get eraserModeWholeStrokeHint => 'Raderar hela streck som den berör';

  @override
  String get eraseAllOnPageTitle => 'Radera allt på sidan?';

  @override
  String get eraseAllOnPageBody =>
      'Detta tar bort alla streck på den aktuella sidan. Du kan ångra den här åtgärden.';

  @override
  String get eraseAllOnPageButton => 'Radera allt på sidan';

  @override
  String get pageSettingsTitle => 'Sidinställningar';

  @override
  String get pageColorTitle => 'Sidfärg';

  @override
  String get pageThemeTitle => 'Sidtema';

  @override
  String get defaultPaperSize => 'Standardpappersstorlek';

  @override
  String get defaultPaperType => 'Standardpapperstyp';

  @override
  String get defaultPageTheme => 'Standardsidtema';

  @override
  String get notebookDefaultsHint =>
      'Används när du skapar en ny anteckningsbok. Du kan fortfarande ändra valen i dialogrutan.';

  @override
  String get pageThemeLight => 'Ljust';

  @override
  String get pageThemeDark => 'Mörkt';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastellrosa';

  @override
  String get pageThemePastelBlue => 'Pastellblå';

  @override
  String get pageThemePastelMint => 'Pastellmint';

  @override
  String get pageSizeTitle => 'Sidstorlek';

  @override
  String get pageOrientationTitle => 'Orientering';

  @override
  String get pageTemplateTitle => 'Sidmall';

  @override
  String get pageBookmark => 'Bokmärke';

  @override
  String get pageRemoveBookmark => 'Ta bort bokmärke';

  @override
  String get pageAudioTitle => 'Ljud';

  @override
  String get pageSplit => 'Dela';

  @override
  String get pageExportTitle => 'Exportera';

  @override
  String get pdfPagesKeepBackground =>
      'PDF-sidor behåller dokumentets bakgrund';

  @override
  String get pdfPagesKeepDimensions =>
      'PDF-sidor behåller dokumentets dimensioner';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF-sidor behåller dokumentets orientering';

  @override
  String get exportPageAsPng => 'Exportera sida som PNG';

  @override
  String get exportPageAsPngSubtitle => 'Dela bild av den här sidan';

  @override
  String get exportPageAsPdf => 'Exportera sida som PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Vektorbläck, dela via enhetens delningsmeny';

  @override
  String get exportNotebookAsPdf => 'Exportera anteckningsbok som PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sidor',
      one: '1 sida',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Bifoga ljudfil';

  @override
  String get pageAudioAttachSubtitle => 'MP3, M4A, WAV och andra lokala format';

  @override
  String get pageAudioAttachedToPage => 'Bifogad till den här sidan';

  @override
  String get pageAudioReplace => 'Ersätt ljudfil';

  @override
  String get pageAudioRemove => 'Ta bort ljud';

  @override
  String get pageAudioPlay => 'Spela';

  @override
  String get pageAudioPause => 'Pausa';

  @override
  String get contentsTitle => 'Innehåll';

  @override
  String get contentsSubtitle =>
      'Rubriker från inmatad text och OCR-indexerat bläck';

  @override
  String get contentsEmpty =>
      'Inga rubriker hittades ännu.\nLägg till stor eller kort inmatad text, eller OCR-indexerade bläckrubriker.';

  @override
  String contentsPageNumber(int number) {
    return 'Sida $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Sidor';

  @override
  String pageOverviewSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count valda',
      one: '1 vald',
    );
    return '$_temp0';
  }

  @override
  String get pageOverviewDeleteSelected => 'Radera valda';

  @override
  String get pageOverviewSelectPages => 'Välj sidor';

  @override
  String get pageOverviewKeepOnePage => 'Behåll minst en sida';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sidor',
      one: '1 sida',
    );
    return 'Radera $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Detta kan inte ångras.';

  @override
  String get pageOverviewDragToReorder => 'Dra för att ordna om';

  @override
  String get pageOverviewBookmarked => 'Bokmärkt';

  @override
  String get ocrIndexing => 'OCR-indexerar…';

  @override
  String get ocrHandwritingSearchable => 'Handskrift sökbar';

  @override
  String get ocrPartial => 'OCR ofullständig';

  @override
  String get trashTitle => 'Papperskorg';

  @override
  String trashFailedToLoad(String error) {
    return 'Kunde inte ladda papperskorgen: $error';
  }

  @override
  String get trashEmpty => 'Papperskorgen är tom';

  @override
  String get trashSectionFolders => 'Mappar';

  @override
  String get trashSectionNotebooks => 'Anteckningsböcker';

  @override
  String get trashDeletionDateUnavailable => 'Raderingsdatum otillgängligt';

  @override
  String get trashExpiresToday => 'Går ut idag';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagar kvar',
      one: '1 dag kvar',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Återställ';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Radera \"$title\" permanent?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Detta tar bort anteckningsboken och alla sidor från enheten.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Radera \"$name\" permanent?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Detta tar bort mappen och dess anteckningsböcker från enheten.';

  @override
  String get splitPageTitle => 'Dela sida?';

  @override
  String splitPageBody(int count) {
    return 'Skapa en ny sida med samma mall och flytta ungefär hälften av de $count strecken till den.';
  }

  @override
  String get splitPageNeedStrokes => 'Minst 2 streck krävs för att dela sidan';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Sida delad: $moved streck flyttades, $remaining kvar';
  }

  @override
  String splitPageFailed(String error) {
    return 'Delning misslyckades: $error';
  }

  @override
  String get splitPageAction => 'Dela sida';

  @override
  String get changePageSizeTitle => 'Ändra sidstorlek?';

  @override
  String get changePageSizeBody =>
      'Den här sidan har bläck. Om du ändrar storlek omformateras sidan; ditt bläck stannar på samma position på sidan.';

  @override
  String get changeOrientationTitle => 'Ändra orientering?';

  @override
  String get changeOrientationBody =>
      'Den här sidan har bläck. Om du ändrar orientering skalas och centreras innehållet för att passa sidans nya gränser.';

  @override
  String convertedToText(String preview) {
    return 'Konverterat till text: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => 'Kunde inte känna igen handskrift';

  @override
  String get handwritingModelTitle => 'Handskriftsmodell';

  @override
  String get handwritingModelDownloadFailed =>
      'Nedladdning misslyckades. Kontrollera nätverket och försök igen.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Laddar ner engelsk handskriftsmodell (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Modellen är redo.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Förfluten tid: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Första nedladdningen (~$sizeMb MB). Tar vanligtvis under två minuter på Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Sida exporterad som PNG';

  @override
  String get pageExportedAsPdf => 'Sida exporterad som PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Anteckningsbok exporterad som PDF';

  @override
  String get exportPreparing => 'Förbereder export…';

  @override
  String exportProgress(int current, int total) {
    return 'Exporterar sida $current av $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Den här sidan har $count streck och kan kännas långsam. Överväg att dela den för bättre prestanda.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Export blockerad: en sida har $count streck (gräns $limit). Dela tunga sidor först.';
  }

  @override
  String get restoreComplete =>
      'Återställning klar. Starta om appen för att ladda det återställda innehållet.';

  @override
  String get textToolHint => 'Skriv här…';

  @override
  String get textToolDone => 'Klar';

  @override
  String get languageKorean => 'Koreanska';

  @override
  String get languagePolish => 'Polska';

  @override
  String get languageSpanish => 'Spanska';

  @override
  String get languageItalian => 'Italienska';

  @override
  String get languageUkrainian => 'Ukrainska';

  @override
  String get languageSwedish => 'Svenska';

  @override
  String get languageNorwegian => 'Norska';

  @override
  String get languageFinnish => 'Finska';

  @override
  String get languageDanish => 'Danska';

  @override
  String get languagePortuguese => 'Portugisiska';
}
