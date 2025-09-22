import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/features/auth/domain/usecases/create_account_with_email_usecase.dart';
import '/features/auth/domain/usecases/send_email_verification_usecase.dart';
import '/features/auth/data/repositories/auth_repository_impl.dart';
import '/features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import '/features/auth/data/datasources/auth_local_datasource.dart';
import '/features/auth/data/adapters/auth_util.dart';
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
  CreateAccountWithEmailUseCase? _createAccountWithEmailUseCase;
  SendEmailVerificationUseCase? _sendEmailVerificationUseCase;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _initializeUseCases() async {
    // Phase 2.6에서 DI로 대체 예정
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalDataSource(prefs: prefs);

    final repository = AuthRepositoryImpl(
      remoteDataSource: FirebaseAuthRemoteDataSource(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        googleSignIn: GoogleSignIn(),
      ),
      localDataSource: localDataSource,
    );

    setState(() {
      _createAccountWithEmailUseCase = CreateAccountWithEmailUseCase(repository: repository);
      _sendEmailVerificationUseCase = SendEmailVerificationUseCase(repository: repository);
    });
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateAccountModel());

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    _model.passwordConfirmTextController ??= TextEditingController();
    _model.passwordConfirmFocusNode ??= FocusNode();

    // UseCase 초기화
    _initializeUseCases();

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords don\'t match!'),
        ),
      );
      return;
    }

    // UseCase가 초기화되지 않았으면 대기
    if (_createAccountWithEmailUseCase == null || _sendEmailVerificationUseCase == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Initializing... Please wait.'),
        ),
      );
      return;
    }

    // 계정 생성
    final authUser = await _createAccountWithEmailUseCase!.execute(
      email: _model.emailAddressTextController.text,
      password: _model.passwordTextController.text,
    );
    if (authUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account. Please try again.'),
        ),
      );
      return;
    }

    // 이메일 인증 발송
    await _sendEmailVerificationUseCase!.execute();
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

    if (context.mounted) {
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