# 📦 /lib/app 디렉토리 마이그레이션 가이드

> Feature-First Architecture - 앱 전역 설정 및 진입점 통합

## 🎯 목적

앱의 진입점, 전역 설정, 라우팅, 의존성 주입을 `/lib/app` 폴더로 중앙화하여 깨끗한 구조와 유지보수성을 확보합니다.

## 🚨 중요: main.dart 위치 전략

### ✅ 권장 방식: main.dart는 루트에 유지
Flutter 표준과 도구 호환성을 위해 `lib/main.dart`는 루트에 유지하고, 실제 앱 로직은 `lib/app/app.dart`로 분리합니다.

```dart
// lib/main.dart - 얇은 스텁 파일
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const App());
}
```

```dart
// lib/app/app.dart - 실제 앱 로직
import 'package:flutter/material.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Versus Space',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
```

### ❌ 피해야 할 방식
```bash
# 이렇게 하지 마세요!
git mv lib/main.dart lib/app/main.dart  # Flutter 도구와 충돌 위험
```

## 📋 현재 상태 분석

### 앱 전역 파일 현황
| 디렉토리/파일 | 파일 수 | 설명 | 영향도 |
|--------------|---------|------|--------|
| `/lib/` 루트 | 3개 | main.dart, app_state.dart, index.dart | 매우 높음 |
| `/lib/core/nav/` | 2개 | nav.dart, serialization_util.dart | 높음 |
| `/lib/core/` 테마 | 3개 | app_theme.dart, app_localizations.dart, internationalization.dart | 매우 높음 |
| `/lib/core/` 상태 | 1개 | app_model.dart | 높음 |
| `/lib/providers/` | 1개 | navigation_provider.dart | 중간 |
| `/lib/design_system/` | 5개 | 디자인 토큰 및 상수 | 중간 |
| **총합** | **15개+** | **앱 전역 설정 파일** | **전체 앱 영향** |

## 🏗️ Feature-First 구조 매핑

```
/lib/
├── main.dart                    # 진입점 (루트에 유지!)
│
├── app/
│   ├── app.dart                 # MyApp 위젯
│   ├── router/                  # 라우팅 관련
│   │   ├── router.dart          # GoRouter 메인 설정
│   │   ├── routes.dart          # 라우트 정의
│   │   ├── route_params.dart    # 라우트 파라미터 직렬화
│   │   ├── guards/              # 라우트 가드
│   │   │   ├── auth_guard.dart  # 인증 체크 (Domain 인터페이스 사용)
│   │   │   └── permission_guard.dart # 권한 체크
│   │   └── README.md
│   │
│   ├── di/                      # 의존성 주입
│   │   ├── di.dart              # GetIt 설정
│   │   ├── modules/             # DI 모듈
│   │   │   ├── app_module.dart  # 앱 전역 모듈
│   │   │   ├── network_module.dart # 네트워크 모듈
│   │   │   ├── storage_module.dart # 스토리지 모듈
│   │   │   └── service_module.dart # 서비스 모듈
│   │   └── README.md
│   │
│   ├── theme/                   # 디자인 시스템
│   │   ├── app_theme.dart      # 테마 설정
│   │   ├── light_theme.dart    # 라이트 모드
│   │   ├── dark_theme.dart     # 다크 모드
│   │   ├── colors/             # 색상 시스템
│   │   │   ├── app_colors.dart # 색상 정의
│   │   │   └── color_schemes.dart # 색상 스키마
│   │   ├── typography/         # 타이포그래피
│   │   │   ├── text_styles.dart # 텍스트 스타일
│   │   │   └── font_families.dart # 폰트 패밀리
│   │   ├── spacing/            # 간격 시스템
│   │   │   ├── spacing.dart   # 간격 상수
│   │   │   └── padding.dart   # 패딩 정의
│   │   ├── components/         # 테마 컴포넌트
│   │   │   ├── button_theme.dart # 버튼 테마
│   │   │   ├── card_theme.dart # 카드 테마
│   │   │   └── input_theme.dart # 입력 테마
│   │   └── README.md
│   │
│   ├── config/                  # 앱 설정
│   │   ├── app_config.dart     # 앱 전역 설정
│   │   ├── environment.dart    # 환경 설정
│   │   ├── firebase_config.dart # Firebase 설정
│   │   └── api_config.dart     # API 엔드포인트
│   │
│   ├── localization/            # 다국어 지원
│   │   ├── app_localizations.dart # 다국어 설정
│   │   ├── l10n/                # 언어 파일
│   │   │   ├── en.dart         # 영어
│   │   │   ├── ko.dart         # 한국어
│   │   │   └── de.dart         # 독일어
│   │   └── README.md
│   │
│   ├── state/                   # 전역 상태 관리
│   │   ├── app_state.dart      # 메인 앱 상태
│   │   ├── providers/          # Provider 정의
│   │   │   ├── navigation_provider.dart
│   │   │   ├── theme_provider.dart
│   │   │   └── locale_provider.dart
│   │   └── README.md
│   │
│   ├── widgets/                 # 전역 위젯
│   │   ├── app_scaffold.dart   # 기본 스캐폴드
│   │   ├── loading_widget.dart # 로딩 위젯
│   │   └── error_widget.dart   # 에러 위젯
│   │
│   └── README.md                # 앱 디렉토리 문서
```

