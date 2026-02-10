# Google Play Console 자동 배포 설정 가이드

## 개요

이 문서는 Google Play Console의 Closed Testing 트랙에 자동으로 배포하기 위한 설정 가이드입니다.

### 배포 플로우

- **develop 브랜치** → Firebase App Distribution (DEV, APK)
- **main 브랜치** → Google Play Console Closed Testing (PROD, AAB)

---

## 1. Google Play Console 서비스 계정 생성

### 1.1 Google Cloud Console에서 서비스 계정 생성

1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. Firebase 프로젝트와 동일한 프로젝트 선택
3. **"IAM 및 관리자"** → **"서비스 계정"** 메뉴 클릭
4. **"서비스 계정 만들기"** 클릭:
   - **이름**: `pause-it-play-console-uploader`
   - **설명**: `Fastlane을 통한 Google Play Console 자동 업로드용`
   - **"만들기 및 계속하기"** 클릭
5. 역할 선택: **건너뛰기** (Play Console에서 권한 부여)
6. **"완료"** 클릭
7. 생성된 서비스 계정 클릭 → **"키"** 탭
8. **"키 추가"** → **"새 키 만들기"** → **JSON** 선택
9. JSON 키 파일 다운로드 (예: `pause-it-play-console-xxx.json`)

### 1.2 Google Play Console에 서비스 계정 연결

