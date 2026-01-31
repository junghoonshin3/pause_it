# 프로젝트명: Pause it (Youtube TimeStamp)

## 📌 프로젝트 개요
- **목적**: 유튜브 영상 시청 중 중단 시점(URL + 시간)을 카테고리별로 저장하는 앱.
- **플랫폼**: Flutter (Android/iOS/Web/Desktop 확장 고려)
- **상태**: 초기 개발 단계 (로컬 DB 기반)

## 🛠 기술 스택
- **Language**: Dart
- **Framework**: Flutter
- **Database**: sqflite (Local)
- **State Management**: Riverpod
- **Key Libraries**: youtube_explode_dart, url_launcher

## 🏗 아키텍처 및 규칙
- **Pattern**: Clean Architecture (Data -> Domain -> Presentation)
- **Naming**: 
  - 프로젝트명: `pause_it`
  - 클래스/파일명: Snake_case (파일), PascalCase (클래스)
- **Constraints**: 
  - 로그인 없이 로컬 우선 구현 (추후 Firebase 연동 예정)
  - 실제 스토어 배포용 고퀄리티 코드 유지
  - 추후 기능 추가을 염두해둔 유연한 설계

## 🎯 현재 진행 단계
- [x] Step 1: 프로젝트 구조 설계 및 DB 모델링 ✅
- [x] Step 2: 유튜브 메타데이터 추출 로직 구현 ✅
- [x] Step 3: 메인 UI 및 카테고리 기능 개발 ✅
- [x] Step 4: 영상 상세 추가 및 이동 로직 구현 ✅ (Current)

## 명심해야하는 부분
1. 단계별 점진적 개발 (Incremental Development)
한 번에 전체 앱 코드를 쏟아내지 마.

내가 준 'Step' 단위로 진행하며, 각 단계가 끝날 때마다 내가 코드를 실행해 보고 피드백을 줄 때까지 기다려줘.

각 단계가 끝나면 다음 단계에서 무엇을 할지 브리핑해 줘.

2. 모듈화된 파일 구조 (File Separation)
모든 코드를 main.dart 한 곳에 작성하지 마.

실제 배포용 프로젝트처럼 lib/models, lib/screens, lib/services, lib/widgets 등 기능별로 파일을 엄격히 분리해서 작성해 줘.

코드를 줄 때는 반드시 **파일 경로(예: lib/models/video_model.dart)**를 명시해 줘.

3. 코드 품질 및 주석 (Clean Code)
모든 클래스와 주요 함수에는 역할과 매개변수를 설명하는 한글 주석을 상세히 달아줘.

예외 상황(잘못된 URL, 네트워크 오류, DB 쓰기 실패 등)에 대한 Error Handling 코드를 반드시 포함해 줘.

Material 3 디자인 시스템을 기본으로 사용하여 UI가 세련되게 보이도록 신경 써줘.

4. 상태 관리 및 아키텍처 (Architecture)
데이터 흐름이 명확하도록 상태 관리(Provider 또는 Riverpod)를 적용해 줘.

UI 로직과 비즈니스 로직(DB 처리, API 통신)을 분리하는 패턴을 유지해 줘.

5. 작업 확인 및 동기화 (Sync)
답변 마지막에는 항상 현재 우리가 Claude.md에 정의한 단계 중 어디에 있는지, 다음 작업은 무엇인지 체크리스트 형식으로 보여줘.