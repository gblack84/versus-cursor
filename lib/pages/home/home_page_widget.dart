import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/components/notifications/notification_badge_provider.dart';
import '/backend/backend.dart';
import '/design_system/design_system.dart';
import '/services/cache/unified_cache_service.dart';

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
        child: StreamBuilder<List<PostsModel>>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .limit(20)
              .snapshots()
              .map((snapshot) => 
                  snapshot.docs.map((doc) => PostsModel.fromSnapshot(doc)).toList()),
          builder: (context, snapshot) {
            // 로딩 상태
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    VersusColors.primary,
                  ),
                ),
              );
            }

            final posts = snapshot.data!;

            // 게시물이 없을 때
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

  Widget _buildVersusCard(BuildContext context, PostsModel post) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: VersusSpacing.md, 
        vertical: VersusSpacing.sm
      ),
      child: InkWell(
        onTap: () {
          // TODO: 게시물 상세 페이지로 이동
          print('Post clicked: ${post.questionTitle}');
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
                          ? Icon(Icons.person, color: VersusColors.primary, size: 20)
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
                              (post.optionA['title'] as String?) ?? 'Option A',
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
                            color: VersusColors.secondary.withValues(alpha: 0.3),
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
                              (post.optionB['title'] as String?) ?? 'Option B',
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
                          '${post.participantcount}명 참여',
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
                          '${post.commentcount}',
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
                          '${post.likecount}',
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