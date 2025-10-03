import '../value_objects/media_content.dart';

/// PostContent Domain Model
/// Clean Architecture - Domain Layer Entity
///
/// Manages A vs B content structure for Versus posts.
/// Wraps MediaContent objects and provides content-specific
/// business logic and validation.
class PostContent {
  const PostContent({
    required this.postId,
    required this.optionA,
    required this.optionB,
    this.layoutType = 'vertical',
    this.targetAudience,
    this.moderation,
    this.thumbnails = const {},
    this.processingStatus = 'pending',
    this.processedAt,
  });

  // Core Fields
  final String postId; // Foreign key to PostCore.id

  // A vs B Content
  final MediaContent optionA;
  final MediaContent optionB;

  // Layout Configuration
  final String layoutType; // 'horizontal', 'vertical', 'single'

  // Metadata
  final Map<String, dynamic>? targetAudience; // AI targeting data
  final Map<String, dynamic>? moderation; // Content moderation results
  final Map<String, String> thumbnails; // Thumbnail URLs for quick preview

  // Processing Status
  final String
      processingStatus; // 'pending', 'processing', 'completed', 'failed'
  final DateTime? processedAt;

  /// Check if this is single option mode (no B option)
  bool get isSingleOption => optionB.isEmpty;

  /// Check if this has dual options
  bool get hasDualOptions => !isSingleOption;

  /// Check if content is ready for voting
  bool get isReadyForVoting {
    if (isSingleOption) {
      return optionA.hasContent && processingStatus == 'completed';
    }
    return optionA.hasContent &&
        optionB.hasContent &&
        processingStatus == 'completed';
  }

  /// Get the dominant media type
  String get dominantMediaType {
    if (optionA.mediaType == optionB.mediaType) {
      return optionA.mediaType;
    }
    // Mixed media types
    if (optionA.hasImages || optionB.hasImages) return 'image';
    if (optionA.hasVideo || optionB.hasVideo) return 'video';
    return 'text';
  }

  /// Calculate aspect ratio difference
  double get aspectRatioDifference {
    final ratioA = optionA.aspectRatio ?? 1.0;
    final ratioB = optionB.aspectRatio ?? 1.0;
    return (ratioA - ratioB).abs();
  }

  /// Determine optimal layout based on content
  String calculateOptimalLayout() {
    if (isSingleOption) return 'single';

    // Use aspect ratios for smart layout
    final ratioA = optionA.aspectRatio;
    final ratioB = optionB.aspectRatio;

    if (ratioA != null && ratioB != null) {
      // Both portrait images (aspect < 1)
      if (ratioA < 1.0 && ratioB < 1.0) {
        return 'horizontal'; // Side by side
      }
      // Both landscape images (aspect > 1.5)
      if (ratioA > 1.5 && ratioB > 1.5) {
        return 'vertical'; // Stack vertically
      }
    }

    // Default based on media type
    if (dominantMediaType == 'text') return 'vertical';
    return layoutType; // Use provided layout
  }

  /// Create from Firestore data
  factory PostContent.fromMap(Map<String, dynamic> data, String postId) {
    return PostContent(
      postId: postId,
      optionA: MediaContent.fromMap(data['optionA'] ?? {}),
      optionB: MediaContent.fromMap(data['optionB'] ?? {}),
      layoutType: data['layoutType'] ?? 'vertical',
      targetAudience: data['targetAudience'],
      moderation: data['moderation'],
      thumbnails: Map<String, String>.from(data['thumbnails'] ?? {}),
      processingStatus: data['processingStatus'] ?? 'pending',
      processedAt: data['processedAt']?.toDate(),
    );
  }

  /// Create from JSON (for caching)
  factory PostContent.fromJson(Map<String, dynamic> json) {
    return PostContent(
      postId: json['postId'] ?? '',
      optionA: MediaContent.fromJson(json['optionA'] ?? {}),
      optionB: MediaContent.fromJson(json['optionB'] ?? {}),
      layoutType: json['layoutType'] ?? 'vertical',
      targetAudience: json['targetAudience'],
      moderation: json['moderation'],
      thumbnails: Map<String, String>.from(json['thumbnails'] ?? {}),
      processingStatus: json['processingStatus'] ?? 'pending',
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'optionA': optionA.toMap(),
      'optionB': optionB.toMap(),
      'layoutType': layoutType,
      if (targetAudience != null) 'targetAudience': targetAudience,
      if (moderation != null) 'moderation': moderation,
      if (thumbnails.isNotEmpty) 'thumbnails': thumbnails,
      'processingStatus': processingStatus,
      if (processedAt != null) 'processedAt': processedAt,
    };
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'optionA': optionA.toJson(),
      'optionB': optionB.toJson(),
      'layoutType': layoutType,
      if (targetAudience != null) 'targetAudience': targetAudience,
      if (moderation != null) 'moderation': moderation,
      'thumbnails': thumbnails,
      'processingStatus': processingStatus,
      if (processedAt != null) 'processedAt': processedAt!.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PostContent copyWith({
    String? postId,
    MediaContent? optionA,
    MediaContent? optionB,
    String? layoutType,
    Map<String, dynamic>? targetAudience,
    Map<String, dynamic>? moderation,
    Map<String, String>? thumbnails,
    String? processingStatus,
    DateTime? processedAt,
  }) {
    return PostContent(
      postId: postId ?? this.postId,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      layoutType: layoutType ?? this.layoutType,
      targetAudience: targetAudience ?? this.targetAudience,
      moderation: moderation ?? this.moderation,
      thumbnails: thumbnails ?? this.thumbnails,
      processingStatus: processingStatus ?? this.processingStatus,
      processedAt: processedAt ?? this.processedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostContent && other.postId == postId;
  }

  @override
  int get hashCode => postId.hashCode;

  @override
  String toString() {
    return 'PostContent(postId: $postId, layout: $layoutType, status: $processingStatus)';
  }
}

/// Content validation helper
class PostContentValidator {
  static ValidationResult validate(PostContent content) {
    // Ensure option A has content
    if (!content.optionA.hasContent) {
      return ValidationResult(
        isValid: false,
        error: 'Option A is required',
      );
    }

    // For dual mode, ensure option B has content
    if (!content.isSingleOption && !content.optionB.hasContent) {
      return ValidationResult(
        isValid: false,
        error: 'Option B is required in dual mode',
      );
    }

    // Warn about mixed media types
    if (content.optionA.mediaType != content.optionB.mediaType) {
      return ValidationResult(
        isValid: true,
        warning: 'Different media types may affect layout',
      );
    }

    return ValidationResult(isValid: true);
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? error;
  final String? warning;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.warning,
  });
}
