import 'package:equatable/equatable.dart';

/// Domain entity representing media content for post options A or B
class MediaContent extends Equatable {
  const MediaContent({
    this.text = '',
    this.imageUrls = const [],
    this.videoUrl = '',
    this.youtubeUrl = '',
    this.aspectRatio,
    this.aspectRatios = const [],
    this.layoutType = '',
    this.thumbnailUrl = '',
    this.mediaType = 'text',
    this.duration,
    this.fileSize,
    this.dimensions = const {},
  });

  final String text;
  final List<String> imageUrls;
  final String videoUrl;
  final String youtubeUrl;
  final double? aspectRatio; // Single aspect ratio (backward compatibility)
  final List<double> aspectRatios; // Multiple aspect ratios for multi-image support
  final String layoutType;
  final String thumbnailUrl;
  final String mediaType;
  final int? duration;
  final int? fileSize;
  final Map<String, dynamic> dimensions;

  /// Creates a copy of this media content with the given fields replaced with new values
  MediaContent copyWith({
    String? text,
    List<String>? imageUrls,
    String? videoUrl,
    String? youtubeUrl,
    double? aspectRatio,
    List<double>? aspectRatios,
    String? layoutType,
    String? thumbnailUrl,
    String? mediaType,
    int? duration,
    int? fileSize,
    Map<String, dynamic>? dimensions,
  }) {
    return MediaContent(
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      layoutType: layoutType ?? this.layoutType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaType: mediaType ?? this.mediaType,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  /// Converts this media content to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'youtubeUrl': youtubeUrl,
      'aspectRatio': aspectRatio,
      'aspectRatios': aspectRatios,
      'layoutType': layoutType,
      'thumbnailUrl': thumbnailUrl,
      'mediaType': mediaType,
      'duration': duration,
      'fileSize': fileSize,
      'dimensions': dimensions,
    };
  }

  /// Creates media content from a Firestore document
  factory MediaContent.fromJson(Map<String, dynamic> json) {
    return MediaContent(
      text: json['text'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      videoUrl: json['videoUrl'] ?? '',
      youtubeUrl: json['youtubeUrl'] ?? '',
      aspectRatio: json['aspectRatio']?.toDouble(),
      aspectRatios: json['aspectRatios'] != null
          ? List<double>.from(
              (json['aspectRatios'] as List).map((e) => (e as num).toDouble()))
          : [],
      layoutType: json['layoutType'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'text',
      duration: json['duration'],
      fileSize: json['fileSize'],
      dimensions: Map<String, dynamic>.from(json['dimensions'] ?? {}),
    );
  }

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

  /// Create from Map (alias for fromJson for compatibility)
  factory MediaContent.fromMap(Map<String, dynamic> map) {
    return MediaContent.fromJson(map);
  }

  /// Convert to Map (alias for toJson for compatibility)
  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [
        text,
        imageUrls,
        videoUrl,
        youtubeUrl,
        aspectRatio,
        aspectRatios,
        layoutType,
        thumbnailUrl,
        mediaType,
        duration,
        fileSize,
        dimensions,
      ];

  @override
  String toString() =>
      'MediaContent(text: $text, hasImages: $hasImages, hasVideo: $hasVideo)';
}
