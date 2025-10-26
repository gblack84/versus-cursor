import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design_system/design_system.dart';
import '/core/constants/app_constants.dart';
import '/features/voting/domain/constants/voting_constants.dart';

/// Vote Card Profile Header 컴포넌트
///
/// **기능:**
/// - Pikle 브랜딩 표시 (아이콘 + 텍스트)
/// - 발신자 프로필 이미지 및 이름 표시
/// - 투표 상태 배지 표시
/// - 내가 만든 피클/타인이 보낸 피클 구분
///
/// **레이아웃:**
/// ```
/// [프로필]  [Pikle 도착!       ]  [상태배지]
///          [발신자님이 물어봅니다]
/// ```
class VoteCardProfileHeader extends StatelessWidget {
  const VoteCardProfileHeader({
    super.key,
    required this.isMe,
    required this.statusInfo,
    this.displayName,
    this.senderProfileImageUrl,
    this.currentUserName,
  });

  /// 내가 만든 투표 여부
  final bool isMe;

  /// 투표 상태 정보 (color, icon, text)
  final Map<String, dynamic> statusInfo;

  /// 표시할 이름 (발신자 또는 내 이름)
  final String? displayName;

  /// 발신자 프로필 이미지 URL
  final String? senderProfileImageUrl;

  /// 현재 사용자 이름 (isMe일 때 사용)
  final String? currentUserName;

  @override
  Widget build(BuildContext context) {
    // isMe에 따라 표시할 이름 결정
    final effectiveDisplayName = isMe
        ? (currentUserName ?? '나')
        : (displayName ?? AppConstants.unknownUserText);

    // 프로필 이미지 존재 여부
    final hasProfileImage = senderProfileImageUrl?.isNotEmpty ?? false;

    return Row(
      children: [
        // 1. 프로필 이미지
        _buildProfileImage(hasProfileImage),
        const SizedBox(width: 12),

        // 2. 중간 영역: Pikle 브랜딩 + 발신자 정보
        Expanded(
          child: _buildBrandingAndSenderInfo(effectiveDisplayName),
        ),

        // 3. 오른쪽: 상태 배지
        _buildStatusBadge(),
      ],
    );
  }

  /// 프로필 이미지 위젯
  Widget _buildProfileImage(bool hasProfileImage) {
    return GestureDetector(
      onTap: () {
        // TODO: 프로필 페이지로 이동
        debugPrint('Navigate to profile: ${displayName ?? currentUserName}');
      },
      child: CircleAvatar(
        radius: 20,
        backgroundImage: hasProfileImage && !isMe
            ? CachedNetworkImageProvider(senderProfileImageUrl!)
            : null,
        backgroundColor: hasProfileImage && !isMe
            ? Colors.transparent
            : VersusColors.borderLight,
        child: !hasProfileImage || isMe
            ? Icon(
                Icons.person,
                size: 24,
                color: VersusColors.textSecondary,
              )
            : null,
      ),
    );
  }

  /// Pikle 브랜딩 + 발신자 정보 위젯
  Widget _buildBrandingAndSenderInfo(String effectiveDisplayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pikle 도착! 라인
        Row(
          children: [
            Image.asset(
              'assets/images/pikle_icon.png',
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isMe ? '내가 만든 피클' : 'Pikle 도착!',
              style: VersusTextStyles.labelMedium.copyWith(
                color: VersusColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),

        // 발신자 정보
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: isMe ? '나' : effectiveDisplayName,
                  style: VersusTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: VersusColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: isMe ? ' • 투표 생성됨' : '님이 물어봅니다',
                  style: VersusTextStyles.labelSmall.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 상태 배지 위젯
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VersusSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (statusInfo['color'] as Color).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'] as IconData,
            size: VotingConstants.multiImageIndicatorIconSize,
            color: statusInfo['color'] as Color,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo['text'] as String,
            style: VersusTextStyles.labelSmall.copyWith(
              fontSize: 11,
              color: statusInfo['color'] as Color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
