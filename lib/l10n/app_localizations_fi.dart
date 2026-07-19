// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Peruuta';

  @override
  String get actionCreate => 'Luo';

  @override
  String get actionRename => 'Nimeä uudelleen';

  @override
  String get actionSave => 'Tallenna';

  @override
  String get actionDelete => 'Poista';

  @override
  String get actionAdd => 'Lisää';

  @override
  String get actionBack => 'Takaisin';

  @override
  String get actionDone => 'Valmis';

  @override
  String get actionSplit => 'Jaa';

  @override
  String get actionRecover => 'Palauta kopio';

  @override
  String get actionRestore => 'Palauta tiedot';

  @override
  String get actionExport => 'Vie';

  @override
  String get actionRetry => 'Yritä uudelleen';

  @override
  String get actionRetrying => 'Yritetään uudelleen…';

  @override
  String get actionExportFirst => 'Vie ensin';

  @override
  String get actionEraseAll => 'Pyyhi kaikki';

  @override
  String get actionChangeSize => 'Vaihda koko';

  @override
  String get actionChangeOrientation => 'Vaihda suunta';

  @override
  String get actionUseColor => 'Käytä väriä';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Yleiskatsaus';

  @override
  String get libraryTrash => 'Roskakori';

  @override
  String get librarySettings => 'Asetukset';

  @override
  String get libraryFolders => 'Kansiot';

  @override
  String get libraryNoFoldersYet => 'Ei kansioita vielä';

  @override
  String get libraryAll => 'Kaikki';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Luokittelemattomat';

  @override
  String get libraryBreadcrumb => 'Kirjasto';

  @override
  String get librarySearchHint =>
      'Hae muistikirjoista ja kirjoitetusta tekstistä…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Ei tuloksia';

  @override
  String get libraryFolderEmpty => 'Tämä kansio on tyhjä';

  @override
  String get libraryNoNotebooksWithTag => 'Ei muistikirjoja tällä tunnisteella';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Ei luokittelemattomia muistikirjoja';

  @override
  String get libraryNoNotebooksYet => 'Ei muistikirjoja vielä';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Kirjastoa ei voitu ladata: $error';
  }

  @override
  String get tooltipBackupRestore => 'Varmuuskopiointi ja palautus';

  @override
  String get tooltipTrash => 'Roskakori';

  @override
  String get tooltipNewNotebook => 'Uusi muistikirja';

  @override
  String get tooltipNewFolder => 'Uusi kansio';

  @override
  String get tooltipNewSubfolder => 'Uusi alikansio';

  @override
  String get tooltipImportPdf => 'Tuo PDF';

  @override
  String get folderNew => 'Uusi kansio';

  @override
  String get folderNewSubfolder => 'Uusi alikansio';

  @override
  String get folderRename => 'Nimeä kansio uudelleen';

  @override
  String get folderMoveToTrash => 'Siirrä roskakoriin';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Siirretäänkö \"$name\" roskakoriin?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Kansio ja sen muistikirjat siirtyvät roskakoriin 30 päiväksi.';

  @override
  String get notebookNew => 'Uusi muistikirja';

  @override
  String get notebookUntitled => 'Nimetön';

  @override
  String get notebookTitleLabel => 'Otsikko';

  @override
  String get notebookSizeLabel => 'Koko';

  @override
  String get notebookPaperLabel => 'Paperi';

  @override
  String get notebookCoverLabel => 'Kansi';

  @override
  String get notebookRename => 'Nimeä muistikirja uudelleen';

  @override
  String get notebookMoveToFolder => 'Siirrä kansioon';

  @override
  String get notebookEditTags => 'Muokkaa tunnisteita';

  @override
  String get notebookExportWorkbook => 'Vie muistikirja';

  @override
  String get notebookExportWorkbookSubtitle => 'Jaa kaikki sivut PDF:nä';

  @override
  String get notebookMoveToTrash => 'Siirrä roskakoriin';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Siirretäänkö \"$title\" roskakoriin?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Muistikirja piilotetaan kirjastosta 30 päiväksi. Muste ja sivut säilyvät laitteella, kunnes roskakori tyhjennetään. Vie varmuuskopio ensin, jos haluat ylimääräisen kopion.';

  @override
  String notebookTagsFor(String title) {
    return 'Tunnisteet kohteelle \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'Ei tunnisteita vielä. Luo uusi alla.';

  @override
  String get notebookNewTag => 'Uusi tunniste';

  @override
  String get notebookAddTag => 'Lisää tunniste';

  @override
  String get notebookNoPagesToExport =>
      'Tässä muistikirjassa ei ole vietäviä sivuja';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" viety PDF:nä';
  }

  @override
  String get notebookBackupExportedReady =>
      'Varmuuskopio viety. Voit siirtää roskakoriin, kun olet valmis.';

  @override
  String get importPdfSnack =>
      'Tuodaan PDF… sivut renderöidään kerran ja pysyvät sen jälkeen offline-tilassa.';

  @override
  String importFailed(String error) {
    return 'Tuonti epäonnistui: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Vienti epäonnistui: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Varmuuskopiointi epäonnistui: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Automaattinen palautus epäonnistui: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Varmuuskopion palautus epäonnistui: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Ladataan käsialamallia (~$sizeMb Mt) taustalla…';
  }

  @override
  String get templateBlank => 'Tyhjä';

  @override
  String get templateLined => 'Viivallinen';

  @override
  String get templateGrid => 'Ruudukko';

  @override
  String get templateDotted => 'Pisteviivallinen';

  @override
  String get templateCollegeRuled => 'College-viivallinen';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Pysty';

  @override
  String get orientationLandscape => 'Vaaka';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Asetukset';

  @override
  String get settingsSectionLanguage => 'Kieli';

  @override
  String get settingsSectionAppearanceAndPreferences => 'Ulkoasu ja asetukset';

  @override
  String get settingsSectionAppearance => 'Ulkoasu';

  @override
  String get settingsAppearanceDarkMode => 'Tumma tila';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Valitse vaalea, tumma tai seuraa laitetta (järjestelmäoletus)';

  @override
  String get themeSystem => 'Järjestelmä';

  @override
  String get themeLight => 'Vaalea';

  @override
  String get themeDark => 'Tumma';

  @override
  String get settingsSectionPreferences => 'Valinnat';

  @override
  String get settingsLanguageLabel => 'Sovelluksen kieli';

  @override
  String get languageEnglish => 'Englanti';

  @override
  String get languageGerman => 'Saksa';

  @override
  String get languageFrench => 'Ranska';

  @override
  String get languageDutch => 'Hollanti';

  @override
  String get settingsSectionToolbar => 'Työkalupalkki';

  @override
  String get settingsToolbarReorderHint =>
      'Järjestä piirtotyökalut vetämällä. Kumoa ja tee uudelleen pysyvät oikealla.';

  @override
  String get settingsResetToolbarOrder => 'Palauta työkalupalkin järjestys';

  @override
  String get settingsSectionNotebook => 'Muistikirja';

  @override
  String get settingsPageTurnMode => 'Sivunvaihtotila';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Pyyhkäise yksi sivu kerrallaan jatkuvan vierityksen sijaan (oletus pois päältä)';

  @override
  String get settingsZoomNavigation => 'Zoomauksen navigointi';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Zoomaa ja panoroi sivuja nipistämällä (oletus päällä)';

  @override
  String get settingsSectionDrawing => 'Piirtäminen';

  @override
  String get settingsStrokeSmoothing => 'Piirron tasoitus';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Pehmentää piirtojen kulmia automaattisesti (oletus päällä)';

  @override
  String get settingsStrokeSmoothingStrength => 'Tasoituksen voimakkuus';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent % — alempi säilyttää hienommat yksityiskohdat; suositus $recommended %';
  }

  @override
  String get settingsFingerDrawing => 'Piirtäminen sormella';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Piirrä sormella; kun pois päältä, vain kynä piirtää (oletus pois päältä)';

  @override
  String get settingsGestureInkEditing => 'Musteen muokkaus eleillä';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Raaputa OCR-indeksoidun musteen päällä pyyhkiäksesi sen (oletus päällä)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Pidä S Penin sivupainiketta pohjassa vaihtaaksesi työkalua tilapäisesti. Päästä irti palauttaaksesi edellisen työkalun. Toimii Samsung-laitteilla, joissa on sivupainiketuki.';

  @override
  String get settingsSpenBarrelAction => 'Sivupainikkeen toiminto';

  @override
  String get settingsSectionOcrDictionary => 'OCR-sanasto';

  @override
  String get settingsOcrDictionaryHint =>
      'OCR:iin erikoistuneet termit käsialan tunnistukseen. Lähellä olevat osumat korjataan musteen indeksoinnissa, ja termit parantavat muistikirjahakua.';

  @override
  String get settingsNoCustomOcrTerms => 'Ei mukautettuja termejä vielä.';

  @override
  String get settingsRemoveOcrTerm => 'Poista termi';

  @override
  String get settingsAddOcrTerm => 'Lisää termi';

  @override
  String get settingsAddOcrTermTitle => 'Lisää OCR-termi';

  @override
  String get settingsOcrTermLabel => 'Termi';

  @override
  String get settingsOcrTermHint => 'esim. ominaisarvo, mitochondria';

  @override
  String get settingsSectionYourData => 'Tietosi';

  @override
  String get settingsYourDataHint =>
      'Penfold tallentaa kaiken tälle laitteelle yhteen SQLite-tietokantaan ja resurssikansioihin — ei pilvisynkronointia. Katso docs/ARCHITECTURE.md täydellisestä paikallisesta tiedostorakenteesta.';

  @override
  String get settingsDatabase => 'Tietokanta';

  @override
  String get settingsSectionBackupRestore => 'Varmuuskopiointi ja palautus';

  @override
  String get settingsBackupRestoreHint =>
      'Vie zip-tiedosto penfold.db:stä ja resurssikansioista tai palauta aiemmasta varmuuskopiosta. Nykyinen tietokanta tallennetaan backups/-kansioon ennen palautusta.';

  @override
  String get settingsExportBackup => 'Vie varmuuskopio';

  @override
  String get settingsExportBackupSubtitle =>
      'Pakkaa zip-tiedostoksi penfold.db, PDF-lähteet, kuvat ja vanhat PDF-sivut';

  @override
  String get settingsRecoverFromBackup => 'Palauta varmuuskopiosta';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Viimeisin automaattinen varmuuskopio: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Palauta varmuuskopio';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Korvaa paikalliset tiedot Penfold-varmuuskopio-zipillä';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Palautetaanko automaattisesta varmuuskopiosta?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Tämä korvaa nykyiset muistikirjat ja tiedostot varmuuskopiosta $timestamp. Nykyinen tietokanta tallennetaan backups/-kansioon ennen palautusta.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Palautetaanko varmuuskopio?';

  @override
  String get settingsRestoreBackupBody =>
      'Tämä korvaa nykyiset muistikirjat ja tiedostot. Nykyinen tietokanta tallennetaan backups/-kansioon ennen palautusta.';

  @override
  String get settingsSectionAbout => 'Tietoja';

  @override
  String get settingsAboutSubtitle =>
      'Paikallinen käsialamuistikirja — ei tilejä, ei pilveä.';

  @override
  String settingsVersion(String version) {
    return 'Versio $version';
  }

  @override
  String get spenActionEraser => 'Pyyhekumi';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Kynä';

  @override
  String get spenActionNone => 'Ei toimintoa';

  @override
  String get toolPen => 'Kynä';

  @override
  String get toolHighlighter => 'Korostuskynä';

  @override
  String get toolTape => 'Teippi';

  @override
  String get toolEraser => 'Pyyhekumi';

  @override
  String get toolSelection => 'Aluevalinta';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Muoto';

  @override
  String get toolFill => 'Täytä';

  @override
  String get toolText => 'Teksti';

  @override
  String get toolInsertImage => 'Lisää kuva';

  @override
  String get brushPen => 'Kynä';

  @override
  String get brushFountain => 'Täytekynä';

  @override
  String get brushPencil => 'Lyijykynä';

  @override
  String get brushMarker => 'Tussi';

  @override
  String get brushCalligraphy => 'Kalligrafia';

  @override
  String get toolbarPreviousBookmark => 'Edellinen kirjanmerkki';

  @override
  String get toolbarNextBookmark => 'Seuraava kirjanmerkki';

  @override
  String get toolbarConvertToText => 'Muunna tekstiksi';

  @override
  String get toolbarCopy => 'Kopioi';

  @override
  String get toolbarDelete => 'Poista';

  @override
  String get toolbarPaste => 'Liitä';

  @override
  String get toolbarUndo => 'Kumoa';

  @override
  String get toolbarRedo => 'Tee uudelleen';

  @override
  String get toolbarAddPage => 'Lisää sivu';

  @override
  String get toolbarStylusOnly => 'Vain kynä (kämmenen hylkäys)';

  @override
  String get toolbarFingerDrawing => 'Piirtäminen sormella';

  @override
  String get toolbarPageOverview => 'Sivujen yleiskatsaus';

  @override
  String get toolbarTableOfContents => 'Sisällysluettelo';

  @override
  String get toolbarPageMenu => 'Sivuvalikko';

  @override
  String get penOptionsTitle => 'Kynä';

  @override
  String get highlighterOptionsTitle => 'Korostuskynä';

  @override
  String get brushLabel => 'Kynätyyli';

  @override
  String get colorLabel => 'Väri';

  @override
  String get customColorTitle => 'Mukautettu väri';

  @override
  String get hueLabel => 'Sävy';

  @override
  String get saturationLabel => 'Kylläisyys';

  @override
  String get brightnessLabel => 'Kirkkaus';

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
  String get tapeOptionsTitle => 'Teippi';

  @override
  String get tapeOptionsHint =>
      'Piirrä peittääksesi muistiinpanot; napauta teippiä paljastaaksesi tai piilottaaksesi ne uudelleen';

  @override
  String get fillColorTitle => 'Täyttöväri';

  @override
  String get fillOptionsHint =>
      'Piirrä suljettu muoto tai napauta muodon sisällä täyttääksesi';

  @override
  String get eraserSizeTitle => 'Pyyhekumin koko';

  @override
  String get eraserModeTitle => 'Pyyhekumitila';

  @override
  String get eraserModePixel => 'Pikseli';

  @override
  String get eraserModeStroke => 'Piirto';

  @override
  String get eraserModePartialHint => 'Pyyhkii vain musteen pyyhtimen alla';

  @override
  String get eraserModeWholeStrokeHint =>
      'Pyyhkii kokonaiset piirrot, joihin se osuu';

  @override
  String get eraseAllOnPageTitle => 'Pyyhitäänkö kaikki sivulta?';

  @override
  String get eraseAllOnPageBody =>
      'Tämä poistaa kaikki piirrot nykyiseltä sivulta. Voit kumota tämän toiminnon.';

  @override
  String get eraseAllOnPageButton => 'Pyyhi kaikki sivulta';

  @override
  String get pageSettingsTitle => 'Sivun asetukset';

  @override
  String get pageColorTitle => 'Sivun väri';

  @override
  String get pageThemeTitle => 'Sivun teema';

  @override
  String get defaultPaperSize => 'Paperin oletuskoko';

  @override
  String get defaultPaperType => 'Paperin oletustyyppi';

  @override
  String get defaultPageTheme => 'Sivun oletusteema';

  @override
  String get notebookDefaultsHint =>
      'Käytetään, kun luot uuden muistikirjan. Voit silti muuttaa valintoja valintaikkunassa.';

  @override
  String get pageThemeLight => 'Vaalea';

  @override
  String get pageThemeDark => 'Tumma';

  @override
  String get pageThemeSepia => 'Seepia';

  @override
  String get pageThemePastelPink => 'Pastellinen vaaleanpunainen';

  @override
  String get pageThemePastelBlue => 'Pastellinen sininen';

  @override
  String get pageThemePastelMint => 'Pastellinen minttu';

  @override
  String get pageSizeTitle => 'Sivun koko';

  @override
  String get pageOrientationTitle => 'Suunta';

  @override
  String get pageTemplateTitle => 'Sivupohja';

  @override
  String get pageBookmark => 'Kirjanmerkki';

  @override
  String get pageRemoveBookmark => 'Poista kirjanmerkki';

  @override
  String get pageAudioTitle => 'Ääni';

  @override
  String get pageSplit => 'Jaa';

  @override
  String get pageExportTitle => 'Vie';

  @override
  String get pdfPagesKeepBackground =>
      'PDF-sivut säilyttävät asiakirjan taustan';

  @override
  String get pdfPagesKeepDimensions => 'PDF-sivut säilyttävät asiakirjan mitat';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF-sivut säilyttävät asiakirjan suunnan';

  @override
  String get exportPageAsPng => 'Vie sivu PNG:nä';

  @override
  String get exportPageAsPngSubtitle => 'Jaa kuva tästä sivusta';

  @override
  String get exportPageAsPdf => 'Vie sivu PDF:nä';

  @override
  String get exportPageAsPdfSubtitle =>
      'Vektorimuste; jaa järjestelmän jakoikkunan kautta';

  @override
  String get exportNotebookAsPdf => 'Vie muistikirja PDF:nä';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sivua',
      one: '1 sivu',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Liitä äänitiedosto';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV ja muut paikalliset muodot';

  @override
  String get pageAudioAttachedToPage => 'Liitetty tälle sivulle';

  @override
  String get pageAudioReplace => 'Korvaa äänitiedosto';

  @override
  String get pageAudioRemove => 'Poista ääni';

  @override
  String get pageAudioPlay => 'Toista';

  @override
  String get pageAudioPause => 'Tauko';

  @override
  String get contentsTitle => 'Sisällys';

  @override
  String get contentsSubtitle =>
      'Otsikot kirjoitetusta tekstistä ja OCR-indeksoidusta käsialasta';

  @override
  String get contentsEmpty =>
      'Otsikoita ei löytynyt vielä.\nLisää suurta tai lyhyttä kirjoitettua tekstiä tai OCR-indeksoituja käsialan otsikoita.';

  @override
  String contentsPageNumber(int number) {
    return 'Sivu $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Sivut';

  @override
  String pageOverviewSelected(int count) {
    return 'Valittu: $count';
  }

  @override
  String get pageOverviewDeleteSelected => 'Poista valitut';

  @override
  String get pageOverviewSelectPages => 'Valitse sivut';

  @override
  String get pageOverviewKeepOnePage => 'Pidä vähintään yksi sivu';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sivua',
      one: '1 sivu',
    );
    return 'Poistetaanko $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Tätä ei voi kumota.';

  @override
  String get pageOverviewDragToReorder => 'Järjestä uudelleen vetämällä';

  @override
  String get pageOverviewBookmarked => 'Kirjanmerkitty';

  @override
  String get ocrIndexing => 'OCR-indeksointi…';

  @override
  String get ocrHandwritingSearchable => 'Käsialahaku käytössä';

  @override
  String get ocrPartial => 'OCR osittain valmis';

  @override
  String get trashTitle => 'Roskakori';

  @override
  String trashFailedToLoad(String error) {
    return 'Roskakorin lataus epäonnistui: $error';
  }

  @override
  String get trashEmpty => 'Roskakori on tyhjä';

  @override
  String get trashSectionFolders => 'Kansiot';

  @override
  String get trashSectionNotebooks => 'Muistikirjat';

  @override
  String get trashDeletionDateUnavailable => 'Poistopäivä ei saatavilla';

  @override
  String get trashExpiresToday => 'Vanhenee tänään';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count päivää jäljellä',
      one: '1 päivä jäljellä',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Palauta';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Poistetaanko \"$title\" pysyvästi?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Tämä poistaa muistikirjan ja kaikki sivut tältä laitteelta.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Poistetaanko \"$name\" pysyvästi?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Tämä poistaa kansion ja sen muistikirjat tältä laitteelta.';

  @override
  String get splitPageTitle => 'Jaetaanko sivu?';

  @override
  String splitPageBody(int count) {
    return 'Luo uusi sivu samalla pohjalla ja siirrä noin puolet $count piirrosta sille.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Tarvitaan vähintään 2 piirtoa sivun jakamiseen';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Sivu jaettu: $moved piirtoa siirretty, $remaining jäljellä';
  }

  @override
  String splitPageFailed(String error) {
    return 'Jako epäonnistui: $error';
  }

  @override
  String get splitPageAction => 'Jaa sivu';

  @override
  String get changePageSizeTitle => 'Vaihdetaanko sivun kokoa?';

  @override
  String get changePageSizeBody =>
      'Tällä sivulla on mustetta. Koon vaihtaminen järjestää sivun uudelleen; muste pysyy samassa kohdassa.';

  @override
  String get changeOrientationTitle => 'Vaihdetaanko suuntaa?';

  @override
  String get changeOrientationBody =>
      'Tällä sivulla on mustetta. Suunnan vaihtaminen skaalaa ja keskittää sisällön uusiin sivurajoihin.';

  @override
  String convertedToText(String preview) {
    return 'Muunnettu tekstiksi: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => 'Käsialaa ei voitu tunnistaa';

  @override
  String get handwritingModelTitle => 'Käsialamalli';

  @override
  String get handwritingModelDownloadFailed =>
      'Lataus epäonnistui. Tarkista verkko ja yritä uudelleen.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Ladataan englanninkielistä käsialamallia (~$sizeMb Mt)…';
  }

  @override
  String get handwritingModelReady => 'Malli valmis.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Kulunut: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Ensimmäinen lataus (~$sizeMb Mt). Wi-Fi-yhteydellä yleensä alle kaksi minuuttia.';
  }

  @override
  String get pageExportedAsPng => 'Sivu viety PNG:nä';

  @override
  String get pageExportedAsPdf => 'Sivu viety PDF:nä';

  @override
  String get notebookExportedAsPdfSnack => 'Muistikirja viety PDF:nä';

  @override
  String get exportPreparing => 'Valmistellaan vientiä…';

  @override
  String exportProgress(int current, int total) {
    return 'Viedään sivu $current/$total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Tällä sivulla on $count piirtoa, ja se voi tuntua hitaalta. Harkitse jakamista paremman suorituskyvyn vuoksi.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Vienti estetty: sivulla on $count piirtoa (raja $limit). Jaa raskaat sivut ensin.';
  }

  @override
  String get restoreComplete =>
      'Palautus valmis. Käynnistä sovellus uudelleen ladataksesi palautetut tiedot.';

  @override
  String get textToolHint => 'Kirjoita tähän…';

  @override
  String get textToolDone => 'Valmis';

  @override
  String get languageKorean => 'Korea';

  @override
  String get languagePolish => 'Puola';

  @override
  String get languageSpanish => 'Espanja';

  @override
  String get languageItalian => 'Italia';

  @override
  String get languageUkrainian => 'Ukraina';

  @override
  String get languageSwedish => 'Ruotsi';

  @override
  String get languageNorwegian => 'Norja';

  @override
  String get languageFinnish => 'Suomi';

  @override
  String get languageDanish => 'Tanska';

  @override
  String get languagePortuguese => 'Portugali';
}
