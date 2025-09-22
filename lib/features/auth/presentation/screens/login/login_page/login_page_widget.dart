import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/create_test_account_usecase.dart';
import '/features/auth/domain/factories/auth_repository_factory.dart';
import '/features/auth/presentation/screens/login/components/email_login_form.dart';
import '/features/auth/presentation/screens/login/components/test_account_buttons.dart';
import '/features/auth/presentation/screens/login/components/login_buttons.dart';
import '/features/auth/presentation/screens/login/components/create_account_link.dart';
import '/testpage_select/testpage_select_widget.dart';
import '/features/auth/presentation/screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart';
import '/features/auth/presentation/screens/signup/create_account/create_account_widget.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_page_model.dart';
export 'login_page_model.dart';

class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});

  static String routeName = 'Login_page';
  static String routePath = '/loginPage';

  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends State<LoginPageWidget>
    with TickerProviderStateMixin {
  late LoginPageModel _model;
  SignInWithEmailUseCase? _signInWithEmailUseCase;
  CreateTestAccountUseCase? _createTestAccountUseCase;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  Future<void> _initializeUseCases() async {
    // Factory를 통한 Repository 생성 (Clean Architecture 준수)
    final repository = await AuthRepositoryFactory.create();

    // UseCase 초기화
    setState(() {
      _signInWithEmailUseCase = SignInWithEmailUseCase(repository: repository);
      _createTestAccountUseCase = CreateTestAccountUseCase(repository: repository);
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPageModel());

    // UseCase 초기화 (Phase 2.6에서 DI로 대체 예정)
    _initializeUseCases();

    _model.emailAddressLoginTextController ??= TextEditingController();
    _model.emailAddressLoginFocusNode ??= FocusNode();

    _model.passwordLoginTextController ??= TextEditingController();
    _model.passwordLoginFocusNode ??= FocusNode();

    animationsMap.addAll({
      'columnOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 400.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 400.0.ms,
            begin: Offset(0.0, 60.0),
            end: Offset(0.0, 0.0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 200.0.ms,
            duration: 400.0.ms,
            begin: Offset(-0.349, 0),
            end: Offset(0, 0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper method for email login
  Future<void> _handleEmailLogin() async {
    // UseCase가 아직 초기화되지 않았으면 리턴
    if (_signInWithEmailUseCase == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('시스템을 초기화 중입니다. 잠시 후 다시 시도해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    GoRouter.of(context).prepareAuthEvent();

    final user = await _signInWithEmailUseCase!.execute(
      email: _model.emailAddressLoginTextController.text,
      password: _model.passwordLoginTextController.text,
    );

    if (user == null) {
      // UI 피드백: 로그인 실패 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      context.pushNamedAuth(
        TestpageSelectWidget.routeName,
        context.mounted,
        extra: <String, dynamic>{
          kTransitionInfoKey: TransitionInfo(
            hasTransition: true,
            duration: Duration(milliseconds: 500),
          ),
        },
      );
    }
  }

  // Helper method for test account login
  Future<void> _handleTestAccountLogin({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? platform,
  }) async {
    // UseCase가 아직 초기화되지 않았으면 리턴
    if (_createTestAccountUseCase == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('시스템을 초기화 중입니다. 잠시 후 다시 시도해주세요.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    GoRouter.of(context).prepareAuthEvent();

    final result = await _createTestAccountUseCase!.execute(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
      platform: platform,
    );

    // UI 피드백: 결과에 따라 적절한 메시지 표시
    if (!result.success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? '테스트 계정 생성/로그인에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 성공 메시지 표시
    if (context.mounted && result.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message!),
          backgroundColor: Colors.green,
        ),
      );
    }

    if (context.mounted) {
      context.pushNamedAuth(
        TestpageSelectWidget.routeName,
        context.mounted,
      );
    }
  }

  void _handlePhoneLogin() {
    context.pushNamed(
      PhoneCreatAccountWidget.routeName,
      queryParameters: {
        'phoneNumberParam': serializeParam(
          '',
          ParamType.String,
        ),
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          duration: Duration(milliseconds: 500),
        ),
      },
    );
  }

  void _handleCreateAccount() async {
    context.pushNamed(
      CreateAccountWidget.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          duration: Duration(milliseconds: 900),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFECECEC),
              ),
              child: Form(
                key: _model.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Header Image
                      Container(
                        width: double.infinity,
                        height: 350.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.asset(
                              'assets/images/20250402_1128____remix_01jqt58d7tey2bhvkccgczdtsg.png',
                            ).image,
                          ),
                        ),
                      ),
                      // Login Form Container
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email & Password Form Fields
                              EmailLoginForm(
                                emailController:
                                    _model.emailAddressLoginTextController!,
                                passwordController:
                                    _model.passwordLoginTextController!,
                                emailFocusNode:
                                    _model.emailAddressLoginFocusNode!,
                                passwordFocusNode:
                                    _model.passwordLoginFocusNode!,
                                passwordVisibility:
                                    _model.passwordLoginVisibility,
                                onPasswordVisibilityToggle: () => setState(
                                  () => _model.passwordLoginVisibility =
                                      !_model.passwordLoginVisibility,
                                ),
                                emailValidator: _model
                                    .emailAddressLoginTextControllerValidator
                                    .asValidator(context),
                                passwordValidator: _model
                                    .passwordLoginTextControllerValidator
                                    .asValidator(context),
                              ),
                              // Login Buttons (Email & Phone)
                              LoginButtons(
                                onEmailLogin: _handleEmailLogin,
                                onPhoneLogin: _handlePhoneLogin,
                              ),
                              // Test Account Buttons (Development Only)
                              if (kDebugMode || kProfileMode)
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 16.0, 0.0, 0.0),
                                  child: TestAccountButtons(
                                    onTestAccountLogin: _handleTestAccountLogin,
                                  ),
                                ),
                              // Create Account Link
                              CreateAccountLink(
                                onTap: _handleCreateAccount,
                              ),
                            ],
                          ).animateOnPageLoad(
                              animationsMap['columnOnPageLoadAnimation']!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}