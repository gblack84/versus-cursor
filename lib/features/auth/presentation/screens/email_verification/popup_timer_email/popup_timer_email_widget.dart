import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:get_it/get_it.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/presentation/providers/usecase_providers.dart';
import '/features/auth/presentation/widgets/auth_user_stream_widget.dart' hide currentUserId;
import '/core/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'popup_timer_email_provider.dart';
import '../../../widgets/timer/auth_timer_display.dart';

// Phase 10: PopupTimerEmailModel → Riverpod 3.x (Timer + verification state)
// AppTimer 제거 (2025-11-11): stop_watch_timer 직접 사용 + AuthTimerDisplay

class PopupTimerEmailWidget extends ConsumerStatefulWidget {
  const PopupTimerEmailWidget({super.key});

  @override
  ConsumerState<PopupTimerEmailWidget> createState() => _PopupTimerEmailWidgetState();
}

class _PopupTimerEmailWidgetState extends ConsumerState<PopupTimerEmailWidget> {
  // stop_watch_timer 직접 사용 (AppTimer 제거)
  late final StopWatchTimer _timer;

  @override
  void initState() {
    super.initState();

    // stop_watch_timer 직접 초기화
    _timer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: 180000, // 180초 (3분)
    );

    // 타이머 값 변경 리스너
    _timer.rawTime.listen((value) {
      final displayTime = StopWatchTimer.getDisplayTime(
        value,
        hours: false,
        milliSecond: false,
      );
      ref.read(popupTimerEmailProvider.notifier).updateTimerValues(
        milliseconds: value,
        displayValue: displayTime,
      );
      if (mounted) setState(() {});
    });

    // 타이머 종료 리스너
    _timer.fetchEnded.listen((_) async {
      // 시간 초과 - 사용자 계정 삭제
      final accountManagementUseCase = ref.read(accountManagementUseCaseProvider);
      await accountManagementUseCase.deleteAccount();

      if (mounted) {
        Navigator.pop(context);
        context.pushNamed(StartPageWidget.routeName);
      }
    });

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // 타이머 시작
      _timer.onStartTimer();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.dispose();
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
                  child: PickleMarkWidget(),
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
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w800,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
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
                            final userId = await ref.read(currentUserIdProvider.future);
                            if (userId == null) return;

                            // Contract 패턴 폐기 (2025-11-09): IUserRepository 직접 사용
                            final userRepository = GetIt.instance<IUserRepository>();
                            await userRepository.updateUser(
                              userId,
                              {
                                'photoUrl': 'https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec',
                              },
                            );
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
                      textStyle: AppTheme.of(context).titleSmall.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight:
                                  AppTheme.of(context).titleSmall.fontWeight,
                              fontStyle:
                                  AppTheme.of(context).titleSmall.fontStyle,
                            ),
                            color: Color(0xFF14181B),
                            letterSpacing: 0.0,
                            fontWeight:
                                AppTheme.of(context).titleSmall.fontWeight,
                            fontStyle:
                                AppTheme.of(context).titleSmall.fontStyle,
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
                                fontWeight:
                                    AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle:
                                    AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight:
                                  AppTheme.of(context).bodyMedium.fontWeight,
                              fontStyle:
                                  AppTheme.of(context).bodyMedium.fontStyle,
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
                                fontStyle:
                                    AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.bold,
                              fontStyle:
                                  AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                      )
                    ],
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontStyle:
                                AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
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
                              // 사용자 계정 삭제
                              final accountManagementUseCase = ref.read(accountManagementUseCaseProvider);
                              await accountManagementUseCase.deleteAccount();

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
                              if (ref.read(popupTimerEmailProvider).canResend) {
                                ref.read(popupTimerEmailProvider.notifier).incrementResendCount();

                                // 타이머 리셋 및 재시작
                                _timer.setPresetTime(mSec: 180000, add: false);
                                _timer.onResetTimer();
                                _timer.onStartTimer();

                                // 이메일 인증 재발송
                                final userId = await ref.read(currentUserIdProvider.future);
                                if (userId == null) return;

                                final emailVerificationUseCase = ref.read(emailVerificationUseCaseProvider);
                                await emailVerificationUseCase.sendVerificationEmail();
                              } else {
                                // 사용자 계정 삭제
                                final accountManagementUseCase = ref.read(accountManagementUseCaseProvider);
                                await accountManagementUseCase.deleteAccount();

                                Navigator.pop(context);
                                BotToast.showText(
                                  text: 'You\'ve exceeded the 3 attempt limit. Please create a new email.',
                                );

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
              child: AuthTimerDisplay(
                timer: _timer,
                style: AppTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight:
                            AppTheme.of(context).headlineSmall.fontWeight,
                        fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                      ),
                      color: Color(0xFFFF4E00),
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                      fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                    ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
