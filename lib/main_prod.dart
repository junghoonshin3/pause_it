import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'generated/l10n/app_localizations.dart';
import 'shared/data/database/database_helper.dart';
import 'features/categories/presentation/screens/categories_list_screen_brutalist.dart';
import 'features/videos/presentation/providers/video_provider.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/config/flavor_config.dart';
import 'core/config/app_config.dart';
import 'core/providers/locale_provider.dart';

/// [main] - 앱 진입점 (PROD 환경)
///
/// 주요 작업:
/// - Flavor 설정 초기화 (PROD)
/// - WidgetsFlutterBinding 초기화
/// - 데이터베이스 초기화
/// - 타임존 초기화 (알림 기능용)
/// - 알림 서비스 초기화 및 권한 요청
/// - 앱 실행
void main() async {
  // Flutter 엔진 초기화 (데이터베이스 사용을 위해 필요)
  WidgetsFlutterBinding.ensureInitialized();

  // Flavor 설정 초기화 (PROD)
  FlavorConfig(
    flavor: Flavor.prod,
    name: 'PROD',
    appName: 'Pause it',
    bundleId: 'com.pauseit.pauseIt',
    packageName: 'com.pauseit.pause_it',
  );

  // 앱 설정 로드 (PROD에서는 로깅 비활성화)
  // ignore: unused_local_variable
  final appConfig = AppConfig.prod;

  // 데이터베이스 초기화 (테이블 생성 보장)
  await DatabaseHelper.instance.database;

  // 타임존 데이터 초기화 (알림 스케줄링에 필요)
  tz.initializeTimeZones();

  // 알림 서비스 초기화
  await NotificationService.instance.initialize();

  // 알림 권한 요청 (iOS 및 Android 13+)
  await NotificationService.instance.requestPermission();

  // 앱 실행
  runApp(const ProviderScope(child: MyApp()));
}

/// [MyApp] - 앱 루트 위젯 (PROD 환경)
///
/// Material Design 3 적용 및 Share Intent 리스너 구임
/// PROD 환경에서는 디버그 배너 숨김
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  late StreamSubscription<String> _intentSubscription;

  @override
  void initState() {
    super.initState();
    _handleInitialSharedIntent();
    _listenToSharedIntents();
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
        if (AppConfig.prod.enableLogging) {
          debugPrint('공유 처리 실패: ${failure.message}');
        }
      },
      (sharedUrlResult) {
        // sharedUrlStateProvider에 저장 -> 다이얼로그 트리거
        ref.read(sharedUrlStateProvider.notifier).state = sharedUrlResult;
      },
    );
  }

  @override
  void dispose() {
    _intentSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: FlavorConfig.instance.appName,
      debugShowCheckedModeBanner: false, // PROD 환경: 디버그 배너 숨김
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
