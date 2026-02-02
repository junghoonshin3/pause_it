// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'PAUSE IT';

  @override
  String get appSubtitle => 'TIMESTAMP ARCHIVE';

  @override
  String get commonButtonAdd => '추가';

  @override
  String get commonButtonSave => '저장';

  @override
  String get commonButtonCancel => '취소';

  @override
  String get commonButtonConfirm => '확인';

  @override
  String get commonButtonDelete => '삭제';

  @override
  String get commonButtonEdit => '편집';

  @override
  String get commonLoading => 'LOADING...';

  @override
  String get commonError => 'ERROR';

  @override
  String get brutalistAdd => 'ADD';

  @override
  String get brutalistCategories => 'CATEGORIES';

  @override
  String get brutalistVideos => 'VIDEOS';

  @override
  String get brutalistNoCategories => 'NO CATEGORIES';

  @override
  String get brutalistNoCategoriesDesc => '카테고리를 추가하여\n유튜브 영상을 관리하세요';

  @override
  String get brutalistNoVideos => 'NO VIDEOS';

  @override
  String get brutalistNoVideosDesc => '영상을 추가하여\n타임스탬프를 기록하세요';

  @override
  String get brutalistCategoryAdded => 'CATEGORY ADDED';

  @override
  String get brutalistCategoryUpdated => 'CATEGORY UPDATED';

  @override
  String get brutalistCategoryDeleted => 'CATEGORY DELETED';

  @override
  String get brutalistFailedToAdd => 'FAILED TO ADD';

  @override
  String get brutalistFailedToUpdate => 'FAILED TO UPDATE';

  @override
  String get brutalistFailedToDelete => 'FAILED TO DELETE';

  @override
  String get brutalistCannotDeleteLast => 'CANNOT DELETE LAST CATEGORY';

  @override
  String get brutalistVideoAdded => 'VIDEO ADDED';

  @override
  String get brutalistVideoUpdated => 'VIDEO UPDATED';

  @override
  String get brutalistVideoDeleted => 'VIDEO DELETED';

  @override
  String get brutalistVideoMoved => 'VIDEO MOVED';

  @override
  String get brutalistConfirmDelete => 'CONFIRM DELETE';

  @override
  String get categoryAddTitle => '카테고리 추가';

  @override
  String get categoryEditTitle => '카테고리 편집';

  @override
  String get categoryNameLabel => '카테고리 이름';

  @override
  String get categoryNameHint => '예: 개발 강의, 음악, 요리 등';

  @override
  String get categoryColorLabel => '색상 선택';

  @override
  String get categoryCurrentBadge => '현재';

  @override
  String get categoryErrorEmpty => '카테고리 이름을 입력해주세요.';

  @override
  String get categoryErrorMinLength => '카테고리 이름은 최소 2자 이상이어야 합니다.';

  @override
  String get categoryDeleteConfirmTitle => '카테고리 삭제';

  @override
  String categoryDeleteConfirmMessage(String name) {
    return '$name 카테고리를 삭제하시겠습니까?\n포함된 모든 영상도 함께 삭제됩니다.';
  }

  @override
  String get categorySelectionTitle => '카테고리 선택';

  @override
  String get categorySelectionPrompt => '어느 카테고리에 추가할까요?';

  @override
  String categorySelectionAddSuccess(String name) {
    return '$name에 영상이 추가되었습니다';
  }

  @override
  String get categorySelectionAddFailed => '영상 추가에 실패했습니다';

  @override
  String get categorySelectionEmpty => '카테고리가 없습니다';

  @override
  String get categorySelectionEmptyDesc => '먼저 카테고리를 생성해주세요';

  @override
  String get categorySelectionLoadError => '카테고리를 불러올 수 없습니다';

  @override
  String get videoAddTitle => '영상 추가';

  @override
  String get videoEditTitle => '영상 편집';

  @override
  String get videoAddPrompt => 'YouTube 영상 URL을 입력하세요';

  @override
  String get videoUrlLabel => 'YouTube URL';

  @override
  String get videoUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get videoTimestampLabel => '타임스탬프 (선택)';

  @override
  String get videoTimestampHint => '1:23 또는 1:23:45';

  @override
  String get videoTimestampHelperDefault => '중단한 시점을 입력하세요 (기본값: 0:00)';

  @override
  String videoTimestampHelperWithMax(String max) {
    return '중단한 시점을 입력하세요 (최대: $max)';
  }

  @override
  String get videoTimestampHelperEdit => '중단한 시점을 입력하세요';

  @override
  String get videoMemoLabel => '메모 (선택)';

  @override
  String get videoMemoHint => '이 영상에 대한 메모를 입력하세요';

  @override
  String get videoMemoHelper => '나중에 기억할 내용을 적어두세요';

  @override
  String get videoCategoryLabel => '카테고리';

  @override
  String get videoCategoryMoveInfo => '저장 시 영상이 새 카테고리로 이동됩니다';

  @override
  String get videoLoadingMetadata => '영상 정보를 가져오는 중...';

  @override
  String get videoDeleteConfirmTitle => '영상 삭제';

  @override
  String get videoDeleteConfirmMessage => '이 영상을 삭제하시겠습니까?';

  @override
  String get videoPlayButton => '재생';

  @override
  String get videoPlayWithTime => '타임스탬프에서 재생';

  @override
  String get errorUrlEmpty => 'URL을 입력해주세요';

  @override
  String get errorUrlInvalid => '유효하지 않은 YouTube URL입니다';

  @override
  String get errorNetwork => '네트워크 오류: 인터넷 연결을 확인해주세요';

  @override
  String get errorVideoNotFound => '영상을 찾을 수 없습니다 (비공개/삭제됨)';

  @override
  String get errorVideoMetadataFailed => '영상 정보를 가져올 수 없습니다';

  @override
  String get errorTimestampInvalidFormat =>
      '올바른 타임스탬프 형식을 입력하세요 (예: 1:23 또는 1:23:45)';

  @override
  String errorTimestampExceeds(String timestamp, String duration) {
    return '타임스탬프($timestamp)가 영상 길이($duration)를 초과할 수 없습니다';
  }

  @override
  String get errorGeneric => '오류가 발생했습니다';

  @override
  String get notificationVideoAdded => '영상이 추가되었습니다';

  @override
  String get notificationVideoUpdated => '영상이 수정되었습니다';

  @override
  String get notificationVideoDeleted => '영상이 삭제되었습니다';

  @override
  String get notificationCategoryAdded => '카테고리가 추가되었습니다';

  @override
  String get notificationCategoryUpdated => '카테고리가 수정되었습니다';

  @override
  String get notificationCategoryDeleted => '카테고리가 삭제되었습니다';

  @override
  String get notificationCannotDeleteLastCategory => '마지막 카테고리는 삭제할 수 없습니다';
}
