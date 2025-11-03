import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/domain/failures/post_failure.dart';
import '/features/post/presentation/providers/post_providers.dart';
import '/features/post/presentation/providers/post_params.dart';
import '/core/design_system/design_system.dart';
import '/core/constants/app_constants.dart';
import '/core_exports.dart';

/// Popular Posts Page - Riverpod 2.x Migration
///
/// **Phase 2: ConsumerWidget Pattern**
/// - Uses popularPostsStreamProvider for real-time updates
/// - AsyncValue.when() for automatic state handling
/// - No manual dispose needed
class PopularPostsPage extends ConsumerWidget {
  const PopularPostsPage({super.key});

  static String routeName = 'popularPosts';
  static String routePath = '/popular';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch popular posts stream with default params
    final postsAsync = ref.watch(
      popularPostsStreamProvider(
        const PopularPostsParams(limit: 20, timeWindow: Duration(days: 7)),
      ),
    );

    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: VersusColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '인기 게시물',
          style: VersusTextStyles.headingSmall,
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: postsAsync.when(
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
                      ref.invalidate(popularPostsStreamProvider(const PopularPostsParams(limit: 20, timeWindow: Duration(days: 7))));
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
                      Icons.star,
                      size: 64,
                      color: VersusColors.textSecondary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '인기 게시물이 없습니다',
                      style: VersusTextStyles.headingMedium.copyWith(
                        color: VersusColors.textSecondary,
                      ),
                    ),
                    VersusSpacing.gapSM,
                    Text(
                      '새로운 게시물을 작성해보세요!',
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
                ref.invalidate(popularPostsStreamProvider(const PopularPostsParams(limit: 20, timeWindow: Duration(days: 7))));
              },
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: VersusSpacing.sm),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPopularCard(context, post);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopularCard(BuildContext context, PostDisplay post) {
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
                    CircleAvatar(
                      radius: AppConstants.profileAvatarRadius,
                      backgroundColor: VersusColors.primaryWithAlpha(0.2),
                      backgroundImage: post.photoUrl.isNotEmpty
                          ? NetworkImage(post.photoUrl)
                          : null,
                      child: post.photoUrl.isEmpty
                          ? Icon(Icons.person,
                              color: VersusColors.primary, size: 20)
                          : null,
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
                    // 인기 뱃지
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: VersusColors.info.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: VersusColors.info,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'POPULAR',
                            style: VersusTextStyles.labelSmall.copyWith(
                              color: VersusColors.info,
                              fontWeight: FontWeight.bold,
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
