import 'dart:async';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'generated/l10n/app_localizations.dart';
import 'shared/data/database/database_helper.dart';
import 'features/categories/presentation/screens/categories_list_screen_brutalist.dart';
import 'features/videos/presentation/providers/video_provider.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/config/flavor_config.dart';
import 'core/config/app_config.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/analytics_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options_dev.dart';

/// [main] - 앱 진입점 (DEV 환경)
///
/// 주요 작업:
/// - Flavor 설정 초기화 (DEV)
/// - WidgetsFlutterBinding 초기화
/// - 데이터베이스 초기화
/// - 타임존 초기화 (알림 기능용)
/// - 알림 서비스 초기화 및 권한 요청
/// - 앱 실행
void main() async {
  // Flutter 엔진 초기화 (데이터베이스 사용을 위해 필요)
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어베이스 초기화
  await Firebase.initializeApp(options: DevFirebaseOptions.currentPlatform);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Flavor 설정 초기화 (DEV)
  FlavorConfig(
    flavor: Flavor.dev,
    name: 'DEV',
    appName: 'Pause it DEV',
    bundleId: 'com.pauseit.pauseIt.dev',
    packageName: 'com.pauseit.pause_it.dev',
  );

  // 앱 설정 로드
  final appConfig = AppConfig.dev;
  if (appConfig.enableLogging) {
    debugPrint('🔧 [DEV] Pause it DEV 시작');
    debugPrint('🔧 [DEV] Flavor: ${FlavorConfig.instance}');
    debugPrint('🔧 [DEV] Config: $appConfig');
  }

  // 데이터베이스 초기화 (테이블 생성 보장)
  await DatabaseHelper.instance.database;

  // 타임존 데이터 초기화 및 디바이스 로컬 타임졸 설정 (알림 스케줄링에 필요)
  tz.initializeTimeZones();
  final timezoneInfo = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

  // 알림 서비스 초기화
  await NotificationService.instance.initialize();

  // 알림 권한 요청 (iOS 및 Android 13+)
  await NotificationService.instance.requestPermission();

  // Analytics: 앱 시작 이벤트 로깅
  AnalyticsService.instance.logAppStarted();

  // 앱 실행
  runApp(const ProviderScope(child: MyApp()));
}

/// [MyApp] - 앱 루트 위젯 (DEV 환경)
///
/// Material Design 3 적용 및 Share Intent 리스너 구현
/// DEV 환경에서는 디버그 배너 표시
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late StreamSubscription<String> _intentSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 앱 설정 복원 (SharedPreferences)
    ref.read(settingsProvider.notifier).loadSettings();
    _handleInitialSharedIntent();
    _listenToSharedIntents();
  }

  /// [didChangeAppLifecycleState] - 앱 라이프사이클 변경 시 Analytics 로깅
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AnalyticsService.instance.logAppResumed();
        break;
      case AppLifecycleState.paused:
        AnalyticsService.instance.logAppPaused();
        break;
      case AppLifecycleState.detached:
        AnalyticsService.instance.logAppDetached();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// [_handleInitialSharedIntent] - 앱 최초 실행 시 공유 데이터 처리
  ///
  /// YouTube 공유로 앱이 실행된 경우 URL 처리
  Future<void> _handleInitialSharedIntent() async {
    final service = ref.read(shareIntentServiceProvider);
    final sharedText = await service.getInitialSharedText();
    if (sharedText != null && sharedText.isNotEmpty) {
      _processSharedUrl(sharedText);
    }
  }

  /// [_listenToSharedIntents] - 앱 실행 중 공유 스트림 구독
  ///
  /// 앱이 백그라운드에 있을 때 공유받은 경우 처리
  void _listenToSharedIntents() {
    final service = ref.read(shareIntentServiceProvider);
    _intentSubscription = service.sharedTextStream.listen((sharedText) {
      if (sharedText.isNotEmpty) {
        _processSharedUrl(sharedText);
      }
    });
  }

  /// [_processSharedUrl] - 공유 URL 처리
  ///
  /// YouTube URL을 파싱하고 메타데이터를 가져와서
  /// sharedUrlStateProvider에 저장 (다이얼로그 트리거)
  Future<void> _processSharedUrl(String sharedText) async {
    final handleSharedUrl = ref.read(handleSharedUrlProvider);
    final result = await handleSharedUrl(sharedText);

    result.fold(
      (failure) {
        // 에러는 무시 (YouTube URL이 아닐 수 있음)
        debugPrint('공유 처리 실패: ${failure.message}');
      },
      (sharedUrlResult) {
        // sharedUrlStateProvider에 저장 -> 다이얼로그 트리거
        ref.read(sharedUrlStateProvider.notifier).state = sharedUrlResult;
        // Analytics: 공유 Intent 수신 성공 로깅
        AnalyticsService.instance.logShareIntentReceived(
          hasTimestamp: sharedUrlResult.timestampSeconds > 0,
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: FlavorConfig.instance.appName,
      debugShowCheckedModeBanner: true, // DEV 환경: 디버그 배너 표시
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // 다국어 설정
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // 사용자가 언어를 명시적으로 설정한 경우
        if (locale != null) return locale;

        // 시스템 언어가 지원하는 언어 중 하나인 경우
        if (deviceLocale != null) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale.languageCode) {
              return supportedLocale;
            }
          }
        }

        // 기본값: 영어
        return const Locale('en', 'US');
      },

      home: const CategoriesListScreenBrutalist(),
    );
  }
}
