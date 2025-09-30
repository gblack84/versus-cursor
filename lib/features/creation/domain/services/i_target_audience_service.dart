import '../models/target_audience.dart';

/// Domain service interface for target audience operations
abstract class ITargetAudienceService {
  /// Validate target audience configuration
  ValidationResult validateTargetAudience(TargetAudience audience);

  /// Create target audience with validation
  Future<TargetAudience> createTargetAudience({
    required String mode,
    required int targetCount,
    List<String>? selectedUserIds,
    Map<String, dynamic>? filters,
  });

  /// Get recommended users based on content
  Future<List<String>> getRecommendedUsers({
    required String contentId,
    required int count,
  });
}

/// Validation result for target audience
class ValidationResult {
  final bool isValid;
  final String? error;
  final Map<String, dynamic>? metadata;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.metadata,
  });
}