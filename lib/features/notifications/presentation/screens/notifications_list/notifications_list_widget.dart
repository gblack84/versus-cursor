import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/notifications/presentation/providers/notification_providers.dart';
import '/features/notifications/presentation/helpers/notification_display_helper.dart';
import '/core_exports.dart';

/// 알림 목록 화면
///
/// **Riverpod ConsumerWidget**:
/// - StatefulWidget → ConsumerWidget 마이그레이션 완료
/// - StreamBuilder → AsyncValue.when() 패턴 사용
/// - GetIt → Riverpod Provider로 DI 전환
///
/// **상태 관리**:
/// - watchUserNotificationsProvider: 실시간 알림 스트림
/// - markAsReadNotifierProvider: 읽음 처리 액션
class NotificationsListWidget extends ConsumerWidget {
  const NotificationsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Riverpod Provider로 실시간 알림 감시
    final notificationsAsync = ref.watch(
      watchUserNotificationsProvider(userId),
    );

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
        // AsyncValue.when()으로 loading/error/data 상태 처리
        child: notificationsAsync.when(
          // 로딩 중
          loading: () => Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.of(context).primary,
                ),
              ),
            ),
          ),
          // 에러 발생
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 72.0,
                    color: AppTheme.of(context).error,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    '알림을 불러올 수 없습니다',
                    style: AppTheme.of(context).titleLarge.override(
                          color: AppTheme.of(context).error,
                          letterSpacing: 0.0,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    error.toString(),
                    style: AppTheme.of(context).bodyMedium.override(
                          color: AppTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // 데이터 로드 성공
          data: (notifications) {
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
                            // Riverpod Notifier로 읽음 처리
                            if (!notification.isRead) {
                              if (userId.isNotEmpty) {
                                try {
                                  await ref
                                      .read(markAsReadProvider.notifier)
                                      .call(
                                        notificationId: notification.id,
                                        userId: userId,
                                      );
                                } catch (e) {
                                  // 에러 처리는 Notifier 내부에서 수행됨
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('알림 읽음 처리 실패'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              }
                            }

                            // 알림 클릭 시 관련 게시물로 이동하는 기능이 필요합니다.
                            // 현재는 알림 읽음 처리만 수행하고 있습니다.
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('알림 상세 보기 구현 예정'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
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
                              NotificationDisplayHelper.getIcon(notification.type),
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
                                  NotificationDisplayHelper.getTitle(notification.type),
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
                                  dateTimeFormat('relative', notification.createdAt),
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
}
