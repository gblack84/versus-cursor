import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart'; // AppRoute, ParamType, GoRoute
import '/features/profile/presentation/screens/profile_edit/profile_edit_screen.dart';
import '/features/profile/presentation/screens/settings/settings_screen.dart';
import '/features/profile/presentation/screens/user_posts_list/user_posts_list_screen.dart';
import '/features/profile/presentation/screens/onboarding/onboarding_flow_screen.dart';
import '/features/profile/presentation/screens/user_info/user_info_display/user_info_display_screen.dart';
import '/features/profile/presentation/screens/user_info_input/user_info_input_widget.dart';
import '/features/profile/presentation/screens/onboarding/interest_selection/expertise_select/expertise_select_widget.dart';
import '/features/profile/presentation/screens/onboarding/interest_selection/hobbies_select/hobbies_select_widget.dart';
import '/features/profile/presentation/screens/onboarding/interest_selection/agreed_select/agrred_select_widget.dart';

/// Profile Feature Routes (Clean Architecture v4.0)
///
/// **Feature-First Architecture**:
/// - 프로필 관련 모든 routes를 Feature 내부로 캡슐화
/// - nav.dart의 복잡도 감소 (668줄 → 단순화)
///
/// **Phase 2 마이그레이션**:
/// - AppRoute 패턴 유지 (requireAuth, asyncParams 지원)
/// - WidgetRef 파라미터로 Riverpod 통합
/// - Type-safe navigation 지원
///
/// **Routes**:
/// - ProfileEditScreen (프로필 편집, requireAuth: true)
/// - SettingsScreen (설정, requireAuth: true)
/// - UserPostsListScreen (사용자 게시물 목록, requireAuth: true)
/// - OnboardingFlowScreen (온보딩, requireAuth: true)
/// - UserInfoDisplayScreen (사용자 정보 표시, requireAuth: false)
/// - UserInfoInputWidget (사용자 정보 입력, requireAuth: true)
class ProfileRoutes {
  /// Private constructor to prevent instantiation
  ProfileRoutes._();

  /// List of all profile-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...ProfileRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  static List<GoRoute> routes(WidgetRef ref) => [
        // Profile Edit Screen (프로필 편집)
        AppRoute(
          name: ProfileEditScreen.routeName,
          path: ProfileEditScreen.routePath,
          requireAuth: true,
          builder: (context, params) => ProfileEditScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(ref),

        // Settings Screen (설정)
        AppRoute(
          name: SettingsScreen.routeName,
          path: SettingsScreen.routePath,
          requireAuth: true,
          builder: (context, params) => SettingsScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(ref),

        // User Posts List Screen (사용자 게시물 목록)
        AppRoute(
          name: UserPostsListScreen.routeName,
          path: UserPostsListScreen.routePath,
          requireAuth: true,
          builder: (context, params) => UserPostsListScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(ref),

        // Onboarding Flow Screen (온보딩)
        AppRoute(
          name: OnboardingFlowScreen.routeName,
          path: OnboardingFlowScreen.routePath,
          requireAuth: true,
          builder: (context, params) => OnboardingFlowScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(ref),

        // User Info Display Screen (사용자 정보 표시, Public)
        AppRoute(
          name: UserInfoDisplayScreen.routeName,
          path: UserInfoDisplayScreen.routePath,
          requireAuth: false, // Public route
          builder: (context, params) => UserInfoDisplayScreen(
            userId: params.getParam('userId', ParamType.String) ?? '',
          ),
        ).toRoute(ref),

        // User Info Input Widget (사용자 정보 입력)
        AppRoute(
          name: UserInfoInputWidget.routeName,
          path: UserInfoInputWidget.routePath,
          requireAuth: true,
          builder: (context, params) => UserInfoInputWidget(),
        ).toRoute(ref),

        // Interest Selection Screens (관심사 선택)
        // Expertise Select (전문 분야 선택)
        AppRoute(
          name: ExpertiseSelectWidget.routeName,
          path: ExpertiseSelectWidget.routePath,
          requireAuth: false, // Public route (온보딩 전에도 접근 가능)
          builder: (context, params) => const ExpertiseSelectWidget(),
        ).toRoute(ref),

        // Hobbies Select (취미 선택)
        AppRoute(
          name: HobbiesSelectWidget.routeName,
          path: HobbiesSelectWidget.routePath,
          requireAuth: false, // Public route
          builder: (context, params) => const HobbiesSelectWidget(),
        ).toRoute(ref),

        // Agrred Select (관심사 선택)
        AppRoute(
          name: AgrredSelectWidget.routeName,
          path: AgrredSelectWidget.routePath,
          requireAuth: false, // Public route
          builder: (context, params) => const AgrredSelectWidget(),
        ).toRoute(ref),
      ];

  /// Route names for type-safe navigation
  ///
  /// **사용 예시**:
  /// ```dart
  /// context.goNamed(ProfileRoutes.profileEdit, pathParameters: {'userId': userId});
  /// ```
  static String get profileEdit => ProfileEditScreen.routeName;
  static String get settings => SettingsScreen.routeName;
  static String get userPostsList => UserPostsListScreen.routeName;
  static String get onboardingFlow => OnboardingFlowScreen.routeName;
  static String get userInfoDisplay => UserInfoDisplayScreen.routeName;
  static String get userInfoInput => UserInfoInputWidget.routeName;

  // Interest Selection
  static String get expertiseSelect => ExpertiseSelectWidget.routeName;
  static String get hobbiesSelect => HobbiesSelectWidget.routeName;
  static String get agrredSelect => AgrredSelectWidget.routeName;

  /// Route paths for reference
  static String get profileEditPath => ProfileEditScreen.routePath;
  static String get settingsPath => SettingsScreen.routePath;
  static String get userPostsListPath => UserPostsListScreen.routePath;
  static String get onboardingFlowPath => OnboardingFlowScreen.routePath;
  static String get userInfoDisplayPath => UserInfoDisplayScreen.routePath;
  static String get userInfoInputPath => UserInfoInputWidget.routePath;

  // Interest Selection Paths
  static String get expertiseSelectPath => ExpertiseSelectWidget.routePath;
  static String get hobbiesSelectPath => HobbiesSelectWidget.routePath;
  static String get agrredSelectPath => AgrredSelectWidget.routePath;
}
