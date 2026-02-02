# Pause it - 핵심 개발 규칙

## 1. 기술 스택
- Framework: Flutter (Material 3)
- State Management: Riverpod
- Database: sqflite (Local First)
- Architecture: Clean Architecture (Data/Domain/Presentation)

## 2. 코딩 스타일 & 네이밍
- 파일명: `snake_case.dart`
- 클래스명: `PascalCase`
- 변수/함수명: `camelCase`
- 모든 주요 함수 및 클래스에는 한글 주석 필수

## 3. 아키텍처 원칙
- UI와 비즈니스 로직 엄격 분리
- 기능별 파일 분할 (lib/models, lib/providers, lib/services, lib/screens 등)
- 예외 처리(Try-Catch) 및 사용자 피드백(SnackBar 등) 필수 포함

## 4. 커밋 규칙
- 커밋 메시지는 **반드시 한글**로 작성
- 커밋 타입은 영문으로 작성하고 콜론 뒤에 한글 설명
- 형식: `type: 한글로 작성된 커밋 내용`

### 커밋 타입
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `refactor`: 코드 리팩토링 (기능 변경 없음)
- `style`: UI/디자인 변경
- `chore`: 빌드 설정, 패키지 매니저 등 기타 작업
- `docs`: 문서 수정
- `test`: 테스트 코드 추가/수정

### 커밋 예시
```
feat: 카테고리별 영상 정렬 기능 추가
fix: 영상 삭제 시 발생하는 오류 수정
refactor: 비디오 모델 구조 개선
style: Neo-Brutalist 디자인 시스템 적용
chore: 앱 아이콘 업데이트
docs: README 설치 가이드 추가
```