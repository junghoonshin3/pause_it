# 배포 가이드

## 개요

Pause It 프로젝트의 자동 배포 시스템은 두 가지 환경을 지원합니다:

| 브랜치 | 환경 | 플랫폼 | 파일 형식 | 용도 |
|--------|------|--------|-----------|------|
| `develop` | DEV | Firebase App Distribution | APK | 내부 개발 및 QA 테스트 |
| `main` | PROD | Google Play Console | AAB | Closed Testing (프로덕션 심사용) |

---

## 빠른 시작

### 1. DEV 배포 (develop 브랜치)

```bash
# develop 브랜치에 푸시하면 자동 배포
git checkout develop
git add .
git commit -m "feat: 새로운 기능 추가"
git push origin develop
```

**결과**: Firebase App Distribution에 APK 업로드 → 테스터들에게 자동 알림

### 2. PROD 배포 (main 브랜치)

```bash
# develop → main PR 생성 및 머지
# GitHub에서 PR 승인 후 머지
```

**결과**: Google Play Console Closed Testing에 AAB 업로드 (Draft 상태) → Play Console에서 수동 배포

---

## 자동 배포 워크플로우

### GitHub Actions 트리거

- **트리거 조건**: `develop` 또는 `main` 브랜치에 push 이벤트 발생
- **워크플로우 파일**: `.github/workflows/deploy.yml`

### 단계별 프로세스

#### 1. 환경 설정
- Java 17, Flutter (stable), Ruby 3.2 설치
- Gradle 및 Flutter 빌드 캐시 복원

#### 2. 인증 파일 생성
- **공통**: Android Keystore (`upload-key.jks`, `key.properties`)
- **공통**: Google Services JSON 파일 (`google-services.json`)
- **공통**: `.env` 파일 (Firebase 환경변수)
- **DEV**: Firebase 서비스 계정 JSON
- **PROD**: Google Play Console 서비스 계정 JSON

#### 3. 빌드 및 배포
- **DEV**: APK 빌드 → Firebase App Distribution 업로드
- **PROD**: AAB 빌드 → Google Play Console 업로드 (Draft)

#### 4. 아티팩트 보관
- **PROD**: AAB 파일 7일간 보관 (디버깅용)

---

## 필수 GitHub Secrets

아래 Secrets는 GitHub 저장소 설정에서 미리 등록되어 있어야 합니다:

### 공통 Secrets

| Secret 이름 | 설명 | 생성 방법 |
|-------------|------|-----------|
| `ANDROID_KEYSTORE_BASE64` | Android 서명 키스토어 (Base64) | `base64 -i upload-key.jks` |
| `ANDROID_KEY_PROPERTIES` | 키스토어 설정 파일 | `cat key.properties` |
| `GOOGLE_SERVICES_DEV` | Google Services JSON (DEV, Base64) | `base64 -i google-services.json` |
| `GOOGLE_SERVICES_JSON_PROD` | Google Services JSON (PROD, Base64) | `base64 -i google-services.json` |
| `FIREBASE_API_KEY_DEV_ANDROID` | Firebase API 키 (DEV, Android) | Firebase Console |
| `FIREBASE_APP_ID_DEV_ANDROID` | Firebase App ID (DEV, Android) | Firebase Console |
| `FIREBASE_API_KEY_PROD_ANDROID` | Firebase API 키 (PROD, Android) | Firebase Console |
| `FIREBASE_APP_ID_PROD_ANDROID` | Firebase App ID (PROD, Android) | Firebase Console |

### DEV 전용 Secrets

