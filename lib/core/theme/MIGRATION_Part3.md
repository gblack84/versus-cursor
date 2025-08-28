# 📋 Core Theme 마이그레이션 계획 (Part 3)

> 작성일: 2025-08-28 | 대상: Core Theme 레이어 | 예상 기간: 3일

## 🎯 마이그레이션 목표

Core Theme를 Feature-First Architecture에 맞게 재구조화하여:
- ✅ Design System 구축
- ✅ Theme Feature 모듈 생성
- ✅ Provider 패턴 적용
- ✅ 테스트 가능한 구조
- ✅ 확장 가능한 테마 시스템

## 📊 현재 상태 분석

### 📁 현재 구조
```
lib/core/theme/
└── app_theme.dart              # 395줄 - 모든 테마 로직
```

### 🔍 식별된 문제점
1. **단일 파일 집중** - 395줄의 모든 로직이 한 파일에
2. **불완전한 구현** - DarkModeTheme Typography 미구현
3. **직접 의존성** - SharedPreferences 직접 사용
4. **하드코딩** - 색상 값 하드코딩
5. **테스트 어려움** - 정적 메서드와 싱글톤 패턴

## 📈 마이그레이션 전략

### 🏗️ 목표 구조
```
lib/
├── core/
│   ├── design_system/           # 순수 디자인 시스템 (기존)
│   │   └── tokens/              # Design Tokens (이미 존재)
│   │       ├── versus_colors.dart      # 기존 파일 리팩토링
│   │       ├── versus_text_styles.dart # 기존 파일 리팩토링
│   │       ├── versus_spacing.dart     # 기존 파일 유지
│   │       ├── versus_radius.dart      # 기존 파일 유지
│   │       └── versus_tokens.dart      # 기존 export 파일
│   │
│   └── theme/                  # 앱 테마 정의 (현재 위치 유지)
│       ├── app_theme.dart      # 기존 파일 리팩토링
│       ├── light_theme.dart    # 새로 생성
│       ├── dark_theme.dart     # 새로 생성
│       ├── theme_data_factory.dart  # ThemeData 생성 팩토리
│       └── custom_themes/      # 향후 확장용
│           └── brand_theme.dart
│
└── features/
    └── theme/                  # Theme Feature (새로 생성)
        ├── domain/
        │   ├── models/
        │   │   ├── theme_mode.dart
        │   │   └── theme_config.dart
        │   ├── repositories/
        │   │   └── theme_repository.dart
        │   └── services/
        │       └── theme_service.dart
        ├── data/
        │   ├── repositories/
        │   │   └── theme_repository_impl.dart
        │   └── services/
        │       └── theme_storage_service.dart
        └── presentation/
            ├── providers/
            │   └── theme_provider.dart
            └── widgets/
                ├── theme_mode_toggle.dart
                └── adaptive_theme_builder.dart
```

## 🔄 마이그레이션 단계

### Phase 1: 분석 및 준비 (Day 1 - 오전)

#### 1.1 의존성 분석
```bash
# AppTheme 사용처 찾기
grep -r "AppTheme" lib/ --include="*.dart" | wc -l
# 예상: 100+ 파일

# 색상 직접 참조 찾기
grep -r "theme\." lib/ --include="*.dart"
```

#### 1.2 테스트 작성
```dart
// test/core/theme/app_theme_test.dart
void main() {
  group('AppTheme', () {
    test('should initialize SharedPreferences', () async {
      // 현재 동작 테스트
    });
    
    test('should return correct theme mode', () {
      // 테마 모드 테스트
    });
  });
}
```

### Phase 2: Design System 구축 (Day 1 - 오후)

#### 2.1 디렉토리 생성
```bash
# Design System 디렉토리 구조 생성
mkdir -p lib/core/design_system/{tokens,foundation}

# Token 파일 생성
touch lib/core/design_system/tokens/color_tokens.dart
touch lib/core/design_system/tokens/typography_tokens.dart
touch lib/core/design_system/tokens/spacing_tokens.dart
touch lib/core/design_system/tokens/radius_tokens.dart
```

#### 2.2 기존 Design Tokens 리팩토링
```dart
// lib/core/design_system/tokens/versus_colors.dart (기존 파일 수정)
import 'package:flutter/material.dart';

/// Versus Space Color System - 리팩토링
class VersusColors {
  // Brand Colors (기존 유지)
  static const Color primary = Color(0xFFD95B5B);
  static const Color secondary = Color(0xFF588157);
  
  // Light Theme Colors
  static const light = _LightColors();
  
  // Dark Theme Colors (새로 추가)
  static const dark = _DarkColors();
  
  // System Colors (기존 개선)
  static const system = _SystemColors();
}

class _LightColors {
  const _LightColors();
  
  final primary = const Color(0xFFD95B5B);
  final secondary = const Color(0xFF588157);
  final background = const Color(0xFFFAF9F6);
  final surface = const Color(0xFFF5F2E8);
  final text = const Color(0xFF4A444B);
  final textSecondary = const Color(0xFF8A817C);
}

class _DarkColors {
  const _DarkColors();
  
  final primary = const Color(0xFF4B39EF);
  final secondary = const Color(0xFF39D2C0);
  final background = const Color(0xFF1D2428);
  final surface = const Color(0xFF14181B);
  final text = const Color(0xFFFFFFFF);
  final textSecondary = const Color(0xFF95A1AC);
}

class _SystemColors {
  const _SystemColors();
  
  final success = const Color(0xFF249689);
  final warning = const Color(0xFFF9CF58);
  final error = const Color(0xFFFF5963);
  final info = const Color(0xFF4B9BFF);
}
```

