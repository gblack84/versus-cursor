import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '/core_exports.dart';
import '/features/auth/data/adapters/auth_util.dart';
import '/features/notifications/data/adapters/notification_service.dart';
import '/features/notifications/data/adapters/global_notification_manager.dart';
import '/services/cache/preload_strategy.dart';

class VersusApp extends StatefulWidget {
  const VersusApp({super.key});

  @override
  State<VersusApp> createState() => _VersusAppState();

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

class _VersusAppState extends State<VersusApp> {
  Locale? _locale;
  ThemeMode _themeMode = AppTheme.themeMode;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  late Stream<BaseAuthUser> userStream;
  final authUserSub = authenticatedUserStream.listen((_) {});

  String getRoute([RouteMatchBase? routeMatch]) {
    final RouteMatchBase lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    
    userStream = versusSpaceFirebaseUserStream()
      ..listen((user) async {
        _appStateNotifier.update(user);
        
        // NotificationService 초기화
        if (user.loggedIn && user.uid != null && user.uid!.isNotEmpty) {
          // 사용자가 로그인하면 알림 리스닝 시작
          NotificationService.instance.startListening(user.uid!);
          GlobalNotificationManager.instance.startListening();
          
          // lastActive 필드 업데이트
          try {
            await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
                'lastActive': FieldValue.serverTimestamp(),
              });
            debugPrint('[VersusApp] 알림 서비스 시작 및 lastActive 업데이트: ${user.uid}');
            
            // Preload recent chats for better cache performance
            // UI 렌더링이 완료된 후 시작하도록 지연시킴
            Future.delayed(const Duration(milliseconds: 500), () async {
              try {
                if (user.uid != null) {
                  // 프리로드를 순차적으로 수행하여 메인 스레드 부하 감소
                  await PreloadStrategy().preloadRecentChats(user.uid!);
                  // 추가 지연을 주어 UI 반응성 유지
                  await Future.delayed(const Duration(milliseconds: 100));
                  await PreloadStrategy().preloadHomeFeedPosts();
                  debugPrint('[VersusApp] 프리로드 완료');
                }
              } catch (e) {
                debugPrint('[VersusApp] 프리로드 실패: $e');
              }
            });
          } catch (e) {
            debugPrint('[VersusApp] lastActive 업데이트 실패: $e');
          }
        } else {
          // 사용자가 로그아웃하면 알림 리스닝 중지
          NotificationService.instance.stopListening();
          GlobalNotificationManager.instance.stopListening();
          debugPrint('[VersusApp] 알림 서비스 중지');
        }
      });
    jwtTokenStream.listen((_) {});
  }

  @override
  void dispose() {
    authUserSub.cancel();
    NotificationService.instance.stopListening();
    GlobalNotificationManager.instance.stopListening();
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
      routerConfig: _router,
    );
  }
}

// For backward compatibility
@Deprecated('Use VersusApp instead')
class MyApp extends VersusApp {
  const MyApp({super.key}) : super();
}