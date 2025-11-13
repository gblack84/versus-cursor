import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';

import '/core_exports.dart';
import '/app/widgets/index.dart';
import '/app/widgets/navigation/main_navigation_shell.dart';

// Auth Guard (Phase 3: 인증 로직 분리)
import '/app/router/guards/auth_guard.dart';

// Feature Routes (Phase 2: 라우트 모듈화)
// Auth, Profile, Creation, Chat, Notifications, Post, Search 라우트가 각 Feature로 모듈화됨
import '/features/notifications/presentation/routes/notification_routes.dart';
import '/features/profile/presentation/routes/profile_routes.dart';
import '/features/auth/presentation/routes/auth_routes.dart';
import '/features/creation/presentation/routes/creation_routes.dart';
import '/features/chat/presentation/routes/chat_routes.dart';
import '/features/post/presentation/routes/post_routes.dart';
import '/features/search/presentation/routes/search_routes.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Router 생성 함수 (Riverpod 3.x)
///
/// **Phase 1 마이그레이션**: AppStateNotifier 제거, WidgetRef 사용
/// - Firebase Auth 직접 사용으로 간소화
/// - refreshListenable 제거 (Riverpod 자동 리프레시)
/// - 향후 Phase 3에서 AuthGuard로 개선 예정
GoRouter createRouter(WidgetRef ref) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => StartPageWidget(),
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => AuthGuard.redirectIfAuthenticated(),
          builder: (context, state) => StartPageWidget(),
        ),
        // ShellRoute: 하단 네비게이션용
        ShellRoute(
          builder: (context, state, child) => MainNavigationShell(child: child),
          routes: [
            // 메인 네비게이션 라우트
            GoRoute(
              name: HomePageWidget.routeName,
              path: HomePageWidget.routePath,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: HomePageWidget(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
            GoRoute(
              name: SearchPageWidget.routeName,
              path: SearchPageWidget.routePath,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: SearchPageWidget(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
            GoRoute(
              name: ProfilePageWidget.routeName,
              path: ProfilePageWidget.routePath,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: ProfilePageWidget(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
            GoRoute(
              name: CreatePostScreen.routeName,
              path: CreatePostScreen.routePath,
              pageBuilder: (context, state) => CustomTransitionPage(
                // Phase 3 마이그레이션 완료: Clean Architecture 버전으로 전환
                child: CreatePostScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
            // Chat 라우트 - Clean Architecture v4.0
            GoRoute(
              name: ChatListWidgetClean.routeName,
              path: ChatListWidgetClean.routePath,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: ChatListWidgetClean(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
            GoRoute(
              name: FriendsWidget.routeName,
              path: FriendsWidget.routePath,
              pageBuilder: (context, state) => CustomTransitionPage(
                child: FriendsWidget(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) => child,
              ),
            ),
          ],
        ),
        // Auth Feature 라우트 (Phase 2: 모듈화)
        ...AuthRoutes.routes(ref),
        // Profile Feature 라우트 (Phase 2: 모듈화)
        ...ProfileRoutes.routes(ref),

        // 개발 & 테스트 라우트 (Feature 외부)
        AppRoute(
          name: TestpageSelectWidget.routeName,
          path: TestpageSelectWidget.routePath,
          builder: (context, params) => TestpageSelectWidget(),
        ).toRoute(ref),
        AppRoute(
          name: 'devPage',
          path: '/dev',
          builder: (context, params) => TestpageSelectWidget(),
        ).toRoute(ref),
        // Creation Feature 라우트 (Phase 2: 모듈화)
        ...CreationRoutes.routes(ref),
        // Chat Feature 라우트 (Phase 2: 모듈화)
        ...ChatRoutes.routes(ref),

        // Debug 라우트 (개발자 전용 - kDebugMode에서만 접근)
        GoRoute(
          name: 'DebugLogs',
          path: '/debug/logs',
          pageBuilder: (context, state) {
            // 개발 모드가 아니면 접근 차단
            if (!kDebugMode) {
              return MaterialPage(
                key: state.pageKey,
                child: Scaffold(
                  appBar: AppBar(title: Text('Access Denied')),
                  body: Center(
                    child: Text(
                      'Debug mode only',
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ),
              );
            }

            return MaterialPage(
              key: state.pageKey,
              child: DebugLogPage(),
            );
          },
        ),

        // Notification Feature 라우트
        ...NotificationRoutes.routes(ref),
        // Post Feature 라우트
        ...PostRoutes.routes(ref),
        // Search Feature 라우트 (현재 빈 리스트 - 향후 구현 대비)
        ...SearchRoutes.routes(ref),
      ],
      observers: [routeObserver, BotToastNavigatorObserver()],
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

/// Navigation Extensions (Phase 1: 단순화)
///
/// **변경 사항**:
/// - ignoreRedirect 파라미터 제거 (AppStateNotifier 제거로 불필요)
/// - mounted 체크만 유지
/// - Phase 3에서 AuthGuard와 통합 예정
extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) =>
      !mounted
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
  }) =>
      !mounted
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // 스택에 라우트가 하나만 있으면 pop 대신 초기 페이지로 이동
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

/// GoRouter Extensions (Phase 1: AppStateNotifier 제거)
///
/// **이전 기능**:
/// - prepareAuthEvent(): Auth 변경 알림 제어 (제거됨)
/// - shouldRedirect(): 리다이렉트 필요 여부 체크 (제거됨)
/// - clearRedirectLocation(): 리다이렉트 위치 초기화 (제거됨)
///
/// **Phase 3**: AuthGuard 패턴으로 완전히 대체 예정
extension GoRouterExtensions on GoRouter {
  // AppStateNotifier 관련 메서드 제거
  // 향후 AuthGuard 패턴으로 대체
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class AppParameters {
  AppParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // 파라미터가 비어있거나 transition info 전용 extra 파라미터만 있으면 isEmpty true
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // extras에서 가져온 파라미터는 직접 반환
    if (param is! String) {
      return param;
    }
    // 직렬화된 값 역직렬화하여 반환
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class AppRoute {
  const AppRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, AppParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(WidgetRef ref) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) => AuthGuard.checkAuth(
          requireAuth: requireAuth,
          state: state,
        ),
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = AppParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return CustomTransitionPage(
            key: state.pageKey,
            child: child,
            transitionDuration: transitionInfo.hasTransition
                ? transitionInfo.duration
                : Duration.zero, // 애니메이션 없이 즉시 전환
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              if (!transitionInfo.hasTransition) {
                return child; // 애니메이션 없이 즉시 표시
              }
              // 페이드 전환 효과 (hasTransition: true일 때만)
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.duration = const Duration(milliseconds: 300),
  });

  final bool hasTransition;
  final Duration duration;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
