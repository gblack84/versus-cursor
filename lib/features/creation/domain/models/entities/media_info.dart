import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_info.freezed.dart';
part 'media_info.g.dart';

/// Domain entity for media information using Freezed sealed union
/// Represents either image or video media with type-safe pattern matching
@freezed
sealed class MediaInfo with _$MediaInfo {
  /// Image media variant
  ///
  /// Contains image-specific properties like aspect ratio and dimensions
  const factory MediaInfo.image({
    required String id,
    required String url,
    String? parentId,
    double? aspectRatio,
    double? width,
    double? height,
    int? size,
    String? mimeType,
    DateTime? createdAt,
    String? thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) = ImageInfo;

  /// Video media variant
  ///
  /// Contains video-specific properties like duration and dimensions
  const factory MediaInfo.video({
    required String id,
    required String url,
    String? parentId,
    double? width,
    double? height,
    double? duration,
    int? size,
    String? mimeType,
    DateTime? createdAt,
    String? thumbnailUrl,
    double? aspectRatio,
    Map<String, dynamic>? metadata,
  }) = VideoInfo;

  /// JSON serialization support
  factory MediaInfo.fromJson(Map<String, dynamic> json) =>
      _$MediaInfoFromJson(json);
}
