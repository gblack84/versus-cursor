import 'package:get_it/get_it.dart';
import 'package:bot_toast/bot_toast.dart';
import '/core/utils/error_handler.dart';
import '/features/auth/presentation/providers/auth_provider.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'phonelogeinpincode_model.dart';
import 'phonemaximum/phonemaximum_widget.dart';
export 'phonelogeinpincode_model.dart';

class PhonelogeinpincodeWidget extends StatefulWidget {
  const PhonelogeinpincodeWidget({
    super.key,
    required this.phoneNumberParam,
  });

  final String? phoneNumberParam;

  static String routeName = 'Phonelogeinpincode';
  static String routePath = '/phonelogeinpincode';

  @override
  State<PhonelogeinpincodeWidget> createState() =>
      _PhonelogeinpincodeWidgetState();
}

class _PhonelogeinpincodeWidgetState extends State<PhonelogeinpincodeWidget> {
  late PhonelogeinpincodeModel _model;
  late final AuthProvider _authProvider = GetIt.instance<AuthProvider>();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhonelogeinpincodeModel());

    // AuthProvider 초기화 확인 (GetIt에서 가져온 Singleton)
    if (!_authProvider.isInitialized) {
      _authProvider.initialize();
    }

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.timerController.onStartTimer();
      await Future.delayed(const Duration(milliseconds: 30000));
      _model.canResendCode = true;
      setState(() {});
    });

    _model.pinCodeFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: AppIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 30.0,
          ),
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
                ),
              },
            );
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
              child: Text(
                AppLocalizations.of(context).getText(
                  'bjt41bts' /* Back */,
                ),
                style: AppTheme.of(context).displaySmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight:
                            AppTheme.of(context).displaySmall.fontWeight,
                        fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                      ),
                      color: Colors.black,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).displaySmall.fontWeight,
                      fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                    ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/20250402_1112_____remix_01jqt4bfgvebj8s1j9b2ywjy5z.png',
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        actions: [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Align(
        alignment: AlignmentDirectional(0.0, -1.0),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 570.0,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFECECEC),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 0.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'daf828ek' /* Phone Login */,
                  ),
                  style: AppTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              AppTheme.of(context).headlineMedium.fontWeight,
                          fontStyle:
                              AppTheme.of(context).headlineMedium.fontStyle,
                        ),
                        color: Colors.black,
                        letterSpacing: 0.0,
                        fontWeight:
                            AppTheme.of(context).headlineMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).headlineMedium.fontStyle,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'ddk0vrr5' /* Please enter your phone number... */,
                  ),
                  style: AppTheme.of(context).labelMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              AppTheme.of(context).labelMedium.fontWeight,
                          fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).labelMedium.fontWeight,
                        fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(),
                            child: RichText(
                              textScaler: MediaQuery.of(context).textScaler,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: valueOrDefault<String>(
                                      '${widget.phoneNumberParam}',
                                      '+12345678900',
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          fontSize: 19.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context).getText(
                                      '6lsg39md' /* 
Enter the 6-digit code sent t... */
                                      ,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  )
                                ],
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Container(
                            decoration: BoxDecoration(),
                            child: PinCodeTextField(
                              autoDisposeControllers: false,
                              appContext: context,
                              length: 6,
                              textStyle:
                                  AppTheme.of(context).bodyLarge.override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: AppTheme.of(context)
                                              .bodyLarge
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .bodyLarge
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .bodyLarge
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyLarge
                                            .fontStyle,
                                      ),
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              enableActiveFill: false,
                              autoFocus: true,
                              focusNode: _model.pinCodeFocusNode,
                              enablePinAutofill: false,
                              errorTextSpace: 16.0,
                              showCursor: true,
                              cursorColor: AppTheme.of(context).primary,
                              obscureText: false,
                              hintCharacter: '●',
                              keyboardType: TextInputType.number,
                              pinTheme: PinTheme(
                                fieldHeight: 44.0,
                                fieldWidth: 44.0,
                                borderWidth: 2.0,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.0),
                                  bottomRight: Radius.circular(12.0),
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                ),
                                shape: PinCodeFieldShape.box,
                                activeColor: AppTheme.of(context).primaryText,
                                inactiveColor: AppTheme.of(context).alternate,
                                selectedColor: AppTheme.of(context).primary,
                              ),
                              controller: _model.pinCodeController,
                              onChanged: (_) {},
                              onCompleted: (_) async {
                                final smsCodeVal =
                                    _model.pinCodeController!.text;
                                if (smsCodeVal.isEmpty) {
                                  BotToast.showText(text: 'Enter SMS verification code.');
                                  return;
                                }

                                // 로딩 중이면 리턴
                                if (_authProvider.isLoading) {
                                  return;
                                }

                                // 전화번호 인증
                                final phoneVerified = await _authProvider.signInWithPhone(
                                  phoneNumber: widget.phoneNumberParam ?? '',
                                  verificationCode: smsCodeVal,
                                );

                                if (phoneVerified) {
                                  _model.isVerified = true;
                                  setState(() {});

                                  // 인증 성공 시 다음 페이지로 이동
                                  if (context.mounted) {
                                    context.pushNamedAuth(
                                      UserInfoInputWidget.routeName,
                                      context.mounted,
                                      extra: <String, dynamic>{
                                        kTransitionInfoKey: TransitionInfo(
                                          hasTransition: true,
                                          duration: Duration(milliseconds: 500),
                                        ),
                                      },
                                    );
                                  }
                                } else {
                                  _model.isVerified = false;
                                  setState(() {});

                                  // 에러 메시지 표시
                                  if (context.mounted) {
                                    ErrorHandler.handle(
                                      _authProvider.errorMessage ?? '인증에 실패했습니다. 코드를 다시 확인해주세요.',
                                      customMessage: _authProvider.errorMessage ?? '인증에 실패했습니다. 코드를 다시 확인해주세요.',
                                      context: context,
                                    );
                                  }
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: _model.pinCodeControllerValidator
                                  .asValidator(context),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).secondaryBackground,
                              shape: BoxShape.rectangle,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                if (_model.isVerified == true)
                                  Text(
                                    AppLocalizations.of(context).getText(
                                      'ep61t57h' /* Authentication succeeded!! */,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: Color(0xFF8000FD),
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w800,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  ),
                                if (_model.isVerified == false)
                                  Text(
                                    AppLocalizations.of(context).getText(
                                      '85h4oe02' /* Authentication failed. Please ... */,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: Color(0xFFFF0000),
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w800,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).secondaryBackground,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              AppTimer(
                                initialTime: _model.timerInitialTimeMs,
                                getDisplayTime: (value) =>
                                    StopWatchTimer.getDisplayTime(
                                  value,
                                  hours: false,
                                  milliSecond: false,
                                ),
                                controller: _model.timerController,
                                updateStateInterval:
                                    Duration(milliseconds: 1000),
                                onChanged: (value, displayTime, shouldUpdate) {
                                  _model.timerMilliseconds = value;
                                  _model.timerValue = displayTime;
                                  if (shouldUpdate) setState(() {});
                                },
                                textAlign: TextAlign.start,
                                style:
                                    AppTheme.of(context).headlineSmall.override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: AppTheme.of(context)
                                                .headlineSmall
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .headlineSmall
                                                .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context)
                                              .headlineSmall
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .headlineSmall
                                              .fontStyle,
                                        ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppButtonWidget(
                                  onPressed: (_model.timerMilliseconds > 90000)
                                      ? null
                                      : () async {
                                          if (_model.canResendCount < 3) {
                                            _model.canResendCount++;
                                            setState(() {});
                                            _model.timerController.timer
                                                .setPresetTime(
                                                    mSec: 60000, add: false);
                                            _model.timerController
                                                .onResetTimer();

                                            _model.timerController
                                                .onStartTimer();
                                            final phoneNumberVal =
                                                widget.phoneNumberParam;
                                            if (phoneNumberVal == null ||
                                                phoneNumberVal.isEmpty ||
                                                !phoneNumberVal
                                                    .startsWith('+')) {
                                              BotToast.showText(text: 'Phone Number is required and has to start with +.');
                                              return;
                                            }
                                            // 로딩 중이면 리턴
                                            if (_authProvider.isLoading) {
                                              return;
                                            }

                                            // OTP 재전송
                                            final smsSent = await _authProvider.resendPhoneOtp();

                                            if (smsSent) {
                                              // 코드가 성공적으로 전송됨
                                              if (context.mounted) {
                                                ErrorHandler.showSuccessToast('인증 코드가 재전송되었습니다.');
                                              }
                                            } else {
                                              // 재전송 실패
                                              if (context.mounted) {
                                                ErrorHandler.handle(
                                                  _authProvider.errorMessage ?? '코드 재전송에 실패했습니다.',
                                                  customMessage: _authProvider.errorMessage ?? '코드 재전송에 실패했습니다.',
                                                  context: context,
                                                );
                                              }
                                            }

                                            BotToast.showText(
                                              text: 'pMessage resent. After 3 attempts, you will be returned to the login screen.',
                                            );
                                          } else {
                                            // 3회 재전송 제한 초과 시 경고 모달 표시
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext dialogContext) {
                                                return Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  elevation: 0,
                                                  insetPadding: EdgeInsets.all(16.0),
                                                  child: PhonemaximumWidget(),
                                                );
                                              },
                                            );
                                          }
                                        },
                                  text: AppLocalizations.of(context).getText(
                                    '7ezietmr' /* Re Code */,
                                  ),
                                  options: AppButtonOptions(
                                    height: 40.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 0.0, 16.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.black,
                                    textStyle: AppTheme.of(context)
                                        .titleSmall
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: AppTheme.of(context)
                                                .titleSmall
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .titleSmall
                                                .fontStyle,
                                          ),
                                          color: Colors.white,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context)
                                              .titleSmall
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .titleSmall
                                              .fontStyle,
                                        ),
                                    elevation: 10.0,
                                    borderRadius: BorderRadius.circular(8.0),
                                    disabledColor: Color(0xFF57636C),
                                    disabledTextColor: Color(0xFFA7A6A6),
                                  ),
                                ),
                              ),
                              Container(
                                width: 350.0,
                                decoration: BoxDecoration(),
                                child: Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Text(
                                    AppLocalizations.of(context).getText(
                                      'pyfnfxye' /* Tip. If you haven’t received i... */,
                                    ),
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: AppTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                  child: AppButtonWidget(
                    onPressed: (_model.isVerified != true)
                        ? null
                        : () async {
                            // 이미 인증이 성공한 경우 다음 페이지로 이동
                            context.pushNamedAuth(
                              UserInfoInputWidget.routeName,
                              context.mounted,
                              extra: <String, dynamic>{
                                kTransitionInfoKey: TransitionInfo(
                                  hasTransition: true,
                                  duration: Duration(milliseconds: 500),
                                ),
                              },
                            );
                          },
                    text: AppLocalizations.of(context).getText(
                      'xjt78grf' /* Next */,
                    ),
                    options: AppButtonOptions(
                      width: 270.0,
                      height: 50.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Colors.black,
                      textStyle: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight:
                                  AppTheme.of(context).titleSmall.fontWeight,
                              fontStyle:
                                  AppTheme.of(context).titleSmall.fontStyle,
                            ),
                            color: Colors.white,
                            letterSpacing: 0.0,
                            fontWeight:
                                AppTheme.of(context).titleSmall.fontWeight,
                            fontStyle:
                                AppTheme.of(context).titleSmall.fontStyle,
                          ),
                      elevation: 10.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      disabledColor: Color(0xFF57636C),
                      disabledTextColor: Color(0xFFA7A6A6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
