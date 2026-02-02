// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PAUSE IT';

  @override
  String get appSubtitle => 'TIMESTAMP ARCHIVE';

  @override
  String get commonButtonAdd => '追加';

  @override
  String get commonButtonSave => '保存';

  @override
  String get commonButtonCancel => 'キャンセル';

  @override
  String get commonButtonConfirm => '確認';

  @override
  String get commonButtonDelete => '削除';

  @override
  String get commonButtonEdit => '編集';

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
  String get brutalistNoCategoriesDesc => 'カテゴリを追加して\nYouTube動画を管理しましょう';

  @override
  String get brutalistNoVideos => 'NO VIDEOS';

  @override
  String get brutalistNoVideosDesc => '動画を追加して\nタイムスタンプを記録しましょう';

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
  String get categoryAddTitle => 'カテゴリを追加';

  @override
  String get categoryEditTitle => 'カテゴリを編集';

  @override
  String get categoryNameLabel => 'カテゴリ名';

  @override
  String get categoryNameHint => '例：開発講座、音楽、料理など';

  @override
  String get categoryColorLabel => '色を選択';

  @override
  String get categoryCurrentBadge => '現在';

  @override
  String get categoryErrorEmpty => 'カテゴリ名を入力してください。';

  @override
  String get categoryErrorMinLength => 'カテゴリ名は2文字以上である必要があります。';

  @override
  String get categoryDeleteConfirmTitle => 'カテゴリを削除';

  @override
  String categoryDeleteConfirmMessage(String name) {
    return '$nameカテゴリを削除しますか？\n含まれるすべての動画も削除されます。';
  }

  @override
  String get categorySelectionTitle => 'カテゴリを選択';

  @override
  String get categorySelectionPrompt => 'どのカテゴリに追加しますか？';

  @override
  String categorySelectionAddSuccess(String name) {
    return '$nameに動画が追加されました';
  }

  @override
  String get categorySelectionAddFailed => '動画の追加に失敗しました';

  @override
  String get categorySelectionEmpty => 'カテゴリがありません';

  @override
  String get categorySelectionEmptyDesc => 'まずカテゴリを作成してください';

  @override
  String get categorySelectionLoadError => 'カテゴリを読み込めません';

  @override
  String get videoAddTitle => '動画を追加';

  @override
  String get videoEditTitle => '動画を編集';

  @override
  String get videoAddPrompt => 'YouTube動画のURLを入力してください';

  @override
  String get videoUrlLabel => 'YouTube URL';

  @override
  String get videoUrlHint => 'https://www.youtube.com/watch?v=...';

  @override
  String get videoTimestampLabel => 'タイムスタンプ（任意）';

  @override
  String get videoTimestampHint => '1:23 または 1:23:45';

  @override
  String get videoTimestampHelperDefault => '中断した時点を入力してください（デフォルト：0:00）';

  @override
  String videoTimestampHelperWithMax(String max) {
    return '中断した時点を入力してください（最大：$max）';
  }

  @override
  String get videoTimestampHelperEdit => '中断した時点を入力してください';

  @override
  String get videoMemoLabel => 'メモ（任意）';

  @override
  String get videoMemoHint => 'この動画のメモを入力してください';

  @override
  String get videoMemoHelper => '後で思い出すことを書き留めましょう';

  @override
  String get videoCategoryLabel => 'カテゴリ';

  @override
  String get videoCategoryMoveInfo => '保存時に動画が新しいカテゴリに移動します';

  @override
  String get videoLoadingMetadata => '動画情報を取得中...';

  @override
  String get videoDeleteConfirmTitle => '動画を削除';

  @override
  String get videoDeleteConfirmMessage => 'この動画を削除しますか？';

  @override
  String get videoPlayButton => '再生';

  @override
  String get videoPlayWithTime => 'タイムスタンプから再生';

  @override
  String get errorUrlEmpty => 'URLを入力してください';

  @override
  String get errorUrlInvalid => '無効なYouTube URLです';

  @override
  String get errorNetwork => 'ネットワークエラー：インターネット接続を確認してください';

  @override
  String get errorVideoNotFound => '動画が見つかりません（非公開/削除済み）';

  @override
  String get errorVideoMetadataFailed => '動画情報を取得できません';

  @override
  String get errorTimestampInvalidFormat =>
      '正しいタイムスタンプ形式を入力してください（例：1:23 または 1:23:45）';

  @override
  String errorTimestampExceeds(String timestamp, String duration) {
    return 'タイムスタンプ（$timestamp）が動画の長さ（$duration）を超えることはできません';
  }

  @override
  String get errorGeneric => 'エラーが発生しました';

  @override
  String get notificationVideoAdded => '動画が追加されました';

  @override
  String get notificationVideoUpdated => '動画が更新されました';

  @override
  String get notificationVideoDeleted => '動画が削除されました';

  @override
  String get notificationCategoryAdded => 'カテゴリが追加されました';

  @override
  String get notificationCategoryUpdated => 'カテゴリが更新されました';

  @override
  String get notificationCategoryDeleted => 'カテゴリが削除されました';

  @override
  String get notificationCannotDeleteLastCategory => '最後のカテゴリは削除できません';
}
