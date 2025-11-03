import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/notifications/presentation/providers/notification_providers.dart';
import '/features/notifications/presentation/widgets/notification_badge.dart';

/// 앱바에서 사용할 수 있는 알림 아이콘 액션
///
/// **Riverpod ConsumerWidget**:
/// - StatelessWidget → ConsumerWidget 마이그레이션 완료
/// - StreamBuilder → AsyncValue.when() 패턴 사용
/// - GetIt → Riverpod Provider로 DI 전환
///
/// **상태 관리**:
/// - watchUnreadCountProvider: 실시간 읽지 않은 알림 개수
///
/// **사용 예시**:
/// ```dart
/// AppBar(
///   actions: [
///     NotificationAppBarAction(),
///   ],
/// )
/// ```
class NotificationAppBarAction extends ConsumerWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? badgeColor;

  const NotificationAppBarAction({
    Key? key,
    this.onPressed,
    this.icon = Icons.notifications_outlined,
    this.iconColor,
    this.badgeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FirebaseAuth에서 현재 사용자 ID 가져오기
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      // 로그인하지 않은 경우 0개로 표시
      return NotificationIconWithBadge(
        count: 0,
        icon: icon,
        iconColor: iconColor,
        badgeColor: badgeColor,
        onPressed: onPressed ??
            () {
              // 기본 동작: 알림 목록 페이지로 이동
              context.pushNamed('notificationsList');
            },
      );
    }

    // Riverpod Provider로 실시간 읽지 않은 알림 개수 감시
    final unreadCountAsync = ref.watch(
      watchUnreadCountProvider(userId),
    );

    // AsyncValue.when()으로 loading/error/data 상태 처리
    return unreadCountAsync.when(
      // 로딩 중 또는 에러 시 0개로 표시
      loading: () => NotificationIconWithBadge(
        count: 0,
        icon: icon,
        iconColor: iconColor,
        badgeColor: badgeColor,
        onPressed: onPressed ??
            () {
              context.pushNamed('notificationsList');
            },
      ),
      error: (error, stack) => NotificationIconWithBadge(
        count: 0,
        icon: icon,
        iconColor: iconColor,
        badgeColor: badgeColor,
        onPressed: onPressed ??
            () {
              context.pushNamed('notificationsList');
            },
      ),
      // 데이터 로드 성공
      data: (count) => NotificationIconWithBadge(
        count: count,
        icon: icon,
        iconColor: iconColor,
        badgeColor: badgeColor,
        onPressed: onPressed ??
            () {
              // 기본 동작: 알림 목록 페이지로 이동
              context.pushNamed('notificationsList');
            },
      ),
    );
  }
}
