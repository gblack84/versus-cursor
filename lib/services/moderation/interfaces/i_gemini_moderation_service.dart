import '../models/moderation_result.dart';

/// Port interface for Gemini Moderation Service
///
/// Provides Gemini AI-based content validation via Cloud Functions:
/// - Content logic validation
/// - Context analysis
/// - Expected vote ratio prediction
///
/// **Port-Adapter Pattern**:
/// - This is the Port (interface/contract)
/// - GeminiModerationService is the Adapter (implementation)
///
/// **Benefits**:
/// - Dependency Inversion: Domain depends on interface, not implementation
/// - Testability: Easy to create mock implementations
/// - Flexibility: Can swap implementations at runtime
abstract class IGeminiModerationService {
  /// Initialize Gemini service (if needed)
  ///
  /// Currently no-op as Cloud Functions handle initialization
  void initialize();

  /// Validate post content with Gemini AI via Cloud Functions
  ///
  /// Performs comprehensive content validation:
  /// - Logic consistency check
  /// - Context appropriateness analysis
  /// - Expected vote ratio prediction (A vs B)
  ///
  /// **Parameters**:
  /// - [userId]: User ID for tracking
  /// - [questionTitle]: Main question text
  /// - [description]: Optional description text
  /// - [titleA]: Option A title
  /// - [titleB]: Option B title
  /// - [imageUrlA]: Option A image URL
  /// - [imageUrlB]: Option B image URL
  /// - [visionDataA]: Vision API results for image A
  /// - [visionDataB]: Vision API results for image B
  /// - [perspectiveScores]: Perspective API toxicity scores
  /// - [sessionId]: Session tracking ID
  /// - [documentId]: Document ID for revision tracking
  /// - [revisionCount]: Revision attempt count
  ///
  /// **Returns**: Gemini moderation result with validation status and suggestions
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<IGeminiModerationService>();
  /// final result = await service.validateContent(
  ///   userId: 'user123',
  ///   questionTitle: '어떤 영화가 더 재미있나요?',
  ///   titleA: '어벤져스',
  ///   titleB: '인터스텔라',
  /// );
  ///
  /// if (result?.isValid ?? false) {
  ///   print('Gemini AI 검증 통과');
  ///   print('예상 투표 비율: A=${result!.expectedRatioA}, B=${result.expectedRatioB}');
  /// } else {
  ///   print('Gemini AI 검증 실패: ${result?.reason}');
  /// }
  /// ```
  Future<GeminiModerationResult?> validateContent({
    required String userId,
    required String? questionTitle,
    required String? description,
    required String? titleA,
    required String? titleB,
    String? imageUrlA,
    String? imageUrlB,
    Map<String, dynamic>? visionDataA,
    Map<String, dynamic>? visionDataB,
    Map<String, double>? perspectiveScores,
    String? sessionId,
    String? documentId,
    int? revisionCount,
  });
}
