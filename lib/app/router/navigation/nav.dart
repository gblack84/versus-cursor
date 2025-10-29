import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/core_exports.dart';

import '/features/chat/domain/entities/chat.dart' as chat_entities;
import '/app/widgets/index.dart';
import '/app/widgets/navigation/main_navigation_shell.dart';

// Non-Auth Feature imports from app/widgets/index.dart
// (These are still needed until their respective features are migrated)

// Import Notification Feature routes
import '/features/notifications/presentation/routes/notification_routes.dart';
// Import Profile Feature screens
import '/features/profile/presentation/screens/profile_edit/profile_edit_screen.dart';
import '/features/profile/presentation/screens/settings/settings_screen.dart';
import '/features/profile/presentation/screens/user_posts_list/user_posts_list_screen.dart';
import '/features/profile/presentation/screens/onboarding/onboarding_flow_screen.dart';
import '/features/profile/presentation/screens/user_info/user_info_display/user_info_display_screen.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  User? initialUser;
  User? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => showSplashImage;
  bool get loggedIn => user != null;
  bool get initiallyLoggedIn => initialUser != null;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(User? newUser) {
    final shouldUpdate =
        user?.uid == null || newUser?.uid == null || user?.uid != newUser?.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => StartPageWidget(),
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) {
            if (appStateNotifier.loggedIn) {
              return '/home';
            }
            return null;
          },
          builder: (context, state) => StartPageWidget(),
        ),
        // ShellRoute for bottom navigation
        ShellRoute(
          builder: (context, state, child) => MainNavigationShell(child: child),
          routes: [
            // Main navigation routes
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
            // Chat routes - Clean Architecture v4.0
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
        AppRoute(
          name: LoginPageWidget.routeName,
          path: LoginPageWidget.routePath,
          builder: (context, params) => LoginPageWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: CreateAccountWidget.routeName,
          path: CreateAccountWidget.routePath,
          builder: (context, params) => CreateAccountWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: ForgotPasswordWidget.routeName,
          path: ForgotPasswordWidget.routePath,
          builder: (context, params) => ForgotPasswordWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: UserInfoInputWidget.routeName,
          path: UserInfoInputWidget.routePath,
          requireAuth: true,
          builder: (context, params) => UserInfoInputWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: TestpageSelectWidget.routeName,
          path: TestpageSelectWidget.routePath,
          builder: (context, params) => TestpageSelectWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: 'devPage',
          path: '/dev',
          builder: (context, params) => TestpageSelectWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: ExpertiseSelectWidget.routeName,
          path: ExpertiseSelectWidget.routePath,
          builder: (context, params) => ExpertiseSelectWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: HobbiesSelectWidget.routeName,
          path: HobbiesSelectWidget.routePath,
          builder: (context, params) => HobbiesSelectWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: AgrredSelectWidget.routeName,
          path: AgrredSelectWidget.routePath,
          builder: (context, params) => AgrredSelectWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: ProfileEditScreen.routeName,
          path: ProfileEditScreen.routePath,
          requireAuth: true,
          builder: (context, params) => ProfileEditScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: SettingsScreen.routeName,
          path: SettingsScreen.routePath,
          requireAuth: true,
          builder: (context, params) => SettingsScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: UserPostsListScreen.routeName,
          path: UserPostsListScreen.routePath,
          requireAuth: true,
          builder: (context, params) => UserPostsListScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(appStateNotifier),
        // OnboardingFlowScreen route
        AppRoute(
          name: OnboardingFlowScreen.routeName,
          path: OnboardingFlowScreen.routePath,
          requireAuth: true,
          builder: (context, params) => OnboardingFlowScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(appStateNotifier),
        // UserInfoDisplayScreen route
        AppRoute(
          name: UserInfoDisplayScreen.routeName,
          path: UserInfoDisplayScreen.routePath,
          requireAuth: false,
          builder: (context, params) => UserInfoDisplayScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: StartPageWidget.routeName,
          path: StartPageWidget.routePath,
          builder: (context, params) => StartPageWidget(),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: PhoneCreatAccountWidget.routeName,
          path: PhoneCreatAccountWidget.routePath,
          builder: (context, params) => PhoneCreatAccountWidget(
            phoneNumberParam: params.getParam(
              'phoneNumberParam',
              ParamType.String,
            ),
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: PhonelogeinpincodeWidget.routeName,
          path: PhonelogeinpincodeWidget.routePath,
          builder: (context, params) => PhonelogeinpincodeWidget(
            phoneNumberParam: params.getParam(
              'phoneNumberParam',
              ParamType.String,
            ),
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: ProImageEditorPage.routeName,
          path: ProImageEditorPage.routePath,
          builder: (context, params) => ProImageEditorPage(
            imagePath: params.getParam(
              'imagePath',
              ParamType.String,
            ),
            box: params.getParam(
              'box',
              ParamType.String,
            ),
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: ImageViewerPage.routeName,
          path: ImageViewerPage.routePath,
          builder: (context, params) => ImageViewerPage(
            imageUrls: params.getParam<String>('imageUrls', ParamType.String) !=
                    null
                ? (params.getParam<String>('imageUrls', ParamType.String) ?? '')
                    .split(',')
                : [],
            imagePaths:
                params.getParam<String>('imagePaths', ParamType.String) != null
                    ? (params.getParam<String>(
                                'imagePaths', ParamType.String) ??
                            '')
                        .split('|')
                    : [],
            initialIndex: params.getParam(
                  'initialIndex',
                  ParamType.int,
                ) ??
                0,
            box: params.getParam(
              'box',
              ParamType.String,
            ),
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: ChatDetailWidgetClean.routeName,
          path: ChatDetailWidgetClean.routePath,
          requireAuth: true,
          builder: (context, params) => ChatDetailWidgetClean(
            chatDocument: params.state.extra != null
                ? (params.state.extra as Map<String, dynamic>)['chatDocument']
                    as chat_entities.Chat?
                : null,
          ),
        ).toRoute(appStateNotifier),
        AppRoute(
          name: AIChatPageClean.routeName,
          path: AIChatPageClean.routePath,
          requireAuth: true,
          builder: (context, params) => AIChatPageClean(
            aiChatId: params.getParam('aiChatId', ParamType.String),
          ),
        ).toRoute(appStateNotifier),

        // Notification Feature routes
        ...NotificationRoutes.routes,
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

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
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
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
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

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
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
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
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

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/startPage';
          }
          return null;
        },
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

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
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
