import 'dart:io';

/// Port Interface for Image Moderation Service
///
/// Clean Architecture - Domain layer interface (Port)
/// Implemented by ImageModerationService in Services layer (Adapter)
///
/// Responsibilities:
/// - Image content moderation via Cloud Vision API
/// - Inappropriate content detection (violence, adult, etc.)
/// - AI-based safety analysis
///
/// Pattern: Port-Adapter (Hexagonal Architecture)
abstract class IImageModerationService {
  /// Check image for inappropriate content
  ///
  /// Uses Cloud Vision API to analyze image content for:
  /// - Adult content
  /// - Violence
  /// - Racy content
  /// - Other inappropriate material
  ///
  /// Returns [ModerationResult] with isAppropriate flag and reason
  ///
  /// Example:
  /// ```dart
  /// final result = await moderationService.checkImage(
  ///   imageFile: File('path/to/image.jpg'),
  ///   box: 'optionA',
  /// );
  ///
  /// if (!result.isAppropriate) {
  ///   print('Image rejected: ${result.reason}');
  /// }
  /// ```
  Future<ModerationResult> checkImage({
    required File imageFile,
    required String box,
  });
}

/// Moderation result from AI analysis
///
/// Contains the result of image content moderation
class ModerationResult {
  /// Whether the image is appropriate for display
  final bool isAppropriate;

  /// Reason for rejection (if isAppropriate is false)
  final String reason;

  /// Whether the image contains text (OCR detection)
  final bool hasText;

  /// Additional details from the moderation service
  ///
  /// May include:
  /// - Confidence scores
  /// - Detected categories
  /// - API response metadata
  final Map<String, dynamic>? details;

  ModerationResult({
    required this.isAppropriate,
    required this.reason,
    this.hasText = false,
    this.details,
  });

  /// Create a passing moderation result
  factory ModerationResult.pass({bool hasText = false}) {
    return ModerationResult(
      isAppropriate: true,
      reason: '',
      hasText: hasText,
      details: null,
    );
  }

  /// Create a failing moderation result
  factory ModerationResult.fail(
    String reason, {
    bool hasText = false,
    Map<String, dynamic>? details,
  }) {
    return ModerationResult(
      isAppropriate: false,
      reason: reason,
      hasText: hasText,
      details: details,
    );
  }

  @override
  String toString() {
    return 'ModerationResult(isAppropriate: $isAppropriate, reason: $reason, hasText: $hasText)';
  }
}