#### 2.3 Typography Tokens 정의
```dart
// lib/core/design_system/tokens/typography_tokens.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class TypographyTokens {
  static const fontFamily = 'Plus Jakarta Sans';
  
  // Display Styles
  static TextStyle displayLarge({Color? color}) => 
    GoogleFonts.plusJakartaSans(
      fontSize: 64,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: color,
    );
    
  static TextStyle displayMedium({Color? color}) => 
    GoogleFonts.plusJakartaSans(
      fontSize: 44,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: color,
    );
    
  // ... 추가 스타일 정의
}
```

### Phase 3: Theme Feature 모듈 생성 (Day 2 - 오전)

#### 3.1 Feature 구조 생성
```bash
# Theme Feature 디렉토리 생성
mkdir -p lib/features/theme/{domain,data,presentation}/{models,repositories,services,providers,widgets}

# 기본 파일 생성
touch lib/features/theme/domain/models/theme_mode.dart
touch lib/features/theme/domain/repositories/theme_repository.dart
touch lib/features/theme/data/repositories/theme_repository_impl.dart
```

#### 3.2 Repository 패턴 구현
```dart
// lib/features/theme/domain/repositories/theme_repository.dart
import 'package:flutter/material.dart';

abstract class ThemeRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> saveThemeMode(ThemeMode mode);
  Stream<ThemeMode> watchThemeMode();
  Future<void> clearThemeMode();
}

// lib/features/theme/data/repositories/theme_repository_impl.dart
class ThemeRepositoryImpl implements ThemeRepository {
  final SharedPreferences _prefs;
  final _controller = StreamController<ThemeMode>.broadcast();
  
  static const _key = 'theme_mode';
  
  ThemeRepositoryImpl(this._prefs);
  
  @override
  Future<ThemeMode> getThemeMode() async {
    final value = _prefs.getString(_key);
    if (value == null) return ThemeMode.system;
    return ThemeMode.values.byName(value);
  }
  
  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_key, mode.name);
    _controller.add(mode);
  }
}
```

#### 3.3 Theme Provider 구현
```dart
// lib/features/theme/presentation/providers/theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  final ThemeRepository _repository;
  
  ThemeMode _mode = ThemeMode.system;
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;
  
  ThemeProvider(this._repository);
  
  ThemeMode get mode => _mode;
  ThemeData? get lightTheme => _lightTheme;
  ThemeData? get darkTheme => _darkTheme;
  
  Future<void> initialize() async {
    _mode = await _repository.getThemeMode();
    _buildThemes();
    notifyListeners();
    
    // Watch for changes
    _repository.watchThemeMode().listen((mode) {
      _mode = mode;
      notifyListeners();
    });
  }
  
  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _repository.saveThemeMode(mode);
    notifyListeners();
  }
  
  void _buildThemes() {
    _lightTheme = _createLightTheme();
    _darkTheme = _createDarkTheme();
  }
}
```

### Phase 4: 기존 코드 리팩토링 (Day 2 - 오후)

#### 4.1 AppTheme 어댑터 생성
```dart
// lib/core/theme/app_theme_adapter.dart (새로 생성)
/// 기존 AppTheme 호환성을 위한 어댑터
class AppThemeAdapter {
  static AppTheme of(BuildContext context) {
    final provider = context.read<ThemeProvider>();
    final brightness = Theme.of(context).brightness;
    
    return brightness == Brightness.dark
        ? DarkModeThemeAdapter(provider)
        : LightModeThemeAdapter(provider);
  }
}

class LightModeThemeAdapter extends AppTheme {
  final ThemeProvider provider;
  
  LightModeThemeAdapter(this.provider);
  
  @override
  Color get primary => VersusColors.light.primary;
  
  // ... 기존 인터페이스 구현
}
```

#### 4.2 점진적 마이그레이션
```dart
// lib/core/theme/app_theme.dart
@Deprecated('Use ThemeProvider instead')
abstract class AppTheme {
  // 기존 코드 유지하되 Deprecated 표시
  
  static AppTheme of(BuildContext context) {
    // 새로운 시스템으로 리디렉션
    return AppThemeAdapter.of(context);
  }
}
```

