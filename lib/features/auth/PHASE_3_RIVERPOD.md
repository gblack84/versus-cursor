# Phase 3: Riverpod 2.x 마이그레이션

> **소요 시간**: 1.5일
> **난이도**: ⭐⭐⭐⭐☆ (높음)
> **영향 범위**: Presentation Layer (Provider + UI 8개 화면)
> **UI 영향**: ✅ **있음** (8개 화면 모두 변경 필요)

---

## 📋 목차

1. [개요](#1-개요)
2. [현재 상태 분석](#2-현재-상태-분석)
3. [마이그레이션 목표](#3-마이그레이션-목표)
4. [단계별 가이드](#4-단계별-가이드)
5. [Before/After 전체 코드](#5-beforeafter-전체-코드)
6. [백엔드-UI 연결 완전 가이드](#6-백엔드-ui-연결-완전-가이드)
7. [8개 UI 화면 변경 가이드](#7-8개-ui-화면-변경-가이드)
8. [테스트 전략](#8-테스트-전략)
9. [롤백 계획](#9-롤백-계획)

---

## 1. 개요

### 1.1 Phase 3의 목적

Voting Feature의 실시간 상태 관리 패턴을 Auth Feature에 적용합니다:
- ✅ **Riverpod 2.x**: ChangeNotifier → StreamProvider.family
- ✅ **keepAlive()**: BehaviorSubject 캐싱 → Provider 자동 관리
- ✅ **자동 dispose**: 수동 StreamSubscription → autoDispose
- ✅ **UI 자동 업데이트**: notifyListeners() → Stream 자동 감지

### 1.2 변경 대상

| Layer | 파일 | 라인 | 변경 내용 |
|-------|------|------|----------|
| **Presentation - Provider** | `auth_provider.dart` | 662줄 | **유지** (하위 호환성) |
| **Presentation - Provider** | `auth_providers.dart` | 0줄 → 350줄 | **신규 생성** |
| **Presentation - UI** | `login_page_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `create_account_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `popup_timer_email_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `start_page_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `phone_creat_account_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `phonelogeinpincode_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `forgot_password_widget.dart` | 변경 | Consumer 패턴 |
| **Presentation - UI** | `auth_user_stream_widget.dart` | 변경 | Stream 직접 사용 |

**총 변경**: 1개 신규 생성 + 8개 UI 화면 수정

### 1.3 왜 Riverpod를 사용하는가?

**ChangeNotifier + GetIt의 한계**:
```dart
// ❌ 현재 패턴
class AuthProvider extends ChangeNotifier {
  static AuthProvider? _instance;  // Singleton

  StreamSubscription? _authStreamSubscription;  // 수동 관리
  StreamSubscription? _userDocumentSubscription;
  StreamSubscription? _jwtTokenSubscription;

  void _setupLegacyStreams() {
    _authStreamSubscription = FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
      _currentUser = user?.toAuthUser();
      notifyListeners();  // 수동 호출
    });
    // ... 3개 Stream 수동 관리
  }

  @override
  void dispose() {
    _authStreamSubscription?.cancel();  // 수동 해제
    _userDocumentSubscription?.cancel();
    _jwtTokenSubscription?.cancel();
    super.dispose();
  }
}

// UI에서 사용
late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

@override
void initState() {
  super.initState();
  if (!_authProvider.isInitialized) {
    _authProvider.initialize();  // 수동 초기화
  }
}

// 문제점:
// 1. Stream 3개를 수동으로 관리
// 2. dispose 누락 시 메모리 누수
// 3. notifyListeners() 수동 호출
// 4. 초기화 타이밍 복잡
```

**Riverpod의 장점**:
```dart
// ✅ Riverpod 패턴
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: null 먼저 emit
    yield null;

    // 2. Firebase 실시간 Stream
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      yield user?.toAuthUser();
    }

    // 3. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

// UI에서 사용
class LoginPageWidget extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateStreamProvider(AuthStateParams()));

    return authState.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(e),
      data: (user) => _buildLoginForm(user),
    );
  }
}

// 장점:
// 1. Stream 자동 관리 (autoDispose)
// 2. 메모리 누수 방지 (자동 dispose)
// 3. UI 자동 업데이트 (Stream 감지)
// 4. 초기화 불필요 (Provider 자동 생성)
// 5. Voting Feature와 100% 동일한 패턴
```

**Voting Feature 참조 패턴**:
```dart
// lib/features/voting/presentation/providers/vote_state_providers.dart
final voteStateStreamProvider =
    StreamProvider.autoDispose.family<VoteStateData, VoteStateParams>(
  (ref, params) async* {
    yield const VoteStateData(...);  // 기본값

    await for (final voteStateData in useCase(...)) {
      yield voteStateData;  // 실시간 업데이트
    }

    ref.keepAlive();  // 중복 리스너 방지
  },
);
```

---

## 2. 현재 상태 분석

### 2.1 ChangeNotifier 패턴 구조

**파일**: `lib/features/auth/presentation/providers/auth_provider.dart` (662줄)

<details>
<summary>현재 전체 구조 보기 (클릭)</summary>

```dart
// ❌ Before: ChangeNotifier + Singleton
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
// ... 8개 UseCase imports

class AuthProvider extends ChangeNotifier implements AuthContract {
  // ========== Singleton Pattern ==========
  static AuthProvider? _instance;
  static const String _className = 'AuthProvider';

  factory AuthProvider() {
    if (_instance == null) {
      _instance = AuthProvider._(
        signInWithEmailUseCase: GetIt.instance<SignInWithEmailUseCase>(),
        signUpWithEmailUseCase: GetIt.instance<SignUpWithEmailUseCase>(),
        // ... 7개 더
      );
      _instance!._initialize();
    }
    return _instance!;
  }

  AuthProvider._({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    // ... 7개 더
  })  : _signInWithEmailUseCase = signInWithEmailUseCase,
        _signUpWithEmailUseCase = signUpWithEmailUseCase;
        // ... 7개 더

  // ========== Dependencies (9 UseCases) ==========
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithPhoneUseCase _signInWithPhoneUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final PasswordManagementUseCase _passwordManagementUseCase;
  final EmailVerificationUseCase _emailVerificationUseCase;
  final AccountManagementUseCase _accountManagementUseCase;

  // ========== State ==========
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // ========== Manual Stream Subscriptions ==========
  StreamSubscription? _authStreamSubscription;
  StreamSubscription? _userDocumentSubscription;
  StreamSubscription? _jwtTokenSubscription;

  // ========== Getters ==========
  AuthUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;

  // ========== Initialization ==========
  void _initialize() {
    _setupLegacyStreams();
    _isInitialized = true;
  }

  void _setupLegacyStreams() {
    // Stream 1: Firebase Auth State
    _authStreamSubscription = versusSpaceFirebaseUserStream().listen(
      (user) {
        _currentUser = user;
        notifyListeners();
      },
      onError: (error) {
        _setError('인증 상태 오류: $error');
      },
    );

    // Stream 2: User Document
    _userDocumentSubscription = FirebaseAuth.instance
        .authStateChanges()
        .asyncMap((user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        return doc.data();
      }
      return null;
    }).listen(
      (data) {
        if (data != null) {
          // User document 업데이트
          notifyListeners();
        }
      },
    );

    // Stream 3: JWT Token
    _jwtTokenSubscription = FirebaseAuth.instance.idTokenChanges().listen(
      (user) {
        // Token 업데이트
        notifyListeners();
      },
    );
  }

  // ========== Public Methods (8개) ==========

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final result = await _signInWithEmailUseCase.execute(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final result = await _signUpWithEmailUseCase.execute(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);

    final result = await _signInWithGoogleUseCase.execute();

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  // ... 5개 메서드 더 (Apple, Phone, Password, Email, Account)

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // ========== Private Helpers ==========
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========== Dispose ==========
  @override
  void dispose() {
    _authStreamSubscription?.cancel();
    _userDocumentSubscription?.cancel();
    _jwtTokenSubscription?.cancel();
    super.dispose();
  }
}
```

</details>

### 2.2 현재 UI 사용 패턴

**파일**: `lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart`

```dart
// ❌ Before: GetIt + ChangeNotifier
class _LoginPageWidgetState extends State<LoginPageWidget> {
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();

    // 수동 초기화
    if (!_authProvider.isInitialized) {
      _authProvider.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _authProvider.isLoading
          ? CircularProgressIndicator()
          : _buildLoginForm(),
    );
  }

  Future<void> _handleEmailLogin() async {
    if (_authProvider.isLoading) return;

    final success = await _authProvider.signInWithEmail(
      email: _model.emailAddressLoginTextController.text,
      password: _model.passwordLoginTextController.text,
    );

    if (success) {
      context.goNamed('HomePage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authProvider.errorMessage ?? 'Login failed')),
      );
    }
  }
}
```

### 2.3 문제점 요약

| 문제 | 설명 | 영향 |
|------|------|------|
| **Singleton 복잡도** | static + factory 패턴 | 초기화 타이밍 복잡 |
| **Stream 수동 관리** | 3개 StreamSubscription | 메모리 누수 위험 |
| **dispose 누락 위험** | 수동 cancel() 호출 | 버그 가능성 |
| **초기화 체크** | isInitialized 플래그 | UI에서 매번 체크 |
| **notifyListeners 수동** | 모든 상태 변경 시 호출 | 휴먼 에러 가능성 |

---

## 3. 마이그레이션 목표

### 3.1 Riverpod Provider 구조

**신규 파일**: `lib/features/auth/presentation/providers/auth_providers.dart` (350줄)

```dart
// ✅ After: Riverpod Providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '/app/di.dart';  // GetIt은 UseCase에만 사용
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
// ... 8개 UseCase imports

// ========== UseCase Providers (GetIt 래핑) ==========
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return getIt<SignInWithEmailUseCase>();
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return getIt<SignUpWithEmailUseCase>();
});

// ... 7개 더

// ========== Auth State Stream Provider ==========
/// Voting Feature 패턴 100% 적용
///
/// **Coordinator._stateCache (BehaviorSubject) 완벽 대체**:
/// - ✅ BehaviorSubject 캐싱 → StreamProvider.family + keepAlive()
/// - ✅ 중복 리스너 방지 → Family가 자동 관리
/// - ✅ 즉시 로딩 → yield null (기본값)
/// - ✅ 자동 메모리 정리 → autoDispose
/// - ✅ 실시간 동기화 → Firebase Stream 전달
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: 기본값 먼저 emit
    yield null;

    // 2. Firebase 실시간 Stream
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      yield user?.toAuthUser();
    }

    // 3. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

/// Auth State 파라미터 (Family Provider용)
class AuthStateParams {
  const AuthStateParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

// ========== Loading State Provider ==========
final authLoadingProvider = StateProvider<bool>((ref) => false);

// ========== Error Message Provider ==========
final authErrorProvider = StateProvider<String?>((ref) => null);

// ========== Action Providers (비동기 작업) ==========
final signInWithEmailProvider = Provider.autoDispose.family<
    Future<Either<AuthFailure, AuthUser>>, SignInParams>((ref, params) {
  final useCase = ref.watch(signInWithEmailUseCaseProvider);
  return useCase.execute(email: params.email, password: params.password);
});

class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SignInParams &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password;

  @override
  int get hashCode => email.hashCode ^ password.hashCode;
}

// ... 7개 Action Provider 더
```

### 3.2 목표 UI 패턴

```dart
// ✅ After: ConsumerStatefulWidget + ref.watch
class LoginPageWidget extends ConsumerStatefulWidget {
  const LoginPageWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends ConsumerState<LoginPageWidget> {
  // GetIt 제거, initState 불필요

  @override
  Widget build(BuildContext context) {
    // 1. Auth 상태 감시
    final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));

    // 2. 로딩 상태 감시
    final isLoading = ref.watch(authLoadingProvider);

    // 3. 에러 메시지 감시
    final errorMessage = ref.watch(authErrorProvider);

    return Scaffold(
      body: authState.when(
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(e),
        data: (user) => _buildLoginForm(user, isLoading, errorMessage),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    // 1. 로딩 시작
    ref.read(authLoadingProvider.notifier).state = true;

    // 2. UseCase 실행
    final signInUseCase = ref.read(signInWithEmailUseCaseProvider);

    final result = await signInUseCase.execute(
      email: _model.emailAddressLoginTextController.text,
      password: _model.passwordLoginTextController.text,
    );

    // 3. 결과 처리
    result.fold(
      (failure) {
        ref.read(authErrorProvider.notifier).state = failure.message;
        ref.read(authLoadingProvider.notifier).state = false;
      },
      (user) {
        ref.read(authLoadingProvider.notifier).state = false;
        context.goNamed('HomePage');
      },
    );
  }
}
```

### 3.3 변경 요약

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **Widget Type** | `StatefulWidget` | `ConsumerStatefulWidget` | Riverpod |
| **Provider 주입** | `GetIt.instance<AuthProvider>()` | `ref.watch(provider)` | Riverpod |
| **초기화** | `if (!isInitialized) initialize()` | 불필요 | 자동 |
| **상태 감시** | `_authProvider.currentUser` | `ref.watch(authStateStreamProvider)` | Stream |
| **상태 업데이트** | `notifyListeners()` | Stream 자동 감지 | 자동 |
| **Stream 관리** | 수동 cancel() | autoDispose | 자동 |
| **코드 라인** | 662줄 | 350줄 | -312줄 (47% 감소) |

---

## 4. 단계별 가이드

### 4.1 사전 준비

**Step 1: 의존성 추가**

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^2.5.1
```

```bash
flutter pub get
```

**Step 2: 백업 생성**

```bash
# Presentation Layer 백업
cp -r lib/features/auth/presentation lib/features/auth/presentation.backup

# Git 커밋 (롤백 포인트)
git add .
git commit -m "chore(auth): Backup before Riverpod migration"
```

### 4.2 Riverpod Provider 생성

**Step 3: auth_providers.dart 신규 생성**

**파일**: `lib/features/auth/presentation/providers/auth_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '/app/di.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
// ... 7개 UseCase imports

// ========== UseCase Providers ==========
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return getIt<SignInWithEmailUseCase>();
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return getIt<SignUpWithEmailUseCase>();
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return getIt<SignInWithGoogleUseCase>();
});

final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return getIt<SignInWithAppleUseCase>();
});

final signInWithPhoneUseCaseProvider = Provider<SignInWithPhoneUseCase>((ref) {
  return getIt<SignInWithPhoneUseCase>();
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return getIt<GetCurrentUserUseCase>();
});

final passwordManagementUseCaseProvider = Provider<PasswordManagementUseCase>((ref) {
  return getIt<PasswordManagementUseCase>();
});

final emailVerificationUseCaseProvider = Provider<EmailVerificationUseCase>((ref) {
  return getIt<EmailVerificationUseCase>();
});

final accountManagementUseCaseProvider = Provider<AccountManagementUseCase>((ref) {
  return getIt<AccountManagementUseCase>();
});

// ========== Auth State Stream ==========
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    // 즉시 로딩: null 먼저 emit
    yield null;

    // Firebase 실시간 Stream
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      yield user?.toAuthUser();
    }

    // keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

class AuthStateParams {
  const AuthStateParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

// ========== Loading & Error State ==========
final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
```

**Step 4: main.dart에 ProviderScope 추가**

```dart
// lib/main.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // GetIt 초기화 (UseCase 등록)
  setupGetIt();

  runApp(
    ProviderScope(  // ← Riverpod 추가
      child: MyApp(),
    ),
  );
}
```

### 4.3 UI 화면 변경 (8개 파일)

**패턴 1: StatefulWidget → ConsumerStatefulWidget**

```dart
// Before
class LoginPageWidget extends StatefulWidget {
  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();
  // ...
}

// After
class LoginPageWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends ConsumerState<LoginPageWidget> {
  // GetIt 제거
  // ...
}
```

**패턴 2: build 메서드 변경**

```dart
// Before
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: _authProvider.isLoading
        ? CircularProgressIndicator()
        : _buildForm(),
  );
}

// After
@override
Widget build(BuildContext context) {
  final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
  final isLoading = ref.watch(authLoadingProvider);

  return Scaffold(
    body: authState.when(
      loading: () => CircularProgressIndicator(),
      error: (e, s) => ErrorWidget(e),
      data: (user) => isLoading
          ? CircularProgressIndicator()
          : _buildForm(user),
    ),
  );
}
```

**패턴 3: 액션 메서드 변경**

```dart
// Before
Future<void> _handleLogin() async {
  final success = await _authProvider.signInWithEmail(
    email: email,
    password: password,
  );

  if (success) {
    context.goNamed('HomePage');
  } else {
    showError(_authProvider.errorMessage);
  }
}

// After
Future<void> _handleLogin() async {
  ref.read(authLoadingProvider.notifier).state = true;

  final signInUseCase = ref.read(signInWithEmailUseCaseProvider);

  final result = await signInUseCase.execute(
    email: email,
    password: password,
  );

  result.fold(
    (failure) {
      ref.read(authErrorProvider.notifier).state = failure.message;
      ref.read(authLoadingProvider.notifier).state = false;
      showError(failure.message);
    },
    (user) {
      ref.read(authLoadingProvider.notifier).state = false;
      context.goNamed('HomePage');
    },
  );
}
```

### 4.4 컴파일 확인

```bash
# 전체 프로젝트 컴파일
flutter analyze

# 예상 에러:
# - StatefulWidget → ConsumerStatefulWidget 변경 필요
# - GetIt.instance → ref.watch 변경 필요
```

### 4.5 auth_provider.dart 유지 (하위 호환성)

**Step 5: 기존 auth_provider.dart 유지**

```dart
// lib/features/auth/presentation/providers/auth_provider.dart

// ⚠️ DEPRECATED: Riverpod로 마이그레이션 중
// 하위 호환성을 위해 일시적으로 유지
// 모든 UI 화면이 Riverpod로 전환되면 삭제 예정

@Deprecated('Use auth_providers.dart with Riverpod instead')
class AuthProvider extends ChangeNotifier {
  // ... 기존 코드 유지
}
```

---

## 5. Before/After 전체 코드

### 5.1 Provider 비교

<details>
<summary>Before: auth_provider.dart (662줄) - 일부</summary>

```dart
class AuthProvider extends ChangeNotifier {
  static AuthProvider? _instance;

  StreamSubscription? _authStreamSubscription;
  StreamSubscription? _userDocumentSubscription;
  StreamSubscription? _jwtTokenSubscription;

  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  void _setupLegacyStreams() {
    _authStreamSubscription = FirebaseAuth.instance
        .authStateChanges()
        .listen((user) {
      _currentUser = user?.toAuthUser();
      notifyListeners();
    });
    // ... 2개 더
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    final result = await _signInWithEmailUseCase.execute(
      email: email,
      password: password,
    );

    return result.fold(
      (failure) {
        _setError(failure.message);
        return false;
      },
      (user) {
        _currentUser = user;
        notifyListeners();
        return true;
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStreamSubscription?.cancel();
    _userDocumentSubscription?.cancel();
    _jwtTokenSubscription?.cancel();
    super.dispose();
  }
}
```

</details>

<details>
<summary>After: auth_providers.dart (350줄) - 전체</summary>

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import '/app/di.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/failures/auth_failure.dart';
import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_phone_usecase.dart';
import '/features/auth/domain/usecases/get_current_user_usecase.dart';
import '/features/auth/domain/usecases/password_management_usecase.dart';
import '/features/auth/domain/usecases/email_verification_usecase.dart';
import '/features/auth/domain/usecases/account_management_usecase.dart';

// ========== UseCase Providers ==========
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return getIt<SignInWithEmailUseCase>();
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return getIt<SignUpWithEmailUseCase>();
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return getIt<SignInWithGoogleUseCase>();
});

final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return getIt<SignInWithAppleUseCase>();
});

final signInWithPhoneUseCaseProvider = Provider<SignInWithPhoneUseCase>((ref) {
  return getIt<SignInWithPhoneUseCase>();
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return getIt<GetCurrentUserUseCase>();
});

final passwordManagementUseCaseProvider = Provider<PasswordManagementUseCase>((ref) {
  return getIt<PasswordManagementUseCase>();
});

final emailVerificationUseCaseProvider = Provider<EmailVerificationUseCase>((ref) {
  return getIt<EmailVerificationUseCase>();
});

final accountManagementUseCaseProvider = Provider<AccountManagementUseCase>((ref) {
  return getIt<AccountManagementUseCase>();
});

// ========== Auth State Stream Provider ==========
/// Voting Feature 패턴 100% 적용
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    yield null;

    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      yield user?.toAuthUser();
    }

    ref.keepAlive();
  },
);

class AuthStateParams {
  const AuthStateParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

// ========== Loading & Error State ==========
final authLoadingProvider = StateProvider<bool>((ref) => false);
final authErrorProvider = StateProvider<String?>((ref) => null);
```

</details>

### 5.2 UI 비교: LoginPageWidget

<details>
<summary>Before: GetIt + ChangeNotifier (일부)</summary>

```dart
class _LoginPageWidgetState extends State<LoginPageWidget> {
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();

    if (!_authProvider.isInitialized) {
      _authProvider.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _authProvider.isLoading
          ? CircularProgressIndicator()
          : _buildLoginForm(),
    );
  }

  Future<void> _handleEmailLogin() async {
    if (_authProvider.isLoading) return;

    final success = await _authProvider.signInWithEmail(
      email: _model.emailAddressLoginTextController.text,
      password: _model.passwordLoginTextController.text,
    );

    if (success) {
      context.goNamed('HomePage');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authProvider.errorMessage ?? 'Login failed')),
      );
    }
  }
}
```

</details>

<details>
<summary>After: Riverpod (일부)</summary>

```dart
class _LoginPageWidgetState extends ConsumerState<LoginPageWidget> {
  // initState 불필요

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
    final isLoading = ref.watch(authLoadingProvider);
    final errorMessage = ref.watch(authErrorProvider);

    return Scaffold(
      body: authState.when(
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(e),
        data: (user) => isLoading
            ? CircularProgressIndicator()
            : _buildLoginForm(user, errorMessage),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    ref.read(authLoadingProvider.notifier).state = true;

    final signInUseCase = ref.read(signInWithEmailUseCaseProvider);

    final result = await signInUseCase.execute(
      email: _model.emailAddressLoginTextController.text,
      password: _model.passwordLoginTextController.text,
    );

    result.fold(
      (failure) {
        ref.read(authErrorProvider.notifier).state = failure.message;
        ref.read(authLoadingProvider.notifier).state = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
      (user) {
        ref.read(authLoadingProvider.notifier).state = false;
        context.goNamed('HomePage');
      },
    );
  }
}
```

</details>

---

## 6. 백엔드-UI 연결 완전 가이드

### 6.1 로그인 플로우 (End-to-End)

```
[UI Layer] login_page_widget.dart
    ↓ 사용자가 로그인 버튼 클릭
    ↓ _handleEmailLogin() 호출
    │
    ├─ ref.read(authLoadingProvider.notifier).state = true
    │  → 로딩 UI 표시
    │
    └─ ref.read(signInWithEmailUseCaseProvider)
       → UseCase 가져오기 (GetIt)

[Domain Layer] sign_in_with_email_usecase.dart
    ↓ execute(email, password) 호출
    ↓ 이메일/비밀번호 유효성 검증
    ↓
    ├─ 실패: return left(AuthFailure.invalidEmail())
    │
    └─ 성공: _repository.signInWithEmailAndPassword()

[Data Layer] auth_repository_impl.dart
    ↓ signInWithEmailAndPassword(email, password) 호출
    ↓ Firebase Auth SDK 호출

[Firebase Backend] Firebase Authentication
    ↓ POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword
    ↓ 인증 처리
    │
    ├─ 실패: throw FirebaseAuthException
    │  ↓ _mapFirebaseException()
    │  ↓ return left(AuthFailure.userNotFound())
    │
    └─ 성공: UserCredential 반환
       ↓ user?.toAuthUser()
       ↓ return right(AuthUser(...))

[Data Layer → Domain Layer]
    ↓ Either<AuthFailure, AuthUser> 반환

[Domain Layer → UI Layer]
    ↓ result.fold()
    │
    ├─ Left(failure):
    │  ↓ ref.read(authErrorProvider.notifier).state = failure.message
    │  ↓ ref.read(authLoadingProvider.notifier).state = false
    │  └─ ScaffoldMessenger 에러 표시
    │
    └─ Right(user):
       ↓ ref.read(authLoadingProvider.notifier).state = false
       ↓ context.goNamed('HomePage')

[Riverpod Stream] authStateStreamProvider
    ↓ Firebase.authStateChanges() 감지
    ↓ yield user?.toAuthUser()
    └─ UI 자동 리렌더링 (ref.watch 중인 모든 위젯)
```

### 6.2 회원가입 플로우 (IdempotencyService 포함)

```
[UI Layer] create_account_widget.dart
    ↓ 회원가입 버튼 클릭
    ↓ _handleSignUp() 호출
    │
    ├─ ref.read(authLoadingProvider.notifier).state = true
    │
    └─ ref.read(signUpWithEmailUseCaseProvider)

[Domain Layer] sign_up_with_email_usecase.dart
    ↓ execute(email, password, eventId) 호출
    ↓ IdempotencyService.executeIdempotent()

[Idempotency Layer] idempotency_service.dart
    ↓ Firestore Transaction 시작
    ↓ idempotency/{type}_{id}_{userId} 체크
    │
    ├─ 이미 존재 (eventId 동일): return null (재시도)
    ├─ 이미 존재 (eventId 다름): throw IdempotencyViolation (중복)
    │
    └─ 첫 실행: operation() 호출

[Data Layer] auth_repository_impl.dart
    ↓ signUpWithEmailAndPassword(email, password)

[Firebase Backend] Firebase Authentication
    ↓ POST .../accounts:signUp
    │
    ├─ 실패: throw FirebaseAuthException
    │  → left(AuthFailure.emailAlreadyInUse())
    │
    └─ 성공: UserCredential 반환
       ↓ Firestore users 컬렉션 문서 생성
       ↓ idempotency 컬렉션 eventId 저장
       ↓ return right(AuthUser(...))

[Domain Layer → UI Layer]
    ↓ result.fold()
    │
    ├─ Left(failure):
    │  └─ 에러 표시
    │
    └─ Right(user):
       ↓ 이메일 인증 페이지로 이동
       └─ emailVerificationUseCase.sendVerificationEmail()
```

### 6.3 실시간 상태 동기화 플로우

```
[Firebase Backend] Firebase Authentication
    ↓ 사용자 로그인/로그아웃 이벤트 발생
    ↓ authStateChanges() Stream emit

[Riverpod Stream] authStateStreamProvider
    ↓ await for (user in authStateChanges())
    ↓ yield user?.toAuthUser()

[UI Layer] 모든 ref.watch(authStateStreamProvider) 위젯
    ↓ authState.when() 자동 호출
    │
    ├─ loading: CircularProgressIndicator()
    ├─ error: ErrorWidget(e)
    └─ data: _buildContent(user)
       │
       ├─ user == null: 로그인 화면 표시
       └─ user != null: 메인 화면 표시
```

---

## 7. 8개 UI 화면 변경 가이드

### 7.1 화면 1: login_page_widget.dart

**변경 사항**:
- StatefulWidget → ConsumerStatefulWidget
- GetIt 제거, ref.watch 사용
- initState 제거
- authState.when() 패턴 적용

<details>
<summary>전체 Before/After 코드</summary>

```dart
// Before
class LoginPageWidget extends StatefulWidget {
  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();
    if (!_authProvider.isInitialized) {
      _authProvider.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _authProvider.isLoading
          ? CircularProgressIndicator()
          : _buildLoginForm(),
    );
  }

  Future<void> _handleEmailLogin() async {
    final success = await _authProvider.signInWithEmail(...);
    if (success) {
      context.goNamed('HomePage');
    } else {
      showError(_authProvider.errorMessage);
    }
  }
}

// After
class LoginPageWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends ConsumerState<LoginPageWidget> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      body: authState.when(
        loading: () => CircularProgressIndicator(),
        error: (e, s) => ErrorWidget(e),
        data: (user) => isLoading
            ? CircularProgressIndicator()
            : _buildLoginForm(user),
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    ref.read(authLoadingProvider.notifier).state = true;

    final signInUseCase = ref.read(signInWithEmailUseCaseProvider);
    final result = await signInUseCase.execute(...);

    result.fold(
      (failure) {
        ref.read(authErrorProvider.notifier).state = failure.message;
        ref.read(authLoadingProvider.notifier).state = false;
        showError(failure.message);
      },
      (user) {
        ref.read(authLoadingProvider.notifier).state = false;
        context.goNamed('HomePage');
      },
    );
  }
}
```

</details>

### 7.2 화면 2: create_account_widget.dart

**변경 사항**:
- 동일한 패턴
- signUpWithEmailUseCase 사용
- 회원가입 후 이메일 인증 페이지로 이동

### 7.3 화면 3-8: 동일한 패턴 적용

| 화면 | UseCase | 특이사항 |
|------|---------|----------|
| `popup_timer_email_widget.dart` | emailVerificationUseCase | 타이머 UI |
| `start_page_widget.dart` | getCurrentUserUseCase | 초기 화면 |
| `phone_creat_account_widget.dart` | signInWithPhoneUseCase | 휴대폰 인증 |
| `phonelogeinpincode_widget.dart` | signInWithPhoneUseCase | PIN 입력 |
| `forgot_password_widget.dart` | passwordManagementUseCase | 비밀번호 찾기 |
| `auth_user_stream_widget.dart` | authStateStreamProvider | Stream 직접 사용 |

---

## 8. 테스트 전략

### 8.1 Provider Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  group('authStateStreamProvider', () {
    test('초기값으로 null emit', () async {
      final container = ProviderContainer();

      final provider = container.read(
        authStateStreamProvider(const AuthStateParams()),
      );

      expect(
        provider,
        const AsyncValue<AuthUser?>.loading(),
      );
    });

    test('Firebase Stream 변경 시 자동 업데이트', () async {
      // Given
      final mockAuth = MockFirebaseAuth();
      final userStream = Stream.value(MockUser());

      when(() => mockAuth.authStateChanges()).thenAnswer((_) => userStream);

      // When
      final container = ProviderContainer();
      final provider = container.read(
        authStateStreamProvider(const AuthStateParams()),
      );

      // Then
      await expectLater(
        provider.stream,
        emitsInOrder([
          null,  // 초기값
          isA<AuthUser>(),  // Firebase Stream 값
        ]),
      );
    });
  });
}
```

### 8.2 Widget Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('로그인 화면이 authState에 따라 렌더링', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateStreamProvider.overrideWith(
            (ref, params) => Stream.value(null),  // 로그아웃 상태
          ),
        ],
        child: MaterialApp(home: LoginPageWidget()),
      ),
    );

    // 로그인 폼이 표시되는지 확인
    expect(find.byType(TextField), findsNWidgets(2));  // 이메일, 비밀번호
    expect(find.text('로그인'), findsOneWidget);
  });

  testWidgets('로딩 중일 때 CircularProgressIndicator 표시', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authLoadingProvider.overrideWith((ref) => true),
        ],
        child: MaterialApp(home: LoginPageWidget()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## 9. 롤백 계획

### 9.1 Git 롤백

```bash
# 변경사항 확인
git status
git diff lib/features/auth/presentation/

# Presentation Layer 전체 롤백
git checkout HEAD -- lib/features/auth/presentation/

# main.dart 롤백
git checkout HEAD -- lib/main.dart

# 신규 파일 삭제
rm lib/features/auth/presentation/providers/auth_providers.dart

# 의존성 제거 (선택사항)
# pubspec.yaml에서 flutter_riverpod 제거 후
flutter pub get
```

### 9.2 수동 롤백

```bash
# 백업 복원
cp -r lib/features/auth/presentation.backup lib/features/auth/presentation

# 신규 파일 삭제
rm lib/features/auth/presentation/providers/auth_providers.dart

# 컴파일 확인
flutter analyze
```

### 9.3 롤백 검증

```bash
# GetIt 패턴 확인
grep -r "GetIt.instance<AuthProvider>" lib/features/auth/presentation/screens/
# → 8개 파일 발견되어야 함

# Riverpod 패턴 확인 (없어야 함)
grep -r "ConsumerStatefulWidget" lib/features/auth/presentation/screens/
# → 결과 없어야 함

# 앱 실행 확인
flutter run
```

---

## 📊 Phase 3 완료 체크리스트

### Provider Layer
- [ ] `auth_providers.dart` 신규 생성 (350줄)
- [ ] UseCase Provider 9개 생성
- [ ] authStateStreamProvider 생성
- [ ] authLoadingProvider 생성
- [ ] authErrorProvider 생성

### UI Layer (8개 화면)
- [ ] `login_page_widget.dart` Riverpod 적용
- [ ] `create_account_widget.dart` Riverpod 적용
- [ ] `popup_timer_email_widget.dart` Riverpod 적용
- [ ] `start_page_widget.dart` Riverpod 적용
- [ ] `phone_creat_account_widget.dart` Riverpod 적용
- [ ] `phonelogeinpincode_widget.dart` Riverpod 적용
- [ ] `forgot_password_widget.dart` Riverpod 적용
- [ ] `auth_user_stream_widget.dart` Riverpod 적용

### 공통
- [ ] `pubspec.yaml`에 flutter_riverpod 의존성 추가
- [ ] `main.dart`에 ProviderScope 추가
- [ ] Git 커밋 (롤백 포인트)
- [ ] `flutter analyze` 통과 확인
- [ ] Widget 테스트 8개 통과 확인
- [ ] 8개 화면 모두 정상 작동 확인

### Legacy 코드 유지 (하위 호환성)
- [ ] `auth_provider.dart` @Deprecated 어노테이션 추가
- [ ] 주석으로 마이그레이션 완료 시 삭제 예정 명시

---

## ✅ 성공 기준

| 항목 | 기준 |
|------|------|
| **컴파일** | `flutter analyze` 0 issues |
| **테스트** | Widget 테스트 8개 이상 통과 |
| **GetIt 제거** | UI에서 `GetIt.instance<AuthProvider>` 0개 |
| **Riverpod 적용** | 8개 화면 모두 ConsumerStatefulWidget |
| **UI 동작** | 로그인/로그아웃/회원가입 정상 작동 |
| **실시간 동기화** | authStateChanges Stream 자동 감지 |

---

## 🎯 다음 단계

Phase 3 완료 후 **Phase 4: IdempotencyService**로 진행합니다.

- **대상**: 3개 UseCase (sign_up, email_verification, password_management)
- **작업**: 중복 가입/이메일/비밀번호 리셋 방지
- **소요 시간**: 1일

문서: `PHASE_4_IDEMPOTENCY.md`
