import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:uuid/uuid.dart';
import '/services/error/error_handler_service.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/presentation/providers/usecase_providers.dart';
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

// Phase 10: CreateAccountModel → Riverpod 3.x (TextField-only → Widget class)

class CreateAccountWidget extends ConsumerStatefulWidget {
  const CreateAccountWidget({super.key});

  static String routeName = 'Create_Account';
  static String routePath = '/createAccount';

  @override
  ConsumerState<CreateAccountWidget> createState() => _CreateAccountWidgetState();
}

class _CreateAccountWidgetState extends ConsumerState<CreateAccountWidget> {
  // Phase 10: TextField controllers and validators (moved from CreateAccountModel)
  final formKey = GlobalKey<FormState>();
  late final FocusNode _emailAddressFocusNode;
  late final TextEditingController _emailAddressTextController;
  late final FocusNode _passwordFocusNode;
  late final TextEditingController _passwordTextController;
  late bool _passwordVisibility;
  late final FocusNode _passwordConfirmFocusNode;
  late final TextEditingController _passwordConfirmTextController;
  late bool _passwordConfirmVisibility;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Email validator
  String? _emailAddressTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return AppLocalizations.of(context).getText(
        'sfx28arj' /* Email is required */,
      );
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return AppLocalizations.of(context).getText(
        'fg4iipv6' /* Please enter a valid email add... */,
      );
    }
    return null;
  }

  // Password validator
  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return AppLocalizations.of(context).getText(
        'c10h5qqp' /* Password is required */,
      );
    }

    if (!RegExp(
            '^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@\$!%*#?&])[A-Za-z\\d@\$!%*#?&]{8,15}\$')
        .hasMatch(val)) {
      return AppLocalizations.of(context).getText(
        'nlyzshnr' /* Please enter at least 8 charac... */,
      );
    }
    return null;
  }

  // Password confirm validator
  String? _passwordConfirmTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return AppLocalizations.of(context).getText(
        'dv9ttawj' /* Confirm Password is required */,
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Phase 10: Initialize TextField controllers (moved from CreateAccountModel)
    _emailAddressTextController = TextEditingController();
    _emailAddressFocusNode = FocusNode();
    _passwordTextController = TextEditingController();
    _passwordFocusNode = FocusNode();
    _passwordVisibility = false;
    _passwordConfirmTextController = TextEditingController();
    _passwordConfirmFocusNode = FocusNode();
    _passwordConfirmVisibility = false;

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    // Phase 10: Dispose TextField controllers (moved from CreateAccountModel)
    _emailAddressFocusNode.dispose();
    _emailAddressTextController.dispose();
    _passwordFocusNode.dispose();
    _passwordTextController.dispose();
    _passwordConfirmFocusNode.dispose();
    _passwordConfirmTextController.dispose();

    super.dispose();
  }

  // Helper method for email signup
  Future<void> _handleEmailSignup() async {
    if (formKey.currentState == null ||
        !formKey.currentState!.validate()) {
      return;
    }
    if (_passwordTextController.text !=
        _passwordConfirmTextController.text) {
      BotToast.showText(text: '비밀번호가 일치하지 않습니다!');
      return;
    }

    // 로딩 중이면 리턴
    final isLoading = ref.read(authLoadingProvider);
    if (isLoading) {
      return;
    }

    // 로딩 시작
    ref.read(authLoadingProvider.notifier).setLoading(true);

    // 계정 생성
    final eventId = const Uuid().v4(); // Generate UUID for idempotency
    final signUpUseCase = ref.read(signUpWithEmailUseCaseProvider);
    final result = await signUpUseCase.execute(
      email: _emailAddressTextController.text,
      password: _passwordTextController.text,
      eventId: eventId,
    );

    // 결과 처리
    await result.fold(
      (failure) async {
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
      (user) async {
        // 성공 처리 - 이메일 인증 발송
        final emailVerificationUseCase = ref.read(emailVerificationUseCaseProvider);
        await emailVerificationUseCase.sendVerificationEmail(
          userId: user.uid,
          eventId: const Uuid().v4(),
        );

        ref.read(authLoadingProvider.notifier).setLoading(false);

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
      },
    );
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
                        key: formKey,
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
                                  emailController: _emailAddressTextController,
                                  passwordController: _passwordTextController,
                                  passwordConfirmController: _passwordConfirmTextController,
                                  emailFocusNode: _emailAddressFocusNode,
                                  passwordFocusNode: _passwordFocusNode,
                                  passwordConfirmFocusNode: _passwordConfirmFocusNode,
                                  passwordVisibility: _passwordVisibility,
                                  passwordConfirmVisibility: _passwordConfirmVisibility,
                                  onPasswordVisibilityToggle: () => setState(
                                    () => _passwordVisibility = !_passwordVisibility,
                                  ),
                                  onPasswordConfirmVisibilityToggle: () => setState(
                                    () => _passwordConfirmVisibility = !_passwordConfirmVisibility,
                                  ),
                                  emailValidator: (val) =>
                                      _emailAddressTextControllerValidator(context, val),
                                  passwordValidator: (val) =>
                                      _passwordTextControllerValidator(context, val),
                                  passwordConfirmValidator: (val) =>
                                      _passwordConfirmTextControllerValidator(context, val),
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