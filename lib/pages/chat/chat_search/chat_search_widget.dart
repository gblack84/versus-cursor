import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_utils.dart';
import '/design_system/design_system.dart';

class ChatSearchWidget extends StatefulWidget {
  const ChatSearchWidget({Key? key}) : super(key: key);

  static String routeName = 'chat_search';
  static String routePath = '/chat/search';

  @override
  State<ChatSearchWidget> createState() => _ChatSearchWidgetState();
}

class _ChatSearchWidgetState extends State<ChatSearchWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    // 검색 로직
                    setState(() {});
                  },
                ),
              ),
            ),
            // 검색 결과 또는 추천 친구
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildRecommendations()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    if (currentUserReference == null) {
      return _buildNotLoggedIn();
    }

    return StreamBuilder<List<UsersModel>>(
      stream: queryUsersModel(
        queryBuilder: (usersRecord) => usersRecord
            .where('uid', isNotEqualTo: currentUserUid)
            .orderBy('uid')
            .orderBy('total_a_points', descending: true)
            .limit(20),
      ),
      builder: (context, snapshot) {
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

        final users = snapshot.data!;
        
        if (users.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildUserItem(user);
          },
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final searchQuery = _searchController.text.toLowerCase();
    
    return StreamBuilder<List<UsersModel>>(
      stream: queryUsersModel(
        queryBuilder: (usersRecord) => usersRecord
            .where('uid', isNotEqualTo: currentUserUid)
            .orderBy('uid')
            .orderBy('display_name'),
      ),
      builder: (context, snapshot) {
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

        final allUsers = snapshot.data!;
        final filteredUsers = allUsers.where((user) {
          return user.displayName.toLowerCase().contains(searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: VersusColors.textSecondary,
                ),
                VersusSpacing.gapMD,
                Text(
                  '검색 결과가 없습니다',
                  style: VersusTextStyles.headingMedium.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserItem(user);
          },
        );
      },
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
            Icons.person_search,
            size: 64,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapMD,
          Text(
            '추천할 친구가 없습니다',
            style: VersusTextStyles.headingMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(UsersModel user) {
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
                  image: user.photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: user.photoUrl.isEmpty
                      ? VersusColors.primaryWithAlpha(0.1)
                      : null,
                ),
                child: user.photoUrl.isEmpty
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
                      user.displayName,
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
              VersusButton(
                text: '팔로우',
                size: VersusButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('팔로우 기능은 준비 중입니다.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}