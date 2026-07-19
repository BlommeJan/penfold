// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionCreate => 'Crear';

  @override
  String get actionRename => 'Renombrar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionSplit => 'Dividir';

  @override
  String get actionRecover => 'Recuperar';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionRetrying => 'Reintentando…';

  @override
  String get actionExportFirst => 'Exportar primero';

  @override
  String get actionEraseAll => 'Borrar todo';

  @override
  String get actionChangeSize => 'Cambiar tamaño';

  @override
  String get actionChangeOrientation => 'Cambiar orientación';

  @override
  String get actionUseColor => 'Usar color';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Vista general';

  @override
  String get libraryTrash => 'Papelera';

  @override
  String get librarySettings => 'Ajustes';

  @override
  String get libraryFolders => 'Carpetas';

  @override
  String get libraryNoFoldersYet => 'Aún no hay carpetas';

  @override
  String get libraryAll => 'Todos';

  @override
  String get libraryUncategorized => 'Sin categoría';

  @override
  String get libraryBreadcrumb => 'Biblioteca';

  @override
  String get librarySearchHint => 'Buscar cuadernos y texto tecleado…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Sin resultados';

  @override
  String get libraryFolderEmpty => 'Esta carpeta está vacía';

  @override
  String get libraryNoNotebooksWithTag => 'No hay cuadernos con esta etiqueta';

  @override
  String get libraryNoUncategorizedNotebooks =>
      'No hay cuadernos sin categoría';

  @override
  String get libraryNoNotebooksYet => 'Aún no hay cuadernos';

  @override
  String libraryCouldNotLoad(String error) {
    return 'No se pudo cargar la biblioteca: $error';
  }

  @override
  String get tooltipBackupRestore => 'Copia de seguridad y restauración';

  @override
  String get tooltipTrash => 'Papelera';

  @override
  String get tooltipNewNotebook => 'Nuevo cuaderno';

  @override
  String get tooltipNewFolder => 'Nueva carpeta';

  @override
  String get tooltipNewSubfolder => 'Nueva subcarpeta';

  @override
  String get tooltipImportPdf => 'Importar PDF';

  @override
  String get folderNew => 'Nueva carpeta';

  @override
  String get folderNewSubfolder => 'Nueva subcarpeta';

  @override
  String get folderRename => 'Renombrar carpeta';

  @override
  String get folderMoveToTrash => 'Mover a la papelera';

  @override
  String folderMoveToTrashTitle(String name) {
    return '¿Mover «$name» a la papelera?';
  }

  @override
  String get folderMoveToTrashBody =>
      'La carpeta y sus cuadernos se moverán a la papelera durante 30 días.';

  @override
  String get notebookNew => 'Nuevo cuaderno';

  @override
  String get notebookUntitled => 'Sin título';

  @override
  String get notebookTitleLabel => 'Título';

  @override
  String get notebookSizeLabel => 'Tamaño';

  @override
  String get notebookPaperLabel => 'Papel';

  @override
  String get notebookCoverLabel => 'Portada';

  @override
  String get notebookRename => 'Renombrar cuaderno';

  @override
  String get notebookMoveToFolder => 'Mover a carpeta';

  @override
  String get notebookEditTags => 'Editar etiquetas';

  @override
  String get notebookExportWorkbook => 'Exportar cuaderno';

  @override
  String get notebookExportWorkbookSubtitle =>
      'Compartir todas las páginas como PDF';

  @override
  String get notebookMoveToTrash => 'Mover a la papelera';

  @override
  String notebookMoveToTrashTitle(String title) {
    return '¿Mover «$title» a la papelera?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'El cuaderno se ocultará de la biblioteca durante 30 días. La tinta y las páginas permanecen en este dispositivo hasta que vacíes la papelera. Exporta primero una copia de seguridad si quieres una copia extra.';

  @override
  String notebookTagsFor(String title) {
    return 'Etiquetas de «$title»';
  }

  @override
  String get notebookNoTagsYet => 'Aún no hay etiquetas. Crea una abajo.';

  @override
  String get notebookNewTag => 'Nueva etiqueta';

  @override
  String get notebookAddTag => 'Añadir etiqueta';

  @override
  String get notebookNoPagesToExport =>
      'Este cuaderno no tiene páginas para exportar';

  @override
  String notebookExportedAsPdf(String title) {
    return '«$title» exportado en PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Copia de seguridad exportada. Puedes mover el cuaderno a la papelera cuando quieras.';

  @override
  String get importPdfSnack =>
      'Importando PDF… las páginas se renderizan una vez y luego quedan sin conexión.';

  @override
  String importFailed(String error) {
    return 'Error al importar: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Error en la copia de seguridad: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Error al recuperar: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'Descargando modelo de escritura a mano (~$sizeMb MB) en segundo plano…';
  }

  @override
  String get templateBlank => 'En blanco';

  @override
  String get templateLined => 'Rayado';

  @override
  String get templateGrid => 'Cuadrícula';

  @override
  String get templateDotted => 'Punteado';

  @override
  String get templateCollegeRuled => 'Universitario';

  @override
  String get templateCollegeShort => 'Univ.';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Carta';

  @override
  String get orientationPortrait => 'Vertical';

  @override
  String get orientationLandscape => 'Horizontal';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsSectionAppearanceAndPreferences =>
      'Apariencia y preferencias';

  @override
  String get settingsSectionAppearance => 'Apariencia';

  @override
  String get settingsAppearanceDarkMode => 'Modo oscuro';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Elige claro, oscuro o seguir el dispositivo (predeterminado del sistema)';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get settingsSectionPreferences => 'Preferencias';

  @override
  String get settingsLanguageLabel => 'Idioma de la aplicación';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageDutch => 'Neerlandés';

  @override
  String get settingsSectionToolbar => 'Barra de herramientas';

  @override
  String get settingsToolbarReorderHint =>
      'Arrastra para reordenar las herramientas de dibujo. Deshacer y rehacer permanecen fijos a la derecha.';

  @override
  String get settingsResetToolbarOrder => 'Restablecer orden de la barra';

  @override
  String get settingsSectionNotebook => 'Cuaderno';

  @override
  String get settingsPageTurnMode => 'Modo página a página';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Deslizar de página en página en lugar de desplazamiento continuo (desactivado por defecto)';

  @override
  String get settingsZoomNavigation => 'Navegación con zoom';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Pellizcar para ampliar y desplazarse en las páginas (activado por defecto)';

  @override
  String get settingsSectionDrawing => 'Dibujo';

  @override
  String get settingsStrokeSmoothing => 'Suavizado de trazos';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Suaviza los trazos de tinta con el algoritmo Chaikin (activado por defecto)';

  @override
  String get settingsStrokeSmoothingStrength => 'Intensidad del suavizado';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent % — un valor más bajo conserva más detalle; recomendado $recommended %';
  }

  @override
  String get settingsFingerDrawing => 'Dibujo con el dedo';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Dibujar con el dedo en el papel; si está desactivado, solo el lápiz óptico dibuja (desactivado por defecto)';

  @override
  String get settingsGestureInkEditing => 'Edición de tinta por gestos';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Pasa sobre la tinta indexada por OCR para borrarla (activado por defecto)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Mantén pulsado el botón lateral del S Pen para cambiar temporalmente de herramienta. Suéltalo para volver a la herramienta anterior. Funciona en dispositivos Samsung con botón lateral.';

  @override
  String get settingsSpenBarrelAction => 'Acción del botón lateral';

  @override
  String get settingsSectionOcrDictionary => 'Diccionario OCR';

  @override
  String get settingsOcrDictionaryHint =>
      'Términos de dominio para el OCR de escritura a mano. Las coincidencias cercanas se corrigen al indexar la tinta, y los términos mejoran la búsqueda en cuadernos.';

  @override
  String get settingsNoCustomOcrTerms => 'Aún no hay términos personalizados.';

  @override
  String get settingsRemoveOcrTerm => 'Eliminar término';

  @override
  String get settingsAddOcrTerm => 'Añadir término';

  @override
  String get settingsAddOcrTermTitle => 'Añadir término OCR';

  @override
  String get settingsOcrTermLabel => 'Término';

  @override
  String get settingsOcrTermHint => 'p. ej., autovalor, mitocondria';

  @override
  String get settingsSectionYourData => 'Tus datos';

  @override
  String get settingsYourDataHint =>
      'Penfold guarda todo en este dispositivo en una única base de datos SQLite y carpetas de recursos — sin sincronización en la nube. Consulta docs/ARCHITECTURE.md para la estructura completa de archivos en el dispositivo.';

  @override
  String get settingsDatabase => 'Base de datos';

  @override
  String get settingsSectionBackupRestore =>
      'Copia de seguridad y restauración';

  @override
  String get settingsBackupRestoreHint =>
      'Exporta un zip de penfold.db y las carpetas de recursos, o restaura desde una copia anterior. Tu base de datos actual se guarda en backups/ antes de restaurar.';

  @override
  String get settingsExportBackup => 'Exportar copia de seguridad';

  @override
  String get settingsExportBackupSubtitle =>
      'Crea un archivo zip con penfold.db, fuentes PDF, imágenes y páginas PDF heredadas';

  @override
  String get settingsRecoverFromBackup => 'Recuperar desde copia de seguridad';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Última copia automática: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Restaurar copia de seguridad';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Reemplazar datos locales desde un zip de copia de Penfold';

  @override
  String get settingsRecoverAutoBackupTitle =>
      '¿Recuperar desde copia automática?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Esto reemplazará tus cuadernos y archivos actuales con la copia del $timestamp. Tu base de datos actual se guardará en backups/ antes de restaurar.';
  }

  @override
  String get settingsRestoreBackupTitle => '¿Restaurar copia de seguridad?';

  @override
  String get settingsRestoreBackupBody =>
      'Esto reemplazará tus cuadernos y archivos actuales. Tu base de datos actual se guardará en backups/ antes de restaurar.';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsAboutSubtitle =>
      'App de notas manuscritas con almacenamiento local — sin cuentas, sin nube.';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get spenActionEraser => 'Goma';

  @override
  String get spenActionLasso => 'Lazo';

  @override
  String get spenActionPen => 'Pluma';

  @override
  String get spenActionNone => 'Ninguna';

  @override
  String get toolPen => 'Pluma';

  @override
  String get toolHighlighter => 'Subrayador';

  @override
  String get toolTape => 'Cinta';

  @override
  String get toolEraser => 'Goma';

  @override
  String get toolSelection => 'Selección';

  @override
  String get toolLasso => 'Lazo';

  @override
  String get toolShape => 'Forma';

  @override
  String get toolFill => 'Relleno';

  @override
  String get toolText => 'Texto';

  @override
  String get toolInsertImage => 'Insertar imagen';

  @override
  String get brushPen => 'Pluma';

  @override
  String get brushFountain => 'Estilográfica';

  @override
  String get brushPencil => 'Lápiz';

  @override
  String get brushMarker => 'Rotulador';

  @override
  String get brushCalligraphy => 'Caligrafía';

  @override
  String get toolbarPreviousBookmark => 'Marcador anterior';

  @override
  String get toolbarNextBookmark => 'Marcador siguiente';

  @override
  String get toolbarConvertToText => 'Convertir a texto';

  @override
  String get toolbarCopy => 'Copiar';

  @override
  String get toolbarDelete => 'Eliminar';

  @override
  String get toolbarPaste => 'Pegar';

  @override
  String get toolbarUndo => 'Deshacer';

  @override
  String get toolbarRedo => 'Rehacer';

  @override
  String get toolbarAddPage => 'Añadir página';

  @override
  String get toolbarStylusOnly => 'Solo stylus (rechazo de palma)';

  @override
  String get toolbarFingerDrawing => 'Dibujo con el dedo';

  @override
  String get toolbarPageOverview => 'Vista de páginas';

  @override
  String get toolbarTableOfContents => 'Índice';

  @override
  String get toolbarPageMenu => 'Menú de página';

  @override
  String get penOptionsTitle => 'Pluma';

  @override
  String get highlighterOptionsTitle => 'Subrayador';

  @override
  String get brushLabel => 'Pincel';

  @override
  String get colorLabel => 'Color';

  @override
  String get customColorTitle => 'Color personalizado';

  @override
  String get hueLabel => 'Tono';

  @override
  String get saturationLabel => 'Saturación';

  @override
  String get brightnessLabel => 'Brillo';

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
  String get tapeOptionsTitle => 'Cinta';

  @override
  String get tapeOptionsHint =>
      'Dibuja para cubrir notas; toca la cinta para mostrar u ocultar de nuevo';

  @override
  String get fillColorTitle => 'Color de relleno';

  @override
  String get fillOptionsHint =>
      'Dibuja un bucle cerrado o toca dentro de una forma para rellenar';

  @override
  String get eraserSizeTitle => 'Tamaño de la goma';

  @override
  String get eraserModeTitle => 'Modo de la goma';

  @override
  String get eraserModePixel => 'Píxel';

  @override
  String get eraserModeStroke => 'Trazo';

  @override
  String get eraserModePartialHint =>
      'Borra solo la tinta bajo el círculo de la goma';

  @override
  String get eraserModeWholeStrokeHint =>
      'Borra los trazos completos que toque';

  @override
  String get eraseAllOnPageTitle => '¿Borrar todo en la página?';

  @override
  String get eraseAllOnPageBody =>
      'Esto elimina todos los trazos de la página actual. Puedes deshacer esta acción.';

  @override
  String get eraseAllOnPageButton => 'Borrar todo en la página';

  @override
  String get pageSettingsTitle => 'Ajustes de página';

  @override
  String get pageColorTitle => 'Color de página';

  @override
  String get pageThemeTitle => 'Tema de página';

  @override
  String get defaultPaperSize => 'Tamaño de papel predeterminado';

  @override
  String get defaultPaperType => 'Tipo de papel predeterminado';

  @override
  String get defaultPageTheme => 'Tema de página predeterminado';

  @override
  String get notebookDefaultsHint =>
      'Se usa al crear un cuaderno nuevo. Puedes cambiar las opciones en el diálogo.';

  @override
  String get pageThemeLight => 'Claro';

  @override
  String get pageThemeDark => 'Oscuro';

  @override
  String get pageThemeSepia => 'Sepia';

  @override
  String get pageThemePastelPink => 'Rosa pastel';

  @override
  String get pageThemePastelBlue => 'Azul pastel';

  @override
  String get pageThemePastelMint => 'Menta pastel';

  @override
  String get pageSizeTitle => 'Tamaño de página';

  @override
  String get pageOrientationTitle => 'Orientación';

  @override
  String get pageTemplateTitle => 'Plantilla de página';

  @override
  String get pageBookmark => 'Marcador';

  @override
  String get pageRemoveBookmark => 'Quitar marcador';

  @override
  String get pageAudioTitle => 'Audio';

  @override
  String get pageSplit => 'Dividir';

  @override
  String get pageExportTitle => 'Exportar';

  @override
  String get pdfPagesKeepBackground =>
      'Las páginas PDF conservan el fondo del documento';

  @override
  String get pdfPagesKeepDimensions =>
      'Las páginas PDF conservan las dimensiones del documento';

  @override
  String get pdfPagesKeepOrientation =>
      'Las páginas PDF conservan la orientación del documento';

  @override
  String get exportPageAsPng => 'Exportar página como PNG';

  @override
  String get exportPageAsPngSubtitle => 'Compartir imagen de esta página';

  @override
  String get exportPageAsPdf => 'Exportar página como PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Tinta vectorial; compartir mediante el menú de compartir del sistema';

  @override
  String get exportNotebookAsPdf => 'Exportar cuaderno como PDF';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => 'Adjuntar archivo de audio';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV y otros formatos locales';

  @override
  String get pageAudioAttachedToPage => 'Adjunto a esta página';

  @override
  String get pageAudioReplace => 'Reemplazar archivo de audio';

  @override
  String get pageAudioRemove => 'Quitar audio';

  @override
  String get pageAudioPlay => 'Reproducir';

  @override
  String get pageAudioPause => 'Pausar';

  @override
  String get contentsTitle => 'Índice';

  @override
  String get contentsSubtitle =>
      'Encabezados del texto tecleado y la tinta indexada por OCR';

  @override
  String get contentsEmpty =>
      'Aún no se encontraron encabezados.\nAñade texto tecleado grande o breve, o encabezados de tinta indexados por OCR.';

  @override
  String contentsPageNumber(int number) {
    return 'Página $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Páginas';

  @override
  String pageOverviewSelected(int count) {
    return '$count seleccionadas';
  }

  @override
  String get pageOverviewDeleteSelected => 'Eliminar seleccionadas';

  @override
  String get pageOverviewSelectPages => 'Seleccionar páginas';

  @override
  String get pageOverviewKeepOnePage => 'Conserva al menos una página';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '¿Eliminar $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Esto no se puede deshacer.';

  @override
  String get pageOverviewDragToReorder => 'Arrastra para reordenar';

  @override
  String get pageOverviewBookmarked => 'Con marcador';

  @override
  String get ocrIndexing => 'Indexando OCR…';

  @override
  String get ocrHandwritingSearchable => 'Escritura a mano buscable';

  @override
  String get ocrPartial => 'OCR parcial';

  @override
  String get trashTitle => 'Papelera';

  @override
  String trashFailedToLoad(String error) {
    return 'Error al cargar la papelera: $error';
  }

  @override
  String get trashEmpty => 'La papelera está vacía';

  @override
  String get trashSectionFolders => 'Carpetas';

  @override
  String get trashSectionNotebooks => 'Cuadernos';

  @override
  String get trashDeletionDateUnavailable =>
      'Fecha de eliminación no disponible';

  @override
  String get trashExpiresToday => 'Se elimina hoy';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count días',
      one: 'Queda 1 día',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restaurar';

  @override
  String trashDeleteNotebookTitle(String title) {
    return '¿Eliminar «$title» permanentemente?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Esto elimina el cuaderno y todas sus páginas de este dispositivo.';

  @override
  String trashDeleteFolderTitle(String name) {
    return '¿Eliminar «$name» permanentemente?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Esto elimina la carpeta y sus cuadernos de este dispositivo.';

  @override
  String get splitPageTitle => '¿Dividir página?';

  @override
  String splitPageBody(int count) {
    return 'Crea una página nueva con la misma plantilla y mueve aproximadamente la mitad de los $count trazos a ella.';
  }

  @override
  String get splitPageNeedStrokes =>
      'Se necesitan al menos 2 trazos para dividir esta página';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Página dividida: $moved trazos movidos, $remaining permanecen';
  }

  @override
  String splitPageFailed(String error) {
    return 'Error al dividir: $error';
  }

  @override
  String get splitPageAction => 'Dividir página';

  @override
  String get changePageSizeTitle => '¿Cambiar tamaño de página?';

  @override
  String get changePageSizeBody =>
      'Esta página tiene tinta. Cambiar el tamaño volverá a maquetar la página; tu tinta permanecerá en la misma posición.';

  @override
  String get changeOrientationTitle => '¿Cambiar orientación?';

  @override
  String get changeOrientationBody =>
      'Esta página tiene tinta. Cambiar la orientación escalará y centrará el contenido para ajustarlo a los nuevos límites de la página.';

  @override
  String convertedToText(String preview) {
    return 'Convertido a texto: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'No se pudo reconocer la escritura a mano';

  @override
  String get handwritingModelTitle => 'Modelo de escritura a mano';

  @override
  String get handwritingModelDownloadFailed =>
      'Error en la descarga. Comprueba la red e inténtalo de nuevo.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'Descargando modelo de escritura a mano en inglés (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Modelo listo.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Transcurrido: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Descarga inicial (~$sizeMb MB). Suele completarse en menos de dos minutos con Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Página exportada como PNG';

  @override
  String get pageExportedAsPdf => 'Página exportada en PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Cuaderno exportado en PDF';

  @override
  String get exportPreparing => 'Preparando exportación…';

  @override
  String exportProgress(int current, int total) {
    return 'Exportando página $current de $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Esta página tiene $count trazos y puede ir lenta. Considera dividirla para mejorar el rendimiento.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'No se puede exportar: una página tiene $count trazos (límite $limit). Divide primero las páginas pesadas.';
  }

  @override
  String get restoreComplete =>
      'Restauración completada. Reinicia la aplicación para cargar los datos restaurados.';

  @override
  String get textToolHint => 'Escribe aquí…';

  @override
  String get textToolDone => 'Listo';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languagePolish => 'Polaco';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get languageSwedish => 'Sueco';

  @override
  String get languageNorwegian => 'Noruego';

  @override
  String get languageFinnish => 'Finlandés';

  @override
  String get languageDanish => 'Danés';

  @override
  String get languagePortuguese => 'Portugués';
}
