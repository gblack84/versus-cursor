# Auth Feature - 사용 가이드 & 아키텍처

## 🏗️ 아키텍처 개요

### Clean Architecture v4.0 구조
```
lib/features/auth/
├── domain/              # 비즈니스 규칙 (독립적)
│   ├── models/         # 도메인 엔티티
│   ├── repositories/   # Repository 인터페이스
│   ├── usecases/      # 비즈니스 로직
│   └── failures/      # 도메인 예외
│
├── data/               # 데이터 레이어
│   ├── repositories/   # Repository 구현체
│   ├── datasources/   # 원격/로컬 데이터 소스
│   ├── adapters/      # 레거시 어댑터
│   ├── dto/          # Data Transfer Objects
│   └── mappers/      # 데이터 변환
│
├── presentation/       # UI 레이어
│   ├── providers/     # 상태 관리
│   ├── screens/       # 화면 위젯
│   │   ├── login/
│   │   ├── signup/
│   │   ├── phone_auth/
│   │   └── email_verification/
│   └── index.dart     # Public API
│
└── docs/              # 문서
    ├── FEATURE_OVERVIEW.md
    ├── API_REFERENCE.md
    └── USAGE_GUIDE.md
```

### 계층 간 의존성 규칙
```
Presentation → Domain ← Data

✅ 허용:
- Presentation이 Domain 참조
- Data가 Domain 참조

❌ 금지:
- Domain이 다른 레이어 참조
- Presentation이 Data 직접 참조
```

## 🚀 빠른 시작

### 1. 의존성 설정
```yaml
# pubspec.yaml
dependencies:
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.0
  get_it: ^7.6.0
  google_sign_in: ^6.2.0
  sign_in_with_apple: ^5.0.0
```

### 2. 초기화
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 의존성 주입 설정
  setupDependencies();

  // Auth Provider 초기화
  final authProvider = GetIt.instance<AuthProvider>();
  await authProvider.initialize();

  runApp(MyApp());
}
```

### 3. GetIt 설정
```dart
// app/di.dart
void setupDependencies() {
  final getIt = GetIt.instance;

  // Auth Feature 등록
  getIt.registerLazySingleton<AuthProvider>(
    () => AuthProvider()
  );
}
```

## 📖 사용 예제

### 이메일 로그인 구현
```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GetIt에서 AuthProvider 가져오기
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    // 로딩 상태 표시
    setState(() => _isLoading = true);

    try {
      // 로그인 시도
      final success = await _authProvider.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (success) {
        // 홈 화면으로 이동
        context.go('/home');
      } else {
        // 에러 메시지 표시
        _showError(_authProvider.errorMessage ?? '로그인 실패');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(controller: _emailController),
          TextField(controller: _passwordController),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text('로그인'),
          ),
        ],
      ),
    );
  }
}
```

### 소셜 로그인 구현
```dart
class SocialLoginButtons extends StatelessWidget {
  final authProvider = GetIt.instance<AuthProvider>();

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final success = await authProvider.signInWithGoogle();

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google 로그인 실패')),
      );
    }
  }

  Future<void> _handleAppleLogin(BuildContext context) async {
    final success = await authProvider.signInWithApple();

    if (success) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.g_mobiledata),
          label: Text('Google로 계속'),
          onPressed: () => _handleGoogleLogin(context),
        ),
        if (Platform.isIOS)
          ElevatedButton.icon(
            icon: Icon(Icons.apple),
            label: Text('Apple로 계속'),
            onPressed: () => _handleAppleLogin(context),
          ),
      ],
    );
  }
}
```

### SMS 인증 구현
```dart
class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final authProvider = GetIt.instance<AuthProvider>();
  String? _sessionId;
  int _resendCount = 0;

  Future<void> _sendOtp() async {
    // 재전송 제한 확인
    if (_resendCount >= 3) {
      // PhonemaximumWidget 표시
      await showDialog(
        context: context,
        builder: (_) => PhonemaximumWidget(),
      );
      return;
    }

    _sessionId = await authProvider.sendSmsOtp('+821012345678');
    _resendCount++;

    if (_sessionId != null) {
      // OTP 입력 화면으로
      _showOtpInput();
    }
  }

  Future<void> _verifyOtp(String otp) async {
    if (_sessionId == null) return;

    final success = await authProvider.verifySmsOtp(_sessionId!, otp);

    if (success) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: '전화번호'),
        ),
        ElevatedButton(
          onPressed: _sendOtp,
          child: Text('인증번호 전송'),
        ),
      ],
    );
  }
}
```

### 이메일 인증 처리
```dart
class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final authProvider = GetIt.instance<AuthProvider>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    // 2초마다 인증 상태 확인
    _timer = Timer.periodic(Duration(seconds: 2), (_) async {
      await authProvider.checkEmailVerificationStatus();

      if (authProvider.isEmailVerified) {
        _timer?.cancel();
        // 인증 완료, 다음 화면으로
        context.go('/profile-setup');
      }
    });
  }

  Future<void> _resendEmail() async {
    await authProvider.sendEmailVerification();
    _showSnackBar('인증 메일을 재전송했습니다');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupTimerEmailWidget(); // 타이머 표시 위젯
  }
}
```

### 로그아웃 및 계정 삭제
```dart
class ProfileSettings extends StatelessWidget {
  final authProvider = GetIt.instance<AuthProvider>();

