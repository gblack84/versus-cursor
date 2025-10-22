import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '/core/domain/usecases/get_current_user_use_case.dart';
import '/features/notifications/domain/usecases/watch_unread_count_usecase.dart';
import '/features/notifications/presentation/widgets/notification_badge.dart';

/// 앱바에서 사용할 수 있는 알림 아이콘 액션
///
/// 실시간으로 읽지 않은 알림 개수를 뱃지로 표시합니다.
/// GetIt DI를 통해 UseCase를 주입받아 Clean Architecture를 준수합니다.
class NotificationAppBarAction extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // UseCase를 GetIt DI에서 가져옴
    final getCurrentUser = GetIt.instance<GetCurrentUserUseCase>();
    final watchUnreadCount = GetIt.instance<WatchUnreadCountUseCase>();

    // currentUserId getter 사용 (동기 메서드)
    final userId = getCurrentUser.currentUserId;

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

    return StreamBuilder<int>(
      stream: watchUnreadCount.call(userId),
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return NotificationIconWithBadge(
          count: count,
          icon: icon,
          iconColor: iconColor,
          badgeColor: badgeColor,
          onPressed: onPressed ??
              () {
                // 기본 동작: 알림 목록 페이지로 이동
                context.pushNamed('notificationsList');
              },
        );
      },
    );
  }
}
