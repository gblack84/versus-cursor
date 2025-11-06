import 'package:cloud_firestore/cloud_firestore.dart';
import 'media_info.dart';

/// Firestore Extension for MediaInfo (Sealed Class)
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Direct Firestore ↔ Sealed Class transformation
/// - Type discrimination via 'type' field ('image' | 'video')
/// - when() pattern matching for type-safe conversion
///
/// **Phase 5 Migration**: Extension Pattern for Sealed Classes
/// - Replaces: ImageResultDto, VideoResultDto, MediaInfoMapper
/// - Reduces: 167 lines (DTO) + 89 lines (Mapper) → 120 lines (Extension)
/// - Code reduction: 53%
/// - **Preserves fields lost in DTO**: width, height, aspectRatio
extension MediaInfoFirestore on MediaInfo {
  /// Convert MediaInfo (Sealed Class) to Firestore document format
  ///
  /// **Usage in Repository**:
  /// ```dart
  /// final imageInfo = MediaInfo.image(id: '123', url: 'https://...');
  /// await _firestore.collection('media').doc(imageInfo.id).set(
  ///   imageInfo.toFirestore(),  // ← Extension method
  /// );
  /// ```
  ///
  /// **Pattern Matching**: Uses when() to handle Image vs Video
  Map<String, dynamic> toFirestore() {
    return when(
      image: (id, url, parentId, aspectRatio, width, height, size, mimeType,
          createdAt, thumbnailUrl, metadata) {
        return {
          'id': id,
          'type': 'image', // ← Discriminator field
          'url': url,
          if (parentId != null) 'parentId': parentId,
          if (aspectRatio != null) 'aspectRatio': aspectRatio,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
          if (size != null) 'size': size,
          if (mimeType != null) 'mimeType': mimeType,
          if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt),
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (metadata != null) 'metadata': metadata,
        };
      },
      video: (id, url, parentId, width, height, duration, size, mimeType,
          createdAt, thumbnailUrl, aspectRatio, metadata) {
        return {
          'id': id,
          'type': 'video', // ← Discriminator field
          'url': url,
          if (parentId != null) 'parentId': parentId,
          if (width != null) 'width': width,
          if (height != null) 'height': height,
          if (duration != null) 'duration': duration,
          if (size != null) 'size': size,
          if (mimeType != null) 'mimeType': mimeType,
          if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt),
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (aspectRatio != null) 'aspectRatio': aspectRatio,
          if (metadata != null) 'metadata': metadata,
        };
      },
    );
  }

  /// Create MediaInfo (Sealed Class) from Firestore Map
  ///
  /// **Usage in Repository**:
  /// ```dart
  /// Stream<List<MediaInfo>> watchImages(String parentId) {
  ///   return _firestore
  ///     .collection('media')
  ///     .where('type', isEqualTo: 'image')
  ///     .snapshots()
  ///     .map((snapshot) => snapshot.docs
  ///       .map((doc) => MediaInfoFirestore.fromFirestore(doc.data()))
  ///       .whereType<ImageInfo>()  // ← Sealed Class filter
  ///       .toList()
  ///     );
  /// }
  /// ```
  ///
  /// **Type Discrimination**: Checks 'type' field to create ImageInfo or VideoInfo
  static MediaInfo fromFirestore(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    if (type == 'video') {
      return MediaInfo.video(
        id: data['id'] as String? ?? '',
        url: data['url'] as String? ?? '',
        parentId: data['parentId'] as String?,
        width: _parseDouble(data['width']),
        height: _parseDouble(data['height']),
        duration: _parseDouble(data['duration']),
        size: _parseInt(data['size']),
        mimeType: data['mimeType'] as String?,
        createdAt: _parseDateTime(data['createdAt']),
        thumbnailUrl: data['thumbnailUrl'] as String?,
        aspectRatio: _parseDouble(data['aspectRatio']),
        metadata: data['metadata'] as Map<String, dynamic>?,
      );
    }

    // Default: image
    return MediaInfo.image(
      id: data['id'] as String? ?? '',
      url: data['url'] as String? ?? '',
      parentId: data['parentId'] as String?,
      aspectRatio: _parseDouble(data['aspectRatio']),
      width: _parseDouble(data['width']),
      height: _parseDouble(data['height']),
      size: _parseInt(data['size']),
      mimeType: data['mimeType'] as String?,
      createdAt: _parseDateTime(data['createdAt']),
      thumbnailUrl: data['thumbnailUrl'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// Parse DateTime from Firestore Timestamp or DateTime
  static DateTime? _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return null;
  }

  /// Parse double from dynamic (handles int, double, String)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Parse int from dynamic (handles int, double, String)
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