## 📁 상세 파일 이동 계획

### Phase 1: 디렉토리 구조 생성

```bash
# 디렉토리 구조 생성
mkdir -p lib/app/router/guards
mkdir -p lib/app/di/modules
mkdir -p lib/app/theme/{colors,typography,spacing,components}
mkdir -p lib/app/config
mkdir -p lib/app/localization/l10n
mkdir -p lib/app/state/providers
mkdir -p lib/app/widgets
```

### Phase 2: 앱 분리 및 상태 관리 이동

```bash
# app.dart 생성 (main.dart에서 분리)
# main.dart는 루트에 유지!
cat > lib/app/app.dart << 'EOF'
import 'package:flutter/material.dart';
import 'router/router.dart';
import 'theme/app_theme.dart';
import 'localization/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Versus Space',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
EOF

# 상태 관리 파일 이동
git mv lib/app_state.dart lib/app/state/app_state.dart
git mv lib/index.dart lib/app/widgets/index.dart

# Core 상태 관리 패턴
git mv lib/core/app_model.dart lib/app/state/app_model.dart

# Provider 이동
git mv lib/providers/navigation_provider.dart lib/app/state/providers/

# main.dart 수정 (스텁으로 변경)
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'app/di/di.dart';
import 'app/config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );
  
  // 의존성 주입 설정
  await configureDependencies();
  
  // 앱 실행
  runApp(const App());
}
EOF
```

### Phase 3: 라우팅 시스템 이동

```bash
# 네비게이션 파일들
git mv lib/core/nav/nav.dart lib/app/router/router.dart
git mv lib/core/nav/serialization_util.dart lib/app/router/route_params.dart

# auth_guard.dart 생성 (순환참조 방지 패턴)
cat > lib/app/router/guards/auth_guard.dart << 'EOF'
import 'package:go_router/go_router.dart';
import 'package:versus_space/features/auth/domain/repositories/auth_repository.dart';

class AuthGuard {
  final AuthRepository authRepository;  // Domain 인터페이스만 의존
  
  AuthGuard(this.authRepository);
  
  String? redirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authRepository.isAuthenticated;
    final isAuthRoute = state.path?.startsWith('/auth') ?? false;
    
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }
    
    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }
    
    return null;
  }
}
EOF
```

### Phase 4: 테마 시스템 이동

