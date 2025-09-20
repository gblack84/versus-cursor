# 🔌 Auth Feature - App Layer 통합 가이드

> **최종 업데이트**: 2025-01-20 | **버전**: 1.0.0
> **진행 상태**: 🔄 통합 대기 중
> **참조 모델**: Voting Feature App Layer Integration
> **통합 우선순위**: Critical (인증은 모든 기능의 기반)

## 📊 App Layer 통합 현황

### 현재 의존성 분석
```
App Layer → Auth Feature 의존성:
├── /app/router.dart → 인증 관련 라우트 15개
├── /app/state/app_state.dart → 사용자 상태 관리
├── /app/di.dart → Auth DI 미설정 (TODO)
└── 36개 외부 파일 → auth_util.dart 직접 의존
```

### 목표 의존성 구조
```
App Layer → Auth Feature (Clean):
├── /app/router.dart → AuthRouterModule
├── /app/state/ → AuthStateProvider
├── /app/di.dart → AuthDIModule
└── 0개 직접 의존 (모두 UseCase 통해 접근)
```

## 🎯 통합 전략

### Phase 1: DI Module 생성 및 등록

#### 1.1 Auth DI Module 생성
```dart
// lib/features/auth/di/auth_di_module.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../data/repositories/auth_repository_impl.dart';
// Mappers - Firebase 1:1 매칭 필수
import '../data/mappers/firestore_user_mapper.dart';
import '../data/mappers/firebase_user_mapper.dart';
import '../data/mappers/auth_user_mapper.dart';
import '../data/mappers/auth_token_mapper.dart';
// ... 30개 UseCase imports

class AuthDIModule {
  static void configureDependencies(GetIt getIt) {
    // External Dependencies
    if (!getIt.isRegistered<FirebaseAuth>()) {
      getIt.registerLazySingleton<FirebaseAuth>(
        () => FirebaseAuth.instance,
      );
    }

    // Mappers (Firebase 1:1 매칭)
    getIt.registerLazySingleton<FirestoreUserMapper>(
      () => FirestoreUserMapper(),
    );

    getIt.registerLazySingleton<FirebaseUserMapper>(
      () => FirebaseUserMapper(),
    );

    getIt.registerLazySingleton<AuthUserMapper>(
      () => AuthUserMapper(),
    );

    getIt.registerLazySingleton<AuthTokenMapper>(
      () => AuthTokenMapper(),
    );

    // DataSources
    getIt.registerLazySingleton<IAuthRemoteDataSource>(
      () => FirebaseAuthDataSource(
        firebaseAuth: getIt(),
        firestore: getIt(),
        userMapper: getIt(),  // Mapper 주입
      ),
    );

    getIt.registerLazySingleton<IAuthLocalDataSource>(
      () => AuthLocalDataSource(
        sharedPreferences: getIt(),
      ),
    );

    // Repository (Mappers 포함)
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        firestoreMapper: getIt(),  // Mapper 주입
        authUserMapper: getIt(),    // Mapper 주입
        networkInfo: getIt(),
      ),
    );

    // UseCases (30개)
    _registerUseCases(getIt);
  }

  static void _registerUseCases(GetIt getIt) {
    // 인증 기본
    getIt.registerFactory(() => SignInWithEmailUseCase(getIt()));
    getIt.registerFactory(() => SignInWithGoogleUseCase(getIt()));
    getIt.registerFactory(() => SignInWithAppleUseCase(getIt()));
    getIt.registerFactory(() => SignInWithGitHubUseCase(getIt()));
    getIt.registerFactory(() => SignInWithPhoneUseCase(getIt()));
    getIt.registerFactory(() => SignInAnonymouslyUseCase(getIt()));
    getIt.registerFactory(() => SignOutUseCase(getIt()));

    // 계정 관리
    getIt.registerFactory(() => CreateAccountWithEmailUseCase(getIt()));
    getIt.registerFactory(() => CreatePhoneAccountUseCase(getIt()));
    getIt.registerFactory(() => VerifyEmailUseCase(getIt()));
    getIt.registerFactory(() => VerifyPhoneOtpUseCase(getIt()));
    getIt.registerFactory(() => ResetPasswordUseCase(getIt()));
    getIt.registerFactory(() => UpdatePasswordUseCase(getIt()));
    getIt.registerFactory(() => DeleteAccountUseCase(getIt()));

    // 사용자 정보
    getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
    getIt.registerFactory(() => GetCurrentUserEmailUseCase(getIt()));
    getIt.registerFactory(() => GetCurrentUserUidUseCase(getIt()));
    getIt.registerFactory(() => IsAuthenticatedUseCase(getIt()));
    getIt.registerFactory(() => IsEmailVerifiedUseCase(getIt()));
    getIt.registerFactory(() => UpdateUserEmailUseCase(getIt()));

    // 토큰 관리
    getIt.registerFactory(() => GetJwtTokenUseCase(getIt()));
    getIt.registerFactory(() => RefreshTokenUseCase(getIt()));

    // Phone Auth
    getIt.registerFactory(() => SendSmsOtpUseCase(getIt()));
    getIt.registerFactory(() => ResendSmsOtpUseCase(getIt()));
    getIt.registerFactory(() => VerifySmsOtpUseCase(getIt()));

    // 세션 관리
    getIt.registerFactory(() => CheckAuthStateUseCase(getIt()));
    getIt.registerFactory(() => StreamAuthStateUseCase(getIt()));
    getIt.registerFactory(() => HandleAuthRedirectUseCase(getIt()));
  }
}
```

