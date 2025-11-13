import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // TODO Phase C-3: Auth Feature의 SignOutUseCase 사용
import '/features/auth/presentation/providers/auth_providers.dart';
import '/core_exports.dart';
// Phase 3: Riverpod 3.x - profile_notifiers.dart (Freezed + Code Generation)
import '/features/profile/presentation/providers/profile_notifiers.dart';
// Phase 3: Riverpod - profile_post_providers.dart (Feature-First)
import '/features/profile/presentation/providers/profile_post_providers.dart';
import '/core/design_system/design_system.dart';
import '/features/profile/domain/entities/user_post_item.dart';
import '/features/profile/presentation/screens/settings/settings_screen.dart';
import '/features/profile/presentation/screens/user_posts_list/user_posts_list_screen.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';
import '/features/profile/presentation/widgets/profile/profile_stats_card.dart';
import '/features/profile/presentation/widgets/profile/profile_completion_card.dart';

/// 프로필 메인 페이지 (Riverpod)
///
/// **Architecture**: Clean Architecture v4.0 + Riverpod
/// - ✅ ConsumerStatefulWidget으로 전환
/// - ✅ profileStreamProvider로 실시간 프로필 동기화
/// - ✅ profileUserPostsStreamProvider (Feature-First)
class ProfilePageWidget extends ConsumerStatefulWidget {
  const ProfilePageWidget({super.key});

  static String routeName = 'profile_page';
  static String routePath = '/profile';

