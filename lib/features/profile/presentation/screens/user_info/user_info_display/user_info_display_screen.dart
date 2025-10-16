import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/profile_provider.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/features/profile/presentation/widgets/profile/profile_header.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';
import '/features/profile/presentation/widgets/interests/interest_chip.dart';
import '/features/profile/domain/models/interest.dart';
import '/features/profile/presentation/widgets/profile/profile_stats_card.dart';

/// 사용자 정보 표시 화면
///
/// **Clean Architecture v4.0 준수**:
/// - Provider 패턴으로 상태 관리
/// - UseCase 통해 비즈니스 로직 처리
/// - 읽기 전용 프로필 정보 표시
class UserInfoDisplayScreen extends StatefulWidget {
  const UserInfoDisplayScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'user_info_display';
  static String routePath = '/user/:userId/info';

  @override
  State<UserInfoDisplayScreen> createState() => _UserInfoDisplayScreenState();
}

class _UserInfoDisplayScreenState extends State<UserInfoDisplayScreen> {
  late Stream<UserProfile?> _profileStream;

  @override
  void initState() {
    super.initState();
    // 🆕 Real-time Stream 시작
    // Consumer 대신 StreamBuilder로 변경하여 실시간 동기화 구현
    final provider = context.read<ProfileProvider>();
    _profileStream = provider.watchOtherUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getText('user_info' /* 사용자 정보 */),
          style: AppTheme.of(context).headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 프로필 공유 기능
            },
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: _profileStream,
        builder: (context, snapshot) {
          // 로딩 상태 (초기 연결 대기 중)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProfileLoadingIndicator(
              size: LoadingSize.medium,
            );
          }

          // 에러 상태
          if (snapshot.hasError) {
            return ProfileErrorMessage(
              message: snapshot.error.toString(),
              onRetry: () {
                // Stream 재시작
                setState(() {
                  final provider = context.read<ProfileProvider>();
                  _profileStream = provider.watchOtherUserProfile(widget.userId);
                });
              },
            );
          }

          // 프로필 표시
          // ⚠️ snapshot.data는 실시간으로 업데이트됩니다!
          final profile = snapshot.data;
          if (profile == null) {
            return Center(
              child: Text(
                AppLocalizations.of(context).getText('user_not_found' /* 사용자를 찾을 수 없습니다 */),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 프로필 헤더
                ProfileHeader(profile: profile),

                const SizedBox(height: 16),

                // 기본 정보
                _buildInfoSection(
                  context,
                  AppLocalizations.of(context).getText('basic_info' /* 기본 정보 */),
                  [
                    _buildInfoRow(
                      context,
                      Icons.email,
                      AppLocalizations.of(context).getText('email' /* 이메일 */),
                      profile.email,
                    ),
                    if (profile.phoneNumber?.isNotEmpty == true)
                      _buildInfoRow(
                        context,
                        Icons.phone,
                        AppLocalizations.of(context).getText('phone' /* 전화번호 */),
                        profile.phoneNumber!,
                      ),
                    if (profile.gender?.isNotEmpty == true)
                      _buildInfoRow(
                        context,
                        Icons.person,
                        AppLocalizations.of(context).getText('gender' /* 성별 */),
                        profile.gender!,
                      ),
                    if (profile.language?.isNotEmpty == true)
                      _buildInfoRow(
                        context,
                        Icons.language,
                        AppLocalizations.of(context).getText('language' /* 언어 */),
                        profile.language!,
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // 관심사
                if (profile.interests.isNotEmpty)
                  _buildInfoSection(
                    context,
                    AppLocalizations.of(context).getText('interests' /* 관심사 */),
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.interests
                            .map((interest) => InterestChip(
                                  interest: Interest.fromString(interest, 'hobby'),
                                ))
                            .toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // 전문분야
                if (profile.expertise.isNotEmpty)
                  _buildInfoSection(
                    context,
                    AppLocalizations.of(context).getText('expertise' /* 전문분야 */),
                    [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile.expertise
                            .map((exp) => InterestChip(
                                  interest: Interest.fromString(exp, 'expertise'),
                                ))
                            .toList(),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                // 포인트 정보
                _buildInfoSection(
                  context,
                  AppLocalizations.of(context).getText('points' /* 포인트 */),
                  [
                    ProfilePointsCard(
                      pointsA: profile.pointsA,
                      pointsQ: profile.pointsQ,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 랭킹 정보
                if (profile.currentRank?.isNotEmpty == true || profile.currentTitle?.isNotEmpty == true)
                  _buildInfoSection(
                    context,
                    AppLocalizations.of(context).getText('ranking' /* 랭킹 */),
                    [
                      if (profile.currentRank?.isNotEmpty == true)
                        _buildInfoRow(
                          context,
                          Icons.military_tech,
                          AppLocalizations.of(context).getText('rank' /* 등급 */),
                          profile.currentRank!,
                        ),
                      if (profile.currentTitle?.isNotEmpty == true)
                        _buildInfoRow(
                          context,
                          Icons.star,
                          AppLocalizations.of(context).getText('title' /* 칭호 */),
                          profile.currentTitle!,
                        ),
                    ],
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.of(context).headlineSmall,
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.of(context).bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
