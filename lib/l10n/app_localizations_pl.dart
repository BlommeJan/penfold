// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionCreate => 'Utwórz';

  @override
  String get actionRename => 'Zmień nazwę';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionAdd => 'Dodaj';

  @override
  String get actionBack => 'Wstecz';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionSplit => 'Podziel';

  @override
  String get actionRecover => 'Odzyskaj';

  @override
  String get actionRestore => 'Przywróć';

  @override
  String get actionExport => 'Eksportuj';

  @override
  String get actionRetry => 'Ponów';

  @override
  String get actionRetrying => 'Ponawianie…';

  @override
  String get actionExportFirst => 'Najpierw eksportuj';

  @override
  String get actionEraseAll => 'Wymaż wszystko';

  @override
  String get actionChangeSize => 'Zmień rozmiar';

  @override
  String get actionChangeOrientation => 'Zmień orientację';

  @override
  String get actionUseColor => 'Użyj koloru';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Przegląd';

  @override
  String get libraryTrash => 'Kosz';

  @override
  String get librarySettings => 'Ustawienia';

  @override
  String get libraryFolders => 'Foldery';

  @override
  String get libraryNoFoldersYet => 'Brak folderów';

  @override
  String get libraryAll => 'Wszystkie';

  @override
  String get libraryUncategorized => 'Bez kategorii';

  @override
  String get libraryBreadcrumb => 'Biblioteka';

  @override
  String get librarySearchHint => 'Szukaj notatników i wpisanego tekstu…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Brak wyników';

  @override
  String get libraryFolderEmpty => 'Ten folder jest pusty';

  @override
  String get libraryNoNotebooksWithTag => 'Brak notatników z tą etykietą';

  @override
  String get libraryNoUncategorizedNotebooks => 'Brak notatników bez kategorii';

  @override
  String get libraryNoNotebooksYet => 'Brak notatników';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Nie udało się wczytać biblioteki: $error';
  }

  @override
  String get tooltipBackupRestore => 'Kopia zapasowa i przywracanie';

  @override
  String get tooltipTrash => 'Kosz';

  @override
  String get tooltipNewNotebook => 'Nowy notatnik';

  @override
  String get tooltipNewFolder => 'Nowy folder';

  @override
  String get tooltipNewSubfolder => 'Nowy podfolder';

  @override
  String get tooltipImportPdf => 'Importuj PDF';

  @override
  String get folderNew => 'Nowy folder';

  @override
  String get folderNewSubfolder => 'Nowy podfolder';

  @override
  String get folderRename => 'Zmień nazwę folderu';

  @override
  String get folderMoveToTrash => 'Przenieś do kosza';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Przenieść „$name” do kosza?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Folder i jego notatniki trafią do kosza na 30 dni.';

  @override
  String get notebookNew => 'Nowy notatnik';

  @override
  String get notebookUntitled => 'Bez tytułu';

  @override
  String get notebookTitleLabel => 'Tytuł';

  @override
  String get notebookSizeLabel => 'Rozmiar';

  @override
  String get notebookPaperLabel => 'Papier';

  @override
  String get notebookCoverLabel => 'Okładka';

  @override
  String get notebookRename => 'Zmień nazwę notatnika';

  @override
  String get notebookMoveToFolder => 'Przenieś do folderu';

  @override
  String get notebookEditTags => 'Edytuj etykiety';

  @override
  String get notebookExportWorkbook => 'Eksportuj notatnik';

  @override
  String get notebookExportWorkbookSubtitle =>
      'Udostępnij wszystkie strony jako PDF';

  @override
  String get notebookMoveToTrash => 'Przenieś do kosza';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Przenieść „$title” do kosza?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Notatnik zostanie ukryty w bibliotece na 30 dni. Atrament i strony pozostaną na tym urządzeniu, dopóki nie opróżnisz kosza. Wyeksportuj kopię zapasową, jeśli chcesz dodatkową kopię.';

  @override
  String notebookTagsFor(String title) {
    return 'Etykiety dla „$title”';
  }

  @override
  String get notebookNoTagsYet => 'Brak etykiet. Utwórz nową poniżej.';

  @override
  String get notebookNewTag => 'Nowa etykieta';

  @override
  String get notebookAddTag => 'Dodaj etykietę';

  @override
  String get notebookNoPagesToExport => 'Ten notatnik nie ma stron do eksportu';

  @override
  String notebookExportedAsPdf(String title) {
    return '„$title” wyeksportowano jako PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Kopia zapasowa wyeksportowana. Możesz przenieść notatnik do kosza, gdy będziesz gotowy.';

  @override
  String get importPdfSnack =>
      'Importowanie PDF… strony renderują się raz, potem działają offline.';

  @override
  String importFailed(String error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Kopia zapasowa nie powiodła się: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Odzyskiwanie nie powiodło się: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Przywracanie nie powiodło się: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Pobieranie modelu pisma odręcznego (~$sizeMb MB) w tle…';
  }

  @override
  String get templateBlank => 'Pusta';

  @override
  String get templateLined => 'W linie';

  @override
  String get templateGrid => 'W kratkę';

  @override
  String get templateDotted => 'W kropki';

  @override
  String get templateCollegeRuled => 'W linie (college)';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Pionowa';

  @override
  String get orientationLandscape => 'Pozioma';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsSectionLanguage => 'Język';

  @override
  String get settingsSectionAppearanceAndPreferences => 'Wygląd i preferencje';

  @override
  String get settingsSectionAppearance => 'Wygląd';

  @override
  String get settingsAppearanceDarkMode => 'Tryb ciemny';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Wybierz jasny, ciemny lub zgodny z urządzeniem (domyślnie system)';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get settingsSectionPreferences => 'Preferencje';

  @override
  String get settingsLanguageLabel => 'Język aplikacji';

  @override
  String get languageEnglish => 'Angielski';

  @override
  String get languageGerman => 'Niemiecki';

  @override
  String get languageFrench => 'Francuski';

  @override
  String get languageDutch => 'Holenderski';

  @override
  String get settingsSectionToolbar => 'Pasek narzędzi';

  @override
  String get settingsToolbarReorderHint =>
      'Przeciągnij, aby zmienić kolejność narzędzi rysowania. Cofnij i ponów pozostają po prawej.';

  @override
  String get settingsResetToolbarOrder => 'Resetuj kolejność paska narzędzi';

  @override
  String get settingsSectionNotebook => 'Notatnik';

  @override
  String get settingsPageTurnMode => 'Tryb przewracania stron';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Przewijaj po jednej stronie zamiast ciągłego przewijania (domyślnie wył.)';

  @override
  String get settingsZoomNavigation => 'Nawigacja powiększeniem';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Szczypnij, aby powiększyć i przesuwać strony (domyślnie wł.)';

  @override
  String get settingsSectionDrawing => 'Rysowanie';

  @override
  String get settingsStrokeSmoothing => 'Wygładzanie pociągnięć';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Wygładzaj pociągnięcia atramentu algorytmem Chaikina (domyślnie wł.)';

  @override
  String get settingsStrokeSmoothingStrength => 'Siła wygładzania';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — niższa wartość zachowuje więcej detali; zalecane $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Rysowanie palcem';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Rysuj palcem na stronie; gdy wył., tylko rysik rysuje (domyślnie wył.)';

  @override
  String get settingsGestureInkEditing => 'Edycja atramentu gestem';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Przekreśl atrament zindeksowany przez OCR, aby go wymazać (domyślnie wł.)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Przytrzymaj boczny przycisk S Pen, aby tymczasowo przełączyć narzędzie. Puść, aby przywrócić poprzednie. Działa na urządzeniach Samsung z obsługą przycisku bocznego.';

  @override
  String get settingsSpenBarrelAction => 'Akcja przycisku bocznego';

  @override
  String get settingsSectionOcrDictionary => 'Słownik OCR';

  @override
  String get settingsOcrDictionaryHint =>
      'Terminy branżowe dla OCR pisma odręcznego. Podobne dopasowania są korygowane przy indeksowaniu atramentu, a terminy wzmacniają wyszukiwanie w notatniku.';

  @override
  String get settingsNoCustomOcrTerms => 'Brak własnych terminów.';

  @override
  String get settingsRemoveOcrTerm => 'Usuń termin';

  @override
  String get settingsAddOcrTerm => 'Dodaj termin';

  @override
  String get settingsAddOcrTermTitle => 'Dodaj termin OCR';

  @override
  String get settingsOcrTermLabel => 'Termin';

  @override
  String get settingsOcrTermHint => 'np. wartość własna, mitochondrium';

  @override
  String get settingsSectionYourData => 'Twoje dane';

  @override
  String get settingsYourDataHint =>
      'Penfold przechowuje wszystko na tym urządzeniu w jednej bazie SQLite i folderach zasobów — bez synchronizacji w chmurze. Pełny układ plików na urządzeniu: docs/ARCHITECTURE.md.';

  @override
  String get settingsDatabase => 'Baza danych';

  @override
  String get settingsSectionBackupRestore => 'Kopia zapasowa i przywracanie';

  @override
  String get settingsBackupRestoreHint =>
      'Eksportuj zip z penfold.db i folderami zasobów lub przywróć z wcześniejszej kopii. Obecna baza zostanie zapisana w backups/ przed przywróceniem.';

  @override
  String get settingsExportBackup => 'Eksportuj kopię zapasową';

  @override
  String get settingsExportBackupSubtitle =>
      'Spakuj penfold.db, źródła PDF, obrazy i starsze strony PDF';

  @override
  String get settingsRecoverFromBackup => 'Odzyskaj z kopii zapasowej';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Ostatnia automatyczna kopia: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Przywróć kopię zapasową';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Zastąp lokalne dane plikiem zip kopii Penfold';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Odzyskać z automatycznej kopii?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'To zastąpi bieżące notatniki i pliki kopią z $timestamp. Obecna baza zostanie zapisana w backups/ przed odzyskaniem.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Przywrócić kopię zapasową?';

  @override
  String get settingsRestoreBackupBody =>
      'To zastąpi bieżące notatniki i pliki. Obecna baza zostanie zapisana w backups/ przed przywróceniem.';

  @override
  String get settingsSectionAbout => 'Informacje';

  @override
  String get settingsAboutSubtitle =>
      'Notatnik z pismem odręcznym — lokalnie, bez kont i chmury.';

  @override
  String settingsVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get spenActionEraser => 'Gumka';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Pióro';

  @override
  String get spenActionNone => 'Brak';

  @override
  String get toolPen => 'Pióro';

  @override
  String get toolHighlighter => 'Zakreślacz';

  @override
  String get toolTape => 'Taśma';

  @override
  String get toolEraser => 'Gumka';

  @override
  String get toolSelection => 'Zaznaczenie';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Kształt';

  @override
  String get toolFill => 'Wypełnienie';

  @override
  String get toolText => 'Tekst';

  @override
  String get toolInsertImage => 'Wstaw obraz';

  @override
  String get brushPen => 'Pióro';

  @override
  String get brushFountain => 'Pióro wieczne';

  @override
  String get brushPencil => 'Ołówek';

  @override
  String get brushMarker => 'Marker';

  @override
  String get brushCalligraphy => 'Kaligrafia';

  @override
  String get toolbarPreviousBookmark => 'Poprzednia zakładka';

  @override
  String get toolbarNextBookmark => 'Następna zakładka';

  @override
  String get toolbarConvertToText => 'Konwertuj na tekst';

  @override
  String get toolbarCopy => 'Kopiuj';

  @override
  String get toolbarDelete => 'Usuń';

  @override
  String get toolbarPaste => 'Wklej';

  @override
  String get toolbarUndo => 'Cofnij';

  @override
  String get toolbarRedo => 'Ponów';

  @override
  String get toolbarAddPage => 'Dodaj stronę';

  @override
  String get toolbarStylusOnly => 'Tylko rysik (odrzucanie dłoni)';

  @override
  String get toolbarFingerDrawing => 'Rysowanie palcem';

  @override
  String get toolbarPageOverview => 'Przegląd stron';

  @override
  String get toolbarTableOfContents => 'Spis treści';

  @override
  String get toolbarPageMenu => 'Menu strony';

  @override
  String get penOptionsTitle => 'Pióro';

  @override
  String get highlighterOptionsTitle => 'Zakreślacz';

  @override
  String get brushLabel => 'Typ pióra';

  @override
  String get colorLabel => 'Kolor';

  @override
  String get customColorTitle => 'Kolor własny';

  @override
  String get hueLabel => 'Odcień';

  @override
  String get saturationLabel => 'Nasycenie';

  @override
  String get brightnessLabel => 'Jasność';

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
  String get tapeOptionsTitle => 'Taśma';

  @override
  String get tapeOptionsHint =>
      'Rysuj, aby zakryć notatki; dotknij taśmy, aby ponownie pokazać lub ukryć';

  @override
  String get fillColorTitle => 'Kolor wypełnienia';

  @override
  String get fillOptionsHint =>
      'Narysuj zamkniętą pętlę lub dotknij wnętrza kształtu, aby wypełnić';

  @override
  String get eraserSizeTitle => 'Rozmiar gumki';

  @override
  String get eraserModeTitle => 'Tryb gumki';

  @override
  String get eraserModePixel => 'Częściowa';

  @override
  String get eraserModeStroke => 'Pociągnięcie';

  @override
  String get eraserModePartialHint => 'Wymazuje tylko atrament pod kołem gumki';

  @override
  String get eraserModeWholeStrokeHint =>
      'Wymazuje całe pociągnięcia, których dotknie';

  @override
  String get eraseAllOnPageTitle => 'Wymazać wszystko na stronie?';

  @override
  String get eraseAllOnPageBody =>
      'To usunie wszystkie pociągnięcia na bieżącej stronie. Możesz cofnąć tę akcję.';

  @override
  String get eraseAllOnPageButton => 'Wymaż wszystko na stronie';

  @override
  String get pageSettingsTitle => 'Ustawienia strony';

  @override
  String get pageColorTitle => 'Kolor strony';

  @override
  String get pageThemeTitle => 'Motyw strony';

  @override
  String get defaultPaperSize => 'Domyślny rozmiar papieru';

  @override
  String get defaultPaperType => 'Domyślny typ papieru';

  @override
  String get defaultPageTheme => 'Domyślny motyw strony';

  @override
  String get notebookDefaultsHint =>
      'Używane przy tworzeniu nowego notatnika. Możesz nadal zmienić wybory w oknie dialogowym.';

  @override
  String get pageThemeLight => 'Jasny';

  @override
  String get pageThemeDark => 'Ciemny';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Pastelowy róż';

  @override
  String get pageThemePastelBlue => 'Pastelowy błękit';

  @override
  String get pageThemePastelMint => 'Pastelowa mięta';

  @override
  String get pageSizeTitle => 'Rozmiar strony';

  @override
  String get pageOrientationTitle => 'Orientacja';

  @override
  String get pageTemplateTitle => 'Szablon strony';

  @override
  String get pageBookmark => 'Zakładka';

  @override
  String get pageRemoveBookmark => 'Usuń zakładkę';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Podziel';

  @override
  String get pageExportTitle => 'Eksport';

  @override
  String get pdfPagesKeepBackground => 'Strony PDF zachowują tło dokumentu';

  @override
  String get pdfPagesKeepDimensions => 'Strony PDF zachowują wymiary dokumentu';

  @override
  String get pdfPagesKeepOrientation =>
      'Strony PDF zachowują orientację dokumentu';

  @override
  String get exportPageAsPng => 'Eksportuj stronę jako PNG';

  @override
  String get exportPageAsPngSubtitle => 'Udostępnij obraz tej strony';

  @override
  String get exportPageAsPdf => 'Eksportuj stronę jako PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Atrament wektorowy, udostępnij przez menu udostępniania systemowego';

  @override
  String get exportNotebookAsPdf => 'Eksportuj notatnik jako PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stron',
      many: '$count stron',
      few: '$count strony',
      one: '1 strona',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Dołącz plik audio';

  @override
  String get pageAudioAttachSubtitle => 'MP3, M4A, WAV i inne lokalne formaty';

  @override
  String get pageAudioAttachedToPage => 'Dołączono do tej strony';

  @override
  String get pageAudioReplace => 'Zastąp plik audio';

  @override
  String get pageAudioRemove => 'Usuń audio';

  @override
  String get pageAudioPlay => 'Odtwaj';

  @override
  String get pageAudioPause => 'Wstrzymaj';

  @override
  String get contentsTitle => 'Spis treści';

  @override
  String get contentsSubtitle =>
      'Nagłówki z wpisanego tekstu i atramentu zindeksowanego przez OCR';

  @override
  String get contentsEmpty =>
      'Nie znaleziono jeszcze nagłówków.\nDodaj duży lub krótki wpisany tekst albo nagłówki z atramentu zindeksowanego przez OCR.';

  @override
  String contentsPageNumber(int number) {
    return 'Strona $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Strony';

  @override
  String pageOverviewSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zaznaczonych',
      many: '$count zaznaczonych',
      few: '$count zaznaczone',
      one: '1 zaznaczona',
    );
    return '$_temp0';
  }

  @override
  String get pageOverviewDeleteSelected => 'Usuń zaznaczone';

  @override
  String get pageOverviewSelectPages => 'Zaznacz strony';

  @override
  String get pageOverviewKeepOnePage => 'Zachowaj co najmniej jedną stronę';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stron',
      many: '$count stron',
      few: '$count strony',
      one: '1 stronę',
    );
    return 'Usunąć $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Tej operacji nie można cofnąć.';

  @override
  String get pageOverviewDragToReorder => 'Przeciągnij, aby zmienić kolejność';

  @override
  String get pageOverviewBookmarked => 'Z zakładką';

  @override
  String get ocrIndexing => 'Indeksowanie OCR…';

  @override
  String get ocrHandwritingSearchable => 'Przeszukiwalne pismo odręczne';

  @override
  String get ocrPartial => 'OCR częściowe';

  @override
  String get trashTitle => 'Kosz';

  @override
  String trashFailedToLoad(String error) {
    return 'Nie udało się wczytać kosza: $error';
  }

  @override
  String get trashEmpty => 'Kosz jest pusty';

  @override
  String get trashSectionFolders => 'Foldery';

  @override
  String get trashSectionNotebooks => 'Notatniki';

  @override
  String get trashDeletionDateUnavailable => 'Data usunięcia niedostępna';

  @override
  String get trashExpiresToday => 'Wygasa dziś';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pozostało $count dni',
      many: 'Pozostało $count dni',
      few: 'Pozostały $count dni',
      one: 'Pozostał 1 dzień',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Przywróć';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Trwale usunąć „$title”?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'To usunie notatnik i wszystkie strony z tego urządzenia.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Trwale usunąć „$name”?';
  }

  @override
  String get trashDeleteFolderBody =>
      'To usunie folder i jego notatniki z tego urządzenia.';

  @override
  String get splitPageTitle => 'Podzielić stronę?';

  @override
  String splitPageBody(int count) {
    return 'Utwórz nową stronę z tym samym szablonem i przenieś na nią około połowę pociągnięć (łącznie $count).';
  }

  @override
  String get splitPageNeedStrokes =>
      'Do podziału strony potrzeba co najmniej dwóch pociągnięć';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Strona podzielona: przeniesiono $moved, pozostało $remaining';
  }

  @override
  String splitPageFailed(String error) {
    return 'Podział nie powiódł się: $error';
  }

  @override
  String get splitPageAction => 'Podziel stronę';

  @override
  String get changePageSizeTitle => 'Zmienić rozmiar strony?';

  @override
  String get changePageSizeBody =>
      'Ta strona ma atrament. Zmiana rozmiaru przeformatuje stronę; atrament pozostanie w tej samej pozycji na stronie.';

  @override
  String get changeOrientationTitle => 'Zmienić orientację?';

  @override
  String get changeOrientationBody =>
      'Ta strona ma atrament. Zmiana orientacji skaluje i wyśrodkuje zawartość, aby dopasować ją do nowych granic strony.';

  @override
  String convertedToText(String preview) {
    return 'Skonwertowano na tekst: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'Nie udało się rozpoznać pisma odręcznego';

  @override
  String get handwritingModelTitle => 'Model pisma odręcznego';

  @override
  String get handwritingModelDownloadFailed =>
      'Pobieranie nie powiodło się. Sprawdź sieć i ponów.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Pobieranie angielskiego modelu pisma odręcznego (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Model gotowy.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Upłynęło: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Pierwsze pobieranie (~$sizeMb MB). Zwykle kończy się w mniej niż dwie minuty przez Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Strona wyeksportowana jako PNG';

  @override
  String get pageExportedAsPdf => 'Strona wyeksportowana jako PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Notatnik wyeksportowany jako PDF';

  @override
  String get exportPreparing => 'Przygotowywanie eksportu…';

  @override
  String exportProgress(int current, int total) {
    return 'Eksportowanie strony $current z $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Dużo pociągnięć ($count) — ta strona może działać wolno. Rozważ podział dla lepszej wydajności.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Eksport zablokowany: liczba pociągnięć ($count) przekracza limit ($limit). Najpierw podziel obciążone strony.';
  }

  @override
  String get restoreComplete =>
      'Przywracanie zakończone. Uruchom ponownie aplikację, aby wczytać przywrócone dane.';

  @override
  String get textToolHint => 'Wpisz tutaj…';

  @override
  String get textToolDone => 'Gotowe';

  @override
  String get languageKorean => 'Koreański';

  @override
  String get languagePolish => 'Polski';

  @override
  String get languageSpanish => 'Hiszpański';

  @override
  String get languageItalian => 'Włoski';

  @override
  String get languageUkrainian => 'Ukraiński';

  @override
  String get languageSwedish => 'Szwedzki';

  @override
  String get languageNorwegian => 'Norweski';

  @override
  String get languageFinnish => 'Fiński';

  @override
  String get languageDanish => 'Duński';

  @override
  String get languagePortuguese => 'Portugalski';
}
