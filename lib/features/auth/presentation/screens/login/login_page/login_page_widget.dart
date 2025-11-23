import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_space/gen/assets.gen.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/presentation/providers/usecase_providers.dart';
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

// Phase 10: LoginPageModel → Riverpod 3.x (TextField-only → Widget class)

class LoginPageWidget extends ConsumerStatefulWidget {
  const LoginPageWidget({super.key});

  static String routeName = 'Login_page';
  static String routePath = '/loginPage';

  @override
  ConsumerState<LoginPageWidget> createState() => _LoginPageWidgetState();
}

class _LoginPageWidgetState extends ConsumerState<LoginPageWidget>
    with TickerProviderStateMixin {
  // Phase 10: TextField controllers and validators (moved from LoginPageModel)
  final formKey = GlobalKey<FormState>();
  late final FocusNode _emailAddressLoginFocusNode;
  late final TextEditingController _emailAddressLoginTextController;
  late final FocusNode _passwordLoginFocusNode;
  late final TextEditingController _passwordLoginTextController;
  late bool _passwordLoginVisibility;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Email validator
  String? _emailAddressLoginTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return AppLocalizations.of(context).getText(
        'zodqb7tr' /* Please enter a valid email add... */,
      );
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Has to be a valid email address.';
    }
    return null;
  }

  // Password validator
  String? _passwordLoginTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return AppLocalizations.of(context).getText(
        'a3s2kg05' /* Password must be at least 6 ch... */,
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Phase 10: Initialize TextField controllers (moved from LoginPageModel)
    _emailAddressLoginTextController = TextEditingController();
    _emailAddressLoginFocusNode = FocusNode();
    _passwordLoginTextController = TextEditingController();
    _passwordLoginFocusNode = FocusNode();
    _passwordLoginVisibility = false;

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    // Phase 10: Dispose TextField controllers (moved from LoginPageModel)
    _emailAddressLoginFocusNode.dispose();
    _emailAddressLoginTextController.dispose();
    _passwordLoginFocusNode.dispose();
    _passwordLoginTextController.dispose();

    super.dispose();
  }

  // Helper method for email login - Riverpod Pattern
  Future<void> _handleEmailLogin() async {
    // 로딩 중이면 리턴
    final isLoading = ref.read(authLoadingProvider);
    if (isLoading) {
      return;
    }

    // Phase 1: prepareAuthEvent() 제거 (AppStateNotifier 제거로 불필요)
    // Riverpod은 자동으로 auth 상태 변경을 감지합니다

    // 로딩 시작
    ref.read(authLoadingProvider.notifier).setLoading(true);

    // UseCase 실행
    final signInUseCase = ref.read(signInWithEmailUseCaseProvider);
    final result = await signInUseCase.execute(
      email: _emailAddressLoginTextController.text,
      password: _passwordLoginTextController.text,
    );

    // 결과 처리
    result.fold(
      (failure) {
        // 실패 처리
        ref.read(authErrorProvider.notifier).setError(failure.message);
        ref.read(authLoadingProvider.notifier).setLoading(false);

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
        ref.read(authLoadingProvider.notifier).setLoading(false);

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

    // Phase 1: prepareAuthEvent() 제거 (AppStateNotifier 제거로 불필요)
    // Riverpod은 자동으로 auth 상태 변경을 감지합니다

    // 로딩 시작
    ref.read(authLoadingProvider.notifier).setLoading(true);

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
            ref.read(authErrorProvider.notifier).setError(signUpFailure.message);
            ref.read(authLoadingProvider.notifier).setLoading(false);

            if (context.mounted) {
              ErrorHandler.handle(
                signUpFailure.message,
                customMessage: '테스트 계정 생성/로그인에 실패했습니다.',
                context: context,
              );
            }
          },
          (user) {
            ref.read(authLoadingProvider.notifier).setLoading(false);

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
        ref.read(authLoadingProvider.notifier).setLoading(false);

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
                key: formKey,
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
                            image: Assets.images_login_header.provider(),
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
                                    _emailAddressLoginTextController,
                                passwordController:
                                    _passwordLoginTextController,
                                emailFocusNode:
                                    _emailAddressLoginFocusNode,
                                passwordFocusNode:
                                    _passwordLoginFocusNode,
                                passwordVisibility:
                                    _passwordLoginVisibility,
                                onPasswordVisibilityToggle: () => setState(
                                  () => _passwordLoginVisibility =
                                      !_passwordLoginVisibility,
                                ),
                                emailValidator: (val) =>
                                    _emailAddressLoginTextControllerValidator(context, val),
                                passwordValidator: (val) =>
                                    _passwordLoginTextControllerValidator(context, val),
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
                          ),
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