// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionCreate => 'Crea';

  @override
  String get actionRename => 'Rinomina';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionDone => 'Fine';

  @override
  String get actionSplit => 'Dividi';

  @override
  String get actionRecover => 'Recupera';

  @override
  String get actionRestore => 'Ripristina';

  @override
  String get actionExport => 'Esporta';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionRetrying => 'Nuovo tentativo…';

  @override
  String get actionExportFirst => 'Esporta prima';

  @override
  String get actionEraseAll => 'Cancella tutto';

  @override
  String get actionChangeSize => 'Cambia dimensione';

  @override
  String get actionChangeOrientation => 'Cambia orientamento';

  @override
  String get actionUseColor => 'Usa colore';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Panoramica';

  @override
  String get libraryTrash => 'Cestino';

  @override
  String get librarySettings => 'Impostazioni';

  @override
  String get libraryFolders => 'Cartelle';

  @override
  String get libraryNoFoldersYet => 'Nessuna cartella ancora';

  @override
  String get libraryAll => 'Tutti';

  @override
  String get libraryUncategorized => 'Senza categoria';

  @override
  String get libraryBreadcrumb => 'Libreria';

  @override
  String get librarySearchHint => 'Cerca quaderni e testo digitato…';

  @override
  String get libraryNoMatches => 'Nessun risultato';

  @override
  String get libraryFolderEmpty => 'Questa cartella è vuota';

  @override
  String get libraryNoNotebooksWithTag => 'Nessun quaderno con questo tag';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'Nessun quaderno senza categoria';

  @override
  String get libraryNoNotebooksYet => 'Nessun quaderno ancora';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Impossibile caricare la libreria: $error';
  }

  @override
  String get tooltipBackupRestore => 'Backup e ripristino';

  @override
  String get tooltipTrash => 'Cestino';

  @override
  String get tooltipNewNotebook => 'Nuovo quaderno';

  @override
  String get tooltipNewFolder => 'Nuova cartella';

  @override
  String get tooltipNewSubfolder => 'Nuova sottocartella';

  @override
  String get tooltipImportPdf => 'Importa PDF';

  @override
  String get folderNew => 'Nuova cartella';

  @override
  String get folderNewSubfolder => 'Nuova sottocartella';

  @override
  String get folderRename => 'Rinomina cartella';

  @override
  String get folderMoveToTrash => 'Sposta nel cestino';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Spostare \"$name\" nel cestino?';
  }

  @override
  String get folderMoveToTrashBody =>
      'La cartella e i suoi quaderni vengono spostati nel cestino per 30 giorni.';

  @override
  String get notebookNew => 'Nuovo quaderno';

  @override
  String get notebookUntitled => 'Senza titolo';

  @override
  String get notebookTitleLabel => 'Titolo';

  @override
  String get notebookSizeLabel => 'Dimensione';

  @override
  String get notebookPaperLabel => 'Carta';

  @override
  String get notebookCoverLabel => 'Copertina';

  @override
  String get notebookRename => 'Rinomina quaderno';

  @override
  String get notebookMoveToFolder => 'Sposta in cartella';

  @override
  String get notebookEditTags => 'Modifica tag';

  @override
  String get notebookExportWorkbook => 'Esporta quaderno';

  @override
  String get notebookExportWorkbookSubtitle =>
      'Condividi tutte le pagine come PDF';

  @override
  String get notebookMoveToTrash => 'Sposta nel cestino';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Spostare \"$title\" nel cestino?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Il quaderno viene nascosto dalla libreria per 30 giorni. Inchiostro e pagine restano su questo dispositivo finché il cestino non viene svuotato. Esporta prima un backup se vuoi una copia aggiuntiva.';

  @override
  String notebookTagsFor(String title) {
    return 'Tag per \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'Nessun tag. Creane uno qui sotto.';

  @override
  String get notebookNewTag => 'Nuovo tag';

  @override
  String get notebookAddTag => 'Aggiungi tag';

  @override
  String get notebookNoPagesToExport =>
      'Questo quaderno non ha pagine da esportare';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" esportato come PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Backup esportato. Puoi spostarlo nel cestino quando sei pronto.';

  @override
  String get importPdfSnack =>
      'Importazione PDF… le pagine vengono generate una volta, poi restano offline.';

  @override
  String importFailed(String error) {
    return 'Importazione non riuscita: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Backup non riuscito: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Recupero non riuscito: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Ripristino non riuscito: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Download del modello di scrittura (~$sizeMb MB) in secondo piano…';
  }

  @override
  String get templateBlank => 'Bianco';

  @override
  String get templateLined => 'Righe';

  @override
  String get templateGrid => 'Quadretti';

  @override
  String get templateDotted => 'Puntini';

  @override
  String get templateCollegeRuled => 'Righe americane';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Verticale';

  @override
  String get orientationLandscape => 'Orizzontale';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSectionLanguage => 'Lingua';

  @override
  String get settingsSectionAppearanceAndPreferences => 'Aspetto e preferenze';

  @override
  String get settingsSectionAppearance => 'Aspetto';

  @override
  String get settingsAppearanceDarkMode => 'Modalità scura';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Scegli chiaro, scuro o segui il dispositivo (predefinito: sistema)';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get settingsSectionPreferences => 'Preferenze';

  @override
  String get settingsLanguageLabel => 'Lingua dell\'app';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageDutch => 'Olandese';

  @override
  String get settingsSectionToolbar => 'Barra strumenti';

  @override
  String get settingsToolbarReorderHint =>
      'Trascina per riordinare gli strumenti di disegno. Annulla e ripeti restano fissi a destra.';

  @override
  String get settingsResetToolbarOrder => 'Ripristina ordine barra strumenti';

  @override
  String get settingsSectionNotebook => 'Quaderno';

  @override
  String get settingsPageTurnMode => 'Modalità cambio pagina';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Scorri una pagina alla volta invece dello scorrimento continuo (disattivato di default)';

  @override
  String get settingsZoomNavigation => 'Navigazione con zoom';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Pizzica per ingrandire e spostarti sulle pagine (attivato di default)';

  @override
  String get settingsSectionDrawing => 'Disegno';

  @override
  String get settingsStrokeSmoothing => 'Levigatura dei tratti';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Leviga i tratti d\'inchiostro con l\'algoritmo di Chaikin (attivato di default)';

  @override
  String get settingsStrokeSmoothingStrength => 'Intensità di levigatura';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — valori più bassi mantengono più dettaglio; consigliato $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Disegno con dito';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Disegna con il dito sul foglio; se disattivato, solo lo stilo disegna (disattivato di default)';

  @override
  String get settingsGestureInkEditing => 'Modifica inchiostro con gesti';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Passa sopra l\'inchiostro indicizzato con OCR per cancellarlo (attivato di default)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Tieni premuto il pulsante laterale della S Pen per cambiare temporaneamente strumento. Rilascia per ripristinare lo strumento precedente. Funziona sui dispositivi Samsung con supporto del pulsante laterale.';

  @override
  String get settingsSpenBarrelAction => 'Azione pulsante laterale';

  @override
  String get settingsSectionOcrDictionary => 'Dizionario OCR';

  @override
  String get settingsOcrDictionaryHint =>
      'Termini di dominio per l\'OCR della scrittura. Le corrispondenze simili vengono corrette quando l\'inchiostro viene indicizzato e i termini migliorano la ricerca nei quaderni.';

  @override
  String get settingsNoCustomOcrTerms => 'Nessun termine personalizzato.';

  @override
  String get settingsRemoveOcrTerm => 'Rimuovi termine';

  @override
  String get settingsAddOcrTerm => 'Aggiungi termine';

  @override
  String get settingsAddOcrTermTitle => 'Aggiungi termine OCR';

  @override
  String get settingsOcrTermLabel => 'Termine';

  @override
  String get settingsOcrTermHint => 'es. autovalore, mitocondrio';

  @override
  String get settingsSectionYourData => 'I tuoi dati';

  @override
  String get settingsYourDataHint =>
      'Penfold salva tutto su questo dispositivo in un unico database SQLite e cartelle di risorse — nessuna sincronizzazione cloud. Vedi docs/ARCHITECTURE.md per la struttura completa dei file sul dispositivo.';

  @override
  String get settingsDatabase => 'Database';

  @override
  String get settingsSectionBackupRestore => 'Backup e ripristino';

  @override
  String get settingsBackupRestoreHint =>
      'Esporta uno zip di penfold.db e delle cartelle di risorse, oppure ripristina da un backup precedente. Il database attuale viene salvato in backups/ prima del ripristino.';

  @override
  String get settingsExportBackup => 'Esporta backup';

  @override
  String get settingsExportBackupSubtitle =>
      'Crea uno zip con penfold.db, PDF sorgente, immagini e pagine PDF legacy';

  @override
  String get settingsRecoverFromBackup => 'Recupera da backup';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Ultimo backup automatico: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Ripristina backup';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Sostituisci i dati locali con uno zip di backup Penfold';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Recuperare dal backup automatico?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Questo sostituisce quaderni e file attuali con il backup del $timestamp. Il database attuale verrà salvato in backups/ prima del ripristino.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Ripristinare il backup?';

  @override
  String get settingsRestoreBackupBody =>
      'Questo sostituisce quaderni e file attuali. Il database attuale verrà salvato in backups/ prima del ripristino.';

  @override
  String get settingsSectionAbout => 'Informazioni';

  @override
  String get settingsAboutSubtitle =>
      'Quaderno digitale per scrittura a mano, tutto in locale — senza account né cloud.';

  @override
  String settingsVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get spenActionEraser => 'Gomma';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Penna';

  @override
  String get spenActionNone => 'Nessuna';

  @override
  String get toolPen => 'Penna';

  @override
  String get toolHighlighter => 'Evidenziatore';

  @override
  String get toolTape => 'Nastro coprente';

  @override
  String get toolEraser => 'Gomma';

  @override
  String get toolSelection => 'Selezione';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Forma';

  @override
  String get toolFill => 'Riempimento';

  @override
  String get toolText => 'Testo';

  @override
  String get toolInsertImage => 'Inserisci immagine';

  @override
  String get brushPen => 'Penna';

  @override
  String get brushFountain => 'Stilografica';

  @override
  String get brushPencil => 'Matita';

  @override
  String get brushMarker => 'Pennarello';

  @override
  String get brushCalligraphy => 'Calligrafia';

  @override
  String get toolbarPreviousBookmark => 'Segnalibro precedente';

  @override
  String get toolbarNextBookmark => 'Segnalibro successivo';

  @override
  String get toolbarConvertToText => 'Converti in testo';

  @override
  String get toolbarCopy => 'Copia';

  @override
  String get toolbarDelete => 'Elimina';

  @override
  String get toolbarPaste => 'Incolla';

  @override
  String get toolbarUndo => 'Annulla';

  @override
  String get toolbarRedo => 'Ripeti';

  @override
  String get toolbarAddPage => 'Aggiungi pagina';

  @override
  String get toolbarStylusOnly => 'Solo stilo (rifiuto del palmo)';

  @override
  String get toolbarFingerDrawing => 'Disegno con dito';

  @override
  String get toolbarPageOverview => 'Panoramica pagine';

  @override
  String get toolbarTableOfContents => 'Sommario';

  @override
  String get toolbarPageMenu => 'Menu pagina';

  @override
  String get penOptionsTitle => 'Penna';

  @override
  String get highlighterOptionsTitle => 'Evidenziatore';

  @override
  String get brushLabel => 'Stile';

  @override
  String get colorLabel => 'Colore';

  @override
  String get customColorTitle => 'Colore personalizzato';

  @override
  String get hueLabel => 'Tonalità';

  @override
  String get saturationLabel => 'Saturazione';

  @override
  String get brightnessLabel => 'Luminosità';

  @override
  String get tapeOptionsTitle => 'Nastro coprente';

  @override
  String get tapeOptionsHint =>
      'Disegna per coprire le note; tocca il nastro coprente per mostrarle o nasconderle di nuovo';

  @override
  String get fillColorTitle => 'Colore di riempimento';

  @override
  String get fillOptionsHint =>
      'Disegna un contorno chiuso oppure tocca l\'interno di una forma per riempirla';

  @override
  String get eraserSizeTitle => 'Dimensione gomma';

  @override
  String get eraserModeTitle => 'Modalità gomma';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Tratto';

  @override
  String get eraserModePartialHint =>
      'Cancella solo l\'inchiostro sotto il cerchio della gomma';

  @override
  String get eraserModeWholeStrokeHint => 'Cancella i tratti interi che tocca';

  @override
  String get eraseAllOnPageTitle => 'Cancellare tutto sulla pagina?';

  @override
  String get eraseAllOnPageBody =>
      'Questo rimuove ogni tratto sulla pagina corrente. Puoi annullare questa azione.';

  @override
  String get eraseAllOnPageButton => 'Cancella tutto sulla pagina';

  @override
  String get pageSettingsTitle => 'Impostazioni pagina';

  @override
  String get pageColorTitle => 'Colore pagina';

  @override
  String get pageThemeTitle => 'Tema pagina';

  @override
  String get defaultPaperSize => 'Dimensione carta predefinita';

  @override
  String get defaultPaperType => 'Tipo carta predefinito';

  @override
  String get defaultPageTheme => 'Tema pagina predefinito';

  @override
  String get notebookDefaultsHint =>
      'Usato quando crei un nuovo quaderno. Puoi comunque modificare le scelte nella finestra di dialogo.';

  @override
  String get pageThemeLight => 'Chiaro';

  @override
  String get pageThemeDark => 'Scuro';

  @override
  String get pageThemeSepia => 'Seppia';

  @override
  String get pageThemePastelPink => 'Rosa pastello';

  @override
  String get pageThemePastelBlue => 'Blu pastello';

  @override
  String get pageThemePastelMint => 'Menta pastello';

  @override
  String get pageSizeTitle => 'Dimensione pagina';

  @override
  String get pageOrientationTitle => 'Orientamento';

  @override
  String get pageTemplateTitle => 'Modello pagina';

  @override
  String get pageBookmark => 'Segnalibro';

  @override
  String get pageRemoveBookmark => 'Rimuovi segnalibro';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Dividi';

  @override
  String get pageExportTitle => 'Esporta';

  @override
  String get pdfPagesKeepBackground =>
      'Le pagine PDF mantengono lo sfondo del documento';

  @override
  String get pdfPagesKeepDimensions =>
      'Le pagine PDF mantengono le dimensioni del documento';

  @override
  String get pdfPagesKeepOrientation =>
      'Le pagine PDF mantengono l\'orientamento del documento';

  @override
  String get exportPageAsPng => 'Esporta pagina come PNG';

  @override
  String get exportPageAsPngSubtitle =>
      'Condividi l\'immagine di questa pagina';

  @override
  String get exportPageAsPdf => 'Esporta pagina come PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Inchiostro vettoriale, condividi dal menu Condividi di sistema';

  @override
  String get exportNotebookAsPdf => 'Esporta quaderno come PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagine',
      one: '1 pagina',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Allega file audio';

  @override
  String get pageAudioAttachSubtitle => 'MP3, M4A, WAV e altri formati locali';

  @override
  String get pageAudioAttachedToPage => 'Allegato a questa pagina';

  @override
  String get pageAudioReplace => 'Sostituisci file audio';

  @override
  String get pageAudioRemove => 'Rimuovi audio';

  @override
  String get pageAudioPlay => 'Riproduci';

  @override
  String get pageAudioPause => 'Pausa';

  @override
  String get contentsTitle => 'Sommario';

  @override
  String get contentsSubtitle =>
      'Intestazioni da testo digitato e inchiostro indicizzato con OCR';

  @override
  String get contentsEmpty =>
      'Nessuna intestazione trovata.\nAggiungi testo digitato grande o breve, oppure intestazioni in inchiostro indicizzato con OCR.';

  @override
  String contentsPageNumber(int number) {
    return 'Pagina $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Pagine';

  @override
  String pageOverviewSelected(int count) {
    return 'Selezionate: $count';
  }

  @override
  String get pageOverviewDeleteSelected => 'Elimina selezionate';

  @override
  String get pageOverviewSelectPages => 'Seleziona pagine';

  @override
  String get pageOverviewKeepOnePage => 'Mantieni almeno una pagina';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagine',
      one: '1 pagina',
    );
    return 'Eliminare $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody =>
      'Questa azione non può essere annullata.';

  @override
  String get pageOverviewDragToReorder => 'Trascina per riordinare';

  @override
  String get pageOverviewBookmarked => 'Segnalibro impostato';

  @override
  String get ocrIndexing => 'Indicizzazione OCR…';

  @override
  String get ocrHandwritingSearchable => 'Scrittura ricercabile';

  @override
  String get ocrPartial => 'OCR parziale';

  @override
  String get trashTitle => 'Cestino';

  @override
  String trashFailedToLoad(String error) {
    return 'Impossibile caricare il cestino: $error';
  }

  @override
  String get trashEmpty => 'Il cestino è vuoto';

  @override
  String get trashSectionFolders => 'Cartelle';

  @override
  String get trashSectionNotebooks => 'Quaderni';

  @override
  String get trashDeletionDateUnavailable =>
      'Data eliminazione non disponibile';

  @override
  String get trashExpiresToday => 'Scade oggi';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restano $count giorni',
      one: 'Resta 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Ripristina';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Eliminare \"$title\" definitivamente?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Questo rimuove il quaderno e tutte le pagine da questo dispositivo.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Eliminare \"$name\" definitivamente?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Questo rimuove la cartella e i suoi quaderni da questo dispositivo.';

  @override
  String get splitPageTitle => 'Dividere la pagina?';

  @override
  String splitPageBody(int count) {
    return 'Crea una nuova pagina con lo stesso modello e sposta circa metà dei $count tratti nella nuova pagina.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Servono almeno 2 tratti per dividere questa pagina';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Pagina divisa: $moved tratti spostati, $remaining rimasti';
  }

  @override
  String splitPageFailed(String error) {
    return 'Divisione non riuscita: $error';
  }

  @override
  String get splitPageAction => 'Dividi pagina';

  @override
  String get changePageSizeTitle => 'Cambiare dimensione pagina?';

  @override
  String get changePageSizeBody =>
      'Questa pagina contiene inchiostro. Cambiare la dimensione ricalcola il layout della pagina; l\'inchiostro resta nella stessa posizione.';

  @override
  String get changeOrientationTitle => 'Cambiare orientamento?';

  @override
  String get changeOrientationBody =>
      'Questa pagina contiene inchiostro. Cambiare l\'orientamento ridimensiona e centra il contenuto per adattarlo ai nuovi margini della pagina.';

  @override
  String convertedToText(String preview) {
    return 'Convertito in testo: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'Impossibile riconoscere la scrittura';

  @override
  String get handwritingModelTitle => 'Modello di scrittura';

  @override
  String get handwritingModelDownloadFailed =>
      'Download non riuscito. Controlla la rete e riprova.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Download del modello di scrittura inglese (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Modello pronto.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Tempo trascorso: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Download iniziale (~$sizeMb MB). Di solito termina in meno di due minuti su Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Pagina esportata come PNG';

  @override
  String get pageExportedAsPdf => 'Pagina esportata come PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Quaderno esportato come PDF';

  @override
  String get exportPreparing => 'Preparazione esportazione…';

  @override
  String exportProgress(int current, int total) {
    return 'Esportazione pagina $current di $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Questa pagina ha $count tratti e potrebbe risultare lenta. Considera di dividerla per migliorare le prestazioni.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Esportazione bloccata: una pagina ha $count tratti (limite $limit). Dividi prima le pagine pesanti.';
  }

  @override
  String get restoreComplete =>
      'Ripristino completato. Riavvia l\'app per caricare i dati ripristinati.';

  @override
  String get textToolHint => 'Digita qui…';

  @override
  String get textToolDone => 'Fine';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languagePolish => 'Polacco';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageUkrainian => 'Ucraino';

  @override
  String get languageSwedish => 'Svedese';

  @override
  String get languageNorwegian => 'Norvegese';

  @override
  String get languageFinnish => 'Finlandese';

  @override
  String get languageDanish => 'Danese';

  @override
  String get languagePortuguese => 'Portoghese';
}
