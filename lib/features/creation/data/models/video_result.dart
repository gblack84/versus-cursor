import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_result.freezed.dart';

/// DTO for Video data transfer from Firestore
/// Replaces VideoModel with pure data structure
///
/// This DTO eliminates DocumentReference dependency while preserving
/// all functionality including parentId and encoding status tracking.
@freezed
sealed class VideoResult with _$VideoResult {
  const factory VideoResult({
    required String id,
    required String url,
    required int duration,
    required String params,
    String? sourceVideoUrl,
    String? thumbUrl,
    String? ownerUid,
    String? status,
    DateTime? createdAt,
    String? parentId, // Read directly from Firestore field
  }) = _VideoResult;

  /// Create DTO from Firestore document
  ///
  /// [data] - Document data from Firestore
  /// [id] - Document ID
  factory VideoResult.fromFirestore(Map<String, dynamic> data, String id) {
    return VideoResult(
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
}

/// Extension for Firestore serialization
extension VideoResultFirestore on VideoResult {
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
}