#### 1.2 App DI 통합
```dart
// app/di.dart 수정 필요
import 'features/auth/di/auth_di_module.dart';
import 'features/voting/di/voting_di_module.dart';

void configureDependencies() {
  final getIt = GetIt.instance;

  // Core Dependencies
  _configureCoreDependencies(getIt);

  // Feature Modules
  AuthDIModule.configureDependencies(getIt);
  VotingDIModule.configureDependencies(getIt);
  // ... 기타 피처 모듈
}
```

### Phase 2: Router 통합

#### 2.1 Auth Routes Module
```dart
// lib/features/auth/presentation/routes/auth_routes.dart
import 'package:go_router/go_router.dart';
import '../screens/login_page_widget.dart';
import '../screens/create_account_widget.dart';
import '../screens/forgot_password_widget.dart';
// ... 기타 화면 imports

class AuthRoutes {
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String forgotPassword = '/forgot-password';
  static const String phoneLogin = '/phone-login';
  static const String phoneCreateAccount = '/phone-create-account';
  static const String verifyEmail = '/verify-email';
  static const String verifyPhone = '/verify-phone';
  static const String startPage = '/start';

  static List<GoRoute> getRoutes() {
    return [
      GoRoute(
        path: login,
        name: 'LoginPage',
        builder: (context, state) => const LoginPageWidget(),
      ),
      GoRoute(
        path: createAccount,
        name: 'CreateAccount',
        builder: (context, state) => const CreateAccountWidget(),
      ),
      GoRoute(
        path: forgotPassword,
        name: 'ForgotPassword',
        builder: (context, state) => const ForgotPasswordWidget(),
      ),
      // ... 기타 라우트
    ];
  }

  // Guards
  static String? authGuard(GoRouterState state) {
    final isAuthenticated = GetIt.I<IsAuthenticatedUseCase>()();

    if (!isAuthenticated && !_isPublicRoute(state.uri.path)) {
      return login;
    }

    if (isAuthenticated && _isAuthRoute(state.uri.path)) {
      return '/home';
    }

    return null;
  }

  static bool _isPublicRoute(String path) {
    return [login, createAccount, forgotPassword, startPage]
        .contains(path);
  }

  static bool _isAuthRoute(String path) {
    return path.startsWith('/login') ||
           path.startsWith('/create-account') ||
           path.startsWith('/forgot-password');
  }
}
```

#### 2.2 App Router 통합
```dart
// app/router.dart 수정 필요
import 'features/auth/presentation/routes/auth_routes.dart';

final appRouter = GoRouter(
  initialLocation: '/start',
  redirect: (context, state) => AuthRoutes.authGuard(state),
  routes: [
    ...AuthRoutes.getRoutes(),
    // ... 기타 피처 라우트
  ],
);
```

### Phase 3: State Management 분리

#### 3.1 Auth State Provider
```dart
// lib/features/auth/presentation/providers/auth_state_provider.dart
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/usecases/stream_auth_state_use_case.dart';

class AuthStateProvider extends ChangeNotifier {
  final StreamAuthStateUseCase _streamAuthStateUseCase;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthStateProvider({
    required StreamAuthStateUseCase streamAuthStateUseCase,
  }) : _streamAuthStateUseCase = streamAuthStateUseCase {
    _initAuthStream();
  }

  // Getters
  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userUid => _currentUser?.uid;
  String? get userEmail => _currentUser?.email;
  String? get displayName => _currentUser?.displayName;

  void _initAuthStream() {
    _streamAuthStateUseCase().listen(
      (user) {
        _currentUser = user;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Actions
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      final signOutUseCase = GetIt.I<SignOutUseCase>();
      await signOutUseCase();

      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Stream cleanup if needed
    super.dispose();
  }
}
```

