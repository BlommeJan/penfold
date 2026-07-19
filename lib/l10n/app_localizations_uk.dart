// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Скасувати';

  @override
  String get actionCreate => 'Створити';

  @override
  String get actionRename => 'Перейменувати';

  @override
  String get actionSave => 'Зберегти';

  @override
  String get actionDelete => 'Видалити';

  @override
  String get actionAdd => 'Додати';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionSplit => 'Розділити';

  @override
  String get actionRecover => 'Відновити';

  @override
  String get actionRestore => 'Відновити';

  @override
  String get actionExport => 'Експорт';

  @override
  String get actionRetry => 'Повторити';

  @override
  String get actionRetrying => 'Повторення…';

  @override
  String get actionExportFirst => 'Спочатку експорт';

  @override
  String get actionEraseAll => 'Стерти все';

  @override
  String get actionChangeSize => 'Змінити розмір';

  @override
  String get actionChangeOrientation => 'Змінити орієнтацію';

  @override
  String get actionUseColor => 'Використати колір';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Огляд';

  @override
  String get libraryTrash => 'Кошик';

  @override
  String get librarySettings => 'Налаштування';

  @override
  String get libraryFolders => 'Папки';

  @override
  String get libraryNoFoldersYet => 'Папок ще немає';

  @override
  String get libraryAll => 'Усі';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Без категорії';

  @override
  String get libraryBreadcrumb => 'Бібліотека';

  @override
  String get librarySearchHint => 'Пошук зошитів і набраного тексту…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Нічого не знайдено';

  @override
  String get libraryFolderEmpty => 'Ця папка порожня';

  @override
  String get libraryNoNotebooksWithTag => 'Немає зошитів із цим тегом';

  @override
  String get libraryNoUncategorizedNotebooks => 'Немає зошитів без категорії';

  @override
  String get libraryNoNotebooksYet => 'Зошитів ще немає';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Не вдалося завантажити бібліотеку: $error';
  }

  @override
  String get tooltipBackupRestore => 'Резервна копія та відновлення';

  @override
  String get tooltipTrash => 'Кошик';

  @override
  String get tooltipNewNotebook => 'Новий зошит';

  @override
  String get tooltipNewFolder => 'Нова папка';

  @override
  String get tooltipNewSubfolder => 'Нова вкладена папка';

  @override
  String get tooltipImportPdf => 'Імпорт PDF';

  @override
  String get folderNew => 'Нова папка';

  @override
  String get folderNewSubfolder => 'Нова вкладена папка';

  @override
  String get folderRename => 'Перейменувати папку';

  @override
  String get folderMoveToTrash => 'Перемістити в кошик';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Перемістити «$name» у кошик?';
  }

  @override
  String get folderMoveToTrashBody =>
      'Папку та її зошити буде переміщено в кошик на 30 днів.';

  @override
  String get notebookNew => 'Новий зошит';

  @override
  String get notebookUntitled => 'Без назви';

  @override
  String get notebookTitleLabel => 'Назва';

  @override
  String get notebookSizeLabel => 'Розмір';

  @override
  String get notebookPaperLabel => 'Папір';

  @override
  String get notebookCoverLabel => 'Обкладинка';

  @override
  String get notebookRename => 'Перейменувати зошит';

  @override
  String get notebookMoveToFolder => 'Перемістити в папку';

  @override
  String get notebookEditTags => 'Редагувати теги';

  @override
  String get notebookExportWorkbook => 'Експорт зошита';

  @override
  String get notebookExportWorkbookSubtitle => 'Надіслати всі сторінки як PDF';

  @override
  String get notebookMoveToTrash => 'Перемістити в кошик';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Перемістити «$title» у кошик?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'Зошит буде приховано з бібліотеки на 30 днів. Чорнило та сторінки залишаться на цьому пристрої, доки кошик не буде очищено. Експортуйте резервну копію, якщо потрібна додаткова копія.';

  @override
  String notebookTagsFor(String title) {
    return 'Теги для «$title»';
  }

  @override
  String get notebookNoTagsYet => 'Тегів ще немає. Створіть новий нижче.';

  @override
  String get notebookNewTag => 'Новий тег';

  @override
  String get notebookAddTag => 'Додати тег';

  @override
  String get notebookNoPagesToExport =>
      'У цьому зошиті немає сторінок для експорту';

  @override
  String notebookExportedAsPdf(String title) {
    return '«$title» експортовано як PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Резервну копію експортовано. Можете перемістити в кошик, коли будете готові.';

  @override
  String get importPdfSnack =>
      'Імпорт PDF… сторінки відображаються один раз, потім працюють офлайн.';

  @override
  String importFailed(String error) {
    return 'Помилка імпорту: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Помилка експорту: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Помилка резервного копіювання: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Помилка відновлення: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Помилка відновлення: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Завантаження моделі розпізнавання почерку (~$sizeMb МБ) у фоновому режимі…';
  }

  @override
  String get templateBlank => 'Чистий';

  @override
  String get templateLined => 'Лінований';

  @override
  String get templateGrid => 'Клітинка';

  @override
  String get templateDotted => 'Крапки';

  @override
  String get templateCollegeRuled => 'Лінований (college)';

  @override
  String get templateCollegeShort => 'College';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Книжкова';

  @override
  String get orientationLandscape => 'Альбомна';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsSectionLanguage => 'Мова';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Зовнішній вигляд і налаштування';

  @override
  String get settingsSectionAppearance => 'Зовнішній вигляд';

  @override
  String get settingsAppearanceDarkMode => 'Темний режим';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Світла, темна тема або як на пристрої (системна за замовчуванням)';

  @override
  String get themeSystem => 'Системна';

  @override
  String get themeLight => 'Світла';

  @override
  String get themeDark => 'Темна';

  @override
  String get settingsSectionPreferences => 'Уподобання';

  @override
  String get settingsLanguageLabel => 'Мова застосунку';

  @override
  String get languageEnglish => 'Англійська';

  @override
  String get languageGerman => 'Німецька';

  @override
  String get languageFrench => 'Французька';

  @override
  String get languageDutch => 'Нідерландська';

  @override
  String get settingsSectionToolbar => 'Панель інструментів';

  @override
  String get settingsToolbarReorderHint =>
      'Перетягніть, щоб змінити порядок інструментів малювання. Скасувати та повторити залишаються праворуч.';

  @override
  String get settingsResetToolbarOrder => 'Скинути порядок панелі';

  @override
  String get settingsSectionNotebook => 'Зошит';

  @override
  String get settingsPageTurnMode => 'Режим перегортання';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Перегортати по одній сторінці замість безперервного прокручування (за замовчуванням вимкнено)';

  @override
  String get settingsZoomNavigation => 'Навігація масштабом';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Масштабування та переміщення сторінок жестами (за замовчуванням увімкнено)';

  @override
  String get settingsSectionDrawing => 'Малювання';

  @override
  String get settingsStrokeSmoothing => 'Згладжування штрихів';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Згладжувати штрихи чорнила методом Chaikin (за замовчуванням увімкнено)';

  @override
  String get settingsStrokeSmoothingStrength => 'Сила згладжування';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — менше значення зберігає більше деталей; рекомендовано $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Малювання пальцем';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Малювати пальцем на сторінці; якщо вимкнено, малює лише стилус (за замовчуванням вимкнено)';

  @override
  String get settingsGestureInkEditing => 'Редагування чорнила жестами';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Проведіть по OCR-індексованому чорнилу, щоб стерти його (за замовчуванням увімкнено)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Утримуйте бокову кнопку S Pen, щоб тимчасово перемкнути інструмент. Відпустіть, щоб повернути попередній інструмент. Працює на пристроях Samsung із підтримкою бокової кнопки.';

  @override
  String get settingsSpenBarrelAction => 'Дія бокової кнопки';

  @override
  String get settingsSectionOcrDictionary => 'Словник OCR';

  @override
  String get settingsOcrDictionaryHint =>
      'Спеціальні терміни для OCR почерку. Схожі збіги виправляються під час індексації чорнила, а терміни покращують пошук у зошитах.';

  @override
  String get settingsNoCustomOcrTerms => 'Власних термінів ще немає.';

  @override
  String get settingsRemoveOcrTerm => 'Видалити термін';

  @override
  String get settingsAddOcrTerm => 'Додати термін';

  @override
  String get settingsAddOcrTermTitle => 'Додати термін OCR';

  @override
  String get settingsOcrTermLabel => 'Термін';

  @override
  String get settingsOcrTermHint => 'наприклад, eigenvalue, mitochondria';

  @override
  String get settingsSectionYourData => 'Ваші дані';

  @override
  String get settingsYourDataHint =>
      'Penfold зберігає все на цьому пристрої в одній базі SQLite та папках ресурсів — без хмарної синхронізації. Повний опис локального сховища див. у docs/ARCHITECTURE.md.';

  @override
  String get settingsDatabase => 'База даних';

  @override
  String get settingsSectionBackupRestore => 'Резервна копія та відновлення';

  @override
  String get settingsBackupRestoreHint =>
      'Експортуйте zip-архів penfold.db і папок ресурсів або відновіть з попередньої резервної копії. Поточну базу буде збережено в backups/ перед відновленням.';

  @override
  String get settingsExportBackup => 'Експорт резервної копії';

  @override
  String get settingsExportBackupSubtitle =>
      'Zip-архів penfold.db, PDF-джерел, зображень і застарілих PDF-сторінок';

  @override
  String get settingsRecoverFromBackup => 'Відновити з резервної копії';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Остання автокопія: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Відновити резервну копію';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Замінити локальні дані з zip-архіву резервної копії Penfold';

  @override
  String get settingsRecoverAutoBackupTitle => 'Відновити з автокопії?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Це замінить ваші поточні зошити та файли резервною копією від $timestamp. Поточну базу буде збережено в backups/ перед відновленням.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Відновити резервну копію?';

  @override
  String get settingsRestoreBackupBody =>
      'Це замінить ваші поточні зошити та файли. Поточну базу буде збережено в backups/ перед відновленням.';

  @override
  String get settingsSectionAbout => 'Про застосунок';

  @override
  String get settingsAboutSubtitle =>
      'Локальний зошит для рукопису — без облікових записів і хмари.';

  @override
  String settingsVersion(String version) {
    return 'Версія $version';
  }

  @override
  String get spenActionEraser => 'Гумка';

  @override
  String get spenActionLasso => 'Lasso';

  @override
  String get spenActionPen => 'Перо';

  @override
  String get spenActionNone => 'Немає';

  @override
  String get toolPen => 'Перо';

  @override
  String get toolHighlighter => 'Текст-маркер';

  @override
  String get toolTape => 'Стрічка';

  @override
  String get toolEraser => 'Гумка';

  @override
  String get toolSelection => 'Виділення';

  @override
  String get toolLasso => 'Lasso';

  @override
  String get toolShape => 'Фігура';

  @override
  String get toolFill => 'Заливка';

  @override
  String get toolText => 'Текст';

  @override
  String get toolInsertImage => 'Вставити зображення';

  @override
  String get brushPen => 'Перо';

  @override
  String get brushFountain => 'Перьова';

  @override
  String get brushPencil => 'Олівець';

  @override
  String get brushMarker => 'Маркер';

  @override
  String get brushCalligraphy => 'Каліграфія';

  @override
  String get toolbarPreviousBookmark => 'Попередня закладка';

  @override
  String get toolbarNextBookmark => 'Наступна закладка';

  @override
  String get toolbarConvertToText => 'Перетворити на текст';

  @override
  String get toolbarCopy => 'Копіювати';

  @override
  String get toolbarDelete => 'Видалити';

  @override
  String get toolbarPaste => 'Вставити';

  @override
  String get toolbarUndo => 'Скасувати';

  @override
  String get toolbarRedo => 'Повторити';

  @override
  String get toolbarAddPage => 'Додати сторінку';

  @override
  String get toolbarStylusOnly => 'Лише стилус (блокування долоні)';

  @override
  String get toolbarFingerDrawing => 'Малювання пальцем';

  @override
  String get toolbarPageOverview => 'Огляд сторінок';

  @override
  String get toolbarTableOfContents => 'Зміст';

  @override
  String get toolbarPageMenu => 'Меню сторінки';

  @override
  String get penOptionsTitle => 'Перо';

  @override
  String get highlighterOptionsTitle => 'Текст-маркер';

  @override
  String get brushLabel => 'Тип пера';

  @override
  String get colorLabel => 'Колір';

  @override
  String get customColorTitle => 'Власний колір';

  @override
  String get hueLabel => 'Відтінок';

  @override
  String get saturationLabel => 'Насиченість';

  @override
  String get brightnessLabel => 'Яскравість';

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
  String get tapeOptionsTitle => 'Стрічка';

  @override
  String get tapeOptionsHint =>
      'Малюйте, щоб приховати нотатки; торкніться стрічки, щоб знову показати або сховати';

  @override
  String get fillColorTitle => 'Колір заливки';

  @override
  String get fillOptionsHint =>
      'Намалюйте замкнутий контур або торкніться всередині фігури, щоб залити';

  @override
  String get eraserSizeTitle => 'Розмір гумки';

  @override
  String get eraserModeTitle => 'Режим гумки';

  @override
  String get eraserModePixel => 'Піксельна';

  @override
  String get eraserModeStroke => 'Штрих';

  @override
  String get eraserModePartialHint => 'Стирає лише чорнило під колом гумки';

  @override
  String get eraserModeWholeStrokeHint => 'Стирає цілі штрихи, яких торкається';

  @override
  String get eraseAllOnPageTitle => 'Стерти все на сторінці?';

  @override
  String get eraseAllOnPageBody =>
      'Це видалить усі штрихи на поточній сторінці. Дію можна скасувати.';

  @override
  String get eraseAllOnPageButton => 'Стерти все на сторінці';

  @override
  String get pageSettingsTitle => 'Налаштування сторінки';

  @override
  String get pageColorTitle => 'Колір сторінки';

  @override
  String get pageThemeTitle => 'Тема сторінки';

  @override
  String get defaultPaperSize => 'Розмір паперу за замовчуванням';

  @override
  String get defaultPaperType => 'Тип паперу за замовчуванням';

  @override
  String get defaultPageTheme => 'Тема сторінки за замовчуванням';

  @override
  String get notebookDefaultsHint =>
      'Використовується під час створення нового зошита. Вибір можна змінити в діалозі.';

  @override
  String get pageThemeLight => 'Світла';

  @override
  String get pageThemeDark => 'Темна';

  @override
  String get pageThemeSepia => 'Сепія';

  @override
  String get pageThemePastelPink => 'Пастельний рожевий';

  @override
  String get pageThemePastelBlue => 'Пастельний блакитний';

  @override
  String get pageThemePastelMint => 'Пастельна мʼята';

  @override
  String get pageSizeTitle => 'Розмір сторінки';

  @override
  String get pageOrientationTitle => 'Орієнтація';

  @override
  String get pageTemplateTitle => 'Шаблон сторінки';

  @override
  String get pageBookmark => 'Закладка';

  @override
  String get pageRemoveBookmark => 'Прибрати закладку';

  @override
  String get pageAudioTitle => 'Аудіо';

  @override
  String get pageSplit => 'Розділити';

  @override
  String get pageExportTitle => 'Експорт';

  @override
  String get pdfPagesKeepBackground => 'PDF-сторінки зберігають фон документа';

  @override
  String get pdfPagesKeepDimensions =>
      'PDF-сторінки зберігають розміри документа';

  @override
  String get pdfPagesKeepOrientation =>
      'PDF-сторінки зберігають орієнтацію документа';

  @override
  String get exportPageAsPng => 'Експорт сторінки як PNG';

  @override
  String get exportPageAsPngSubtitle => 'Надіслати зображення цієї сторінки';

  @override
  String get exportPageAsPdf => 'Експорт сторінки як PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Векторне чорнило, надіслати через системне меню';

  @override
  String get exportNotebookAsPdf => 'Експорт зошита як PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сторінок',
      many: '$count сторінок',
      few: '$count сторінки',
      one: '1 сторінка',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Додати аудіофайл';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV та інші локальні формати';

  @override
  String get pageAudioAttachedToPage => 'Додано до цієї сторінки';

  @override
  String get pageAudioReplace => 'Замінити аудіофайл';

  @override
  String get pageAudioRemove => 'Видалити аудіо';

  @override
  String get pageAudioPlay => 'Відтворити';

  @override
  String get pageAudioPause => 'Пауза';

  @override
  String get contentsTitle => 'Зміст';

  @override
  String get contentsSubtitle =>
      'Заголовки з набраного тексту та OCR-індексованого чорнила';

  @override
  String get contentsEmpty =>
      'Заголовків ще не знайдено.\nДодайте великий або короткий набраний текст або заголовки з OCR-індексованого чорнила.';

  @override
  String contentsPageNumber(int number) {
    return 'Сторінка $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Сторінки';

  @override
  String pageOverviewSelected(int count) {
    return 'Вибрано: $count';
  }

  @override
  String get pageOverviewDeleteSelected => 'Видалити вибране';

  @override
  String get pageOverviewSelectPages => 'Вибрати сторінки';

  @override
  String get pageOverviewKeepOnePage => 'Залиште щонайменше одну сторінку';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сторінок',
      many: '$count сторінок',
      few: '$count сторінки',
      one: '1 сторінку',
    );
    return 'Видалити $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Цю дію не можна скасувати.';

  @override
  String get pageOverviewDragToReorder => 'Перетягніть, щоб змінити порядок';

  @override
  String get pageOverviewBookmarked => 'Закладена';

  @override
  String get ocrIndexing => 'Індексація OCR…';

  @override
  String get ocrHandwritingSearchable => 'Пошук по почерку доступний';

  @override
  String get ocrPartial => 'Часткове OCR';

  @override
  String get trashTitle => 'Кошик';

  @override
  String trashFailedToLoad(String error) {
    return 'Не вдалося завантажити кошик: $error';
  }

  @override
  String get trashEmpty => 'Кошик порожній';

  @override
  String get trashSectionFolders => 'Папки';

  @override
  String get trashSectionNotebooks => 'Зошити';

  @override
  String get trashDeletionDateUnavailable => 'Дата видалення недоступна';

  @override
  String get trashExpiresToday => 'Зникне сьогодні';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Залишилося $count днів',
      many: 'Залишилося $count днів',
      few: 'Залишилося $count дні',
      one: 'Залишився 1 день',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Відновити';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Назавжди видалити «$title»?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Це видалить зошит і всі його сторінки з цього пристрою.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Назавжди видалити «$name»?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Це видалить папку та її зошити з цього пристрою.';

  @override
  String get trashDeleteAll => 'Delete all';

  @override
  String get trashDeleteAllConfirmTitle => 'Delete all items in Trash?';

  @override
  String get trashDeleteAllConfirmBody =>
      'This permanently removes all trashed notebooks and folders from this device.';

  @override
  String get splitPageTitle => 'Розділити сторінку?';

  @override
  String splitPageBody(int count) {
    return 'Створити нову сторінку з тим самим шаблоном і перенести на неї приблизно половину з $count штрихів.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Потрібно щонайменше 2 штрихи, щоб розділити цю сторінку';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Сторінку розділено: перенесено $moved штрихів, залишилося $remaining';
  }

  @override
  String splitPageFailed(String error) {
    return 'Помилка розділення: $error';
  }

  @override
  String get splitPageAction => 'Розділити сторінку';

  @override
  String get changePageSizeTitle => 'Змінити розмір сторінки?';

  @override
  String get changePageSizeBody =>
      'На цій сторінці є чорнило. Зміна розміру перекомпонує сторінку; чорнило залишиться на тих самих позиціях.';

  @override
  String get changeOrientationTitle => 'Змінити орієнтацію?';

  @override
  String get changeOrientationBody =>
      'На цій сторінці є чорнило. Зміна орієнтації масштабує та центрує вміст під нові межі сторінки.';

  @override
  String convertedToText(String preview) {
    return 'Перетворено на текст: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => 'Не вдалося розпізнати почерк';

  @override
  String get handwritingModelTitle => 'Модель розпізнавання почерку';

  @override
  String get handwritingModelDownloadFailed =>
      'Помилка завантаження. Перевірте мережу та повторіть.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Завантаження англомовної моделі розпізнавання почерку (~$sizeMb МБ)…';
  }

  @override
  String get handwritingModelReady => 'Модель готова.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Минуло: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Перше завантаження (~$sizeMb МБ). Зазвичай завершується менш ніж за дві хвилини через Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Сторінку експортовано як PNG';

  @override
  String get pageExportedAsPdf => 'Сторінку експортовано як PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Зошит експортовано як PDF';

  @override
  String get exportPreparing => 'Підготовка експорту…';

  @override
  String exportProgress(int current, int total) {
    return 'Експорт сторінки $current з $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'На цій сторінці $count штрихів — може працювати повільно. Розділіть її для кращої продуктивності.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Експорт заблоковано: на сторінці $count штрихів (ліміт $limit). Спочатку розділіть важкі сторінки.';
  }

  @override
  String get restoreComplete =>
      'Відновлення завершено. Перезапустіть застосунок, щоб завантажити відновлені дані.';

  @override
  String get textToolHint => 'Введіть текст…';

  @override
  String get textToolDone => 'Готово';

  @override
  String get languageKorean => 'Корейська';

  @override
  String get languagePolish => 'Польська';

  @override
  String get languageSpanish => 'Іспанська';

  @override
  String get languageItalian => 'Італійська';

  @override
  String get languageUkrainian => 'Українська';

  @override
  String get languageSwedish => 'Шведська';

  @override
  String get languageNorwegian => 'Норвезька';

  @override
  String get languageFinnish => 'Фінська';

  @override
  String get languageDanish => 'Данська';

  @override
  String get languagePortuguese => 'Португальська';
}
