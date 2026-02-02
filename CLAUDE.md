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