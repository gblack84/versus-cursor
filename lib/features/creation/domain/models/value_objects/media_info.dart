/// Domain entity for media information
/// Clean Architecture compliant media representation
abstract class MediaInfo {
  final String id;
  final String url;
  final Map<String, dynamic>? metadata;

  const MediaInfo({
    required this.id,
    required this.url,
    this.metadata,
  });

  Map<String, dynamic> toJson();
}

/// Domain entity for image information
class ImageInfo extends MediaInfo {
  final String? parentId;
  final double? aspectRatio;
  final double? width;
  final double? height;
  final int? size;
  final String? mimeType;
  final DateTime? createdAt;
  final String? thumbnailUrl;

  const ImageInfo({
    required String id,
    required String url,
    this.parentId,
    this.aspectRatio,
    this.width,
    this.height,
    this.size,
    this.mimeType,
    this.createdAt,
    this.thumbnailUrl,
    Map<String, dynamic>? metadata,
  }) : super(id: id, url: url, metadata: metadata);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'parentId': parentId,
      'aspectRatio': aspectRatio,
      'width': width,
      'height': height,
      'size': size,
      'mimeType': mimeType,
      'createdAt': createdAt?.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      parentId: json['parentId'],
      aspectRatio: json['aspectRatio']?.toDouble(),
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      size: json['size'],
      mimeType: json['mimeType'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      thumbnailUrl: json['thumbnailUrl'],
      metadata: json['metadata'],
    );
  }
}

/// Domain entity for video information
class VideoInfo extends MediaInfo {
  final String? parentId;
  final double? width;
  final double? height;
  final double? duration;
  final int? size;
  final String? mimeType;
  final DateTime? createdAt;
  final String? thumbnailUrl;
  final double? aspectRatio;

  const VideoInfo({
    required String id,
    required String url,
    this.parentId,
    this.width,
    this.height,
    this.duration,
    this.size,
    this.mimeType,
    this.createdAt,
    this.thumbnailUrl,
    this.aspectRatio,
    Map<String, dynamic>? metadata,
  }) : super(id: id, url: url, metadata: metadata);

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'parentId': parentId,
      'width': width,
      'height': height,
      'duration': duration,
      'size': size,
      'mimeType': mimeType,
      'createdAt': createdAt?.toIso8601String(),
      'thumbnailUrl': thumbnailUrl,
      'aspectRatio': aspectRatio,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      parentId: json['parentId'],
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      duration: json['duration']?.toDouble(),
      size: json['size'],
      mimeType: json['mimeType'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      thumbnailUrl: json['thumbnailUrl'],
      aspectRatio: json['aspectRatio']?.toDouble(),
      metadata: json['metadata'],
    );
  }
}