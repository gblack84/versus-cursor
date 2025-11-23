import 'package:fpdart/fpdart.dart';
import '../../failures/creation_failure.dart';
import '../../entities/target_audience.dart';
import '../../services/i_target_audience_service.dart';
import '/services/logging/dev_logger.dart';

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
  Future<Either<CreationFailure, TargetAudience>> createFromProviderMap(
    Map<String, dynamic> providerMap,
  ) async {
    DevLogger.params({
      'providerMap_keys': providerMap.keys.toList(),
      'collectionType': providerMap['collectionType'],
      'targetCount': providerMap['targetCount'],
    }, tag: 'CreateFromProviderMap');

    try {
      DevLogger.checkpoint('Step 1: Create target audience from Provider map', tag: 'CreateFromProviderMap');
      // Create target audience from Provider map using Entity factory
      final targetAudience = TargetAudience.fromProviderMap(providerMap);

      DevLogger.checkpoint('Step 2: Validate target audience', tag: 'CreateFromProviderMap');
      // Validate target audience
      final validationResult = validateTargetAudience(targetAudience);

      if (!validationResult.isValid) {
        DevLogger.validation(
          field: 'targetAudience',
          reason: validationResult.error ?? 'Invalid target audience configuration',
          tag: 'CreateFromProviderMap',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {
              'targetAudience':
                  validationResult.error ??
                  'Invalid target audience configuration',
            },
          ),
        );
      }

      DevLogger.result(
        isSuccess: true,
        data: {
          'collectionType': targetAudience.collectionType,
          'targetCount': targetAudience.targetCount,
          'selectedInterests_count': targetAudience.selectedInterests.length,
        },
        tag: 'CreateFromProviderMap',
      );
      return right(targetAudience);
    } catch (error, stackTrace) {
      DevLogger.error(
        'Create from provider map failed - Exception caught',
        error: error,
        stackTrace: stackTrace,
        tag: 'CreateFromProviderMap',
      );
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'createFromProviderMap',
        ),
      );
    }
  }

  /// Create and validate a target audience configuration
  Future<Either<CreationFailure, TargetAudience>> createTargetAudience({
    required String collectionType,
    required int targetCount,
    List<String>? selectedInterests,
    String? selectedAgeGroup,
    String? selectedGender,
    bool activeUserOnly = true,
    bool isPremium = false,
  }) async {
    DevLogger.params({
      'collectionType': collectionType,
      'targetCount': targetCount,
      'selectedInterests_count': selectedInterests?.length ?? 0,
      'selectedAgeGroup': selectedAgeGroup ?? '전체',
      'selectedGender': selectedGender ?? 'all',
      'activeUserOnly': activeUserOnly,
      'isPremium': isPremium,
    }, tag: 'CreateTargetAudience');

    try {
      DevLogger.checkpoint('Step 1: Create target audience model', tag: 'CreateTargetAudience');
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

      DevLogger.checkpoint('Step 2: Validate target audience', tag: 'CreateTargetAudience');
      // Validate target audience
      final validationResult = validateTargetAudience(targetAudience);

      if (!validationResult.isValid) {
        DevLogger.validation(
          field: 'targetAudience',
          reason: validationResult.error ?? 'Invalid target audience configuration',
          tag: 'CreateTargetAudience',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {
              'targetAudience':
                  validationResult.error ??
                  'Invalid target audience configuration',
            },
          ),
        );
      }

      DevLogger.result(
        isSuccess: true,
        data: {
          'collectionType': targetAudience.collectionType,
          'targetCount': targetAudience.targetCount,
          'status': targetAudience.status,
        },
        tag: 'CreateTargetAudience',
      );
      return right(targetAudience);
    } catch (error, stackTrace) {
      DevLogger.error(
        'Target audience creation failed - Exception caught',
        error: error,
        stackTrace: stackTrace,
        tag: 'CreateTargetAudience',
      );
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'createTargetAudience',
        ),
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
  Future<Either<CreationFailure, TargetAudienceRecommendation>>
  getRecommendations({
    required String title,
    required String description,
    List<String>? imageTags,
  }) async {
    DevLogger.params({
      'title_length': title.length,
      'title_preview': title.length > 50 ? '${title.substring(0, 50)}...' : title,
      'description_length': description.length,
      'imageTags_count': imageTags?.length ?? 0,
    }, tag: 'GetRecommendations');

    try {
      DevLogger.checkpoint('Step 1: Analyze content for recommendations', tag: 'GetRecommendations');
      // Analyze content and generate recommendations
      final recommendations = await _analyzeContentForRecommendations(
        title: title,
        description: description,
        imageTags: imageTags,
      );

      DevLogger.result(
        isSuccess: true,
        data: {
          'mode': recommendations.mode,
          'suggestedCount': recommendations.suggestedCount,
          'suggestedInterests_count': recommendations.suggestedInterests.length,
          'confidence': recommendations.confidence,
        },
        tag: 'GetRecommendations',
      );
      return right(recommendations);
    } catch (error, stackTrace) {
      DevLogger.error(
        'Get recommendations failed - Exception caught',
        error: error,
        stackTrace: stackTrace,
        tag: 'GetRecommendations',
      );
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'getRecommendations',
        ),
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
