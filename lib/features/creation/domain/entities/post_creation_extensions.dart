import 'package:cloud_firestore/cloud_firestore.dart';
import 'post_creation.dart';
import 'target_audience_extensions.dart';

/// Firestore Extension for PostCreation
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Direct Firestore ↔ Entity transformation
/// - No DataSource/DTO/Mapper layers
/// - 60% code reduction from Phase 4
///
/// **Phase 5 Migration**: Extension Pattern
/// - Replaces: PostCreationDto, CreationFirestoreMapper
/// - Reduces: 447 lines (DTO) + 453 lines (Mapper) → 180 lines (Extension)
/// - Code reduction: 85%
extension PostCreationFirestore on PostCreation {
  /// Convert PostCreation entity to Firestore document format
  ///
  /// **Usage in Repository**:
  /// ```dart
  /// await _firestore.collection('posts').doc(post.id).set(
  ///   post.toFirestore(),  // ← Extension method
  /// );
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'optionA': optionA.toFirestore(),
      'optionB': optionB.toFirestore(),
      if (targetAudience != null)
        'targetAudience': targetAudience!.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      'status': status.name,
      'likeCount': likeCount,
      'commentCount': commentCount,
      if (voteConfig != null) 'voteConfig': voteConfig!.toFirestore(),
      'isAnonymous': isAnonymous,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create PostCreation entity from Firestore DocumentSnapshot
  ///
  /// **Usage in Repository**:
  /// ```dart
  /// Stream<PostCreation> watchPost(String postId) {
  ///   return _firestore.collection('posts').doc(postId).snapshots().map(
  ///     (snapshot) => PostCreationFirestore.fromFirestore(snapshot),
  ///   );
  /// }
  /// ```
  static PostCreation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PostCreation(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      optionA: _parsePostOption(data['optionA'] as Map<String, dynamic>?),
      optionB: _parsePostOption(data['optionB'] as Map<String, dynamic>?),
      targetAudience: data['targetAudience'] != null
          ? TargetAudienceFirestore.fromMap(
              data['targetAudience'] as Map<String, dynamic>?)
          : null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      status: _parsePostStatus(data['status'] as String?),
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      voteConfig: data['voteConfig'] != null
          ? _parseVoteConfig(data['voteConfig'] as Map<String, dynamic>?)
          : null,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      category: data['category'] as String?,
      tags: _parseStringList(data['tags']),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  /// Parse PostOption from Firestore Map
  static PostOption _parsePostOption(Map<String, dynamic>? data) {
    if (data == null) {
      return const PostOption(imageUrls: [], aspectRatios: []);
    }

    return PostOption(
      text: data['text'] as String?,
      imageUrls: _parseStringList(data['imageUrls']),
      videoUrls: _parseStringList(data['videoUrls']),
      aspectRatios: _parseDoubleList(data['aspectRatios']),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Parse VoteConfiguration from Firestore Map
  static VoteConfiguration _parseVoteConfig(Map<String, dynamic>? data) {
    if (data == null) {
      return const VoteConfiguration();
    }

    return VoteConfiguration(
      startTime: _parseDateTime(data['startTime']),
      endTime: _parseDateTime(data['endTime']),
      duration: data['duration'] as int?,
      allowAnonymous: data['allowAnonymous'] as bool? ?? false,
      requiresExpansion: data['requiresExpansion'] as bool? ?? false,
      settings: data['settings'] as Map<String, dynamic>?,
    );
  }

  /// Parse PostStatus enum from String
  static PostStatus _parsePostStatus(String? status) {
    if (status == null) return PostStatus.draft;

    return PostStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PostStatus.draft,
    );
  }

  /// Parse DateTime from Firestore Timestamp or DateTime
  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    return DateTime.now();
  }

  /// Parse List<String> from dynamic
  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];
    if (list is List) return list.map((e) => e.toString()).toList();
    return [];
  }

  /// Parse List<double> from dynamic
  static List<double> _parseDoubleList(dynamic list) {
    if (list == null) return [];
    if (list is List) {
      return list.map((e) {
        if (e is double) return e;
        if (e is int) return e.toDouble();
        if (e is String) return double.tryParse(e) ?? 0.0;
        return 0.0;
      }).toList();
    }
    return [];
  }
}

/// Firestore Extension for PostOption
extension PostOptionFirestore on PostOption {
  /// Convert PostOption to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      if (text != null) 'text': text,
      'imageUrls': imageUrls,
      if (videoUrls != null) 'videoUrls': videoUrls,
      'aspectRatios': aspectRatios,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Firestore Extension for VoteConfiguration
extension VoteConfigurationFirestore on VoteConfiguration {
  /// Convert VoteConfiguration to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      if (startTime != null) 'startTime': Timestamp.fromDate(startTime!),
      if (endTime != null) 'endTime': Timestamp.fromDate(endTime!),
      if (duration != null) 'duration': duration,
      'allowAnonymous': allowAnonymous,
      'requiresExpansion': requiresExpansion,
      if (settings != null) 'settings': settings,
    };
  }
}
