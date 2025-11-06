import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_content.freezed.dart';
part 'media_content.g.dart';

/// Domain entity representing media content for post options A or B
///
/// **Freezed Migration**: Equatable에서 Freezed로 마이그레이션
/// - 불변성 자동 보장
/// - copyWith 자동 생성
/// - 6개 비즈니스 로직 getter 보존
@freezed
sealed class MediaContent with _$MediaContent {
  const MediaContent._();

  const factory MediaContent({
    @Default('') String text,
    @Default([]) List<String> imageUrls,
    @Default('') String videoUrl,
    @Default('') String youtubeUrl,
    double? aspectRatio, // Single aspect ratio (backward compatibility)
    @Default([]) List<double> aspectRatios, // Multiple aspect ratios for multi-image support
    @Default('') String layoutType,
    @Default('') String thumbnailUrl,
    @Default('text') String mediaType,
    int? duration,
    int? fileSize,
    @Default({}) Map<String, dynamic> dimensions,
  }) = _MediaContent;

  /// Freezed's fromJson for JSON deserialization
  factory MediaContent.fromJson(Map<String, dynamic> json) =>
      _$MediaContentFromJson(json);

  /// Create from Map (alias for fromJson for compatibility)
  factory MediaContent.fromMap(Map<String, dynamic> map) {
    return MediaContent.fromJson(map);
  }

  /// Convert to Map (alias for toJson for compatibility)
  Map<String, dynamic> toMap() => toJson();

  // ============================================
  // Business Logic (비즈니스 로직)
  // ============================================

  /// Checks if this media content has any media (images or videos)
  bool get hasMedia =>
      imageUrls.isNotEmpty || videoUrl.isNotEmpty || youtubeUrl.isNotEmpty;

  /// Checks if this media content has images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Checks if this media content has video
  bool get hasVideo => videoUrl.isNotEmpty || youtubeUrl.isNotEmpty;

  /// Gets the primary image URL (first in the list)
  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// Check if content is empty (no text and no media)
  bool get isEmpty => text.isEmpty && !hasMedia;

  /// Check if has any content (text or media)
  bool get hasContent => text.isNotEmpty || hasMedia;
}