```bash
# 테마 관련 파일들
git mv lib/core/app_theme.dart lib/app/theme/app_theme.dart
git mv lib/design_system/constants/colors.dart lib/app/theme/colors/app_colors.dart
git mv lib/design_system/constants/spacing.dart lib/app/theme/spacing/spacing.dart
git mv lib/design_system/constants/text_styles.dart lib/app/theme/typography/text_styles.dart
```

### Phase 5: 다국어 시스템 이동

```bash
# 다국어 파일
git mv lib/core/app_localizations.dart lib/app/localization/app_localizations.dart
git mv lib/core/internationalization.dart lib/app/localization/internationalization.dart
```

### Phase 6: 새 파일 생성

#### 1. DI 설정 생성 (순환참조 방지 패턴 적용)
```dart
// lib/app/di/di.dart
import 'package:get_it/get_it.dart';
import 'modules/app_module.dart';
import 'modules/network_module.dart';
import 'modules/storage_module.dart';
import 'modules/service_module.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // Domain 레이어 먼저 등록 (인터페이스)
  await _registerDomain();
  
  // Data 레이어 등록 (구현체)
  await _registerData();
  
  // Presentation 레이어 등록
  await _registerPresentation();
  
  // App 레이어 등록 (Domain 인터페이스에만 의존)
  await _registerApp();
}

Future<void> _registerDomain() async {
  // Domain interfaces registration
  // 예: sl.registerLazySingleton<AuthRepository>(() => ...);
}

Future<void> _registerData() async {
  // Data layer implementations
  await NetworkModule.configure(sl);
  await StorageModule.configure(sl);
}

Future<void> _registerPresentation() async {
  // Presentation layer
  await ServiceModule.configure(sl);
}

Future<void> _registerApp() async {
  // App layer (Domain 인터페이스만 사용)
  await AppModule.configure(sl);
  
  // Router with auth guard
  sl.registerSingleton<AuthGuard>(
    AuthGuard(sl<AuthRepository>()),  // Domain 인터페이스 주입
  );
}
```

#### 2. 라우터 분리 (router/routes.dart)
```dart
// lib/app/router/routes.dart
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String voting = '/voting';
  static const String createPost = '/create-post';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
}
```

#### 3. 앱 설정 생성 (config/app_config.dart)
```dart
// lib/app/config/app_config.dart
class AppConfig {
  static const String appName = 'Versus Space';
  static const String appVersion = '2.1.0';
  static const String minSupportedVersion = '2.0.0';
  
  // Feature Flags
  static const bool enableAI = true;
  static const bool enableNotifications = true;
  static const bool enableChat = true;
  static const bool enableVoting = true;
  
  // Cache Settings
  static const int cacheSize = 100;
  static const Duration cacheTTL = Duration(minutes: 5);
  
  // API Settings
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
```

## 📝 Import 경로 업데이트

### 점진적 Import 변경 전략
Core 마이그레이션과 동일하게 브리지 파일을 사용한 점진적 변경을 적용합니다.

```dart
// lib/app_exports.dart - 임시 브리지
export 'app/state/app_state.dart';
export 'app/router/router.dart';
export 'app/theme/app_theme.dart';
export 'app/localization/app_localizations.dart';
// ... 기타 exports

// 점진적으로 IDE 리팩터링으로 교체
```

### Import 변경 예시

