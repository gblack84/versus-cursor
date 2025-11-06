import 'package:fpdart/fpdart.dart';
import '../entities/target_audience.dart';
import '../failures/creation_failures.dart';

/// Domain service interface for target audience operations
abstract class ITargetAudienceService {
  /// Validate target audience configuration
  ValidationResult validateTargetAudience(TargetAudience audience);

  /// Create target audience with validation
  Future<Either<TargetAudienceFailure, TargetAudience>> createTargetAudience({
    required String mode,
    required int targetCount,
    List<String>? selectedUserIds,
    Map<String, dynamic>? filters,
  });

  /// Get recommended users based on content
  Future<Either<TargetAudienceFailure, List<String>>> getRecommendedUsers({
    required String contentId,
    required int count,
  });

  /// Convert TargetAudience domain model to Firestore format
  Map<String, dynamic> convertModelToFirestore(TargetAudience model);
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