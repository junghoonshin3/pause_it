# Google Play Console Closed Testing 자동 배포 구현 완료

## 🎉 구현 개요

Google Play Console의 Closed Testing 트랙에 자동으로 배포하는 CI/CD 파이프라인을 구축했습니다. 이제 main 브랜치에 머지하면 자동으로 AAB 파일이 Play Console에 업로드됩니다.

---

## ✅ 변경된 파일

### 1. Fastlane 구성

#### `android/fastlane/Pluginfile`
- ✅ `fastlane-plugin-supply` 추가 (Play Console 업로드용)

#### `android/fastlane/Appfile`
- ✅ `json_key_file` 경로 설정: `google_play_credentials.json`
- ✅ 패키지명 주석 업데이트

#### `android/fastlane/Fastfile`
- ✅ `deploy_to_play_console()` 함수 추가:
  - AAB 빌드 (Play Console 필수)
  - Closed Testing 트랙 업로드
  - Draft 상태로 배포 (수동 검토 필요)
- ✅ `prod` lane 변경: Firebase → Play Console

#### `android/fastlane/metadata/android/ko-KR/changelogs/default.txt` (신규)
- ✅ 기본 릴리스 노트: "버그 수정 및 안정성 개선"

### 2. GitHub Actions 워크플로우

#### `.github/workflows/deploy.yml`
- ✅ 워크플로우 이름 변경: "Deploy to Firebase App Distribution & Google Play Console"
- ✅ Google Play Console 서비스 계정 생성 단계 추가 (main 브랜치만)
- ✅ Firebase 서비스 계정 단계 제거 (Prod는 Play Console만 사용)
- ✅ Prod 배포 단계 이름 변경: "Deploy to Prod (Google Play Console)"
- ✅ AAB 아티팩트 업로드 단계 추가 (7일 보관)

### 3. 문서화

#### `docs/google-play-console-setup.md` (신규)
- ✅ 서비스 계정 생성 가이드 (단계별 스크린샷 설명)
- ✅ Play Console 권한 설정 방법
- ✅ GitHub Secrets 등록 방법
- ✅ 로컬 테스트 가이드
- ✅ 트러블슈팅 섹션
- ✅ 전체 체크리스트

#### `docs/DEPLOYMENT.md` (신규)
- ✅ 빠른 시작 가이드
- ✅ 자동 배포 워크플로우 설명
- ✅ 필수 GitHub Secrets 목록
- ✅ Play Console 수동 배포 절차
- ✅ 로컬 빌드 방법
- ✅ 트러블슈팅

---

## 🚀 새로운 배포 플로우

### 이전 (Before)

```
develop → Firebase App Distribution (DEV, APK)
main    → Firebase App Distribution (PROD, APK)
```

### 이후 (After)

```
develop → Firebase App Distribution (DEV, APK)
main    → Google Play Console Closed Testing (PROD, AAB)
```

---

## 📋 다음 단계 (사용자가 해야 할 일)

### 1. Google Play Console 서비스 계정 생성 ⚠️ 필수

**참고 문서**: [`docs/google-play-console-setup.md`](./docs/google-play-console-setup.md)

#### 1.1 Google Cloud Console
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. Firebase 프로젝트 선택
3. "IAM 및 관리자" → "서비스 계정" → "서비스 계정 만들기"
4. 이름: `pause-it-play-console-uploader`
5. 역할: 건너뛰기 (Play Console에서 설정)
6. "키" 탭 → JSON 키 생성 및 다운로드

