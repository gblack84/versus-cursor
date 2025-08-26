import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/features/common/presentation/design_system/design_system.dart';

/// 투표 카드 메시지의 헤더 컴포넌트
/// 
/// 프로필 이미지, 발신자 정보, 상태 배지를 표시합니다.
class VoteCardHeader extends StatelessWidget {
  final bool isMe;
  final String? currentUserName;
  final String? senderDisplayName;
  final String? senderProfileImageUrl;
  final Map<String, dynamic> statusInfo;

  const VoteCardHeader({
    super.key,
    required this.isMe,
    this.currentUserName,
    this.senderDisplayName,
    this.senderProfileImageUrl,
    required this.statusInfo,
  });

  @override
  Widget build(BuildContext context) {
    // isMe에 따라 표시할 이름과 프로필 결정
    final displayName = isMe 
        ? (currentUserName ?? '나')
        : (senderDisplayName ?? '알 수 없는 사용자');
    
    // 프로필 이미지도 isMe에 따라 결정
    final hasProfileImage = senderProfileImageUrl?.isNotEmpty ?? false;
    
    return Row(
      children: [
        // 프로필 이미지
        GestureDetector(
          onTap: () {
            // TODO: 프로필 페이지로 이동
            debugPrint('Navigate to profile: $displayName');
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
        ),
        const SizedBox(width: 12),
        
        // 중간 영역: Pikle 브랜딩 + 발신자 정보
        Expanded(
          child: Column(
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
                    // isMe에 따라 다른 텍스트 표시
                    isMe
                        ? '내가 만든 피클' 
                        : 'Pikle 도착!',
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
                        text: isMe ? '나' : displayName,
                        style: VersusTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: VersusColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: isMe
                            ? ' • 투표 생성됨'
                            : '님이 물어봅니다',
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 오른쪽: 상태 배지
        Container(
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
                size: 12,
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
        ),
      ],
    );
  }
}