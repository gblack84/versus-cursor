# 📨 Core Theme 레이어

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Theme는 애플리케이션의 테마 시스템을 관리하는 레이어입니다. Light/Dark 모드 지원, 색상 시스템, 타이포그래피, 테마 지속성을 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/theme/
└── app_theme.dart          # 395줄 - 통합 테마 시스템

총 1개 파일, 395줄
```

## 🔍 현재 코드 분석

### 1. app_theme.dart (395줄)

#### 핵심 구성요소

**AppTheme 추상 클래스**:
```dart
abstract class AppTheme {
  static Future initialize() async
  static ThemeMode get themeMode
  static void saveThemeMode(ThemeMode mode)
  static AppTheme of(BuildContext context)
  
  // 색상 시스템
  late Color primary;
  late Color secondary;
  late Color tertiary;
  // ... 16개 색상 속성
  
  // Typography 접근자
  Typography get typography => ThemeTypography(this);
}
```

**주요 기능**:
- SharedPreferences를 통한 테마 모드 저장/복원
- Light/Dark 모드 전환 지원
- 16가지 색상 팔레트
- Material 3 Typography 시스템
- Deprecated 속성으로 레거시 호환성

**LightModeTheme 클래스**:
```dart
class LightModeTheme extends AppTheme {
  // 밝은 테마 색상 정의
  late Color primary = const Color(0xFFD95B5B);  // 빨간색
  late Color secondary = const Color(0xFF588157); // 초록색
  // ... 14개 추가 색상
}
```

**DarkModeTheme 클래스**:
```dart
class DarkModeTheme extends AppTheme {
  // 어두운 테마 색상 정의
  late Color primary = const Color(0xFF4B39EF);   // 파란색
  late Color secondary = const Color(0xFF39D2C0); // 청록색
  // ... 14개 추가 색상
}
```

**ThemeTypography 클래스**:
```dart
class ThemeTypography extends Typography {
  // Google Fonts - Plus Jakarta Sans
  // 13가지 텍스트 스타일 정의
  // display, headline, title, label, body 각각 large/medium/small
}
```

**TextStyleHelper Extension**:
```dart
extension TextStyleHelper on TextStyle {
  TextStyle override({...}) // 텍스트 스타일 커스터마이징
}
```

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **단일 파일 집중**: 모든 테마 로직이 한 파일에 집중
- **불완전한 구현**: DarkModeTheme이 Typography를 재정의하지 않음
- **확장성 부족**: 새로운 테마 추가가 어려운 구조

### 2. 아키텍처 문제
- **직접적인 의존성**: SharedPreferences를 직접 사용 (Service 레이어 없음)
- **하드코딩**: 색상 값들이 코드에 하드코딩
- **토큰 시스템 부재**: Design Token 개념 미적용

### 3. 유지보수 문제
- **색상 일관성**: 색상 팔레트 관리 체계 부재
- **테마 확장**: 브랜드별 테마나 계절 테마 추가 어려움
- **테스트 어려움**: 정적 메서드와 싱글톤 패턴으로 테스트 복잡

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조

```
lib/
├── core/
│   └── design_system/         # 순수 디자인 시스템
│       ├── tokens/            # Design Tokens
│       │   ├── color_tokens.dart
│       │   ├── typography_tokens.dart
│       │   └── spacing_tokens.dart
│       └── foundation/        # 기본 요소
│           ├── colors.dart
│           └── typography.dart
│
├── features/
│   └── theme/                 # Theme Feature
│       ├── domain/
│       │   ├── models/
│       │   │   └── theme_mode.dart
│       │   └── repositories/
│       │       └── theme_repository.dart
│       ├── data/
│       │   ├── repositories/
│       │   │   └── theme_repository_impl.dart
│       │   └── services/
│       │       └── theme_persistence_service.dart
│       └── presentation/
│           ├── providers/
│           │   └── theme_provider.dart
│           └── widgets/
│               └── theme_mode_toggle.dart
│
└── shared/
    └── theme/
        ├── app_theme.dart      # 앱 전체 테마 정의
        ├── light_theme.dart
        └── dark_theme.dart
```

### 2. Design Token 시스템

```dart
// core/design_system/tokens/color_tokens.dart
abstract class ColorTokens {
  // Semantic Tokens
  static const primary = Color(0xFFD95B5B);
  static const secondary = Color(0xFF588157);
  static const error = Color(0xFFFF5963);
  static const warning = Color(0xFFF9CF58);
  static const success = Color(0xFF249689);
  
  // Primitive Tokens
  static const red50 = Color(0xFFFEE2E2);
  static const red500 = Color(0xFFD95B5B);
  static const red900 = Color(0xFF7F1D1D);
}

