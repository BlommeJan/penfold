// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Annuleren';

  @override
  String get actionCreate => 'Aanmaken';

  @override
  String get actionRename => 'Hernoemen';

  @override
  String get actionSave => 'Opslaan';

  @override
  String get actionDelete => 'Verwijderen';

  @override
  String get actionAdd => 'Toevoegen';

  @override
  String get actionBack => 'Terug';

  @override
  String get actionDone => 'Klaar';

  @override
  String get actionSplit => 'Splitsen';

  @override
  String get actionRecover => 'Herstellen';

  @override
  String get actionRestore => 'Terugzetten';

  @override
  String get actionExport => 'Exporteren';

  @override
  String get actionRetry => 'Opnieuw proberen';

  @override
  String get actionRetrying => 'Opnieuw proberen…';

  @override
  String get actionExportFirst => 'Eerst exporteren';

  @override
  String get actionEraseAll => 'Alles wissen';

  @override
  String get actionChangeSize => 'Formaat wijzigen';

  @override
  String get actionChangeOrientation => 'Richting wijzigen';

  @override
  String get actionUseColor => 'Kleur gebruiken';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Overzicht';

  @override
  String get libraryTrash => 'Prullenbak';

  @override
  String get librarySettings => 'Instellingen';

  @override
  String get libraryFolders => 'Mappen';

  @override
  String get libraryNoFoldersYet => 'Nog geen mappen';

  @override
  String get libraryAll => 'Alles';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Zonder categorie';

  @override
  String get libraryBreadcrumb => 'Bibliotheek';

  @override
  String get librarySearchHint => 'Zoek in notitieboeken en getypte tekst…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Geen resultaten';

  @override
  String get libraryFolderEmpty => 'Deze map is leeg';

  @override
  String get libraryNoNotebooksWithTag => 'Geen notitieboeken met dit label';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Geen notitieboeken zonder categorie';

  @override
  String get libraryNoNotebooksYet => 'Nog geen notitieboeken';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Bibliotheek kon niet worden geladen: $error';
  }

  @override
  String get tooltipBackupRestore => 'Back-up & herstel';

  @override
  String get tooltipTrash => 'Prullenbak';

  @override
  String get tooltipNewNotebook => 'Nieuw notitieboek';

  @override
  String get tooltipNewFolder => 'Nieuwe map';

  @override
  String get tooltipNewSubfolder => 'Nieuwe submap';

  @override
  String get tooltipImportPdf => 'PDF importeren';

  @override
  String get folderNew => 'Nieuwe map';

  @override
  String get folderNewSubfolder => 'Nieuwe submap';

  @override
  String get folderRename => 'Map hernoemen';

  @override
  String get folderMoveToTrash => 'Naar de prullenbak';

  @override
  String folderMoveToTrashTitle(String name) {
    return '\"$name\" naar de prullenbak verplaatsen?';
  }

  @override
  String get folderMoveToTrashBody =>
      'De map en bijbehorende notitieboeken gaan 30 dagen naar de prullenbak.';

  @override
  String get notebookNew => 'Nieuw notitieboek';

  @override
  String get notebookUntitled => 'Naamloos';

  @override
  String get notebookTitleLabel => 'Titel';

  @override
  String get notebookSizeLabel => 'Formaat';

  @override
  String get notebookPaperLabel => 'Papier';

  @override
  String get notebookCoverLabel => 'Omslag';

  @override
  String get notebookRename => 'Notitieboek hernoemen';

  @override
  String get notebookMoveToFolder => 'Naar map verplaatsen';

  @override
  String get notebookEditTags => 'Labels bewerken';

  @override
  String get notebookExportWorkbook => 'Notitieboek exporteren';

  @override
  String get notebookExportWorkbookSubtitle => 'Deel alle pagina\'s als PDF';

  @override
  String get notebookMoveToTrash => 'Naar de prullenbak';

  @override
  String notebookMoveToTrashTitle(String title) {
    return '\"$title\" naar de prullenbak verplaatsen?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Het notitieboek wordt 30 dagen uit de bibliotheek verborgen. Inkt en pagina\'s blijven op dit apparaat totdat de prullenbak wordt geleegd. Exporteer eerst een back-up als je een extra kopie wilt.';

  @override
  String notebookTagsFor(String title) {
    return 'Labels voor \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'Nog geen labels. Maak er hieronder een aan.';

  @override
  String get notebookNewTag => 'Nieuw label';

  @override
  String get notebookAddTag => 'Label toevoegen';

  @override
  String get notebookNoPagesToExport =>
      'Dit notitieboek heeft geen pagina\'s om te exporteren';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" geëxporteerd als PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Back-up geëxporteerd. Je kunt naar de prullenbak verplaatsen wanneer je klaar bent.';

  @override
  String get importPdfSnack =>
      'PDF importeren… pagina\'s worden één keer gerenderd en blijven daarna offline.';

  @override
  String importFailed(String error) {
    return 'Importeren mislukt: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Exporteren mislukt: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Back-up mislukt: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Herstel mislukt: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Terugzetten mislukt: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Handschriftmodel downloaden (~$sizeMb MB) op de achtergrond…';
  }

  @override
  String get templateBlank => 'Blanco';

  @override
  String get templateLined => 'Gelijnd';

  @override
  String get templateGrid => 'Raster';

  @override
  String get templateDotted => 'Gestippeld';

  @override
  String get templateCollegeRuled => 'College-lijntjes';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Staand';

  @override
  String get orientationLandscape => 'Liggend';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsSectionLanguage => 'Taal';

  @override
  String get settingsSectionAppearanceAndPreferences => 'Weergave & voorkeuren';

  @override
  String get settingsSectionAppearance => 'Weergave';

  @override
  String get settingsAppearanceDarkMode => 'Donkere modus';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Kies licht, donker of volg het systeem (standaard)';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get settingsSectionPreferences => 'Voorkeuren';

  @override
  String get settingsLanguageLabel => 'Taal van de app';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageGerman => 'Duits';

  @override
  String get languageFrench => 'Frans';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get settingsSectionToolbar => 'Werkbalk';

  @override
  String get settingsToolbarReorderHint =>
      'Sleep om tekengereedschappen te herschikken. Ongedaan maken en opnieuw blijven rechts vast staan.';

  @override
  String get settingsResetToolbarOrder => 'Volgorde werkbalk resetten';

  @override
  String get settingsSectionNotebook => 'Notitieboek';

  @override
  String get settingsPageTurnMode => 'Bladermodus';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Veeg één pagina per keer in plaats van doorlopend scrollen (standaard uit)';

  @override
  String get settingsZoomNavigation => 'Zoomnavigatie';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Knijp om in te zoomen en te pannen op pagina\'s (standaard aan)';

  @override
  String get settingsSectionDrawing => 'Tekenen';

  @override
  String get settingsStrokeSmoothing => 'Lijnverzachting';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Verzacht inktlijnen met Chaikin corner-cutting (standaard aan)';

  @override
  String get settingsStrokeSmoothingStrength => 'Verzachtingssterkte';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — lager behoudt meer detail; aanbevolen $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Tekenen met vinger';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Teken met je vinger op het papier; als dit uit staat, tekent alleen de stylus (standaard uit)';

  @override
  String get settingsGestureInkEditing => 'Gebaren-inktbewerking';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Streep over OCR-geïndexeerde inkt om die te wissen (standaard aan)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Houd de zijknop van de S Pen ingedrukt om tijdelijk van gereedschap te wisselen. Laat los om je vorige gereedschap te herstellen. Werkt op Samsung-apparaten met ondersteuning voor de zijknop.';

  @override
  String get settingsSpenBarrelAction => 'Actie zijknop';

  @override
  String get settingsSectionOcrDictionary => 'OCR-woordenlijst';

  @override
  String get settingsOcrDictionaryHint =>
      'Vaktermen voor handschriftherkenning. Bijna-matches worden gecorrigeerd wanneer inkt wordt geïndexeerd, en termen verbeteren het zoeken in notitieboeken.';

  @override
  String get settingsNoCustomOcrTerms => 'Nog geen aangepaste termen.';

  @override
  String get settingsRemoveOcrTerm => 'Term verwijderen';

  @override
  String get settingsAddOcrTerm => 'Term toevoegen';

  @override
  String get settingsAddOcrTermTitle => 'OCR-term toevoegen';

  @override
  String get settingsOcrTermLabel => 'Term';

  @override
  String get settingsOcrTermHint => 'bijv. eigenwaarde, mitochondrium';

  @override
  String get settingsSectionYourData => 'Je gegevens';

  @override
  String get settingsYourDataHint =>
      'Penfold slaat alles op dit apparaat op in één SQLite-database en assetmappen — geen cloudsynchronisatie. Zie docs/ARCHITECTURE.md voor de volledige lokale bestandsstructuur.';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsSectionBackupRestore => 'Back-up & herstel';

  @override
  String get settingsBackupRestoreHint =>
      'Exporteer een zip van penfold.db en assetmappen, of herstel vanuit een eerdere back-up. Je huidige database wordt vóór het herstel opgeslagen in backups/.';

  @override
  String get settingsExportBackup => 'Back-up exporteren';

  @override
  String get settingsExportBackupSubtitle =>
      'Zip penfold.db, PDF-bronnen, afbeeldingen en legacy PDF-pagina\'s';

  @override
  String get settingsRecoverFromBackup => 'Herstellen vanuit back-up';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Laatste automatische back-up: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Back-up terugzetten';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Vervang lokale gegevens door een Penfold-back-up-zip';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Herstellen vanuit automatische back-up?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Dit vervangt je huidige notitieboeken en bestanden door de back-up van $timestamp. Je huidige database wordt vóór het herstel opgeslagen in backups/.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Back-up terugzetten?';

  @override
  String get settingsRestoreBackupBody =>
      'Dit vervangt je huidige notitieboeken en bestanden. Je huidige database wordt vóór het herstel opgeslagen in backups/.';

  @override
  String get settingsSectionAbout => 'Over';

  @override
  String get settingsAboutSubtitle =>
      'Lokaal notitieboek voor handschrift — geen accounts, geen cloud.';

  @override
  String settingsVersion(String version) {
    return 'Versie $version';
  }

  @override
  String get spenActionEraser => 'Gum';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Pen';

  @override
  String get spenActionNone => 'Geen';

  @override
  String get toolPen => 'Pen';

  @override
  String get toolHighlighter => 'Markeerstift';

  @override
  String get toolTape => 'Tape';

  @override
  String get toolEraser => 'Gum';

  @override
  String get toolSelection => 'Selectie';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Vorm';

  @override
  String get toolFill => 'Vulling';

  @override
  String get toolText => 'Tekst';

  @override
  String get toolInsertImage => 'Afbeelding invoegen';

  @override
  String get brushPen => 'Pen';

  @override
  String get brushFountain => 'Vulpen';

  @override
  String get brushPencil => 'Potlood';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Kalligrafie';

  @override
  String get toolbarPreviousBookmark => 'Vorige bladwijzer';

  @override
  String get toolbarNextBookmark => 'Volgende bladwijzer';

  @override
  String get toolbarConvertToText => 'Omzetten naar tekst';

  @override
  String get toolbarCopy => 'Kopiëren';

  @override
  String get toolbarDelete => 'Verwijderen';

  @override
  String get toolbarPaste => 'Plakken';

  @override
  String get toolbarUndo => 'Ongedaan maken';

  @override
  String get toolbarRedo => 'Opnieuw';

  @override
  String get toolbarAddPage => 'Pagina toevoegen';

  @override
  String get toolbarStylusOnly => 'Alleen stylus (handpalm-afwijzing)';

  @override
  String get toolbarFingerDrawing => 'Tekenen met vinger';

  @override
  String get toolbarPageOverview => 'Pagina-overzicht';

  @override
  String get toolbarTableOfContents => 'Inhoudsopgave';

  @override
  String get toolbarPageMenu => 'Paginamenu';

  @override
  String get penOptionsTitle => 'Pen';

  @override
  String get highlighterOptionsTitle => 'Markeerstift';

  @override
  String get brushLabel => 'Penseel';

  @override
  String get colorLabel => 'Kleur';

  @override
  String get customColorTitle => 'Aangepaste kleur';

  @override
  String get hueLabel => 'Tint';

  @override
  String get saturationLabel => 'Verzadiging';

  @override
  String get brightnessLabel => 'Helderheid';

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
  String get tapeOptionsHint =>
      'Teken om notities af te dekken; tik op tape om opnieuw te tonen of te verbergen';

  @override
  String get fillColorTitle => 'Vulkleur';

  @override
  String get fillOptionsHint =>
      'Teken een gesloten lus, of tik binnen een vorm om te vullen';

  @override
  String get eraserSizeTitle => 'Grootte gum';

  @override
  String get eraserModeTitle => 'Gummodus';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Lijn';

  @override
  String get eraserModePartialHint => 'Wist alleen inkt onder de gumcirkel';

  @override
  String get eraserModeWholeStrokeHint => 'Wist hele lijnen die worden geraakt';

  @override
  String get eraseAllOnPageTitle => 'Alles op pagina wissen?';

  @override
  String get eraseAllOnPageBody =>
      'Dit verwijdert elke lijn op de huidige pagina. Je kunt deze actie ongedaan maken.';

  @override
  String get eraseAllOnPageButton => 'Alles op pagina wissen';

  @override
  String get pageSettingsTitle => 'Pagina-instellingen';

  @override
  String get pageColorTitle => 'Paginakleur';

  @override
  String get pageThemeTitle => 'Paginathema';

  @override
  String get defaultPaperSize => 'Standaard papierformaat';

  @override
  String get defaultPaperType => 'Standaard papiertype';

  @override
  String get defaultPageTheme => 'Standaard paginathema';

  @override
  String get notebookDefaultsHint =>
      'Gebruikt wanneer je een nieuw notitieboek maakt. Je kunt keuzes nog steeds wijzigen in het dialoogvenster.';

  @override
  String get pageThemeLight => 'Licht';

  @override
  String get pageThemeDark => 'Donker';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastelroze';

  @override
  String get pageThemePastelBlue => 'Pastelblauw';

  @override
  String get pageThemePastelMint => 'Pastelmunt';

  @override
  String get pageSizeTitle => 'Paginaformaat';

  @override
  String get pageOrientationTitle => 'Richting';

  @override
  String get pageTemplateTitle => 'Paginasjabloon';

  @override
  String get pageBookmark => 'Bladwijzer';

  @override
  String get pageRemoveBookmark => 'Bladwijzer verwijderen';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Splitsen';

  @override
  String get pageExportTitle => 'Exporteren';

  @override
  String get pdfPagesKeepBackground =>
      'PDF-pagina\'s behouden hun documentachtergrond';

  @override
  String get pdfPagesKeepDimensions =>
      'PDF-pagina\'s behouden hun documentafmetingen';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF-pagina\'s behouden hun documentoriëntatie';

  @override
  String get exportPageAsPng => 'Pagina exporteren als PNG';

  @override
  String get exportPageAsPngSubtitle => 'Deel afbeelding van deze pagina';

  @override
  String get exportPageAsPdf => 'Pagina exporteren als PDF';

  @override
  String get exportPageAsPdfSubtitle => 'Vectorinkt, delen via deelmenu';

  @override
  String get exportNotebookAsPdf => 'Notitieboek exporteren als PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagina\'s',
      one: '1 pagina',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Audiobestand bijvoegen';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV en andere lokale formaten';

  @override
  String get pageAudioAttachedToPage => 'Bijgevoegd aan deze pagina';

  @override
  String get pageAudioReplace => 'Audiobestand vervangen';

  @override
  String get pageAudioRemove => 'Audio verwijderen';

  @override
  String get pageAudioPlay => 'Afspelen';

  @override
  String get pageAudioPause => 'Pauzeren';

  @override
  String get contentsTitle => 'Inhoud';

  @override
  String get contentsSubtitle =>
      'Koppen uit getypte tekst en OCR-geïndexeerde inkt';

  @override
  String get contentsEmpty =>
      'Nog geen koppen gevonden.\nVoeg grote of korte getypte tekst toe, of OCR-geïndexeerde inktkoppen.';

  @override
  String contentsPageNumber(int number) {
    return 'Pagina $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Pagina\'s';

  @override
  String pageOverviewSelected(int count) {
    return '$count geselecteerd';
  }

  @override
  String get pageOverviewDeleteSelected => 'Geselecteerde verwijderen';

  @override
  String get pageOverviewSelectPages => 'Pagina\'s selecteren';

  @override
  String get pageOverviewKeepOnePage => 'Houd minstens één pagina';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagina\'s',
      one: '1 pagina',
    );
    return '$_temp0 verwijderen?';
  }

  @override
  String get pageOverviewDeleteBody => 'Dit kan niet ongedaan worden gemaakt.';

  @override
  String get pageOverviewDragToReorder => 'Sleep om te herschikken';

  @override
  String get pageOverviewBookmarked => 'Met bladwijzer';

  @override
  String get ocrIndexing => 'OCR-indexering…';

  @override
  String get ocrHandwritingSearchable => 'Handschift doorzoekbaar';

  @override
  String get ocrPartial => 'OCR gedeeltelijk';

  @override
  String get trashTitle => 'Prullenbak';

  @override
  String trashFailedToLoad(String error) {
    return 'De prullenbak kon niet worden geladen: $error';
  }

  @override
  String get trashEmpty => 'De prullenbak is leeg';

  @override
  String get trashSectionFolders => 'Mappen';

  @override
  String get trashSectionNotebooks => 'Notitieboeken';

  @override
  String get trashDeletionDateUnavailable =>
      'Verwijderingsdatum niet beschikbaar';

  @override
  String get trashExpiresToday => 'Verloopt vandaag';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dagen resterend',
      one: '1 dag resterend',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Terugzetten';

  @override
  String trashDeleteNotebookTitle(String title) {
    return '\"$title\" permanent verwijderen?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Dit verwijdert het notitieboek en alle pagina\'s van dit apparaat.';

  @override
  String trashDeleteFolderTitle(String name) {
    return '\"$name\" permanent verwijderen?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Dit verwijdert de map en bijbehorende notitieboeken van dit apparaat.';

  @override
  String get splitPageTitle => 'Pagina splitsen?';

  @override
  String splitPageBody(int count) {
    return 'Maak een nieuwe pagina met dezelfde sjabloon en verplaats ongeveer de helft van de $count lijnen ernaartoe.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Minstens 2 lijnen nodig om deze pagina te splitsen';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Pagina gesplitst: $moved lijnen verplaatst, $remaining blijven over';
  }

  @override
  String splitPageFailed(String error) {
    return 'Splitsen mislukt: $error';
  }

  @override
  String get splitPageAction => 'Pagina splitsen';

  @override
  String get changePageSizeTitle => 'Paginaformaat wijzigen?';

  @override
  String get changePageSizeBody =>
      'Deze pagina bevat inkt. Het wijzigen van het formaat herlegt de pagina; je inkt blijft op dezelfde positie op de pagina.';

  @override
  String get changeOrientationTitle => 'Richting wijzigen?';

  @override
  String get changeOrientationBody =>
      'Deze pagina bevat inkt. Het wijzigen van de richting schaalt en centreert je inhoud zodat die binnen de nieuwe paginagrenzen past.';

  @override
  String convertedToText(String preview) {
    return 'Omgezet naar tekst: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'Handschrift kon niet worden herkend';

  @override
  String get handwritingModelTitle => 'Handschriftmodel';

  @override
  String get handwritingModelDownloadFailed =>
      'Download mislukt. Controleer netwerk en probeer opnieuw.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Engels handschriftmodel downloaden (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Model gereed.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Verstreken: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Eerste download (~$sizeMb MB). Duurt meestal minder dan twee minuten via Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Pagina geëxporteerd als PNG';

  @override
  String get pageExportedAsPdf => 'Pagina geëxporteerd als PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Notitieboek geëxporteerd als PDF';

  @override
  String get exportPreparing => 'Export voorbereiden…';

  @override
  String exportProgress(int current, int total) {
    return 'Pagina $current van $total exporteren…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Deze pagina heeft $count lijnen en kan traag aanvoelen. Overweeg om te splitsen voor betere prestaties.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Export geblokkeerd: een pagina heeft $count lijnen (limiet $limit). Splits zware pagina\'s eerst.';
  }

  @override
  String get restoreComplete =>
      'Herstel voltooid. Start de app opnieuw om de herstelde gegevens te laden.';

  @override
  String get textToolHint => 'Typ hier…';

  @override
  String get textToolDone => 'Klaar';

  @override
  String get languageKorean => 'Koreaans';

  @override
  String get languagePolish => 'Pools';

  @override
  String get languageSpanish => 'Spaans';

  @override
  String get languageItalian => 'Italiaans';

  @override
  String get languageUkrainian => 'Oekraïens';

  @override
  String get languageSwedish => 'Zweeds';

  @override
  String get languageNorwegian => 'Noors';

  @override
  String get languageFinnish => 'Fins';

  @override
  String get languageDanish => 'Deens';

  @override
  String get languagePortuguese => 'Portugees';
}
