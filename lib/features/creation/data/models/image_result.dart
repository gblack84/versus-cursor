import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_result.freezed.dart';

/// DTO for Image data transfer from Firestore
/// Replaces ImagesModel with pure data structure
///
/// This DTO eliminates DocumentReference dependency while preserving
/// all functionality including parentId tracking.
@freezed
sealed class ImageResult with _$ImageResult {
  const factory ImageResult({
    required String id,
    required String url,
    required int option,
    String? parentId, // Read directly from Firestore field
  }) = _ImageResult;

  /// Create DTO from Firestore document
  ///
  /// [data] - Document data from Firestore
  /// [id] - Document ID
  factory ImageResult.fromFirestore(Map<String, dynamic> data, String id) =>
      ImageResult(
        id: id,
        url: data['url'] as String? ?? '',
        option: data['option'] as int? ?? 0,
        parentId: data['parentId'] as String?,
      );
}

/// Extension for Firestore serialization
extension ImageResultFirestore on ImageResult {
  /// Convert DTO to Firestore document data
  Map<String, dynamic> toFirestore() => {
        'url': url,
        'option': option,
        if (parentId != null) 'parentId': parentId,
      };
}
