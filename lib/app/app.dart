import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/core_exports.dart';
import '/features/notifications/domain/services/i_notification_service.dart';
import '/features/notifications/presentation/providers/notification_overlay_provider.dart';
import '/features/profile/presentation/providers/usecase_providers.dart';
import '/app/lifecycle/initialization/initialization_providers.dart';
import 'package:get_it/get_it.dart';

class VersusApp extends ConsumerStatefulWidget {
  const VersusApp({super.key});

  @override
  ConsumerState<VersusApp> createState() => _VersusAppState();

  static _VersusAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_VersusAppState>()!;
}

class VersusAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class _VersusAppState extends ConsumerState<VersusApp> {
  Locale? _locale;
  ThemeMode _themeMode = AppTheme.themeMode;
  GoRouter? _router;
  late Stream<User?> userStream;

  // NotificationOverlayProvider: 인앱 알림 다이얼로그용
  NotificationOverlayProvider? _overlayProvider;

  String getRoute([RouteMatchBase? routeMatch]) {
    if (_router == null) return '/';

    final RouteMatchBase lastMatch =
        routeMatch ?? _router!.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router!.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() {
    if (_router == null) return ['/'];

    return _router!.routerDelegate.currentConfiguration.matches
        .map((e) => getRoute(e))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    userStream = FirebaseAuth.instance.authStateChanges()
      ..listen((user) async {
        // INotificationService를 통한 통합 알림 시스템 초기화
        if (user != null && user.uid.isNotEmpty) {
          // 사용자가 로그인하면 알림 시스템 시작
          final notificationService = GetIt.instance<INotificationService>();
          notificationService.startListening(user.uid);

          // NotificationOverlayProvider 초기화 및 시작
          _overlayProvider = GetIt.instance<NotificationOverlayProvider>();
          _overlayProvider!.startListening();
          debugPrint('[VersusApp] 알림 오버레이 프로바이더 시작');

          // ✅ Clean Architecture: UpdateLastActiveUseCase 사용
          final updateLastActiveUseCase = ref.read(updateLastActiveUseCaseProvider);
          final updateResult = await updateLastActiveUseCase(user.uid);

          updateResult.fold(
            (failure) {
              debugPrint('[VersusApp] lastActive 업데이트 실패: $failure');
              // 비중요 작업이므로 사용자에게 알리지 않음
            },
            (_) {
              debugPrint('[VersusApp] 알림 서비스 시작 및 lastActive 업데이트: ${user.uid}');
            },
          );

          // ✅ Service Layer: AppInitializationService 사용 (병렬 프리로드)
          final initService = ref.read(appInitializationServiceProvider);
          initService.initialize(user.uid);
          // 비동기 실행, 결과 대기 불필요 (백그라운드 프리로드)
        } else {
          // 사용자가 로그아웃하면 알림 시스템 종료
          final notificationService = GetIt.instance<INotificationService>();
          notificationService.stopListening();
          debugPrint('[VersusApp] 알림 서비스 중지');

          // NotificationOverlayProvider 정리
          _overlayProvider?.stopListening();
          _overlayProvider = null;
          debugPrint('[VersusApp] 알림 오버레이 프로바이더 중지');
        }
      });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Router 초기화 (ref 접근 가능, 한 번만 초기화)
    _router ??= createRouter(ref);
  }

  @override
  void dispose() {
    // INotificationService는 stopListening으로 정리됨 (위에서 호출)
    // NotificationOverlayProvider 안전한 정리
    _overlayProvider?.stopListening();
    super.dispose();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        AppTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'versus-space',
      builder: (context, child) {
        // BotToast 초기화
        final botToastBuilder = BotToastInit();

        return botToastBuilder(context, child);
      },
      scrollBehavior: VersusAppScrollBehavior(),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router!,
    );
  }
}

// 하위 호환성 유지 (deprecated)
@Deprecated('Use VersusApp instead')
class MyApp extends VersusApp {
  const MyApp({super.key}) : super();
}
