import 'package:get_it/get_it.dart';
import '/features/auth/data/adapters/auth_util.dart';
import '/features/profile/domain/repositories/i_user_repository.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
                        child: Stack(
                          children: [],
                        ),
                      ),
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
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller:
                                        _model.emailAddressLoginTextController,
                                    focusNode:
                                        _model.emailAddressLoginFocusNode,
                                    autofocus: true,
                                    autofillHints: [AutofillHints.email],
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        'b6l0k8k2' /* Email */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF57636C),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFE0E3E7),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF4B39EF),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.all(24.0),
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: _model
                                        .emailAddressLoginTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 16.0),
                                child: Container(
                                  width: double.infinity,
                                  child: TextFormField(
                                    controller:
                                        _model.passwordLoginTextController,
                                    focusNode: _model.passwordLoginFocusNode,
                                    autofocus: false,
                                    autofillHints: [AutofillHints.password],
                                    obscureText:
                                        !_model.passwordLoginVisibility,
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        '6l9ekgal' /* Password */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF57636C),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFE0E3E7),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFF4B39EF),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF5963),
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.all(24.0),
                                      suffixIcon: InkWell(
                                        onTap: () => setState(
                                          () => _model.passwordLoginVisibility =
                                              !_model.passwordLoginVisibility,
                                        ),
                                        focusNode:
                                            FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordLoginVisibility
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Color(0xFF57636C),
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: Colors.black,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                    validator: _model
                                        .passwordLoginTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 16.0),
                                  child: AppButtonWidget(
                                    onPressed: () async {
                                      GoRouter.of(context).prepareAuthEvent();

                                      final user =
                                          await authManager.signInWithEmail(
                                        context,
                                        _model.emailAddressLoginTextController
                                            .text,
                                        _model.passwordLoginTextController.text,
                                      );
                                      if (user == null) {
                                        return;
                                      }

                                      // authenticatedUserStream이 currentUser를 설정할 때까지 대기
                                      int attempts = 0;
                                      while (currentUserReference == null && attempts < 20) {
                                        await Future.delayed(const Duration(milliseconds: 500));
                                        attempts++;
                                      }
                                      
                                      if (currentUserReference == null) {
                                        debugPrint('경고: currentUserReference가 설정되지 않음');
                                        // 직접 DocumentReference 생성하여 업데이트
                                        final directRef = FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid);
                                        
                                        await directRef.update({
                                          ...mapToFirestore(
                                            {
                                              'lastActive':
                                                  FieldValue.serverTimestamp(),
                                            },
                                          ),
                                        });
                                      } else {
                                        // 정상적으로 currentUserReference 사용
                                        await currentUserReference!.update({
                                          ...mapToFirestore(
                                            {
                                              'lastActive':
                                                  FieldValue.serverTimestamp(),
                                            },
                                          ),
                                        });
                                      }

                                      context.pushNamedAuth(
                                        TestpageSelectWidget.routeName,
                                        context.mounted,
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey: TransitionInfo(
                                            hasTransition: true,
                                            duration:
                                                Duration(milliseconds: 500),
                                          ),
                                        },
                                      );
                                    },
                                    text: AppLocalizations.of(context).getText(
                                      '4wwn8ov8' /* Log in */,
                                    ),
                                    options: AppButtonOptions(
                                      width: 230.0,
                                      height: 52.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: Colors.black,
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 10.0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 16.0),
                                  child: AppButtonWidget(
                                    onPressed: () async {
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
                                            duration:
                                                Duration(milliseconds: 500),
                                          ),
                                        },
                                      );
                                    },
                                    text: AppLocalizations.of(context).getText(
                                      'uk1cwrhu' /* Phone Log in */,
                                    ),
                                    options: AppButtonOptions(
                                      width: 230.0,
                                      height: 52.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: Colors.black,
                                      textStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      elevation: 10.0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                              // 테스트 계정 로그인 버튼 (디버그 모드에서만 표시)
                              if (!kReleaseMode)
                                Align(
                                  alignment: AlignmentDirectional(0.0, 0.0),
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 16.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          '테스트 계정',
                                          style: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.plusJakartaSans(),
                                                color: AppTheme.of(context).secondaryText,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // 관리자 계정
                                            AppButtonWidget(
                                              onPressed: () async {
                                                GoRouter.of(context).prepareAuthEvent();
                                                
                                                // 먼저 로그인 시도
                                                var user = await authManager.signInWithEmail(
                                                  context,
                                                  'admin@versus.test',
                                                  'test1234!',
                                                );
                                                
                                                // 계정이 없으면 생성
                                                if (user == null) {
                                                  user = await authManager.createAccountWithEmail(
                                                    context,
                                                    'admin@versus.test',
                                                    'test1234!',
                                                  );
                                                  
                                                  if (user == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('관리자 계정 생성 실패'),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // 사용자 문서 생성
                                                  final usersCreateData = {
                                                    'email': 'admin@versus.test',
                                                    'displayName': '관리자',
                                                    'createdTime': FieldValue.serverTimestamp(),
                                                    'role': 'admin',
                                                    'uid': user.uid,
                                                  };
                                                  // Repository 패턴 사용 - createUser 메서드 활용
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  
                                                  // UserProfile 생성
                                                  await UserProfile.collection.doc(user.uid).set(usersCreateData);
                                                }
                                                
                                                // authenticatedUserStream이 currentUser를 설정할 때까지 대기
                                                int attempts = 0;
                                                while (currentUserReference == null && attempts < 20) {
                                                  await Future.delayed(const Duration(milliseconds: 500));
                                                  attempts++;
                                                }
                                                
                                                if (currentUserReference == null) {
                                                  debugPrint('경고: currentUserReference가 설정되지 않음');
                                                  // 직접 DocumentReference 생성하여 업데이트
                                                  // Repository를 통해 업데이트 (추후 완전 마이그레이션)
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  final directRef = userRepository.getUserReference(user.uid);
                                                  
                                                  await directRef.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'admin',
                                                    }),
                                                  });
                                                } else {
                                                  // 정상적으로 currentUserReference 사용
                                                  await currentUserReference!.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'admin',
                                                    }),
                                                  });
                                                }
                                                
                                                context.pushNamedAuth(
                                                  TestpageSelectWidget.routeName,
                                                  context.mounted,
                                                );
                                              },
                                              text: '관리자',
                                              options: AppButtonOptions(
                                                width: 100.0,
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: AppTheme.of(context).primary,
                                                textStyle: AppTheme.of(context).titleSmall.override(
                                                  font: GoogleFonts.plusJakartaSans(),
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            SizedBox(width: 12.0),
                                            // 플랫폼별 테스트 계정
                                            AppButtonWidget(
                                              onPressed: () async {
                                                GoRouter.of(context).prepareAuthEvent();
                                                
                                                // iOS 플랫폼 고정
                                                final testEmail = 'tester-ios@versus.test';
                                                final testPassword = 'test1234!';
                                                
                                                // 먼저 로그인 시도
                                                var user = await authManager.signInWithEmail(
                                                  context,
                                                  testEmail,
                                                  testPassword,
                                                );
                                                
                                                // 계정이 없으면 생성
                                                if (user == null) {
                                                  user = await authManager.createAccountWithEmail(
                                                    context,
                                                    testEmail,
                                                    testPassword,
                                                  );
                                                  
                                                  if (user == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('iOS 테스터 계정 생성 실패'),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // 사용자 문서 생성
                                                  final usersCreateData = {
                                                    'email': testEmail,
                                                    'displayName': '테스터 (아이폰 16 프로)',
                                                    'createdTime': FieldValue.serverTimestamp(),
                                                    'role': 'tester',
                                                    'platform': 'ios',  // 플랫폼 정보 저장
                                                    'uid': user.uid,
                                                  };
                                                  // Repository 패턴 사용 - createUser 메서드 활용
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  
                                                  // UserProfile 생성
                                                  await UserProfile.collection.doc(user.uid).set(usersCreateData);
                                                }
                                                
                                                // authenticatedUserStream이 currentUser를 설정할 때까지 대기
                                                int attempts = 0;
                                                while (currentUserReference == null && attempts < 20) {
                                                  await Future.delayed(const Duration(milliseconds: 500));
                                                  attempts++;
                                                }
                                                
                                                if (currentUserReference == null) {
                                                  debugPrint('경고: currentUserReference가 설정되지 않음');
                                                  // 직접 DocumentReference 생성하여 업데이트
                                                  // Repository를 통해 업데이트 (추후 완전 마이그레이션)
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  final directRef = userRepository.getUserReference(user.uid);
                                                  
                                                  await directRef.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'ios',
                                                    }),
                                                  });
                                                } else {
                                                  // 정상적으로 currentUserReference 사용
                                                  await currentUserReference!.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'ios',
                                                    }),
                                                  });
                                                }
                                                
                                                context.pushNamedAuth(
                                                  TestpageSelectWidget.routeName,
                                                  context.mounted,
                                                );
                                              },
                                              text: '아이폰 16 프로',
                                              options: AppButtonOptions(
                                                width: 120.0,
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: AppTheme.of(context).secondary,
                                                textStyle: AppTheme.of(context).titleSmall.override(
                                                  font: GoogleFonts.plusJakartaSans(),
                                                  color: Colors.white,
                                                  fontSize: 14.0,
                                                  letterSpacing: 0.0,
                                                ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.0),
                                        // 두 번째 줄: Android, macOS, 웹앱
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Android 테스트 계정
                                            AppButtonWidget(
                                              onPressed: () async {
                                                GoRouter.of(context).prepareAuthEvent();
                                                
                                                final testEmail = 'tester-android@versus.test';
                                                final testPassword = 'test1234!';
                                                
                                                // 먼저 로그인 시도
                                                var user = await authManager.signInWithEmail(
                                                  context,
                                                  testEmail,
                                                  testPassword,
                                                );
                                                
                                                // 계정이 없으면 생성
                                                if (user == null) {
                                                  user = await authManager.createAccountWithEmail(
                                                    context,
                                                    testEmail,
                                                    testPassword,
                                                  );
                                                  
                                                  if (user == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Android 테스터 계정 생성 실패'),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // 사용자 문서 생성
                                                  final usersCreateData = {
                                                    'email': testEmail,
                                                    'displayName': '테스터 (Android)',
                                                    'createdTime': FieldValue.serverTimestamp(),
                                                    'role': 'tester',
                                                    'platform': 'android',
                                                    'uid': user.uid,
                                                  };
                                                  // Repository 패턴 사용 - createUser 메서드 활용
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  
                                                  // UserProfile 생성
                                                  await UserProfile.collection.doc(user.uid).set(usersCreateData);
                                                }
                                                
                                                // authenticatedUserStream이 currentUser를 설정할 때까지 대기
                                                int attempts = 0;
                                                while (currentUserReference == null && attempts < 20) {
                                                  await Future.delayed(const Duration(milliseconds: 500));
                                                  attempts++;
                                                }
                                                
                                                if (currentUserReference == null) {
                                                  debugPrint('경고: currentUserReference가 설정되지 않음');
                                                  // 직접 DocumentReference 생성하여 업데이트
                                                  // Repository를 통해 업데이트 (추후 완전 마이그레이션)
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  final directRef = userRepository.getUserReference(user.uid);
                                                  
                                                  await directRef.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'android',
                                                    }),
                                                  });
                                                } else {
                                                  // 정상적으로 currentUserReference 사용
                                                  await currentUserReference!.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'android',
                                                    }),
                                                  });
                                                }
                                                
                                                context.pushNamedAuth(
                                                  TestpageSelectWidget.routeName,
                                                  context.mounted,
                                                );
                                              },
                                              text: 'Android',
                                              options: AppButtonOptions(
                                                width: 80.0,
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: AppTheme.of(context).secondary,
                                                textStyle: AppTheme.of(context).titleSmall.override(
                                                  font: GoogleFonts.plusJakartaSans(),
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            // macOS 테스트 계정
                                            AppButtonWidget(
                                              onPressed: () async {
                                                GoRouter.of(context).prepareAuthEvent();
                                                
                                                final testEmail = 'tester-macos@versus.test';
                                                final testPassword = 'test1234!';
                                                
                                                // 먼저 로그인 시도
                                                var user = await authManager.signInWithEmail(
                                                  context,
                                                  testEmail,
                                                  testPassword,
                                                );
                                                
                                                // 계정이 없으면 생성
                                                if (user == null) {
                                                  user = await authManager.createAccountWithEmail(
                                                    context,
                                                    testEmail,
                                                    testPassword,
                                                  );
                                                  
                                                  if (user == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('macOS 테스터 계정 생성 실패'),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // 사용자 문서 생성
                                                  final usersCreateData = {
                                                    'email': testEmail,
                                                    'displayName': '테스터 (macOS)',
                                                    'createdTime': FieldValue.serverTimestamp(),
                                                    'role': 'tester',
                                                    'platform': 'macos',
                                                    'uid': user.uid,
                                                  };
                                                  // Repository 패턴 사용 - createUser 메서드 활용
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  
                                                  // UserProfile 생성
                                                  await UserProfile.collection.doc(user.uid).set(usersCreateData);
                                                }
                                                
                                                // authenticatedUserStream이 currentUser를 설정할 때까지 대기
                                                int attempts = 0;
                                                while (currentUserReference == null && attempts < 20) {
                                                  await Future.delayed(const Duration(milliseconds: 500));
                                                  attempts++;
                                                }
                                                
                                                if (currentUserReference == null) {
                                                  debugPrint('경고: currentUserReference가 설정되지 않음');
                                                  // 직접 DocumentReference 생성하여 업데이트
                                                  // Repository를 통해 업데이트 (추후 완전 마이그레이션)
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  final directRef = userRepository.getUserReference(user.uid);
                                                  
                                                  await directRef.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'macos',
                                                    }),
                                                  });
                                                } else {
                                                  // 정상적으로 currentUserReference 사용
                                                  await currentUserReference!.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'macos',
                                                    }),
                                                  });
                                                }
                                                
                                                context.pushNamedAuth(
                                                  TestpageSelectWidget.routeName,
                                                  context.mounted,
                                                );
                                              },
                                              text: 'macOS 앱',
                                              options: AppButtonOptions(
                                                width: 90.0,
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: AppTheme.of(context).secondary,
                                                textStyle: AppTheme.of(context).titleSmall.override(
                                                  font: GoogleFonts.plusJakartaSans(),
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            // 웹앱 테스트 계정
                                            AppButtonWidget(
                                              onPressed: () async {
                                                GoRouter.of(context).prepareAuthEvent();
                                                
                                                final testEmail = 'tester-web@versus.test';
                                                final testPassword = 'test1234!';
                                                
                                                // 먼저 로그인 시도
                                                var user = await authManager.signInWithEmail(
                                                  context,
                                                  testEmail,
                                                  testPassword,
                                                );
                                                
                                                // 계정이 없으면 생성
                                                if (user == null) {
                                                  user = await authManager.createAccountWithEmail(
                                                    context,
                                                    testEmail,
                                                    testPassword,
                                                  );
                                                  
                                                  if (user == null) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('웹앱 테스터 계정 생성 실패'),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  
                                                  // 사용자 문서 생성
                                                  final usersCreateData = {
                                                    'email': testEmail,
                                                    'displayName': '테스터 (웹앱)',
                                                    'createdTime': FieldValue.serverTimestamp(),
                                                    'role': 'tester',
                                                    'platform': 'web',
                                                    'uid': user.uid,
                                                  };
                                                  // Repository 패턴 사용 - createUser 메서드 활용
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  
                                                  // UserProfile 생성
                                                  await UserProfile.collection.doc(user.uid).set(usersCreateData);
                                                }
                                                
                                                // authenticatedUserStream이 currentUser를 설정할 때까지 대기
                                                int attempts = 0;
                                                while (currentUserReference == null && attempts < 20) {
                                                  await Future.delayed(const Duration(milliseconds: 500));
                                                  attempts++;
                                                }
                                                
                                                if (currentUserReference == null) {
                                                  debugPrint('경고: currentUserReference가 설정되지 않음');
                                                  // 직접 DocumentReference 생성하여 업데이트
                                                  // Repository를 통해 업데이트 (추후 완전 마이그레이션)
                                                  final userRepository = GetIt.instance<IUserRepository>();
                                                  final directRef = userRepository.getUserReference(user.uid);
                                                  
                                                  await directRef.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'web',
                                                    }),
                                                  });
                                                } else {
                                                  // 정상적으로 currentUserReference 사용
                                                  await currentUserReference!.update({
                                                    ...mapToFirestore({
                                                      'lastActive': FieldValue.serverTimestamp(),
                                                      'role': 'tester',
                                                      'platform': 'web',
                                                    }),
                                                  });
                                                }
                                                
                                                context.pushNamedAuth(
                                                  TestpageSelectWidget.routeName,
                                                  context.mounted,
                                                );
                                              },
                                              text: '웹앱',
                                              options: AppButtonOptions(
                                                width: 70.0,
                                                height: 40.0,
                                                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: AppTheme.of(context).secondary,
                                                textStyle: AppTheme.of(context).titleSmall.override(
                                                  font: GoogleFonts.plusJakartaSans(),
                                                  color: Colors.white,
                                                  fontSize: 13.0,
                                                  letterSpacing: 0.0,
                                                ),
                                                elevation: 3.0,
                                                borderSide: BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 16.0, 0.0, 16.0),
                                  child: AppButtonWidget(
                                    onPressed: () async {
                                      context.pushNamed(
                                        ForgotPasswordWidget.routeName,
                                        extra: <String, dynamic>{
                                          kTransitionInfoKey: TransitionInfo(
                                            hasTransition: true,
                                            duration:
                                                Duration(milliseconds: 500),
                                          ),
                                        },
                                      );
                                    },
                                    text: AppLocalizations.of(context).getText(
                                      'ymtbo8l4' /* Forgot Password */,
                                    ),
                                    options: AppButtonOptions(
                                      width: 230.0,
                                      height: 44.0,
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                      iconPadding:
                                          EdgeInsetsDirectional.fromSTEB(
                                              0.0, 0.0, 0.0, 0.0),
                                      color: Colors.white,
                                      textStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF101213),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      elevation: 10.0,
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).animateOnPageLoad(
                              animationsMap['columnOnPageLoadAnimation']!),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 24.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              context.pushNamed(TestpageSelectWidget.routeName);
                            },
                            child: Text(
                              AppLocalizations.of(context).getText(
                                'e1wsx5w1' /* Or sign up with, goto test */,
                              ),
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context)
                                  .labelMedium
                                  .override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w500,
                                      fontStyle: AppTheme.of(context)
                                          .labelMedium
                                          .fontStyle,
                                    ),
                                    color: Color(0xFF57636C),
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: AppTheme.of(context)
                                        .labelMedium
                                        .fontStyle,
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
      ),
    );
  }
}