```dart
// Before
import '/main.dart';  // 이제 불필요
import '/app_state.dart';
import '/core/nav/nav.dart';
import '/core/app_theme.dart';
import '/core/app_localizations.dart';
import '/providers/navigation_provider.dart';
import '/design_system/constants/colors.dart';

// After
import '/app/state/app_state.dart';
import '/app/router/router.dart';
import '/app/theme/app_theme.dart';
import '/app/localization/app_localizations.dart';
import '/app/state/providers/navigation_provider.dart';
import '/app/theme/colors/app_colors.dart';
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 앱 초기화
- [ ] 앱 정상 시작 (main.dart → app.dart)
- [ ] DI 컨테이너 초기화
- [ ] Firebase 초기화
- [ ] 캐시 초기화

#### 2. 라우팅
- [ ] 모든 페이지 접근 가능
- [ ] 라우트 가드 동작 (Domain 인터페이스 사용)
- [ ] 딥링크 처리
- [ ] 네비게이션 전환

#### 3. 테마
- [ ] 라이트/다크 모드 전환
- [ ] 커스텀 색상 적용
- [ ] 타이포그래피 적용
- [ ] 컴포넌트 테마 적용

#### 4. 다국어
- [ ] 언어 전환
- [ ] 번역 키 로드
- [ ] 날짜/숫자 포맷

#### 5. 상태 관리
- [ ] AppState 동작
- [ ] Provider 업데이트
- [ ] 상태 지속성

## ⚠️ 주의사항

### 1. main.dart 위치
- **절대 이동하지 않음** - Flutter 도구 호환성 유지
- 스텁 파일로만 사용
- 실제 로직은 app.dart에 구현

### 2. 순환 참조 방지
- Router는 Domain 인터페이스만 의존
- Feature 구현체 직접 참조 금지
- DI 등록 순서 준수 (Domain → Data → Presentation → App)

### 3. 성능 고려사항
- 테마 캐싱 유지
- 불필요한 리빌드 방지
- 메모리 누수 체크

### 4. 호환성
- 기존 코드와의 호환성 유지
- 점진적 마이그레이션 (브리지 파일 활용)
- Deprecated 어노테이션 활용

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **진입점** | 중간 | 1개 | main.dart 스텁화 |
| **라우팅** | 높음 | 50개+ | 페이지 네비게이션 |
| **테마** | 매우 높음 | 100개+ | 모든 UI 컴포넌트 |
| **다국어** | 중간 | 30개+ | 텍스트 표시 |
| **상태 관리** | 높음 | 20개+ | 데이터 흐름 |
| **총 영향** | **매우 높음** | **200개+** | 전체 앱 영향 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout flutterflow

# 또는 백업 브랜치로 복귀
git checkout backup/before-app-migration
```

## 📅 예상 소요 시간

| Phase | 소요 시간 | 난이도 | 설명 |
|-------|----------|--------|------|
| Phase 1: 디렉토리 생성 | 10분 | ⭐ | 구조 생성 |
| Phase 2: 앱 분리 | 50분 | ⭐⭐⭐ | main.dart 스텁화 & app.dart 생성 |
| Phase 3: 라우팅 이동 | 1시간 | ⭐⭐⭐ | 순환참조 방지 패턴 적용 |
| Phase 4: 테마 이동 | 1.5시간 | ⭐⭐⭐⭐ | Core app_theme |
| Phase 5: 다국어 이동 | 40분 | ⭐⭐ | Core i18n 파일들 |
| Phase 6: 새 파일 생성 | 1시간 | ⭐⭐⭐ | DI, Config 설정 |
| Phase 7: Import 수정 | 2시간 30분 | ⭐⭐⭐⭐ | 점진적 변경 |
| Phase 8: 테스트 | 1시간 | ⭐⭐⭐ | 통합 테스트 |
| **총 소요 시간** | **8시간 10분** | ⭐⭐⭐⭐ | Core 통합 포함 |

## 🚀 다음 단계

1. **백업 생성**
   ```bash
   git add .
   git commit -m "chore: backup before app migration"
   git checkout -b feature/app-migration
   ```

2. **단계별 실행**
   - main.dart는 루트에 유지
   - app.dart로 로직 분리
   - 순환참조 방지 패턴 적용
   - Phase별로 진행
   - 각 Phase 후 테스트

3. **Import 자동화**
   - 브리지 파일 생성
   - IDE 리팩터링 활용
   - 점진적 교체

---

*이 문서는 Feature-First Architecture 마이그레이션의 App 디렉토리 통합 가이드입니다.*
*작성일: 2025-08-25*
*수정일: 2025-08-26 - main.dart 루트 유지 전략 추가*