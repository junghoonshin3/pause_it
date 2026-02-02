// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PAUSE IT';

  @override
  String get appSubtitle => 'TIMESTAMP ARCHIVE';

  @override
  String get commonButtonAdd => 'Add';

  @override
  String get commonButtonSave => 'Save';

  @override
  String get commonButtonCancel => 'Cancel';

  @override
  String get commonButtonConfirm => 'Confirm';

  @override
  String get commonButtonDelete => 'Delete';

  @override
  String get commonButtonEdit => 'Edit';

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
  String get brutalistNoCategoriesDesc =>
      'Add categories to\nmanage your YouTube videos';

  @override
  String get brutalistNoVideos => 'NO VIDEOS';

  @override
  String get brutalistNoVideosDesc => 'Add videos to\nrecord timestamps';

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
  String get categoryAddTitle => 'Add Category';

  @override
  String get categoryEditTitle => 'Edit Category';

  @override
  String get categoryNameLabel => 'Category Name';

  @override
  String get categoryNameHint => 'e.g., Dev Tutorials, Music, Cooking';

  @override
  String get categoryColorLabel => 'Select Color';

  @override
  String get categoryCurrentBadge => 'Current';

  @override
  String get categoryErrorEmpty => 'Please enter a category name.';

  @override
  String get categoryErrorMinLength =>
      'Category name must be at least 2 characters.';

  @override
  String get categoryDeleteConfirmTitle => 'Delete Category';

  @override
  String categoryDeleteConfirmMessage(String name) {
    return 'Delete $name category?\nAll videos will also be deleted.';
  }

  @override
  String get categorySelectionTitle => 'Select Category';

  @override
  String get categorySelectionPrompt => 'Which category do you want to add to?';

  @override
  String categorySelectionAddSuccess(String name) {
    return 'Video added to $name';
  }

  @override
  String get categorySelectionAddFailed => 'Failed to add video';

  @override
  String get categorySelectionEmpty => 'No categories available';

  @override
  String get categorySelectionEmptyDesc => 'Please create a category first';

  @override
  String get categorySelectionLoadError => 'Unable to load categories';

  @override
  String get videoAddTitle => 'Add Video';

  @override
  String get videoEditTitle => 'Edit Video';

  @override
  String get videoAddPrompt => 'Enter YouTube video URL';

  @override
  String get videoUrlLabel => 'YouTube URL';

  @override
  String get videoUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get videoTimestampLabel => 'Timestamp (Optional)';

  @override
  String get videoTimestampHint => '1:23 or 1:23:45';

  @override
  String get videoTimestampHelperDefault =>
      'Enter where you stopped (Default: 0:00)';

  @override
  String videoTimestampHelperWithMax(String max) {
    return 'Enter where you stopped (Max: $max)';
  }

  @override
  String get videoTimestampHelperEdit => 'Enter where you stopped';

  @override
  String get videoMemoLabel => 'Memo (Optional)';

  @override
  String get videoMemoHint => 'Enter a memo for this video';

  @override
  String get videoMemoHelper => 'Write something to remember later';

  @override
  String get videoCategoryLabel => 'Category';

  @override
  String get videoCategoryMoveInfo => 'Video will move to new category on save';

  @override
  String get videoLoadingMetadata => 'Fetching video info...';

  @override
  String get videoDeleteConfirmTitle => 'Delete Video';

  @override
  String get videoDeleteConfirmMessage => 'Delete this video?';

  @override
  String get videoPlayButton => 'Play';

  @override
  String get videoPlayWithTime => 'Play from timestamp';

  @override
  String get errorUrlEmpty => 'Please enter a URL';

  @override
  String get errorUrlInvalid => 'Invalid YouTube URL';

  @override
  String get errorNetwork => 'Network error: Check your internet connection';

  @override
  String get errorVideoNotFound => 'Video not found (private/deleted)';

  @override
  String get errorVideoMetadataFailed => 'Failed to fetch video info';

  @override
  String get errorTimestampInvalidFormat =>
      'Enter valid timestamp format (e.g., 1:23 or 1:23:45)';

  @override
  String errorTimestampExceeds(String timestamp, String duration) {
    return 'Timestamp ($timestamp) cannot exceed video duration ($duration)';
  }

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get notificationVideoAdded => 'Video added';

  @override
  String get notificationVideoUpdated => 'Video updated';

  @override
  String get notificationVideoDeleted => 'Video deleted';

  @override
  String get notificationCategoryAdded => 'Category added';

  @override
  String get notificationCategoryUpdated => 'Category updated';

  @override
  String get notificationCategoryDeleted => 'Category deleted';

  @override
  String get notificationCannotDeleteLastCategory =>
      'Cannot delete last category';
}
