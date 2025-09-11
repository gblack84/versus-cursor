import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/features/notifications/domain/usecases/get_current_user_id.dart';
import '/features/notifications/domain/usecases/get_unread_notification_count.dart';
import '/features/notifications/presentation/widgets/notification_badge.dart';

/// NotificationService와 연결된 알림 뱃지 제공자
///
/// 실시간으로 읽지 않은 알림 개수를 표시합니다.
class NotificationBadgeProvider extends StatelessWidget {
  final Widget Function(BuildContext context, int count) builder;

  const NotificationBadgeProvider({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // UseCase를 Provider에서 가져옴 (DI container에서 제공)
    final getCurrentUserId =
        Provider.of<GetCurrentUserIdUseCase>(context, listen: false);
    final getUnreadCount =
        Provider.of<GetUnreadNotificationCountUseCase>(context, listen: false);

    final userId = getCurrentUserId.execute();

    if (userId == null) {
      // 로그인하지 않은 경우 0개로 표시
      return builder(context, 0);
    }

    return StreamBuilder<int>(
      stream: getUnreadCount.execute(userId),
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return builder(context, count);
      },
    );
  }
}

/// 앱바에서 사용할 수 있는 알림 아이콘 액션
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
    return NotificationBadgeProvider(
      builder: (context, count) {
        return NotificationIconWithBadge(
          count: count,
          icon: icon,
          iconColor: iconColor,
          badgeColor: badgeColor,
          onPressed: onPressed ??
              () {
                // 기본 동작: 알림 페이지로 이동
                // TODO: 알림 목록 페이지로 라우팅
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('알림 페이지로 이동'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
        );
      },
    );
  }
}
