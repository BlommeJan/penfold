// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Annuller';

  @override
  String get actionCreate => 'Opret';

  @override
  String get actionRename => 'Omdøb';

  @override
  String get actionSave => 'Gem';

  @override
  String get actionDelete => 'Slet';

  @override
  String get actionAdd => 'Tilføj';

  @override
  String get actionBack => 'Tilbage';

  @override
  String get actionDone => 'Færdig';

  @override
  String get actionSplit => 'Opdel';

  @override
  String get actionRecover => 'Gendan';

  @override
  String get actionRestore => 'Gendan';

  @override
  String get actionExport => 'Eksporter';

  @override
  String get actionRetry => 'Prøv igen';

  @override
  String get actionRetrying => 'Prøver igen…';

  @override
  String get actionExportFirst => 'Eksporter først';

  @override
  String get actionEraseAll => 'Slet alt';

  @override
  String get actionChangeSize => 'Skift størrelse';

  @override
  String get actionChangeOrientation => 'Skift retning';

  @override
  String get actionUseColor => 'Brug farve';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Oversigt';

  @override
  String get libraryTrash => 'Papirkurv';

  @override
  String get librarySettings => 'Indstillinger';

  @override
  String get libraryFolders => 'Mapper';

  @override
  String get libraryNoFoldersYet => 'Ingen mapper endnu';

  @override
  String get libraryAll => 'Alle';

  @override
  String get libraryUncategorized => 'Uden kategori';

  @override
  String get libraryBreadcrumb => 'Bibliotek';

  @override
  String get librarySearchHint => 'Søg i notesbøger og indtastet tekst…';

  @override
  String get libraryNoMatches => 'Ingen resultater';

  @override
  String get libraryFolderEmpty => 'Denne mappe er tom';

  @override
  String get libraryNoNotebooksWithTag => 'Ingen notesbøger med dette tag';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Ingen notesbøger uden kategori';

  @override
  String get libraryNoNotebooksYet => 'Ingen notesbøger endnu';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Kunne ikke indlæse bibliotek: $error';
  }

  @override
  String get tooltipBackupRestore => 'Sikkerhedskopi og gendannelse';

  @override
  String get tooltipTrash => 'Papirkurv';

  @override
  String get tooltipNewNotebook => 'Ny notesbog';

  @override
  String get tooltipNewFolder => 'Ny mappe';

  @override
  String get tooltipNewSubfolder => 'Ny undermappe';

  @override
  String get tooltipImportPdf => 'Importér PDF';

  @override
  String get folderNew => 'Ny mappe';

  @override
  String get folderNewSubfolder => 'Ny undermappe';

  @override
  String get folderRename => 'Omdøb mappe';

  @override
  String get folderMoveToTrash => 'Flyt til papirkurv';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Flyt \"$name\" til papirkurv?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Mappen og dens notesbøger flyttes til papirkurven i 30 dage.';

  @override
  String get notebookNew => 'Ny notesbog';

  @override
  String get notebookUntitled => 'Uden titel';

  @override
  String get notebookTitleLabel => 'Titel';

  @override
  String get notebookSizeLabel => 'Størrelse';

  @override
  String get notebookPaperLabel => 'Papir';

  @override
  String get notebookCoverLabel => 'Cover';

  @override
  String get notebookRename => 'Omdøb notesbog';

  @override
  String get notebookMoveToFolder => 'Flyt til mappe';

  @override
  String get notebookEditTags => 'Rediger tags';

  @override
  String get notebookExportWorkbook => 'Eksporter notesbog';

  @override
  String get notebookExportWorkbookSubtitle => 'Del alle sider som PDF';

  @override
  String get notebookMoveToTrash => 'Flyt til papirkurv';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Flyt \"$title\" til papirkurv?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Notesbogen skjules i biblioteket i 30 dage. Blæk og sider forbliver på denne enhed, indtil papirkurven tømmes. Eksporter en sikkerhedskopi først, hvis du vil have en ekstra kopi.';

  @override
  String notebookTagsFor(String title) {
    return 'Tags til \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'Ingen tags endnu. Opret et nedenfor.';

  @override
  String get notebookNewTag => 'Nyt tag';

  @override
  String get notebookAddTag => 'Tilføj tag';

  @override
  String get notebookNoPagesToExport =>
      'Denne notesbog har ingen sider at eksportere';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" eksporteret som PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Sikkerhedskopi eksporteret. Du kan flytte til papirkurv, når du er klar.';

  @override
  String get importPdfSnack =>
      'Importerer PDF… sider gengives én gang og forbliver derefter offline.';

  @override
  String importFailed(String error) {
    return 'Import mislykkedes: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Eksport mislykkedes: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Sikkerhedskopi mislykkedes: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Gendannelse mislykkedes: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Gendannelse mislykkedes: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Henter håndskriftmodel (~$sizeMb MB) i baggrunden…';
  }

  @override
  String get templateBlank => 'Tom';

  @override
  String get templateLined => 'Linjeret';

  @override
  String get templateGrid => 'Gitter';

  @override
  String get templateDotted => 'Prikket';

  @override
  String get templateCollegeRuled => 'College-linjeret';

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
  String get orientationLandscape => 'Liggende';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get settingsSectionLanguage => 'Sprog';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Udseende og præferencer';

  @override
  String get settingsSectionAppearance => 'Udseende';

  @override
  String get settingsAppearanceDarkMode => 'Mørk tilstand';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Vælg lys, mørk eller følg enheden (standard: system)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Lys';

  @override
  String get themeDark => 'Mørk';

  @override
  String get settingsSectionPreferences => 'Præferencer';

  @override
  String get settingsLanguageLabel => 'Appsprog';

  @override
  String get languageEnglish => 'Engelsk';

  @override
  String get languageGerman => 'Tysk';

  @override
  String get languageFrench => 'Fransk';

  @override
  String get languageDutch => 'Hollandsk';

  @override
  String get settingsSectionToolbar => 'Værktøjslinje';

  @override
  String get settingsToolbarReorderHint =>
      'Træk for at omarrangere tegneværktøjer. Fortryd og gendan forbliver fast til højre.';

  @override
  String get settingsResetToolbarOrder => 'Nulstil rækkefølge på værktøjslinje';

  @override
  String get settingsSectionNotebook => 'Notesbog';

  @override
  String get settingsPageTurnMode => 'Sidevendningstilstand';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Stryg én side ad gangen i stedet for løbende rulning (standard: fra)';

  @override
  String get settingsZoomNavigation => 'Zoomnavigation';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Knib for at zoome og panorere på sider (standard: til)';

  @override
  String get settingsSectionDrawing => 'Tegning';

  @override
  String get settingsStrokeSmoothing => 'Strøgudjævning';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Gør blækstrøg glattere med Chaikin-hjørneskæring (standard: til)';

  @override
  String get settingsStrokeSmoothingStrength => 'Udjævningsstyrke';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent % — lavere bevarer finere detaljer; anbefalet $recommended %';
  }

  @override
  String get settingsFingerDrawing => 'Tegning med finger';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Tegn med finger på papiret; når fra, tegner kun stylus (standard: fra)';

  @override
  String get settingsGestureInkEditing => 'Gestusblækredigering';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Skrab over OCR-indekseret blæk for at slette det (standard: til)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Hold S Pen-sideknappen nede for midlertidigt at skifte værktøj. Slip for at gendanne dit forrige værktøj. Virker på Samsung-enheder med sideknap-understøttelse.';

  @override
  String get settingsSpenBarrelAction => 'Sideknap-handling';

  @override
  String get settingsSectionOcrDictionary => 'OCR-ordliste';

  @override
  String get settingsOcrDictionaryHint =>
      'Fagtermer til håndskrift-OCR. Tætte matches rettes, når blæk indekseres, og termer booster notesbogssøgning.';

  @override
  String get settingsNoCustomOcrTerms => 'Ingen brugerdefinerede termer endnu.';

  @override
  String get settingsRemoveOcrTerm => 'Fjern term';

  @override
  String get settingsAddOcrTerm => 'Tilføj term';

  @override
  String get settingsAddOcrTermTitle => 'Tilføj OCR-term';

  @override
  String get settingsOcrTermLabel => 'Term';

  @override
  String get settingsOcrTermHint => 'f.eks. egenværdi, mitokondrie';

  @override
  String get settingsSectionYourData => 'Dine data';

  @override
  String get settingsYourDataHint =>
      'Penfold gemmer alt på denne enhed i én SQLite-database og aktivmapper — ingen cloudsynkronisering. Se docs/ARCHITECTURE.md for det fulde lokale fillayout.';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsSectionBackupRestore => 'Sikkerhedskopi og gendannelse';

  @override
  String get settingsBackupRestoreHint =>
      'Eksporter en zip med penfold.db og aktivmapper, eller gendan fra en tidligere sikkerhedskopi. Din nuværende database gemmes i backups/ før gendannelse.';

  @override
  String get settingsExportBackup => 'Eksporter sikkerhedskopi';

  @override
  String get settingsExportBackupSubtitle =>
      'Zip penfold.db, PDF-kilder, billeder og ældre PDF-sider';

  @override
  String get settingsRecoverFromBackup => 'Gendan fra sikkerhedskopi';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Seneste autosikkerhedskopi: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Gendan sikkerhedskopi';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Erstat lokale data fra en Penfold-sikkerhedskopi-zip';

  @override
  String get settingsRecoverAutoBackupTitle => 'Gendan fra autosikkerhedskopi?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Dette erstatter dine nuværende notesbøger og filer med sikkerhedskopien fra $timestamp. Din nuværende database gemmes i backups/ før gendannelse.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Gendan sikkerhedskopi?';

  @override
  String get settingsRestoreBackupBody =>
      'Dette erstatter dine nuværende notesbøger og filer. Din nuværende database gemmes i backups/ før gendannelse.';

  @override
  String get settingsSectionAbout => 'Om';

  @override
  String get settingsAboutSubtitle =>
      'Lokal-først håndskriftsnotesbog — ingen konti, ingen cloud.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get spenActionEraser => 'Viskelæder';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Pen';

  @override
  String get spenActionNone => 'Ingen';

  @override
  String get toolPen => 'Pen';

  @override
  String get toolHighlighter => 'Overstregningstusch';

  @override
  String get toolTape => 'Tape';

  @override
  String get toolEraser => 'Viskelæder';

  @override
  String get toolSelection => 'Markering';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Form';

  @override
  String get toolFill => 'Fyld';

  @override
  String get toolText => 'Tekst';

  @override
  String get toolInsertImage => 'Indsæt billede';

  @override
  String get brushPen => 'Pen';

  @override
  String get brushFountain => 'Fyldepen';

  @override
  String get brushPencil => 'Blyant';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Kalligrafi';

  @override
  String get toolbarPreviousBookmark => 'Forrige bogmærke';

  @override
  String get toolbarNextBookmark => 'Næste bogmærke';

  @override
  String get toolbarConvertToText => 'Konvertér til tekst';

  @override
  String get toolbarCopy => 'Kopiér';

  @override
  String get toolbarDelete => 'Slet';

  @override
  String get toolbarPaste => 'Indsæt';

  @override
  String get toolbarUndo => 'Fortryd';

  @override
  String get toolbarRedo => 'Gentag';

  @override
  String get toolbarAddPage => 'Tilføj side';

  @override
  String get toolbarStylusOnly => 'Kun stylus (håndfladeafvisning)';

  @override
  String get toolbarFingerDrawing => 'Tegning med finger';

  @override
  String get toolbarPageOverview => 'Sideoversigt';

  @override
  String get toolbarTableOfContents => 'Indholdsfortegnelse';

  @override
  String get toolbarPageMenu => 'Sidemenu';

  @override
  String get penOptionsTitle => 'Pen';

  @override
  String get highlighterOptionsTitle => 'Overstregningstusch';

  @override
  String get brushLabel => 'Pensel';

  @override
  String get colorLabel => 'Farve';

  @override
  String get customColorTitle => 'Brugerdefineret farve';

  @override
  String get hueLabel => 'Nuance';

  @override
  String get saturationLabel => 'Mætning';

  @override
  String get brightnessLabel => 'Lysstyrke';

  @override
  String get tapeOptionsTitle => 'Tape';

  @override
  String get tapeOptionsHint =>
      'Tegn for at dække noter; tryk på tape for at vise eller skjule igen';

  @override
  String get fillColorTitle => 'Fyldfarve';

  @override
  String get fillOptionsHint =>
      'Tegn en lukket løkke, eller tryk inde i en form for at fylde';

  @override
  String get eraserSizeTitle => 'Viskelæderstørrelse';

  @override
  String get eraserModeTitle => 'Viskelædertilstand';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Strøg';

  @override
  String get eraserModePartialHint =>
      'Sletter kun blæk under viskelædercirklen';

  @override
  String get eraserModeWholeStrokeHint => 'Sletter hele strøg, den rører';

  @override
  String get eraseAllOnPageTitle => 'Slet alt på siden?';

  @override
  String get eraseAllOnPageBody =>
      'Dette fjerner alle strøg på den nuværende side. Du kan fortryde denne handling.';

  @override
  String get eraseAllOnPageButton => 'Slet alt på siden';

  @override
  String get pageSettingsTitle => 'Sideindstillinger';

  @override
  String get pageColorTitle => 'Sidefarve';

  @override
  String get pageThemeTitle => 'Sidetema';

  @override
  String get defaultPaperSize => 'Standard papirstørrelse';

  @override
  String get defaultPaperType => 'Standard papirtype';

  @override
  String get defaultPageTheme => 'Standard sidetema';

  @override
  String get notebookDefaultsHint =>
      'Bruges, når du opretter en ny notesbog. Du kan stadig ændre valg i dialogen.';

  @override
  String get pageThemeLight => 'Lys';

  @override
  String get pageThemeDark => 'Mørk';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastelrosa';

  @override
  String get pageThemePastelBlue => 'Pastelblå';

  @override
  String get pageThemePastelMint => 'Pastelmint';

  @override
  String get pageSizeTitle => 'Sidestørrelse';

  @override
  String get pageOrientationTitle => 'Retning';

  @override
  String get pageTemplateTitle => 'Sideskabelon';

  @override
  String get pageBookmark => 'Bogmærke';

  @override
  String get pageRemoveBookmark => 'Fjern bogmærke';

  @override
  String get pageAudioTitle => 'Lyd';

  @override
  String get pageSplit => 'Opdel';

  @override
  String get pageExportTitle => 'Eksport';

  @override
  String get pdfPagesKeepBackground =>
      'PDF-sider beholder dokumentets baggrund';

  @override
  String get pdfPagesKeepDimensions =>
      'PDF-sider beholder dokumentets dimensioner';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF-sider beholder dokumentets retning';

  @override
  String get exportPageAsPng => 'Eksporter side som PNG';

  @override
  String get exportPageAsPngSubtitle => 'Del billede af denne side';

  @override
  String get exportPageAsPdf => 'Eksporter side som PDF';

  @override
  String get exportPageAsPdfSubtitle => 'Vektorblæk, del via systemark';

  @override
  String get exportNotebookAsPdf => 'Eksporter notesbog som PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sider',
      one: '1 side',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Vedhæft lydfil';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV og andre lokale formater';

  @override
  String get pageAudioAttachedToPage => 'Vedhæftet til denne side';

  @override
  String get pageAudioReplace => 'Erstat lydfil';

  @override
  String get pageAudioRemove => 'Fjern lyd';

  @override
  String get pageAudioPlay => 'Afspil';

  @override
  String get pageAudioPause => 'Pause';

  @override
  String get contentsTitle => 'Indhold';

  @override
  String get contentsSubtitle =>
      'Overskrifter fra indtastet tekst og OCR-indekseret blæk';

  @override
  String get contentsEmpty =>
      'Ingen overskrifter fundet endnu.\nTilføj stor eller kort indtastet tekst, eller OCR-indekserede blækoverskrifter.';

  @override
  String contentsPageNumber(int number) {
    return 'Side $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Sider';

  @override
  String pageOverviewSelected(int count) {
    return '$count valgt';
  }

  @override
  String get pageOverviewDeleteSelected => 'Slet valgte';

  @override
  String get pageOverviewSelectPages => 'Vælg sider';

  @override
  String get pageOverviewKeepOnePage => 'Behold mindst én side';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sider',
      one: '1 side',
    );
    return 'Slet $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Dette kan ikke fortrydes.';

  @override
  String get pageOverviewDragToReorder => 'Træk for at omarrangere';

  @override
  String get pageOverviewBookmarked => 'Bogmærket';

  @override
  String get ocrIndexing => 'OCR-indekserer…';

  @override
  String get ocrHandwritingSearchable => 'Håndskrift kan søges';

  @override
  String get ocrPartial => 'OCR delvis';

  @override
  String get trashTitle => 'Papirkurv';

  @override
  String trashFailedToLoad(String error) {
    return 'Kunne ikke indlæse papirkurv: $error';
  }

  @override
  String get trashEmpty => 'Papirkurven er tom';

  @override
  String get trashSectionFolders => 'Mapper';

  @override
  String get trashSectionNotebooks => 'Notesbøger';

  @override
  String get trashDeletionDateUnavailable => 'Sletningsdato utilgængelig';

  @override
  String get trashExpiresToday => 'Udløber i dag';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dage tilbage',
      one: '1 dag tilbage',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Gendan';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Slet \"$title\" permanent?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Dette fjerner notesbogen og alle sider fra denne enhed.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Slet \"$name\" permanent?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Dette fjerner mappen og dens notesbøger fra denne enhed.';

  @override
  String get splitPageTitle => 'Opdel side?';

  @override
  String splitPageBody(int count) {
    return 'Opret en ny side med samme skabelon og flyt cirka halvdelen af de $count strøg over på den.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Mindst 2 strøg kræves for at opdele denne side';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Side opdelt: $moved strøg flyttet, $remaining tilbage';
  }

  @override
  String splitPageFailed(String error) {
    return 'Opdeling mislykkedes: $error';
  }

  @override
  String get splitPageAction => 'Opdel side';

  @override
  String get changePageSizeTitle => 'Skift sidestørrelse?';

  @override
  String get changePageSizeBody =>
      'Denne side har blæk. Ændring af størrelsen omarrangerer siden; dit blæk forbliver på samme position på siden.';

  @override
  String get changeOrientationTitle => 'Skift retning?';

  @override
  String get changeOrientationBody =>
      'Denne side har blæk. Ændring af retning skalerer og centrerer dit indhold, så det passer til de nye sidegrænser.';

  @override
  String convertedToText(String preview) {
    return 'Konverteret til tekst: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => 'Kunne ikke genkende håndskrift';

  @override
  String get handwritingModelTitle => 'Håndskriftmodel';

  @override
  String get handwritingModelDownloadFailed =>
      'Download mislykkedes. Tjek netværk og prøv igen.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Henter engelsk håndskriftmodel (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Model klar.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Forløbet: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Førstegangsdownload (~$sizeMb MB). Slutter normalt på under to minutter over Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Side eksporteret som PNG';

  @override
  String get pageExportedAsPdf => 'Side eksporteret som PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Notesbog eksporteret som PDF';

  @override
  String get exportPreparing => 'Forbereder eksport…';

  @override
  String exportProgress(int current, int total) {
    return 'Eksporterer side $current af $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Denne side har $count strøg og kan føles langsom. Overvej at opdele den for bedre ydeevne.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Eksport blokeret: en side har $count strøg (grænse $limit). Opdel tunge sider først.';
  }

  @override
  String get restoreComplete =>
      'Gendannelse fuldført. Genstart appen for at indlæse de gendannede data.';

  @override
  String get textToolHint => 'Skriv her…';

  @override
  String get textToolDone => 'Færdig';

  @override
  String get languageKorean => 'Koreansk';

  @override
  String get languagePolish => 'Polsk';

  @override
  String get languageSpanish => 'Spansk';

  @override
  String get languageItalian => 'Italiensk';

  @override
  String get languageUkrainian => 'Ukrainsk';

  @override
  String get languageSwedish => 'Svensk';

  @override
  String get languageNorwegian => 'Norsk';

  @override
  String get languageFinnish => 'Finsk';

  @override
  String get languageDanish => 'Dansk';

  @override
  String get languagePortuguese => 'Portugisisk';
}
