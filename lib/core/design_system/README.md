# Common Design System

## 📋 개요
Versus Space 앱 전체에서 일관된 디자인 언어를 제공하는 디자인 시스템 컴포넌트들을 관리합니다.

## 🎯 역할
- **디자인 토큰 관리**: 색상, 타이포그래피, 간격, 반경 등의 디자인 변수
- **일관된 브랜딩**: 앱 전체에서 통일된 시각적 경험 제공
- **테마 시스템**: 라이트/다크 모드 지원 및 동적 테마 변경
- **디자인 가이드라인**: Material Design 3 기반의 커스텀 디자인 시스템

## 📁 파일 구조
```
presentation/
└── design_system/
    ├── tokens/
    │   # 실제 마이그레이션 파일 (from /design_system/tokens/)
    │   ├── versus_colors.dart
    │   ├── versus_spacing.dart
    │   ├── versus_text_styles.dart
    │   ├── versus_radius.dart
    │   ├── versus_icons.dart
    │   └── versus_icon_data.dart
    └── components/
        # 실제 마이그레이션 파일 (from /design_system/components/)
        ├── versus_button.dart
        ├── versus_dialog.dart
        ├── versus_text_field.dart
        └── versus_icon.dart
```

## 🚀 마이그레이션 대상

### 실제 이동할 파일
```bash
# 디자인 토큰 이동 (6개)
git mv lib/design_system/tokens/versus_colors.dart \
       lib/features/common/presentation/design_system/tokens/

git mv lib/design_system/tokens/versus_spacing.dart \
       lib/features/common/presentation/design_system/tokens/

git mv lib/design_system/tokens/versus_text_styles.dart \
       lib/features/common/presentation/design_system/tokens/

git mv lib/design_system/tokens/versus_radius.dart \
       lib/features/common/presentation/design_system/tokens/

git mv lib/design_system/tokens/versus_icons.dart \
       lib/features/common/presentation/design_system/tokens/

git mv lib/design_system/tokens/versus_icon_data.dart \
       lib/features/common/presentation/design_system/tokens/

# UI 컴포넌트 이동 (4개)
git mv lib/design_system/components/versus_button.dart \
       lib/features/common/presentation/design_system/components/

git mv lib/design_system/components/versus_dialog.dart \
       lib/features/common/presentation/design_system/components/

git mv lib/design_system/components/versus_text_field.dart \
       lib/features/common/presentation/design_system/components/

git mv lib/design_system/components/versus_icon.dart \
       lib/features/common/presentation/design_system/components/

# 유틸리티 이동 (1개)
git mv lib/design_system/utils/icon_style_manager.dart \
       lib/features/common/presentation/design_system/utils/
```

## 💻 디자인 토큰 사양

### 1. VersusColors
**역할**: 앱 전체 색상 팔레트 정의

**색상 카테고리**:
- **Primary Colors**: primary, primaryLight, primaryDark
- **Secondary Colors**: secondary, secondaryLight, secondaryDark
- **Neutral Colors**: neutral100 ~ neutral900 (9단계)
- **Semantic Colors**: success, warning, error, info
- **Surface Colors**: surface, surfaceVariant, background
- **Text Colors**: textPrimary, textSecondary, textDisabled, textInverse
- **VS Battle Colors**: vsRed, vsBlue, vsYellow

**그라디언트 정의**:
- `primaryGradient`: Primary 색상 그라디언트
- `vsGradient`: VS 대결 그라디언트 (빨강 → 파랑)

**ColorScheme Extensions**:
- `light()`: 라이트 모드 색상 스키마
- `dark()`: 다크 모드 색상 스키마

### 2. VersusTextStyles
**역할**: 타이포그래피 시스템 정의

**폰트 패밀리**: SourGummy

**텍스트 스타일 계층**:
- **Display**: displayLarge (57pt), displayMedium (45pt), displaySmall (36pt)
- **Headline**: headlineLarge (32pt), headlineMedium (28pt), headlineSmall (24pt)
- **Title**: titleLarge (22pt), titleMedium (16pt), titleSmall (14pt)
- **Body**: bodyLarge (16pt), bodyMedium (14pt), bodySmall (12pt)
- **Label**: labelLarge (14pt), labelMedium (12pt), labelSmall (11pt)

**커스텀 스타일**:
- `versus`: VS 대결용 특수 스타일 (48pt, 900 weight)
- `score`: 점수 표시용 스타일 (36pt, 700 weight)

### 3. VersusSpacing
**역할**: 일관된 간격 시스템 제공

**기본 단위**: 4px

**간격 스케일**:
- `xxxs`: 2px (0.5 unit)
- `xxs`: 4px (1 unit)
- `xs`: 8px (2 units)
- `sm`: 12px (3 units)
- `md`: 16px (4 units)
- `lg`: 20px (5 units)
- `xl`: 24px (6 units)
- `xxl`: 32px (8 units)
- `xxxl`: 40px (10 units)
- `xxxxl`: 48px (12 units)

