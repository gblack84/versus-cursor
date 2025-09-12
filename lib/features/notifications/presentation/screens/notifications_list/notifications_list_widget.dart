import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/core/domain/ports/i_user_service.dart';
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/notifications/domain/models/notification.dart'
    show NotificationType;
import '/features/notifications/domain/usecases/mark_notification_as_read_use_case.dart';
import '/core_exports.dart';

class NotificationsListWidget extends StatefulWidget {
  const NotificationsListWidget({Key? key}) : super(key: key);

  static String routeName = 'notificationsList';
  static String routePath = '/notifications';

  @override
  State<NotificationsListWidget> createState() =>
      _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final INotificationRepository _notificationRepository;
  late final MarkNotificationAsReadUseCase _markAsRead;
  late final IUserService _userService;

  @override
  void initState() {
    super.initState();
    _notificationRepository = GetIt.instance<INotificationRepository>();
    _markAsRead = GetIt.instance<MarkNotificationAsReadUseCase>();
    _userService = GetIt.instance<IUserService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        automaticallyImplyLeading: true,
        title: Text(
          '알림',
          style: AppTheme.of(context).headlineMedium.override(
                color: AppTheme.of(context).primaryText,
                fontSize: 22.0,
                letterSpacing: 0.0,
              ),
        ),
        actions: [],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: StreamBuilder<List<domain.Notification>>(
          stream: _notificationRepository.watchUserNotifications(
            userId: _userService.currentUserId,
          ),
          builder: (context, snapshot) {
            // 로딩 중
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.of(context).primary,
                    ),
                  ),
                ),
              );
            }

            List<domain.Notification> notifications = snapshot.data!;

            if (notifications.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 72.0,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '알림이 없습니다',
                        style: AppTheme.of(context).titleLarge.override(
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isExpired = notification.isExpired;

                return Opacity(
                  opacity: notification.isRead || isExpired ? 0.6 : 1.0,
                  child: InkWell(
                    onTap: isExpired
                        ? null
                        : () async {
                            // 읽음 처리
                            if (!notification.isRead) {
                              await _markAsRead.call(
                                MarkAsReadParams(
                                    notificationId: notification.id),
                              );
                            }

                            // 알림 클릭 시 관련 게시물로 이동하는 기능이 필요합니다.
                            // 현재는 알림 읽음 처리만 수행하고 있습니다.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('알림 상세 보기 구현 예정'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? Colors.transparent
                            : AppTheme.of(context)
                                .accent1
                                .withValues(alpha: 0.1),
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.of(context).alternate,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).accent1,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getNotificationIcon(notification),
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getNotificationTitle(notification),
                                  style:
                                      AppTheme.of(context).bodyLarge.override(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  notification.content,
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  DateFormat('MM월 dd일 HH:mm').format(
                                    notification.createdAt,
                                  ),
                                  style: AppTheme.of(context)
                                      .bodySmall
                                      .override(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead && !isExpired)
                            Container(
                              width: 8.0,
                              height: 8.0,
                              decoration: BoxDecoration(
                                color: AppTheme.of(context).error,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _getNotificationTitle(domain.Notification notification) {
    switch (notification.type) {
      case NotificationType.votingRequest:
        return '투표 요청';
      case NotificationType.systemAlert:
        return '시스템 알림';
      case NotificationType.postLiked:
        return '좋아요';
      case NotificationType.commentAdded:
        return '댓글';
      case NotificationType.friendRequest:
        return '친구 요청';
      case NotificationType.postCompleted:
        return '게시물 완료';
      case NotificationType.achievementUnlocked:
        return '업적 달성';
    }
  }

  IconData _getNotificationIcon(domain.Notification notification) {
    switch (notification.type) {
      case NotificationType.votingRequest:
        return Icons.how_to_vote;
      case NotificationType.systemAlert:
        return Icons.info_outline;
      case NotificationType.postLiked:
        return Icons.favorite;
      case NotificationType.commentAdded:
        return Icons.comment;
      case NotificationType.friendRequest:
        return Icons.person_add;
      case NotificationType.postCompleted:
        return Icons.check_circle;
      case NotificationType.achievementUnlocked:
        return Icons.emoji_events;
    }
  }
}
