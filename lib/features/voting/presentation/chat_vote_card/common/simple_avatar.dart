import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design_system/design_system.dart';
import '/services/cache/unified_image_cache_service.dart';

/// 간단한 프로필 아바타 위젯 (Voting Feature 전용)
///
/// **Clean Architecture v4.0 준수**:
/// - Feature 격리: Profile Feature 의존성 제거
/// - 재사용 가능한 UI 컴포넌트
/// - Design System 기반 일관된 디자인
///
/// **이미지 캐싱**:
/// - CachedNetworkImageProvider로 네트워크 요청 최소화
/// - Avatar 크기별 최적화된 memCacheWidth 적용
class SimpleAvatar extends StatelessWidget {
  const SimpleAvatar({
    super.key,
    required this.photoUrl,
    this.size = AvatarSize.medium,
  });

  final String photoUrl;
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final radius = _getRadius();

    return CircleAvatar(
      radius: radius,
      backgroundColor: VersusColors.backgroundSecondary,
      backgroundImage: photoUrl.isNotEmpty
          ? CachedNetworkImageProvider(
              photoUrl,
              cacheKey: photoUrl,
              maxWidth: _getCacheWidth(),
            )
          : null,
      child: photoUrl.isEmpty
          ? Icon(
              Icons.person,
              size: radius * 1.2,
              color: VersusColors.textSecondary,
            )
          : null,
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

  /// 캐시 너비 계산 (diameter * 2.0 scale factor)
  ///
  /// **최적화된 캐시 크기**:
  /// - Small: 80px (20 radius * 2 * 2.0)
  /// - Medium: 160px (40 radius * 2 * 2.0)
  /// - Large: 240px (60 radius * 2 * 2.0)
  /// - ExtraLarge: 320px (80 radius * 2 * 2.0)
  int _getCacheWidth() {
    final radius = _getRadius();
    final diameter = radius * 2;
    return (diameter * UnifiedImageCacheService.SCALE_FACTOR).toInt();
  }
}

/// 아바타 크기 열거형
enum AvatarSize {
  small,
  medium,
  large,
  extraLarge,
}
