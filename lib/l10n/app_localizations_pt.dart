// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionCreate => 'Criar';

  @override
  String get actionRename => 'Mudar o nome';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionSplit => 'Dividir';

  @override
  String get actionRecover => 'Recuperar';

  @override
  String get actionRestore => 'Restaurar';

  @override
  String get actionExport => 'Exportar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionRetrying => 'A tentar novamente…';

  @override
  String get actionExportFirst => 'Exportar primeiro';

  @override
  String get actionEraseAll => 'Apagar tudo';

  @override
  String get actionChangeSize => 'Alterar tamanho';

  @override
  String get actionChangeOrientation => 'Alterar orientação';

  @override
  String get actionUseColor => 'Usar cor';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => 'Visão geral';

  @override
  String get libraryTrash => 'Lixo';

  @override
  String get librarySettings => 'Definições';

  @override
  String get libraryFolders => 'Pastas';

  @override
  String get libraryNoFoldersYet => 'Ainda não há pastas';

  @override
  String get libraryAll => 'Tudo';

  @override
  String get libraryViewAll => 'All';

  @override
  String get libraryViewOverview => 'Overview';

  @override
  String get libraryUncategorized => 'Sem categoria';

  @override
  String get libraryBreadcrumb => 'Biblioteca';

  @override
  String get librarySearchHint => 'Pesquisar cadernos e texto digitado…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => 'Sem resultados';

  @override
  String get libraryFolderEmpty => 'Esta pasta está vazia';

  @override
  String get libraryNoNotebooksWithTag => 'Nenhum caderno com esta etiqueta';

  @override
  String get libraryNoUncategorizedNotebooks => 'Nenhum caderno sem categoria';

  @override
  String get libraryNoNotebooksYet => 'Ainda não há cadernos';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return 'Não foi possível carregar a biblioteca: $error';
  }

  @override
  String get tooltipBackupRestore => 'Cópia de segurança e restauro';

  @override
  String get tooltipTrash => 'Lixo';

  @override
  String get tooltipNewNotebook => 'Novo caderno';

  @override
  String get tooltipNewFolder => 'Nova pasta';

  @override
  String get tooltipNewSubfolder => 'Nova subpasta';

  @override
  String get tooltipImportPdf => 'Importar PDF';

  @override
  String get folderNew => 'Nova pasta';

  @override
  String get folderNewSubfolder => 'Nova subpasta';

  @override
  String get folderRename => 'Mudar o nome da pasta';

  @override
  String get folderMoveToTrash => 'Mover para o lixo';

  @override
  String folderMoveToTrashTitle(String name) {
    return 'Mover \"$name\" para o lixo?';
  }

  @override
  String get folderMoveToTrashBody =>
      'A pasta e os seus cadernos vão para o lixo durante 30 dias.';

  @override
  String get notebookNew => 'Novo caderno';

  @override
  String get notebookUntitled => 'Sem título';

  @override
  String get notebookTitleLabel => 'Título';

  @override
  String get notebookSizeLabel => 'Tamanho';

  @override
  String get notebookPaperLabel => 'Papel';

  @override
  String get notebookCoverLabel => 'Capa';

  @override
  String get notebookRename => 'Mudar o nome do caderno';

  @override
  String get notebookMoveToFolder => 'Mover para a pasta';

  @override
  String get notebookEditTags => 'Editar etiquetas';

  @override
  String get notebookExportWorkbook => 'Exportar o caderno';

  @override
  String get notebookExportWorkbookSubtitle =>
      'Partilhar todas as páginas em PDF';

  @override
  String get notebookMoveToTrash => 'Mover para o lixo';

  @override
  String notebookMoveToTrashTitle(String title) {
    return 'Mover \"$title\" para o lixo?';
  }

  @override
  String get notebookMoveToTrashBody =>
      'O caderno fica oculto na biblioteca durante 30 dias. A tinta e as páginas permanecem neste dispositivo até esvaziar o lixo. Exporte primeiro uma cópia de segurança se quiser uma cópia extra.';

  @override
  String notebookTagsFor(String title) {
    return 'Etiquetas de \"$title\"';
  }

  @override
  String get notebookNoTagsYet => 'Ainda não há etiquetas. Crie uma abaixo.';

  @override
  String get notebookNewTag => 'Nova etiqueta';

  @override
  String get notebookAddTag => 'Adicionar etiqueta';

  @override
  String get notebookNoPagesToExport =>
      'Este caderno não tem páginas para exportar';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\" exportado em PDF';
  }

  @override
  String get notebookBackupExportedReady =>
      'Cópia de segurança exportada. Pode mover para o lixo quando quiser.';

  @override
  String get importPdfSnack =>
      'A importar PDF… as páginas são renderizadas uma vez e depois ficam offline.';

  @override
  String importFailed(String error) {
    return 'Falha na importação: $error';
  }

  @override
  String exportFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String backupFailed(String error) {
    return 'Falha na cópia de segurança: $error';
  }

  @override
  String recoveryFailed(String error) {
    return 'Falha na recuperação: $error';
  }

  @override
  String restoreFailed(String error) {
    return 'Falha no restauro: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return 'A transferir o modelo de escrita manual (~$sizeMb MB) em segundo plano…';
  }

  @override
  String get templateBlank => 'Em branco';

  @override
  String get templateLined => 'Pautado';

  @override
  String get templateGrid => 'Grelha';

  @override
  String get templateDotted => 'Ponteado';

  @override
  String get templateCollegeRuled => 'Pautado universitário';

  @override
  String get templateCollegeShort => 'Universitário';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => 'Retrato';

  @override
  String get orientationLandscape => 'Paisagem';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => 'Definições';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsSectionAppearanceAndPreferences => 'Aspeto e preferências';

  @override
  String get settingsSectionAppearance => 'Aspeto';

  @override
  String get settingsAppearanceDarkMode => 'Modo escuro';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      'Escolha claro, escuro ou igual ao dispositivo (predefinição do sistema)';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get settingsSectionPreferences => 'Preferências';

  @override
  String get settingsLanguageLabel => 'Idioma da aplicação';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageDutch => 'Neerlandês';

  @override
  String get settingsSectionToolbar => 'Barra de ferramentas';

  @override
  String get settingsToolbarReorderHint =>
      'Arraste para reordenar as ferramentas de desenho. Desfazer e refazer ficam fixos à direita.';

  @override
  String get settingsResetToolbarOrder => 'Repor ordem da barra de ferramentas';

  @override
  String get settingsSectionNotebook => 'Caderno';

  @override
  String get settingsPageTurnMode => 'Modo de virar página';

  @override
  String get settingsPageTurnModeSubtitle =>
      'Deslize uma página de cada vez em vez de deslocamento contínuo (predefinição desligada)';

  @override
  String get settingsZoomNavigation => 'Navegação com zoom';

  @override
  String get settingsZoomNavigationSubtitle =>
      'Beliscar para ampliar e deslocar nas páginas (predefinição ligada)';

  @override
  String get settingsSectionDrawing => 'Desenho';

  @override
  String get settingsStrokeSmoothing => 'Suavização de traços';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Suaviza traços de tinta com o algoritmo Chaikin (predefinição ligada)';

  @override
  String get settingsStrokeSmoothingStrength => 'Intensidade da suavização';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — valores mais baixos preservam mais detalhe; recomendado $recommended%';
  }

  @override
  String get settingsFingerDrawing => 'Desenho com o dedo';

  @override
  String get settingsFingerDrawingSubtitle =>
      'Desenhe com o dedo no papel; desligado, só a caneta desenha (predefinição desligada)';

  @override
  String get settingsGestureInkEditing => 'Edição de tinta por gestos';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'Raspe sobre tinta indexada por OCR para a apagar (predefinição ligada)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'Mantenha premido o botão lateral da S Pen para mudar temporariamente de ferramenta. Solte para restaurar a ferramenta anterior. Funciona em dispositivos Samsung com suporte para o botão lateral.';

  @override
  String get settingsSpenBarrelAction => 'Ação do botão lateral';

  @override
  String get settingsSectionOcrDictionary => 'Dicionário OCR';

  @override
  String get settingsOcrDictionaryHint =>
      'Termos de domínio para OCR de escrita manual. Correspondências próximas são corrigidas quando a tinta é indexada, e os termos melhoram a pesquisa nos cadernos.';

  @override
  String get settingsNoCustomOcrTerms => 'Ainda não há termos personalizados.';

  @override
  String get settingsRemoveOcrTerm => 'Remover termo';

  @override
  String get settingsAddOcrTerm => 'Adicionar termo';

  @override
  String get settingsAddOcrTermTitle => 'Adicionar termo OCR';

  @override
  String get settingsOcrTermLabel => 'Termo';

  @override
  String get settingsOcrTermHint => 'p. ex. autovalor, mitocôndria';

  @override
  String get settingsSectionYourData => 'Os seus dados';

  @override
  String get settingsYourDataHint =>
      'O Penfold guarda tudo neste dispositivo numa única base de dados SQLite e pastas de recursos — sem sincronização na nuvem. Consulte docs/ARCHITECTURE.md para o esquema completo de ficheiros no dispositivo.';

  @override
  String get settingsDatabase => 'Base de dados';

  @override
  String get settingsSectionBackupRestore => 'Cópia de segurança e restauro';

  @override
  String get settingsBackupRestoreHint =>
      'Exporte um zip de penfold.db e pastas de recursos, ou restaure a partir de uma cópia de segurança anterior. A base de dados atual é guardada em backups/ antes do restauro.';

  @override
  String get settingsExportBackup => 'Exportar cópia de segurança';

  @override
  String get settingsExportBackupSubtitle =>
      'Comprimir penfold.db, fontes PDF, imagens e páginas PDF legadas';

  @override
  String get settingsRecoverFromBackup =>
      'Recuperar a partir de cópia de segurança';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return 'Última cópia de segurança automática: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => 'Restaurar cópia de segurança';

  @override
  String get settingsRestoreBackupSubtitle =>
      'Substituir dados locais a partir de um zip de cópia de segurança do Penfold';

  @override
  String get settingsRecoverAutoBackupTitle =>
      'Recuperar a partir da cópia de segurança automática?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return 'Isto substitui os seus cadernos e ficheiros atuais pela cópia de segurança de $timestamp. A base de dados atual será guardada em backups/ antes do restauro.';
  }

  @override
  String get settingsRestoreBackupTitle => 'Restaurar cópia de segurança?';

  @override
  String get settingsRestoreBackupBody =>
      'Isto substitui os seus cadernos e ficheiros atuais. A base de dados atual será guardada em backups/ antes do restauro.';

  @override
  String get settingsSectionAbout => 'Acerca de';

  @override
  String get settingsAboutSubtitle =>
      'Caderno de notas manuscritas local — sem contas, sem nuvem.';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get spenActionEraser => 'Borracha';

  @override
  String get spenActionLasso => 'Laço';

  @override
  String get spenActionPen => 'Caneta';

  @override
  String get spenActionNone => 'Nenhuma';

  @override
  String get toolPen => 'Caneta';

  @override
  String get toolHighlighter => 'Marcador';

  @override
  String get toolTape => 'Fita';

  @override
  String get toolEraser => 'Borracha';

  @override
  String get toolSelection => 'Seleção';

  @override
  String get toolLasso => 'Laço';

  @override
  String get toolShape => 'Forma';

  @override
  String get toolFill => 'Preenchimento';

  @override
  String get toolText => 'Texto';

  @override
  String get toolInsertImage => 'Inserir imagem';

  @override
  String get brushPen => 'Caneta';

  @override
  String get brushFountain => 'Caneta de tinteiro';

  @override
  String get brushPencil => 'Lápis';

  @override
  String get brushMarker => 'Marcador';

  @override
  String get brushCalligraphy => 'Caligrafia';

  @override
  String get toolbarPreviousBookmark => 'Marcador anterior';

  @override
  String get toolbarNextBookmark => 'Marcador seguinte';

  @override
  String get toolbarConvertToText => 'Converter em texto';

  @override
  String get toolbarCopy => 'Copiar';

  @override
  String get toolbarDelete => 'Eliminar';

  @override
  String get toolbarPaste => 'Colar';

  @override
  String get toolbarUndo => 'Desfazer';

  @override
  String get toolbarRedo => 'Refazer';

  @override
  String get toolbarAddPage => 'Adicionar página';

  @override
  String get toolbarStylusOnly => 'Só caneta (rejeição da palma da mão)';

  @override
  String get toolbarFingerDrawing => 'Desenho com o dedo';

  @override
  String get toolbarPageOverview => 'Visão geral das páginas';

  @override
  String get toolbarTableOfContents => 'Índice';

  @override
  String get toolbarPageMenu => 'Menu da página';

  @override
  String get penOptionsTitle => 'Caneta';

  @override
  String get highlighterOptionsTitle => 'Marcador';

  @override
  String get brushLabel => 'Pincel';

  @override
  String get colorLabel => 'Cor';

  @override
  String get customColorTitle => 'Cor personalizada';

  @override
  String get hueLabel => 'Matiz';

  @override
  String get saturationLabel => 'Saturação';

  @override
  String get brightnessLabel => 'Brilho';

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
  String get tapeOptionsTitle => 'Fita';

  @override
  String get tapeOptionsHint =>
      'Desenhe para cobrir notas; toque na fita para revelar ou ocultar novamente';

  @override
  String get fillColorTitle => 'Cor de preenchimento';

  @override
  String get fillOptionsHint =>
      'Desenhe um contorno fechado ou toque dentro de uma forma para preencher';

  @override
  String get eraserSizeTitle => 'Tamanho da borracha';

  @override
  String get eraserModeTitle => 'Modo da borracha';

  @override
  String get eraserModePixel => 'Píxel';

  @override
  String get eraserModeStroke => 'Traço';

  @override
  String get eraserModePartialHint =>
      'Apaga apenas a tinta sob o círculo da borracha';

  @override
  String get eraserModeWholeStrokeHint => 'Apaga traços inteiros que toque';

  @override
  String get eraseAllOnPageTitle => 'Apagar tudo na página?';

  @override
  String get eraseAllOnPageBody =>
      'Isto remove todos os traços na página atual. Pode desfazer esta ação.';

  @override
  String get eraseAllOnPageButton => 'Apagar tudo na página';

  @override
  String get pageSettingsTitle => 'Definições da página';

  @override
  String get pageColorTitle => 'Cor da página';

  @override
  String get pageThemeTitle => 'Tema da página';

  @override
  String get defaultPaperSize => 'Tamanho de papel predefinido';

  @override
  String get defaultPaperType => 'Tipo de papel predefinido';

  @override
  String get defaultPageTheme => 'Tema de página predefinido';

  @override
  String get notebookDefaultsHint =>
      'Usado quando cria um novo caderno. Ainda pode alterar as opções na caixa de diálogo.';

  @override
  String get pageThemeLight => 'Claro';

  @override
  String get pageThemeDark => 'Escuro';

  @override
  String get pageThemeSepia => 'Sépia';

  @override
  String get pageThemePastelPink => 'Rosa pastel';

  @override
  String get pageThemePastelBlue => 'Azul pastel';

  @override
  String get pageThemePastelMint => 'Verde menta pastel';

  @override
  String get pageSizeTitle => 'Tamanho da página';

  @override
  String get pageOrientationTitle => 'Orientação';

  @override
  String get pageTemplateTitle => 'Modelo da página';

  @override
  String get pageBookmark => 'Marcador';

  @override
  String get pageRemoveBookmark => 'Remover marcador';

  @override
  String get pageAudioTitle => 'Áudio';

  @override
  String get pageSplit => 'Dividir';

  @override
  String get pageExportTitle => 'Exportar';

  @override
  String get pdfPagesKeepBackground =>
      'As páginas PDF mantêm o fundo do documento';

  @override
  String get pdfPagesKeepDimensions =>
      'As páginas PDF mantêm as dimensões do documento';

  @override
  String get pdfPagesKeepOrientation =>
      'As páginas PDF mantêm a orientação do documento';

  @override
  String get exportPageAsPng => 'Exportar página como PNG';

  @override
  String get exportPageAsPngSubtitle => 'Partilhar imagem desta página';

  @override
  String get exportPageAsPdf => 'Exportar página como PDF';

  @override
  String get exportPageAsPdfSubtitle =>
      'Tinta vetorial; partilhar através do menu de partilha do sistema';

  @override
  String get exportNotebookAsPdf => 'Exportar o caderno em PDF';

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
  String get pageAudioAttach => 'Anexar ficheiro de áudio';

  @override
  String get pageAudioAttachSubtitle =>
      'MP3, M4A, WAV e outros formatos locais';

  @override
  String get pageAudioAttachedToPage => 'Anexado a esta página';

  @override
  String get pageAudioReplace => 'Substituir ficheiro de áudio';

  @override
  String get pageAudioRemove => 'Remover áudio';

  @override
  String get pageAudioPlay => 'Reproduzir';

  @override
  String get pageAudioPause => 'Pausar';

  @override
  String get contentsTitle => 'Conteúdo';

  @override
  String get contentsSubtitle =>
      'Títulos de texto digitado e tinta indexada por OCR';

  @override
  String get contentsEmpty =>
      'Ainda não foram encontrados títulos.\nAdicione texto digitado grande ou curto, ou títulos de tinta indexados por OCR.';

  @override
  String contentsPageNumber(int number) {
    return 'Página $number';
  }

  @override
  String get pageOverviewPagesSuffix => ' — Páginas';

  @override
  String pageOverviewSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionadas',
      one: '1 selecionada',
    );
    return '$_temp0';
  }

  @override
  String get pageOverviewDeleteSelected => 'Eliminar selecionadas';

  @override
  String get pageOverviewSelectPages => 'Selecionar páginas';

  @override
  String get pageOverviewKeepOnePage => 'Mantenha pelo menos uma página';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return 'Eliminar $_temp0?';
  }

  @override
  String get pageOverviewDeleteBody => 'Isto não pode ser desfeito.';

  @override
  String get pageOverviewDragToReorder => 'Arraste para reordenar';

  @override
  String get pageOverviewBookmarked => 'Com marcador';

  @override
  String get ocrIndexing => 'A indexar OCR…';

  @override
  String get ocrHandwritingSearchable => 'Escrita manual pesquisável';

  @override
  String get ocrPartial => 'OCR parcial';

  @override
  String get trashTitle => 'Lixo';

  @override
  String trashFailedToLoad(String error) {
    return 'Falha ao carregar o lixo: $error';
  }

  @override
  String get trashEmpty => 'O lixo está vazio';

  @override
  String get trashSectionFolders => 'Pastas';

  @override
  String get trashSectionNotebooks => 'Cadernos';

  @override
  String get trashDeletionDateUnavailable => 'Data de eliminação indisponível';

  @override
  String get trashExpiresToday => 'Expira hoje';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias restantes',
      one: '1 dia restante',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => 'Restaurar';

  @override
  String trashDeleteNotebookTitle(String title) {
    return 'Eliminar \"$title\" permanentemente?';
  }

  @override
  String get trashDeleteNotebookBody =>
      'Isto remove o caderno e todas as páginas deste dispositivo.';

  @override
  String trashDeleteFolderTitle(String name) {
    return 'Eliminar \"$name\" permanentemente?';
  }

  @override
  String get trashDeleteFolderBody =>
      'Isto remove a pasta e os seus cadernos deste dispositivo.';

  @override
  String get trashDeleteAll => 'Delete all';

  @override
  String get trashDeleteAllConfirmTitle => 'Delete all items in Trash?';

  @override
  String get trashDeleteAllConfirmBody =>
      'This permanently removes all trashed notebooks and folders from this device.';

  @override
  String get splitPageTitle => 'Dividir página?';

  @override
  String splitPageBody(int count) {
    return 'Crie uma nova página com o mesmo modelo e mova cerca de metade dos $count traços para ela.';
  }

  @override
  String get splitPageNeedStrokes =>
      'São necessários pelo menos 2 traços para dividir esta página';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return 'Página dividida: $moved traços movidos, $remaining permanecem';
  }

  @override
  String splitPageFailed(String error) {
    return 'Falha ao dividir: $error';
  }

  @override
  String get splitPageAction => 'Dividir página';

  @override
  String get changePageSizeTitle => 'Alterar tamanho da página?';

  @override
  String get changePageSizeBody =>
      'Esta página tem tinta. Alterar o tamanho vai reorganizar a página; a sua tinta mantém-se na mesma posição na página.';

  @override
  String get changeOrientationTitle => 'Alterar orientação?';

  @override
  String get changeOrientationBody =>
      'Esta página tem tinta. Alterar a orientação dimensiona e centra o conteúdo para caber nos novos limites da página.';

  @override
  String convertedToText(String preview) {
    return 'Convertido em texto: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting =>
      'Não foi possível reconhecer a escrita manual';

  @override
  String get handwritingModelTitle => 'Modelo de escrita manual';

  @override
  String get handwritingModelDownloadFailed =>
      'Falha na transferência. Verifique a rede e tente novamente.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return 'A transferir o modelo de escrita manual em inglês (~$sizeMb MB)…';
  }

  @override
  String get handwritingModelReady => 'Modelo pronto.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return 'Decorrido: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return 'Transferência inicial (~$sizeMb MB). Normalmente conclui em menos de dois minutos com Wi‑Fi.';
  }

  @override
  String get pageExportedAsPng => 'Página exportada em PNG';

  @override
  String get pageExportedAsPdf => 'Página exportada em PDF';

  @override
  String get notebookExportedAsPdfSnack => 'Caderno exportado em PDF';

  @override
  String get exportPreparing => 'A preparar a exportação…';

  @override
  String exportProgress(int current, int total) {
    return 'A exportar página $current de $total…';
  }

  @override
  String pageComplexityWarning(int count) {
    return 'Esta página tem $count traços e pode ficar lenta. Considere dividi-la para melhor desempenho.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return 'Exportação bloqueada: uma página tem $count traços (limite $limit). Divida primeiro as páginas pesadas.';
  }

  @override
  String get restoreComplete =>
      'Restauro concluído. Reinicie a aplicação para carregar os dados restaurados.';

  @override
  String get textToolHint => 'Escreva aqui…';

  @override
  String get textToolDone => 'Concluído';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languagePolish => 'Polaco';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageUkrainian => 'Ucraniano';

  @override
  String get languageSwedish => 'Sueco';

  @override
  String get languageNorwegian => 'Norueguês';

  @override
  String get languageFinnish => 'Finlandês';

  @override
  String get languageDanish => 'Dinamarquês';

  @override
  String get languagePortuguese => 'Português';
}
