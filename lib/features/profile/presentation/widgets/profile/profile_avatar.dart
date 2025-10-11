import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 프로필 아바타 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 다양한 크기 및 편집 모드 지원
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    this.size = AvatarSize.medium,
    this.editable = false,
    this.onEditTap,
  });

  final String photoUrl;
  final AvatarSize size;
  final bool editable;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final radius = _getRadius();

    return Stack(
      children: [
        // 아바타 이미지
        CircleAvatar(
          radius: radius,
          backgroundColor: AppTheme.of(context).secondaryBackground,
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty
              ? Icon(
                  Icons.person,
                  size: radius * 1.2,
                  color: AppTheme.of(context).secondaryText,
                )
              : null,
        ),

        // 편집 버튼 (옵션)
        if (editable && onEditTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.of(context).primaryBackground,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: _getIconSize(),
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _getRadius() {
    switch (size) {
      case AvatarSize.small:
        return 20.0;
      case AvatarSize.medium:
        return 40.0;
      case AvatarSize.large:
        return 60.0;
      case AvatarSize.extraLarge:
        return 80.0;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AvatarSize.small:
      case AvatarSize.medium:
        return 16.0;
      case AvatarSize.large:
        return 20.0;
      case AvatarSize.extraLarge:
        return 24.0;
    }
  }
}

/// 아바타 크기 열거형
enum AvatarSize {
  small,
  medium,
  large,
  extraLarge,
}
