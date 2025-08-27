import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/backend/backend.dart';
import '/features/auth/data/services/auth_util.dart';
import '/core/design_system/design_system.dart';

class ProfilePageWidget extends StatefulWidget {
  const ProfilePageWidget({super.key});

  static String routeName = 'profile_page';
  static String routePath = '/profile';

  @override
  State<ProfilePageWidget> createState() => _ProfilePageWidgetState();
}

class _ProfilePageWidgetState extends State<ProfilePageWidget> {
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
            : StreamBuilder<UsersModel>(
                stream: UsersModel.getDocument(currentUserReference!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          VersusColors.primary,
                        ),
                      ),
                    );
                  }

                  final user = snapshot.data!;
                  
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
                                backgroundColor: VersusColors.primaryWithAlpha(0.2),
                                backgroundImage: user.photoUrl.isNotEmpty
                                    ? NetworkImage(user.photoUrl)
                                    : null,
                                child: user.photoUrl.isEmpty
                                    ? Icon(Icons.person, color: VersusColors.primary, size: 50)
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        
                        // 로그아웃 버튼
                        VersusButton.error(
                          text: '로그아웃',
                          isFullWidth: true,
                          size: VersusButtonSize.large,
                          onPressed: () async {
                            await authManager.signOut();
                            context.goNamed('startPage');
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

  Widget _buildPointInfo(BuildContext context, String label, String value, Color color) {
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
}