**컴포넌트별 간격**:
- `buttonPaddingHorizontal`: 16px
- `buttonPaddingVertical`: 12px
- `cardPadding`: 16px
- `listItemSpacing`: 8px
- `sectionSpacing`: 32px

**페이지 여백**:
- `pagePaddingHorizontal`: 16px
- `pagePaddingVertical`: 20px

**반응형 간격**: `responsive()` 메서드로 화면 크기별 간격 조정

### 4. VersusRadius
**역할**: 모서리 둥글기 시스템 정의

**반경 값**:
- `none`: 0px
- `xs`: 4px
- `sm`: 8px
- `md`: 12px
- `lg`: 16px
- `xl`: 20px
- `xxl`: 24px
- `xxxl`: 32px
- `full`: 9999px (완전 둥근)

**컴포넌트별 반경**:
- `button`: 12px
- `card`: 16px
- `dialog`: 20px
- `bottomSheet`: 24px
- `avatar`: 완전 둥근
- `chip`: 완전 둥근
- `textField`: 8px

**특수 BorderRadius**:
- `topOnly`: 상단만 둥근 모서리
- `bottomOnly`: 하단만 둥근 모서리

### 5. VersusIcons
**역할**: 아이콘 시스템 관리

**아이콘 카테고리**:
- **Navigation**: home, search, add, profile, settings
- **Social**: like, unlike, comment, share, bookmark
- **Media**: play, pause, camera, gallery, video
- **Action**: edit, delete, close, check, more
- **VS Battle**: versus, voteA, voteB, timer, trophy
- **Notification**: notification, notificationActive, notificationOff

**유틸리티 메서드**:
- `getIconByName(name)`: 이름으로 아이콘 가져오기
- `styled()`: 스타일이 적용된 아이콘 생성
- `primary()`, `secondary()`, `error()`, `success()`: 의미별 아이콘 스타일

### 6. AppTheme
**역할**: 통합 테마 시스템

**테마 구성**:
- Material3 디자인 시스템 사용
- 라이트/다크 모드 지원
- 커스텀 컴포넌트 테마

**컴포넌트 테마**:
- `ElevatedButtonTheme`: 버튼 스타일
- `CardTheme`: 카드 스타일
- `InputDecorationTheme`: 입력 필드 스타일
- `AppBarTheme`: 앱바 스타일
- `BottomNavigationBarTheme`: 하단 네비게이션 스타일

## 🧪 테스트 전략

### 테마 테스트
- 라이트/다크 테마 생성 확인
- 색상 스키마 적용 확인
- 컴포넌트 테마 적용 확인

### 색상 대비 테스트
- WCAG AA 기준 충족 확인 (4.5:1 이상)
- 텍스트와 배경 색상 대비 검증
- 접근성 표준 준수 확인

### 반응형 테스트
- 다양한 화면 크기에서 간격 테스트
- 브레이크포인트별 스타일 변경 확인
- 반응형 타이포그래피 테스트

## ✅ 마이그레이션 체크리스트

### Phase 1: 토큰 마이그레이션
- [ ] VersusColors 마이그레이션
- [ ] VersusTextStyles 마이그레이션
- [ ] VersusSpacing 마이그레이션
- [ ] VersusRadius 마이그레이션
- [ ] VersusIcons 마이그레이션

### Phase 2: 테마 시스템
- [ ] AppTheme 구현
- [ ] LightTheme 구현
- [ ] DarkTheme 구현
- [ ] ThemeExtensions 구현

### Phase 3: 유틸리티
- [ ] ResponsiveUtils 구현
- [ ] ThemeProvider 구현
- [ ] ColorUtils 구현

### Phase 4: 테스트
- [ ] 테마 테스트 작성
- [ ] 색상 대비 테스트
- [ ] 반응형 테스트

## 📝 사용 가이드

### 색상 사용
```dart
// Primary 색상
Container(color: VersusColors.primary)

// Gradient
Container(decoration: BoxDecoration(gradient: VersusColors.primaryGradient))

// Semantic 색상
Icon(Icons.check, color: VersusColors.success)
```

### 타이포그래피 사용
```dart
// Headline
Text('제목', style: VersusTextStyles.headlineMedium)

// Body with color
Text('본문', style: VersusTextStyles.bodyMedium.copyWith(
  color: VersusColors.textSecondary,
))
```

### 간격 사용
```dart
// Padding
Padding(padding: VersusEdgeInsets.allMD)

// SizedBox
SizedBox(height: VersusSpacing.lg)

// Responsive spacing
VersusSpacing.responsive(base, mobile: sm, tablet: md, desktop: lg)
```

### 반경 사용
```dart
// Container with border radius
Container(decoration: BoxDecoration(borderRadius: VersusRadius.lg))

// Card with custom radius
Card(shape: VersusRadius.roundedRectangle(VersusRadius.card))
```

### 테마 적용
```dart
MaterialApp(
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
)
```

---

*Common Design System은 앱 전체에서 일관된 디자인 언어를 제공합니다.*
*최종 업데이트: 2025-08-25*