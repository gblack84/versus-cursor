# 🎨 Theme - 디자인 시스템

> Material Design 3 기반 통합 테마 시스템

## 개요

앱 전체의 시각적 일관성을 보장하는 중앙화된 디자인 시스템입니다. 색상, 타이포그래피, 간격, 컴포넌트 스타일을 체계적으로 관리합니다.

## 구조

```
theme/
├── app_theme.dart          # 메인 테마 설정
├── light_theme.dart        # 라이트 모드
├── dark_theme.dart         # 다크 모드
├── colors/                 # 색상 시스템
│   ├── app_colors.dart    # 색상 정의
│   └── color_schemes.dart # 색상 스키마
├── typography/             # 타이포그래피
│   ├── text_styles.dart   # 텍스트 스타일
│   └── font_families.dart # 폰트 패밀리
├── spacing/                # 간격 시스템
│   ├── spacing.dart       # 간격 상수
│   └── padding.dart       # 패딩 정의
├── components/             # 컴포넌트 테마
│   ├── button_theme.dart  # 버튼 테마
│   ├── card_theme.dart    # 카드 테마
│   └── input_theme.dart   # 입력 테마
└── README.md
```

## 주요 기능

### 1. 메인 테마 설정 (app_theme.dart)

**역할**: 테마 시스템 초기화 및 관리

**주요 기능**:
- 테마 모드 관리: system, light, dark 모드 지원
- 테마 초기화: SharedPreferences에서 저장된 테마 모드 로드
- 테마 저장: 사용자 선택 테마 모드 영구 저장
- 테마 접근자: 라이트/다크 테마 데이터 제공
- 동적 색상 접근: 현재 테마에 맞는 색상 반환

**ThemeMode 옵션**:
- system: 시스템 설정 따르기
- light: 라이트 모드 강제
- dark: 다크 모드 강제

### 2. 색상 시스템 (colors/app_colors.dart)

**역할**: 앱 전체 색상 팔레트 정의

**색상 카테고리**:

**Primary Colors** - Versus Space Red:
- primary: #E94B3C - 메인 브랜드 색상
- primaryLight: #FF6B5A - 밝은 변형
- primaryDark: #B73628 - 어두운 변형

**Secondary Colors** - Green:
- secondary: #4CAF50 - 보조 색상
- secondaryLight: #81C784 - 밝은 변형
- secondaryDark: #388E3C - 어두운 변형

**Tertiary Colors** - Beige:
- tertiary: #F5E6D3 - 제3색상
- tertiaryLight: #FFF8F0 - 밝은 변형
- tertiaryDark: #E8D4B8 - 어두운 변형

**Neutral Colors**:
- white부터 black까지 11단계 그레이 스케일
- gray50 (#FAFAFA) ~ gray900 (#212121)

**Semantic Colors**:
- success: #4CAF50 - 성공 상태
- warning: #FFC107 - 경고 상태
- error: #F44336 - 에러 상태
- info: #2196F3 - 정보 표시

### 3. 타이포그래피 (typography/text_styles.dart)

**역할**: 텍스트 스타일 체계 정의

**폰트 패밀리**:
- 주 폰트: SourGummy
- 보조 폰트: ReadexPro

**텍스트 스타일 계층**:

**Display** (대제목):
- displayLarge: 57pt, weight 400
- displayMedium: 45pt, weight 400
- displaySmall: 36pt, weight 400

**Headline** (제목):
- headlineLarge: 32pt, weight 600
- headlineMedium: 28pt, weight 600
- headlineSmall: 24pt, weight 600

**Title** (부제목):
- titleLarge: 22pt, weight 500
- titleMedium: 16pt, weight 500
- titleSmall: 14pt, weight 500

**Body** (본문):
- bodyLarge: 16pt, weight 400
- bodyMedium: 14pt, weight 400
- bodySmall: 12pt, weight 400

**Label** (레이블):
- labelLarge: 14pt, weight 500
- labelMedium: 12pt, weight 500
- labelSmall: 11pt, weight 500

### 4. 간격 시스템 (spacing/spacing.dart)

**역할**: 일관된 간격 체계 제공

**기본 단위**: 4px

**간격 스케일**:
- xs: 4px (1 unit)
- sm: 8px (2 units)
- md: 12px (3 units)
- lg: 16px (4 units)
- xl: 20px (5 units)
- xxl: 24px (6 units)
- xxxl: 32px (8 units)
- xxxxl: 48px (12 units)

**컴포넌트 간격**:
- buttonPadding: 16px
- cardPadding: 16px
- listItemPadding: 12px
- iconSize: 24px
- avatarSize: 48px

**레이아웃 간격**:
- screenPadding: 16px
- sectionSpacing: 32px
- itemSpacing: 12px

### 5. 컴포넌트 테마 (components/)

**역할**: UI 컴포넌트별 스타일 정의

**Button Theme** (button_theme.dart):
- ElevatedButton: 
  - 배경색: primary
  - elevation: 2
  - padding: horizontal 20px, vertical 12px
  - borderRadius: 8px
- TextButton:
  - 텍스트색: primary
  - padding: horizontal 16px, vertical 8px
- OutlinedButton:
  - 테두리색: primary
  - padding: horizontal 20px, vertical 12px
  - borderRadius: 8px

## 사용 방법

### 1. 테마 적용

**MaterialApp 설정**:
- theme: 라이트 테마 데이터
- darkTheme: 다크 테마 데이터
- themeMode: 현재 테마 모드

### 2. 색상 사용

**동적 색상** (테마 전환 자동 대응):
- AppColors.of(context): 현재 테마 색상 접근

**고정 색상** (테마와 무관):
- AppColors.error: 에러 색상 직접 사용

### 3. 타이포그래피 사용

**직접 사용**:
- AppTextStyles.headlineMedium: 스타일 직접 적용

**커스터마이징**:
- .copyWith(): 일부 속성만 변경

### 4. 간격 사용

**Padding**: EdgeInsets.all(AppSpacing.lg)
**SizedBox**: SizedBox(height: AppSpacing.md)
**Margin**: EdgeInsets.symmetric()

## 테마 전환

**테마 모드 변경**:
- Light ↔ Dark 토글
- System 모드로 전환
- SharedPreferences에 자동 저장

## 마이그레이션 체크리스트

- [ ] 하드코딩된 색상을 AppColors로 변경
- [ ] 인라인 TextStyle을 AppTextStyles로 변경
- [ ] 마법의 숫자를 AppSpacing으로 변경
- [ ] 커스텀 버튼 스타일을 테마로 통합
- [ ] 다크모드 대응 확인

## 주의사항

1. **동적 색상**: AppColors.of(context) 사용으로 테마 전환 자동 대응
2. **일관성**: 모든 UI 요소는 디자인 시스템 사용
3. **접근성**: 충분한 색상 대비 유지 (WCAG AA 기준)
4. **성능**: 테마 객체 재생성 최소화

---

*디자인 시스템 문서 - Feature-First Architecture*