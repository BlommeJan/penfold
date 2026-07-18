// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Avbryt';

  @override
  String get actionCreate => 'Opprett';

  @override
  String get actionRename => 'Gi nytt navn';

  @override
  String get actionSave => 'Lagre';

  @override
  String get actionDelete => 'Slett';

  @override
  String get actionAdd => 'Legg til';

  @override
  String get actionBack => 'Tilbake';

  @override
  String get actionDone => 'Ferdig';

  @override
  String get actionSplit => 'Del';

  @override
  String get actionRecover => 'Gjenopprett';

  @override
  String get actionRestore => 'Gjenopprett';

  @override
  String get actionExport => 'Eksporter';

  @override
  String get actionRetry => 'Prøv igjen';

  @override
  String get actionRetrying => 'Prøver igjen…';

  @override
  String get actionExportFirst => 'Eksporter først';

  @override
  String get actionEraseAll => 'Viske ut alt';

  @override
  String get actionChangeSize => 'Endre størrelse';

  @override
  String get actionChangeOrientation => 'Endre retning';

  @override
  String get actionUseColor => 'Bruk farge';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Oversikt';

  @override
  String get libraryTrash => 'Papirkurv';

  @override
  String get librarySettings => 'Innstillinger';

  @override
  String get libraryFolders => 'Mapper';

  @override
  String get libraryNoFoldersYet => 'Ingen mapper ennå';

  @override
  String get libraryAll => 'Alle';

  @override
  String get libraryUncategorized => 'Ukategorisert';

  @override
  String get libraryBreadcrumb => 'Bibliotek';

  @override
  String get librarySearchHint => 'Søk i notatbøker og skrevet tekst…';

  @override
  String get libraryNoMatches => 'Ingen treff';

  @override
  String get libraryFolderEmpty => 'Denne mappen er tom';

  @override
  String get libraryNoNotebooksWithTag => 'Ingen notatbøker med denne taggen';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Ingen ukategoriserte notatbøker';

  @override
  String get libraryNoNotebooksYet => 'Ingen notatbøker ennå';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Kunne ikke laste bibliotek: $error';
  }

  @override
  String get tooltipBackupRestore => 'Sikkerhetskopi og gjenoppretting';

  @override
  String get tooltipTrash => 'Papirkurv';

  @override
  String get tooltipNewNotebook => 'Ny notatbok';

  @override
  String get tooltipNewFolder => 'Ny mappe';

  @override
  String get tooltipNewSubfolder => 'Ny undermappe';

  @override
  String get tooltipImportPdf => 'Importer PDF';

  @override
  String get folderNew => 'Ny mappe';

  @override
  String get folderNewSubfolder => 'Ny undermappe';

  @override
  String get folderRename => 'Gi mappen nytt navn';

  @override
  String get folderMoveToTrash => 'Flytt til papirkurv';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Flytte «$name» til papirkurv?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Mappen og notatbøkene i den flyttes til papirkurv i 30 dager.';

  @override
  String get notebookNew => 'Ny notatbok';

  @override
  String get notebookUntitled => 'Uten tittel';

  @override
  String get notebookTitleLabel => 'Tittel';

  @override
  String get notebookSizeLabel => 'Størrelse';

  @override
  String get notebookPaperLabel => 'Papir';

  @override
  String get notebookCoverLabel => 'Omslag';

  @override
  String get notebookRename => 'Gi notatbok nytt navn';

  @override
  String get notebookMoveToFolder => 'Flytt til mappe';

  @override
  String get notebookEditTags => 'Rediger tagger';

  @override
  String get notebookExportWorkbook => 'Eksporter arbeidsbok';

  @override
  String get notebookExportWorkbookSubtitle => 'Del alle sider som PDF';

  @override
  String get notebookMoveToTrash => 'Flytt til papirkurv';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Flytte «$title» til papirkurv?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Notatboken skjules fra biblioteket i 30 dager. Blekk og sider blir på enheten til papirkurven tømmes. Eksporter en sikkerhetskopi først hvis du vil ha en ekstra kopi.';

  @override
  String notebookTagsFor(String title) {
    return 'Tagger for «$title»';
  }

  @override
  String get notebookNoTagsYet => 'Ingen tagger ennå. Opprett en nedenfor.';

  @override
  String get notebookNewTag => 'Ny tagg';

  @override
  String get notebookAddTag => 'Legg til tagg';

  @override
  String get notebookNoPagesToExport =>
      'Denne notatboken har ingen sider å eksportere';

  @override
  String notebookExportedAsPdf(String title) {
    return '«$title» eksportert som PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Sikkerhetskopi eksportert. Du kan flytte til papirkurv når du er klar.';

  @override
  String get importPdfSnack =>
      'Importerer PDF… sidene rendres én gang, deretter er de tilgjengelig offline.';

  @override
  String importFailed(String error) {
    return 'Import mislyktes: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Eksport mislyktes: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Sikkerhetskopiering mislyktes: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Gjenoppretting mislyktes: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Gjenoppretting mislyktes: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Laster ned håndskriftmodell (~$sizeMb MB) i bakgrunnen…';
  }

  @override
  String get templateBlank => 'Tom';

  @override
  String get templateLined => 'Linjert';

  @override
  String get templateGrid => 'Rutenett';

  @override
  String get templateDotted => 'Prikket';

  @override
  String get templateCollegeRuled => 'College-linjer';

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
  String get settingsTitle => 'Innstillinger';

  @override
  String get settingsSectionLanguage => 'Språk';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Utseende og preferanser';

  @override
  String get settingsSectionAppearance => 'Utseende';

  @override
  String get settingsAppearanceDarkMode => 'Mørk modus';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Velg lys, mørk eller følg enheten (standard: system)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Lys';

  @override
  String get themeDark => 'Mørk';

  @override
  String get settingsSectionPreferences => 'Preferanser';

  @override
  String get settingsLanguageLabel => 'Appspråk';

  @override
  String get languageEnglish => 'Engelsk';

  @override
  String get languageGerman => 'Tysk';

  @override
  String get languageFrench => 'Fransk';

  @override
  String get languageDutch => 'Nederlandsk';

  @override
  String get settingsSectionToolbar => 'Verktøylinje';

  @override
  String get settingsToolbarReorderHint =>
      'Dra for å endre rekkefølge på tegneverktøy. Angre og gjør om forblir fast til høyre.';

  @override
  String get settingsResetToolbarOrder => 'Tilbakestill verktøylinje';

  @override
  String get settingsSectionNotebook => 'Notatbok';

  @override
  String get settingsPageTurnMode => 'Sidevendingsmodus';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Sveip én side om gangen i stedet for kontinuerlig rulling (standard: av)';

  @override
  String get settingsZoomNavigation => 'Zoomnavigering';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Knip for å zoome og panorere på sider (standard: på)';

  @override
  String get settingsSectionDrawing => 'Tegning';

  @override
  String get settingsStrokeSmoothing => 'Strekglatting';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Glatte blekkstreker med Chaikin-hjørnebeskjæring (standard: på)';

  @override
  String get settingsStrokeSmoothingStrength => 'Glattingsstyrke';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — lavere beholder finere detaljer; anbefalt $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Tegning med finger';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Tegn med finger på papiret; når av, tegner kun stylus (standard: av)';

  @override
  String get settingsGestureInkEditing => 'Gestredigering av blekk';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Skrap over OCR-indeksert blekk for å viske det ut (standard: på)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Hold sideknappen på S Pen for å bytte verktøy midlertidig. Slipp for å gjenopprette forrige verktøy. Fungerer på Samsung-enheter med støtte for sideknapp.';

  @override
  String get settingsSpenBarrelAction => 'Sideknapp-handling';

  @override
  String get settingsSectionOcrDictionary => 'OCR-ordliste';

  @override
  String get settingsOcrDictionaryHint =>
      'Fagtermer for håndskrift-OCR. Nære treff korrigeres når blekk indekseres, og termer forsterker søk i notatbøker.';

  @override
  String get settingsNoCustomOcrTerms => 'Ingen egendefinerte termer ennå.';

  @override
  String get settingsRemoveOcrTerm => 'Fjern term';

  @override
  String get settingsAddOcrTerm => 'Legg til term';

  @override
  String get settingsAddOcrTermTitle => 'Legg til OCR-term';

  @override
  String get settingsOcrTermLabel => 'Term';

  @override
  String get settingsOcrTermHint => 'f.eks. egenverdi, mitokondrier';

  @override
  String get settingsSectionYourData => 'Dine data';

  @override
  String get settingsYourDataHint =>
      'Penfold lagrer alt på denne enheten i én SQLite-database og ressursmapper — ingen skysynkronisering. Se docs/ARCHITECTURE.md for full filstruktur på enheten.';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsSectionBackupRestore => 'Sikkerhetskopi og gjenoppretting';

  @override
  String get settingsBackupRestoreHint =>
      'Eksporter en zip av penfold.db og ressursmapper, eller gjenopprett fra en tidligere sikkerhetskopi. Nåværende database lagres i backups/ før gjenoppretting.';

  @override
  String get settingsExportBackup => 'Eksporter sikkerhetskopi';

  @override
  String get settingsExportBackupSubtitle =>
      'Zip penfold.db, PDF-kilder, bilder og eldre PDF-sider';

  @override
  String get settingsRecoverFromBackup => 'Gjenopprett fra sikkerhetskopi';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Siste autosikkerhetskopi: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Gjenopprett sikkerhetskopi';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Erstatt lokale data fra en Penfold-sikkerhetskopi (zip)';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Gjenopprette fra autosikkerhetskopi?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Dette erstatter notatbøkene og filene dine med sikkerhetskopi fra $timestamp. Nåværende database lagres i backups/ før gjenoppretting.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Gjenopprette sikkerhetskopi?';

  @override
  String get settingsRestoreBackupBody =>
      'Dette erstatter notatbøkene og filene dine. Nåværende database lagres i backups/ før gjenoppretting.';

  @override
  String get settingsSectionAbout => 'Om';

  @override
  String get settingsAboutSubtitle =>
      'Lokal-først håndskriftsnotatbok — ingen kontoer, ingen sky.';

  @override
  String settingsVersion(String version) {
    return 'Versjon $version';
  }

  @override
  String get spenActionEraser => 'Viskelær';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Penn';

  @override
  String get spenActionNone => 'Ingen';

  @override
  String get toolPen => 'Penn';

  @override
  String get toolHighlighter => 'Markeringspenn';

  @override
  String get toolTape => 'Tape';

  @override
  String get toolEraser => 'Viskelær';

  @override
  String get toolSelection => 'Utvalg';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Form';

  @override
  String get toolFill => 'Fyll';

  @override
  String get toolText => 'Tekst';

  @override
  String get toolInsertImage => 'Sett inn bilde';

  @override
  String get brushPen => 'Penn';

  @override
  String get brushFountain => 'Fyllepenn';

  @override
  String get brushPencil => 'Blyant';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Kalligrafi';

  @override
  String get toolbarPreviousBookmark => 'Forrige bokmerke';

  @override
  String get toolbarNextBookmark => 'Neste bokmerke';

  @override
  String get toolbarConvertToText => 'Konverter til tekst';

  @override
  String get toolbarCopy => 'Kopier';

  @override
  String get toolbarDelete => 'Slett';

  @override
  String get toolbarPaste => 'Lim inn';

  @override
  String get toolbarUndo => 'Angre';

  @override
  String get toolbarRedo => 'Gjør om';

  @override
  String get toolbarAddPage => 'Legg til side';

  @override
  String get toolbarStylusOnly => 'Kun stylus (håndflateavvisning)';

  @override
  String get toolbarFingerDrawing => 'Tegning med finger';

  @override
  String get toolbarPageOverview => 'Sideoversikt';

  @override
  String get toolbarTableOfContents => 'Innholdsfortegnelse';

  @override
  String get toolbarPageMenu => 'Sidemeny';

  @override
  String get penOptionsTitle => 'Penn';

  @override
  String get highlighterOptionsTitle => 'Markeringspenn';

  @override
  String get brushLabel => 'Pensel';

  @override
  String get colorLabel => 'Farge';

  @override
  String get customColorTitle => 'Egendefinert farge';

  @override
  String get hueLabel => 'Nyanse';

  @override
  String get saturationLabel => 'Metning';

  @override
  String get brightnessLabel => 'Lysstyrke';

  @override
  String get tapeOptionsTitle => 'Tape';

  @override
  String get tapeOptionsHint =>
      'Tegn for å dekke notater; trykk på tape for å vise eller skjule igjen';

  @override
  String get fillColorTitle => 'Fyllfarge';

  @override
  String get fillOptionsHint =>
      'Tegn en lukket løkke, eller trykk inni en form for å fylle';

  @override
  String get eraserSizeTitle => 'Viskelærstørrelse';

  @override
  String get eraserModeTitle => 'Viskelærmodus';

  @override
  String get eraserModePixel => 'Piksel';

  @override
  String get eraserModeStroke => 'Strek';

  @override
  String get eraserModePartialHint =>
      'Visker bare blekk under viskelær-sirkelen';

  @override
  String get eraserModeWholeStrokeHint => 'Visker hele streker den berører';

  @override
  String get eraseAllOnPageTitle => 'Vise ut alt på siden?';

  @override
  String get eraseAllOnPageBody =>
      'Dette fjerner alle streker på gjeldende side. Du kan angre denne handlingen.';

  @override
  String get eraseAllOnPageButton => 'Vise ut alt på siden';

  @override
  String get pageSettingsTitle => 'Sideinnstillinger';

  @override
  String get pageColorTitle => 'Sidefarge';

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
      'Brukes når du oppretter en ny notatbok. Du kan fortsatt endre valg i dialogen.';

  @override
  String get pageThemeLight => 'Lys';

  @override
  String get pageThemeDark => 'Mørk';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastell rosa';

  @override
  String get pageThemePastelBlue => 'Pastell blå';

  @override
  String get pageThemePastelMint => 'Pastell mint';

  @override
  String get pageSizeTitle => 'Sidestørrelse';

  @override
  String get pageOrientationTitle => 'Retning';

  @override
  String get pageTemplateTitle => 'Sidemal';

  @override
  String get pageBookmark => 'Bokmerke';

  @override
  String get pageRemoveBookmark => 'Fjern bokmerke';

  @override
  String get pageAudioTitle => 'Lyd';

  @override
  String get pageSplit => 'Del';

  @override
  String get pageExportTitle => 'Eksport';

  @override
  String get pdfPagesKeepBackground => 'PDF-sider beholder dokumentbakgrunnen';

  @override
  String get pdfPagesKeepDimensions =>
      'PDF-sider beholder dokumentdimensjonene';

  @override
  String get pdfPagesKeepOrientation => 'PDF-sider beholder dokumentretningen';

  @override
  String get exportPageAsPng => 'Eksporter side som PNG';

  @override
  String get exportPageAsPngSubtitle => 'Del bilde av denne siden';

  @override
  String get exportPageAsPdf => 'Eksporter side som PDF';

  @override
  String get exportPageAsPdfSubtitle => 'Vektorblekk, del via systemark';

  @override
  String get exportNotebookAsPdf => 'Eksporter notatbok som PDF';

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
  String get pageAudioAttach => 'Legg ved lydfil';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV og andre lokale formater';

  @override
  String get pageAudioAttachedToPage => 'Vedlagt denne siden';

  @override
  String get pageAudioReplace => 'Erstatt lydfil';

  @override
  String get pageAudioRemove => 'Fjern lyd';

  @override
  String get pageAudioPlay => 'Spill av';

  @override
  String get pageAudioPause => 'Pause';

  @override
  String get contentsTitle => 'Innhold';

  @override
  String get contentsSubtitle =>
      'Overskrifter fra skrevet tekst og OCR-indeksert blekk';

  @override
  String get contentsEmpty =>
      'Ingen overskrifter funnet ennå.\nLegg til store eller korte skrevne overskrifter, eller OCR-indekserte blekkoverskrifter.';

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
  String get pageOverviewDeleteSelected => 'Slett valgte';

  @override
  String get pageOverviewSelectPages => 'Velg sider';

  @override
  String get pageOverviewKeepOnePage => 'Behold minst én side';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sider',
      one: '1 side',
    );
    return 'Slette $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Dette kan ikke angres.';

  @override
  String get pageOverviewDragToReorder => 'Dra for å endre rekkefølge';

  @override
  String get pageOverviewBookmarked => 'Bokmerket';

  @override
  String get ocrIndexing => 'OCR-indeksering…';

  @override
  String get ocrHandwritingSearchable => 'Håndskrift søkbar';

  @override
  String get ocrPartial => 'OCR delvis';

  @override
  String get trashTitle => 'Papirkurv';

  @override
  String trashFailedToLoad(String error) {
    return 'Kunne ikke laste papirkurv: $error';
  }

  @override
  String get trashEmpty => 'Papirkurven er tom';

  @override
  String get trashSectionFolders => 'Mapper';

  @override
  String get trashSectionNotebooks => 'Notatbøker';

  @override
  String get trashDeletionDateUnavailable => 'Slettedato utilgjengelig';

  @override
  String get trashExpiresToday => 'Utløper i dag';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dager igjen',
      one: '1 dag igjen',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Gjenopprett';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Slette «$title» permanent?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Dette fjerner notatboken og alle sider fra denne enheten.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Slette «$name» permanent?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Dette fjerner mappen og notatbøkene i den fra denne enheten.';

  @override
  String get splitPageTitle => 'Dele side?';

  @override
  String splitPageBody(int count) {
    return 'Opprett en ny side med samme mal og flytt omtrent halvparten av $count streker dit.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Trenger minst 2 streker for å dele denne siden';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Side delt: $moved streker flyttet, $remaining gjenstår';
  }

  @override
  String splitPageFailed(String error) {
    return 'Deling mislyktes: $error';
  }

  @override
  String get splitPageAction => 'Del side';

  @override
  String get changePageSizeTitle => 'Endre sidestørrelse?';

  @override
  String get changePageSizeBody =>
      'Denne siden har blekk. Endring av størrelse endrer sideoppsettet; blekket forblir på samme posisjon på siden.';

  @override
  String get changeOrientationTitle => 'Endre retning?';

  @override
  String get changeOrientationBody =>
      'Denne siden har blekk. Endring av retning skalerer og sentrerer innholdet for å passe nye sidegrenser.';

  @override
  String convertedToText(String preview) {
    return 'Konvertert til tekst: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => 'Kunne ikke gjenkjenne håndskrift';

  @override
  String get handwritingModelTitle => 'Håndskriftmodell';

  @override
  String get handwritingModelDownloadFailed =>
      'Nedlasting mislyktes. Sjekk nettverk og prøv igjen.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Laster ned engelsk håndskriftmodell (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Modell klar.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Forløpt: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Førstegangs nedlasting (~$sizeMb MB). Fullføres vanligvis på under to minutter over Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Side eksportert som PNG';

  @override
  String get pageExportedAsPdf => 'Side eksportert som PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Notatbok eksportert som PDF';

  @override
  String get exportPreparing => 'Forbereder eksport…';

  @override
  String exportProgress(int current, int total) {
    return 'Eksporterer side $current av $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Denne siden har $count streker og kan føles treg. Vurder å dele den for bedre ytelse.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Eksport blokkert: en side har $count streker (grense $limit). Del tunge sider først.';
  }

  @override
  String get restoreComplete =>
      'Gjenoppretting fullført. Start appen på nytt for å laste de gjenopprettede dataene.';

  @override
  String get textToolHint => 'Skriv her…';

  @override
  String get textToolDone => 'Ferdig';

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
