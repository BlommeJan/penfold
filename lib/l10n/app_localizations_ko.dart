// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Penfold';

  @override
  String get actionCancel => '취소';

  @override
  String get actionCreate => '만들기';

  @override
  String get actionRename => '이름 변경';

  @override
  String get actionSave => '저장';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionAdd => '추가';

  @override
  String get actionBack => '뒤로';

  @override
  String get actionDone => '완료';

  @override
  String get actionSplit => '분할';

  @override
  String get actionRecover => '복구';

  @override
  String get actionRestore => '복원';

  @override
  String get actionExport => '내보내기';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionRetrying => '다시 시도 중…';

  @override
  String get actionExportFirst => '먼저 내보내기';

  @override
  String get actionEraseAll => '모두 지우기';

  @override
  String get actionChangeSize => '크기 변경';

  @override
  String get actionChangeOrientation => '방향 변경';

  @override
  String get actionUseColor => '색상 사용';

  @override
  String get libraryTitle => 'Penfold';

  @override
  String get libraryOverview => '개요';

  @override
  String get libraryTrash => '휴지통';

  @override
  String get librarySettings => '설정';

  @override
  String get libraryFolders => '폴더';

  @override
  String get libraryNoFoldersYet => '폴더가 없습니다';

  @override
  String get libraryAll => '전체';

  @override
  String get libraryUncategorized => '미분류';

  @override
  String get libraryBreadcrumb => '라이브러리';

  @override
  String get librarySearchHint => '노트 및 입력한 텍스트 검색…';

  @override
  String librarySearchMatchTag(String name) {
    return 'Tag: $name';
  }

  @override
  String librarySearchMatchFolder(String name) {
    return 'Folder: $name';
  }

  @override
  String get libraryNoMatches => '일치하는 항목이 없습니다';

  @override
  String get libraryFolderEmpty => '이 폴더가 비어 있습니다';

  @override
  String get libraryNoNotebooksWithTag => '이 태그가 지정된 노트가 없습니다';

  @override
  String get libraryNoUncategorizedNotebooks => '미분류 노트가 없습니다';

  @override
  String get libraryNoNotebooksYet => '노트가 없습니다';

  @override
  String get libraryNoNotebooksYetHint =>
      'Private by design — no login. Your notes stay on this device.';

  @override
  String libraryCouldNotLoad(String error) {
    return '라이브러리를 불러올 수 없습니다: $error';
  }

  @override
  String get tooltipBackupRestore => '백업 및 복원';

  @override
  String get tooltipTrash => '휴지통';

  @override
  String get tooltipNewNotebook => '새 노트';

  @override
  String get tooltipNewFolder => '새 폴더';

  @override
  String get tooltipNewSubfolder => '새 하위 폴더';

  @override
  String get tooltipImportPdf => 'PDF 가져오기';

  @override
  String get folderNew => '새 폴더';

  @override
  String get folderNewSubfolder => '새 하위 폴더';

  @override
  String get folderRename => '폴더 이름 변경';

  @override
  String get folderMoveToTrash => '휴지통으로 이동';

  @override
  String folderMoveToTrashTitle(String name) {
    return '\"$name\"을(를) 휴지통으로 이동하시겠습니까?';
  }

  @override
  String get folderMoveToTrashBody => '폴더와 포함된 노트는 30일 동안 휴지통에 보관됩니다.';

  @override
  String get notebookNew => '새 노트';

  @override
  String get notebookUntitled => '제목 없음';

  @override
  String get notebookTitleLabel => '제목';

  @override
  String get notebookSizeLabel => '크기';

  @override
  String get notebookPaperLabel => '용지';

  @override
  String get notebookCoverLabel => '표지';

  @override
  String get notebookRename => '노트 이름 변경';

  @override
  String get notebookMoveToFolder => '폴더로 이동';

  @override
  String get notebookEditTags => '태그 편집';

  @override
  String get notebookExportWorkbook => '노트 내보내기';

  @override
  String get notebookExportWorkbookSubtitle => '모든 페이지를 PDF로 공유';

  @override
  String get notebookMoveToTrash => '휴지통으로 이동';

  @override
  String notebookMoveToTrashTitle(String title) {
    return '\"$title\"을(를) 휴지통으로 이동하시겠습니까?';
  }

  @override
  String get notebookMoveToTrashBody =>
      '노트가 30일 동안 라이브러리에서 숨겨집니다. 잉크와 페이지는 휴지통을 비울 때까지 이 기기에 유지됩니다. 추가 사본이 필요하면 먼저 백업을 내보냅니다.';

  @override
  String notebookTagsFor(String title) {
    return '\"$title\" 태그';
  }

  @override
  String get notebookNoTagsYet => '태그가 없습니다. 아래에서 새 태그를 추가할 수 있습니다.';

  @override
  String get notebookNewTag => '새 태그';

  @override
  String get notebookAddTag => '태그 추가';

  @override
  String get notebookNoPagesToExport => '이 노트에는 내보낼 페이지가 없습니다';

  @override
  String notebookExportedAsPdf(String title) {
    return '\"$title\"을(를) PDF로 내보냈습니다';
  }

  @override
  String get notebookBackupExportedReady =>
      '백업을 내보냈습니다. 준비되면 휴지통으로 이동할 수 있습니다.';

  @override
  String get importPdfSnack => 'PDF 가져오는 중… 페이지는 한 번 렌더링된 후 오프라인으로 유지됩니다.';

  @override
  String importFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String exportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String backupFailed(String error) {
    return '백업 실패: $error';
  }

  @override
  String recoveryFailed(String error) {
    return '복구 실패: $error';
  }

  @override
  String restoreFailed(String error) {
    return '복원 실패: $error';
  }

  @override
  String handwritingModelDownloadingBackground(int sizeMb) {
    return '손글씨 모델(~$sizeMb MB)을(를) 백그라운드에서 다운로드하는 중…';
  }

  @override
  String get templateBlank => '빈 페이지';

  @override
  String get templateLined => '줄';

  @override
  String get templateGrid => '격자';

  @override
  String get templateDotted => '점';

  @override
  String get templateCollegeRuled => '대학용 줄';

  @override
  String get templateCollegeShort => '대학용';

  @override
  String get pageSizeA4 => 'A4';

  @override
  String get pageSizeA5 => 'A5';

  @override
  String get pageSizeLetter => 'Letter';

  @override
  String get orientationPortrait => '세로';

  @override
  String get orientationLandscape => '가로';

  @override
  String get pdfLabel => 'PDF';

  @override
  String get settingsSummarySeparator => ' · ';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionLanguage => '언어';

  @override
  String get settingsSectionAppearanceAndPreferences => '모양 및 기본 설정';

  @override
  String get settingsSectionAppearance => '모양';

  @override
  String get settingsAppearanceDarkMode => '다크 모드';

  @override
  String get settingsAppearanceDarkModeSubtitle =>
      '밝게, 어둡게 또는 기기 설정에 맞춤(기본: 시스템)';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeLight => '밝게';

  @override
  String get themeDark => '어둡게';

  @override
  String get settingsSectionPreferences => '기본 설정';

  @override
  String get settingsLanguageLabel => '앱 언어';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageGerman => '독일어';

  @override
  String get languageFrench => '프랑스어';

  @override
  String get languageDutch => '네덜란드어';

  @override
  String get settingsSectionToolbar => '도구 모음';

  @override
  String get settingsToolbarReorderHint =>
      '드래그하여 그리기 도구 순서를 변경합니다. 실행 취소와 다시 실행은 오른쪽에 고정됩니다.';

  @override
  String get settingsResetToolbarOrder => '도구 모음 순서 초기화';

  @override
  String get settingsSectionNotebook => '노트';

  @override
  String get settingsPageTurnMode => '페이지 넘김 모드';

  @override
  String get settingsPageTurnModeSubtitle => '연속 스크롤 대신 한 페이지씩 스와이프(기본: 끔)';

  @override
  String get settingsZoomNavigation => '확대/축소 탐색';

  @override
  String get settingsZoomNavigationSubtitle => '페이지에서 핀치하여 확대/축소 및 이동(기본: 켬)';

  @override
  String get settingsSectionDrawing => '그리기';

  @override
  String get settingsStrokeSmoothing => '획 스무딩';

  @override
  String get settingsStrokeSmoothingSubtitle =>
      'Chaikin 코너 커팅으로 잉크 획을 부드럽게 처리(기본: 켬)';

  @override
  String get settingsStrokeSmoothingStrength => '스무딩 강도';

  @override
  String settingsStrokeSmoothingStrengthSubtitle(int percent, int recommended) {
    return '$percent% — 낮을수록 세부 디테일 유지; 권장 $recommended%';
  }

  @override
  String get settingsFingerDrawing => '손가락 그리기';

  @override
  String get settingsFingerDrawingSubtitle =>
      '손가락으로 종이에 그립니다. 끄면 스타일러스로만 그릴 수 있습니다(기본: 끔)';

  @override
  String get settingsGestureInkEditing => '제스처 잉크 편집';

  @override
  String get settingsGestureInkEditingSubtitle =>
      'OCR로 색인된 잉크 위를 긁어 지웁니다(기본: 켬)';

  @override
  String get settingsSectionSpen => 'S Pen';

  @override
  String get settingsSpenHint =>
      'S Pen 버튼을 길게 누르면 도구가 일시적으로 전환됩니다. 버튼에서 손을 떼면 이전 도구로 돌아갑니다. S Pen 버튼을 지원하는 Samsung 기기에서 사용할 수 있습니다.';

  @override
  String get settingsSpenBarrelAction => 'S Pen 버튼 동작';

  @override
  String get settingsSectionOcrDictionary => 'OCR 용어 사전';

  @override
  String get settingsOcrDictionaryHint =>
      '손글씨 OCR에 사용할 전문 용어입니다. 유사한 단어는 잉크 색인 시 교정되며, 용어는 노트 검색에도 반영됩니다.';

  @override
  String get settingsNoCustomOcrTerms => '사용자 지정 용어가 없습니다.';

  @override
  String get settingsRemoveOcrTerm => '용어 제거';

  @override
  String get settingsAddOcrTerm => '용어 추가';

  @override
  String get settingsAddOcrTermTitle => 'OCR 용어 추가';

  @override
  String get settingsOcrTermLabel => '용어';

  @override
  String get settingsOcrTermHint => '예: eigenvalue, mitochondria';

  @override
  String get settingsSectionYourData => '내 데이터';

  @override
  String get settingsYourDataHint =>
      'Penfold는 모든 데이터를 단일 SQLite 데이터베이스와 에셋 폴더에 이 기기에 저장합니다 — 클라우드 동기화 없음. 전체 온디바이스 파일 구조는 docs/ARCHITECTURE.md를 참조합니다.';

  @override
  String get settingsDatabase => '데이터베이스';

  @override
  String get settingsSectionBackupRestore => '백업 및 복원';

  @override
  String get settingsBackupRestoreHint =>
      'penfold.db와 에셋 폴더를 zip으로 내보내거나 이전 백업에서 복원합니다. 복원 전 현재 데이터베이스는 backups/에 저장됩니다.';

  @override
  String get settingsExportBackup => '백업 내보내기';

  @override
  String get settingsExportBackupSubtitle =>
      'penfold.db, PDF 원본, 이미지 및 레거시 PDF 페이지를 zip으로 내보내기';

  @override
  String get settingsRecoverFromBackup => '백업에서 복구';

  @override
  String settingsLatestAutoBackup(String timestamp, String size) {
    return '최신 자동 백업: $timestamp ($size)';
  }

  @override
  String get settingsRestoreBackup => '백업 복원';

  @override
  String get settingsRestoreBackupSubtitle => 'Penfold 백업 zip에서 로컬 데이터 교체';

  @override
  String get settingsRecoverAutoBackupTitle => '자동 백업에서 복구하시겠습니까?';

  @override
  String settingsRecoverAutoBackupBody(String timestamp) {
    return '현재 노트와 파일이 $timestamp 백업으로 교체됩니다. 복원 전 현재 데이터베이스는 backups/에 저장됩니다.';
  }

  @override
  String get settingsRestoreBackupTitle => '백업을 복원하시겠습니까?';

  @override
  String get settingsRestoreBackupBody =>
      '현재 노트와 파일이 교체됩니다. 복원 전 현재 데이터베이스는 backups/에 저장됩니다.';

  @override
  String get settingsSectionAbout => '정보';

  @override
  String get settingsAboutSubtitle => '로컬 우선 필기 노트 — 계정 없음, 클라우드 없음.';

  @override
  String settingsVersion(String version) {
    return '버전 $version';
  }

  @override
  String get spenActionEraser => '지우개';

  @override
  String get spenActionLasso => '올가미';

  @override
  String get spenActionPen => '펜';

  @override
  String get spenActionNone => '없음';

  @override
  String get toolPen => '펜';

  @override
  String get toolHighlighter => '형광펜';

  @override
  String get toolTape => '테이프';

  @override
  String get toolEraser => '지우개';

  @override
  String get toolSelection => '선택';

  @override
  String get toolLasso => '올가미';

  @override
  String get toolShape => '도형';

  @override
  String get toolFill => '채우기';

  @override
  String get toolText => '텍스트';

  @override
  String get toolInsertImage => '이미지 삽입';

  @override
  String get brushPen => '펜';

  @override
  String get brushFountain => '만년필';

  @override
  String get brushPencil => '연필';

  @override
  String get brushMarker => '마커';

  @override
  String get brushCalligraphy => '캘리그래피';

  @override
  String get toolbarPreviousBookmark => '이전 책갈피';

  @override
  String get toolbarNextBookmark => '다음 책갈피';

  @override
  String get toolbarConvertToText => '텍스트로 변환';

  @override
  String get toolbarCopy => '복사';

  @override
  String get toolbarDelete => '삭제';

  @override
  String get toolbarPaste => '붙여넣기';

  @override
  String get toolbarUndo => '실행 취소';

  @override
  String get toolbarRedo => '다시 실행';

  @override
  String get toolbarAddPage => '페이지 추가';

  @override
  String get toolbarStylusOnly => '스타일러스 전용(손바닥 거부)';

  @override
  String get toolbarFingerDrawing => '손가락 그리기';

  @override
  String get toolbarPageOverview => '페이지 개요';

  @override
  String get toolbarTableOfContents => '목차';

  @override
  String get toolbarPageMenu => '페이지 메뉴';

  @override
  String get penOptionsTitle => '펜';

  @override
  String get highlighterOptionsTitle => '형광펜';

  @override
  String get brushLabel => '브러시';

  @override
  String get colorLabel => '색상';

  @override
  String get customColorTitle => '사용자 지정 색상';

  @override
  String get hueLabel => '색조';

  @override
  String get saturationLabel => '채도';

  @override
  String get brightnessLabel => '밝기';

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
  String get tapeOptionsTitle => '테이프';

  @override
  String get tapeOptionsHint => '그려서 메모를 가리고, 테이프를 탭하여 다시 표시하거나 숨깁니다';

  @override
  String get fillColorTitle => '채우기 색상';

  @override
  String get fillOptionsHint => '닫힌 루프를 그리거나 도형 안쪽을 탭하여 채웁니다';

  @override
  String get eraserSizeTitle => '지우개 크기';

  @override
  String get eraserModeTitle => '지우개 모드';

  @override
  String get eraserModePixel => '픽셀';

  @override
  String get eraserModeStroke => '획';

  @override
  String get eraserModePartialHint => '지우개 원 아래의 잉크만 지웁니다';

  @override
  String get eraserModeWholeStrokeHint => '닿은 획 전체를 지웁니다';

  @override
  String get eraseAllOnPageTitle => '페이지의 모든 내용을 지우시겠습니까?';

  @override
  String get eraseAllOnPageBody => '현재 페이지의 모든 획이 제거됩니다. 실행 취소할 수 있습니다.';

  @override
  String get eraseAllOnPageButton => '페이지 모두 지우기';

  @override
  String get pageSettingsTitle => '페이지 설정';

  @override
  String get pageColorTitle => '페이지 색상';

  @override
  String get pageThemeTitle => '페이지 테마';

  @override
  String get defaultPaperSize => '기본 용지 크기';

  @override
  String get defaultPaperType => '기본 용지 유형';

  @override
  String get defaultPageTheme => '기본 페이지 테마';

  @override
  String get notebookDefaultsHint => '새 노트를 만들 때 사용됩니다. 대화상자에서 언제든 변경할 수 있습니다.';

  @override
  String get pageThemeLight => '밝게';

  @override
  String get pageThemeDark => '어둡게';

  @override
  String get pageThemeSepia => '세피아';

  @override
  String get pageThemePastelPink => '파스텔 핑크';

  @override
  String get pageThemePastelBlue => '파스텔 블루';

  @override
  String get pageThemePastelMint => '파스텔 민트';

  @override
  String get pageSizeTitle => '페이지 크기';

  @override
  String get pageOrientationTitle => '방향';

  @override
  String get pageTemplateTitle => '페이지 템플릿';

  @override
  String get pageBookmark => '책갈피';

  @override
  String get pageRemoveBookmark => '책갈피 제거';

  @override
  String get pageAudioTitle => '오디오';

  @override
  String get pageSplit => '분할';

  @override
  String get pageExportTitle => '내보내기';

  @override
  String get pdfPagesKeepBackground => 'PDF 페이지는 문서 배경을 유지합니다';

  @override
  String get pdfPagesKeepDimensions => 'PDF 페이지는 문서 크기를 유지합니다';

  @override
  String get pdfPagesKeepOrientation => 'PDF 페이지는 문서 방향을 유지합니다';

  @override
  String get exportPageAsPng => '페이지를 PNG로 내보내기';

  @override
  String get exportPageAsPngSubtitle => '이 페이지의 이미지 공유';

  @override
  String get exportPageAsPdf => '페이지를 PDF로 내보내기';

  @override
  String get exportPageAsPdfSubtitle => '벡터 잉크, 시스템 공유 시트로 공유';

  @override
  String get exportNotebookAsPdf => '노트를 PDF로 내보내기';

  @override
  String exportNotebookPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count페이지',
      one: '1페이지',
    );
    return '$_temp0';
  }

  @override
  String get pageAudioAttach => '오디오 파일 첨부';

  @override
  String get pageAudioAttachSubtitle => 'MP3, M4A, WAV 및 기타 로컬 형식';

  @override
  String get pageAudioAttachedToPage => '이 페이지에 첨부됨';

  @override
  String get pageAudioReplace => '오디오 파일 교체';

  @override
  String get pageAudioRemove => '오디오 제거';

  @override
  String get pageAudioPlay => '재생';

  @override
  String get pageAudioPause => '일시 정지';

  @override
  String get contentsTitle => '목차';

  @override
  String get contentsSubtitle => '입력한 텍스트 및 OCR로 색인된 잉크의 제목';

  @override
  String get contentsEmpty =>
      '제목을 찾을 수 없습니다.\n큰 또는 짧은 입력한 텍스트, 또는 OCR로 색인된 잉크 제목을 추가합니다.';

  @override
  String contentsPageNumber(int number) {
    return '$number페이지';
  }

  @override
  String get pageOverviewPagesSuffix => ' — 페이지';

  @override
  String pageOverviewSelected(int count) {
    return '$count개 선택됨';
  }

  @override
  String get pageOverviewDeleteSelected => '선택 항목 삭제';

  @override
  String get pageOverviewSelectPages => '페이지 선택';

  @override
  String get pageOverviewKeepOnePage => '페이지를 하나 이상 유지해야 합니다';

  @override
  String pageOverviewDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count페이지',
      one: '1페이지',
    );
    return '$_temp0를 삭제하시겠습니까?';
  }

  @override
  String get pageOverviewDeleteBody => '이 작업은 실행 취소할 수 없습니다.';

  @override
  String get pageOverviewDragToReorder => '드래그하여 순서 변경';

  @override
  String get pageOverviewBookmarked => '책갈피됨';

  @override
  String get ocrIndexing => 'OCR 색인 생성 중…';

  @override
  String get ocrHandwritingSearchable => '손글씨 검색 가능';

  @override
  String get ocrPartial => 'OCR 일부 완료';

  @override
  String get trashTitle => '휴지통';

  @override
  String trashFailedToLoad(String error) {
    return '휴지통을 불러올 수 없습니다: $error';
  }

  @override
  String get trashEmpty => '휴지통이 비어 있습니다';

  @override
  String get trashSectionFolders => '폴더';

  @override
  String get trashSectionNotebooks => '노트';

  @override
  String get trashDeletionDateUnavailable => '삭제 날짜를 확인할 수 없습니다';

  @override
  String get trashExpiresToday => '오늘 만료';

  @override
  String trashDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 남음',
      one: '1일 남음',
    );
    return '$_temp0';
  }

  @override
  String get trashRestore => '복원';

  @override
  String trashDeleteNotebookTitle(String title) {
    return '\"$title\"을(를) 영구 삭제하시겠습니까?';
  }

  @override
  String get trashDeleteNotebookBody => '노트와 모든 페이지가 이 기기에서 제거됩니다.';

  @override
  String trashDeleteFolderTitle(String name) {
    return '\"$name\"을(를) 영구 삭제하시겠습니까?';
  }

  @override
  String get trashDeleteFolderBody => '폴더와 포함된 노트가 이 기기에서 제거됩니다.';

  @override
  String get splitPageTitle => '페이지를 분할하시겠습니까?';

  @override
  String splitPageBody(int count) {
    return '동일한 템플릿으로 새 페이지를 만들고 $count개 획 중 약 절반을 이동합니다.';
  }

  @override
  String get splitPageNeedStrokes => '이 페이지를 분할하려면 획이 2개 이상 필요합니다';

  @override
  String splitPageSuccess(int moved, int remaining) {
    return '페이지 분할 완료: $moved개 획 이동, $remaining개 남음';
  }

  @override
  String splitPageFailed(String error) {
    return '분할 실패: $error';
  }

  @override
  String get splitPageAction => '페이지 분할';

  @override
  String get changePageSizeTitle => '페이지 크기를 변경하시겠습니까?';

  @override
  String get changePageSizeBody =>
      '이 페이지에 잉크가 있습니다. 크기를 변경하면 페이지 레이아웃이 다시 조정되며, 잉크는 페이지에서 같은 위치에 유지됩니다.';

  @override
  String get changeOrientationTitle => '방향을 변경하시겠습니까?';

  @override
  String get changeOrientationBody =>
      '이 페이지에 잉크가 있습니다. 방향을 변경하면 새 페이지 범위에 맞게 내용이 확대/축소되고 중앙에 배치됩니다.';

  @override
  String convertedToText(String preview) {
    return '텍스트로 변환됨: $preview';
  }

  @override
  String get couldNotRecognizeHandwriting => '손글씨를 인식할 수 없습니다';

  @override
  String get handwritingModelTitle => '손글씨 모델';

  @override
  String get handwritingModelDownloadFailed =>
      '다운로드에 실패했습니다. 네트워크를 확인한 후 다시 시도할 수 있습니다.';

  @override
  String handwritingModelDownloading(int sizeMb) {
    return '영어 손글씨 모델(~$sizeMb MB) 다운로드 중…';
  }

  @override
  String get handwritingModelReady => '모델 준비 완료.';

  @override
  String handwritingModelElapsed(String elapsed) {
    return '경과: $elapsed';
  }

  @override
  String handwritingModelDownloadHint(int sizeMb) {
    return '최초 다운로드(~$sizeMb MB). Wi‑Fi에서는 보통 2분 이내에 완료됩니다.';
  }

  @override
  String get pageExportedAsPng => '페이지를 PNG로 내보냈습니다';

  @override
  String get pageExportedAsPdf => '페이지를 PDF로 내보냈습니다';

  @override
  String get notebookExportedAsPdfSnack => '노트를 PDF로 내보냈습니다';

  @override
  String get exportPreparing => '내보내기 준비 중…';

  @override
  String exportProgress(int current, int total) {
    return '$total페이지 중 $current페이지 내보내는 중…';
  }

  @override
  String pageComplexityWarning(int count) {
    return '이 페이지에 획이 $count개 있어 느려질 수 있습니다. 성능 향상을 위해 분할을 권장합니다.';
  }

  @override
  String pageComplexityExportBlocked(int count, int limit) {
    return '내보내기 차단: 페이지에 획이 $count개 있습니다(한도 $limit). 먼저 무거운 페이지를 분할해야 합니다.';
  }

  @override
  String get restoreComplete => '복원이 완료되었습니다. 복원된 데이터를 불러오려면 앱을 다시 시작해야 합니다.';

  @override
  String get textToolHint => '여기에 입력…';

  @override
  String get textToolDone => '완료';

  @override
  String get languageKorean => '한국어';

  @override
  String get languagePolish => '폴란드어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languageItalian => '이탈리아어';

  @override
  String get languageUkrainian => '우크라이나어';

  @override
  String get languageSwedish => '스웨덴어';

  @override
  String get languageNorwegian => '노르웨이어';

  @override
  String get languageFinnish => '핀란드어';

  @override
  String get languageDanish => '덴마크어';

  @override
  String get languagePortuguese => '포르투갈어';
}