| Secret 이름 | 설명 | 생성 방법 |
|-------------|------|-----------|
| `FIREBASE_SERVICE_ACCOUNT_JSON_DEV_BASE64` | Firebase 서비스 계정 (DEV, Base64) | [Firebase 가이드](https://firebase.google.com/docs/app-distribution/authenticate-service-account) |

### PROD 전용 Secrets

| Secret 이름 | 설명 | 생성 방법 |
|-------------|------|-----------|
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64` | Play Console 서비스 계정 (Base64) | [Play Console 가이드](./google-play-console-setup.md) |

---

## Play Console 수동 배포 절차

main 브랜치에 머지하면 자동으로 AAB가 업로드되지만, **실제 배포는 수동**으로 진행해야 합니다.

### 1. Play Console 접속

1. [Google Play Console](https://play.google.com/console) 접속
2. **"Pause it"** 앱 선택

### 2. Draft 릴리스 확인

1. **"출시"** → **"테스트"** → **"비공개 테스트"** 클릭
2. **"새 릴리스"** 섹션에서 Draft 상태 확인
3. 버전 정보 검토:
   - 버전 코드 (Git 커밋 카운트)
   - 버전 이름 (pubspec.yaml)
   - AAB 크기

### 3. 릴리스 검토 및 배포

1. **"검토"** 버튼 클릭
2. 릴리스 노트 확인 (자동 생성: "버그 수정 및 안정성 개선")
3. **"비공개 테스트로 출시 시작"** 클릭
4. 완료!

### 4. 테스터 관리

1. **"테스터"** 탭 클릭
2. 이메일 목록 생성 및 테스터 추가 (최소 12명)
3. 옵트인 URL을 테스터에게 공유

---

## 로컬 빌드 및 테스트

자동 배포를 사용하지 않고 로컬에서 직접 빌드/배포할 수도 있습니다.

### DEV 환경

```bash
# APK 빌드
flutter build apk --release --flavor dev -t lib/main_dev.dart

# Fastlane으로 Firebase 배포
cd android
bundle exec fastlane dev
```

### PROD 환경

```bash
# AAB 빌드
flutter build appbundle --release --flavor prod -t lib/main_prod.dart

# Fastlane으로 Play Console 배포
cd android
bundle exec fastlane prod
```

> **주의**: 로컬 배포 시 서비스 계정 JSON 파일이 필요합니다.
> - DEV: `android/firebase_credentials.json`
> - PROD: `android/google_play_credentials.json`

---

## 버전 관리

### 버전 코드 (Version Code)

자동으로 Git 커밋 수를 기반으로 생성됩니다:

```gradle
// android/app/build.gradle.kts
versionCode = "git rev-list --count HEAD".execute().text.trim().toInt()
```

### 버전 이름 (Version Name)

`pubspec.yaml`에서 수동 관리:

```yaml
version: 1.0.0+1
```

형식: `주.부.패치+빌드번호`

---

## 트러블슈팅

### 빌드 실패

**문제**: Gradle 빌드 실패

**해결**:
```bash
# Gradle 캐시 삭제
cd android
./gradlew clean

# Flutter 빌드 캐시 삭제
cd ..
flutter clean
flutter pub get
```

### Firebase 업로드 실패 (DEV)

**문제**: `Unauthorized` 또는 `Invalid credentials`

**해결**:
1. Firebase Console → 프로젝트 설정 → 서비스 계정
2. 새 서비스 계정 키 생성
3. GitHub Secrets 업데이트: `FIREBASE_SERVICE_ACCOUNT_JSON_DEV_BASE64`

### Play Console 업로드 실패 (PROD)

**문제**: `Insufficient permissions`

**해결**:
1. Play Console → 설정 → API 액세스
2. 서비스 계정 권한 확인:
   - ✅ 릴리스 보기
   - ✅ 릴리스 제작 및 수정
3. 5-10분 대기 (권한 전파)

### 버전 코드 충돌

**문제**: `Version code already used`

**해결**:
1. Play Console에서 최신 버전 코드 확인
2. 로컬 커밋 수 확인: `git rev-list --count HEAD`
3. 필요 시 Fastfile에서 수동 오버라이드

---

## 참고 문서

- [Google Play Console 설정 가이드](./google-play-console-setup.md)
- [Firebase App Distribution 문서](https://firebase.google.com/docs/app-distribution)
- [Fastlane 공식 문서](https://docs.fastlane.tools/)
- [Flutter Android 배포 가이드](https://docs.flutter.dev/deployment/android)

---

## 배포 체크리스트

### 첫 배포 전 준비
- [ ] GitHub Secrets 모두 등록 완료
- [ ] Firebase App Distribution 테스터 그룹 생성
- [ ] Play Console 서비스 계정 설정 완료
- [ ] Play Console 테스터 목록 생성 (12명 이상)

### 매 배포 시
- [ ] 변경 사항 테스트 완료
- [ ] 버전 번호 업데이트 (`pubspec.yaml`)
- [ ] CHANGELOG 작성 (필요 시)
- [ ] develop 브랜치 테스트 통과 확인
- [ ] main 브랜치 머지 전 코드 리뷰
- [ ] Play Console에서 Draft 릴리스 검토
- [ ] 테스터에게 배포 알림

### 프로덕션 전환 시 (심사 후)
- [ ] 14일 테스트 완료 확인
- [ ] 크래시 리포트 검토
- [ ] 사용자 피드백 확인
- [ ] Fastfile `track` 변경 (`internal` → `production`)
- [ ] 단계별 출시 비율 결정
