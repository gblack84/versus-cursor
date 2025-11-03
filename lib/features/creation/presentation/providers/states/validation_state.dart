import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/failures/creation_failures.dart';

part 'validation_state.freezed.dart';

/// Validation result model for individual content items
@freezed
sealed class ValidationResult with _$ValidationResult {
  const ValidationResult._();

  const factory ValidationResult({
    required String id,
    required bool isApproved,
    String? rejectionReason,
    required double confidence,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) = _ValidationResult;

  /// Check if validation was rejected
  bool get isRejected => !isApproved;

  /// Check if validation result is expired
  bool isExpired(Duration cacheExpiration) {
    final age = DateTime.now().difference(timestamp);
    return age > cacheExpiration;
  }
}

/// Complete state for MediaValidationProvider
///
/// This consolidates all state variables from MediaValidationProvider into a single immutable state
@freezed
sealed class ValidationState with _$ValidationState {
  const ValidationState._();

  const factory ValidationState({
    /// Cache of validation results by ID
    @Default({}) Map<String, ValidationResult> validationResults,

    /// Current validation status
    @Default(false) bool isValidating,

    /// Current validation message
    String? validationMessage,

    /// Current validation failure
    Failure? validationFailure,

    /// Vision API results for Box A (for compatibility)
    Map<String, dynamic>? visionResultA,

    /// Vision API results for Box B (for compatibility)
    Map<String, dynamic>? visionResultB,
  }) = _ValidationState;

  /// Get validation summary statistics
  ValidationSummary get summary {
    final approved = validationResults.values.where((r) => r.isApproved).length;
    final rejected = validationResults.values.where((r) => r.isRejected).length;
    final total = validationResults.length;

    return ValidationSummary(
      approved: approved,
      rejected: rejected,
      total: total,
      allApproved: rejected == 0 && total > 0,
      hasRejections: rejected > 0,
    );
  }

  /// Parse rejection reasons for display
  String parseRejectionReasons() {
    final rejectedItems = validationResults.entries
        .where((entry) => entry.value.isRejected)
        .toList();

    if (rejectedItems.isEmpty) {
      return '';
    }

    final reasonsMap = <String, List<String>>{};

    for (final item in rejectedItems) {
      final reason = item.value.rejectionReason ?? '알 수 없는 이유';
      final itemId = item.key;

      if (reasonsMap.containsKey(reason)) {
        reasonsMap[reason]!.add(itemId);
      } else {
        reasonsMap[reason] = [itemId];
      }
    }

    return reasonsMap.entries
        .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
        .join('\n');
  }
}

/// Summary statistics for validation results
class ValidationSummary {
  final int approved;
  final int rejected;
  final int total;
  final bool allApproved;
  final bool hasRejections;

  ValidationSummary({
    required this.approved,
    required this.rejected,
    required this.total,
    required this.allApproved,
    required this.hasRejections,
  });
}
