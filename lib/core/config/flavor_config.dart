/// Flavor 환경 열거형
///
/// dev: 개발 환경
/// prod: 프로덕션 환경
enum Flavor { dev, prod }

/// Flavor 설정 클래스 (Singleton)
///
/// 앱의 환경별 설정을 관리합니다.
/// - App Name, Bundle ID, Package Name 등 환경별로 다른 값 제공
/// - isDev, isProd 헬퍼 메서드로 환경 체크 간편화
class FlavorConfig {
  final Flavor flavor;
  final String name;
  final String appName;
  final String bundleId;
  final String packageName;

  static FlavorConfig? _instance;

  /// Flavor 설정 생성자
  ///
  /// 한 번만 초기화되며, 이후 호출 시 기존 인스턴스 반환 (Singleton)
  factory FlavorConfig({
    required Flavor flavor,
    required String name,
    required String appName,
    required String bundleId,
    required String packageName,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor,
      name,
      appName,
      bundleId,
      packageName,
    );
    return _instance!;
  }

  FlavorConfig._internal(
    this.flavor,
    this.name,
    this.appName,
    this.bundleId,
    this.packageName,
  );

  /// 현재 Flavor 설정 인스턴스 가져오기
  static FlavorConfig get instance => _instance!;

  /// Dev 환경 여부 확인
  static bool get isDev => _instance?.flavor == Flavor.dev;

  /// Prod 환경 여부 확인
  static bool get isProd => _instance?.flavor == Flavor.prod;

  @override
  String toString() {
    return 'FlavorConfig(flavor: $flavor, name: $name, appName: $appName)';
  }
}
