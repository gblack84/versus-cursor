# 📋 Core Design System 마이그레이션 계획 (Part 3)

> 작성일: 2025-08-28 | 대상: Core Design System 레이어 | 예상 기간: 2주

## 🎯 마이그레이션 목표

Core Design System을 Feature-First Architecture에 맞게 재구조화하여:
- ✅ Core는 토큰만 유지, 컴포넌트는 Shared로 분리
- ✅ Theme Extension 기반 동적 테마 시스템
- ✅ Material 3 디자인 가이드라인 준수
- ✅ Feature별 커스터마이징 가능한 구조

## 📊 현재 상태 분석

### 📁 현재 구조
```
lib/core/design_system/
├── tokens/        # 556줄 - 유지 및 개선
├── components/    # 1,071줄 - Shared로 이동
└── utils/         # 62줄 - 적절한 위치로 재배치
```

### 🔍 식별된 문제점
1. **구조적 문제** - Core에 UI 컴포넌트 포함 (Feature 독립성 위반)
2. **테마 시스템** - 정적 클래스로만 구성 (동적 변경 불가)
3. **파일 크기** - 일부 컴포넌트 너무 큼 (405줄, 346줄)
4. **테스트 부재** - 디자인 시스템 테스트 없음

## 📈 마이그레이션 전략

### 🏗️ 목표 구조
```
lib/
├── core/
│   └── design_system/
│       ├── tokens/                      # 토큰만 유지
│       │   ├── theme/
│       │   │   ├── app_theme.dart      # Material 3 테마
│       │   │   ├── theme_extensions.dart
│       │   │   └── theme_provider.dart
│       │   ├── colors/
│       │   │   ├── color_tokens.dart
│       │   │   └── color_schemes.dart
│       │   ├── typography/
│       │   │   ├── text_tokens.dart
│       │   │   └── text_themes.dart
│       │   ├── spacing/
│       │   │   └── spacing_tokens.dart
│       │   └── design_tokens.dart       # 통합 export
│       │
│       └── index.dart
│
├── shared/
│   └── widgets/
│       ├── buttons/
│       │   ├── app_button.dart         # 기본 버튼
│       │   ├── icon_button.dart
│       │   └── button_styles.dart
│       ├── dialogs/
│       │   ├── app_dialog.dart
│       │   ├── confirmation_dialog.dart
│       │   └── alert_dialog.dart
│       ├── inputs/
│       │   ├── app_text_field.dart
│       │   ├── app_form_field.dart
│       │   └── input_decorations.dart
│       └── index.dart
│
└── features/
    └── [feature_name]/
        └── presentation/
            └── widgets/             # Feature 특화 컴포넌트
```

## 🔄 마이그레이션 단계

### Phase 1: Theme Extension 구현 (Day 1-2)

#### 1.1 색상 Theme Extension 생성
```dart
// lib/core/design_system/tokens/theme/color_extension.dart
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color onError;
  
  const AppColorScheme({
    required this.primary,
    required this.secondary,
    // ...
  });
  
  static const light = AppColorScheme(
    primary: Color(0xFFD95B5B),
    secondary: Color(0xFF588157),
    // ...
  );
  
  static const dark = AppColorScheme(
    primary: Color(0xFF4B39EF),
    secondary: Color(0xFF39D2C0),
    // ...
  );
  
  @override
  ThemeExtension<AppColorScheme> copyWith({...}) {...}
  
  @override
  ThemeExtension<AppColorScheme> lerp(
    covariant ThemeExtension<AppColorScheme>? other,
    double t,
  ) {...}
}
```

#### 1.2 간격 Theme Extension 생성
```dart
// lib/core/design_system/tokens/theme/spacing_extension.dart
@immutable
class AppSpacingTheme extends ThemeExtension<AppSpacingTheme> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  
  const AppSpacingTheme({
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 20.0,
    this.xl = 32.0,
  });
  
  EdgeInsets get paddingXS => EdgeInsets.all(xs);
  EdgeInsets get paddingSM => EdgeInsets.all(sm);
  // ...
}
```

