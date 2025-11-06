import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/presentation/providers/usecase_providers.dart';
import '/core/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
import '/core/utils/error_handler.dart';
import '/app/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'start_page_model.dart';
export 'start_page_model.dart';

class StartPageWidget extends ConsumerStatefulWidget {
  const StartPageWidget({super.key});

  static String routeName = 'startPage';
  static String routePath = '/startPage';

  @override
  ConsumerState<StartPageWidget> createState() => _StartPageWidgetState();
}

class _StartPageWidgetState extends ConsumerState<StartPageWidget>
    with TickerProviderStateMixin {
  late StartPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  var hasButtonTriggered1 = false;
  var hasButtonTriggered2 = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StartPageModel());

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
      'buttonOnActionTriggerAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.0, 1.0),
            end: Offset(0.95, 0.95),
          ),
        ],
      ),
      'buttonOnActionTriggerAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onActionTrigger,
        applyInitialState: false,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeOut,
            delay: 0.0.ms,
            duration: 200.0.ms,
            begin: Offset(1.0, 1.0),
            end: Offset(0.95, 0.95),
          ),
        ],
      ),
    });
    setupAnimations(
      animationsMap.values.where((anim) =>
          anim.trigger == AnimationTrigger.onActionTrigger ||
          !anim.applyInitialState),
      this,
    );

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
        backgroundColor: AppTheme.of(context).primaryBackground,
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFECECEC),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 400.0,
                decoration: BoxDecoration(),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Container(
                          width: 300.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Text(
                                  AppLocalizations.of(context).getText(
                                    'ur72jrvo' /* Life is a 'c' between 'b' and ... */,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'SourGummy',
                                    color: Color(0xFF14181B),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 66.0,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
                        child: wrapWithModel(
                          model: _model.pickleMarkModel,
                          updateCallback: () => setState(() {}),
                          child: PickleMarkWidget(),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 26.0, 0.0, 16.0),
                          child: Wrap(
                            spacing: 0.0,
                            runSpacing: 0.0,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            direction: Axis.horizontal,
                            runAlignment: WrapAlignment.center,
                            verticalDirection: VerticalDirection.down,
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 12.0),
                                child: AppButtonWidget(
                                  onPressed: () async {
                                    context.pushNamed(
                                      CreateAccountWidget.routeName,
                                      extra: <String, dynamic>{
                                        kTransitionInfoKey: TransitionInfo(
                                          hasTransition: true,
                                          duration: Duration(milliseconds: 500),
                                        ),
                                      },
                                    );
                                  },
                                  text: AppLocalizations.of(context).getText(
                                    'tkccfqfy' /* Go To Create Account */,
                                  ),
                                  options: AppButtonOptions(
                                    width: 230.0,
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.black,
                                    textStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                    elevation: 5.0,
                                    borderSide: BorderSide(
                                      color: Color(0xFFE0E3E7),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation1']!,
                                    hasBeenTriggered: hasButtonTriggered1),
                              ),
                              isAndroid
                                  ? Container()
                                  : Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 8.0),
                                      child: AppButtonWidget(
                                        onPressed: () async {
                                          // 로딩 중이면 리턴
                                          final isLoading = ref.read(authLoadingProvider);
                                          if (isLoading) {
                                            return;
                                          }

                                          GoRouter.of(context).prepareAuthEvent();

                                          ref.read(authLoadingProvider.notifier).setLoading(true);

                                          final signInWithAppleUseCase = ref.read(signInWithAppleUseCaseProvider);
                                          final result = await signInWithAppleUseCase.execute(
                                            eventId: const Uuid().v4(),
                                          );

                                          result.fold(
                                            (failure) {
                                              ref.read(authLoadingProvider.notifier).setLoading(false);
                                              if (context.mounted) {
                                                ErrorHandler.handle(
                                                  failure.message,
                                                  customMessage: 'Apple 로그인에 실패했습니다.',
                                                  context: context,
                                                );
                                              }
                                            },
                                            (user) {
                                              ref.read(authLoadingProvider.notifier).setLoading(false);
                                              if (context.mounted) {
                                                context.goNamedAuth(
                                                    TestpageSelectWidget.routeName,
                                                    context.mounted);
                                              }
                                            },
                                          );
                                        },
                                        text: AppLocalizations.of(context)
                                            .getText(
                                          '3gnrvqoi' /* Continue with Apple */,
                                        ),
                                        icon: FaIcon(
                                          FontAwesomeIcons.apple,
                                          size: 20.0,
                                        ),
                                        options: AppButtonOptions(
                                          width: 230.0,
                                          height: 44.0,
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          iconColor: Color(0xFF14181B),
                                          color: Colors.white,
                                          textStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.bold,
                                                  fontStyle:
                                                      AppTheme.of(context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color: Color(0xFF101213),
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.bold,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                              ),
                                          elevation: 5.0,
                                          borderSide: BorderSide(
                                            color: Color(0xFFE0E3E7),
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                      ),
                                    ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 8.0),
                                child: AppButtonWidget(
                                  onPressed: () async {
                                    // 로딩 중이면 리턴
                                    final isLoading = ref.read(authLoadingProvider);
                                    if (isLoading) {
                                      return;
                                    }

                                    GoRouter.of(context).prepareAuthEvent();

                                    ref.read(authLoadingProvider.notifier).setLoading(true);

                                    final signInWithGoogleUseCase = ref.read(signInWithGoogleUseCaseProvider);
                                    final result = await signInWithGoogleUseCase.execute(
                                      eventId: const Uuid().v4(),
                                    );

                                    result.fold(
                                      (failure) {
                                        ref.read(authLoadingProvider.notifier).setLoading(false);
                                        if (context.mounted) {
                                          ErrorHandler.handle(
                                            failure.message,
                                            customMessage: 'Google 로그인에 실패했습니다.',
                                            context: context,
                                          );
                                        }
                                      },
                                      (user) {
                                        ref.read(authLoadingProvider.notifier).setLoading(false);
                                        if (context.mounted) {
                                          context.goNamedAuth(
                                              TestpageSelectWidget.routeName,
                                              context.mounted);
                                        }
                                      },
                                    );
                                  },
                                  text: AppLocalizations.of(context).getText(
                                    's24g5s5d' /* Continue with Google */,
                                  ),
                                  icon: FaIcon(
                                    FontAwesomeIcons.google,
                                    size: 20.0,
                                  ),
                                  options: AppButtonOptions(
                                    width: 230.0,
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.white,
                                    textStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: Color(0xFF101213),
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                    elevation: 5.0,
                                    borderSide: BorderSide(
                                      color: Color(0xFFE0E3E7),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 8.0),
                                child: AppButtonWidget(
                                  onPressed: () async {
                                    // 로딩 중이면 리턴
                                    final isLoading = ref.read(authLoadingProvider);
                                    if (isLoading) {
                                      return;
                                    }

                                    GoRouter.of(context).prepareAuthEvent();

                                    ref.read(authLoadingProvider.notifier).setLoading(true);

                                    final signInWithGoogleUseCase = ref.read(signInWithGoogleUseCaseProvider);
                                    final result = await signInWithGoogleUseCase.execute(
                                      eventId: const Uuid().v4(),
                                    );

                                    result.fold(
                                      (failure) {
                                        ref.read(authLoadingProvider.notifier).setLoading(false);
                                        if (context.mounted) {
                                          ErrorHandler.handle(
                                            failure.message,
                                            customMessage: 'Google 로그인에 실패했습니다.',
                                            context: context,
                                          );
                                        }
                                      },
                                      (user) {
                                        ref.read(authLoadingProvider.notifier).setLoading(false);
                                        if (context.mounted) {
                                          context.goNamedAuth(
                                              TestpageSelectWidget.routeName,
                                              context.mounted);
                                        }
                                      },
                                    );
                                  },
                                  text: AppLocalizations.of(context).getText(
                                    'ntv3cl1f' /* Continue with Facebook */,
                                  ),
                                  icon: FaIcon(
                                    FontAwesomeIcons.squareFacebook,
                                    size: 20.0,
                                  ),
                                  options: AppButtonOptions(
                                    width: 230.0,
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconColor: Colors.white,
                                    color: Color(0xFF005CFF),
                                    textStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: Color(0xFF101213),
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                    elevation: 5.0,
                                    borderSide: BorderSide(
                                      color: Color(0xFFE0E3E7),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              AppButtonWidget(
                                onPressed: () async {
                                  // 로딩 중이면 리턴
                                  final isLoading = ref.read(authLoadingProvider);
                                  if (isLoading) {
                                    return;
                                  }

                                  // Instagram 로그인은 현재 Google로 대체 (추후 구현 예정)
                                  GoRouter.of(context).prepareAuthEvent();

                                  ref.read(authLoadingProvider.notifier).setLoading(true);

                                  final signInWithGoogleUseCase = ref.read(signInWithGoogleUseCaseProvider);
                                  final result = await signInWithGoogleUseCase.execute(
                                    eventId: const Uuid().v4(),
                                  );

                                  result.fold(
                                    (failure) {
                                      ref.read(authLoadingProvider.notifier).setLoading(false);
                                      if (context.mounted) {
                                        ErrorHandler.handle(
                                          failure.message,
                                          customMessage: 'Instagram 로그인에 실패했습니다.',
                                          context: context,
                                        );
                                      }
                                    },
                                    (user) {
                                      ref.read(authLoadingProvider.notifier).setLoading(false);
                                      if (context.mounted) {
                                        context.goNamedAuth(
                                            TestpageSelectWidget.routeName,
                                            context.mounted);
                                      }
                                    },
                                  );
                                },
                                text: AppLocalizations.of(context).getText(
                                  '4ssf49xr' /* Continue with Instagram */,
                                ),
                                icon: FaIcon(
                                  FontAwesomeIcons.instagram,
                                  size: 20.0,
                                ),
                                options: AppButtonOptions(
                                  width: 230.0,
                                  height: 44.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
                                  iconColor: Colors.white,
                                  color: Color(0xFFFF8455),
                                  textStyle:
                                      AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: Color(0xFF101213),
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                  elevation: 5.0,
                                  borderSide: BorderSide(
                                    color: Color(0xFFE0E3E7),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 12.0, 0.0, 16.0),
                                child: AppButtonWidget(
                                  onPressed: () async {
                                    context.pushNamed(
                                      LoginPageWidget.routeName,
                                      extra: <String, dynamic>{
                                        kTransitionInfoKey: TransitionInfo(
                                          hasTransition: true,
                                          duration: Duration(milliseconds: 500),
                                        ),
                                      },
                                    );
                                  },
                                  text: AppLocalizations.of(context).getText(
                                    'b71h3bzp' /* Go To Sign in */,
                                  ),
                                  options: AppButtonOptions(
                                    width: 230.0,
                                    height: 44.0,
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    iconPadding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 0.0),
                                    color: Colors.white,
                                    textStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: Color(0xFF101213),
                                          fontSize: 14.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                    elevation: 10.0,
                                    borderSide: BorderSide(
                                      color: Color(0xFFE0E3E7),
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ).animateOnActionTrigger(
                                    animationsMap[
                                        'buttonOnActionTriggerAnimation2']!,
                                    hasBeenTriggered: hasButtonTriggered2),
                              ),
                            ],
                          ),
                        ),
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
    );
  }
}
