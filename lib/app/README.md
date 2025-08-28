# 📱 App Layer 상세 문서

> Feature-First Architecture의 앱 진입점 및 전역 설정 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

App Layer는 Versus Space 애플리케이션의 진입점과 전역 설정을 관리합니다.
라우팅, 전역 상태 관리, 의존성 주입, 앱 초기화를 담당하는 최상위 레이어입니다.

## 🚀 마이그레이션 현황

**통합 마이그레이션 문서가 작성되었습니다**: [MIGRATION_APP_ORDER_RULES.md](./MIGRATION_APP_ORDER_RULES.md)

### 마이그레이션 문서 구조
- **통합 규칙 문서**: `MIGRATION_APP_ORDER_RULES.md` - 전체 실행 순서와 규칙
- **DI 시스템**: `di/MIGRATION_Part3.md` - GetIt 기반 의존성 주입
- **Router 시스템**: `router/MIGRATION_Part3.md` - 라우터 모듈화
- **State 관리**: `state/MIGRATION_Part3.md` - AppState 분리
- **Widgets 레이어**: `widgets/MIGRATION_Part3.md` - 레이어 정리
- **Models**: `models/MIGRATION_Part3.md` - Location 모델 처리

## 🏗️ 현재 디렉토리 구조

```
lib/app/
├── app.dart                    # 앱 진입점 (VersusApp)
├── di/                         # 의존성 주입 (미구현)
│   └── README.md
├── models/                     # 앱 레벨 모델
│   ├── lat_lng.dart           # 위치 좌표 모델
│   └── place.dart             # 장소 모델
├── router/                     # 라우팅 설정
│   └── navigation/
│       ├── nav.dart           # GoRouter 설정
│       └── serialization_util.dart  # 라우트 직렬화
├── state/                      # 전역 상태 관리
│   ├── app_state.dart        # 전역 AppState (싱글톤)
│   └── providers/
│       └── navigation_provider.dart  # 네비게이션 상태
└── widgets/                    # 앱 레벨 위젯
    ├── debug/
    │   └── debug_log_page.dart  # 디버그 로그 페이지
    ├── index.dart             # 위젯 export
    └── navigation/
        └── main_navigation_shell.dart  # 메인 네비게이션 셸
```

## 🔍 현재 코드 분석

### 1. app.dart - 앱 진입점
**현재 기능:**
- MaterialApp 설정 및 초기화
- 테마 모드 관리 (다크/라이트)
- 다국어 지원 설정
- GoRouter 통합
- BotToast 설정
- 사용자 인증 스트림 관리

**사용처:**
- `main.dart`에서 호출되는 최상위 위젯
- 전체 앱의 루트 위젯

**개선 필요사항:**
- ❌ 너무 많은 책임 (초기화, 라우팅, 상태 관리)
- ❌ Feature 의존성이 직접 import됨

### 2. state/app_state.dart - 전역 상태
**현재 기능:**
- 싱글톤 패턴으로 전역 상태 관리
- 업로드 관련 상태 (이미지, 비디오, 텍스트)
- 언어 설정
- 사용자 표시 이름

**문제점:**
- ❌ 너무 많은 책임 (800+ 줄)
- ❌ Feature 특정 로직이 포함됨 (업로드는 posts feature)
- ❌ 단일 파일에 모든 상태

### 3. router/navigation/nav.dart - 라우팅
**현재 기능:**
- GoRouter 설정
- 라우트 정의
- 네비게이션 가드
- 딥링크 처리

**문제점:**
- ❌ Feature 라우트가 하드코딩됨
- ❌ 라우트 정의가 중앙집중식

### 4. models/ - 앱 레벨 모델
**현재 상태:**
- `lat_lng.dart`: 위치 좌표 (Google Maps 관련)
- `place.dart`: 장소 정보 (Google Places 관련)

**평가:**
- ⚠️ 현재 앱에서 사용되지 않는 것으로 보임
- ⚠️ 지도 기능이 있다면 별도 Feature로 분리 필요

### 5. widgets/ - 앱 레벨 위젯
**현재 상태:**
- `main_navigation_shell.dart`: 하단 네비게이션
- `debug_log_page.dart`: 디버그 페이지

**평가:**
- ✅ 네비게이션 셸은 앱 레벨에 적합
- ⚠️ 디버그 페이지는 개발 도구로 분리 가능

## 🛠️ Feature-First Architecture 개선 방안

### 1. 즉시 개선 필요 (Critical)

#### AppState 분리
```dart
// 현재: 모든 것이 하나의 파일에
class AppState {
  // 언어 설정 ✅ (앱 레벨)
  String selectedLang;
  
  // 업로드 상태 ❌ (posts feature로 이동)
  List<String> uploadImageA;
  List<String> uploadVideoA;
  // ...
}

// 개선안:
// lib/app/state/app_state.dart - 순수 앱 상태만
class AppState {
  String selectedLang;
  ThemeMode themeMode;
  // 앱 레벨 상태만
}

// lib/features/posts/presentation/providers/upload_state.dart
class UploadState {
  List<String> uploadImageA;
  List<String> uploadVideoA;
  // posts feature 상태
}
```

#### 라우팅 모듈화
```dart
// 현재: 중앙집중식 라우팅
GoRouter(
  routes: [
    // 모든 라우트가 한 곳에
  ]
)

// 개선안: Feature별 라우트 등록
// lib/app/router/app_router.dart
class AppRouter {
  static GoRouter create() {
    return GoRouter(
      routes: [
        ...AuthFeature.routes,
        ...PostsFeature.routes,
        ...ChatFeature.routes,
        // 각 Feature가 자신의 라우트 제공
      ]
    );
  }
}
```

