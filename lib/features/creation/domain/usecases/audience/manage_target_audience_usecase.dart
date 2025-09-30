import '../../core/result.dart';
import ../../failures/creation_failures.dart';
import '../../models/target_audience.dart';
import '../../services/i_target_audience_service.dart';

/// UseCase for managing target audience
///
/// This UseCase wraps the TargetAudienceService to provide a clean interface
/// for the Presentation layer, following Clean Architecture principles.
class ManageTargetAudienceUseCase {
  final ITargetAudienceService _targetAudienceService;

  ManageTargetAudienceUseCase({
    required ITargetAudienceService targetAudienceService,
  }) : _targetAudienceService = targetAudienceService;

  /// Create and validate a target audience configuration
  Future<Result<TargetAudience>> createTargetAudience({
    required String mode,
    required int targetCount,
    int? minAge,
    int? maxAge,
    String? gender,
    List<String>? interests,
    List<String>? jobCategories,
    bool isPremium = false,
  }) async {
    try {
      // Create target audience model
      final targetAudience = TargetAudience(
        mode: mode,
        targetCount: targetCount,
        ageMin: minAge,
        ageMax: maxAge,
        gender: gender,
        interests: interests ?? [],
        jobCategories: jobCategories ?? [],
        isPremium: isPremium,
        isActive: true,
        createdAt: DateTime.now(),
      );

      // Validate target audience
      final validationResult = validateTargetAudience(targetAudience);

      if (!validationResult.isValid) {
        return ResultFailure(
          ValidationFailure(
            validationResult.error ?? 'Invalid target audience configuration',
          ),
        );
      }

      return Success(targetAudience);
    } catch (error) {
      print('ManageTargetAudienceUseCase Error: $error');
      return ResultFailure(
        UnknownFailure('Failed to create target audience: $error'),
      );
    }
  }

  /// Validate a target audience configuration
  ValidationResult validateTargetAudience(TargetAudience targetAudience) {
    return _targetAudienceService.validateTargetAudience(targetAudience);
  }

  /// Convert target audience to Firestore format
  Map<String, dynamic> convertToFirestoreFormat(TargetAudience targetAudience) {
    return _targetAudienceService.convertModelToFirestore(targetAudience);
  }

  /// Get target audience recommendations based on post content
  Future<Result<TargetAudienceRecommendation>> getRecommendations({
    required String title,
    required String description,
    List<String>? imageTags,
  }) async {
    try {
      // Analyze content and generate recommendations
      final recommendations = await _analyzeContentForRecommendations(
        title: title,
        description: description,
        imageTags: imageTags,
      );

      return Success(recommendations);
    } catch (error) {
      print('GetRecommendations Error: $error');
      return ResultFailure(
        UnknownFailure('Failed to get recommendations: $error'),
      );
    }
  }

  /// Private method to analyze content and generate recommendations
  Future<TargetAudienceRecommendation> _analyzeContentForRecommendations({
    required String title,
    required String description,
    List<String>? imageTags,
  }) async {
    // Basic content analysis (can be enhanced with AI later)
    final combinedText = '$title $description ${imageTags?.join(' ') ?? ''}';
    final lowerText = combinedText.toLowerCase();

    // Determine recommended interests based on keywords
    final recommendedInterests = <String>[];

    if (lowerText.contains('fashion') ||
        lowerText.contains('style') ||
        lowerText.contains('outfit')) {
      recommendedInterests.add('fashion');
    }

    if (lowerText.contains('food') ||
        lowerText.contains('recipe') ||
        lowerText.contains('cooking')) {
      recommendedInterests.add('food');
    }

    if (lowerText.contains('tech') ||
        lowerText.contains('app') ||
        lowerText.contains('software')) {
      recommendedInterests.add('technology');
    }

    if (lowerText.contains('travel') ||
        lowerText.contains('trip') ||
        lowerText.contains('vacation')) {
      recommendedInterests.add('travel');
    }

    // Determine recommended age range based on content
    int? recommendedMinAge;
    int? recommendedMaxAge;

    if (lowerText.contains('university') ||
        lowerText.contains('college') ||
        lowerText.contains('student')) {
      recommendedMinAge = 18;
      recommendedMaxAge = 25;
    }

    // Default recommendation
    return TargetAudienceRecommendation(
      mode: 'quick',
      suggestedCount: 100,
      suggestedInterests: recommendedInterests,
      suggestedMinAge: recommendedMinAge,
      suggestedMaxAge: recommendedMaxAge,
      confidence: recommendedInterests.isNotEmpty ? 0.7 : 0.3,
    );
  }
}

/// Validation result for target audience
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({
    required this.isValid,
    this.error,
  });
}

/// Target audience recommendations
class TargetAudienceRecommendation {
  final String mode;
  final int suggestedCount;
  final List<String> suggestedInterests;
  final int? suggestedMinAge;
  final int? suggestedMaxAge;
  final String? suggestedGender;
  final double confidence;

  TargetAudienceRecommendation({
    required this.mode,
    required this.suggestedCount,
    required this.suggestedInterests,
    this.suggestedMinAge,
    this.suggestedMaxAge,
    this.suggestedGender,
    required this.confidence,
  });
}