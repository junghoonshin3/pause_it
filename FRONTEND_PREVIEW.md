# Pause it - Neo-Brutalist Frontend Preview

## 🎨 완성된 디자인 시스템

### ✅ 구현 완료된 컴포넌트

#### 1. **메인 테마 시스템** (`app_theme.dart`)
- Neo-Brutalist 디자인 철학 적용
- Space Grotesk + Noto Sans 타이포그래피 시스템
- 전기적인 색상 팔레트 (Cyan, Neon Pink, Yellow)
- 날카로운 직각 모서리와 강한 섀도우

#### 2. **CategoryCardBrutalist**
```
┌─────────────────────┐
│ [12]            ■   │  ← 비디오 카운트 + 상태 인디케이터
│                     │
│     ╔═══════╗       │  ← 큰 아이콘 박스
│     ║ 📁   ║       │
│     ╚═══════╝       │
│                     │
│  CATEGORY NAME      │  ← 대문자 대담한 타이틀
│  VIDEOS             │
└─────────────────────┘
   ▓▓▓▓▓▓ (shadow)
```

**특징:**
- 그리드 패턴 배경 텍스처
- 탭 시 스케일 + 섀도우 애니메이션
- 롱프레스 옵션 메뉴 (Edit/Delete)
- 카테고리 색상 배경

#### 3. **CategoriesListScreenBrutalist**
```
╔═══════════════════════════════════╗
║ ▌PAUSE IT                     [⟳] ║  ← 커스텀 헤더
║ ▌TIMESTAMP ARCHIVE                ║
║                                   ║
║ [4 CATEGORIES] [ACTIVE]           ║  ← 통계 스트립
╠═══════════════════════════════════╣
║                                   ║
║  ┌────┐  ┌────┐  ┌────┐  ┌────┐  ║  ← 그리드 레이아웃
║  │ 🎬 │  │ 📚 │  │ 🎵 │  │ 🎯 │  ║
║  └────┘  └────┘  └────┘  └────┘  ║
║                                   ║
║  ┌────┐  ┌────┐                   ║
║  │ 🎨 │  │ 💻 │                   ║
║  └────┘  └────┘                   ║
║                                   ║
╠═══════════════════════════════════╣
║                        [+ ADD] ▓▓ ║  ← Brutalist FAB
╚═══════════════════════════════════╝
```

**특징:**
- 진입 시 staggered fade-up 애니메이션
- 커스텀 헤더 with 그라디언트 액센트
- Brutalist 스낵바 알림
- 빈 화면 상태 처리

---

## 🎬 애니메이션 & 인터랙션

### 카드 탭 애니메이션
```
Normal State:
┌─────────┐
│  카드   │
└─────────┘
   ▓▓▓▓

Pressed State (150ms):
 ┌────────┐
 │  카드  │ (scale: 0.98)
 └────────┘
  ▓▓ (shadow offset: 6,6 → 2,2)
```

### 페이지 전환
- 오른쪽에서 슬라이드 (300ms, easeOutCubic)
- 부드러운 네이티브 느낌

### 진입 애니메이션
- 카드별 50ms 지연 (staggered)
- 아래에서 위로 fade-up
- 전체 300ms 완료

---

## 🎯 주요 디자인 결정

### Why Neo-Brutalism?
1. **차별화**: 일반적인 Material Design 피하기
2. **강렬함**: 비디오/미디어 콘텐츠와 어울리는 대담함
3. **기억성**: 독특한 시각적 정체성
4. **프리미엄**: 전문 도구 느낌

### Why Space Grotesk?
- 기하학적이고 현대적
- 한글(Noto Sans)과 잘 어울림
- 대문자 사용 시 강렬한 느낌

### Why Electric Cyan + Neon Pink?
- 높은 가시성과 대비
- 디지털/미디어 느낌
- 다크 배경에서 돋보임
- 액션별 색상 구분 (Cyan: 주요, Pink: 경고)

---

## 📱 현재 상태

### ✅ 완료
- [x] 전역 테마 시스템
- [x] CategoryCardBrutalist 컴포넌트
- [x] CategoriesListScreenBrutalist 화면
- [x] 탭 애니메이션
- [x] 롱프레스 메뉴
- [x] 빈 화면 상태
- [x] 로딩/에러 화면
- [x] Brutalist 스낵바
- [x] 삭제 확인 다이얼로그
- [x] Google Fonts 통합

### 🔄 다음 단계 (선택사항)
- [ ] VideoListScreen Brutalist 버전
- [ ] VideoCard Brutalist 버전
- [ ] Add/Edit Dialog Brutalist 버전
- [ ] 타임스탬프 입력 UI 개선
- [ ] 공유 다이얼로그 스타일링

---

## 🚀 테스트 방법

### 1. 앱 실행
```bash
flutter run
```

### 2. 확인 사항

#### 시각적 체크
- ✅ 카테고리 카드가 네온 보더와 강한 섀도우로 표시되는가?
- ✅ 헤더의 "PAUSE IT" 타이틀이 대담하고 큰가?
- ✅ 통계 스트립이 모노스페이스 폰트로 표시되는가?
- ✅ 빈 화면 상태가 적절히 스타일링되었는가?

#### 인터랙션 체크
- ✅ 카드 탭 시 스케일 애니메이션이 부드러운가?
- ✅ 롱프레스 시 옵션 메뉴가 Brutalist 스타일인가?
- ✅ 삭제 다이얼로그가 네온 핑크 보더인가?
- ✅ 스낵바가 커스텀 스타일로 표시되는가?

#### 애니메이션 체크
- ✅ 카드들이 순차적으로 나타나는가? (staggered)
- ✅ 페이지 전환이 부드러운가?
- ✅ FAB 버튼이 직각 스타일인가?

---

## 💻 코드 하이라이트

### 그리드 패턴 텍스처
```dart
CustomPaint(
  painter: GridPatternPainter(
    color: contrastColor.withOpacity(0.08),
  ),
)
```

### Brutalist 섀도우
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withOpacity(0.5),
    offset: Offset(6, 6),
    blurRadius: 0,  // No blur! Sharp shadow
  ),
]
```

### 탭 애니메이션
```dart
_scaleAnimation = Tween<double>(
  begin: 1.0,
  end: 0.98,
).animate(CurvedAnimation(
  parent: _controller,
  curve: Curves.easeOutCubic,
));
```

---

## 🎨 색상 참고

```dart
// Copy-paste ready colors
Primary:   #1A1A1D
Secondary: #2D2D30
Surface:   #25252A

Cyan:      #00F0FF  // 주요 액션
Pink:      #FF006E  // 경고/삭제
Yellow:    #FBFF00  // 경고
Purple:    #8B5CF6  // 보조

Text:      #FFFFFF
Muted:     #B4B4B8
Subtle:    #6E6E73
```

---

## 📖 참고 문서

- [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) - 전체 디자인 시스템 문서
- [CLAUDE.md](./CLAUDE.md) - 프로젝트 가이드라인
- Flutter Material 3: https://m3.material.io/
- Google Fonts: https://fonts.google.com/

---

**현재 구현 상태**: Categories 화면 완료 ✅
**다음 작업**: 필요 시 Video 화면 디자인 적용

이 디자인은 일반적인 앱과 완전히 차별화된 시각적 정체성을 제공합니다! 🔲⚡
