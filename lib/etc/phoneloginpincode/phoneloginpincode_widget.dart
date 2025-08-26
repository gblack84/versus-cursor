import '/auth/firebase_auth/auth_util.dart';
import '/etc/vsmark/vsmark_widget.dart';
import '/core_exports.dart';
import '/index.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'phoneloginpincode_model.dart';
export 'phoneloginpincode_model.dart';

class PhoneloginpincodeWidget extends StatefulWidget {
  const PhoneloginpincodeWidget({super.key});

  @override
  State<PhoneloginpincodeWidget> createState() =>
      _PhoneloginpincodeWidgetState();
}

class _PhoneloginpincodeWidgetState extends State<PhoneloginpincodeWidget> {
  late PhoneloginpincodeModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneloginpincodeModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await authManager.refreshUser();
      _model.timerController.onStartTimer();
      if (currentUserEmailVerified) {
        _model.timerController.onStopTimer();
        Navigator.pop(context);

        context.pushNamed(UserInfoInputWidget.routeName);
      }
    });

    _model.pinCodeFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: 300.0,
        height: 350.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0),
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          shape: BoxShape.rectangle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: AlignmentDirectional(0.0, 0.0),
              child: Container(
                width: 200.5,
                height: 56.5,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: wrapWithModel(
                    model: _model.vsmarkModel,
                    updateCallback: () => setState(() {}),
                    child: VsmarkWidget(),
                  ),
                ),
              ),
            ),
            Container(
              width: 248.8,
              height: 74.85,
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground,
              ),
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'usvyes4j' /* Email verification in progress... */,
                  ),
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w800,
                        fontStyle:
                            AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
              child: Container(
                width: 248.8,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                ),
                child: RichText(
                  textScaler: MediaQuery.of(context).textScaler,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context).getText(
                          'h0xldpn5' /* Check your Email,
 */
                          ,
                        ),
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
                      TextSpan(
                        text: valueOrDefault<String>(
                          currentUserEmail,
                          'Versus@space.com',
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
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
                            fontWeight: FontWeight.w600,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      AppLocalizations.of(context).getText(
                        'w7b2rjfw' /* Hello World */,
                      ),
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
                  ),
                  PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 6,
                    textStyle: AppTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: AppTheme.of(context)
                                .bodyLarge
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyLarge
                                .fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight:
                              AppTheme.of(context).bodyLarge.fontWeight,
                          fontStyle:
                              AppTheme.of(context).bodyLarge.fontStyle,
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator:
                        _model.pinCodeControllerValidator.asValidator(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
              child: AppTimer(
                initialTime: _model.timerInitialTimeMs,
                getDisplayTime: (value) => StopWatchTimer.getDisplayTime(
                  value,
                  hours: false,
                  milliSecond: false,
                ),
                controller: _model.timerController,
                updateStateInterval: Duration(milliseconds: 1000),
                onChanged: (value, displayTime, shouldUpdate) {
                  _model.timerMilliseconds = value;
                  _model.timerValue = displayTime;
                  if (shouldUpdate) setState(() {});
                },
                onEnded: () async {
                  await currentUserReference!.delete();

                  context.pushNamed(
                    StartPageWidget.routeName,
                    extra: <String, dynamic>{
                      kTransitionInfoKey: TransitionInfo(
                        hasTransition: true,
                        
                      ),
                    },
                  );
                },
                textAlign: TextAlign.start,
                style: AppTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: AppTheme.of(context)
                            .headlineSmall
                            .fontWeight,
                        fontStyle: AppTheme.of(context)
                            .headlineSmall
                            .fontStyle,
                      ),
                      color: Color(0xFFFF4E00),
                      letterSpacing: 0.0,
                      fontWeight:
                          AppTheme.of(context).headlineSmall.fontWeight,
                      fontStyle:
                          AppTheme.of(context).headlineSmall.fontStyle,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
