import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/aggregates/post_creation.dart';
import '../../domain/models/value_objects/media_content.dart';
import '../../domain/models/value_objects/target_audience.dart';

/// CreationFirestoreMapper - Handles Firebase ↔ Domain model conversion for Creation Feature
///
/// This mapper is responsible for converting between Firebase Firestore documents
/// and Creation Feature's domain model (PostCreation).
///
/// **Phase 2 Migration**: PostCore/PostContent 제거, PostCreation 직접 사용
/// - 447줄 제거 (PostCore 203줄 + PostContent 244줄)
/// - 단순화된 플로우: PostCreation ↔ Firestore
/// - MediaContent는 Firestore DTO로 유지
///
/// Key principles:
/// - Only handles fields that Creation Feature is responsible for
/// - Maintains backward compatibility with legacy field names
/// - Preserves fields from other features without modification
/// - Supports both full document creation and partial updates
class CreationFirestoreMapper {
  // ============================================
  // Firebase → Domain Conversion (READ)
  // ============================================

  /// Extracts PostCreation from Firestore document data
  ///
  /// Converts Firebase document fields into PostCreation domain model.
  /// Only extracts fields that belong to Creation Feature's responsibility.
  PostCreation extractPostCreation(Map<String, dynamic> data, String postId) {
    return PostCreation(
      id: postId,
      // Legacy field name: questionTitle (not title)
      title: data['questionTitle'] ?? '',
      description: data['description'] ?? '',
      // Handle both 'userid' and 'uid' for backward compatibility
      userId: data['userid']?.toString() ?? data['uid']?.toString() ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']),
      category: data['category']?.toString(),
      tags: _parseTags(data['tags']),
      isAnonymous: data['isAnonymous'] ?? false,

      // Convert MediaContent to PostOption
      optionA: _mediaContentToPostOption(
        MediaContent.fromMap(data['optionA'] as Map<String, dynamic>? ?? {}),
      ),
      optionB: _mediaContentToPostOption(
        MediaContent.fromMap(data['optionB'] as Map<String, dynamic>? ?? {}),
      ),

      // TargetAudience
      targetAudience: data['targetAudience'] != null
          ? TargetAudience.fromMap(data['targetAudience'] as Map<String, dynamic>)
          : null,

      // VoteConfiguration
      voteConfig: data['voteConfig'] != null
          ? VoteConfiguration.fromJson(data['voteConfig'] as Map<String, dynamic>)
          : null,

      // PostStatus from string
      status: _parsePostStatus(data['status']),

      // Metrics (default values, will be updated by other features)
      likeCount: data['likecount'] ?? 0,
      commentCount: data['commentcount'] ?? 0,

      // Metadata
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // ============================================
  // Domain → Firebase Conversion (WRITE)
  // ============================================

  /// Creates a complete Firestore document for a new post
  ///
  /// Generates all necessary fields for post creation, including:
  /// - Creation Feature fields from PostCreation
  /// - Default values for fields managed by other features
  /// - Legacy compatibility fields
  Map<String, dynamic> toCreateDocument(PostCreation post) {
    final Map<String, dynamic> document = {
      // ===== PostCreation fields =====
      'questionTitle': post.title,
      'description': post.description,
      'userid': post.userId,
      'uid': post.userId, // Legacy compatibility
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'tags': post.tags ?? [],
      'isAnonymous': post.isAnonymous,
      'status': post.status.name,

      // ===== Media Content (PostOption → MediaContent) =====
      'optionA': _postOptionToMediaContent(post.optionA).toMap(),
      'optionB': _postOptionToMediaContent(post.optionB).toMap(),
      'layoutType': 'vertical', // Default layout
      'processingStatus': 'pending',

      // ===== Default values for other features =====
      // These will be updated by their respective features
      'votesA': 0,
      'votesB': 0,
      'voteStatus': 'pending',
      'voteCompleted': false,
      'commentcount': 0,
      'likecount': 0,
      'sherecount': 0, // Note: legacy typo preserved
      'savecount': 0,
      'reportCount': 0,
      'participantcount': 0,
      'interestcount': 0,

      // ===== Legacy user info (for backward compatibility) =====
      'email': '',
      'displayName': '',
      'photoUrl': '',
      'phoneNumber': '',
      'createdTime': FieldValue.serverTimestamp(),
      'creatorInfo': {
        'userid': post.userId,
        'uid': post.userId,
      },
    };

    // Add optional fields only if they have values
    if (post.category != null) {
      document['category'] = post.category;
    }
    if (post.targetAudience != null) {
      document['targetAudience'] = post.targetAudience!.toMap();
    }
    if (post.voteConfig != null) {
      document['voteConfig'] = post.voteConfig!.toJson();
    }
    if (post.metadata != null) {
      document['metadata'] = post.metadata;
    }

    return document;
  }

  /// Creates a partial update document for existing posts
  ///
  /// Only includes fields that are being updated, preserving
  /// existing values for fields not included in the update.
  Map<String, dynamic> toUpdateDocument(PostCreation post) {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
      'questionTitle': post.title,
      'description': post.description,
      'tags': post.tags ?? [],
      'isAnonymous': post.isAnonymous,
      'status': post.status.name,

      // Media content updates
      'optionA': _postOptionToMediaContent(post.optionA).toMap(),
      'optionB': _postOptionToMediaContent(post.optionB).toMap(),
    };

    // Optional fields
    if (post.category != null) {
      updates['category'] = post.category;
    } else {
      updates['category'] = FieldValue.delete();
    }

    if (post.targetAudience != null) {
      updates['targetAudience'] = post.targetAudience!.toMap();
    } else {
      updates['targetAudience'] = FieldValue.delete();
    }

    if (post.voteConfig != null) {
      updates['voteConfig'] = post.voteConfig!.toJson();
    } else {
      updates['voteConfig'] = FieldValue.delete();
    }

    if (post.metadata != null) {
      updates['metadata'] = post.metadata;
    } else {
      updates['metadata'] = FieldValue.delete();
    }

    return updates;
  }

  /// Merges updates with existing document data
  ///
  /// Useful for ensuring all required fields are present when
  /// performing partial updates. Preserves fields from other features.
  Map<String, dynamic> mergeWithExisting(
    Map<String, dynamic> existing,
    Map<String, dynamic> updates,
  ) {
    final Map<String, dynamic> merged = Map<String, dynamic>.from(existing);

    updates.forEach((key, value) {
      if (value == FieldValue.delete()) {
        merged.remove(key);
      } else {
        merged[key] = value;
      }
    });

    return merged;
  }

  // ============================================
  // Conversion Helper Methods
  // ============================================

  /// Converts PostOption (domain) to MediaContent (Firestore DTO)
  MediaContent _postOptionToMediaContent(PostOption option) {
    return MediaContent(
      text: option.text ?? '',
      imageUrls: option.imageUrls,
      videoUrl: option.videoUrls?.isNotEmpty == true ? option.videoUrls!.first : '',
      aspectRatio: option.aspectRatios.isNotEmpty ? option.aspectRatios.first : null,
      aspectRatios: option.aspectRatios,
      // Note: metadata from PostOption is stored in dimensions field
      dimensions: option.metadata ?? {},
    );
  }

  /// Converts MediaContent (Firestore DTO) to PostOption (domain)
  PostOption _mediaContentToPostOption(MediaContent media) {
    return PostOption(
      text: media.text.isNotEmpty ? media.text : null,
      imageUrls: media.imageUrls,
      videoUrls: media.videoUrl.isNotEmpty ? [media.videoUrl] : null,
      aspectRatios: media.aspectRatios,
      // Note: dimensions field maps to PostOption metadata
      metadata: media.dimensions,
    );
  }

  // ============================================
  // Parsing Helper Methods
  // ============================================

  /// Parses various date/time formats into DateTime
  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  /// Parses tags from various formats
  List<String> _parseTags(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    return [];
  }

  /// Parses PostStatus from string
  PostStatus _parsePostStatus(dynamic value) {
    if (value == null) return PostStatus.draft;

    final statusStr = value.toString().toLowerCase();
    switch (statusStr) {
      case 'published':
        return PostStatus.published;
      case 'voting':
        return PostStatus.voting;
      case 'completed':
        return PostStatus.completed;
      case 'archived':
        return PostStatus.archived;
      case 'deleted':
        return PostStatus.deleted;
      default:
        return PostStatus.draft;
    }
  }
}
