import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/profile_provider.dart';
import '/features/profile/domain/models/user_profile.dart';

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
  @override
  void initState() {
    super.initState();
    // Provider에서 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      provider.loadProfile(widget.userId);
    });
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
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          // 로딩 상태
          if (provider.isLoading && provider.profile == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.of(context).primary,
                ),
              ),
            );
          }

          // 에러 상태
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.of(context).error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: AppTheme.of(context).bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProfile(widget.userId),
                    child: Text(
                      AppLocalizations.of(context).getText('retry' /* 다시 시도 */),
                    ),
                  ),
                ],
              ),
            );
          }

          // 프로필 표시
          final profile = provider.profile;
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
                _buildProfileHeader(profile),

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
                    if (profile.phoneNumber.isNotEmpty)
                      _buildInfoRow(
                        context,
                        Icons.phone,
                        AppLocalizations.of(context).getText('phone' /* 전화번호 */),
                        profile.phoneNumber,
                      ),
                    if (profile.gender.isNotEmpty)
                      _buildInfoRow(
                        context,
                        Icons.person,
                        AppLocalizations.of(context).getText('gender' /* 성별 */),
                        profile.gender,
                      ),
                    if (profile.language.isNotEmpty)
                      _buildInfoRow(
                        context,
                        Icons.language,
                        AppLocalizations.of(context).getText('language' /* 언어 */),
                        profile.language,
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
                            .map((interest) => Chip(
                                  label: Text(interest),
                                  backgroundColor:
                                      AppTheme.of(context).secondaryBackground,
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
                            .map((exp) => Chip(
                                  label: Text(exp),
                                  backgroundColor: AppTheme.of(context).primary.withValues(alpha: 0.1),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPointCard(
                          context,
                          'A Points',
                          profile.pointsA,
                          Icons.emoji_events,
                          AppTheme.of(context).primary,
                        ),
                        _buildPointCard(
                          context,
                          'Q Points',
                          profile.pointsQ,
                          Icons.question_answer,
                          AppTheme.of(context).secondary,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 랭킹 정보
                if (profile.currentRank.isNotEmpty || profile.currentTitle.isNotEmpty)
                  _buildInfoSection(
                    context,
                    AppLocalizations.of(context).getText('ranking' /* 랭킹 */),
                    [
                      if (profile.currentRank.isNotEmpty)
                        _buildInfoRow(
                          context,
                          Icons.military_tech,
                          AppLocalizations.of(context).getText('rank' /* 등급 */),
                          profile.currentRank,
                        ),
                      if (profile.currentTitle.isNotEmpty)
                        _buildInfoRow(
                          context,
                          Icons.star,
                          AppLocalizations.of(context).getText('title' /* 칭호 */),
                          profile.currentTitle,
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

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.of(context).primary,
            AppTheme.of(context).secondary,
          ],
        ),
      ),
      child: Column(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage:
                profile.photoUrl.isNotEmpty ? NetworkImage(profile.photoUrl) : null,
            child: profile.photoUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: AppTheme.of(context).secondaryText,
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // 표시 이름
          Text(
            profile.displayName,
            style: AppTheme.of(context).headlineMedium.override(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),

          // 한 줄 소개
          if (profile.shortDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              profile.shortDescription,
              style: AppTheme.of(context).bodyMedium.override(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
              textAlign: TextAlign.center,
            ),
          ],

          // 프리미엄 뱃지
          if (profile.isPremiumUser) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: AppTheme.of(context).bodySmall.override(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
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

  Widget _buildPointCard(
    BuildContext context,
    String label,
    int points,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.of(context).bodySmall.override(
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            points.toString(),
            style: AppTheme.of(context).headlineMedium.override(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
