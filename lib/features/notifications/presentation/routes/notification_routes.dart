import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart'; // AppRoute, ParamType, GoRoute
import '../screens/notifications_list/notifications_list_widget.dart';
import '../screens/voting_notifications/voting_notifications_widget.dart';
import '../screens/social_notifications/social_notifications_widget.dart';
import '../screens/system_notifications/system_notifications_widget.dart';

/// Notification Feature Routes (Clean Architecture v4.0)
///
/// **Phase 1.2 마이그레이션 완료** (2025-11-10)
///
/// ## 아키텍처 개요
///
/// Feature-First 패턴에 따라 Notifications Feature의 모든 라우트를 독립적으로 관리합니다.
/// nav.dart의 복잡도를 줄이고 Feature별 응집도를 높입니다.
///
/// ## 라우트 구성 (4개)
///
/// 1. **NotificationsListWidget** (`/notifications`)
///    - 전체 알림 목록 (3가지 타입 통합: Social, System, Voting)
///    - requireAuth: true (로그인 필수)
///    - Badge 실시간 업데이트 (unreadNotificationCountProvider)
///
/// 2. **VotingNotificationsWidget** (`/notifications/voting`)
///    - 투표 요청 알림만 필터링
///    - requireAuth: true
///    - Firebase Functions에서 생성 (targetAudienceFlow → sendNotificationsByAI)
///
/// 3. **SocialNotificationsWidget** (`/notifications/social`)
///    - 팔로우, 좋아요, 댓글 등 소셜 알림
///    - requireAuth: true
///    - 실시간 동기화 (Firestore Stream)
///
/// 4. **SystemNotificationsWidget** (`/notifications/system`)
///    - 시스템 공지, 업데이트, 정책 변경 등
///    - requireAuth: true
///    - 읽음 상태 관리 (markAsRead UseCase)
///
/// ## Phase 1.2 마이그레이션 내용
///
/// **Before (Phase 1.1)**: nav.dart에 직접 GoRoute 정의
/// ```dart
/// GoRoute(
///   path: '/notifications',
///   name: 'notificationsList',
///   builder: (context, state) => NotificationsListWidget(),
/// )
/// ```
///
/// **After (Phase 1.2)**: AppRoute 패턴 + Feature Routes 모듈화
/// ```dart
/// AppRoute(
///   name: 'notificationsList',
///   path: '/notifications',
///   requireAuth: true,  // AuthGuard 자동 통합
///   builder: (context, params) => NotificationsListWidget(),
/// ).toRoute(ref)
/// ```
///
/// **주요 변경 사항**:
/// - ✅ requireAuth: true → AuthGuard 자동 적용
/// - ✅ WidgetRef 파라미터 → Riverpod 통합 지원
/// - ✅ AppRoute.toRoute(ref) → NoTransitionPage (즉시 전환, 0ms)
/// - ✅ 타입 안전 네비게이션 → NotificationRoutes.notificationsList 상수
///
/// ## 애니메이션
///
/// 모든 라우트는 **즉시 전환** (Duration.zero, 애니메이션 없음):
/// - 성능 최적화 우선
/// - 알림 목록은 빈번한 이동 → 애니메이션 불필요
/// - AppRoute 패턴 기본 동작: NoTransitionPage
///
/// ## AuthGuard 통합
///
/// 모든 라우트는 `requireAuth: true`로 설정되어 있어 AuthGuard가 자동으로 인증을 체크합니다:
/// - 미인증 사용자 → `/startPage`로 리다이렉션 (Phase 4)
/// - Guard Analytics 이벤트 자동 기록 (Phase 5)
/// - redirectLocation 저장 → 로그인 후 원래 페이지로 복귀
///
/// ## 사용 예시
///
/// ```dart
/// // 1. 타입 안전 네비게이션 (권장)
/// context.goNamed(NotificationRoutes.notificationsList);
///
/// // 2. 특정 타입 알림으로 이동
/// context.goNamed(NotificationRoutes.votingNotifications);
/// context.goNamed(NotificationRoutes.socialNotifications);
/// context.goNamed(NotificationRoutes.systemNotifications);
///
/// // 3. 인증 체크 후 이동 (mounted 체크 포함)
/// context.goNamedAuth(
///   NotificationRoutes.notificationsList,
///   mounted,
/// );
///
/// // 4. 뒤로가기
/// context.safePop(); // 스택이 비면 홈으로 이동
/// ```
///
/// ## nav.dart 통합
///
/// ```dart
/// // /lib/app/router/navigation/nav.dart (line 138)
/// routes: [
///   ...NotificationRoutes.routes(ref), // 4개 라우트 병합
/// ],
/// ```
///
/// ## 참조 문서
///
/// - [notifications/README.md](../../../README.md) - Notifications Feature 전체 가이드
/// - [/lib/app/router/README.md](/lib/app/router/README.md) - Router 시스템 개요
/// - [/lib/app/router/navigation/README.md](/lib/app/router/navigation/README.md) - Navigation 상세 가이드
/// - [/lib/app/router/guards/README.md](/lib/app/router/guards/README.md) - AuthGuard + Phase 5 Analytics
class NotificationRoutes {
  /// Private constructor to prevent instantiation
  NotificationRoutes._();

  /// List of all notification-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...NotificationRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  static List<GoRoute> routes(WidgetRef ref) => [
        // Notifications List Page (전체 알림 목록)
        AppRoute(
          name: 'notificationsList',
          path: '/notifications',
          requireAuth: true, // 알림은 로그인 필수
          builder: (context, params) => NotificationsListWidget(),
        ).toRoute(ref),

        // Voting Notifications Page (투표 알림)
        AppRoute(
          name: 'votingNotifications',
          path: '/notifications/voting',
          requireAuth: true, // 투표 알림은 로그인 필수
          builder: (context, params) => const VotingNotificationsWidget(),
        ).toRoute(ref),

        // Social Notifications Page (소셜 알림)
        AppRoute(
          name: 'socialNotifications',
          path: '/notifications/social',
          requireAuth: true, // 소셜 알림은 로그인 필수
          builder: (context, params) => const SocialNotificationsWidget(),
        ).toRoute(ref),

        // System Notifications Page (시스템 알림)
        AppRoute(
          name: 'systemNotifications',
          path: '/notifications/system',
          requireAuth: true, // 시스템 알림은 로그인 필수
          builder: (context, params) => const SystemNotificationsWidget(),
        ).toRoute(ref),
      ];

  /// Route names for type-safe navigation
  static const String notificationsList = 'notificationsList';
  static const String votingNotifications = 'votingNotifications';
  static const String socialNotifications = 'socialNotifications';
  static const String systemNotifications = 'systemNotifications';

  /// Route paths for direct navigation
  static const String notificationsListPath = '/notifications';
  static const String votingNotificationsPath = '/notifications/voting';
  static const String socialNotificationsPath = '/notifications/social';
  static const String systemNotificationsPath = '/notifications/system';
}