  @override
  ConsumerState<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends ConsumerState<ProfilePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Contract 패턴 폐기 (2025-11-09): FirebaseAuth 직접 사용
  // Phase 3: Riverpod - ProfileProvider 제거
  // 프로필 로드는 profileStreamProvider가 자동 처리

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          '프로필',
          style: VersusTextStyles.headingSmall.copyWith(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Phase C-2: currentUserIdProvider 사용
              final userId = ref.read(currentUserIdProvider).value;
              if (userId != null) {
                context.pushNamed(
                  SettingsScreen.routeName,
                  pathParameters: {'userId': userId},
                );
              }
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        // Phase 3: Riverpod - profileStreamProvider 사용
        child: Builder(
          builder: (context) {
            // Phase C-2: currentUserIdProvider 사용
            final userId = ref.watch(currentUserIdProvider).value;

            if (userId == null) {
              return ProfileErrorMessage(
                message: '로그인이 필요합니다',
                onRetry: () {},
              );
            }

            // Riverpod 3.x: profileStreamProvider로 실시간 프로필 조회 (direct parameter)
            final profileState = ref.watch(profileStreamProvider(userId));

            return profileState.when(
              // Loading state
              loading: () => ProfileLoadingIndicator(
                size: LoadingSize.medium,
              ),
              // Error state
              error: (error, stackTrace) => ProfileErrorMessage(
                message: error.toString(),
                onRetry: () => ref.invalidate(profileStreamProvider(userId)),
              ),
              // Data state
              data: (user) {
                if (user == null) {
                  return ProfileErrorMessage(
                    message: '프로필을 찾을 수 없습니다',
                    onRetry: () => ref.invalidate(profileStreamProvider(userId)),
                  );
                }

                  return SingleChildScrollView(
                    padding: VersusSpacing.paddingMD,
                    child: Column(
                      children: [
                        // 프로필 헤더
                        Container(
                          padding: VersusSpacing.paddingLG,
                          decoration: BoxDecoration(
                            color: VersusColors.backgroundSecondary,
                            borderRadius: VersusRadius.radiusMedium,
                            boxShadow: [
                              BoxShadow(
                                color: VersusColors.blackWithAlpha(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // 프로필 이미지
                              CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    VersusColors.primaryWithAlpha(0.2),
                                backgroundImage: user.photoUrl?.isNotEmpty == true
                                    ? NetworkImage(user.photoUrl!)
                                    : null,
                                child: user.photoUrl?.isEmpty ?? true
                                    ? Icon(Icons.person,
                                        color: VersusColors.primary, size: 50)
                                    : null,
                              ),
                              VersusSpacing.gapMD,

                              // 이름
                              Text(
                                user.displayName?.isNotEmpty == true
                                    ? user.displayName!
                                    : '이름 없음',
                                style: VersusTextStyles.headingSmall,
                              ),
                              VersusSpacing.gapXS,

                              // 이메일
                              Text(
                                user.email,
                                style: VersusTextStyles.bodyMedium.copyWith(
                                  color: VersusColors.textSecondary,
                                ),
                              ),
                              VersusSpacing.gapMD,

                              // 포인트 정보
                              ProfilePointsCard(
                                pointsA: user.pointsA,
                                pointsQ: user.pointsQ,
                              ),
                            ],
                          ),
                        ),
                        VersusSpacing.gapLG,

                        // Phase 6: 프로필 완성도 카드
                        ProfileCompletionCard(
                          userId: user.uid,
                          onCompletePressed: () {
                            // TODO: 프로필 편집 페이지로 이동
                            // context.pushNamed(ProfileEditScreen.routeName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('프로필 편집 기능은 곧 추가될 예정입니다'),
                                backgroundColor: VersusColors.info,
                              ),
                            );
                          },
                        ),
                        VersusSpacing.gapLG,

                        // 프로필 정보
                        Container(
                          padding: VersusSpacing.paddingLG,
                          decoration: BoxDecoration(
                            color: VersusColors.backgroundSecondary,
                            borderRadius: VersusRadius.radiusMedium,
                            boxShadow: [
                              BoxShadow(
                                color: VersusColors.blackWithAlpha(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '프로필 정보',
                                style: VersusTextStyles.headingMedium,
                              ),
                              VersusSpacing.gapMD,

                              // 성별
                              if (user.gender?.isNotEmpty == true)
                                _buildInfoRow(context, '성별', user.gender!),

                              // 가입일
                              if (user.createdTime != null)
                                _buildInfoRow(
                                  context,
                                  '가입일',
                                  dateTimeFormat('yMMMd', user.createdTime),
                                ),

                              // 전문분야
                              if (user.expertise.isNotEmpty)
                                _buildInfoRow(
                                  context,
                                  '전문분야',
                                  user.expertise.join(', '),
                                ),

                              // 관심사
                              if (user.interests.isNotEmpty)
                                _buildInfoRow(
                                  context,
                                  '관심사',
                                  user.interests.join(', '),
                                ),
                            ],
                          ),
                        ),
                        VersusSpacing.gapLG,

                        // 내 게시물 섹션 (Riverpod)
                        _buildUserPostsSection(context, user.uid),
                        VersusSpacing.gapLG,

                        // 로그아웃 버튼
                        VersusButton.error(
                          text: '로그아웃',
                          isFullWidth: true,
                          size: VersusButtonSize.large,
                          onPressed: () async {
                            // Contract 패턴 폐기 (2025-11-09): FirebaseAuth 직접 사용
                            try {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                context.goNamed('startPage');
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('로그아웃 중 오류가 발생했습니다: $e'),
                                    backgroundColor: VersusColors.error,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },  // profileState.when data 닫기
              );    // profileState.when 닫기
            },      // Builder 닫기
          ),        // Builder widget 닫기
      ),            // SafeArea 닫기
    );              // Scaffold 닫기
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: VersusSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: VersusTextStyles.bodyMedium.copyWith(
                color: VersusColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: VersusTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPostsSection(BuildContext context, String userId) {
    // Phase 3: Riverpod - profileUserPostsStreamProvider 사용
    final postsAsync = ref.watch(profileUserPostsStreamProvider(userId, limit: 5));

    return Container(
      padding: VersusSpacing.paddingLG,
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: VersusRadius.radiusMedium,
        boxShadow: [
          BoxShadow(
            color: VersusColors.blackWithAlpha(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내 게시물',
                style: VersusTextStyles.headingMedium,
              ),
              postsAsync.when(
                data: (posts) => posts.isNotEmpty
                    ? TextButton(
                        onPressed: () {
                          context.pushNamed(
                            UserPostsListScreen.routeName,
                            pathParameters: {'userId': userId},
                          );
                        },
                        child: Text(
                          '전체보기',
                          style: VersusTextStyles.bodySmall.copyWith(
                            color: VersusColors.primary,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                loading: () => SizedBox.shrink(),
                error: (_, __) => SizedBox.shrink(),
              ),
            ],
          ),
          VersusSpacing.gapMD,

          // Riverpod AsyncValue.when()으로 상태 처리
          postsAsync.when(
            // Loading state
            loading: () => Padding(
              padding: EdgeInsets.all(VersusSpacing.lg),
              child: ProfileLoadingIndicator(
                size: LoadingSize.small,
              ),
            ),

            // Error state
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: EdgeInsets.all(VersusSpacing.md),
                child: Text(
                  error.toString(),
                  style: VersusTextStyles.bodyMedium.copyWith(
                    color: VersusColors.error,
                  ),
                ),
              ),
            ),

            // Data state
            data: (posts) {
              // Empty state
              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(VersusSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.post_add,
                          size: 48,
                          color: VersusColors.textSecondary,
                        ),
                        VersusSpacing.gapSM,
                        Text(
                          '아직 작성한 게시물이 없습니다',
                          style: VersusTextStyles.bodyMedium.copyWith(
                            color: VersusColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Loaded state
              return Column(
                children: posts.map((post) => _buildPostItem(context, post)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, UserPostItem post) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'postDetail',
          pathParameters: {'postId': post.id},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: VersusSpacing.sm),
        padding: VersusSpacing.paddingMD,
        decoration: BoxDecoration(
          color: VersusColors.backgroundPrimary,
          borderRadius: VersusRadius.radiusSmall,
          border: Border.all(
            color: VersusColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.questionTitle,
              style: VersusTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            VersusSpacing.gapSM,
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
