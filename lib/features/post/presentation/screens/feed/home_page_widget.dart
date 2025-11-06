import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/notifications/presentation/providers/notification_badge_provider.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/domain/failures/post_failure.dart';
import '/features/post/presentation/providers/post_providers.dart';
import '/features/post/presentation/providers/post_params.dart';
import '/features/post/domain/usecases/get_feed_usecase.dart';
import '/core/design_system/design_system.dart';
import '/services/cache/unified_cache_service.dart';

// TODO: Phase 5 - Move ProfileAvatar to core/design_system/widgets/ after all features complete
// Currently depends on Profile Feature widget for displaying user avatars
import '/features/profile/presentation/widgets/profile/profile_avatar.dart';

/// Home Page Widget - Riverpod 2.x Migration
///
/// **Phase 2: ConsumerWidget Pattern**
/// - Uses feedStreamProvider for real-time feed updates
/// - AsyncValue.when() for automatic state handling
/// - No manual dispose needed
/// - Removed FeedProvider dependency
class HomePageWidget extends ConsumerStatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'homePage';
  static String routePath = '/home';

  @override
  ConsumerState<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends ConsumerState<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // 백그라운드에서 인기 게시물 프리로드
    Future.microtask(() async {
      try {
        await UnifiedCacheService.instance.preloadPopularPosts();
        debugPrint('[HomePage] Popular posts preloaded successfully');
      } catch (e) {
        debugPrint('[HomePage] Failed to preload popular posts: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch feed stream with default params
    final feedAsync = ref.watch(
      feedStreamProvider(
        const FeedParams(limit: 20, sortBy: FeedSortBy.latest),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Versus Space',
          style: VersusTextStyles.headingSmall,
        ),
        actions: [
          NotificationAppBarAction(
            onPressed: () {
              context.pushNamed('notificationsList');
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: feedAsync.when(
          // Loading state
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                VersusColors.primary,
              ),
            ),
          ),

          // Error state
          error: (error, stack) {
            String errorMessage = '오류가 발생했습니다';

            if (error is PostFailure) {
              errorMessage = error.when(
                networkError: () => '네트워크 연결을 확인해주세요.',
                serverError: (message) => '서버 오류: ${message ?? "알 수 없는 오류"}',
                timeout: () => '요청 시간이 초과되었습니다.',
                insufficientPermissions: () => '권한이 없습니다.',
                unauthorized: () => '로그인이 필요합니다.',
                postNotFound: (postId) => '게시물을 찾을 수 없습니다.',
                userNotFound: (userId) => '사용자를 찾을 수 없습니다.',
                invalidInput: (field) => '$field 값이 올바르지 않습니다.',
                contentTooLong: (maxLength) => '내용이 너무 깁니다.',
                createFailed: (reason) => '생성 실패',
                updateFailed: (reason) => '업데이트 실패',
                deleteFailed: (reason) => '삭제 실패',
                metricsOperationFailed: (operation, reason) => '통계 작업 실패',
                searchFailed: (query) => '검색 실패',
                queryFailed: (reason) => '조회 실패: ${reason ?? "알 수 없는 오류"}',
                unexpected: (message, err, stackTrace) =>
                    message ?? '예상치 못한 오류가 발생했습니다.',
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: VersusColors.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    errorMessage,
                    style: VersusTextStyles.bodyMedium.copyWith(
                      color: VersusColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(feedStreamProvider(const FeedParams(limit: 20, sortBy: FeedSortBy.latest)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VersusColors.primary,
                    ),
                    child: Text('다시 시도'),
                  ),
                ],
              ),
            );
          },

          // Data state
          data: (posts) {
            if (posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.post_add,
                      size: 64,
                      color: VersusColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '아직 게시물이 없습니다',
                      style: VersusTextStyles.headingMedium.copyWith(
                        color: VersusColors.textSecondary,
                      ),
                    ),
                    VersusSpacing.gapSM,
                    Text(
                      '첫 번째 질문을 작성해보세요!',
                      style: VersusTextStyles.bodyMedium.copyWith(
                        color: VersusColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 게시물 목록
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(feedStreamProvider(const FeedParams(limit: 20, sortBy: FeedSortBy.latest)));
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: VersusSpacing.sm),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildVersusCard(context, post);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVersusCard(BuildContext context, PostDisplay post) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: VersusSpacing.md, vertical: VersusSpacing.sm),
      child: InkWell(
        onTap: () {
          // 게시물 상세 페이지로 이동
          context.pushNamed(
            'postDetail',
            pathParameters: {'postId': post.id},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: VersusColors.backgroundSecondary,
            borderRadius: VersusRadius.card,
            boxShadow: [
              BoxShadow(
                color: VersusColors.blackWithAlpha(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: VersusSpacing.paddingMD,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보
                Row(
                  children: [
                    ProfileAvatar(
                      photoUrl: post.photoUrl,
                      size: AvatarSize.medium,
                    ),
                    VersusSpacing.gapH(VersusSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.displayName.isNotEmpty
                                ? post.displayName
                                : '익명',
                            style: VersusTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dateTimeFormat('relative', post.createdAtDateTime),
                            style: VersusTextStyles.bodySmall.copyWith(
                              color: VersusColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                VersusSpacing.gapMD,

                // 질문 제목
                Text(
                  post.questionTitle,
                  style: VersusTextStyles.headingMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                VersusSpacing.gapMD,

                // A vs B 옵션
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: VersusColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: VersusColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'A',
                              style: VersusTextStyles.labelLarge.copyWith(
                                color: VersusColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              post.optionAText ?? 'Option A',
                              style: VersusTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'VS',
                        style: VersusTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: VersusColors.textSecondary,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: VersusColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                VersusColors.secondary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'B',
                              style: VersusTextStyles.labelLarge.copyWith(
                                color: VersusColors.secondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.0,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              post.optionBText ?? 'Option B',
                              style: VersusTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                VersusSpacing.gapMD,

                // 상호작용 정보
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.how_to_vote,
                          size: 16,
                          color: VersusColors.textSecondary,
                        ),
                        VersusSpacing.gapH(VersusSpacing.xs),
                        Text(
                          '${post.totalVotes}명 참여',
                          style: VersusTextStyles.bodySmall.copyWith(
                            color: VersusColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.comment,
                          size: 16,
                          color: VersusColors.textSecondary,
                        ),
                        VersusSpacing.gapH(VersusSpacing.xs),
                        Text(
                          '${post.commentCount}',
                          style: VersusTextStyles.bodySmall.copyWith(
                            color: VersusColors.textSecondary,
                          ),
                        ),
                        VersusSpacing.gapH(VersusSpacing.md),
                        Icon(
                          Icons.favorite_border,
                          size: 16,
                          color: VersusColors.textSecondary,
                        ),
                        VersusSpacing.gapH(VersusSpacing.xs),
                        Text(
                          '${post.likeCount}',
                          style: VersusTextStyles.bodySmall.copyWith(
                            color: VersusColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
