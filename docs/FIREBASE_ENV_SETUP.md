# Firebase 환경변수 설정 가이드

## 개요

Firebase API 키와 앱 ID를 환경변수로 분리하여 보안을 강화했습니다.
- **민감한 정보**: `apiKey`, `appId` → 환경변수로 관리
- **비민감 정보**: `projectId`, `storageBucket` 등 → Git 커밋

---

## 로컬 개발 환경 설정

### 방법 1: VS Code에서 실행 (권장)

1. VS Code에서 프로젝트 열기
2. `Run and Debug` 패널 열기 (Cmd+Shift+D)
3. 드롭다운에서 선택:
   - `Pause it DEV` - DEV 환경 실행
   - `Pause it PROD` - PROD 환경 실행
4. F5 또는 재생 버튼 클릭

> `.vscode/launch.json`에 환경변수가 이미 설정되어 있습니다.

---

### 방법 2: 빌드 스크립트 사용

#### 1단계: 환경변수 파일 생성

```bash
cp .env.local.example .env.local
```

#### 2단계: `.env.local` 파일 편집

실제 Firebase 키로 값을 교체하세요:

```bash
# DEV 환경
export FIREBASE_API_KEY_DEV_ANDROID="***REMOVED_API_KEY***"
export FIREBASE_APP_ID_DEV_ANDROID="***REMOVED_APP_ID***"
export FIREBASE_API_KEY_DEV_IOS="***REMOVED_API_KEY***"
export FIREBASE_APP_ID_DEV_IOS="***REMOVED_APP_ID***"

# PROD 환경
export FIREBASE_API_KEY_PROD_ANDROID="***REMOVED_API_KEY***"
export FIREBASE_APP_ID_PROD_ANDROID="***REMOVED_APP_ID***"
export FIREBASE_API_KEY_PROD_IOS="***REMOVED_API_KEY***"
export FIREBASE_APP_ID_PROD_IOS="***REMOVED_APP_ID***"
```

#### 3단계: 빌드

```bash
# 환경변수 로드
source .env.local

# DEV 빌드
./scripts/build_dev.sh

# PROD 빌드
./scripts/build_prod.sh
```

---

### 방법 3: Flutter CLI 직접 사용

```bash
# DEV 환경 실행
flutter run --flavor dev -t lib/main_dev.dart \
  --dart-define=FIREBASE_API_KEY_DEV_ANDROID=***REMOVED_API_KEY*** \
  --dart-define=FIREBASE_APP_ID_DEV_ANDROID=***REMOVED_APP_ID*** \
  --dart-define=FIREBASE_API_KEY_DEV_IOS=***REMOVED_API_KEY*** \
  --dart-define=FIREBASE_APP_ID_DEV_IOS=***REMOVED_APP_ID***

# PROD 환경 빌드
flutter build apk --release --flavor prod -t lib/main_prod.dart \
  --dart-define=FIREBASE_API_KEY_PROD_ANDROID=***REMOVED_API_KEY*** \
  --dart-define=FIREBASE_APP_ID_PROD_ANDROID=***REMOVED_APP_ID*** \
  --dart-define=FIREBASE_API_KEY_PROD_IOS=***REMOVED_API_KEY*** \
  --dart-define=FIREBASE_APP_ID_PROD_IOS=***REMOVED_APP_ID***
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
| `FIREBASE_API_KEY_DEV_ANDROID` | `***REMOVED_API_KEY***` |
| `FIREBASE_APP_ID_DEV_ANDROID` | `***REMOVED_APP_ID***` |
| `FIREBASE_API_KEY_DEV_IOS` | `***REMOVED_API_KEY***` |
| `FIREBASE_APP_ID_DEV_IOS` | `***REMOVED_APP_ID***` |

### PROD 환경 (4개)

| Name | Value |
|------|-------|
| `FIREBASE_API_KEY_PROD_ANDROID` | `***REMOVED_API_KEY***` |
| `FIREBASE_APP_ID_PROD_ANDROID` | `***REMOVED_APP_ID***` |
| `FIREBASE_API_KEY_PROD_IOS` | `***REMOVED_API_KEY***` |
| `FIREBASE_APP_ID_PROD_IOS` | `***REMOVED_APP_ID***` |

---

## 트러블슈팅

### 환경변수가 없을 때 증상

- Firebase 초기화 오류: `[core/no-app]`
- 빈 API 키 오류

### 해결 방법

1. **로컬 개발**: `.env.local` 파일이 올바르게 설정되었는지 확인
2. **VS Code**: `.vscode/launch.json`의 `args` 배열에 환경변수가 있는지 확인
3. **CI/CD**: GitHub Secrets가 모두 추가되었는지 확인

### 환경변수 검증

Firebase 초기화 전에 환경변수를 확인하려면:

```dart
const apiKey = String.fromEnvironment('FIREBASE_API_KEY_DEV_ANDROID');
if (apiKey.isEmpty) {
  throw Exception('Firebase API key is not set! Check your environment variables.');
}
```

---

## 파일 구조

```
pause_it/
├── lib/
│   ├── firebase_options.dart          # PROD용 (환경변수 사용)
│   └── firebase_options_dev.dart      # DEV용 (환경변수 사용)
├── scripts/
│   ├── build_dev.sh                   # DEV 빌드 스크립트
│   └── build_prod.sh                  # PROD 빌드 스크립트
├── .vscode/
│   └── launch.json                    # VS Code 디버그 설정
├── .env.local.example                 # 환경변수 템플릿
└── .env.local                         # 실제 환경변수 (Git 무시)
```

---

## 보안 주의사항

1. **절대로 커밋하지 말 것**:
   - `.env.local` (실제 API 키 포함)

2. **커밋 가능**:
   - `.env.local.example` (템플릿만 포함)
   - `lib/firebase_options.dart` (환경변수 참조만 포함)
   - `lib/firebase_options_dev.dart` (환경변수 참조만 포함)

3. **GitHub Actions에서만**:
   - GitHub Secrets를 통해 환경변수 주입
   - 빌드 로그에 환경변수가 노출되지 않도록 주의
