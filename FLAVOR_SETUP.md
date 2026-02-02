# Flutter Flavor 설정 가이드

## 개요

Pause it 프로젝트는 Dev/Prod 환경을 분리하는 Flutter Flavor 시스템을 사용합니다.

## 환경별 앱 식별

| 환경 | App Name | Package ID (Android) | Bundle ID (iOS) |
|------|----------|---------------------|-----------------|
| **Dev** | Pause it DEV | `com.pauseit.pause_it.dev` | `com.pauseit.pauseIt.dev` |
| **Prod** | Pause it | `com.pauseit.pause_it` | `com.pauseit.pauseIt` |

## 로컬에서 실행하기

### Dev 환경 실행
```bash
flutter run -t lib/main_dev.dart
```

### Prod 환경 실행
```bash
flutter run -t lib/main_prod.dart
```

## 빌드하기

### 빌드 스크립트 사용 (권장)

#### Dev 빌드
```bash
./scripts/build_dev.sh
```
- 출력: `build/app/outputs/flutter-apk/app-dev-release.apk`
- 출력 (iOS): `build/ios/iphoneos/Runner.app`

#### Prod 빌드
```bash
./scripts/build_prod.sh
```
- 출력: `build/app/outputs/flutter-apk/app-prod-release.apk`
- 출력 (iOS): `build/ios/iphoneos/Runner.app`

### 수동 빌드

#### Android

**Dev Debug 빌드**
```bash
flutter build apk --debug --flavor dev -t lib/main_dev.dart
```

**Dev Release 빌드**
```bash
flutter build apk --release --flavor dev -t lib/main_dev.dart
```

**Prod Debug 빌드**
```bash
flutter build apk --debug --flavor prod -t lib/main_prod.dart
```

**Prod Release 빌드**
```bash
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

#### iOS

**Dev Debug 빌드**
```bash
flutter build ios --debug --flavor dev -t lib/main_dev.dart --no-codesign
```

**Dev Release 빌드**
```bash
flutter build ios --release --flavor dev -t lib/main_dev.dart --no-codesign
```

**Prod Debug 빌드**
```bash
flutter build ios --debug --flavor prod -t lib/main_prod.dart --no-codesign
```

**Prod Release 빌드**
```bash
flutter build ios --release --flavor prod -t lib/main_prod.dart --no-codesign
```

## 특정 기기에 설치

```bash
# Dev 설치
flutter install --flavor dev -t lib/main_dev.dart -d <device_id>

# Prod 설치
flutter install --flavor prod -t lib/main_prod.dart -d <device_id>
```

## Flavor 설정 파일 구조

```
lib/
├── main_dev.dart              # Dev 진입점
├── main_prod.dart             # Prod 진입점
└── core/
    └── config/
        ├── flavor_config.dart # Flavor 설정 클래스
        └── app_config.dart    # 환경별 설정
```

## Android Flavor 구조

```
android/
├── app/
│   ├── build.gradle.kts       # Product flavors 정의
│   └── src/
│       ├── main/              # 공통 설정
│       ├── dev/               # Dev flavor 리소스
│       │   ├── AndroidManifest.xml
│       │   └── res/
│       │       ├── mipmap-*/ic_launcher.png  # Dev 아이콘
│       │       └── values/strings.xml
│       └── prod/              # Prod flavor 리소스
│           ├── AndroidManifest.xml
│           └── res/
│               ├── mipmap-*/ic_launcher.png  # Prod 아이콘
│               └── values/strings.xml
└── key.properties             # 서명 설정 (gitignored)
```

## iOS Flavor 구조 (향후 구현)

```
ios/
├── Runner.xcodeproj/
│   └── xcshareddata/xcschemes/
│       ├── dev.xcscheme       # Dev 스킴
│       └── prod.xcscheme      # Prod 스킴
└── ExportOptions-*.plist      # Export 옵션
```

## 앱 아이콘

현재 Dev와 Prod 아이콘이 동일합니다. 필요시 다음 파일을 교체하세요:

- `assets/icon_dev.png` - Dev 아이콘 (1024x1024, DEV 배지 포함 권장)
- `assets/icon_prod.png` - Prod 아이콘 (1024x1024)

아이콘 교체 후 다음 명령어로 재생성:

```bash
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-dev.yaml
flutter pub run flutter_launcher_icons:main -f flutter_launcher_icons-prod.yaml
```

## 환경별 설정

### Dev 환경 (`AppConfig.dev`)
- 로깅: 활성화
- 분석: 비활성화
- 디버그 배너: 표시
- API: `https://dev-api.pauseit.com`

### Prod 환경 (`AppConfig.prod`)
- 로깅: 비활성화
- 분석: 활성화 (향후)
- 디버그 배너: 숨김
- API: `https://api.pauseit.com`

## 코드에서 Flavor 확인

```dart
import 'package:pause_it/core/config/flavor_config.dart';
import 'package:pause_it/core/config/app_config.dart';

// Flavor 확인
if (FlavorConfig.isDev) {
  print('현재 Dev 환경');
}

if (FlavorConfig.isProd) {
  print('현재 Prod 환경');
}

// 앱 이름 가져오기
String appName = FlavorConfig.instance.appName;

// 환경별 설정 사용
if (AppConfig.dev.enableLogging) {
  print('로깅 활성화');
}
```

## 주의사항

1. **서명 파일 보안**
   - `android/key.properties`는 절대 Git에 커밋하지 마세요
   - `android/app/keystore.jks`는 안전한 곳에 백업하세요

2. **동시 설치**
   - Dev와 Prod는 서로 다른 Package ID를 사용하므로 동시 설치 가능합니다
   - 각 환경의 데이터베이스는 독립적으로 관리됩니다

3. **빌드 문제 해결**
   - 빌드 오류 발생 시: `flutter clean && flutter pub get`
   - Gradle 캐시 문제 시: `cd android && ./gradlew clean`

## 다음 단계 (향후 작업)

- [ ] iOS Flavor 설정 (Xcode Schemes)
- [ ] Firebase 프로젝트 연동 (Dev/Prod 분리)
- [ ] CI/CD 파이프라인 (GitHub Actions)
- [ ] 스토어 배포 (TestFlight, Google Play)

---

**작성일**: 2026-02-02
**버전**: 1.0.0
