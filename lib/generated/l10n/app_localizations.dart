import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'PAUSE IT'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'TIMESTAMP ARCHIVE'**
  String get appSubtitle;

  /// No description provided for @commonButtonAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get commonButtonAdd;

  /// No description provided for @commonButtonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonButtonSave;

  /// No description provided for @commonButtonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonButtonCancel;

  /// No description provided for @commonButtonConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get commonButtonConfirm;

  /// No description provided for @commonButtonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonButtonDelete;

  /// No description provided for @commonButtonEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get commonButtonEdit;

  /// No description provided for @commonLoading.
  ///
  /// In ko, this message translates to:
  /// **'LOADING...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In ko, this message translates to:
  /// **'ERROR'**
  String get commonError;

  /// No description provided for @brutalistAdd.
  ///
  /// In ko, this message translates to:
  /// **'ADD'**
  String get brutalistAdd;

  /// No description provided for @brutalistCategories.
  ///
  /// In ko, this message translates to:
  /// **'CATEGORIES'**
  String get brutalistCategories;

  /// No description provided for @brutalistVideos.
  ///
  /// In ko, this message translates to:
  /// **'VIDEOS'**
  String get brutalistVideos;

  /// No description provided for @brutalistNoCategories.
  ///
  /// In ko, this message translates to:
  /// **'NO CATEGORIES'**
  String get brutalistNoCategories;

  /// No description provided for @brutalistNoCategoriesDesc.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 추가하여\n유튜브 영상을 관리하세요'**
  String get brutalistNoCategoriesDesc;

  /// No description provided for @brutalistNoVideos.
  ///
  /// In ko, this message translates to:
  /// **'NO VIDEOS'**
  String get brutalistNoVideos;

  /// No description provided for @brutalistNoVideosDesc.
  ///
  /// In ko, this message translates to:
  /// **'영상을 추가하여\n타임스탬프를 기록하세요'**
  String get brutalistNoVideosDesc;

  /// No description provided for @brutalistCategoryAdded.
  ///
  /// In ko, this message translates to:
  /// **'CATEGORY ADDED'**
  String get brutalistCategoryAdded;

  /// No description provided for @brutalistCategoryUpdated.
  ///
  /// In ko, this message translates to:
  /// **'CATEGORY UPDATED'**
  String get brutalistCategoryUpdated;

  /// No description provided for @brutalistCategoryDeleted.
  ///
  /// In ko, this message translates to:
  /// **'CATEGORY DELETED'**
  String get brutalistCategoryDeleted;

  /// No description provided for @brutalistFailedToAdd.
  ///
  /// In ko, this message translates to:
  /// **'FAILED TO ADD'**
  String get brutalistFailedToAdd;

  /// No description provided for @brutalistFailedToUpdate.
  ///
  /// In ko, this message translates to:
  /// **'FAILED TO UPDATE'**
  String get brutalistFailedToUpdate;

  /// No description provided for @brutalistFailedToDelete.
  ///
  /// In ko, this message translates to:
  /// **'FAILED TO DELETE'**
  String get brutalistFailedToDelete;

  /// No description provided for @brutalistCannotDeleteLast.
  ///
  /// In ko, this message translates to:
  /// **'CANNOT DELETE LAST CATEGORY'**
  String get brutalistCannotDeleteLast;

  /// No description provided for @brutalistVideoAdded.
  ///
  /// In ko, this message translates to:
  /// **'VIDEO ADDED'**
  String get brutalistVideoAdded;

  /// No description provided for @brutalistVideoUpdated.
  ///
  /// In ko, this message translates to:
  /// **'VIDEO UPDATED'**
  String get brutalistVideoUpdated;

  /// No description provided for @brutalistVideoDeleted.
  ///
  /// In ko, this message translates to:
  /// **'VIDEO DELETED'**
  String get brutalistVideoDeleted;

  /// No description provided for @brutalistVideoMoved.
  ///
  /// In ko, this message translates to:
  /// **'VIDEO MOVED'**
  String get brutalistVideoMoved;

  /// No description provided for @brutalistConfirmDelete.
  ///
  /// In ko, this message translates to:
  /// **'CONFIRM DELETE'**
  String get brutalistConfirmDelete;

  /// No description provided for @categoryAddTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 추가'**
  String get categoryAddTitle;

  /// No description provided for @categoryEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 편집'**
  String get categoryEditTitle;

  /// No description provided for @categoryNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 이름'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 개발 강의, 음악, 요리 등'**
  String get categoryNameHint;

  /// No description provided for @categoryColorLabel.
  ///
  /// In ko, this message translates to:
  /// **'색상 선택'**
  String get categoryColorLabel;

  /// No description provided for @categoryCurrentBadge.
  ///
  /// In ko, this message translates to:
  /// **'현재'**
  String get categoryCurrentBadge;

  /// No description provided for @categoryErrorEmpty.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 이름을 입력해주세요.'**
  String get categoryErrorEmpty;

  /// No description provided for @categoryErrorMinLength.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 이름은 최소 2자 이상이어야 합니다.'**
  String get categoryErrorMinLength;

  /// No description provided for @categoryDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 삭제'**
  String get categoryDeleteConfirmTitle;

  /// No description provided for @categoryDeleteConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name} 카테고리를 삭제하시겠습니까?\n포함된 모든 영상도 함께 삭제됩니다.'**
  String categoryDeleteConfirmMessage(String name);

  /// No description provided for @categorySelectionTitle.
  ///
  /// In ko, this message translates to:
  /// **'카테고리 선택'**
  String get categorySelectionTitle;

  /// No description provided for @categorySelectionPrompt.
  ///
  /// In ko, this message translates to:
  /// **'어느 카테고리에 추가할까요?'**
  String get categorySelectionPrompt;

  /// No description provided for @categorySelectionAddSuccess.
  ///
  /// In ko, this message translates to:
  /// **'{name}에 영상이 추가되었습니다'**
  String categorySelectionAddSuccess(String name);

  /// No description provided for @categorySelectionAddFailed.
  ///
  /// In ko, this message translates to:
  /// **'영상 추가에 실패했습니다'**
  String get categorySelectionAddFailed;

  /// No description provided for @categorySelectionEmpty.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 없습니다'**
  String get categorySelectionEmpty;

  /// No description provided for @categorySelectionEmptyDesc.
  ///
  /// In ko, this message translates to:
  /// **'먼저 카테고리를 생성해주세요'**
  String get categorySelectionEmptyDesc;

  /// No description provided for @categorySelectionLoadError.
  ///
  /// In ko, this message translates to:
  /// **'카테고리를 불러올 수 없습니다'**
  String get categorySelectionLoadError;

  /// No description provided for @videoAddTitle.
  ///
  /// In ko, this message translates to:
  /// **'영상 추가'**
  String get videoAddTitle;

  /// No description provided for @videoEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'영상 편집'**
  String get videoEditTitle;

  /// No description provided for @videoAddPrompt.
  ///
  /// In ko, this message translates to:
  /// **'YouTube 영상 URL을 입력하세요'**
  String get videoAddPrompt;

  /// No description provided for @videoUrlLabel.
  ///
  /// In ko, this message translates to:
  /// **'YouTube URL'**
  String get videoUrlLabel;

  /// No description provided for @videoUrlHint.
  ///
  /// In ko, this message translates to:
  /// **'https://www.youtube.com/watch?v=...'**
  String get videoUrlHint;

  /// No description provided for @videoTimestampLabel.
  ///
  /// In ko, this message translates to:
  /// **'타임스탬프 (선택)'**
  String get videoTimestampLabel;

  /// No description provided for @videoTimestampHint.
  ///
  /// In ko, this message translates to:
  /// **'1:23, 1:23:45, 1m23s, t=70s'**
  String get videoTimestampHint;

  /// No description provided for @videoTimestampHelperDefault.
  ///
  /// In ko, this message translates to:
  /// **'중단한 시점을 입력하세요 (기본값: 0:00, 예: 1m30s)'**
  String get videoTimestampHelperDefault;

  /// No description provided for @videoTimestampHelperWithMax.
  ///
  /// In ko, this message translates to:
  /// **'중단한 시점을 입력하세요 (최대: {max})'**
  String videoTimestampHelperWithMax(String max);

  /// No description provided for @videoTimestampHelperEdit.
  ///
  /// In ko, this message translates to:
  /// **'중단한 시점을 입력하세요'**
  String get videoTimestampHelperEdit;

  /// No description provided for @videoMemoLabel.
  ///
  /// In ko, this message translates to:
  /// **'메모 (선택)'**
  String get videoMemoLabel;

  /// No description provided for @videoMemoHint.
  ///
  /// In ko, this message translates to:
  /// **'이 영상에 대한 메모를 입력하세요'**
  String get videoMemoHint;

  /// No description provided for @videoMemoHelper.
  ///
  /// In ko, this message translates to:
  /// **'나중에 기억할 내용을 적어두세요'**
  String get videoMemoHelper;

  /// No description provided for @videoCategoryLabel.
  ///
  /// In ko, this message translates to:
  /// **'카테고리'**
  String get videoCategoryLabel;

  /// No description provided for @videoCategoryMoveInfo.
  ///
  /// In ko, this message translates to:
  /// **'저장 시 영상이 새 카테고리로 이동됩니다'**
  String get videoCategoryMoveInfo;

  /// No description provided for @videoLoadingMetadata.
  ///
  /// In ko, this message translates to:
  /// **'영상 정보를 가져오는 중...'**
  String get videoLoadingMetadata;

  /// No description provided for @videoDeleteConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'영상 삭제'**
  String get videoDeleteConfirmTitle;

  /// No description provided for @videoDeleteConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 영상을 삭제하시겠습니까?'**
  String get videoDeleteConfirmMessage;

  /// No description provided for @videoPlayButton.
  ///
  /// In ko, this message translates to:
  /// **'재생'**
  String get videoPlayButton;

  /// No description provided for @videoPlayWithTime.
  ///
  /// In ko, this message translates to:
  /// **'타임스탬프에서 재생'**
  String get videoPlayWithTime;

  /// No description provided for @errorUrlEmpty.
  ///
  /// In ko, this message translates to:
  /// **'URL을 입력해주세요'**
  String get errorUrlEmpty;

  /// No description provided for @errorUrlInvalid.
  ///
  /// In ko, this message translates to:
  /// **'유효하지 않은 YouTube URL입니다'**
  String get errorUrlInvalid;

  /// No description provided for @errorNetwork.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 오류: 인터넷 연결을 확인해주세요'**
  String get errorNetwork;

  /// No description provided for @errorVideoNotFound.
  ///
  /// In ko, this message translates to:
  /// **'영상을 찾을 수 없습니다 (비공개/삭제됨)'**
  String get errorVideoNotFound;

  /// No description provided for @errorVideoMetadataFailed.
  ///
  /// In ko, this message translates to:
  /// **'영상 정보를 가져올 수 없습니다'**
  String get errorVideoMetadataFailed;

  /// No description provided for @errorTimestampInvalidFormat.
  ///
  /// In ko, this message translates to:
  /// **'올바른 타임스탬프 형식을 입력하세요 (예: 1:23, 1:23:45, 1m30s, t=70s)'**
  String get errorTimestampInvalidFormat;

  /// No description provided for @errorTimestampExceeds.
  ///
  /// In ko, this message translates to:
  /// **'타임스탬프({timestamp})가 영상 길이({duration})를 초과할 수 없습니다'**
  String errorTimestampExceeds(String timestamp, String duration);

  /// No description provided for @errorGeneric.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get errorGeneric;

  /// No description provided for @notificationVideoAdded.
  ///
  /// In ko, this message translates to:
  /// **'영상이 추가되었습니다'**
  String get notificationVideoAdded;

  /// No description provided for @notificationVideoUpdated.
  ///
  /// In ko, this message translates to:
  /// **'영상이 수정되었습니다'**
  String get notificationVideoUpdated;

  /// No description provided for @notificationVideoDeleted.
  ///
  /// In ko, this message translates to:
  /// **'영상이 삭제되었습니다'**
  String get notificationVideoDeleted;

  /// No description provided for @notificationCategoryAdded.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 추가되었습니다'**
  String get notificationCategoryAdded;

  /// No description provided for @notificationCategoryUpdated.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 수정되었습니다'**
  String get notificationCategoryUpdated;

  /// No description provided for @notificationCategoryDeleted.
  ///
  /// In ko, this message translates to:
  /// **'카테고리가 삭제되었습니다'**
  String get notificationCategoryDeleted;

  /// No description provided for @notificationCannotDeleteLastCategory.
  ///
  /// In ko, this message translates to:
  /// **'마지막 카테고리는 삭제할 수 없습니다'**
  String get notificationCannotDeleteLastCategory;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
