# Auth Feature - Presentation Layer

## 🎨 개요

Presentation Layer는 Clean Architecture의 최외곽 계층으로, **사용자 인터페이스(UI)와 상태 관리**를 담당합니다. Flutter 위젯, 상태 관리 Provider, UI 모델을 포함하며, Domain Layer의 UseCase를 통해 비즈니스 로직을 실행합니다.

### 📌 현재 구현 상태
- ✅ **화면(Screens)**: 7개 주요 화면 + 1개 모달
- ✅ **컴포넌트(Components)**: 13개 재사용 가능 컴포넌트
- ✅ **모델(Models)**: 7개 화면별 상태 모델
- ✅ **Provider**: 1개 중앙 상태 관리 (AuthProvider)
- ✅ **Export Index**: Public API 정의 완료

## 🏗️ 전체 구조도 (실제 파일 기준)

```
lib/features/auth/presentation/
│
├── 📄 index.dart                    # 🌐 Public API (외부 노출)
│                                    # ✅ 8개 Widget exports
│                                    # ✅ 1개 Provider export
│                                    # ❌ Model/Component 비노출 (캡슐화)
│
├── 📁 providers/                    # 🔄 상태 관리 [1개 파일]
│   └── 📄 auth_provider.dart       # 🎯 Singleton 패턴 (GetIt DI)
│                                    # 🔗 10개 UseCase 통합
│                                    # 📊 ChangeNotifier 패턴
│                                    # 🔐 레거시 호환성 유지
│
└── 📁 screens/                      # 🖼️ UI 화면들 [총 31개 파일]
    │
    ├── 📁 start/                    # 🚀 시작 화면 [2개]
    │   └── 📁 start_page/
    │       ├── 📄 start_page_widget.dart      # 앱 진입점 UI
    │       └── 📄 start_page_model.dart        # 네비게이션 상태
    │
    ├── 📁 login/                    # 🔐 로그인 [6개]
    │   ├── 📁 login_page/           # 메인 로그인 화면
    │   │   ├── 📄 login_page_widget.dart      # 로그인 폼 UI
    │   │   └── 📄 login_page_model.dart        # 폼 검증/에러
    │   └── 📁 components/           # 재사용 컴포넌트 [4개]
    │       ├── 📄 email_login_form.dart        # 이메일/비밀번호
    │       ├── 📄 login_buttons.dart           # 로그인/소셜 버튼
    │       ├── 📄 test_account_buttons.dart    # 개발용 테스트
    │       └── 📄 create_account_link.dart     # 회원가입 링크
    │
    ├── 📁 signup/                   # ✍️ 회원가입 [7개]
    │   ├── 📁 create_account/       # 메인 회원가입 화면
    │   │   ├── 📄 create_account_widget.dart   # 회원가입 폼 UI
    │   │   └── 📄 create_account_model.dart    # 폼 상태/검증
    │   └── 📁 components/           # 재사용 컴포넌트 [5개]
    │       ├── 📄 header_section.dart          # 로고, 타이틀
    │       ├── 📄 signup_form.dart             # 입력 필드들
    │       ├── 📄 signup_buttons.dart          # 가입 실행 버튼
    │       ├── 📄 terms_section.dart           # 약관 동의 UI
    │       └── 📄 login_link.dart              # 로그인 페이지
    │
    ├── 📁 phone_auth/               # 📱 전화번호 인증 [10개]
    │   ├── 📁 phone_creat_account/  # 전화 회원가입 [2개]
    │   │   ├── 📄 phone_creat_account_widget.dart   # 번호 입력 UI
    │   │   └── 📄 phone_creat_account_model.dart    # 번호 검증
    │   ├── 📄 phonelogeinpincode_widget.dart   # OTP 입력 화면
    │   ├── 📄 phonelogeinpincode_model.dart    # OTP 검증/타이머
    │   ├── 📁 phonemaximum/         # SMS 3회 제한 모달 [2개]
    │   │   ├── 📄 phonemaximum_widget.dart     # 경고 모달 UI
    │   │   └── 📄 phonemaximum_model.dart      # 모달 상태
    │   └── 📁 components/           # OTP 컴포넌트 [4개]
    │       ├── 📄 otp_input_field.dart         # 6자리 입력
    │       ├── 📄 otp_timer_display.dart       # 2분 카운트다운
    │       ├── 📄 resend_otp_button.dart       # 재전송 (3회)
    │       └── 📄 verification_status_display.dart  # 인증 상태
    │
    ├── 📁 forgot_password/          # 🔑 비밀번호 재설정 [2개]
    │   └── 📁 forgot_password/
    │       ├── 📄 forgot_password_widget.dart   # 이메일 입력 UI
    │       └── 📄 forgot_password_model.dart    # 재설정 요청
    │
    └── 📁 email_verification/      # 📧 이메일 인증 [2개]
        └── 📁 popup_timer_email/
            ├── 📄 popup_timer_email_widget.dart   # 인증 대기 팝업
            └── 📄 popup_timer_email_model.dart    # 타이머/재전송
```

