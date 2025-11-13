import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'video_encoding.freezed.dart';
part 'video_encoding.g.dart';

/// Video encoding status tracking
///
/// Tracks the status of video encoding processes for Media Service.
/// Used for future video upload feature implementation.
/// Stored in Firestore 'encodings' collection.
@freezed
sealed class VideoEncoding with _$VideoEncoding {
  const VideoEncoding._();

  const factory VideoEncoding({
    required String id,
    required String videoId,
    required String status,
    @Default(0.0) double progress,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? outputUrl,
    String? errorMessage,
  }) = _VideoEncoding;

  factory VideoEncoding.fromJson(Map<String, dynamic> json) =>
      _$VideoEncodingFromJson(json);

  /// Firestore → Entity
  ///
  /// Converts Firestore DocumentSnapshot to VideoEncoding entity.
  /// Uses document ID as id field.
  factory VideoEncoding.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return VideoEncoding(
      id: doc.id,
      videoId: data['videoId'] as String? ?? '',
      status: data['status'] as String? ?? '',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      outputUrl: data['outputUrl'] as String?,
      errorMessage: data['errorMessage'] as String?,
    );
  }

  /// Entity → Firestore
  ///
  /// Converts VideoEncoding entity to Firestore-compatible Map.
  /// Omits id as it's stored as document ID.
  Map<String, dynamic> toFirestore() {
    return {
      'videoId': videoId,
      'status': status,
      'progress': progress,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (outputUrl != null) 'outputUrl': outputUrl,
      if (errorMessage != null) 'errorMessage': errorMessage,
    };
  }

  /// Business logic: Check if encoding is completed
  bool get isCompleted => status == 'completed';

  /// Business logic: Check if encoding failed
  bool get isFailed => status == 'failed';

  /// Business logic: Check if encoding is processing
  bool get isProcessing => status == 'processing';

  /// Business logic: Check if encoding is pending
  bool get isPending => status == 'pending';
}
