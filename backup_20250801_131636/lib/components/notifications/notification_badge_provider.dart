import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/services/notification_service.dart';
import 'notification_badge.dart';

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
    final user = currentUser;
    
    if (user == null || user.uid == null) {
      // 로그인하지 않은 경우 0개로 표시
      return builder(context, 0);
    }

    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    return StreamBuilder<int>(
      stream: notificationService.getUnreadNotificationCount(user.uid!),
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
          onPressed: onPressed ?? () {
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