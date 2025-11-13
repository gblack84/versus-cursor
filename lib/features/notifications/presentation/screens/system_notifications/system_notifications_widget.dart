import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/notifications/presentation/providers/notification_providers.dart';
import '/features/notifications/domain/entities/notification.dart';
import '/core_exports.dart';

/// 시스템 공지 알림 전용 화면
///
/// **Riverpod ConsumerWidget**:
/// - watchSystemNotificationsProvider: System 타입만 필터링된 스트림
/// - AsyncValue.when() 패턴으로 loading/error/data 상태 처리
///
/// **사용 예시**:
/// - 시스템 공지, 업데이트, 유지보수 등의 알림만 보고 싶을 때
/// - 중요한 시스템 메시지 모아보기
class SystemNotificationsWidget extends ConsumerWidget {
  const SystemNotificationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    // Phase C-2: FirebaseAuth 직접 접근 → currentUserIdProvider 사용
    final userId = ref.watch(currentUserIdProvider).value ?? '';

    // System 알림만 필터링된 Stream 구독
    final notificationicationsAsync = ref.watch(
      watchSystemNotificationsProvider(userId),
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        automaticallyImplyLeading: true,
        title: Text(
          '시스템 공지',
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
        child: notificationicationsAsync.when(
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
                    '시스템 공지를 불러올 수 없습니다',
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
                        Icons.campaign_outlined,
                        size: 72.0,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '시스템 공지가 없습니다',
                        style: AppTheme.of(context).titleLarge.override(
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '중요한 시스템 메시지가 있으면 여기에 표시됩니다',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                        textAlign: TextAlign.center,
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
                // SystemNotification 타입 체크
                final notification = notifications[index];
                if (notification is! SystemNotification) {
                  return const SizedBox.shrink();
                }

                // is! 체크 후 타입이 자동으로 확정됨
                final isExpired = notification.isExpired;

                return Opacity(
                  opacity: notification.isRead || isExpired ? 0.6 : 1.0,
                  child: InkWell(
                    onTap: isExpired
                        ? null
                        : () async {
                            // 읽음 처리
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

                            // 액션 URL이 있으면 해당 페이지로 이동 (구현 예정)
                            if (context.mounted) {
                              final actionUrl = notification.actionUrl;
                              if (actionUrl != null && actionUrl.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('이동: $actionUrl'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('시스템 공지 확인'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? Colors.transparent
                            : _getAlertBackgroundColor(
                                context,
                                notification.alertType,
                              ),
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.of(context).alternate,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 알림 타입에 따른 아이콘
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: _getAlertColor(
                                context,
                                notification.alertType,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getAlertIcon(notification.alertType),
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          // 알림 내용
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: AppTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.0,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // 중요도 뱃지
                                    if (notification.alertType ==
                                        SystemAlertType.critical)
                                      Container(
                                        margin:
                                            const EdgeInsets.only(left: 8.0),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 2.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context).error,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: Text(
                                          '중요',
                                          style: AppTheme.of(context)
                                              .bodySmall
                                              .override(
                                                color: Colors.white,
                                                fontSize: 10.0,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4.0),
                                // 내용
                                Text(
                                  notification.content,
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                        letterSpacing: 0.0,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                // 액션 라벨 (있는 경우)
                                if (notification.actionLabel != null &&
                                    notification.actionLabel!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 6.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context).primary,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Text(
                                      notification.actionLabel!,
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ),
                                const SizedBox(height: 4.0),
                                // 시간 정보
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
                          // 읽지 않은 알림 표시
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

  /// 알림 타입에 따른 아이콘 반환
  IconData _getAlertIcon(SystemAlertType alertType) {
    switch (alertType) {
      case SystemAlertType.critical:
        return Icons.error;
      case SystemAlertType.security:
        return Icons.security;
      case SystemAlertType.maintenance:
        return Icons.build;
      case SystemAlertType.update:
        return Icons.system_update;
      case SystemAlertType.info:
        return Icons.info;
    }
  }

  /// 알림 타입에 따른 색상 반환
  Color _getAlertColor(BuildContext context, SystemAlertType alertType) {
    switch (alertType) {
      case SystemAlertType.critical:
        return AppTheme.of(context).error;
      case SystemAlertType.security:
        return Colors.orange;
      case SystemAlertType.maintenance:
        return Colors.blue;
      case SystemAlertType.update:
        return AppTheme.of(context).primary;
      case SystemAlertType.info:
        return AppTheme.of(context).secondary;
    }
  }

  /// 알림 타입에 따른 배경 색상 반환
  Color _getAlertBackgroundColor(
      BuildContext context, SystemAlertType alertType) {
    switch (alertType) {
      case SystemAlertType.critical:
        return AppTheme.of(context).error.withValues(alpha: 0.1);
      case SystemAlertType.security:
        return Colors.orange.withValues(alpha: 0.1);
      case SystemAlertType.maintenance:
        return Colors.blue.withValues(alpha: 0.1);
      case SystemAlertType.update:
        return AppTheme.of(context).primary.withValues(alpha: 0.1);
      case SystemAlertType.info:
        return AppTheme.of(context).accent1.withValues(alpha: 0.1);
    }
  }
}
