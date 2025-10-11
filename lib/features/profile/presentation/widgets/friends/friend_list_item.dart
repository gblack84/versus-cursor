import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/features/profile/domain/models/user_profile.dart';
import '../profile/profile_avatar.dart';

/// 친구 목록 아이템 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - UserProfile 도메인 모델 사용
/// - 액션 버튼 지원 (메시지, 삭제 등)
class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.friend,
    this.onTap,
    this.onMessageTap,
    this.onRemoveTap,
  });

  final UserProfile friend;
  final VoidCallback? onTap;
  final VoidCallback? onMessageTap;
  final VoidCallback? onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      leading: ProfileAvatar(
        photoUrl: friend.photoUrl,
        size: AvatarSize.medium,
      ),
      title: Text(
        friend.displayName,
        style: AppTheme.of(context).bodyLarge.override(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: friend.shortDescription.isNotEmpty
          ? Text(
              friend.shortDescription,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메시지 버튼
          if (onMessageTap != null)
            IconButton(
              icon: Icon(
                Icons.message,
                color: AppTheme.of(context).primary,
              ),
              onPressed: onMessageTap,
            ),

          // 삭제 버튼
          if (onRemoveTap != null)
            IconButton(
              icon: Icon(
                Icons.person_remove,
                color: AppTheme.of(context).error,
              ),
              onPressed: onRemoveTap,
            ),
        ],
      ),
    );
  }
}
