import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/etc/vsmark/vsmark_widget.dart';
import '/core_exports.dart';
import '/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'popup_timer_email_model.dart';
export 'popup_timer_email_model.dart';

class PopupTimerEmailWidget extends StatefulWidget {
  const PopupTimerEmailWidget({super.key});

  @override
  State<PopupTimerEmailWidget> createState() => _PopupTimerEmailWidgetState();
}

class _PopupTimerEmailWidgetState extends State<PopupTimerEmailWidget> {
  late PopupTimerEmailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PopupTimerEmailModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // TimerStart
      _model.timerController.onStartTimer();
    });

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
                    'ajk36y0p' /* Email verification in progress... */,
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
                child: AuthUserStreamWidget(
                  builder: (context) => AppButtonWidget(
                    onPressed: !currentUserEmailVerified
                        ? null
                        : () async {
                            await currentUserReference!
                                .update(createUsersModelData(
                              photoUrl:
                                  'https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec',
                            ));
                            Navigator.pop(context);

                            context.pushNamed(
                              UserInfoInputWidget.routeName,
                              extra: <String, dynamic>{
                                kTransitionInfoKey: TransitionInfo(
                                  hasTransition: true,
                                  
                                  duration: Duration(milliseconds: 500),
                                ),
                              },
                            );
                          },
                    text: currentUserEmailVerified
                        ? 'Success!! Navigate To..!'
                        : 'ing....',
                    options: AppButtonOptions(
                      height: 30.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Colors.white,
                      textStyle:
                          AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Color(0xFF14181B),
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 10.0,
                      borderSide: BorderSide(
                        color: Color(0xFF14181B),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      disabledColor: Color(0xFFFC9C9C),
                      disabledTextColor: Color(0xFFA50000),
                    ),
                  ),
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
                          'zustpgk9' /* Check your Email,
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
              width: 234.62,
              height: 28.9,
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AuthUserStreamWidget(
                    builder: (context) => AppButtonWidget(
                      onPressed: currentUserEmailVerified
                          ? null
                          : () async {
                              await currentUserReference!.delete();
                              await authManager.deleteUser(context);
                              Navigator.pop(context);

                              context.pushNamed(CreateAccountWidget.routeName);
                            },
                      text: AppLocalizations.of(context).getText(
                        'c3ope0t7' /* Edit Email.. */,
                      ),
                      options: AppButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: Colors.black,
                        textStyle:
                            AppTheme.of(context).titleSmall.override(
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
                  AuthUserStreamWidget(
                    builder: (context) => AppButtonWidget(
                      onPressed: currentUserEmailVerified
                          ? null
                          : () async {
                              if (_model.resendCount < 3) {
                                _model.resendCount = _model.resendCount + 1;
                                setState(() {});
                                _model.timerController.timer
                                    .setPresetTime(mSec: 120000, add: false);
                                _model.timerController.onResetTimer();

                                _model.timerController.onStartTimer();
                                await authManager.sendEmailVerification();
                              } else {
                                await currentUserReference!.delete();
                                await authManager.deleteUser(context);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'You’ve exceeded the 3 attempt limit. Please create a new email.',
                                      style: AppTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .headlineSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .headlineSmall
                                                      .fontStyle,
                                            ),
                                            color: Colors.white,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .headlineSmall
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .headlineSmall
                                                    .fontStyle,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    duration: Duration(milliseconds: 4000),
                                    backgroundColor: Color(0xFFD2394E),
                                  ),
                                );
                                await Future.delayed(
                                    const Duration(milliseconds: 4000));

                                context.pushNamed(
                                  CreateAccountWidget.routeName,
                                  extra: <String, dynamic>{
                                    kTransitionInfoKey: TransitionInfo(
                                      hasTransition: true,
                                      
                                      duration: Duration(milliseconds: 500),
                                    ),
                                  },
                                );
                              }
                            },
                      text: AppLocalizations.of(context).getText(
                        'yqb182uz' /* Re Send.. */,
                      ),
                      options: AppButtonOptions(
                        height: 40.0,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            16.0, 0.0, 16.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: Colors.black,
                        textStyle:
                            AppTheme.of(context).titleSmall.override(
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
                  await authManager.deleteUser(context);
                  Navigator.pop(context);

                  context.pushNamed(StartPageWidget.routeName);
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
