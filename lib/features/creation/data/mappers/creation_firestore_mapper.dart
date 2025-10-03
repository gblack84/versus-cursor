import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/core/post_core.dart';
import '../../domain/models/core/post_content.dart';
import '../../domain/models/value_objects/media_content.dart';

/// CreationFirestoreMapper - Handles Firebase ↔ Domain model conversion for Creation Feature
///
/// This mapper is responsible for converting between Firebase Firestore documents
/// and Creation Feature's domain models (PostCore and PostContent).
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

  /// Extracts PostCore from Firestore document data
  ///
  /// Converts Firebase document fields into PostCore domain model.
  /// Only extracts fields that belong to Creation Feature's responsibility.
  PostCore extractPostCore(Map<String, dynamic> data, String postId) {
    return PostCore(
      id: postId,
      // Legacy field name: questionTitle (not title)
      questionTitle: data['questionTitle'] ?? '',
      description: data['description']?.toString().isNotEmpty == true
          ? data['description']
          : null,
      content: data['content']?.toString().isNotEmpty == true
          ? data['content']
          : null,
      // Handle both 'userid' and 'uid' for backward compatibility
      userId: data['userid']?.toString() ?? data['uid']?.toString() ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(data['updatedAt']),
      category: data['category']?.toString().isNotEmpty == true
          ? data['category']
          : null,
      tags: _parseTags(data['tags']),
      visibility: _convertVisibilityToString(data['visibility']),
      isAnonymous: data['isAnonymous'] ?? false,
      premiumRequired: data['premiumRequired'] ?? false,
      // location is stored as Map<String, dynamic> in Firestore, convert to Map<String, double>
      location: data['location'] != null
          ? (data['location'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            )
          : null,
    );
  }

  /// Extracts PostContent from Firestore document data
  ///
  /// Converts Firebase document fields into PostContent domain model.
  /// Handles media content and layout information.
  PostContent extractPostContent(Map<String, dynamic> data, String postId) {
    return PostContent(
      postId: postId,
      // Media content for option A
      optionA: MediaContent.fromMap(data['optionA'] as Map<String, dynamic>? ?? {}),
      // Media content for option B
      optionB: MediaContent.fromMap(data['optionB'] as Map<String, dynamic>? ?? {}),
      layoutType: data['layoutType']?.toString() ?? 'vertical',
      targetAudience: data['targetAudience'] as Map<String, dynamic>?,
      moderation: data['moderation'] as Map<String, dynamic>?,
      processingStatus: data['processingStatus']?.toString() ?? 'completed',
      processedAt: _parseDateTime(data['processedAt']),
    );
  }

  // ============================================
  // Domain → Firebase Conversion (WRITE)
  // ============================================

  /// Creates a complete Firestore document for a new post
  ///
  /// Generates all necessary fields for post creation, including:
  /// - Creation Feature fields from PostCore and PostContent
  /// - Default values for fields managed by other features
  /// - Legacy compatibility fields
  Map<String, dynamic> toCreateDocument(PostCore core, PostContent content) {
    final Map<String, dynamic> document = {
      // ===== PostCore fields =====
      'questionTitle': core.questionTitle,
      'userid': core.userId,
      'uid': core.userId, // Legacy compatibility
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'tags': core.tags,
      'visibility': _convertVisibilityToInt(core.visibility),
      'isAnonymous': core.isAnonymous,
      'premiumRequired': core.premiumRequired,

      // ===== PostContent fields =====
      'optionA': content.optionA.toMap(),
      'optionB': content.optionB.toMap(),
      'layoutType': content.layoutType,
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
        'userid': core.userId,
        'uid': core.userId,
      },
    };

    // Add optional fields only if they have values
    if (core.description != null) {
      document['description'] = core.description;
    }
    if (core.content != null) {
      document['content'] = core.content;
    }
    if (core.category != null) {
      document['category'] = core.category;
    }
    if (core.location != null) {
      document['location'] = core.location;
    }
    if (content.targetAudience != null) {
      document['targetAudience'] = content.targetAudience;
    }
    if (content.moderation != null) {
      document['moderation'] = content.moderation;
    }

    return document;
  }

  /// Creates a partial update document for existing posts
  ///
  /// Only includes fields that are being updated, preserving
  /// existing values for fields not included in the update.
  Map<String, dynamic> toUpdateDocument({
    PostCore? core,
    PostContent? content,
  }) {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Update PostCore fields if provided
    if (core != null) {
      updates['questionTitle'] = core.questionTitle;
      updates['tags'] = core.tags;
      updates['visibility'] = _convertVisibilityToInt(core.visibility);
      updates['isAnonymous'] = core.isAnonymous;
      updates['premiumRequired'] = core.premiumRequired;

      // Handle optional fields
      if (core.description != null) {
        updates['description'] = core.description;
      } else {
        updates['description'] = FieldValue.delete();
      }

      if (core.content != null) {
        updates['content'] = core.content;
      } else {
        updates['content'] = FieldValue.delete();
      }

      if (core.category != null) {
        updates['category'] = core.category;
      } else {
        updates['category'] = FieldValue.delete();
      }

      if (core.location != null) {
        updates['location'] = core.location;
      } else {
        updates['location'] = FieldValue.delete();
      }
    }

    // Update PostContent fields if provided
    if (content != null) {
      updates['optionA'] = content.optionA.toMap();
      updates['optionB'] = content.optionB.toMap();
      updates['layoutType'] = content.layoutType;

      if (content.targetAudience != null) {
        updates['targetAudience'] = content.targetAudience;
      } else {
        updates['targetAudience'] = FieldValue.delete();
      }

      if (content.moderation != null) {
        updates['moderation'] = content.moderation;
      } else {
        updates['moderation'] = FieldValue.delete();
      }

      // processingStatus is always non-null
      updates['processingStatus'] = content.processingStatus;
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
  // Helper Methods
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

  /// Converts visibility from int to string
  String _convertVisibilityToString(dynamic value) {
    if (value == null) return 'public';

    if (value is String) return value;

    if (value is int) {
      switch (value) {
        case 0:
          return 'public';
        case 1:
          return 'friends';
        case 2:
          return 'private';
        default:
          return 'public';
      }
    }

    return 'public';
  }

  /// Converts visibility from string to int
  int _convertVisibilityToInt(String? visibility) {
    switch (visibility) {
      case 'public':
        return 0;
      case 'friends':
        return 1;
      case 'private':
        return 2;
      default:
        return 0;
    }
  }
}