#### 3.2 App State 통합
```dart
// app/state/app_state.dart 수정 필요
class AppState extends ChangeNotifier {
  // 기존 AppState 로직 유지

  // Auth 관련 상태는 AuthStateProvider로 위임
  AuthStateProvider get auth => GetIt.I<AuthStateProvider>();

  // Backward compatibility를 위한 프록시 메서드들
  @Deprecated('Use auth.currentUser instead')
  AuthUser? get currentUser => auth.currentUser;

  @Deprecated('Use auth.isAuthenticated instead')
  bool get isLoggedIn => auth.isAuthenticated;
}
```

### Phase 4: 외부 의존성 마이그레이션

#### 4.1 의존성 맵핑
```yaml
마이그레이션 맵핑:
  # Direct auth_util imports → UseCase
  - from: "import '/features/auth/data/adapters/auth_util.dart'"
    to: "import 'package:get_it/get_it.dart'"
    usage_change:
      before: "currentUserUid"
      after: "GetIt.I<GetCurrentUserUidUseCase>()()"

  # FFAppState auth → AuthStateProvider
  - from: "FFAppState().currentUser"
    to: "context.watch<AuthStateProvider>().currentUser"

  # Firebase Auth 직접 사용 → UseCase
  - from: "FirebaseAuth.instance.currentUser"
    to: "GetIt.I<GetCurrentUserUseCase>()()"
```

#### 4.2 마이그레이션 스크립트
```bash
# Import Guardian을 사용한 자동 수정
/spawn import-guardian "--scope all --fix-auth-imports --mode apply"

# 수정 대상 파일 리스트 (36개)
# - login_page_widget.dart
# - create_account_widget.dart
# - home_page_widget.dart
# - profile_page_widget.dart
# ... 등
```

## 📋 통합 체크리스트

### DI 통합
- [ ] AuthDIModule 생성
- [ ] 30개 UseCase 등록
- [ ] 6개 Mapper 등록 (Firebase 1:1 매칭)
- [ ] DataSource 등록 (Mapper 주입)
- [ ] Repository 등록 (Mapper 활용)
- [ ] app/di.dart에 통합

### Router 통합
- [ ] AuthRoutes 모듈 생성
- [ ] 인증 가드 구현
- [ ] 공개/보호 라우트 구분
- [ ] app/router.dart 통합

### State 통합
- [ ] AuthStateProvider 생성
- [ ] AppState 프록시 메서드 추가
- [ ] Provider 등록
- [ ] 스트림 관리

### 의존성 정리
- [ ] 36개 외부 파일 import 수정
- [ ] auth_util.dart 제거
- [ ] Firebase 직접 의존 제거
- [ ] UseCase 통한 접근으로 전환

## 🚀 실행 계획

### Step 1: UseCase 생성 (Phase 2 실행)
```bash
# CodeSurgeon으로 대형 파일 분해
/spawn code-surgeon "--file lib/features/auth/presentation/screens/login_page_widget.dart --strategy extract-usecases"
```

### Step 2: DI 설정
```bash
# DI Binder로 의존성 설정
/spawn di-binder "--feature auth --mode apply"
```

### Step 3: Import 수정
```bash
# Import Guardian으로 의존성 수정
/spawn import-guardian "--scope all --fix-auth-imports --mode apply"
```

### Step 4: Router 통합
```bash
# Router Splitter로 라우트 분리
/spawn router-splitter "--feature auth --mode apply"
```

### Step 5: 검증
```bash
# Build Sentinel로 최종 검증
/spawn build-sentinel "full --feature auth"
```

## 📊 예상 결과

### Before
- 36개 파일이 auth 내부 구조 직접 의존
- auth_util.dart 전역 함수 사용
- Firebase Auth 직접 접근
- 테스트 불가능한 구조

### After
- 0개 직접 의존 (모두 UseCase 통해 접근)
- DI를 통한 의존성 주입
- 완전한 레이어 분리
- 100% 테스트 가능 구조
- AppState와 완벽한 통합

## 📚 참고 자료

- [Auth Feature README](./README.md)
- [Master Migration Guide](./MASTER_MIGRATION_GUIDE.md)
- [Architecture Rules](/lib/ARCHITECTURE_RULES.md)
- [Voting App Layer Integration](../voting/APP_LAYER_INTEGRATION.md)

---

**이 문서는 Auth Feature의 App Layer 통합을 위한 상세 가이드입니다.**
**DI, Router, State Management를 통해 완벽한 Clean Architecture를 달성합니다.**