#### 1.2 Google Play Console
1. [Play Console](https://play.google.com/console) 접속
2. "설정" → "API 액세스"
3. 서비스 계정 찾기 → "액세스 권한 부여"
4. 권한 설정:
   - ✅ 릴리스 보기
   - ✅ 릴리스 제작 및 수정
   - ❌ 릴리스 관리 및 게시 (수동 검토)
5. "사용자 초대" 클릭

#### 1.3 GitHub Secrets 등록
```bash
# macOS/Linux
base64 -i pause-it-play-console-xxx.json | pbcopy
```

GitHub → Settings → Secrets and variables → Actions:
- **Name**: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`
- **Value**: 위에서 복사한 Base64 문자열

---

### 2. Fastlane 플러그인 설치 (로컬 테스트 시)

```bash
cd android
bundle exec fastlane add_plugin supply
```

> **참고**: 이 명령어는 `Pluginfile`을 자동 업데이트하지만, 이미 수동으로 추가했으므로 건너뛰어도 됩니다.

---

### 3. 테스트 배포

#### 3.1 테스트 브랜치로 검증 (권장)

```bash
# 현재 브랜치(feature/test-ci-workflow)에서 테스트
git add .
git commit -m "feat: Google Play Console 자동 배포 구현"
git push origin feature/test-ci-workflow

# 테스트용 main 브랜치 푸시 (주의: 실제 배포 발생!)
# 또는 워크플로우 파일의 트리거를 임시로 변경하여 테스트
```

#### 3.2 실제 배포 (신중하게!)

```bash
# develop → main PR 생성
# GitHub에서 PR 승인 및 머지

# 자동으로 GitHub Actions 트리거
# → AAB 빌드 → Play Console 업로드 (Draft)
```

#### 3.3 Play Console에서 확인

1. [Play Console](https://play.google.com/console) → "Pause it"
2. "출시" → "테스트" → "비공개 테스트"
3. Draft 릴리스 확인
4. "검토" → "비공개 테스트로 출시 시작"

---

### 4. 테스터 관리

1. Play Console → "테스터" 탭
2. 이메일 목록 생성 (최소 12명)
3. 옵트인 URL 공유
4. 14일간 테스트 진행

---

### 5. 프로덕션 전환 (심사 승인 후)

Google Play 프로덕션 승인을 받은 후:

**파일**: `android/fastlane/Fastfile`

```ruby
# deploy_to_play_console 함수 내부 수정
upload_to_play_store(
  track: "production",       # 변경: internal → production
  # ...
  release_status: "completed",  # 변경: draft → completed
)
```

---

## 🔍 검증 체크리스트

### GitHub Actions 확인
- [ ] Actions 탭에서 워크플로우 실행 확인
- [ ] "Deploy to Prod (Google Play Console)" 단계 성공
- [ ] AAB 아티팩트 다운로드 가능 (Artifacts 섹션)

### Play Console 확인
- [ ] "비공개 테스트" 트랙에 Draft 릴리스 존재
- [ ] 버전 코드 및 버전 이름 정확
- [ ] AAB 파일 크기 정상 (예상: 20-30MB)

### 로컬 테스트 (선택사항)
```bash
# AAB 빌드 테스트
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
ls -lh build/app/outputs/bundle/prodRelease/app-prod-release.aab

# Fastlane 업로드 테스트 (서비스 계정 JSON 필요)
cd android
bundle exec fastlane prod
```

---

## 🐛 트러블슈팅

### 서비스 계정 권한 오류
```
Insufficient permissions to perform this action
```

**해결**:
- Play Console → 설정 → API 액세스
- 서비스 계정 권한 재확인
- 5-10분 대기 (권한 전파)

### 버전 코드 충돌
```
Version code XX has already been used
```

**해결**:
```bash
# 로컬 커밋 수 확인
git rev-list --count HEAD

# Play Console에서 최신 버전 코드 확인
# Fastfile에서 수동 오버라이드:
version_code_override: 123  # 최신 버전 + 1
```

### JSON 키 파일 오류
```
Could not find service account json file
```

**해결**:
- GitHub Secrets 확인: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`
- Base64 인코딩 재확인
- Secret 값 재등록

---

## 📚 참고 문서

- **전체 설정 가이드**: [`docs/google-play-console-setup.md`](./docs/google-play-console-setup.md)
- **배포 가이드**: [`docs/DEPLOYMENT.md`](./docs/DEPLOYMENT.md)
- **Fastlane supply**: https://docs.fastlane.tools/actions/upload_to_play_store/
- **Play Console API**: https://docs.fastlane.tools/actions/supply/#setup

---

## 🎯 요약

### 구현 완료
- ✅ Fastlane 구성 (Play Console 업로드)
- ✅ GitHub Actions 워크플로우 수정
- ✅ 문서화 (설정 가이드, 배포 가이드)

### 사용자가 할 일
1. ⚠️ **Google Play Console 서비스 계정 생성 및 권한 설정**
2. ⚠️ **GitHub Secrets 등록**: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`
3. ✅ Fastlane 플러그인 설치 (로컬 테스트 시)
4. ✅ 테스트 배포 및 검증
5. ✅ 테스터 관리 (12명, 14일)
6. ✅ 프로덕션 전환 (심사 후)

### 주요 변경 사항
- **develop 브랜치**: Firebase (APK) - 변경 없음
- **main 브랜치**: Firebase (APK) → Play Console (AAB)
- **배포 상태**: 자동 완료 → Draft (수동 검토)

---

## 🚨 주의사항

1. **서비스 계정 JSON 파일 보안**:
   - 절대로 Git에 커밋하지 마세요!
   - `.gitignore`에 이미 추가되어 있습니다.

2. **권한 전파 시간**:
   - Play Console에서 권한 설정 후 5-10분 대기 필요

3. **버전 코드 관리**:
   - Git 커밋 수 기반으로 자동 생성
   - Play Console과 충돌 시 수동 오버라이드 필요

4. **Draft 상태**:
   - 자동 업로드는 Draft 상태로만 진행
   - 실제 배포는 Play Console에서 수동으로 진행
   - 심사 승인 후 자동 배포로 전환 가능

---

**구현 완료!** 🎉

이제 Google Play Console 서비스 계정만 설정하면 자동 배포를 사용할 수 있습니다.
