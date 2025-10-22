/// DTO for Video data transfer from Firestore
/// Replaces VideoModel with pure data structure
///
/// This DTO eliminates DocumentReference dependency while preserving
/// all functionality including parentId and encoding status tracking.
class VideoResultDto {
  final String id;
  final String url;
  final int duration;
  final String params;
  final String? sourceVideoUrl;
  final String? thumbUrl;
  final String? ownerUid;
  final String? status;
  final DateTime? createdAt;
  final String? parentId; // Read directly from Firestore field

  const VideoResultDto({
    required this.id,
    required this.url,
    required this.duration,
    required this.params,
    this.sourceVideoUrl,
    this.thumbUrl,
    this.ownerUid,
    this.status,
    this.createdAt,
    this.parentId,
  });

  /// Create DTO from Firestore document
  ///
  /// [data] - Document data from Firestore
  /// [id] - Document ID
  factory VideoResultDto.fromFirestore(Map<String, dynamic> data, String id) {
    return VideoResultDto(
      id: id,
      url: data['url'] as String? ?? '',
      duration: data['duration'] as int? ?? 0,
      params: data['params'] as String? ?? '',
      sourceVideoUrl: data['sourceVideoUrl'] as String?,
      thumbUrl: data['thumbUrl'] as String?,
      ownerUid: data['ownerUid'] as String?,
      status: data['status'] as String?,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : null,
      parentId: data['parentId'] as String?,
    );
  }

  /// Convert DTO to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'duration': duration,
      'params': params,
      if (sourceVideoUrl != null) 'sourceVideoUrl': sourceVideoUrl,
      if (thumbUrl != null) 'thumbUrl': thumbUrl,
      if (ownerUid != null) 'ownerUid': ownerUid,
      if (status != null) 'status': status,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (parentId != null) 'parentId': parentId,
    };
  }

  /// Create a copy with modified fields
  VideoResultDto copyWith({
    String? id,
    String? url,
    int? duration,
    String? params,
    String? sourceVideoUrl,
    String? thumbUrl,
    String? ownerUid,
    String? status,
    DateTime? createdAt,
    String? parentId,
  }) {
    return VideoResultDto(
      id: id ?? this.id,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      params: params ?? this.params,
      sourceVideoUrl: sourceVideoUrl ?? this.sourceVideoUrl,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      ownerUid: ownerUid ?? this.ownerUid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  String toString() {
    return 'VideoResultDto(id: $id, url: $url, duration: $duration, '
        'params: $params, status: $status, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoResultDto &&
        other.id == id &&
        other.url == url &&
        other.duration == duration &&
        other.params == params &&
        other.sourceVideoUrl == sourceVideoUrl &&
        other.thumbUrl == thumbUrl &&
        other.ownerUid == ownerUid &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.parentId == parentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        url.hashCode ^
        duration.hashCode ^
        params.hashCode ^
        sourceVideoUrl.hashCode ^
        thumbUrl.hashCode ^
        ownerUid.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        parentId.hashCode;
  }
}
