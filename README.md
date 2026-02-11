# Pause It

YouTube 영상의 타임스탬프를 카테고리별로 저장하고 관리하는 아카이브 앱

## 주요 기능

- **카테고리 관리** - 커스텀 카테고리로 영상을 분류하고 관리
- **타임스탬프 저장** - YouTube 영상의 특정 시점을 기록하고 바로 재생
- **YouTube 메타데이터 자동 추출** - URL만 입력하면 제목, 썸네일 등 자동으로 가져오기
- **공유 인텐트** - 다른 앱에서 YouTube 링크를 공유하면 바로 저장
- **알림 리마인더** - 저장한 영상을 잊지 않도록 알림 설정
- **다국어 지원** - 한국어, 영어, 일본어

## 스크린샷

<!-- TODO: 스크린샷 추가 -->

## 기술 스택

| 구분 | 기술 |
|------|------|
| Framework | Flutter (Material 3) |
| State Management | Riverpod |
| Database | sqflite (Local First) |
| Analytics & Crash | Firebase Analytics, Crashlytics |
| Architecture | Clean Architecture |
| Design System | Neo-Brutalist |

## 프로젝트 구조

```
lib/
├── core/
│   ├── config/          # 앱 설정, Flavor 설정
│   ├── constants/       # DB 상수
│   ├── error/           # 예외 및 실패 처리
│   ├── providers/       # 전역 Provider (locale, settings, analytics)
│   ├── services/        # YouTube, 공유 인텐트, 알림, 애널리틱스
│   ├── theme/           # Neo-Brutalist 테마
│   └── usecases/        # UseCase 베이스 클래스
├── features/
│   ├── categories/
│   │   ├── data/        # DataSource, Model, Repository 구현
│   │   ├── domain/      # Entity, Repository 인터페이스
│   │   └── presentation/# Screen, Provider, Widget
│   └── videos/
│       ├── data/        # DataSource, Model, Repository 구현
│       ├── domain/      # Entity, UseCase, Repository 인터페이스
│       └── presentation/# Screen, Provider, Widget
├── generated/l10n/      # 다국어 리소스 (ko, en, ja)
├── shared/data/database/ # DatabaseHelper
├── firebase_options.dart
├── firebase_options_dev.dart
├── main_dev.dart         # Dev Flavor 진입점
└── main_prod.dart        # Prod Flavor 진입점
```

## 시작하기

### 요구사항

- Flutter SDK 3.10.4+
- Java 17 (Android 빌드)
- Android Studio 또는 VS Code

### 설치

```bash
git clone https://github.com/junghoonshin3/pause-it.git
cd pause-it
flutter pub get
```

### 환경 변수 설정

프로젝트 루트에 `.env` 파일을 생성하고 Firebase 키를 설정합니다.

```env
FIREBASE_API_KEY_DEV_ANDROID=your_key
FIREBASE_APP_ID_DEV_ANDROID=your_app_id
FIREBASE_API_KEY_DEV_IOS=your_key
FIREBASE_APP_ID_DEV_IOS=your_app_id
FIREBASE_API_KEY_PROD_ANDROID=your_key
FIREBASE_APP_ID_PROD_ANDROID=your_app_id
FIREBASE_API_KEY_PROD_IOS=your_key
FIREBASE_APP_ID_PROD_IOS=your_app_id
```

### 실행

```bash
# Dev
flutter run --flavor dev --target=lib/main_dev.dart

# Prod
flutter run --flavor prod --target=lib/main_prod.dart
```

### 빌드

```bash
# Dev AAB
flutter build appbundle --flavor dev --release --target=lib/main_dev.dart

# Prod AAB
flutter build appbundle --flavor prod --release --target=lib/main_prod.dart
```

## 배포

GitHub Actions의 `workflow_dispatch`를 통한 수동 배포 방식을 사용합니다.

1. GitHub 저장소의 **Actions** 탭으로 이동
2. **Deploy to Firebase App Distribution & Google Play Console** 워크플로우 선택
3. **Run workflow** 클릭 후 배포 대상 선택
   - `dev` - Firebase App Distribution으로 배포
   - `prod` - Google Play Console 비공개 테스트(alpha)로 배포 -> 추후 프로덕션 배포로 변경예정

## 라이선스

<!-- TODO: 라이선스 추가 -->