#### 1.3 타이포그래피 Theme Extension 생성
```dart
// lib/core/design_system/tokens/theme/typography_extension.dart
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle headingSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  
  const AppTypography({
    required this.headingLarge,
    required this.headingMedium,
    // ...
  });
}
```

#### 1.4 통합 Theme 생성
- [ ] Material 3 기반 AppTheme 클래스
- [ ] Light/Dark 테마 정의
- [ ] ThemeProvider 구현
- [ ] 기존 코드와 호환성 레이어

### Phase 2: 컴포넌트 이동 (Day 3-4)

#### 2.1 디렉토리 생성
```bash
mkdir -p lib/shared/widgets/{buttons,dialogs,inputs,feedback}
```

#### 2.2 컴포넌트 분리 및 이동
- [ ] VersusButton → shared/widgets/buttons/app_button.dart
- [ ] VersusDialog → shared/widgets/dialogs/ (분할)
- [ ] VersusTextField → shared/widgets/inputs/ (분할)
- [ ] VersusIcon → shared/widgets/icons/

#### 2.3 의존성 업데이트
```dart
// 기존
import '/core/design_system/components/versus_button.dart';

// 변경
import '/shared/widgets/buttons/app_button.dart';
```

#### 2.4 호환성 레이어
```dart
// 임시 호환성 파일 (점진적 제거)
// lib/core/design_system/components/versus_button.dart
@Deprecated('Use AppButton from shared/widgets instead')
export '/shared/widgets/buttons/app_button.dart' 
  show AppButton as VersusButton;
```

### Phase 3: 대형 컴포넌트 분할 (Day 5-6)

#### 3.1 VersusTextField 분할 (405줄 → 여러 파일)
- [ ] BaseTextField (100줄)
- [ ] EmailField (50줄)
- [ ] PasswordField (80줄)
- [ ] MultilineField (50줄)
- [ ] ValidationHelpers (50줄)
- [ ] Decorations (75줄)

#### 3.2 VersusDialog 분할 (346줄 → 여러 파일)
- [ ] BaseDialog (80줄)
- [ ] WarningDialog (60줄)
- [ ] ErrorDialog (60줄)
- [ ] SuccessDialog (60줄)
- [ ] CustomDialog (86줄)

### Phase 4: Material 3 통합 (Day 7-8)

#### 4.1 Theme 구성
```dart
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD95B5B),
        brightness: Brightness.light,
      ),
      extensions: [
        AppColorScheme.light,
        AppSpacingTheme.standard,
        AppTypography.standard,
      ],
    );
  }
  
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4B39EF),
        brightness: Brightness.dark,
      ),
      extensions: [
        AppColorScheme.dark,
        AppSpacingTheme.standard,
        AppTypography.standard,
      ],
    );
  }
}
```

#### 4.2 사용법 변경
```dart
// 기존
Container(color: VersusColors.primary)

// 변경
Container(color: Theme.of(context).extension<AppColorScheme>()!.primary)

// 헬퍼 Extension 추가
extension ThemeExtensions on BuildContext {
  AppColorScheme get colors => 
    Theme.of(this).extension<AppColorScheme>()!;
  AppSpacingTheme get spacing => 
    Theme.of(this).extension<AppSpacingTheme>()!;
  AppTypography get typography => 
    Theme.of(this).extension<AppTypography>()!;
}

// 간편 사용
Container(color: context.colors.primary)
```

### Phase 5: 테스트 구현 (Day 9-10)

#### 5.1 토큰 테스트
- [ ] 색상 대비 테스트 (WCAG AA 기준)
- [ ] 간격 일관성 테스트
- [ ] 타이포그래피 계층 테스트

#### 5.2 컴포넌트 테스트
- [ ] 버튼 상태별 테스트
- [ ] 다이얼로그 동작 테스트
- [ ] 입력 필드 유효성 테스트

#### 5.3 테마 테스트
- [ ] Light/Dark 테마 전환
- [ ] Theme Extension 동작
- [ ] Material 3 호환성

