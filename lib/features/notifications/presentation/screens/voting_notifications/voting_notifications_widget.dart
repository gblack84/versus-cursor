import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/notifications/presentation/providers/notification_providers.dart';
import '/features/notifications/domain/entities/notification.dart';
import '/core_exports.dart';

/// 투표 요청 알림 전용 화면
///
/// **Riverpod ConsumerWidget**:
/// - watchVotingNotificationsProvider: Voting 타입만 필터링된 스트림
/// - AsyncValue.when() 패턴으로 loading/error/data 상태 처리
///
/// **사용 예시**:
/// - 투표 요청 알림만 보고 싶을 때
/// - 투표 관련 액션이 필요한 알림 모아보기
class VotingNotificationsWidget extends ConsumerWidget {
  const VotingNotificationsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    // Phase C-2: FirebaseAuth 직접 접근 → currentUserIdProvider 사용
    final userId = ref.watch(currentUserIdProvider).value ?? '';

    // Voting 알림만 필터링된 Stream 구독
    final notificationicationsAsync = ref.watch(
      watchVotingNotificationsProvider(userId),
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primaryBackground,
        automaticallyImplyLeading: true,
        title: Text(
          '투표 요청',
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
                    '투표 요청을 불러올 수 없습니다',
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
                        Icons.how_to_vote_outlined,
                        size: 72.0,
                        color: AppTheme.of(context).secondaryText,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '투표 요청이 없습니다',
                        style: AppTheme.of(context).titleLarge.override(
                              color: AppTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '새로운 투표 요청이 있으면 여기에 표시됩니다',
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
                // VotingNotification 타입 체크
                final notification = notifications[index];
                if (notification is! VotingNotification) {
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

                            // 투표 화면으로 이동 (구현 예정)
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '투표 화면으로 이동: ${notification.postTitle}',
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
                          // 투표 아이콘
                          Container(
                            width: 48.0,
                            height: 48.0,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.how_to_vote,
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
                                Text(
                                  notification.postTitle,
                                  style:
                                      AppTheme.of(context).bodyLarge.override(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.0,
                                          ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8.0),
                                // 투표 정보 (A vs B 득표 수)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.thumb_up_outlined,
                                      size: 16.0,
                                      color: AppTheme.of(context).primary,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'A: ${notification.currentVotesA ?? 0}표',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color: AppTheme.of(context).primary,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                    const SizedBox(width: 16.0),
                                    Icon(
                                      Icons.thumb_down_outlined,
                                      size: 16.0,
                                      color: AppTheme.of(context).secondary,
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      'B: ${notification.currentVotesB ?? 0}표',
                                      style: AppTheme.of(context)
                                          .bodySmall
                                          .override(
                                            color:
                                                AppTheme.of(context).secondary,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ],
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
}
