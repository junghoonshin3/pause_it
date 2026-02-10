# CI/CD 가이드

## 개요

Pause It 프로젝트는 GitHub Actions를 사용하여 자동화된 CI/CD 파이프라인을 운영합니다.

- **CI (Continuous Integration)**: PR 단계에서 코드 품질 검증
- **CD (Continuous Deployment)**: 머지 후 Firebase App Distribution 자동 배포

---

## 워크플로우 구조

### 📋 CI - 빌드 & 테스트 (`.github/workflows/ci.yml`)

**트리거:**
- `main` 또는 `develop` 브랜치를 대상으로 하는 **Pull Request 생성/업데이트** 시

**실행 내용:**
1. ✅ 코드 분석 (`flutter analyze`)
2. ✅ 유닛 테스트 (`flutter test`)
3. ✅ Dev/Prod 빌드 검증 (debug 모드)

**목적:**
- PR 머지 전에 코드 품질 검증
- 빌드 가능 여부 확인
- 테스트 실패 시 머지 차단

**배포:** ❌ 배포하지 않음

---

### 🚀 CD - 배포 (`.github/workflows/deploy.yml`)

**트리거:**
- `main` 또는 `develop` 브랜치에 **머지 (push)** 시

**실행 내용:**
1. ✅ Release 모드로 빌드 (`flutter build appbundle --release`)
2. ✅ Firebase App Distribution에 자동 배포
   - `develop` → **DEV 환경** (내부 테스터용)
   - `main` → **PROD 환경** (프로덕션)

**목적:**
- 검증된 코드를 실제 사용자에게 배포
- 스테이징(DEV)/프로덕션(PROD) 환경 분리

**배포:** ✅ Firebase App Distribution

---

## 개발 워크플로우

### 1️⃣ 기능 개발 (Feature Branch)

```bash
# 기능 브랜치 생성
git checkout -b feature/add-new-feature

# 작업 후 커밋
git add .
git commit -m "feat: 새로운 기능 추가"

# 원격 저장소에 푸시
git push origin feature/add-new-feature
```

---

### 2️⃣ PR 생성 → CI 검증

```
GitHub에서 Pull Request 생성
(feature/add-new-feature → develop)

        ↓

[CI 자동 실행] 🔍
├─ flutter analyze
├─ flutter test
└─ flutter build (debug)

        ↓

✅ All checks have passed
또는
❌ Some checks failed (수정 필요)
```

**CI 실행 시간:** 약 3~5분

**확인 방법:**
- GitHub PR 페이지에서 "Checks" 탭 확인
- ✅ 초록색 체크마크: 통과
- ❌ 빨간색 X: 실패 (로그 확인 후 수정)

---

### 3️⃣ PR 머지 → CD 배포

```
CI 통과 + 코드 리뷰 승인
        ↓
PR 머지 (Merge pull request)
        ↓

[CD 자동 실행] 🚀
├─ flutter build appbundle --release
└─ Firebase App Distribution (DEV)

        ↓

📱 내부 테스터에게 자동 알림
앱 다운로드 링크 전송
```

**CD 실행 시간:** 약 5~10분

**확인 방법:**
- GitHub Actions 탭에서 "Deploy to Firebase App Distribution" 워크플로우 확인
- Firebase Console → App Distribution 메뉴에서 새 릴리즈 확인

---

### 4️⃣ 프로덕션 배포 (develop → main)

```bash
# develop에서 충분히 테스트 완료 후

# GitHub에서 PR 생성
(develop → main)

        ↓

[CI 자동 실행] 🔍 (다시 검증)

        ↓

✅ CI 통과 + 최종 승인

        ↓

PR 머지 (main)

        ↓

[CD 자동 실행] 🚀
└─ Firebase App Distribution (PROD)

        ↓

🎉 프로덕션 배포 완료
```

---

## 브랜치 전략 (Git Flow)

```
main (프로덕션)
  ↑
  PR + CI 검증
  ↑
develop (스테이징)
  ↑
  PR + CI 검증
  ↑
feature/* (기능 개발)
```

### 브랜치별 역할

| 브랜치 | 용도 | 배포 환경 | 직접 Push |
|--------|------|-----------|-----------|
| `main` | 프로덕션 코드 | PROD (실사용자) | ❌ PR 필수 |
| `develop` | 개발 통합 | DEV (내부 테스터) | ❌ PR 필수 |
| `feature/*` | 기능 개발 | 없음 | ✅ 가능 |

---

## 주요 규칙

### ✅ DO (권장)