1. [Google Play Console](https://play.google.com/console) 접속
2. **"설정"** (왼쪽 하단 톱니바퀴) → **"API 액세스"** 클릭
3. **"서비스 계정"** 섹션에서 생성한 서비스 계정 확인
4. 해당 서비스 계정 우측의 **"액세스 권한 부여"** 또는 **"앱 액세스 관리"** 클릭
5. 권한 설정:
   - **앱 액세스**: "Pause it" 앱 선택
   - **앱 권한**:
     - ✅ **릴리스 보기**
     - ✅ **릴리스 제작 및 수정**
     - ❌ **릴리스 관리 및 게시** (수동 검토 유지)
6. **"사용자 초대"** 또는 **"변경사항 적용"** 클릭

> **참고**: 권한이 전파되는 데 5-10분 정도 소요될 수 있습니다.

### 1.3 GitHub Secrets에 JSON 키 등록

#### 로컬에서 Base64 인코딩

```bash
# macOS/Linux
base64 -i pause-it-play-console-xxx.json | pbcopy

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("pause-it-play-console-xxx.json")) | Set-Clipboard
```

#### GitHub Secrets 등록

1. GitHub 저장소 → **Settings** → **Secrets and variables** → **Actions**
2. **"New repository secret"** 클릭
3. Secret 정보:
   - **Name**: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`
   - **Value**: 위에서 복사한 Base64 문자열 붙여넣기
4. **"Add secret"** 클릭

---

## 2. Fastlane 플러그인 설치

로컬에서 테스트하기 전에 플러그인을 설치해야 합니다:

```bash
cd android
bundle exec fastlane add_plugin supply
```

이 명령어는 `Pluginfile`에 `fastlane-plugin-supply`를 자동으로 추가합니다.

---

## 3. 로컬 테스트 (선택사항)

### 3.1 Google Play 서비스 계정 JSON 파일 복사

```bash
# JSON 키 파일을 android 디렉토리에 복사
cp /path/to/pause-it-play-console-xxx.json android/google_play_credentials.json
```

> **주의**: `google_play_credentials.json`은 `.gitignore`에 포함되어 있으므로 Git에 커밋되지 않습니다.

### 3.2 AAB 빌드 테스트

```bash
# 프로젝트 루트 디렉토리에서
flutter build appbundle --release --flavor prod -t lib/main_prod.dart

# AAB 파일 확인
ls -lh build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### 3.3 Fastlane 업로드 테스트

```bash
cd android
bundle exec fastlane prod
```

업로드가 성공하면 다음 메시지가 표시됩니다:
```
🎉 Google Play Console Closed Testing 업로드 완료!
📍 Play Console에서 수동으로 검토 후 배포하세요.
```

---

## 4. 자동 배포 사용법

### 4.1 main 브랜치로 머지

```bash
# develop → main PR 생성
git checkout develop
git pull origin develop

# main으로 머지 (GitHub에서 PR 생성 및 머지)
```

### 4.2 자동 배포 확인

1. GitHub → **Actions** 탭
2. 최신 워크플로우 실행 확인 (`Deploy to Firebase App Distribution & Google Play Console`)
3. **"Deploy to Prod (Google Play Console)"** 단계 로그 확인:
   ```
   🎉 Google Play Console Closed Testing 업로드 완료!
   ```
4. **"Upload AAB Artifact"** 단계에서 AAB 파일 다운로드 가능 (7일간 보관)

### 4.3 Play Console에서 수동 배포

자동 업로드 후 Play Console에서 수동으로 배포해야 합니다:

1. [Google Play Console](https://play.google.com/console) 접속
2. **"Pause it"** 앱 선택
3. **"출시"** → **"테스트"** → **"비공개 테스트"** (Closed Testing)
4. **새로운 릴리스 확인** (Draft 상태)
5. **"검토"** 클릭 → 릴리스 노트 및 버전 확인
6. **"비공개 테스트로 출시 시작"** 클릭

---

## 5. 테스터 관리

### 5.1 테스터 목록 생성

1. Play Console → **"Pause it"** → **"출시"** → **"테스트"** → **"비공개 테스트"**
2. **"테스터"** 탭 클릭
3. **"이메일 목록 만들기"** 클릭
4. 목록 이름 입력 (예: `Internal Testers`)
5. **테스터 이메일 추가** (최소 12명 권장):
   - Google 계정 이메일 사용
   - 쉼표로 구분하여 여러 이메일 입력 가능
6. **"변경사항 저장"** 클릭

### 5.2 테스터 초대

1. 테스터 목록 생성 후 **옵트인 URL** 복사
2. 테스터에게 이메일 또는 메시지로 URL 공유:
   ```
   안녕하세요!
   Pause it 앱의 비공개 테스트에 초대합니다.

   아래 링크를 클릭하여 참여해주세요:
   [옵트인 URL]

   참여 후 Google Play에서 앱을 다운로드할 수 있습니다.
   ```

### 5.3 프로덕션 승인 요구사항

Google Play 프로덕션 액세스를 받기 위해서는:
- **최소 12명의 테스터** 참여
- **14일간 연속 테스트** 진행
- 심각한 크래시나 버그 없이 안정성 유지

---

## 6. 프로덕션 전환 (심사 승인 후)

Google Play 프로덕션 승인을 받은 후, 자동 배포를 프로덕션 트랙으로 전환할 수 있습니다.

### 6.1 Fastfile 수정

**파일**: `android/fastlane/Fastfile`

```ruby
# deploy_to_play_console 함수 내부 수정
upload_to_play_store(
  track: "production",       # 변경: internal → production
  aab: "../build/app/outputs/bundle/#{flavor}Release/app-#{flavor}-release.aab",
  json_key: "google_play_credentials.json",
  skip_upload_screenshots: true,
  skip_upload_images: true,
  skip_upload_metadata: false,
  release_status: "completed",  # 변경: draft → completed (자동 배포)
  version_code_override: nil
)
```

### 6.2 단계별 출시 (선택사항)

프로덕션 배포 시 점진적 출시를 원할 경우:

```ruby
upload_to_play_store(
  track: "production",
  rollout: "0.1",  # 10%부터 시작
  # ... 나머지 옵션
)
```

출시 비율 조정:
- `rollout: "0.1"` → 10%
- `rollout: "0.5"` → 50%
- `rollout: "1.0"` → 100% (전체 출시)

---

## 7. 트러블슈팅

### 7.1 권한 오류

**오류 메시지**:
```
Insufficient permissions to perform this action
```

**해결 방법**:
1. Play Console → **설정** → **API 액세스**
2. 서비스 계정 권한 확인:
   - ✅ 릴리스 보기
   - ✅ 릴리스 제작 및 수정
3. 권한 재부여 후 **5-10분 대기** (권한 전파 시간)

### 7.2 버전 코드 충돌

**오류 메시지**:
```
Version code XX has already been used
```

**해결 방법**:

1. **Git 커밋 카운트 확인**:
   ```bash
   git rev-list --count HEAD
   ```

2. **Play Console에서 최신 버전 코드 확인**:
   - Play Console → 앱 → 출시 → 프로덕션 또는 테스트 트랙
   - 최신 릴리스의 버전 코드 확인

3. **Fastfile에서 수동 오버라이드** (임시 해결):
   ```ruby
   upload_to_play_store(
     # ...
     version_code_override: 123  # Play Console 최신 버전 + 1
   )
   ```

### 7.3 AAB 서명 오류

**오류 메시지**:
```
Execution failed for task ':app:signProdReleaseBundle'
```

**해결 방법**:

1. **Keystore 파일 확인**:
   ```bash
   ls -l android/app/upload-key.jks
   ```

2. **key.properties 확인**:
   ```bash
   cat android/key.properties
   ```

3. **GitHub Secrets 검증**:
   - `ANDROID_KEYSTORE_BASE64`
   - `ANDROID_KEY_PROPERTIES`

### 7.4 JSON 키 파일 오류

**오류 메시지**:
```
Could not find service account json file
```

**해결 방법**:

1. **로컬 테스트**:
   ```bash
   ls -l android/google_play_credentials.json
   ```

2. **GitHub Secrets 확인**:
   - Secret 이름: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_BASE64`
   - Base64 인코딩 여부 확인

3. **재인코딩**:
   ```bash
   base64 -i pause-it-play-console-xxx.json | pbcopy
   ```

---

## 8. Google Play 트랙 비교

| 트랙 | 테스터 수 | 배포 속도 | 심사 여부 | 용도 |
|------|-----------|-----------|-----------|------|
| **Internal Testing** | 최대 100명 | 즉시 | ❌ | 개발/QA |
| **Closed Testing** | 무제한 | 몇 시간 | ✅ | **프로덕션 심사 요구사항** |
| **Open Testing** | 누구나 | 몇 시간 | ✅ | 공개 베타 |
| **Production** | 전체 사용자 | 몇 시간~며칠 | ✅ | 실제 출시 |

**현재 사용**: **Closed Testing** (14일, 12명 테스트 필요)

---

## 9. 참고 자료

- [Fastlane supply 액션](https://docs.fastlane.tools/actions/upload_to_play_store/)
- [Google Play Console API 설정](https://docs.fastlane.tools/actions/supply/#setup)
- [Flutter AAB 빌드](https://docs.flutter.dev/deployment/android#build-an-app-bundle)
- [Play Console Closed Testing](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Google Play 심사 요구사항](https://support.google.com/googleplay/android-developer/answer/9859455)

---

## 10. 체크리스트

### Phase 1: 서비스 계정 설정
- [ ] Google Cloud Console에서 서비스 계정 생성
- [ ] JSON 키 다운로드
- [ ] Play Console에 서비스 계정 연결 및 권한 부여
- [ ] GitHub Secrets에 Base64 인코딩된 JSON 등록

### Phase 2: 로컬 테스트 (선택사항)
- [ ] Fastlane 플러그인 설치 (`bundle exec fastlane add_plugin supply`)
- [ ] 로컬에서 AAB 빌드 테스트
- [ ] Fastlane 업로드 테스트

### Phase 3: 자동 배포 테스트
- [ ] 테스트 브랜치로 GitHub Actions 검증
- [ ] main 브랜치 머지 및 자동 배포 확인
- [ ] Play Console에서 Draft 릴리스 확인

### Phase 4: Closed Testing 시작
- [ ] Play Console에서 수동으로 Closed Testing 배포
- [ ] 테스터 12명 이상 초대
- [ ] 14일간 테스트 진행

### Phase 5: 프로덕션 전환 (심사 후)
- [ ] Google Play 프로덕션 승인 대기
- [ ] Fastfile에서 `track: "production"` 변경
- [ ] 단계별 출시 여부 결정
