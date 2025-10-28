import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/presentation/screens/login/components/email_login_form.dart';
import '/features/auth/presentation/screens/login/components/test_account_buttons.dart';
import '/features/auth/presentation/screens/login/components/login_buttons.dart';
import '/features/auth/presentation/screens/login/components/create_account_link.dart';
import '/testpage_select/testpage_select_widget.dart';
import '/features/auth/presentation/screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart';
import '/features/auth/presentation/screens/signup/create_account/create_account_widget.dart';
import '/core_exports.dart';
import '/core/utils/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_page_model.dart';
export 'login_page_model.dart';

class LoginPageWidget extends ConsumerStatefulWidget {
  const LoginPageWidget({super.key});

  static String routeName = 'Login_page';
  static String routePath = '/loginPage';

  @override
  ConsumerState<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends ConsumerState<LoginPageWidget>
    with TickerProviderStateMixin {
  late LoginPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginPageModel());

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

  // Helper method for email login - Riverpod Pattern
  Future<void> _handleEmailLogin() async {
    // 로딩 중이면 리턴
    final isLoading = ref.read(authLoadingProvider);
    if (isLoading) {
      return;
    }

    GoRouter.of(context).prepareAuthEvent();

    // 로딩 시작
    ref.read(authLoadingProvider.notifier).state = true;

    // UseCase 실행
    final signInUseCase = ref.read(signInWithEmailUseCaseProvider);
    final result = await signInUseCase.execute(
      email: _model.emailAddressLoginTextController.text,
      password: _model.passwordLoginTextController.text,
    );

    // 결과 처리
    result.fold(
      (failure) {
        // 실패 처리
        ref.read(authErrorProvider.notifier).state = failure.message;
        ref.read(authLoadingProvider.notifier).state = false;

        if (context.mounted) {
          ErrorHandler.handle(
            failure.message,
            customMessage: failure.message,
            context: context,
          );
        }
      },
      (user) {
        // 성공 처리
        ref.read(authLoadingProvider.notifier).state = false;

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
      },
    );
  }

  // Helper method for test account login - Riverpod Pattern
  Future<void> _handleTestAccountLogin({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? platform,
  }) async {
    // 로딩 중이면 리턴
    final isLoading = ref.read(authLoadingProvider);
    if (isLoading) {
      return;
    }

    GoRouter.of(context).prepareAuthEvent();

    // 로딩 시작
    ref.read(authLoadingProvider.notifier).state = true;

    // 테스트 계정은 일반 로그인으로 처리 (계정이 이미 존재한다고 가정)
    final signInUseCase = ref.read(signInWithEmailUseCaseProvider);
    final signInResult = await signInUseCase.execute(
      email: email,
      password: password,
    );

    // 로그인 실패 시 회원가입 시도
    await signInResult.fold(
      (failure) async {
        // 계정이 없으면 회원가입 시도
        final signUpUseCase = ref.read(signUpWithEmailUseCaseProvider);
        final signUpResult = await signUpUseCase.execute(
          email: email,
          password: password,
          displayName: displayName,
        );

        signUpResult.fold(
          (signUpFailure) {
            ref.read(authErrorProvider.notifier).state = signUpFailure.message;
            ref.read(authLoadingProvider.notifier).state = false;

            if (context.mounted) {
              ErrorHandler.handle(
                signUpFailure.message,
                customMessage: '테스트 계정 생성/로그인에 실패했습니다.',
                context: context,
              );
            }
          },
          (user) {
            ref.read(authLoadingProvider.notifier).state = false;

            if (context.mounted) {
              ErrorHandler.showSuccessToast('테스트 계정으로 로그인되었습니다.');
              context.pushNamedAuth(
                TestpageSelectWidget.routeName,
                context.mounted,
              );
            }
          },
        );
      },
      (user) {
        // 로그인 성공
        ref.read(authLoadingProvider.notifier).state = false;

        if (context.mounted) {
          ErrorHandler.showSuccessToast('테스트 계정으로 로그인되었습니다.');
          context.pushNamedAuth(
            TestpageSelectWidget.routeName,
            context.mounted,
          );
        }
      },
    );
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