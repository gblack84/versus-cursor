import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/presentation/providers/trending_posts_provider.dart';
import '/core/design_system/design_system.dart';
import 'package:get_it/get_it.dart';
import '/core/constants/app_constants.dart';

class TrendingPostsPage extends StatefulWidget {
  const TrendingPostsPage({super.key});

  static String routeName = 'trendingPosts';
  static String routePath = '/trending';

  @override
  State<TrendingPostsPage> createState() => _TrendingPostsPageState();
}

class _TrendingPostsPageState extends State<TrendingPostsPage> {
  late final TrendingPostsProvider _provider;

  @override
  void initState() {
    super.initState();

    // Get provider from DI
    _provider = GetIt.instance<TrendingPostsProvider>();

    // Load trending posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadTrendingPosts();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: VersusColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: VersusColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '트렌딩 게시물',
            style: VersusTextStyles.headingSmall,
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Consumer<TrendingPostsProvider>(
            builder: (context, provider, child) {
              // 로딩 상태
              if (provider.loadingState == TrendingLoadingState.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VersusColors.primary,
                    ),
                  ),
                );
              }

              // 에러 상태
              if (provider.loadingState == TrendingLoadingState.error) {
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
                        provider.errorMessage ?? '오류가 발생했습니다',
                        style: VersusTextStyles.bodyMedium.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.refresh(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VersusColors.primary,
                        ),
                        child: Text('다시 시도'),
                      ),
                    ],
                  ),
                );
              }

              // 게시물 없음 상태
              if (provider.loadingState == TrendingLoadingState.empty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 64,
                        color: VersusColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '트렌딩 게시물이 없습니다',
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

              final posts = provider.posts;

              // 게시물 목록
              return RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: VersusSpacing.sm),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildTrendingCard(context, post);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, PostDisplay post) {
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
                            dateTimeFormat('relative', post.createdAt),
                            style: VersusTextStyles.bodySmall.copyWith(
                              color: VersusColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 트렌딩 뱃지
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: VersusColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 14,
                            color: VersusColors.warning,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'HOT',
                            style: VersusTextStyles.labelSmall.copyWith(
                              color: VersusColors.warning,
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
