import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/app/di.dart';
import '/features/post/presentation/providers/user_posts_provider.dart';
import '/features/post/domain/usecases/get_user_posts_usecase.dart';
import '/features/post/domain/models/post_display.dart';
import '/core/design_system/design_system.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';

/// 사용자 게시물 전체 목록 화면
///
/// **Clean Architecture v4.0 준수**:
/// - Provider 패턴으로 상태 관리
/// - UseCase 통해 비즈니스 로직 처리
/// - UI와 비즈니스 로직 완전 분리
/// - GetIt을 통한 의존성 주입
class UserPostsListScreen extends StatelessWidget {
  const UserPostsListScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'user_posts_list';
  static String routePath = '/user/posts';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserPostsProvider(
        getUserPostsUseCase: getIt<GetUserPostsUseCase>(),
      ),
      child: _UserPostsListContent(userId: userId),
    );
  }
}

/// 게시물 목록 화면 내용
class _UserPostsListContent extends StatefulWidget {
  const _UserPostsListContent({
    required this.userId,
  });

  final String userId;

  @override
  State<_UserPostsListContent> createState() => _UserPostsListContentState();
}

class _UserPostsListContentState extends State<_UserPostsListContent> {
  @override
  void initState() {
    super.initState();

    // Provider에서 게시물 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserPostsProvider>();
      provider.loadUserPosts(userId: widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
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
      body: Consumer<UserPostsProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.loadingState == UserPostsLoadingState.loading ||
              provider.loadingState == UserPostsLoadingState.initial) {
            return ProfileLoadingIndicator(
              size: LoadingSize.medium,
            );
          }

          // Error state
          if (provider.loadingState == UserPostsLoadingState.error) {
            return ProfileErrorMessage(
              message: provider.errorMessage ?? '오류가 발생했습니다',
              onRetry: () => provider.loadUserPosts(userId: widget.userId),
            );
          }

          // Empty state
          if (provider.loadingState == UserPostsLoadingState.empty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
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

          // Loaded state - Posts list
          return RefreshIndicator(
            onRefresh: () async {
              await provider.refresh(userId: widget.userId);
            },
            child: ListView.separated(
              padding: VersusSpacing.paddingMD,
              itemCount: provider.posts.length,
              separatorBuilder: (context, index) => VersusSpacing.gapSM,
              itemBuilder: (context, index) {
                final post = provider.posts[index];
                return _buildPostItem(context, post);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, PostDisplay post) {
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
                Icon(
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
                Icon(
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
                Spacer(),
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
