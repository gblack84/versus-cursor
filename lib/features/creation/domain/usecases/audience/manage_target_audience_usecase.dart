import 'package:fpdart/fpdart.dart';
import '../../failures/creation_failures.dart';
import '../../entities/target_audience.dart';
import '../../services/i_target_audience_service.dart';

/// UseCase for managing target audience
///
/// **Phase 5 Migration**: Removed TargetAudienceDto dependency
/// - Now uses TargetAudience.fromProviderMap() directly
/// - Cleaner interface following Clean Architecture
///
/// This UseCase wraps the TargetAudienceService to provide a clean interface
/// for the Presentation layer, following Clean Architecture principles.
class ManageTargetAudienceUseCase {
  final ITargetAudienceService _targetAudienceService;

  ManageTargetAudienceUseCase({
    required ITargetAudienceService targetAudienceService,
  }) : _targetAudienceService = targetAudienceService;

  /// Create target audience from Provider Map (from Presentation layer)
  ///
  /// **Phase 5 Migration**: Replaced createFromDto() with createFromProviderMap()
  /// - Uses TargetAudience.fromProviderMap() factory method
  /// - No DTO layer needed - direct Entity creation
  ///
  /// This method provides a clean interface for Providers to use
  Future<Either<Failure, TargetAudience>> createFromProviderMap(
    Map<String, dynamic> providerMap,
  ) async {
    try {
      // Create target audience from Provider map using Entity factory
      final targetAudience = TargetAudience.fromProviderMap(providerMap);

      // Validate target audience
      final validationResult = validateTargetAudience(targetAudience);

      if (!validationResult.isValid) {
        return left(
          CreationValidationFailure(
            validationResult.error ?? 'Invalid target audience configuration',
          ),
        );
      }

      return right(targetAudience);
    } catch (error) {
      print('createFromProviderMap Error: $error');
      return left(
        UnknownFailure(message: 'Failed to create target audience: $error'),
      );
    }
  }

  /// Create and validate a target audience configuration
  Future<Either<Failure, TargetAudience>> createTargetAudience({
    required String collectionType,
    required int targetCount,
    List<String>? selectedInterests,
    String? selectedAgeGroup,
    String? selectedGender,
    bool activeUserOnly = true,
    bool isPremium = false,
  }) async {
    try {
      // Create target audience model
      final targetAudience = TargetAudience(
        collectionType: collectionType,
        targetCount: targetCount,
        selectedInterests: selectedInterests ?? [],
        selectedAgeGroup: selectedAgeGroup ?? '전체',
        selectedGender: selectedGender ?? 'all',
        activeUserOnly: activeUserOnly,
        isPremium: isPremium,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      // Validate target audience
      final validationResult = validateTargetAudience(targetAudience);

      if (!validationResult.isValid) {
        return left(
          CreationValidationFailure(
            validationResult.error ?? 'Invalid target audience configuration',
          ),
        );
      }

      return right(targetAudience);
    } catch (error) {
      print('ManageTargetAudienceUseCase Error: $error');
      return left(
        UnknownFailure(message: 'Failed to create target audience: $error'),
      );
    }
  }

  /// Validate a target audience configuration
  ValidationResult validateTargetAudience(TargetAudience targetAudience) {
    return _targetAudienceService.validateTargetAudience(targetAudience);
  }

  /// Convert target audience to Firestore format
  Map<String, dynamic> convertToFirestoreFormat(TargetAudience targetAudience) {
    // Use domain model's toMap() method for Firestore conversion
    return targetAudience.toMap();
  }

  /// Get target audience recommendations based on post content
  Future<Either<Failure, TargetAudienceRecommendation>> getRecommendations({
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

      return right(recommendations);
    } catch (error) {
      print('GetRecommendations Error: $error');
      return left(
        UnknownFailure(message: 'Failed to get recommendations: $error'),
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