## 📂 디렉토리별 상세 설명

### 1. index.dart - Public API

**목적**: Auth Feature에서 외부로 노출할 공개 인터페이스 정의

```dart
// 메인 화면 exports (7개)
export 'screens/start/start_page/start_page_widget.dart';
export 'screens/login/login_page/login_page_widget.dart';
export 'screens/signup/create_account/create_account_widget.dart';
export 'screens/forgot_password/forgot_password/forgot_password_widget.dart';
export 'screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart';
export 'screens/phone_auth/phonelogeinpincode_widget.dart';
export 'screens/email_verification/popup_timer_email/popup_timer_email_widget.dart';

// 모달 export (1개)
export 'screens/phone_auth/phonemaximum/phonemaximum_widget.dart';

// Provider export (1개)
export 'providers/auth_provider.dart';

// 참고: Model과 Component는 의도적으로 export하지 않음 (캡슐화)
```

### 2. providers/ - 상태 관리

#### 📄 auth_provider.dart
```dart
class AuthProvider extends ChangeNotifier {
  // Singleton 패턴 (GetIt 통합)
  static AuthProvider? _instance;

  // 10개 UseCase 의존성
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithPhoneUseCase _signInWithPhoneUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final PasswordManagementUseCase _passwordManagementUseCase;
  final EmailVerificationUseCase _emailVerificationUseCase;
  final AccountManagementUseCase _accountManagementUseCase;

  // 상태 필드
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // 레거시 호환성 필드
  VersusSpaceFirebaseUser? _firebaseUser;
  UserProfile? _currentUserDocument;
  String? _currentJwtToken;
}
```

**특징**:
- 🎯 GetIt을 통한 Singleton 관리
- 🔄 ChangeNotifier 패턴으로 UI 업데이트
- 🏗️ 10개 UseCase 통합
- 🔐 레거시 코드 호환성 유지

### 3. screens/ - UI 화면

#### 📁 start/start_page/ - 시작 화면

**파일 구성**:
- `start_page_widget.dart`: 앱 진입점 UI
- `start_page_model.dart`: 화면 상태 관리

**주요 기능**:
- 로그인/회원가입 선택
- 소셜 로그인 버튼 (Google, Apple)
- 게스트 모드 옵션

#### 📁 login/ - 로그인 화면

**파일 구성**:
```
login_page/
  ├── login_page_widget.dart       # 메인 로그인 화면
  └── login_page_model.dart        # 폼 검증, 상태 관리

components/
  ├── email_login_form.dart        # 이메일/비밀번호 입력 폼
  ├── login_buttons.dart            # 로그인 버튼들
  ├── test_account_buttons.dart    # 개발용 테스트 계정 버튼
  └── create_account_link.dart     # 회원가입 링크
```