// core/design_system/tokens/typography_tokens.dart
abstract class TypographyTokens {
  static const fontFamily = 'Plus Jakarta Sans';
  
  static const displayLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w600,
  );
}
```

### 3. Theme Service 패턴

```dart
// features/theme/domain/repositories/theme_repository.dart
abstract class ThemeRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
  Stream<ThemeMode> watchThemeMode();
}

// features/theme/presentation/providers/theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  final ThemeRepository repository;
  
  ThemeMode _mode = ThemeMode.system;
  
  ThemeProvider(this.repository);
  
  Future<void> initialize() async {
    _mode = await repository.getThemeMode();
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    repository.saveThemeMode(mode);
    notifyListeners();
  }
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|----------|----------|--------|--------|
| Design Token 시스템 구축 | 🔴 매우 높음 | 1일 | 중간 | 매우 높음 |
| Theme Provider 구현 | 🔴 매우 높음 | 0.5일 | 낮음 | 높음 |
| 색상 시스템 분리 | 🟡 중간 | 0.5일 | 낮음 | 중간 |
| Typography 시스템 개선 | 🟡 중간 | 0.5일 | 낮음 | 중간 |
| 테스트 작성 | 🟢 낮음 | 0.5일 | 낮음 | 높음 |

## 🚀 구현 로드맵

### Phase 1: Design Token 시스템 (1일)
- Color Tokens 정의
- Typography Tokens 정의
- Spacing Tokens 정의
- Foundation 레이어 구축

### Phase 2: Theme Feature 모듈 (0.5일)
- Repository 패턴 구현
- Provider 구현
- Service 레이어 추가

### Phase 3: 마이그레이션 (0.5일)
- 기존 AppTheme 리팩토링
- 의존성 업데이트
- 테스트 작성

## 💡 주요 개선 제안

### 1. Design System 구축
```dart
// 토큰 기반 시스템
class DesignSystem {
  static const colors = ColorTokens();
  static const typography = TypographyTokens();
  static const spacing = SpacingTokens();
  static const radius = RadiusTokens();
}
```

### 2. 테마 확장성
```dart
// 커스텀 테마 지원
abstract class CustomTheme {
  ThemeData build();
}

class BrandTheme extends CustomTheme {
  @override
  ThemeData build() {
    // 브랜드별 테마
  }
}
```

### 3. 동적 테마
```dart
// 시간대별 테마
class AdaptiveTheme {
  ThemeMode getThemeByTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 18) {
      return ThemeMode.light;
    }
    return ThemeMode.dark;
  }
}
```

## 🔗 연관 파일 및 의존성

### 현재 의존 관계
- **사용처**: 모든 UI 위젯이 AppTheme 사용
- **의존성**: SharedPreferences, GoogleFonts
- **영향 범위**: 앱 전체 UI

### 리팩토링 후 의존 관계
- **Core → 없음** (독립적인 Design System)
- **Features → Core** (Design Tokens 사용)
- **Shared → Features** (Theme Provider 사용)

## ⚡ 성능 고려사항

1. **테마 전환 성능**: Provider 패턴으로 효율적인 리빌드
2. **메모리 사용**: 색상 상수화로 메모리 절약
3. **폰트 로딩**: Google Fonts 캐싱 최적화

## 🚨 주의사항

1. **Breaking Changes**: 모든 위젯이 AppTheme 의존
2. **마이그레이션 순서**: Design System → Theme Feature → UI 업데이트
3. **테스트**: 테마 전환 시 모든 화면 테스트 필요

## 📋 체크리스트

### 즉시 수정 필요
- [ ] DarkModeTheme Typography 구현
- [ ] SharedPreferences 직접 사용 제거
- [ ] 색상 하드코딩 제거

### 단기 목표 (1주일)
- [ ] Design Token 시스템 구축
- [ ] Theme Provider 구현
- [ ] 테스트 작성

### 장기 목표 (1개월)
- [ ] 완전한 Design System 구축
- [ ] 동적 테마 지원
- [ ] 접근성 개선

## 사용 예시

### 현재 사용법
```dart
// 테마 색상 사용
final color = AppTheme.of(context).primary;

// 텍스트 스타일 사용
Text(
  'Title',
  style: AppTheme.of(context).titleLarge,
);
```

### 개선된 사용법 (제안)
```dart
// Design Token 사용
final color = DesignSystem.colors.primary;

// Theme Provider 사용
Consumer<ThemeProvider>(
  builder: (context, theme, child) {
    return Text(
      'Title',
      style: theme.typography.titleLarge,
    );
  },
);

// 테마 전환
context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
```

---

*이 문서는 Core Theme 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*Design System 구축과 Theme Feature 분리가 시급합니다.*