### Phase 6: 문서화 (Day 11-12)

#### 6.1 Storybook 스타일 문서
- [ ] 컴포넌트 갤러리 생성
- [ ] 인터랙티브 예제
- [ ] 사용 가이드라인

#### 6.2 마이그레이션 가이드
- [ ] Breaking Changes 목록
- [ ] 코드 변경 예제
- [ ] FAQ

### Phase 7: 배포 (Day 13-14)

#### 7.1 점진적 마이그레이션
- [ ] Feature별 순차 적용
- [ ] 호환성 레이어 유지
- [ ] 성능 모니터링

#### 7.2 정리 작업
- [ ] Deprecated 코드 제거
- [ ] 임시 파일 정리
- [ ] 최종 테스트

## 📋 체크리스트

### 🔴 즉시 작업 (Day 1-2)
- [ ] Theme Extension 구조 생성
- [ ] AppColorScheme 구현
- [ ] AppSpacingTheme 구현
- [ ] AppTypography 구현

### 🟡 단기 작업 (Day 3-6)
- [ ] shared/widgets 디렉토리 생성
- [ ] 컴포넌트 이동 시작
- [ ] 대형 파일 분할
- [ ] 의존성 업데이트

### 🟢 중기 작업 (Day 7-10)
- [ ] Material 3 통합
- [ ] 테스트 작성
- [ ] 성능 최적화

### 🔵 장기 작업 (Day 11-14)
- [ ] 문서화 완성
- [ ] 마이그레이션 가이드
- [ ] 배포 및 모니터링

## 🚀 실행 계획

### Week 1: 기반 구축
```bash
# Day 1-2: Theme Extension
touch lib/core/design_system/tokens/theme/{app_theme,color_extension,spacing_extension,typography_extension}.dart

# Day 3-4: 구조 이동
mkdir -p lib/shared/widgets/{buttons,dialogs,inputs}
git mv lib/core/design_system/components/* lib/shared/widgets/

# Day 5-6: 파일 분할
# 대형 컴포넌트 분할 작업
```

### Week 2: 통합 및 배포
```bash
# Day 7-8: Material 3
# Theme 통합 및 테스트

# Day 9-10: 테스트
flutter test lib/core/design_system/
flutter test lib/shared/widgets/

# Day 11-12: 문서화
# Storybook 스타일 문서 생성

# Day 13-14: 배포
# 점진적 마이그레이션
```

## ⚠️ 위험 요소 및 대응 방안

### 위험 1: Breaking Changes
- **위험도**: 매우 높음
- **영향**: 20+ Feature 파일
- **대응**: 
  - 호환성 레이어 제공
  - @Deprecated 어노테이션 활용
  - 점진적 마이그레이션

### 위험 2: 테마 전환 버그
- **위험도**: 중간
- **영향**: UI 일관성
- **대응**:
  - 충분한 테스트
  - A/B 테스트
  - 롤백 계획

### 위험 3: 성능 저하
- **위험도**: 낮음
- **영향**: 앱 성능
- **대응**:
  - 프로파일링
  - 트리 쉐이킹
  - 코드 스플리팅

## 📊 예상 효과

### 정량적 효과
- 코드 재사용성 40% 향상
- 개발 속도 30% 개선
- 버그 발생률 25% 감소
- 번들 크기 15% 감소 (트리 쉐이킹)

### 정성적 효과
- Feature 독립성 확보
- 테마 변경 유연성
- 유지보수성 향상
- 개발자 경험 개선

## 📝 참고 자료

- [Material 3 Design Guidelines](https://m3.material.io)
- [Flutter Theme Extension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- [Atomic Design Methodology](https://atomicdesign.bradfrost.com)
- [Flutter Testing Best Practices](https://flutter.dev/docs/testing)

---

*이 문서는 Core Design System의 Feature-First Architecture 마이그레이션 계획입니다.*
*2주간의 체계적인 전환으로 현대적이고 확장 가능한 디자인 시스템을 구축합니다.*