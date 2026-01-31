# Pause it - Neo-Brutalist Design System

## 🎨 디자인 철학

**Neo-Brutalist Media Archive** - 프리미엄 미디어 관리 도구

Pause it의 새로운 디자인은 브루탈리즘 건축에서 영감을 받은 대담하고 기하학적인 인터페이스입니다. 일반적인 AI 생성 디자인의 평범함을 거부하고, 의도적으로 거칠고 날카로우며 기억에 남는 시각적 정체성을 구축했습니다.

---

## 🎯 핵심 디자인 원칙

### 1. **대담한 기하학적 형태**
- 모든 요소는 날카로운 직각 (border-radius: 0)
- 두꺼운 보더 (2px-4px)
- 강한 드롭섀도우 (오프셋, 블러 없음)
- 레이어드 UI와 겹치는 요소들

### 2. **고대비 타이포그래피**
- **Display/Headlines**: Space Grotesk (대담한 기하학적 sans-serif)
- **Body/Korean**: Noto Sans (한글 지원)
- **Monospace**: Roboto Mono (타임스탬프용)
- 대문자 활용 (UPPERCASE)으로 강렬함 극대화
- Letter-spacing 조정으로 리듬감 부여

### 3. **전기적인 색상**
```
Primary Dark:    #1A1A1D (깊은 차콜)
Secondary Dark:  #2D2D30
Surface Dark:    #25252A

Accent Electric: #00F0FF (시안 - 주요 액션)
Accent Neon:     #FF006E (네온 핑크 - 경고/삭제)
Accent Yellow:   #FBFF00 (경고)
Accent Purple:   #8B5CF6 (보조)
```

### 4. **의도적인 거칠음**
- 그리드 패턴 배경 텍스처
- 노출된 박스섀도우
- 비대칭 레이아웃
- 스탬프 느낌의 UI 요소

---

## 📐 컴포넌트 스타일 가이드

### **CategoryCardBrutalist**
- 카테고리 색상 배경 + 그리드 패턴 텍스처
- 3px 두께 다크 보더
- (6, 6) 오프셋 드롭섀도우
- 탭 시 스케일 애니메이션 (1.0 → 0.98)
- 대문자 타이틀 (letterSpacing: 0.5)
- 코너 장식 (우상단 삼각형 보더)

### **CategoriesListScreenBrutalist**
- 커스텀 헤더 with 그라디언트 액센트 바
- 통계 스트립 (모노스페이스 숫자)
- 그리드 레이아웃 (maxCrossAxisExtent: 220, spacing: 20)
- 진입 애니메이션 (staggered fade-up)
- Brutalist FAB (직각, 두꺼운 보더, 강한 섀도우)

### **Snackbar & Dialogs**
- 완전한 직각 모서리
- 2-4px 컬러 보더
- 아이콘을 박스 안에 배치
- 대문자 라벨링

---

## 🎬 애니메이션 원칙

### 타이밍
```dart
animationDurationFast:   150ms
animationDurationNormal: 300ms
animationDurationSlow:   500ms
```

### 커브
```dart
animationCurve:      Curves.easeOutCubic   // 일반적인 움직임
animationCurveSharp: Curves.easeOutExpo    // 강렬한 움직임
```

### 주요 애니메이션
- **카드 탭**: Scale (1.0 → 0.98) + Shadow offset 변화
- **페이지 전환**: Slide from right (easeOutCubic)
- **진입**: Staggered fade-up (index * 50ms delay)
- **탭 피드백**: 즉각적인 시각적 피드백 (150ms)

---

## 🔧 구현 파일 구조

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart              # 전역 테마 시스템
├── features/
    └── categories/
        └── presentation/
            ├── screens/
            │   └── categories_list_screen_brutalist.dart
            └── widgets/
                └── category_card_brutalist.dart
```

---

## 📱 사용 방법

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 앱 실행
```bash
flutter run
```

### 3. 주요 기능 테스트
- ✅ 카테고리 카드 탭 애니메이션
- ✅ 롱프레스 옵션 메뉴
- ✅ 카테고리 추가/편집/삭제
- ✅ 페이지 전환 애니메이션
- ✅ Brutalist 스낵바 알림

---

## 🚀 다음 단계 (선택사항)

현재 카테고리 화면의 디자인 시스템이 완성되었습니다.
동일한 Neo-Brutalist 디자인을 다른 화면에도 적용하려면:

1. **VideoListScreen** - 영상 목록 화면
2. **VideoCard** - 영상 카드
3. **Add/Edit Dialogs** - 추가/편집 다이얼로그

이들을 같은 디자인 언어로 재구성할 수 있습니다.

---

## 💡 디자인 토큰 (참고)

```dart
// Spacing
spacing-xs:   4px
spacing-sm:   8px
spacing-md:   12px
spacing-lg:   16px
spacing-xl:   20px
spacing-2xl:  24px
spacing-3xl:  32px

// Border Width
border-thin:  2px
border-thick: 3px
border-heavy: 4px

// Shadow
shadow-brutalist:       Offset(6, 6), blur: 0
shadow-brutalist-heavy: Offset(8, 8), blur: 0

// Border Radius
radius: 0 (모든 컴포넌트)
```

---

## 📝 주의사항

- 이 디자인은 **다크 테마 전용**으로 최적화되어 있습니다
- 한글 텍스트는 Noto Sans, 영문은 Space Grotesk 사용
- 모든 애니메이션은 성능 최적화됨 (GPU acceleration)
- 접근성: 높은 대비율 유지 (WCAG AA 이상)

---

**디자인 컨셉**: Neo-Brutalism + Digital Archive + Premium Tool
**색상 팔레트**: Electric Cyan + Neon Pink on Deep Charcoal
**타이포그래피**: Space Grotesk + Noto Sans + Roboto Mono
**애니메이션**: Sharp, Snappy, Intentional

Made with bold design decisions. 🔲⚡
