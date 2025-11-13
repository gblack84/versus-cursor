import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart'; // AppTheme, AppRoute, ParamType, CustomTransitionPage, fixStatusBarOniOS16AndBelow, GoRoute 등
import '/features/auth/presentation/screens/login/login_page/login_page_widget.dart';
import '/features/auth/presentation/screens/signup/create_account/create_account_widget.dart';
import '/features/auth/presentation/screens/forgot_password/forgot_password/forgot_password_widget.dart';
import '/features/auth/presentation/screens/start/start_page/start_page_widget.dart';
import '/features/auth/presentation/screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart';
import '/features/auth/presentation/screens/phone_auth/phonelogeinpincode_widget.dart';

/// Auth Feature Routes (Clean Architecture v4.0)
///
/// **Feature-First Architecture**:
/// - 인증 관련 모든 routes를 Feature 내부로 캡슐화
/// - nav.dart의 복잡도 감소
///
/// **Phase 2 마이그레이션**:
/// - AppRoute 패턴 유지 (requireAuth, asyncParams 지원)
/// - Custom transition 지원 (LoginPage, StartPage)
/// - WidgetRef 파라미터로 Riverpod 통합
///
/// **Routes**:
/// - LoginPageWidget (로그인, custom fade+slide transition)
/// - CreateAccountWidget (회원가입)
/// - ForgotPasswordWidget (비밀번호 찾기)
/// - StartPageWidget (시작 페이지, custom fade+slide transition)
/// - PhoneCreatAccountWidget (전화번호 회원가입)
/// - PhonelogeinpincodeWidget (전화번호 PIN 인증)
class AuthRoutes {
  /// Private constructor to prevent instantiation
  AuthRoutes._();

  /// List of all auth-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...AuthRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  static List<GoRoute> routes(WidgetRef ref) => [
        // Login Page (로그인, Custom Transition)
        GoRoute(
          name: LoginPageWidget.routeName,
          path: LoginPageWidget.routePath,
          pageBuilder: (context, state) {
            fixStatusBarOniOS16AndBelow(context);
            return CustomTransitionPage(
              key: state.pageKey,
              child: LoginPageWidget(),
              transitionDuration: Duration(milliseconds: 400),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Fade + Slide transition (replicates FlutterFlow animation)
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 0.15), // 60px → 15% of screen height
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
            );
          },
        ),

        // Create Account Widget (회원가입)
        AppRoute(
          name: CreateAccountWidget.routeName,
          path: CreateAccountWidget.routePath,
          builder: (context, params) => CreateAccountWidget(),
        ).toRoute(ref),

        // Forgot Password Widget (비밀번호 찾기)
        AppRoute(
          name: ForgotPasswordWidget.routeName,
          path: ForgotPasswordWidget.routePath,
          builder: (context, params) => ForgotPasswordWidget(),
        ).toRoute(ref),

        // Start Page Widget (시작 페이지, Custom Transition)
        GoRoute(
          name: StartPageWidget.routeName,
          path: StartPageWidget.routePath,
          pageBuilder: (context, state) {
            fixStatusBarOniOS16AndBelow(context);
            return CustomTransitionPage(
              key: state.pageKey,
              child: StartPageWidget(),
              transitionDuration: Duration(milliseconds: 400),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Fade + Slide transition (replicates FlutterFlow animation)
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0.0, 0.15), // 60px → 15% of screen height
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
            );
          },
        ),

        // Phone Create Account Widget (전화번호 회원가입)
        AppRoute(
          name: PhoneCreatAccountWidget.routeName,
          path: PhoneCreatAccountWidget.routePath,
          builder: (context, params) => PhoneCreatAccountWidget(
            phoneNumberParam: params.getParam(
              'phoneNumberParam',
              ParamType.String,
            ),
          ),
        ).toRoute(ref),

        // Phone Login Pincode Widget (전화번호 PIN 인증)
        AppRoute(
          name: PhonelogeinpincodeWidget.routeName,
          path: PhonelogeinpincodeWidget.routePath,
          builder: (context, params) => PhonelogeinpincodeWidget(
            phoneNumberParam: params.getParam(
              'phoneNumberParam',
              ParamType.String,
            ),
          ),
        ).toRoute(ref),
      ];

  /// Route names for type-safe navigation
  ///
  /// **사용 예시**:
  /// ```dart
  /// context.goNamed(AuthRoutes.login);
  /// context.goNamed(AuthRoutes.createAccount);
  /// ```
  static String get login => LoginPageWidget.routeName;
  static String get createAccount => CreateAccountWidget.routeName;
  static String get forgotPassword => ForgotPasswordWidget.routeName;
  static String get startPage => StartPageWidget.routeName;
  static String get phoneCreateAccount => PhoneCreatAccountWidget.routeName;
  static String get phoneLoginPincode => PhonelogeinpincodeWidget.routeName;

  /// Route paths for reference
  static String get loginPath => LoginPageWidget.routePath;
  static String get createAccountPath => CreateAccountWidget.routePath;
  static String get forgotPasswordPath => ForgotPasswordWidget.routePath;
  static String get startPagePath => StartPageWidget.routePath;
  static String get phoneCreateAccountPath => PhoneCreatAccountWidget.routePath;
  static String get phoneLoginPincodePath => PhonelogeinpincodeWidget.routePath;
}
