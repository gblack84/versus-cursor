import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/design_system/design_system.dart';

class FriendsListWidget extends StatefulWidget {
  const FriendsListWidget({Key? key}) : super(key: key);

  static String routeName = 'friends_list';
  static String routePath = '/chat/friends';

  @override
  State<FriendsListWidget> createState() => _FriendsListWidgetState();
}

class _FriendsListWidgetState extends State<FriendsListWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          '친구',
          style: VersusTextStyles.headingSmall.copyWith(
                color: Colors.black,
              ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_add_outlined,
              color: Colors.black,
              size: 24.0,
            ),
            onPressed: () {
              // 친구 추가
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('친구 추가 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: currentUserReference == null
            ? _buildNotLoggedIn()
            : StreamBuilder<List<FriendsListModel>>(
                stream: queryFriendsListModel(
                  parent: currentUserReference,
                  queryBuilder: (friendsListRecord) => friendsListRecord
                      .where('follower', isEqualTo: true)
                      .orderBy('last_interaction', descending: true),
                ),
                builder: (context, snapshot) {
                  // 로딩 중
                  if (!snapshot.hasData) {
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

                  final friends = snapshot.data!;

                  if (friends.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friendItem = friends[index];
                      return _buildFriendItem(friendItem);
                    },
                  );
                },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapMD,
          Text(
            '아직 친구가 없습니다',
            style: VersusTextStyles.headingMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
          VersusSpacing.gapSM,
          Text(
            '다른 사용자를 팔로우하면\n여기에 표시됩니다',
            textAlign: TextAlign.center,
            style: VersusTextStyles.bodyMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(FriendsListModel friend) {
    return FutureBuilder<UsersModel?>(
      future: UsersModel.getDocumentOnce(
        FirebaseFirestore.instance.doc('/users/${friend.friendsId}'),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final userData = snapshot.data!;
        
        return InkWell(
          onTap: () {
            // 프로필 페이지로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('프로필 페이지는 준비 중입니다.')),
            );
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
                      image: userData.photoUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(userData.photoUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: userData.photoUrl.isEmpty
                          ? VersusColors.primaryWithAlpha(0.1)
                          : null,
                    ),
                    child: userData.photoUrl.isEmpty
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
                          userData.displayName,
                          style: VersusTextStyles.buttonMedium.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        if (userData.interests.isNotEmpty) ...[
                          VersusSpacing.gapXS,
                          Text(
                            userData.interests.take(2).join(', '),
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
                  // 팔로우 상태
                  if (friend.following)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: VersusSpacing.sm,
                        vertical: VersusSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: VersusColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '맞팔로우',
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}