**Model 필드** (`login_page_model.dart`):
- `emailAddressLoginTextController`: 이메일 입력
- `passwordLoginTextController`: 비밀번호 입력
- `passwordLoginVisibility`: 비밀번호 표시/숨김
- `formKey`: 폼 검증

#### 📁 signup/ - 회원가입 화면

**파일 구성**:
```
create_account/
  ├── create_account_widget.dart   # 메인 회원가입 화면
  └── create_account_model.dart    # 폼 상태 관리

components/
  ├── header_section.dart          # 헤더 (로고, 제목)
  ├── signup_form.dart             # 회원가입 입력 폼
  ├── signup_buttons.dart          # 가입 버튼, 소셜 로그인
  ├── terms_section.dart           # 약관 동의
  └── login_link.dart              # 로그인 페이지 링크
```

**Model 필드** (`create_account_model.dart`):
- `emailTextController`: 이메일 입력
- `passwordTextController`: 비밀번호 입력
- `confirmPasswordTextController`: 비밀번호 확인
- `termsAccepted`: 약관 동의 상태

#### 📁 phone_auth/ - 전화번호 인증

**3개 화면**:
1. **phone_creat_account/**: 전화번호로 계정 생성
2. **phonelogeinpincode**: OTP 코드 입력 (파일 2개가 루트에 위치)
3. **phonemaximum/**: SMS 재전송 3회 제한 경고 모달

**Components (4개)**:
```
components/
  ├── otp_input_field.dart          # 6자리 OTP 입력 필드
  ├── otp_timer_display.dart        # 2분 카운트다운 타이머
  ├── resend_otp_button.dart        # 재전송 버튼 (3회 제한)
  └── verification_status_display.dart  # 인증 상태 표시
```

**핵심 기능**:
- SMS OTP 전송/검증
- 2분 타이머
- 3회 재전송 제한 (PhonemaximumWidget 연동)
- 재전송 카운터 (`canResendCount`)

#### 📁 forgot_password/ - 비밀번호 재설정

**파일 구성**:
```
forgot_password/
  ├── forgot_password_widget.dart  # 비밀번호 재설정 화면
  └── forgot_password_model.dart   # 이메일 입력 상태
```

**주요 기능**:
- 이메일 주소 입력
- 재설정 링크 전송
- 성공/실패 피드백

#### 📁 email_verification/ - 이메일 인증

**파일 구성**:
```
popup_timer_email/
  ├── popup_timer_email_widget.dart  # 이메일 인증 대기 팝업
  └── popup_timer_email_model.dart   # 타이머, 재전송 상태
```

**주요 기능**:
- 실시간 이메일 인증 상태 확인
- 인증 메일 재전송 (3회 제한)
- 타이머 표시 (StopWatchTimer 사용)
- 인증 완료 시 자동 이동

**Model 필드**:
- `timerController`: 타이머 제어
- `resendCount`: 재전송 횟수 추적
- `timerMilliseconds`: 현재 타이머 값

## 🔄 화면 플로우

### 메인 인증 플로우
```
StartPage
    ├─→ LoginPage
    │      ├─→ ForgotPasswordPage
    │      └─→ HomePage (성공)
    │
    └─→ CreateAccountPage
           ├─→ PopupTimerEmail (이메일 인증)
           └─→ PhoneCreatAccount (전화번호 인증)
                  ├─→ PhonelogeinpincodeWidget (OTP)
                  └─→ PhonemaximumWidget (3회 초과 경고)
```

### 컴포넌트 재사용 관계
```
LoginPage
  └── Components
      ├── EmailLoginForm        (이메일/비밀번호 입력)
      ├── LoginButtons          (로그인 실행)
      ├── TestAccountButtons    (개발용)
      └── CreateAccountLink     (회원가입 이동)

CreateAccountPage
  └── Components
      ├── HeaderSection         (브랜딩)
      ├── SignupForm           (정보 입력)
      ├── SignupButtons        (가입 실행)
      ├── TermsSection         (약관)
      └── LoginLink            (로그인 이동)

PhonelogeinpincodeWidget
  └── Components
      ├── OtpInputField        (OTP 입력)
      ├── OtpTimerDisplay      (타이머)
      ├── ResendOtpButton      (재전송)
      └── VerificationStatusDisplay (상태)
```

## 🎨 UI/UX 패턴

### Widget 구조 패턴
```dart
// 모든 화면 위젯의 기본 구조
class [Screen]Widget extends StatefulWidget {
  static const String routeName = '/auth/[screen]';

  @override
  State<[Screen]Widget> createState() => _[Screen]WidgetState();
}

class _[Screen]WidgetState extends State<[Screen]Widget> {
  late [Screen]Model _model;
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => [Screen]Model());
  }
}
```

### Model 구조 패턴
```dart
// 모든 화면 모델의 기본 구조
class [Screen]Model extends AppModel<[Screen]Widget> {
  // Form keys
  final formKey = GlobalKey<FormState>();

  // Text controllers
  TextEditingController? emailController;
  FocusNode? emailFocusNode;

  // Validators
  String? Function(BuildContext, String?)? emailValidator;

  @override
  void initState(BuildContext context) {
    emailValidator = _emailValidator;
  }

  @override
  void dispose() {
    emailController?.dispose();
    emailFocusNode?.dispose();
  }
}
```

## 🔐 보안 고려사항

### 입력 검증
- 이메일 형식: RegExp 검증
- 비밀번호 강도: 최소 6자 이상
- OTP: 6자리 숫자만 허용
- 전화번호: 국제 형식 검증

### 재시도 제한
- SMS OTP: 3회 제한 (PhonemaximumWidget)
- 이메일 인증: 3회 제한
- 로그인 시도: Rate limiting 적용

### 상태 보호
- 민감한 정보 메모리 정리
- 비밀번호 필드 마스킹
- 타이머 기반 세션 만료

## 📘 사용 명세서 (Usage Specifications)

`★ Insight ─────────────────────────────────────`
[1] Auth Feature는 GetIt을 통한 Singleton 패턴으로 관리됩니다
[2] 모든 화면은 AuthProvider를 통해 비즈니스 로직에 접근합니다
[3] Clean Architecture 레이어 간 통신은 인터페이스를 통해 이루어집니다
`─────────────────────────────────────────────────`

### 1. 🚀 Auth Feature 초기화

```dart
// main.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'lib/features/auth/presentation/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase 초기화 (필수)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. GetIt 의존성 주입 설정
  setupAuthDependencies();

  // 3. AuthProvider 초기화 (자동 로그인 확인)
  final authProvider = GetIt.instance<AuthProvider>();
  await authProvider.initialize();

  runApp(MyApp());
}

// 의존성 주입 설정 함수
void setupAuthDependencies() {
  final getIt = GetIt.instance;

  // Data Layer
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(),
  );

  // Domain Layer - UseCases
  getIt.registerLazySingleton(() => SignInWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => SignUpWithEmailUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithGoogleUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithAppleUseCase(getIt()));
  getIt.registerLazySingleton(() => SignInWithPhoneUseCase(getIt()));
  getIt.registerLazySingleton(() => SignOutUseCase(getIt()));

  // Presentation Layer - Provider
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider(),
  );
}
```

### 2. 🗺️ 화면 라우팅 설정

```dart
// app/router/auth_routes.dart
import 'package:go_router/go_router.dart';
import 'package:versus_space/features/auth/presentation/index.dart';

final authRoutes = [
  // 시작 화면 (앱 진입점)
  GoRoute(
    path: '/start',
    name: 'start',
    builder: (context, state) => const StartPageWidget(),
  ),

  // 로그인 플로우
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (context, state) => const LoginPageWidget(),
    routes: [
      // 비밀번호 재설정 (중첩 라우트)
      GoRoute(
        path: 'forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordWidget(),
      ),
    ],
  ),

  // 회원가입 플로우
  GoRoute(
    path: '/signup',
    name: 'signup',
    builder: (context, state) => const CreateAccountWidget(),
    routes: [
      // 이메일 인증 팝업
      GoRoute(
        path: 'email-verification',
        name: 'email-verification',
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: PopupTimerEmailWidget(),
        ),
      ),
    ],
  ),

  // 전화번호 인증 플로우
  GoRoute(
    path: '/phone-auth',
    name: 'phone-auth',
    builder: (context, state) => const PhoneCreatAccountWidget(),
    routes: [
      // OTP 입력 화면
      GoRoute(
        path: 'verify',
        name: 'phone-verify',
        builder: (context, state) {
          final sessionId = state.extra as String?;
          return PhonelogeinpincodeWidget(sessionId: sessionId);
        },
      ),
    ],
  ),
];

// 메인 라우터 설정 (보호된 라우트 포함)
final router = GoRouter(
  initialLocation: '/start',
  redirect: (context, state) {
    final authProvider = GetIt.instance<AuthProvider>();
    final isLoggedIn = authProvider.loggedIn;
    final isAuthRoute = state.matchedLocation.startsWith('/start') ||
                       state.matchedLocation.startsWith('/login') ||
                       state.matchedLocation.startsWith('/signup');

    // 인증되지 않은 사용자가 보호된 페이지 접근 시
    if (!isLoggedIn && !isAuthRoute) {
      return '/start';
    }

    // 인증된 사용자가 인증 페이지 접근 시
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }

    return null; // 정상 진행
  },
  routes: [
    ...authRoutes,
    // 다른 라우트들...
  ],
);
```

### 3. 🔐 로그인 구현 예제

```dart
// screens/login/login_page/login_page_widget.dart
import 'package:versus_space/features/auth/presentation/index.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({Key? key}) : super(key: key);

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget> {
  late LoginPageModel _model;
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPageModel());

    // 이메일/비밀번호 검증 설정
    _model.emailValidator = (context, value) {
      if (value == null || value.isEmpty) {
        return '이메일을 입력해주세요';
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return '올바른 이메일 형식이 아닙니다';
      }
      return null;
    };
  }

  // 이메일/비밀번호 로그인
  Future<void> _handleEmailLogin() async {
    // 폼 검증
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      final success = await _authProvider.signInWithEmail(
        _model.emailController.text.trim(),
        _model.passwordController.text,
      );

      if (success) {
        // 성공: 홈 화면으로 이동
        if (mounted) context.go('/home');
      } else {
        // 실패: 에러 메시지 표시
        _showErrorSnackBar(_authProvider.errorMessage ?? '로그인 실패');
      }
    } catch (e) {
      _showErrorSnackBar('로그인 중 오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _model.isLoading = false);
    }
  }

  // Google 로그인
  Future<void> _handleGoogleLogin() async {
    setState(() => _model.isLoading = true);

    try {
      final success = await _authProvider.signInWithGoogle();

      if (success) {
        // 신규 사용자인 경우 프로필 설정으로
        if (_authProvider.isNewUser) {
          if (mounted) context.go('/profile-setup');
        } else {
          if (mounted) context.go('/home');
        }
      } else {
        _showErrorSnackBar('Google 로그인 실패');
      }
    } finally {
      if (mounted) setState(() => _model.isLoading = false);
    }
  }

  // Apple 로그인 (iOS 전용)
  Future<void> _handleAppleLogin() async {
    if (!Platform.isIOS) {
      _showErrorSnackBar('Apple 로그인은 iOS에서만 가능합니다');
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      final success = await _authProvider.signInWithApple();

      if (success) {
        if (mounted) context.go('/home');
      } else {
        _showErrorSnackBar('Apple 로그인 실패');
      }
    } finally {
      if (mounted) setState(() => _model.isLoading = false);
    }
  }

  // 에러 메시지 표시
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UI 구현...
    return Scaffold(
      body: SafeArea(
        child: _model.isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _model.formKey,
              child: Column(
                children: [
                  // 로그인 폼 UI...
                ],
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
```

### 4. ✍️ 회원가입 구현 예제

```dart
// screens/signup/create_account/create_account_widget.dart
class CreateAccountWidget extends StatefulWidget {
  const CreateAccountWidget({Key? key}) : super(key: key);

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  late CreateAccountModel _model;
  final _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAccountModel());

    // 비밀번호 검증 규칙 설정
    _model.passwordValidator = (context, value) {
      if (value == null || value.isEmpty) {
        return '비밀번호를 입력해주세요';
      }
      if (value.length < 6) {
        return '비밀번호는 6자 이상이어야 합니다';
      }
      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
        return '문자와 숫자를 포함해야 합니다';
      }
      return null;
    };

    // 비밀번호 확인 검증
    _model.confirmPasswordValidator = (context, value) {
      if (value != _model.passwordController.text) {
        return '비밀번호가 일치하지 않습니다';
      }
      return null;
    };
  }

  Future<void> _handleSignUp() async {
    // 1. 폼 검증
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    // 2. 약관 동의 확인
    if (!_model.termsAccepted) {
      _showErrorSnackBar('이용약관에 동의해주세요');
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      // 3. 계정 생성
      final success = await _authProvider.signUpWithEmail(
        _model.emailController.text.trim(),
        _model.passwordController.text,
      );

      if (success) {
        // 4. 이메일 인증 메일 전송
        await _authProvider.sendEmailVerification();

        // 5. 이메일 인증 팝업 표시
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => PopupTimerEmailWidget(
              onVerificationComplete: () {
                // 인증 완료 시 프로필 설정으로 이동
                Navigator.pop(context);
                context.go('/profile-setup');
              },
            ),
          );
        }
      } else {
        // 회원가입 실패 처리
        final errorMessage = _authProvider.errorMessage ?? '회원가입 실패';
        _showErrorSnackBar(errorMessage);

        // 이메일 중복 시 로그인 유도
        if (errorMessage.contains('already in use')) {
          _showLoginPrompt();
        }
      }
    } catch (e) {
      _showErrorSnackBar('회원가입 중 오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _model.isLoading = false);
    }
  }

  // 로그인 유도 다이얼로그
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이미 가입된 이메일'),
        content: Text('이 이메일로 가입된 계정이 있습니다. 로그인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/login');
            },
            child: Text('로그인'),
          ),
        ],
      ),
    );
  }
}
```

### 5. 📱 SMS 인증 구현 예제

```dart
// screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart
class PhoneCreatAccountWidget extends StatefulWidget {
  const PhoneCreatAccountWidget({Key? key}) : super(key: key);

  @override
  State<PhoneCreatAccountWidget> createState() => _PhoneCreatAccountWidgetState();
}

class _PhoneCreatAccountWidgetState extends State<PhoneCreatAccountWidget> {
  late PhoneCreatAccountModel _model;
  final _authProvider = GetIt.instance<AuthProvider>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneCreatAccountModel());

    // 전화번호 검증 설정
    _model.phoneValidator = (context, value) {
      if (value == null || value.isEmpty) {
        return '전화번호를 입력해주세요';
      }
      // 한국 전화번호 형식 확인
      if (!RegExp(r'^01[0-9]-?[0-9]{4}-?[0-9]{4}$').hasMatch(value)) {
        return '올바른 전화번호 형식이 아닙니다';
      }
      return null;
    };
  }

  // SMS OTP 전송
  Future<void> _sendSmsOtp() async {
    // 폼 검증
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    // 재전송 제한 확인 (3회)
    if (_model.resendCount >= 3) {
      // 제한 경고 모달 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PhonemaximumWidget(
          onDismiss: () {
            Navigator.pop(context);
            // 24시간 후 재시도 안내
            _showInfoSnackBar('24시간 후에 다시 시도해주세요');
          },
        ),
      );
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      // 국제 전화번호 포맷으로 변환
      final phoneNumber = _formatPhoneNumber(_model.phoneController.text);

      // SMS 전송 요청
      final sessionId = await _authProvider.sendSmsOtp(phoneNumber);

      if (sessionId != null) {
        // 재전송 카운트 증가
        setState(() => _model.resendCount++);

        // OTP 입력 화면으로 이동
        if (mounted) {
          context.pushNamed(
            'phone-verify',
            extra: {
              'sessionId': sessionId,
              'phoneNumber': phoneNumber,
              'resendCount': _model.resendCount,
            },
          );
        }
      } else {
        _showErrorSnackBar('SMS 전송 실패. 번호를 확인해주세요');
      }
    } catch (e) {
      _showErrorSnackBar('SMS 전송 중 오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _model.isLoading = false);
    }
  }

  // 전화번호 포맷 변환 (010-1234-5678 → +821012345678)
  String _formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('0')) {
      return '+82${cleaned.substring(1)}';
    }
    return '+82$cleaned';
  }
}

// screens/phone_auth/phonelogeinpincode_widget.dart
class PhonelogeinpincodeWidget extends StatefulWidget {
  final String? sessionId;
  final String? phoneNumber;
  final int resendCount;

  const PhonelogeinpincodeWidget({
    Key? key,
    this.sessionId,
    this.phoneNumber,
    this.resendCount = 0,
  }) : super(key: key);

  @override
  State<PhonelogeinpincodeWidget> createState() => _PhonelogeinpincodeWidgetState();
}

class _PhonelogeinpincodeWidgetState extends State<PhonelogeinpincodeWidget> {
  late PhonelogeinpincodeModel _model;
  final _authProvider = GetIt.instance<AuthProvider>();
  Timer? _timer;
  int _remainingSeconds = 120; // 2분 타이머

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhonelogeinpincodeModel());
    _model.resendCount = widget.resendCount;

    // 2분 타이머 시작
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 120);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  // OTP 검증
  Future<void> _verifyOtp() async {
    if (_model.otpController.text.length != 6) {
      _showErrorSnackBar('6자리 인증 코드를 입력해주세요');
      return;
    }

    setState(() => _model.isLoading = true);

    try {
      final success = await _authProvider.verifySmsOtp(
        widget.sessionId!,
        _model.otpController.text,
      );

      if (success) {
        // 인증 성공
        _timer?.cancel();

        // 신규 사용자인 경우 프로필 설정으로
        if (_authProvider.isNewUser) {
          if (mounted) context.go('/profile-setup');
        } else {
          if (mounted) context.go('/home');
        }
      } else {
        _showErrorSnackBar('잘못된 인증 코드입니다');
        _model.otpController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('인증 처리 중 오류가 발생했습니다');
    } finally {
      if (mounted) setState(() => _model.isLoading = false);
    }
  }

  // OTP 재전송
  Future<void> _resendOtp() async {
    if (_model.resendCount >= 3) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PhonemaximumWidget(),
      );
      return;
    }

    final sessionId = await _authProvider.sendSmsOtp(widget.phoneNumber!);
    if (sessionId != null) {
      setState(() => _model.resendCount++);
      _startTimer(); // 타이머 재시작
      _showInfoSnackBar('인증 코드를 재전송했습니다');
    }
  }

  // 타이머 만료 다이얼로그
  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('시간 초과'),
        content: Text('인증 시간이 만료되었습니다. 다시 전송하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 이전 화면으로
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resendOtp();
            },
            child: Text('재전송'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _model.dispose();
    super.dispose();
  }
}
```

### 6. 상태 감시 및 자동 라우팅

```dart
// app.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return MaterialApp.router(
          routerConfig: GoRouter(
            redirect: (context, state) {
              final isLoggedIn = auth.loggedIn;
              final isLoggingIn = state.matchedLocation == '/login';

              // 로그인하지 않은 경우 시작 페이지로
              if (!isLoggedIn && !isLoggingIn) {
                return '/start';
              }

              // 이메일 미인증 사용자는 인증 대기 화면으로
              if (isLoggedIn && !auth.isEmailVerified) {
                return '/email-verification';
              }

              return null;  // 정상 진행
            },
            routes: [...],  // 라우트 정의
          ),
        );
      },
    );
  }
}
```

### 7. 로그아웃 및 계정 관리

```dart
// 프로필 설정 화면
class ProfileSettings extends StatelessWidget {
  final _authProvider = GetIt.instance<AuthProvider>();

  // 로그아웃
  Future<void> handleLogout(BuildContext context) async {
    await _authProvider.signOut();
    context.go('/start');  // 시작 화면으로 이동
  }

  // 비밀번호 변경
  Future<void> changePassword(String newPassword) async {
    final success = await _authProvider.updatePassword(newPassword);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호가 변경되었습니다')),
      );
    }
  }

  // 계정 삭제
  Future<void> deleteAccount(BuildContext context) async {
    // 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('계정 삭제'),
        content: Text('정말로 계정을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _authProvider.deleteAccount(
        confirmationText: 'DELETE',
      );

      if (success) {
        context.go('/start');  // 시작 화면으로 이동
      }
    }
  }
}
```

### 8. Clean Architecture 레이어 통합

```dart
// Presentation → Domain → Data 레이어 연결

// 1. Presentation Layer (UI)
class LoginPageWidget extends StatefulWidget {
  late final AuthProvider _authProvider;  // Provider 사용
}

// 2. Provider (상태 관리)
class AuthProvider extends ChangeNotifier {
  final SignInWithEmailUseCase _signInWithEmailUseCase;  // UseCase 호출

  Future<bool> signInWithEmail(String email, String password) async {
    return await _signInWithEmailUseCase.execute(
      email: email,
      password: password,
    );
  }
}

// 3. Domain Layer (비즈니스 로직)
class SignInWithEmailUseCase {
  final IAuthRepository _repository;  // Repository 인터페이스 사용

  Future<AuthUser?> execute({required String email, required String password}) {
    // 비즈니스 규칙 적용
    if (!_isValidEmail(email)) throw InvalidEmail();
    return _repository.signInWithEmailAndPassword(email, password);
  }
}

// 4. Data Layer (실제 구현)
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;  // Firebase 실제 호출

  Future<AuthUser?> signInWithEmailAndPassword(String email, String password) {
    // Firebase Auth 호출
    return _firebaseAuth.signInWithEmailAndPassword(email, password);
  }
}
```

## 🧪 테스트 고려사항

### Widget 테스트
```dart
testWidgets('로그인 폼 검증', (tester) async {
  await tester.pumpWidget(LoginPageWidget());

  // 빈 필드로 제출
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // 에러 메시지 확인
  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

### Provider 테스트
```dart
test('AuthProvider 로그인 상태 변경', () async {
  final provider = AuthProvider();

  expect(provider.isLoading, false);

  await provider.signInWithEmail('test@example.com', 'password');

  expect(provider.currentUser, isNotNull);
});
```

## 📊 파일 통계

- **총 파일 수**: 31개
- **화면 Widget**: 8개
- **화면 Model**: 7개
- **컴포넌트**: 13개
- **Provider**: 1개
- **Index**: 1개

## 🔗 관련 문서

- [Domain Layer](../domain/README.md) - 비즈니스 로직
- [Data Layer](../data/README.md) - 데이터 접근
- [Feature Overview](../docs/FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](../docs/API_REFERENCE.md) - API 명세