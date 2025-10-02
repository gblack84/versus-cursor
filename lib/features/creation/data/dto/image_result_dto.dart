/// DTO for Image data transfer from Firestore
/// Replaces ImagesModel with pure data structure
///
/// This DTO eliminates DocumentReference dependency while preserving
/// all functionality including parentId tracking.
class ImageResultDto {
  final String id;
  final String url;
  final int option;
  final String? parentId; // Read directly from Firestore field

  const ImageResultDto({
    required this.id,
    required this.url,
    required this.option,
    this.parentId,
  });

  /// Create DTO from Firestore document
  ///
  /// [data] - Document data from Firestore
  /// [id] - Document ID
  factory ImageResultDto.fromFirestore(Map<String, dynamic> data, String id) {
    return ImageResultDto(
      id: id,
      url: data['url'] as String? ?? '',
      option: data['option'] as int? ?? 0,
      parentId: data['parentId'] as String?,
    );
  }

  /// Convert DTO to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'url': url,
      'option': option,
      if (parentId != null) 'parentId': parentId,
    };
  }

  /// Create a copy with modified fields
  ImageResultDto copyWith({
    String? id,
    String? url,
    int? option,
    String? parentId,
  }) {
    return ImageResultDto(
      id: id ?? this.id,
      url: url ?? this.url,
      option: option ?? this.option,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  String toString() {
    return 'ImageResultDto(id: $id, url: $url, option: $option, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageResultDto &&
        other.id == id &&
        other.url == url &&
        other.option == option &&
        other.parentId == parentId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ url.hashCode ^ option.hashCode ^ parentId.hashCode;
  }
}
