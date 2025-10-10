import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/presentation/providers/popular_posts_provider.dart';
import '/core/design_system/design_system.dart';
import 'package:get_it/get_it.dart';

class PopularPostsPage extends StatefulWidget {
  const PopularPostsPage({super.key});

  static String routeName = 'popularPosts';
  static String routePath = '/popular';

  @override
  State<PopularPostsPage> createState() => _PopularPostsPageState();
}

class _PopularPostsPageState extends State<PopularPostsPage> {
  late final PopularPostsProvider _provider;

  @override
  void initState() {
    super.initState();

    // Get provider from DI
    _provider = GetIt.instance<PopularPostsProvider>();

    // Load popular posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadPopularPosts();
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
            '인기 게시물',
            style: VersusTextStyles.headingSmall,
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Consumer<PopularPostsProvider>(
            builder: (context, provider, child) {
              // 로딩 상태
              if (provider.loadingState == PopularLoadingState.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VersusColors.primary,
                    ),
                  ),
                );
              }

              // 에러 상태
              if (provider.loadingState == PopularLoadingState.error) {
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
              if (provider.loadingState == PopularLoadingState.empty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.stars,
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

              final posts = provider.posts;

              // 게시물 목록
              return RefreshIndicator(
                onRefresh: () => provider.refresh(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: VersusSpacing.sm),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return _buildPopularCard(context, post, index);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCard(BuildContext context, PostDisplay post, int index) {
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
                      radius: 20,
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
                    // 순위 뱃지
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRankColor(index).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRankColor(index).withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: VersusTextStyles.labelMedium.copyWith(
                          color: _getRankColor(index),
                          fontWeight: FontWeight.bold,
                        ),
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

  Color _getRankColor(int index) {
    if (index == 0) return Color(0xFFFFD700); // Gold
    if (index == 1) return Color(0xFFC0C0C0); // Silver
    if (index == 2) return Color(0xFFCD7F32); // Bronze
    return VersusColors.primary;
  }
}
