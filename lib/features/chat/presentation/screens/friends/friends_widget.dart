import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:bot_toast/bot_toast.dart';
import '/app/contracts/auth_contract.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/core/design_system/design_system.dart';
import '/core/utils/error_handler.dart';
import '../../providers/friends_provider.dart';

/// Friends Screen Widget (Clean Architecture v4.0)
///
/// **Features**:
/// - Friend recommendations (by totalAPoints ranking)
/// - Friend search (by displayName)
/// - Follow/Unfollow toggle
/// - Friend request (준비 중)
///
/// **Provider Integration**:
/// - FriendsProvider for state management
/// - 4 UseCases for business logic
class FriendsWidget extends StatefulWidget {
  const FriendsWidget({Key? key}) : super(key: key);

  static String routeName = 'chat_friends';
  static String routePath = '/chat/friends';

  @override
  State<FriendsWidget> createState() => _FriendsWidgetState();
}

class _FriendsWidgetState extends State<FriendsWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  // AuthContract helper
  String get currentUserUid => GetIt.instance<AuthContract>().getCurrentUserId() ?? '';

  @override
  void initState() {
    super.initState();
    // Provider 초기화 (친구 추천 목록 로드)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FriendsProvider>();
      if (currentUserUid.isNotEmpty) {
        provider.initialize(currentUserUid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          '친구 추천',
          style: VersusTextStyles.headingSmall.copyWith(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // 검색 바
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: VersusColors.borderLight,
                    width: 1.0,
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: VersusColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '친구 검색',
                    hintStyle: VersusTextStyles.bodyMedium.copyWith(
                      color: VersusColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: VersusColors.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    // Provider를 통한 검색
                    context.read<FriendsProvider>().searchFriends(value);
                  },
                ),
              ),
            ),
            // 검색 결과 또는 추천 친구
            Expanded(
              child: Consumer<FriendsProvider>(
                builder: (context, provider, child) {
                  // 로그인 여부 확인
                  if (currentUserUid.isEmpty) {
                    return _buildNotLoggedIn();
                  }

                  // 로딩 상태
                  if (provider.isLoading) {
                    return Center(
                      child: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            VersusColors.primary,
                          ),
                        ),
                      ),
                    );
                  }

                  // 에러 상태
                  if (provider.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: VersusColors.error,
                          ),
                          VersusSpacing.gapMD,
                          Text(
                            provider.errorMessage ?? '오류가 발생했습니다',
                            style: VersusTextStyles.bodyMedium.copyWith(
                              color: VersusColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          VersusSpacing.gapMD,
                          VersusButton(
                            text: '다시 시도',
                            onPressed: () {
                              provider.initialize(currentUserUid);
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  // 빈 상태
                  if (provider.isEmpty) {
                    return _buildEmptyState(provider.searchQuery);
                  }

                  // 사용자 목록 표시
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      // UserProfile로 안전하게 캐스팅
                      if (user is! UserProfile) return SizedBox.shrink();
                      return _buildUserItem(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapMD,
          Text(
            '로그인이 필요합니다',
            style: VersusTextStyles.headingMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    final isSearching = searchQuery.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.person_search,
            size: 64,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapMD,
          Text(
            isSearching ? '검색 결과가 없습니다' : '추천할 친구가 없습니다',
            style: VersusTextStyles.headingMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserProfile user) {
    return InkWell(
      onTap: () {
        // TODO: Phase 3에서 프로필 페이지 이동 구현 예정
        BotToast.showText(text: '프로필 페이지는 준비 중입니다.');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: VersusColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: Padding(
          padding: VersusSpacing.paddingMD,
          child: Row(
            children: [
              // 프로필 이미지
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: (user.photoUrl?.isNotEmpty ?? false)
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: !(user.photoUrl?.isNotEmpty ?? false)
                      ? VersusColors.primaryWithAlpha(0.1)
                      : null,
                ),
                child: !(user.photoUrl?.isNotEmpty ?? false)
                    ? Center(
                        child: Icon(
                          Icons.person,
                          color: VersusColors.primary,
                          size: 28,
                        ),
                      )
                    : null,
              ),
              VersusSpacing.gapH(VersusSpacing.sm),
              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? '알 수 없음',
                      style: VersusTextStyles.buttonMedium.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    if (user.interests.isNotEmpty) ...[
                      VersusSpacing.gapXS,
                      Text(
                        user.interests.take(2).join(', '),
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // 팔로우 버튼
              _buildFollowButton(user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowButton(UserProfile user) {
    // TODO: Phase 3에서 팔로우 상태 저장 및 실시간 업데이트 구현 예정
    // 현재는 단순 팔로우 버튼만 표시
    return Consumer<FriendsProvider>(
      builder: (context, provider, child) {
        return VersusButton(
          text: '팔로우',
          size: VersusButtonSize.small,
          onPressed: () async {
            if (currentUserUid.isEmpty) {
              BotToast.showText(text: '로그인이 필요합니다.');
              return;
            }

            try {
              final newState = await provider.toggleFollow(user.uid);

              if (mounted) {
                BotToast.showText(
                  text: newState
                      ? '${user.displayName ?? "사용자"}님을 팔로우했습니다'
                      : '언팔로우했습니다',
                );
              }
            } catch (e) {
              if (mounted) {
                ErrorHandler.handle(
                  e,
                  customMessage: '오류가 발생했습니다: ${e.toString()}',
                  context: context,
                );
              }
            }
          },
        );
      },
    );
  }
}
