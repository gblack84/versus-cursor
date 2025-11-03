import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/notifications/presentation/providers/notification_providers.dart';
import '/features/notifications/domain/entities/notification.dart';
import '/core_exports.dart';

/// 소셜 알림 전용 화면
///
/// **Riverpod ConsumerWidget**:
/// - watchSocialNotificationsProvider: Social 타입만 필터링된 스트림
/// - AsyncValue.when() 패턴으로 loading/error/data 상태 처리
///
/// **사용 예시**:
/// - 친구 요청, 좋아요, 댓글 등 소셜 알림만 보고 싶을 때
/// - 사용자 간 상호작용 알림 모아보기
class SocialNotificationsWidget extends ConsumerWidget {
  const SocialNotificationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Social 알림만 필터링된 Stream 구독
    final notificationicationsAsync = ref.watch(
      watchSocialNotificationsProvider(userId),
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        automaticallyImplyLeading: true,
        title: Text(
          '소셜 알림',
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
                    '소셜 알림을 불러올 수 없습니다',
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
                        Icons.people_outline,
                        size: 72.0,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '소셜 알림이 없습니다',
                        style: AppTheme.of(context).titleLarge.override(
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '친구 요청, 좋아요, 댓글 등의 알림이 여기에 표시됩니다',
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
                // SocialNotification 타입 체크
                final notification = notifications[index];
                if (notification is! SocialNotification) {
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

                            // 관련 포스트/프로필로 이동 (구현 예정)
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${notification.fromUserName}님의 알림',
                                  ),
                                  duration: const Duration(seconds: 2),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 프로필 이미지 또는 아이콘
                          _buildUserAvatar(context, notification),
                          const SizedBox(width: 12.0),
                          // 알림 내용
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 사용자 이름 + 액션
                                RichText(
                                  text: TextSpan(
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          letterSpacing: 0.0,
                                        ),
                                    children: [
                                      TextSpan(
                                        text: notification.fromUserName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _getActionText(notification.actionType),
                                        style: TextStyle(
                                          color: AppTheme.of(context)
                                              .secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                // 내용
                                if (notification.content.isNotEmpty)
                                  Text(
                                    notification.content,
                                    style: AppTheme.of(context)
                                        .bodySmall
                                        .override(
                                          color:
                                              AppTheme.of(context).secondaryText,
                                          letterSpacing: 0.0,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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

  /// 사용자 아바타 빌드
  Widget _buildUserAvatar(BuildContext context, SocialNotification notification) {
    if (notification.fromUserProfileUrl != null &&
        notification.fromUserProfileUrl!.isNotEmpty) {
      // 프로필 이미지가 있으면 표시
      return Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(notification.fromUserProfileUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // 프로필 이미지가 없으면 기본 아이콘
      return Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _getActionIcon(notification.actionType),
          color: Colors.white,
          size: 24.0,
        ),
      );
    }
  }

  /// 액션 타입에 따른 아이콘 반환
  IconData _getActionIcon(SocialActionType actionType) {
    switch (actionType) {
      case SocialActionType.like:
        return Icons.favorite;
      case SocialActionType.comment:
        return Icons.comment;
      case SocialActionType.friendRequest:
        return Icons.person_add;
      case SocialActionType.friendAccepted:
        return Icons.check_circle;
      case SocialActionType.follow:
        return Icons.person;
      case SocialActionType.mention:
        return Icons.alternate_email;
      case SocialActionType.share:
        return Icons.share;
    }
  }

  /// 액션 타입에 따른 텍스트 반환
  String _getActionText(SocialActionType actionType) {
    switch (actionType) {
      case SocialActionType.like:
        return '님이 좋아요를 눌렀습니다';
      case SocialActionType.comment:
        return '님이 댓글을 남겼습니다';
      case SocialActionType.friendRequest:
        return '님이 친구 요청을 보냈습니다';
      case SocialActionType.friendAccepted:
        return '님이 친구 요청을 수락했습니다';
      case SocialActionType.follow:
        return '님이 팔로우하기 시작했습니다';
      case SocialActionType.mention:
        return '님이 언급했습니다';
      case SocialActionType.share:
        return '님이 공유했습니다';
    }
  }
}