### 2. 중기 개선 사항

#### 의존성 주입 구현
```dart
// lib/app/di/injection.dart
class Injection {
  static final GetIt _getIt = GetIt.instance;
  
  static Future<void> init() async {
    // Firebase
    _getIt.registerSingleton<FirebaseAuth>(
      FirebaseAuth.instance
    );
    
    // Repositories
    _getIt.registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(_getIt())
    );
    
    // Services
    _getIt.registerSingleton<CacheService>(
      UnifiedCacheService()
    );
  }
}
```

#### Provider 구조 개선
```dart
// lib/app/state/providers/app_providers.dart
class AppProviders {
  static List<SingleChildWidget> get providers => [
    // 앱 레벨 Provider만
    ChangeNotifierProvider(create: (_) => AppState()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LocalizationProvider()),
    
    // Feature Provider는 각 Feature가 제공
    ...AuthFeature.providers,
    ...PostsFeature.providers,
  ];
}
```

### 3. 파일 이동 계획

#### 이동 필요 파일
| 현재 위치 | 이동 대상 | 이유 |
|---------|----------|------|
| `app_state.dart` 업로드 부분 | `/features/posts/presentation/providers/` | Posts Feature 책임 |
| `models/lat_lng.dart` | `/features/location/` (새 Feature) | 위치 기능 별도 관리 |
| `models/place.dart` | `/features/location/` (새 Feature) | 위치 기능 별도 관리 |

#### 유지 파일
| 파일 | 이유 |
|------|------|
| `app.dart` | 앱 진입점 (리팩토링 필요) |
| `navigation_provider.dart` | 전역 네비게이션 상태 |
| `main_navigation_shell.dart` | 앱 레벨 네비게이션 |

## 📊 현재 상태 평가

### 강점
- ✅ 기본적인 레이어 구조 존재
- ✅ GoRouter 사용으로 선언적 라우팅
- ✅ Provider 패턴 사용

### 약점
- ❌ Feature 의존성이 app layer에 직접 포함
- ❌ AppState가 너무 많은 책임
- ❌ DI 시스템 미구현
- ❌ 라우팅이 Feature와 결합

### 기회
- 🔄 AppState를 Feature별로 분리 가능
- 🔄 DI 도입으로 의존성 관리 개선
- 🔄 Feature 모듈화로 확장성 향상

## 🎯 마이그레이션 액션 플랜

### 전체 일정: 4주

#### Week 1: DI 시스템 구축
- GetIt 기반 의존성 주입 시스템 구축
- Firebase 서비스 모듈화
- 전역 서비스 DI 전환

#### Week 2: Router 시스템 리팩토링  
- 542줄 nav.dart를 5개 파일로 분리
- Feature별 라우트 모듈화
- Guard 시스템 구축

#### Week 3: State 관리 분리
- 555줄 AppState를 Feature별로 분리
- Provider 구조 개선
- 브리지 패턴으로 점진적 마이그레이션

#### Week 4: 최종 정리
- Day 1-2: Widgets 레이어 정리
- Day 3: Models 처리
- Day 4-5: 테스트 및 검증

### 상세 실행 계획은 [MIGRATION_APP_ORDER_RULES.md](./MIGRATION_APP_ORDER_RULES.md) 참조

## 📝 코드 예시

### 개선된 App 구조
```dart
// lib/app/app.dart
class VersusApp extends StatelessWidget {
  final Injection injection;
  
  const VersusApp({
    super.key,
    required this.injection,
  });
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            routerConfig: AppRouter.create(),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appState.themeMode,
            locale: appState.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
```

## ⚠️ 마이그레이션 주의사항

### 핵심 원칙
1. **기능 보존**: 모든 기능은 반드시 유지
2. **점진적 마이그레이션**: 단계별 진행으로 리스크 최소화
3. **백업 우선**: 각 단계별 체크포인트 생성
4. **테스트 우선**: 변경 전 테스트 작성
5. **문서화**: 변경사항 즉시 문서화

### 백업 전략
- Git 태그로 각 단계별 백업
- Feature Flag로 즉시 롤백 가능
- 아카이브 브랜치 유지

### 상세 규칙은 [MIGRATION_APP_ORDER_RULES.md](./MIGRATION_APP_ORDER_RULES.md) 참조

## 📚 참고 자료

### 마이그레이션 문서
- [통합 마이그레이션 규칙](./MIGRATION_APP_ORDER_RULES.md)
- [DI 마이그레이션 가이드](./di/MIGRATION_Part3.md)
- [Router 마이그레이션 가이드](./router/MIGRATION_Part3.md)
- [State 마이그레이션 가이드](./state/MIGRATION_Part3.md)
- [Widgets 마이그레이션 가이드](./widgets/MIGRATION_Part3.md)
- [Models 마이그레이션 가이드](./models/MIGRATION_Part3.md)

### 아키텍처 문서
- [Feature-First Architecture Guide](/FEATURE_ARCHITECTURE.md)
- [Global Layers Documentation](/GLOBAL_LAYERS.md)
- [Development Rules](/DEVELOPMENT_RULES.md)

---

*이 문서는 App Layer의 현재 상태와 마이그레이션 계획을 담고 있습니다.*
*마지막 업데이트: 2025-08-28*