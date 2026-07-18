// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionCreate => 'Erstellen';

  @override
  String get actionRename => 'Umbenennen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionSplit => 'Teilen';

  @override
  String get actionRecover => 'Wiederherstellen';

  @override
  String get actionRestore => 'Zurücksetzen';

  @override
  String get actionExport => 'Exportieren';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionRetrying => 'Wird wiederholt…';

  @override
  String get actionExportFirst => 'Zuerst exportieren';

  @override
  String get actionEraseAll => 'Alles löschen';

  @override
  String get actionChangeSize => 'Größe ändern';

  @override
  String get actionChangeOrientation => 'Ausrichtung ändern';

  @override
  String get actionUseColor => 'Farbe verwenden';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Übersicht';

  @override
  String get libraryTrash => 'Papierkorb';

  @override
  String get librarySettings => 'Einstellungen';

  @override
  String get libraryFolders => 'Ordner';

  @override
  String get libraryNoFoldersYet => 'Noch keine Ordner';

  @override
  String get libraryAll => 'Alle';

  @override
  String get libraryUncategorized => 'Ohne Kategorie';

  @override
  String get libraryBreadcrumb => 'Bibliothek';

  @override
  String get librarySearchHint => 'Notizbücher und getippten Text durchsuchen…';

  @override
  String get libraryNoMatches => 'Keine Treffer';

  @override
  String get libraryFolderEmpty => 'Dieser Ordner ist leer';

  @override
  String get libraryNoNotebooksWithTag => 'Keine Notizbücher mit diesem Tag';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Keine Notizbücher ohne Kategorie';

  @override
  String get libraryNoNotebooksYet => 'Noch keine Notizbücher';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Bibliothek konnte nicht geladen werden: $error';
  }

  @override
  String get tooltipBackupRestore => 'Sicherung & Wiederherstellung';

  @override
  String get tooltipTrash => 'Papierkorb';

  @override
  String get tooltipNewNotebook => 'Neues Notizbuch';

  @override
  String get tooltipNewFolder => 'Neuer Ordner';

  @override
  String get tooltipNewSubfolder => 'Neuer Unterordner';

  @override
  String get tooltipImportPdf => 'PDF importieren';

  @override
  String get folderNew => 'Neuer Ordner';

  @override
  String get folderNewSubfolder => 'Neuer Unterordner';

  @override
  String get folderRename => 'Ordner umbenennen';

  @override
  String get folderMoveToTrash => 'In Papierkorb verschieben';

  @override
  String folderMoveToTrashTitle(String name) {
    return '„$name“ in Papierkorb verschieben?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Der Ordner und seine Notizbücher werden 30 Tage im Papierkorb aufbewahrt.';

  @override
  String get notebookNew => 'Neues Notizbuch';

  @override
  String get notebookUntitled => 'Ohne Titel';

  @override
  String get notebookTitleLabel => 'Titel';

  @override
  String get notebookSizeLabel => 'Größe';

  @override
  String get notebookPaperLabel => 'Papier';

  @override
  String get notebookCoverLabel => 'Umschlag';

  @override
  String get notebookRename => 'Notizbuch umbenennen';

  @override
  String get notebookMoveToFolder => 'In Ordner verschieben';

  @override
  String get notebookEditTags => 'Tags bearbeiten';

  @override
  String get notebookExportWorkbook => 'Arbeitsmappe exportieren';

  @override
  String get notebookExportWorkbookSubtitle => 'Alle Seiten als PDF teilen';

  @override
  String get notebookMoveToTrash => 'In Papierkorb verschieben';

  @override
  String notebookMoveToTrashTitle(String title) {
    return '„$title“ in Papierkorb verschieben?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Das Notizbuch wird 30 Tage aus der Bibliothek ausgeblendet. Tinte und Seiten bleiben auf diesem Gerät, bis der Papierkorb geleert wird. Exportieren Sie vorher eine Sicherung, wenn Sie eine zusätzliche Kopie möchten.';

  @override
  String notebookTagsFor(String title) {
    return 'Tags für „$title“';
  }

  @override
  String get notebookNoTagsYet => 'Noch keine Tags. Erstellen Sie unten einen.';

  @override
  String get notebookNewTag => 'Neuer Tag';

  @override
  String get notebookAddTag => 'Tag hinzufügen';

  @override
  String get notebookNoPagesToExport =>
      'Dieses Notizbuch hat keine Seiten zum Exportieren';

  @override
  String notebookExportedAsPdf(String title) {
    return '„$title“ als PDF exportiert';
  }

  @override
  String get notebookBackupExportedReady =>
      'Sicherung exportiert. Sie können das Notizbuch verschieben, wenn Sie bereit sind.';

  @override
  String get importPdfSnack =>
      'PDF wird importiert… Seiten werden einmal gerendert und bleiben dann offline.';

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Zurücksetzen fehlgeschlagen: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Handschriftmodell (~$sizeMb MB) wird im Hintergrund heruntergeladen…';
  }

  @override
  String get templateBlank => 'Leer';

  @override
  String get templateLined => 'Liniert';

  @override
  String get templateGrid => 'Kariert';

  @override
  String get templateDotted => 'Gepunktet';

  @override
  String get templateCollegeRuled => 'College-Liniert';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Hochformat';

  @override
  String get orientationLandscape => 'Querformat';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionLanguage => 'Sprache';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Erscheinungsbild & Einstellungen';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get settingsAppearanceDarkMode => 'Dunkelmodus';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Hell, dunkel oder Systemeinstellung verwenden (Standard: System)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get settingsSectionPreferences => 'Präferenzen';

  @override
  String get settingsLanguageLabel => 'App-Sprache';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageDutch => 'Niederländisch';

  @override
  String get settingsSectionToolbar => 'Symbolleiste';

  @override
  String get settingsToolbarReorderHint =>
      'Zeichenwerkzeuge per Drag & Drop sortieren. Rückgängig und Wiederholen bleiben rechts fixiert.';

  @override
  String get settingsResetToolbarOrder =>
      'Symbolleisten-Reihenfolge zurücksetzen';

  @override
  String get settingsSectionNotebook => 'Notizbuch';

  @override
  String get settingsPageTurnMode => 'Blättermodus';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Seite für Seite wischen statt durchgehend scrollen (Standard: aus)';

  @override
  String get settingsZoomNavigation => 'Zoom-Navigation';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Seiten zoomen und verschieben per Pinch (Standard: an)';

  @override
  String get settingsSectionDrawing => 'Zeichnen';

  @override
  String get settingsStrokeSmoothing => 'Strichglättung';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Tintenstriche mit Chaikin-Glättung verbessern (Standard: an)';

  @override
  String get settingsStrokeSmoothingStrength => 'Glättungsstärke';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent % — niedrigere Werte behalten mehr Details; empfohlen $recommended %';
  }

  @override
  String get settingsFingerDrawing => 'Zeichnen mit dem Finger';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Mit dem Finger auf dem Papier zeichnen; ausgeschaltet zeichnet nur der Stift (Standard: aus)';

  @override
  String get settingsGestureInkEditing => 'Gesten-Tintenbearbeitung';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'OCR-indizierte Tinte durchstreichen, um sie zu löschen (Standard: an)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Halten Sie die S-Pen-Seitentaste, um vorübergehend das Werkzeug zu wechseln. Loslassen stellt das vorherige Werkzeug wieder her. Funktioniert auf Samsung-Geräten mit Seitentasten-Unterstützung.';

  @override
  String get settingsSpenBarrelAction => 'Seitentasten-Aktion';

  @override
  String get settingsSectionOcrDictionary => 'OCR-Wörterbuch';

  @override
  String get settingsOcrDictionaryHint =>
      'Fachbegriffe für Handschrift-OCR. Ähnliche Treffer werden bei der Tintenindizierung korrigiert, und Begriffe verbessern die Notizbuchsuche.';

  @override
  String get settingsNoCustomOcrTerms => 'Noch keine eigenen Begriffe.';

  @override
  String get settingsRemoveOcrTerm => 'Begriff entfernen';

  @override
  String get settingsAddOcrTerm => 'Begriff hinzufügen';

  @override
  String get settingsAddOcrTermTitle => 'OCR-Begriff hinzufügen';

  @override
  String get settingsOcrTermLabel => 'Begriff';

  @override
  String get settingsOcrTermHint => 'z. B. Eigenwert, Mitochondrium';

  @override
  String get settingsSectionYourData => 'Ihre Daten';

  @override
  String get settingsYourDataHint =>
      'Penfold speichert alles auf diesem Gerät in einer SQLite-Datenbank und Asset-Ordnern — ohne Cloud-Synchronisation. Siehe docs/ARCHITECTURE.md für die vollständige lokale Dateistruktur.';

  @override
  String get settingsDatabase => 'Datenbank';

  @override
  String get settingsSectionBackupRestore => 'Sicherung & Wiederherstellung';

  @override
  String get settingsBackupRestoreHint =>
      'Exportieren Sie ein Zip mit penfold.db und Asset-Ordnern oder stellen Sie aus einer früheren Sicherung wieder her. Ihre aktuelle Datenbank wird vor dem Zurücksetzen in backups/ gesichert.';

  @override
  String get settingsExportBackup => 'Sicherung exportieren';

  @override
  String get settingsExportBackupSubtitle =>
      'penfold.db, PDF-Quellen, Bilder und ältere PDF-Seiten als Zip';

  @override
  String get settingsRecoverFromBackup => 'Aus Sicherung wiederherstellen';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Neueste Auto-Sicherung: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Sicherung zurücksetzen';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Lokale Daten aus einer Penfold-Sicherungs-Zip ersetzen';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Aus Auto-Sicherung wiederherstellen?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Dies ersetzt Ihre aktuellen Notizbücher und Dateien durch die Sicherung vom $timestamp. Ihre aktuelle Datenbank wird vor dem Zurücksetzen in backups/ gesichert.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Sicherung zurücksetzen?';

  @override
  String get settingsRestoreBackupBody =>
      'Dies ersetzt Ihre aktuellen Notizbücher und Dateien. Ihre aktuelle Datenbank wird vor dem Zurücksetzen in backups/ gesichert.';

  @override
  String get settingsSectionAbout => 'Über';

  @override
  String get settingsAboutSubtitle =>
      'Lokales Handschrift-Notizbuch — ohne Konten, ohne Cloud.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get spenActionEraser => 'Radierer';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Stift';

  @override
  String get spenActionNone => 'Keine';

  @override
  String get toolPen => 'Stift';

  @override
  String get toolHighlighter => 'Textmarker';

  @override
  String get toolTape => 'Abdeckband';

  @override
  String get toolEraser => 'Radierer';

  @override
  String get toolSelection => 'Auswahl';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Form';

  @override
  String get toolFill => 'Füllen';

  @override
  String get toolText => 'Text';

  @override
  String get toolInsertImage => 'Bild einfügen';

  @override
  String get brushPen => 'Stift';

  @override
  String get brushFountain => 'Füller';

  @override
  String get brushPencil => 'Bleistift';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Kalligrafie';

  @override
  String get toolbarPreviousBookmark => 'Vorheriges Lesezeichen';

  @override
  String get toolbarNextBookmark => 'Nächstes Lesezeichen';

  @override
  String get toolbarConvertToText => 'In Text umwandeln';

  @override
  String get toolbarCopy => 'Kopieren';

  @override
  String get toolbarDelete => 'Löschen';

  @override
  String get toolbarPaste => 'Einfügen';

  @override
  String get toolbarUndo => 'Rückgängig';

  @override
  String get toolbarRedo => 'Wiederholen';

  @override
  String get toolbarAddPage => 'Seite hinzufügen';

  @override
  String get toolbarStylusOnly => 'Nur Stift (Handballen-Erkennung)';

  @override
  String get toolbarFingerDrawing => 'Zeichnen mit dem Finger';

  @override
  String get toolbarPageOverview => 'Seitenübersicht';

  @override
  String get toolbarTableOfContents => 'Inhaltsverzeichnis';

  @override
  String get toolbarPageMenu => 'Seitenmenü';

  @override
  String get penOptionsTitle => 'Stift';

  @override
  String get highlighterOptionsTitle => 'Textmarker';

  @override
  String get brushLabel => 'Stiftart';

  @override
  String get colorLabel => 'Farbe';

  @override
  String get customColorTitle => 'Eigene Farbe';

  @override
  String get hueLabel => 'Farbton';

  @override
  String get saturationLabel => 'Sättigung';

  @override
  String get brightnessLabel => 'Helligkeit';

  @override
  String get tapeOptionsTitle => 'Abdeckband';

  @override
  String get tapeOptionsHint =>
      'Ziehen, um Notizen zu verdecken; auf das Band tippen, um wieder anzuzeigen oder zu verbergen';

  @override
  String get fillColorTitle => 'Füllfarbe';

  @override
  String get fillOptionsHint =>
      'Eine geschlossene Form zeichnen oder in eine Form tippen, um sie zu füllen';

  @override
  String get eraserSizeTitle => 'Radierergröße';

  @override
  String get eraserModeTitle => 'Radierermodus';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Strich';

  @override
  String get eraserModePartialHint =>
      'Löscht nur Tinte unter dem Radiererkreis';

  @override
  String get eraserModeWholeStrokeHint =>
      'Löscht ganze Striche, die berührt werden';

  @override
  String get eraseAllOnPageTitle => 'Alles auf der Seite löschen?';

  @override
  String get eraseAllOnPageBody =>
      'Dies entfernt jeden Strich auf der aktuellen Seite. Sie können diese Aktion rückgängig machen.';

  @override
  String get eraseAllOnPageButton => 'Alles auf der Seite löschen';

  @override
  String get pageSettingsTitle => 'Seiteneinstellungen';

  @override
  String get pageColorTitle => 'Seitenfarbe';

  @override
  String get pageThemeTitle => 'Seitenthema';

  @override
  String get defaultPaperSize => 'Standard-Papiergröße';

  @override
  String get defaultPaperType => 'Standard-Papiertyp';

  @override
  String get defaultPageTheme => 'Standard-Seitenthema';

  @override
  String get notebookDefaultsHint =>
      'Wird beim Erstellen eines neuen Notizbuchs verwendet. Sie können die Auswahl im Dialog weiterhin ändern.';

  @override
  String get pageThemeLight => 'Hell';

  @override
  String get pageThemeDark => 'Dunkel';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastellrosa';

  @override
  String get pageThemePastelBlue => 'Pastellblau';

  @override
  String get pageThemePastelMint => 'Pastellmint';

  @override
  String get pageSizeTitle => 'Seitengröße';

  @override
  String get pageOrientationTitle => 'Ausrichtung';

  @override
  String get pageTemplateTitle => 'Seitenvorlage';

  @override
  String get pageBookmark => 'Lesezeichen';

  @override
  String get pageRemoveBookmark => 'Lesezeichen entfernen';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Teilen';

  @override
  String get pageExportTitle => 'Exportieren';

  @override
  String get pdfPagesKeepBackground =>
      'PDF-Seiten behalten ihren Dokumenthintergrund';

  @override
  String get pdfPagesKeepDimensions => 'PDF-Seiten behalten ihre Dokumentmaße';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF-Seiten behalten ihre Dokumentausrichtung';

  @override
  String get exportPageAsPng => 'Seite als PNG exportieren';

  @override
  String get exportPageAsPngSubtitle => 'Bild dieser Seite teilen';

  @override
  String get exportPageAsPdf => 'Seite als PDF exportieren';

  @override
  String get exportPageAsPdfSubtitle =>
      'Vektor-Tinte, über Systemdialog teilen';

  @override
  String get exportNotebookAsPdf => 'Notizbuch als PDF exportieren';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Audiodatei anhängen';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV und andere lokale Formate';

  @override
  String get pageAudioAttachedToPage => 'An diese Seite angehängt';

  @override
  String get pageAudioReplace => 'Audiodatei ersetzen';

  @override
  String get pageAudioRemove => 'Audio entfernen';

  @override
  String get pageAudioPlay => 'Abspielen';

  @override
  String get pageAudioPause => 'Pausieren';

  @override
  String get contentsTitle => 'Inhalt';

  @override
  String get contentsSubtitle =>
      'Überschriften aus getipptem Text und OCR-indizierter Tinte';

  @override
  String get contentsEmpty =>
      'Noch keine Überschriften gefunden.\nFügen Sie großen oder kleinen getippten Text oder OCR-indizierte Tintenüberschriften hinzu.';

  @override
  String contentsPageNumber(int number) {
    return 'Seite $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Seiten';

  @override
  String pageOverviewSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get pageOverviewDeleteSelected => 'Auswahl löschen';

  @override
  String get pageOverviewSelectPages => 'Seiten auswählen';

  @override
  String get pageOverviewKeepOnePage => 'Mindestens eine Seite behalten';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0 löschen?';
  }

  @override
  String get pageOverviewDeleteBody =>
      'Dies kann nicht rückgängig gemacht werden.';

  @override
  String get pageOverviewDragToReorder => 'Zum Sortieren ziehen';

  @override
  String get pageOverviewBookmarked => 'Mit Lesezeichen';

  @override
  String get ocrIndexing => 'OCR-Indizierung…';

  @override
  String get ocrHandwritingSearchable => 'Handschrift durchsuchbar';

  @override
  String get ocrPartial => 'OCR unvollständig';

  @override
  String get trashTitle => 'Papierkorb';

  @override
  String trashFailedToLoad(String error) {
    return 'Papierkorb konnte nicht geladen werden: $error';
  }

  @override
  String get trashEmpty => 'Papierkorb ist leer';

  @override
  String get trashSectionFolders => 'Ordner';

  @override
  String get trashSectionNotebooks => 'Notizbücher';

  @override
  String get trashDeletionDateUnavailable => 'Löschdatum nicht verfügbar';

  @override
  String get trashExpiresToday => 'Läuft heute ab';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage verbleibend',
      one: '1 Tag verbleibend',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Wiederherstellen';

  @override
  String trashDeleteNotebookTitle(String title) {
    return '„$title“ endgültig löschen?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Dies entfernt das Notizbuch und alle Seiten von diesem Gerät.';

  @override
  String trashDeleteFolderTitle(String name) {
    return '„$name“ endgültig löschen?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Dies entfernt den Ordner und seine Notizbücher von diesem Gerät.';

  @override
  String get splitPageTitle => 'Seite teilen?';

  @override
  String splitPageBody(int count) {
    return 'Eine neue Seite mit derselben Vorlage erstellen und etwa die Hälfte der $count Striche darauf verschieben.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Mindestens 2 Striche nötig, um diese Seite zu teilen';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Seite geteilt: $moved Striche verschoben, $remaining verbleiben';
  }

  @override
  String splitPageFailed(String error) {
    return 'Teilen fehlgeschlagen: $error';
  }

  @override
  String get splitPageAction => 'Seite teilen';

  @override
  String get changePageSizeTitle => 'Seitengröße ändern?';

  @override
  String get changePageSizeBody =>
      'Diese Seite enthält Tinte. Beim Ändern der Größe wird das Layout neu berechnet; Ihre Tinte bleibt an derselben Position auf der Seite.';

  @override
  String get changeOrientationTitle => 'Ausrichtung ändern?';

  @override
  String get changeOrientationBody =>
      'Diese Seite enthält Tinte. Beim Ändern der Ausrichtung wird der Inhalt skaliert und zentriert, um in die neuen Seitenmaße zu passen.';

  @override
  String convertedToText(String preview) {
    return 'In Text umgewandelt: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'Handschrift konnte nicht erkannt werden';

  @override
  String get handwritingModelTitle => 'Handschriftmodell';

  @override
  String get handwritingModelDownloadFailed =>
      'Download fehlgeschlagen. Netzwerk prüfen und erneut versuchen.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Englisches Handschriftmodell (~$sizeMb MB) wird heruntergeladen…';
  }

  @override
  String get handwritingModelReady => 'Modell bereit.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Verstrichen: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Erstmaliger Download (~$sizeMb MB). Dauert per WLAN meist unter zwei Minuten.';
  }

  @override
  String get pageExportedAsPng => 'Seite als PNG exportiert';

  @override
  String get pageExportedAsPdf => 'Seite als PDF exportiert';

  @override
  String get notebookExportedAsPdfSnack => 'Notizbuch als PDF exportiert';

  @override
  String get exportPreparing => 'Export wird vorbereitet…';

  @override
  String exportProgress(int current, int total) {
    return 'Seite $current von $total wird exportiert…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Diese Seite hat $count Striche und kann langsam wirken. Teilen Sie die Seite für bessere Leistung.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Export blockiert: Eine Seite hat $count Striche (Limit $limit). Teilen Sie zuerst schwere Seiten.';
  }

  @override
  String get restoreComplete =>
      'Zurücksetzen abgeschlossen. Bitte starten Sie die App neu, um die wiederhergestellten Daten zu laden.';

  @override
  String get textToolHint => 'Hier tippen…';

  @override
  String get textToolDone => 'Fertig';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languagePolish => 'Polnisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languageUkrainian => 'Ukrainisch';

  @override
  String get languageSwedish => 'Schwedisch';

  @override
  String get languageNorwegian => 'Norwegisch';

  @override
  String get languageFinnish => 'Finnisch';

  @override
  String get languageDanish => 'Dänisch';

  @override
  String get languagePortuguese => 'Portugiesisch';
}