1. **기능 개발은 feature 브랜치에서**
   ```bash
   git checkout -b feature/add-timer
   ```

2. **PR을 통해서만 develop/main에 머지**
   - CI 검증 필수 통과
   - 코드 리뷰 권장

3. **커밋 메시지는 한글로 작성** (CLAUDE.md 규칙)
   ```bash
   git commit -m "feat: 타이머 기능 추가"
   ```

4. **CI 실패 시 즉시 수정**
   - PR에서 "Details" 클릭하여 로그 확인
   - 로컬에서 `flutter analyze`, `flutter test` 실행하여 미리 검증

---

### ❌ DON'T (금지)

1. **develop/main 브랜치에 직접 push 금지**
   ```bash
   # ❌ 이렇게 하지 마세요
   git checkout develop
   git commit -m "급하게 수정"
   git push
   ```

2. **CI를 우회하여 머지 금지**
   - "Merge without waiting for requirements to be met" 사용 금지

3. **테스트가 깨진 상태로 PR 머지 금지**
   - CI가 ❌ 상태일 때 머지하면 CD도 실패

---

## 문제 해결 (Troubleshooting)

### CI 실패 시

**1. flutter analyze 실패**
```bash
# 로컬에서 확인
flutter analyze

# 자동 수정 가능한 항목 수정
dart fix --apply
```

**2. flutter test 실패**
```bash
# 로컬에서 테스트 실행
flutter test

# 특정 테스트만 실행
flutter test test/models/video_test.dart
```

**3. 빌드 실패**
```bash
# 로컬에서 빌드 테스트
flutter build apk --flavor dev --target=lib/main_dev.dart --debug

# 캐시 정리 후 재시도
flutter clean
flutter pub get
```

---

### CD 실패 시

**1. Firebase 인증 실패**
- GitHub Secrets 확인:
  - `FIREBASE_SERVICE_ACCOUNT_JSON_DEV_BASE64`
  - `FIREBASE_SERVICE_ACCOUNT_JSON_PROD_BASE64`
  - `GOOGLE_SERVICES_DEV`
  - `GOOGLE_SERVICES_JSON_PROD`

**2. 빌드 실패**
- GitHub Actions 로그에서 상세 에러 확인
- `.env` 파일 생성 단계 확인

**3. 배포 실패**
- Firebase Console에서 App Distribution 설정 확인
- 테스터 그룹 설정 확인

---

## 성능 최적화

### 캐시 활용

CI/CD 워크플로우는 다음을 캐시하여 빌드 시간을 단축합니다:

1. **Gradle 캐시**: ~4-5분 단축
2. **Flutter 빌드 캐시**: ~1-2분 단축
3. **Ruby Bundler 캐시**: ~30초 단축

**총 빌드 시간:**
- 첫 빌드: ~10-15분
- 캐시 적중 시: ~5-8분

---

## 브랜치 보호 규칙 설정 (선택사항)

직접 push를 완전히 차단하려면 GitHub 설정이 필요합니다:

1. GitHub Repository → **Settings** → **Branches**
2. **Add branch protection rule**
3. Branch name pattern: `main`, `develop`
4. 설정:
   - ✅ **Require a pull request before merging**
   - ✅ **Require status checks to pass before merging**
     - 선택: `test` (CI workflow의 job 이름)
   - ✅ **Require approvals** (1명 이상)
   - ✅ **Dismiss stale pull request approvals when new commits are pushed**

---

## 수동 배포 (긴급 상황)

GitHub Actions에서 수동으로 배포를 트리거할 수 있습니다:

1. GitHub Repository → **Actions** 탭
2. **Deploy to Firebase App Distribution** 선택
3. **Run workflow** 클릭
4. 브랜치 선택 (`main` 또는 `develop`)
5. **Run workflow** 버튼 클릭

---

## 요약

| 단계 | 브랜치 | 트리거 | 실행 내용 | 배포 |
|------|--------|--------|-----------|------|
| 개발 | `feature/*` | 로컬 작업 | - | - |
| CI | PR → `develop` | PR 생성/업데이트 | 분석, 테스트, 빌드 검증 | ❌ |
| CD | `develop` | PR 머지 | Release 빌드, Firebase 배포 | ✅ DEV |
| CI | PR → `main` | PR 생성/업데이트 | 분석, 테스트, 빌드 검증 | ❌ |
| CD | `main` | PR 머지 | Release 빌드, Firebase 배포 | ✅ PROD |

---

## 참고 링크

- [GitHub Actions 문서](https://docs.github.com/en/actions)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Flutter CI/CD 가이드](https://docs.flutter.dev/deployment/cd)
