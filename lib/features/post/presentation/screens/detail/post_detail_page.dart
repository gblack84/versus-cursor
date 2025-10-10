import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/presentation/providers/post_detail_provider.dart';
import '/core/design_system/design_system.dart';
import 'package:get_it/get_it.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({
    super.key,
    required this.postId,
  });

  static String routeName = 'postDetail';
  static String routePath = '/post/:postId';

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late final PostDetailProvider _provider;

  @override
  void initState() {
    super.initState();

    // Get provider from DI
    _provider = GetIt.instance<PostDetailProvider>();

    // Load post
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadPost(widget.postId);
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
            '게시물 상세',
            style: VersusTextStyles.headingSmall,
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Consumer<PostDetailProvider>(
            builder: (context, provider, child) {
              // 로딩 상태
              if (provider.loadingState == PostDetailLoadingState.loading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VersusColors.primary,
                    ),
                  ),
                );
              }

              // 에러 상태
              if (provider.loadingState == PostDetailLoadingState.error) {
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
                        onPressed: () => provider.loadPost(widget.postId),
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
              if (provider.loadingState == PostDetailLoadingState.notFound) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: VersusColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        '게시물을 찾을 수 없습니다',
                        style: VersusTextStyles.bodyMedium.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VersusColors.primary,
                        ),
                        child: Text('돌아가기'),
                      ),
                    ],
                  ),
                );
              }

              // 게시물 로드됨
              final post = provider.post;
              if (post == null) {
                return SizedBox.shrink();
              }

              return RefreshIndicator(
                onRefresh: () => provider.refresh(widget.postId),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPostHeader(post),
                      SizedBox(height: VersusSpacing.md),
                      _buildPostContent(post),
                      SizedBox(height: VersusSpacing.md),
                      _buildPostMetrics(post),
                      SizedBox(height: VersusSpacing.xl),
                      // TODO: 댓글 섹션 추가
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(PostDisplay post) {
    return Container(
      padding: EdgeInsets.all(VersusSpacing.md),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: post.photoUrl.isNotEmpty
                ? NetworkImage(post.photoUrl)
                : null,
            child: post.photoUrl.isEmpty
                ? Icon(Icons.person, color: VersusColors.textSecondary)
                : null,
          ),
          SizedBox(width: VersusSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.displayName,
                  style: VersusTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatDate(post.createdAt),
                  style: VersusTextStyles.labelSmall.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(PostDisplay post) {
    return Container(
      padding: EdgeInsets.all(VersusSpacing.md),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.questionTitle,
            style: VersusTextStyles.headingMedium,
          ),
          SizedBox(height: VersusSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildOptionBox(
                  'A',
                  post.optionAText,
                  post.optionAImages,
                ),
              ),
              SizedBox(width: VersusSpacing.sm),
              Expanded(
                child: _buildOptionBox(
                  'B',
                  post.optionBText,
                  post.optionBImages,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBox(
    String label,
    String? text,
    List<String>? images,
  ) {
    return Container(
      padding: EdgeInsets.all(VersusSpacing.md),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: VersusColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Option $label',
            style: VersusTextStyles.labelMedium.copyWith(
              color: VersusColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: VersusSpacing.sm),
          if (text != null && text.isNotEmpty) ...[
            Text(
              text,
              style: VersusTextStyles.bodyMedium,
            ),
            SizedBox(height: VersusSpacing.sm),
          ],
          if (images != null && images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                images.first,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostMetrics(PostDisplay post) {
    return Container(
      padding: EdgeInsets.all(VersusSpacing.md),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetric(Icons.favorite, post.likeCount.toString()),
          _buildMetric(Icons.comment, post.commentCount.toString()),
          _buildMetric(Icons.how_to_vote, post.totalVotes.toString()),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: VersusColors.textSecondary),
        SizedBox(width: 8),
        Text(
          value,
          style: VersusTextStyles.bodyMedium.copyWith(
            color: VersusColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
