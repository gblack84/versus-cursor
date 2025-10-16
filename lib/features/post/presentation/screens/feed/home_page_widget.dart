import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/notifications/presentation/providers/notification_badge_provider.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/presentation/providers/feed_provider.dart';
import '/core/design_system/design_system.dart';
import '/services/cache/unified_cache_service.dart';
import '/features/profile/presentation/widgets/profile/profile_avatar.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  static String routeName = 'homePage';
  static String routePath = '/home';

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // FeedProvider 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FeedProvider>();
      provider.initializeFeed();
    });

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
        child: Consumer<FeedProvider>(
          builder: (context, provider, child) {
            // 로딩 상태
            if (provider.loadingState == FeedLoadingState.loading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    VersusColors.primary,
                  ),
                ),
              );
            }

            // 에러 상태
            if (provider.loadingState == FeedLoadingState.error) {
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
                      child: Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }

            final posts = provider.posts;

            // 게시물이 없을 때
            if (provider.loadingState == FeedLoadingState.empty || posts.isEmpty) {
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
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: VersusSpacing.sm),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return _buildVersusCard(context, post);
              },
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
                            dateTimeFormat('relative', post.createdAt),
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