  Future<void> _handleSignOut(BuildContext context) async {
    await authProvider.signOut();
    context.go('/start');
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    // 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('계정 삭제'),
        content: Text('정말 삭제하시겠습니까? "DELETE"를 입력하세요.'),
        // ... 입력 필드
      ),
    );

    if (confirm == true) {
      final success = await authProvider.deleteAccount(
        confirmationText: 'DELETE',
      );

      if (success) {
        context.go('/start');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text('로그아웃'),
          onTap: () => _handleSignOut(context),
        ),
        ListTile(
          title: Text('계정 삭제'),
          onTap: () => _handleDeleteAccount(context),
        ),
      ],
    );
  }
}
```

## 🔄 상태 관리 패턴

### ChangeNotifier 패턴
```dart
// Provider 상태 감시
class AuthStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return CircularProgressIndicator();
        }

        if (auth.currentUser != null) {
          return Text('안녕하세요, ${auth.currentUser!.displayName}님');
        }

        return Text('로그인해주세요');
      },
    );
  }
}
```

### Stream 패턴
```dart
// 실시간 인증 상태 감시
class AuthStreamWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BaseAuthUser?>(
      stream: authUserStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        }
        return LoginScreen();
      },
    );
  }
}
```

## 🛠️ 고급 기능

### 재인증 처리
```dart
Future<void> performSensitiveOperation() async {
  final authProvider = GetIt.instance<AuthProvider>();

  // 재인증 필요 여부 확인
  if (await authProvider.needsReAuthentication()) {
    // 재인증 요청
    final password = await _showPasswordDialog();

    try {
      await authProvider.reAuthenticate(password);
      // 민감한 작업 수행
      await authProvider.updatePassword('newPassword123');
    } on RequiresRecentLogin {
      _showError('보안을 위해 다시 로그인해주세요');
      context.go('/login');
    }
  }
}
```

### 커스텀 에러 처리
```dart
class AuthErrorHandler {
  static String getErrorMessage(AuthFailure failure) {
    switch (failure.runtimeType) {
      case InvalidEmailFailure:
        return '올바른 이메일 형식이 아닙니다';
      case WrongPasswordFailure:
        return '비밀번호가 일치하지 않습니다';
      case UserNotFoundFailure:
        return '등록되지 않은 사용자입니다';
      case EmailAlreadyInUseFailure:
        return '이미 사용 중인 이메일입니다';
      case WeakPasswordFailure:
        return '비밀번호는 6자 이상이어야 합니다';
      case TooManyRequestsFailure:
        return '너무 많은 요청입니다. 잠시 후 다시 시도해주세요';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요';
    }
  }
}
```

### 테스트 모드
```dart
// 개발/테스트용 빠른 로그인
class TestAccountButtons extends StatelessWidget {
  final authProvider = GetIt.instance<AuthProvider>();

