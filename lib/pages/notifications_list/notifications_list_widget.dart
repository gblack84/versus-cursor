import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';

class NotificationsListWidget extends StatefulWidget {
  const NotificationsListWidget({Key? key}) : super(key: key);

  static String routeName = 'notificationsList';
  static String routePath = '/notifications';

  @override
  State<NotificationsListWidget> createState() => _NotificationsListWidgetState();
}

class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: StreamBuilder<List<NotificationsModel>>(
          stream: queryNotificationsModel(
            queryBuilder: (notificationsRecord) => notificationsRecord
                .where('userId', isEqualTo: currentUserUid)
                .orderBy('createdAt', descending: true),
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

            List<NotificationsModel> notifications = snapshot.data!;
            
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
                final isExpired = notification.expiryTime != null &&
                    notification.expiryTime!.isBefore(DateTime.now());
                
                return Opacity(
                  opacity: notification.read || isExpired ? 0.6 : 1.0,
                  child: InkWell(
                    onTap: isExpired ? null : () async {
                      // 읽음 처리
                      if (!notification.read) {
                        await notification.reference.update({
                          'read': true,
                          'readAt': FieldValue.serverTimestamp(),
                        });
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
                        color: notification.read 
                            ? Colors.transparent 
                            : AppTheme.of(context).accent1.withValues(alpha: 0.1),
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
                              Icons.how_to_vote,
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
                                  notification.type == 'votingRequest' 
                                      ? '투표 요청' 
                                      : '알림',
                                  style: AppTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '이 게시물에 대한 당신의 의견이 필요해요!',
                                  style: AppTheme.of(context).bodyMedium.override(
                                        color: AppTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  DateFormat('MM월 dd일 HH:mm').format(
                                    notification.createdAt!,
                                  ),
                                  style: AppTheme.of(context).bodySmall.override(
                                        color: AppTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.read && !isExpired)
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
}