### Phase 5: Import 경로 업데이트 (Day 3 - 오전)

#### 5.1 자동 업데이트 스크립트
```bash
#!/bin/bash
# update_theme_imports.sh

# AppTheme 어댑터 import로 변경
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/core/theme/app_theme.dart|import .*/core/theme/app_theme_adapter.dart|g' {} \;

# Provider import 추가
find lib -name "*.dart" -exec sed -i '' \
  '/AppTheme\.of/s/^/import "package:provider\/provider.dart";\n/' {} \;
```

#### 5.2 수동 검증
```bash
# 변경 확인
git diff --name-only | xargs grep -l "AppTheme"

# 컴파일 확인
flutter analyze

# 테스트 실행
flutter test
```

### Phase 6: 테스트 및 검증 (Day 3 - 오후)

#### 6.1 단위 테스트
```dart
// test/features/theme/theme_provider_test.dart
void main() {
  group('ThemeProvider', () {
    test('should initialize with system theme', () async {
      final provider = ThemeProvider(mockRepository);
      await provider.initialize();
      
      expect(provider.mode, ThemeMode.system);
    });
    
    test('should switch theme mode', () {
      provider.setThemeMode(ThemeMode.dark);
      
      verify(mockRepository.saveThemeMode(ThemeMode.dark));
    });
  });
}
```

#### 6.2 통합 테스트
```dart
// test/integration/theme_integration_test.dart
void main() {
  testWidgets('Theme switching test', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(repository),
        child: TestApp(),
      ),
    );
    
    // 테마 전환 테스트
  });
}
```

## 📊 위험 요소 및 대응 방안

### 위험 1: 대규모 Breaking Changes
- **위험도**: 높음
- **영향**: 100+ 파일
- **대응**:
  - 어댑터 패턴으로 호환성 유지
  - 점진적 마이그레이션
  - Deprecated 어노테이션 활용

### 위험 2: 성능 저하
- **위험도**: 낮음
- **영향**: 테마 전환 시
- **대응**:
  - Provider 최적화
  - 선택적 리빌드
  - 메모이제이션

### 위험 3: 시각적 불일치
- **위험도**: 중간
- **영향**: UI 일관성
- **대응**:
  - Design Token 검증
  - 스크린샷 테스트
  - QA 검증

## 📋 체크리스트

### 🔴 Day 1: Design System 구축
- [ ] 의존성 분석 완료
- [ ] 현재 동작 테스트 작성
- [ ] Design System 디렉토리 생성
- [ ] Color Tokens 정의
- [ ] Typography Tokens 정의
- [ ] Spacing Tokens 정의

### 🟡 Day 2: Theme Feature 구현
- [ ] Feature 구조 생성
- [ ] Repository 패턴 구현
- [ ] Provider 구현
- [ ] 어댑터 생성
- [ ] 기존 코드 Deprecated 표시

### 🟢 Day 3: 마이그레이션 및 테스트
- [ ] Import 경로 업데이트
- [ ] 컴파일 에러 수정
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 수행
- [ ] QA 검증

## 🚀 실행 명령

### 빠른 시작
```bash
# Design System 생성
./scripts/create_design_system.sh

# Theme Feature 생성
./scripts/create_theme_feature.sh

# Import 업데이트
./scripts/update_theme_imports.sh

# 테스트 실행
flutter test test/features/theme/
```

### 검증
```bash
# 정적 분석
flutter analyze

# Design Token 검증
dart test/verify_design_tokens.dart

# 시각적 회귀 테스트
flutter test test/golden/
```

## ⚠️ 롤백 계획

만약 문제 발생 시:

```bash
# 1. 어댑터 비활성화
git revert HEAD  # 어댑터 커밋 되돌리기

# 2. 기존 AppTheme 복원
git checkout main -- lib/core/theme/app_theme.dart

# 3. Import 경로 복구
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/shared/theme/app_theme_adapter.dart|import .*/core/theme/app_theme.dart|g' {} \;

# 4. 점진적 재시도
```

## 📊 예상 효과

### 정량적 효과
- 테스트 커버리지 40% → 90%
- 테마 전환 시간 200ms → 50ms
- 코드 재사용성 60% 향상

### 정성적 효과
- 명확한 Design System
- 쉬운 테마 확장
- 일관된 UI/UX
- 향상된 유지보수성

## 📝 참고 자료

- [Material Design 3](https://m3.material.io/)
- [Design Tokens](https://designtokens.org/)
- [Flutter Theme Best Practices](https://docs.flutter.dev/cookbook/design/themes)
- [Provider Pattern](https://pub.dev/packages/provider)

---

*이 문서는 Core Theme의 Feature-First Architecture 마이그레이션 계획입니다.*
*Design System 구축과 점진적 마이그레이션으로 안전한 전환을 보장합니다.*