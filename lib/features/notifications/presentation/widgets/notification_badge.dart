import 'package:flutter/material.dart';

/// 알림 뱃지를 표시하는 위젯
/// 
/// 아이콘 위에 읽지 않은 알림 개수를 표시합니다.
/// 개수가 0일 때는 뱃지가 표시되지 않습니다.
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final double? size;
  final bool showZero;
  final Alignment alignment;
  final EdgeInsets padding;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.count,
    this.badgeColor,
    this.textColor,
    this.size,
    this.showZero = false,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showZero) {
      return child;
    }

    final theme = Theme.of(context);
    final badgeBackgroundColor = badgeColor ?? theme.colorScheme.error;
    final badgeTextColor = textColor ?? Colors.white;
    final badgeSize = size ?? 18.0;

    // 99보다 큰 숫자는 99+로 표시
    final displayCount = count > 99 ? '99+' : count.toString();

    return Stack(
      alignment: alignment,
      children: [
        child,
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: padding,
            constraints: BoxConstraints(
              minWidth: badgeSize,
              minHeight: badgeSize,
            ),
            decoration: BoxDecoration(
              color: badgeBackgroundColor,
              shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
              borderRadius: count > 99 ? BorderRadius.circular(badgeSize / 2) : null,
            ),
            child: Center(
              child: Text(
                displayCount,
                style: TextStyle(
                  color: badgeTextColor,
                  fontSize: badgeSize * 0.6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 알림 아이콘과 뱃지를 함께 표시하는 위젯
class NotificationIconWithBadge extends StatelessWidget {
  final int count;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final Color? badgeColor;
  final VoidCallback? onPressed;

  const NotificationIconWithBadge({
    Key? key,
    required this.count,
    this.icon = Icons.notifications_outlined,
    this.iconSize = 24.0,
    this.iconColor,
    this.badgeColor,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: NotificationBadge(
        count: count,
        badgeColor: badgeColor,
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
      onPressed: onPressed,
    );
  }
}