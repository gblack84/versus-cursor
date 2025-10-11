import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/profile_provider.dart';
import '/features/auth/data/adapters/auth_util.dart';
import '/features/auth/domain/usecases/sign_out_usecase.dart';
import '/features/auth/data/repositories/auth_repository_impl.dart';
import '/features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import '/features/auth/data/datasources/auth_local_datasource.dart';
import '/core/design_system/design_system.dart';
import '/features/post/presentation/providers/user_posts_provider.dart';
import '/features/post/domain/models/post_display.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  static String routeName = 'profile_page';
  static String routePath = '/profile';

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  SignOutUseCase? _signOutUseCase;
  late final UserPostsProvider _userPostsProvider;
  late final ProfileProvider _profileProvider;

  Future<void> _initializeUseCases() async {
    // Phase 2.6에서 DI로 대체 예정
    final prefs = await SharedPreferences.getInstance();
    final localDataSource = AuthLocalDataSource(prefs: prefs);

    final repository = AuthRepositoryImpl(
      remoteDataSource: FirebaseAuthRemoteDataSource(
        firebaseAuth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
        googleSignIn: GoogleSignIn(),
      ),
      localDataSource: localDataSource,
    );

    setState(() {
      _signOutUseCase = SignOutUseCase(repository: repository);
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeUseCases();

    // Initialize providers from DI
    _userPostsProvider = GetIt.instance<UserPostsProvider>();
    _profileProvider = GetIt.instance<ProfileProvider>();

    // Load profile data
    final userId = currentUser?.uid;
    if (userId != null) {
      _profileProvider.loadProfile(userId);
    }
  }

  @override
  void dispose() {
    _userPostsProvider.dispose();
    super.dispose();
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
          '프로필',
          style: VersusTextStyles.headingSmall.copyWith(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // TODO: 설정 페이지로 이동
              context.pushNamed('user_info_input');
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: currentUser == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '로그인이 필요합니다',
                      style: VersusTextStyles.headingMedium,
                    ),
                    VersusSpacing.gapMD,
                    VersusButton.primary(
                      text: '로그인',
                      onPressed: () {
                        context.pushNamed('login_page');
                      },
                    ),
                  ],
                ),
              )
            : Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  // Loading state
                  if (provider.isLoading || provider.profile == null) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          VersusColors.primary,
                        ),
                      ),
                    );
                  }

                  // Error state
                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.errorMessage!,
                            style: VersusTextStyles.bodyMedium.copyWith(
                              color: VersusColors.error,
                            ),
                          ),
                          VersusSpacing.gapMD,
                          VersusButton.primary(
                            text: '다시 시도',
                            onPressed: () {
                              final userId = currentUser?.uid;
                              if (userId != null) {
                                provider.loadProfile(userId);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  final user = provider.profile!;

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
                                backgroundImage: user.photoUrl.isNotEmpty
                                    ? NetworkImage(user.photoUrl)
                                    : null,
                                child: user.photoUrl.isEmpty
                                    ? Icon(Icons.person,
                                        color: VersusColors.primary, size: 50)
                                    : null,
                              ),
                              VersusSpacing.gapMD,

                              // 이름
                              Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildPointInfo(
                                    context,
                                    '답변 포인트',
                                    user.pointsA.toString(),
                                    VersusColors.primary,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 40,
                                    color: VersusColors.borderLight,
                                  ),
                                  _buildPointInfo(
                                    context,
                                    '질문 포인트',
                                    user.pointsQ.toString(),
                                    VersusColors.secondary,
                                  ),
                                ],
                              ),
                            ],
                          ),
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
                              if (user.gender.isNotEmpty)
                                _buildInfoRow(context, '성별', user.gender),

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

                        // 내 게시물 섹션
                        ChangeNotifierProvider.value(
                          value: _userPostsProvider,
                          child: _buildUserPostsSection(context, user.uid),
                        ),
                        VersusSpacing.gapLG,

                        // 로그아웃 버튼
                        VersusButton.error(
                          text: '로그아웃',
                          isFullWidth: true,
                          size: VersusButtonSize.large,
                          onPressed: () async {
                            // UseCase가 초기화되지 않았으면 대기
                            if (_signOutUseCase == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('초기화 중입니다. 잠시만 기다려주세요.'),
                                ),
                              );
                              return;
                            }

                            final success = await _signOutUseCase!.execute();
                            if (success) {
                              context.goNamed('startPage');
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPointInfo(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: VersusTextStyles.headingLarge.copyWith(
            color: color,
          ),
        ),
        VersusSpacing.gapXS,
        Text(
          label,
          style: VersusTextStyles.bodySmall.copyWith(
            color: VersusColors.textSecondary,
          ),
        ),
      ],
    );
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
    return Consumer<UserPostsProvider>(
      builder: (context, provider, child) {
        // Load posts on first build
        if (provider.loadingState == UserPostsLoadingState.initial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.loadUserPosts(userId: userId, limit: 5);
          });
        }

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
                  if (provider.hasPosts)
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to full posts list
                      },
                      child: Text(
                        '전체보기',
                        style: VersusTextStyles.bodySmall.copyWith(
                          color: VersusColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              VersusSpacing.gapMD,

              // Loading state
              if (provider.loadingState == UserPostsLoadingState.loading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(VersusSpacing.lg),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        VersusColors.primary,
                      ),
                    ),
                  ),
                ),

              // Error state
              if (provider.loadingState == UserPostsLoadingState.error)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(VersusSpacing.md),
                    child: Text(
                      provider.errorMessage ?? '오류가 발생했습니다',
                      style: VersusTextStyles.bodyMedium.copyWith(
                        color: VersusColors.error,
                      ),
                    ),
                  ),
                ),

              // Empty state
              if (provider.loadingState == UserPostsLoadingState.empty)
                Center(
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
                ),

              // Loaded state
              if (provider.hasPosts)
                ...provider.posts.map((post) => _buildPostItem(context, post)),
            ],
          ),
        );
      },
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
