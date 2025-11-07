import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/profile/domain/entities/user_post_item.dart';
import '/core/design_system/design_system.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';
import '/features/profile/presentation/providers/profile_notifiers.dart';

/// 사용자 게시물 전체 목록 화면 (Riverpod)
///
/// **Clean Architecture v4.0 + Riverpod 2.x**:
/// - ✅ ConsumerWidget으로 전환
/// - ✅ StreamProvider.autoDispose.family 사용
/// - ✅ AsyncValue.when() 패턴
/// - ✅ 실시간 동기화 (Firestore Stream)
/// - ✅ 자동 dispose 및 keepAlive
///
/// **Phase 3 Riverpod Migration**: ChangeNotifier → Riverpod 완료
class UserPostsListScreen extends ConsumerWidget {
  const UserPostsListScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'user_posts_list';
  static String routePath = '/user/posts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userPostsStreamProvider 구독 (실시간 동기화)
    final postsState = ref.watch(userPostsStreamProvider(userId));

    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '내 게시물',
          style: VersusTextStyles.headingSmall.copyWith(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: postsState.when(
        // Loading state
        loading: () => const ProfileLoadingIndicator(
          size: LoadingSize.medium,
        ),

        // Error state
        error: (error, stackTrace) => ProfileErrorMessage(
          message: error.toString(),
          onRetry: () {
            // Provider 새로고침으로 재시도
            ref.invalidate(userPostsStreamProvider(userId));
          },
        ),

        // Data state (성공)
        data: (posts) {
          // Empty state
          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.post_add,
                    size: 64,
                    color: VersusColors.textSecondary,
                  ),
                  VersusSpacing.gapMD,
                  Text(
                    '아직 작성한 게시물이 없습니다',
                    style: VersusTextStyles.bodyMedium.copyWith(
                      color: VersusColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Posts list with RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async {
              // Provider 새로고침
              ref.invalidate(userPostsStreamProvider(userId));
            },
            child: ListView.separated(
              padding: VersusSpacing.paddingMD,
              itemCount: posts.length,
              separatorBuilder: (context, index) => VersusSpacing.gapSM,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _buildPostItem(context, post);
              },
            ),
          );
        },
      ),
    );
  }

  /// 게시물 아이템 빌더
  Widget _buildPostItem(BuildContext context, UserPostItem post) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'postDetail',
          pathParameters: {'postId': post.id},
        );
      },
      child: Container(
        padding: VersusSpacing.paddingMD,
        decoration: BoxDecoration(
          color: VersusColors.backgroundSecondary,
          borderRadius: VersusRadius.radiusSmall,
          border: Border.all(
            color: VersusColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question title
            Text(
              post.questionTitle,
              style: VersusTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            VersusSpacing.gapSM,

            // Stats row
            Row(
              children: [
                const Icon(
                  Icons.how_to_vote,
                  size: 14,
                  color: VersusColors.textSecondary,
                ),
                VersusSpacing.gapH(4),
                Text(
                  '${post.totalVotes}명',
                  style: VersusTextStyles.bodySmall.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
                VersusSpacing.gapH(VersusSpacing.sm),
                const Icon(
                  Icons.comment,
                  size: 14,
                  color: VersusColors.textSecondary,
                ),
                VersusSpacing.gapH(4),
                Text(
                  '${post.commentCount}',
                  style: VersusTextStyles.bodySmall.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  dateTimeFormat('relative', post.createdAt),
                  style: VersusTextStyles.bodySmall.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
