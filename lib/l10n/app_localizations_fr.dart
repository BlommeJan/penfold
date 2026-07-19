// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionCreate => 'Créer';

  @override
  String get actionRename => 'Renommer';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionSplit => 'Diviser';

  @override
  String get actionRecover => 'Récupérer';

  @override
  String get actionRestore => 'Restaurer';

  @override
  String get actionExport => 'Exporter';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionRetrying => 'Nouvelle tentative…';

  @override
  String get actionExportFirst => 'Exporter d\'abord';

  @override
  String get actionEraseAll => 'Tout effacer';

  @override
  String get actionChangeSize => 'Changer la taille';

  @override
  String get actionChangeOrientation => 'Changer l\'orientation';

  @override
  String get actionUseColor => 'Utiliser la couleur';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Aperçu';

  @override
  String get libraryTrash => 'Corbeille';

  @override
  String get librarySettings => 'Réglages';

  @override
  String get libraryFolders => 'Dossiers';

  @override
  String get libraryNoFoldersYet => 'Aucun dossier pour l\'instant';

  @override
  String get libraryAll => 'Tout';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Sans catégorie';

  @override
  String get libraryBreadcrumb => 'Bibliothèque';

  @override
  String get librarySearchHint => 'Rechercher des carnets et du texte saisi…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Aucun résultat';

  @override
  String get libraryFolderEmpty => 'Ce dossier est vide';

  @override
  String get libraryNoNotebooksWithTag => 'Aucun carnet avec cette étiquette';

  @override
  String get libraryNoUncategorizedNotebooks => 'Aucun carnet sans catégorie';

  @override
  String get libraryNoNotebooksYet => 'Aucun carnet pour l\'instant';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Impossible de charger la bibliothèque : $error';
  }

  @override
  String get tooltipBackupRestore => 'Sauvegarde et restauration';

  @override
  String get tooltipTrash => 'Corbeille';

  @override
  String get tooltipNewNotebook => 'Nouveau carnet';

  @override
  String get tooltipNewFolder => 'Nouveau dossier';

  @override
  String get tooltipNewSubfolder => 'Nouveau sous-dossier';

  @override
  String get tooltipImportPdf => 'Importer un PDF';

  @override
  String get folderNew => 'Nouveau dossier';

  @override
  String get folderNewSubfolder => 'Nouveau sous-dossier';

  @override
  String get folderRename => 'Renommer le dossier';

  @override
  String get folderMoveToTrash => 'Mettre à la corbeille';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Mettre « $name » à la corbeille ?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Le dossier et ses carnets sont déplacés dans la corbeille pendant 30 jours.';

  @override
  String get notebookNew => 'Nouveau carnet';

  @override
  String get notebookUntitled => 'Sans titre';

  @override
  String get notebookTitleLabel => 'Titre';

  @override
  String get notebookSizeLabel => 'Taille';

  @override
  String get notebookPaperLabel => 'Papier';

  @override
  String get notebookCoverLabel => 'Couverture';

  @override
  String get notebookRename => 'Renommer le carnet';

  @override
  String get notebookMoveToFolder => 'Déplacer vers un dossier';

  @override
  String get notebookEditTags => 'Modifier les étiquettes';

  @override
  String get notebookExportWorkbook => 'Exporter le carnet';

  @override
  String get notebookExportWorkbookSubtitle =>
      'Partager toutes les pages en PDF';

  @override
  String get notebookMoveToTrash => 'Mettre à la corbeille';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Mettre « $title » à la corbeille ?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Le carnet est masqué de la bibliothèque pendant 30 jours. L\'encre et les pages restent sur cet appareil jusqu\'à ce que la corbeille soit vidée. Exportez une sauvegarde au préalable si vous souhaitez une copie supplémentaire.';

  @override
  String notebookTagsFor(String title) {
    return 'Étiquettes pour « $title »';
  }

  @override
  String get notebookNoTagsYet =>
      'Aucune étiquette pour l\'instant. Créez-en une ci-dessous.';

  @override
  String get notebookNewTag => 'Nouvelle étiquette';

  @override
  String get notebookAddTag => 'Ajouter une étiquette';

  @override
  String get notebookNoPagesToExport => 'Ce carnet n\'a aucune page à exporter';

  @override
  String notebookExportedAsPdf(String title) {
    return '« $title » exporté en PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Sauvegarde exportée. Vous pouvez déplacer le carnet vers la corbeille quand vous le souhaitez.';

  @override
  String get importPdfSnack =>
      'Importation du PDF… les pages sont rendues une fois, puis restent hors ligne.';

  @override
  String importFailed(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String backupFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Échec de la récupération : $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Téléchargement du modèle d\'écriture manuscrite (~$sizeMb Mo) en arrière-plan…';
  }

  @override
  String get templateBlank => 'Vierge';

  @override
  String get templateLined => 'Ligné';

  @override
  String get templateGrid => 'Quadrillé';

  @override
  String get templateDotted => 'Points';

  @override
  String get templateCollegeRuled => 'Ligné universitaire';

  @override
  String get templateCollegeShort => 'Universitaire';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Portrait';

  @override
  String get orientationLandscape => 'Paysage';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionLanguage => 'Langue';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Apparence et préférences';

  @override
  String get settingsSectionAppearance => 'Apparence';

  @override
  String get settingsAppearanceDarkMode => 'Mode sombre';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Choisir clair, sombre ou suivre l\'appareil (système par défaut)';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsSectionPreferences => 'Préférences';

  @override
  String get settingsLanguageLabel => 'Langue de l\'application';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageDutch => 'Néerlandais';

  @override
  String get settingsSectionToolbar => 'Barre d\'outils';

  @override
  String get settingsToolbarReorderHint =>
      'Faites glisser pour réorganiser les outils de dessin. Annuler et rétablir restent fixes à droite.';

  @override
  String get settingsResetToolbarOrder =>
      'Réinitialiser l\'ordre de la barre d\'outils';

  @override
  String get settingsSectionNotebook => 'Carnet';

  @override
  String get settingsPageTurnMode => 'Mode de changement de page';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Glisser une page à la fois au lieu du défilement continu (désactivé par défaut)';

  @override
  String get settingsZoomNavigation => 'Navigation par zoom';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Pincer pour zoomer et déplacer les pages (activé par défaut)';

  @override
  String get settingsSectionDrawing => 'Dessin';

  @override
  String get settingsStrokeSmoothing => 'Lissage des traits';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Lisser les traits d\'encre avec l\'algorithme de Chaikin (activé par défaut)';

  @override
  String get settingsStrokeSmoothingStrength => 'Intensité du lissage';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent % — une valeur plus basse conserve plus de détails ; $recommended % recommandé';
  }

  @override
  String get settingsFingerDrawing => 'Dessin au doigt';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Dessiner au doigt sur le papier ; si désactivé, seul le stylet dessine (désactivé par défaut)';

  @override
  String get settingsGestureInkEditing => 'Édition gestuelle de l\'encre';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Griffoner sur l\'encre indexée par OCR pour l\'effacer (activé par défaut)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Maintenez le bouton latéral du S Pen pour changer d\'outil temporairement. Relâchez pour revenir à l\'outil précédent. Fonctionne sur les appareils Samsung avec bouton latéral.';

  @override
  String get settingsSpenBarrelAction => 'Action du bouton latéral';

  @override
  String get settingsSectionOcrDictionary => 'Dictionnaire OCR';

  @override
  String get settingsOcrDictionaryHint =>
      'Termes spécialisés pour la reconnaissance d\'écriture manuscrite. Les correspondances proches sont corrigées lors de l\'indexation de l\'encre, et les termes améliorent la recherche dans les carnets.';

  @override
  String get settingsNoCustomOcrTerms =>
      'Aucun terme personnalisé pour l\'instant.';

  @override
  String get settingsRemoveOcrTerm => 'Supprimer le terme';

  @override
  String get settingsAddOcrTerm => 'Ajouter un terme';

  @override
  String get settingsAddOcrTermTitle => 'Ajouter un terme OCR';

  @override
  String get settingsOcrTermLabel => 'Terme';

  @override
  String get settingsOcrTermHint => 'p. ex. valeur propre, mitochondrie';

  @override
  String get settingsSectionYourData => 'Vos données';

  @override
  String get settingsYourDataHint =>
      'Penfold stocke tout sur cet appareil dans une base SQLite unique et des dossiers de ressources — pas de synchronisation cloud. Consultez docs/ARCHITECTURE.md pour la disposition complète des fichiers sur l\'appareil.';

  @override
  String get settingsDatabase => 'Base de données';

  @override
  String get settingsSectionBackupRestore => 'Sauvegarde et restauration';

  @override
  String get settingsBackupRestoreHint =>
      'Exporter une archive zip de penfold.db et des dossiers de ressources, ou restaurer à partir d\'une sauvegarde précédente. Votre base actuelle est enregistrée dans backups/ avant la restauration.';

  @override
  String get settingsExportBackup => 'Exporter la sauvegarde';

  @override
  String get settingsExportBackupSubtitle =>
      'Créer une archive zip de penfold.db, des sources PDF, images et pages PDF héritées';

  @override
  String get settingsRecoverFromBackup => 'Récupérer depuis une sauvegarde';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Dernière sauvegarde automatique : $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Restaurer une sauvegarde';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Remplacer les données locales par une archive zip Penfold';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Récupérer depuis la sauvegarde automatique ?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Cela remplace vos carnets et fichiers actuels par la sauvegarde de $timestamp. Votre base actuelle sera enregistrée dans backups/ avant la restauration.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Restaurer une sauvegarde ?';

  @override
  String get settingsRestoreBackupBody =>
      'Cela remplace vos carnets et fichiers actuels. Votre base actuelle sera enregistrée dans backups/ avant la restauration.';

  @override
  String get settingsSectionAbout => 'À propos';

  @override
  String get settingsAboutSubtitle =>
      'Carnet d\'écriture manuscrite local — pas de comptes, pas de cloud.';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get spenActionEraser => 'Gomme';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Stylo';

  @override
  String get spenActionNone => 'Aucune';

  @override
  String get toolPen => 'Stylo';

  @override
  String get toolHighlighter => 'Surligneur';

  @override
  String get toolTape => 'Ruban';

  @override
  String get toolEraser => 'Gomme';

  @override
  String get toolSelection => 'Sélection';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Forme';

  @override
  String get toolFill => 'Remplissage';

  @override
  String get toolText => 'Texte';

  @override
  String get toolInsertImage => 'Insérer une image';

  @override
  String get brushPen => 'Stylo';

  @override
  String get brushFountain => 'Plume';

  @override
  String get brushPencil => 'Crayon';

  @override
  String get brushMarker => 'Marqueur';

  @override
  String get brushCalligraphy => 'Calligraphie';

  @override
  String get toolbarPreviousBookmark => 'Signet précédent';

  @override
  String get toolbarNextBookmark => 'Signet suivant';

  @override
  String get toolbarConvertToText => 'Convertir en texte';

  @override
  String get toolbarCopy => 'Copier';

  @override
  String get toolbarDelete => 'Supprimer';

  @override
  String get toolbarPaste => 'Coller';

  @override
  String get toolbarUndo => 'Annuler';

  @override
  String get toolbarRedo => 'Rétablir';

  @override
  String get toolbarAddPage => 'Ajouter une page';

  @override
  String get toolbarStylusOnly => 'Stylet uniquement (détection de la paume)';

  @override
  String get toolbarFingerDrawing => 'Dessin au doigt';

  @override
  String get toolbarPageOverview => 'Aperçu des pages';

  @override
  String get toolbarTableOfContents => 'Table des matières';

  @override
  String get toolbarPageMenu => 'Menu de la page';

  @override
  String get penOptionsTitle => 'Stylo';

  @override
  String get highlighterOptionsTitle => 'Surligneur';

  @override
  String get brushLabel => 'Style de trait';

  @override
  String get colorLabel => 'Couleur';

  @override
  String get customColorTitle => 'Couleur personnalisée';

  @override
  String get hueLabel => 'Teinte';

  @override
  String get saturationLabel => 'Saturation';

  @override
  String get brightnessLabel => 'Luminosité';

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
  String get tapeOptionsTitle => 'Ruban';

  @override
  String get tapeOptionsHint =>
      'Dessinez pour masquer des notes ; touchez le ruban pour afficher ou masquer à nouveau';

  @override
  String get fillColorTitle => 'Couleur de remplissage';

  @override
  String get fillOptionsHint =>
      'Dessinez une boucle fermée, ou touchez l\'intérieur d\'une forme pour remplir';

  @override
  String get eraserSizeTitle => 'Taille de la gomme';

  @override
  String get eraserModeTitle => 'Mode gomme';

  @override
  String get eraserModePixel => 'Pixel';

  @override
  String get eraserModeStroke => 'Trait';

  @override
  String get eraserModePartialHint =>
      'Efface uniquement l\'encre sous le cercle de la gomme';

  @override
  String get eraserModeWholeStrokeHint =>
      'Efface les traits entiers qu\'elle touche';

  @override
  String get eraseAllOnPageTitle => 'Tout effacer sur la page ?';

  @override
  String get eraseAllOnPageBody =>
      'Cela supprime tous les traits de la page actuelle. Vous pouvez annuler cette action.';

  @override
  String get eraseAllOnPageButton => 'Tout effacer sur la page';

  @override
  String get pageSettingsTitle => 'Réglages de la page';

  @override
  String get pageColorTitle => 'Couleur de la page';

  @override
  String get pageThemeTitle => 'Thème de la page';

  @override
  String get defaultPaperSize => 'Taille de papier par défaut';

  @override
  String get defaultPaperType => 'Type de papier par défaut';

  @override
  String get defaultPageTheme => 'Thème de page par défaut';

  @override
  String get notebookDefaultsHint =>
      'Utilisé lors de la création d\'un nouveau carnet. Vous pouvez toujours modifier les choix dans la boîte de dialogue.';

  @override
  String get pageThemeLight => 'Clair';

  @override
  String get pageThemeDark => 'Sombre';

  @override
  String get pageThemeSepia => 'Sépia';

  @override
  String get pageThemePastelPink => 'Rose pastel';

  @override
  String get pageThemePastelBlue => 'Bleu pastel';

  @override
  String get pageThemePastelMint => 'Menthe pastel';

  @override
  String get pageSizeTitle => 'Taille de la page';

  @override
  String get pageOrientationTitle => 'Orientation';

  @override
  String get pageTemplateTitle => 'Modèle de page';

  @override
  String get pageBookmark => 'Signet';

  @override
  String get pageRemoveBookmark => 'Retirer le signet';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Diviser';

  @override
  String get pageExportTitle => 'Exporter';

  @override
  String get pdfPagesKeepBackground =>
      'Les pages PDF conservent l\'arrière-plan du document';

  @override
  String get pdfPagesKeepDimensions =>
      'Les pages PDF conservent les dimensions du document';

  @override
  String get pdfPagesKeepOrientation =>
      'Les pages PDF conservent l\'orientation du document';

  @override
  String get exportPageAsPng => 'Exporter la page en PNG';

  @override
  String get exportPageAsPngSubtitle => 'Partager l\'image de cette page';

  @override
  String get exportPageAsPdf => 'Exporter la page en PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Encre vectorielle, partage via le menu de partage';

  @override
  String get exportNotebookAsPdf => 'Exporter le carnet en PDF';

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
  String get pageAudioAttach => 'Joindre un fichier audio';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV et autres formats locaux';

  @override
  String get pageAudioAttachedToPage => 'Joint à cette page';

  @override
  String get pageAudioReplace => 'Remplacer le fichier audio';

  @override
  String get pageAudioRemove => 'Supprimer l\'audio';

  @override
  String get pageAudioPlay => 'Lire';

  @override
  String get pageAudioPause => 'Pause';

  @override
  String get contentsTitle => 'Sommaire';

  @override
  String get contentsSubtitle =>
      'Titres du texte saisi et de l\'encre indexée par OCR';

  @override
  String get contentsEmpty =>
      'Aucun titre trouvé pour l\'instant.\nAjoutez du texte saisi de grande ou petite taille, ou des titres d\'encre indexés par OCR.';

  @override
  String contentsPageNumber(int number) {
    return 'Page $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Pages';

  @override
  String pageOverviewSelected(int count) {
    return 'Sélection : $count';
  }

  @override
  String get pageOverviewDeleteSelected => 'Supprimer la sélection';

  @override
  String get pageOverviewSelectPages => 'Sélectionner des pages';

  @override
  String get pageOverviewKeepOnePage => 'Conserver au moins une page';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return 'Supprimer $_temp0 ?';
  }

  @override
  String get pageOverviewDeleteBody => 'Cette action est irréversible.';

  @override
  String get pageOverviewDragToReorder => 'Faites glisser pour réorganiser';

  @override
  String get pageOverviewBookmarked => 'Avec signet';

  @override
  String get ocrIndexing => 'Indexation OCR…';

  @override
  String get ocrHandwritingSearchable => 'Écriture manuscrite recherchable';

  @override
  String get ocrPartial => 'OCR partiel';

  @override
  String get trashTitle => 'Corbeille';

  @override
  String trashFailedToLoad(String error) {
    return 'Échec du chargement de la corbeille : $error';
  }

  @override
  String get trashEmpty => 'La corbeille est vide';

  @override
  String get trashSectionFolders => 'Dossiers';

  @override
  String get trashSectionNotebooks => 'Carnets';

  @override
  String get trashDeletionDateUnavailable => 'Date de suppression indisponible';

  @override
  String get trashExpiresToday => 'Expire aujourd\'hui';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours restants',
      one: '1 jour restant',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restaurer';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Supprimer « $title » définitivement ?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Cela supprime le carnet et toutes ses pages de cet appareil.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Supprimer « $name » définitivement ?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Cela supprime le dossier et ses carnets de cet appareil.';

  @override
  String get splitPageTitle => 'Diviser la page ?';

  @override
  String splitPageBody(int count) {
    return 'Créer une nouvelle page avec le même modèle et déplacer environ la moitié des $count traits dessus.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Au moins 2 traits sont nécessaires pour diviser cette page';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Page divisée : $moved traits déplacés, $remaining restants';
  }

  @override
  String splitPageFailed(String error) {
    return 'Échec de la division : $error';
  }

  @override
  String get splitPageAction => 'Diviser la page';

  @override
  String get changePageSizeTitle => 'Changer la taille de la page ?';

  @override
  String get changePageSizeBody =>
      'Cette page contient de l\'encre. Changer la taille réorganisera la page ; votre encre reste à la même position sur la page.';

  @override
  String get changeOrientationTitle => 'Changer l\'orientation ?';

  @override
  String get changeOrientationBody =>
      'Cette page contient de l\'encre. Changer l\'orientation redimensionne et centre votre contenu pour l\'adapter aux nouvelles dimensions.';

  @override
  String convertedToText(String preview) {
    return 'Converti en texte : $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'Impossible de reconnaître l\'écriture manuscrite';

  @override
  String get handwritingModelTitle => 'Modèle d\'écriture manuscrite';

  @override
  String get handwritingModelDownloadFailed =>
      'Échec du téléchargement. Vérifiez le réseau et réessayez.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Téléchargement du modèle d\'écriture manuscrite en anglais (~$sizeMb Mo)…';
  }

  @override
  String get handwritingModelReady => 'Modèle prêt.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Temps écoulé : $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Téléchargement initial (~$sizeMb Mo). Prend généralement moins de deux minutes en Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Page exportée en PNG';

  @override
  String get pageExportedAsPdf => 'Page exportée en PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Carnet exporté en PDF';

  @override
  String get exportPreparing => 'Préparation de l\'exportation…';

  @override
  String exportProgress(int current, int total) {
    return 'Exportation de la page $current sur $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Cette page contient $count traits et peut être lente. Envisagez de la diviser pour de meilleures performances.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Exportation bloquée : une page contient $count traits (limite $limit). Divisez d\'abord les pages lourdes.';
  }

  @override
  String get restoreComplete =>
      'Restauration terminée. Veuillez redémarrer l\'application pour charger les données restaurées.';

  @override
  String get textToolHint => 'Saisissez ici…';

  @override
  String get textToolDone => 'Terminé';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languagePolish => 'Polonais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languageUkrainian => 'Ukrainien';

  @override
  String get languageSwedish => 'Suédois';

  @override
  String get languageNorwegian => 'Norvégien';

  @override
  String get languageFinnish => 'Finnois';

  @override
  String get languageDanish => 'Danois';

  @override
  String get languagePortuguese => 'Portugais';
}
