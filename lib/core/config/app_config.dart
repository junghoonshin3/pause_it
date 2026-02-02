/// 앱 환경별 설정 클래스
///
/// Dev/Prod 환경에 따라 다른 설정 값을 제공합니다.
/// - 로깅 활성화 여부
/// - 분석 도구 활성화 여부
/// - API Base URL (향후 백엔드 연동 시 사용)
class AppConfig {
  /// 로깅 활성화 여부 (Dev에서만 활성화)
  final bool enableLogging;

  /// 분석 도구 활성화 여부 (Prod에서만 활성화)
  final bool enableAnalytics;

  /// API Base URL (향후 백엔드 연동 시 사용)
  final String apiBaseUrl;

  const AppConfig({
    required this.enableLogging,
    required this.enableAnalytics,
    required this.apiBaseUrl,
  });

  /// Dev 환경 설정
  ///
  /// - 로깅: 활성화 (디버깅용)
  /// - 분석: 비활성화 (개발 데이터 수집 방지)
  /// - API: dev 서버 URL
  static AppConfig get dev => const AppConfig(
        enableLogging: true,
        enableAnalytics: false,
        apiBaseUrl: 'https://dev-api.pauseit.com',
      );

  /// Prod 환경 설정
  ///
  /// - 로깅: 비활성화 (성능 최적화)
  /// - 분석: 활성화 (사용자 데이터 수집)
  /// - API: 프로덕션 서버 URL
  static AppConfig get prod => const AppConfig(
        enableLogging: false,
        enableAnalytics: true,
        apiBaseUrl: 'https://api.pauseit.com',
      );

  @override
  String toString() {
    return 'AppConfig(logging: $enableLogging, analytics: $enableAnalytics, api: $apiBaseUrl)';
  }
}
