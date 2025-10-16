import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/features/profile/domain/models/user_profile.dart';
import 'profile_avatar.dart';

/// 프로필 헤더 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - UserProfile 도메인 모델 사용
/// - Gradient 배경 및 프리미엄 뱃지 지원
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.editable = false,
    this.onEditPhoto,
  });

  final UserProfile profile;
  final bool editable;
  final VoidCallback? onEditPhoto;

  @override
  Widget build(BuildContext context) {
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
          // 프로필 아바타
          ProfileAvatar(
            photoUrl: profile.photoUrl ?? '',
            size: AvatarSize.extraLarge,
            editable: editable,
            onEditTap: onEditPhoto,
          ),
          const SizedBox(height: 16),

          // 표시 이름
          Text(
            profile.displayName ?? 'Unknown',
            style: AppTheme.of(context).headlineMedium.override(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          // 한 줄 소개
          if (profile.shortDescription?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              profile.shortDescription!,
              style: AppTheme.of(context).bodyMedium.override(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
}
