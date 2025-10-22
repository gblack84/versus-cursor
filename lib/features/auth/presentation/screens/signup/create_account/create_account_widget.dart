import 'package:get_it/get_it.dart';
import 'package:bot_toast/bot_toast.dart';
import '/core/utils/error_handler.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/features/auth/presentation/screens/email_verification/popup_timer_email/popup_timer_email_widget.dart';
import '/features/auth/presentation/screens/signup/components/header_section.dart';
import '/features/auth/presentation/screens/signup/components/signup_form.dart';
import '/features/auth/presentation/screens/signup/components/signup_buttons.dart';
import '/features/auth/presentation/screens/signup/components/terms_section.dart';
import '/features/auth/presentation/screens/signup/components/login_link.dart';
import '/features/auth/presentation/screens/login/login_page/login_page_widget.dart';
import '/features/auth/presentation/screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart';
import '/features/profile/presentation/screens/user_info_input/user_info_input_widget.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'create_account_model.dart';
export 'create_account_model.dart';

class CreateAccountWidget extends StatefulWidget {
  const CreateAccountWidget({super.key});

  static String routeName = 'Create_Account';
  static String routePath = '/createAccount';

  @override
  State<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends State<CreateAccountWidget> {
  late CreateAccountModel _model;
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAccountModel());

    // AuthProvider 초기화 확인 (GetIt에서 가져온 Singleton)
    if (!_authProvider.isInitialized) {
      _authProvider.initialize();
    }

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.passwordConfirmTextController ??= TextEditingController();
    _model.passwordConfirmFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper method for email signup
  Future<void> _handleEmailSignup() async {
    if (_model.formKey.currentState == null ||
        !_model.formKey.currentState!.validate()) {
      return;
    }
    if (_model.passwordTextController.text !=
        _model.passwordConfirmTextController.text) {
      BotToast.showText(text: '비밀번호가 일치하지 않습니다!');
      return;
    }

    // 로딩 중이면 리턴
    if (_authProvider.isLoading) {
      return;
    }

    // 계정 생성
    final success = await _authProvider.signUpWithEmail(
      email: _model.emailAddressTextController.text,
      password: _model.passwordTextController.text,
    );

    if (!success) {
      // UI 피드백: 회원가입 실패 메시지 표시
      if (context.mounted) {
        ErrorHandler.handle(
          _authProvider.errorMessage ?? '계정 생성에 실패했습니다. 다시 시도해주세요.',
          customMessage: _authProvider.errorMessage ?? '계정 생성에 실패했습니다. 다시 시도해주세요.',
          context: context,
        );
      }
      return;
    }

    // 이메일 인증 발송
    await _authProvider.sendEmailVerification();

    if (context.mounted) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            alignment: AlignmentDirectional(0.0, 0.0)
                .resolve(Directionality.of(context)),
            child: WebViewAware(
              child: PopupTimerEmailWidget(),
            ),
          );
        },
      );

      context.pushNamedAuth(
        UserInfoInputWidget.routeName,
        context.mounted,
      );
    }
  }

  // Helper method for phone signup navigation
  void _handlePhoneSignup() {
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

  // Helper method for login link
  void _handleLoginLink() {
    context.pushNamed(LoginPageWidget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).secondaryBackground,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: 8,
            child: Container(
              width: 100.0,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFECECEC),
              ),
              alignment: AlignmentDirectional(0.0, -1.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    HeaderSection(),
                    // Form Container
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Form(
                        key: _model.formKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: Container(
                          width: 380.0,
                          decoration: BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Signup Form
                                SignupForm(
                                  emailController: _model.emailAddressTextController!,
                                  passwordController: _model.passwordTextController!,
                                  passwordConfirmController: _model.passwordConfirmTextController!,
                                  emailFocusNode: _model.emailAddressFocusNode!,
                                  passwordFocusNode: _model.passwordFocusNode!,
                                  passwordConfirmFocusNode: _model.passwordConfirmFocusNode!,
                                  passwordVisibility: _model.passwordVisibility,
                                  passwordConfirmVisibility: _model.passwordConfirmVisibility,
                                  onPasswordVisibilityToggle: () => setState(
                                    () => _model.passwordVisibility = !_model.passwordVisibility,
                                  ),
                                  onPasswordConfirmVisibilityToggle: () => setState(
                                    () => _model.passwordConfirmVisibility = !_model.passwordConfirmVisibility,
                                  ),
                                  emailValidator: _model.emailAddressTextControllerValidator
                                      .asValidator(context),
                                  passwordValidator: _model.passwordTextControllerValidator
                                      .asValidator(context),
                                  passwordConfirmValidator: _model.passwordConfirmTextControllerValidator
                                      .asValidator(context),
                                ),
                                // Signup Buttons
                                SignupButtons(
                                  onEmailSignup: _handleEmailSignup,
                                  onPhoneSignup: _handlePhoneSignup,
                                ),
                                // Terms Section
                                TermsSection(),
                                // Login Link
                                LoginLink(
                                  onTap: _handleLoginLink,
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}