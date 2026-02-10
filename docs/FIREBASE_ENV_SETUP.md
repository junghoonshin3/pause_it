# Firebase 환경변수 설정 가이드

## 개요

Firebase API 키와 앱 ID를 `flutter_dotenv` 패키지를 사용하여 `.env` 파일에서 관리합니다.
- **민감한 정보**: `apiKey`, `appId` → `.env` 파일로 관리 (Git 무시)
- **비민감 정보**: `projectId`, `storageBucket` 등 → Git 커밋

> **중요**: `.env` 파일은 절대로 Git에 커밋하지 마세요!

---

## 로컬 개발 환경 설정

### 방법 1: VS Code에서 실행 (권장)

1. 프로젝트 루트에 `.env` 파일 생성 (아래 예시 참고)
2. VS Code에서 프로젝트 열기
3. `Run and Debug` 패널 열기 (Cmd+Shift+D)
4. 드롭다운에서 선택:
   - `Pause it DEV` - DEV 환경 실행
   - `Pause it PROD` - PROD 환경 실행
5. F5 또는 재생 버튼 클릭

> `.env` 파일의 환경변수가 자동으로 로드됩니다.

---

### 방법 2: 빌드 스크립트 사용

#### 1단계: `.env` 파일 생성

프로젝트 루트에 `.env` 파일을 생성하고 실제 Firebase 키를 추가하세요:

```bash
# DEV 환경
FIREBASE_API_KEY_DEV_ANDROID=your_dev_android_api_key_here
FIREBASE_APP_ID_DEV_ANDROID=your_dev_android_app_id_here
FIREBASE_API_KEY_DEV_IOS=your_dev_ios_api_key_here
FIREBASE_APP_ID_DEV_IOS=your_dev_ios_app_id_here

# PROD 환경
FIREBASE_API_KEY_PROD_ANDROID=your_prod_android_api_key_here
FIREBASE_APP_ID_PROD_ANDROID=your_prod_android_app_id_here
FIREBASE_API_KEY_PROD_IOS=your_prod_ios_api_key_here
FIREBASE_APP_ID_PROD_IOS=your_prod_ios_app_id_here
```

> **참고**: `.env` 파일은 `.gitignore`에 포함되어 있어 Git에 커밋되지 않습니다.

#### 2단계: 빌드

```bash
# DEV 빌드
flutter build appbundle --flavor dev --release --target=lib/main_dev.dart

# PROD 빌드
flutter build appbundle --flavor prod --release --target=lib/main_prod.dart
```

---

### 방법 3: Flutter CLI 직접 사용

> **참고**: 현재는 `flutter_dotenv` 패키지를 사용하여 `.env` 파일에서 환경변수를 로드합니다.
> `--dart-define` 방식은 더 이상 사용하지 않습니다.

```bash
# .env 파일이 준비되어 있다면:

# DEV 환경 실행
flutter run --flavor dev -t lib/main_dev.dart

# PROD 환경 빌드
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

---

## GitHub Secrets 설정 (CI/CD)

GitHub Actions에서 자동 빌드/배포를 위해 다음 Secret을 추가해야 합니다:

### Secret 추가 방법

1. GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** 클릭
3. 아래 8개의 Secret 추가:

### DEV 환경 (4개)

| Name | Value |
|------|-------|
| `FIREBASE_API_KEY_DEV_ANDROID` | Firebase Console에서 확인 |
| `FIREBASE_APP_ID_DEV_ANDROID` | Firebase Console에서 확인 |
| `FIREBASE_API_KEY_DEV_IOS` | Firebase Console에서 확인 |
| `FIREBASE_APP_ID_DEV_IOS` | Firebase Console에서 확인 |

### PROD 환경 (4개)

| Name | Value |
|------|-------|
| `FIREBASE_API_KEY_PROD_ANDROID` | Firebase Console에서 확인 |
| `FIREBASE_APP_ID_PROD_ANDROID` | Firebase Console에서 확인 |
| `FIREBASE_API_KEY_PROD_IOS` | Firebase Console에서 확인 |
| `FIREBASE_APP_ID_PROD_IOS` | Firebase Console에서 확인 |

---

## 트러블슈팅

### 환경변수가 없을 때 증상

- Firebase 초기화 오류: `[core/no-app]`
- 빈 API 키 오류

### 해결 방법

1. **로컬 개발**: `.env` 파일이 프로젝트 루트에 있는지 확인
2. **파일 내용**: 모든 키가 올바르게 설정되었는지 확인
3. **CI/CD**: GitHub Secrets가 모두 추가되었는지 확인

### 환경변수 검증

Firebase 초기화 전에 환경변수를 확인하려면:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final apiKey = dotenv.env['FIREBASE_API_KEY_DEV_ANDROID'];
if (apiKey == null || apiKey.isEmpty) {
  throw Exception('Firebase API key is not set! Check your .env file.');
}
```

---

## 파일 구조

```
pause_it/
├── lib/
│   ├── firebase_options.dart          # PROD용 (dotenv 사용)
│   └── firebase_options_dev.dart      # DEV용 (dotenv 사용)
├── .env                               # 실제 환경변수 (Git 무시)
└── .gitignore                         # .env 파일 제외 설정
```

---

## 보안 주의사항

1. **절대로 커밋하지 말 것**:
   - `.env` (실제 API 키 포함)
   - `.env.local`, `.env.dev`, `.env.prod` 등 모든 환경변수 파일

2. **커밋 가능**:
   - `lib/firebase_options.dart` (dotenv 참조만 포함)
   - `lib/firebase_options_dev.dart` (dotenv 참조만 포함)
   - 문서 파일 (실제 API 키를 포함하지 않은 경우)

3. **GitHub Actions에서**:
   - GitHub Secrets를 통해 `.env` 파일 자동 생성
   - 빌드 로그에 환경변수가 노출되지 않도록 주의

4. **이미 노출된 API 키**:
   - Firebase Console에서 즉시 API 키 재생성 권장
   - Git 히스토리에서 민감한 정보 완전히 제거 필요