  Future<void> _createTestAccount() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'test_$timestamp@example.com';
    final password = 'test123456';

    await authProvider.signUpWithEmail(email, password);

    // 테스트 계정 정보 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('test_email', email);
    await prefs.setString('test_password', password);
  }

  @override
  Widget build(BuildContext context) {
    return kDebugMode
      ? ElevatedButton(
          onPressed: _createTestAccount,
          child: Text('테스트 계정 생성'),
        )
      : SizedBox.shrink();
  }
}
```

## 🔐 보안 고려사항

### 1. 비밀번호 보안
- 최소 6자 이상 강제
- 특수문자/숫자 조합 권장
- 재설정 링크 유효기간 제한

### 2. SMS 보안
- 3회 재전송 제한
- 2분 OTP 유효기간
- 전화번호 형식 검증

### 3. 세션 보안
- JWT 토큰 자동 갱신
- 30일 후 재로그인 요구
- 민감한 작업 시 재인증

### 4. 데이터 보호
- 비밀번호 해싱 (Firebase 자동)
- HTTPS 통신
- 로컬 저장소 암호화

## 🧪 테스트

### 단위 테스트
```dart
// test/auth_provider_test.dart
void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authProvider = AuthProvider(repository: mockRepository);
    });

    test('로그인 성공 테스트', () async {
      when(mockRepository.signInWithEmailAndPassword(any, any))
        .thenAnswer((_) async => testUser);

      final success = await authProvider.signInWithEmail(
        'test@example.com',
        'password123'
      );

      expect(success, true);
      expect(authProvider.currentUser, isNotNull);
    });
  });
}
```

### 통합 테스트
```dart
// integration_test/auth_flow_test.dart
void main() {
  testWidgets('전체 인증 플로우 테스트', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 시작 화면
    expect(find.text('시작하기'), findsOneWidget);

    // 로그인 화면으로
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    // 이메일/비밀번호 입력
    await tester.enterText(
      find.byType(TextField).first,
      'test@example.com'
    );
    await tester.enterText(
      find.byType(TextField).last,
      'password123'
    );

    // 로그인 버튼 탭
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    // 홈 화면 확인
    expect(find.text('홈'), findsOneWidget);
  });
}
```

## 🚀 배포 체크리스트

### 개발 환경
- [ ] Firebase 프로젝트 생성
- [ ] Authentication 활성화
- [ ] 로그인 방법 설정
- [ ] 테스트 사용자 추가

### 프로덕션 준비
- [ ] API 키 보안 설정
- [ ] Rate limiting 설정
- [ ] 에러 로깅 구성
- [ ] 분석 도구 연동

### 플랫폼별 설정
- [ ] iOS: Info.plist 설정
- [ ] Android: SHA 인증서 등록
- [ ] Web: 도메인 허용 목록

## 📚 추가 리소스

### 공식 문서
- [Firebase Auth 문서](https://firebase.google.com/docs/auth)
- [Flutter Firebase 패키지](https://firebase.flutter.dev/docs/auth/overview)
- [Clean Architecture 가이드](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### 프로젝트 문서
- [Feature Overview](./FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](./API_REFERENCE.md) - API 상세 명세
- [Migration Guide](../MIGRATION_GUIDE.md) - 마이그레이션 가이드

### 문의 및 지원
- 이슈 트래커: GitHub Issues
- 이메일: support@versusspace.com
- 디스코드: VersusSpace 개발자 채널