/// Repository interface for content visibility and access control
/// Target Audience 시스템과 연동되는 접근 제어 Repository
abstract class IContentVisibilityRepository {
  /// Set content visibility level
  Future<void> setVisibility(String contentId, VisibilityLevel level);

  /// Check if user can view content
  Future<bool> canUserView(String contentId, String userId);

  /// Get target audience settings
  Future<TargetAudience> getTargetAudience(String contentId);

  /// Update target audience
  Future<void> updateTargetAudience(String contentId, TargetAudience audience);

  /// Get content by visibility level
  Stream<List<String>> getContentByVisibility(VisibilityLevel level);

  /// Set content as anonymous
  Future<void> setAnonymous(String contentId, bool isAnonymous);

  /// Check if content requires premium
  Future<bool> isPremiumRequired(String contentId);

  /// Set premium requirement
  Future<void> setPremiumRequired(String contentId, bool required);

  /// Get user's accessible content
  Stream<List<String>> getUserAccessibleContent(String userId);

  /// Grant user access to content
  Future<void> grantAccess(String contentId, String userId);

  /// Revoke user access to content
  Future<void> revokeAccess(String contentId, String userId);

  /// Get access control list
  Future<List<AccessControl>> getAccessControlList(String contentId);

  /// Send notifications to target audience
  Future<void> sendNotifications(String contentId);
}

/// Visibility levels
enum VisibilityLevel {
  public,      // Anyone can view
  friends,     // Only friends can view
  private,     // Only creator can view
  custom,      // Custom target audience
  premium,     // Premium users only
}

/// Target audience configuration
class TargetAudience {
  final String mode;  // 'quick', 'public', 'custom'
  final List<String>? interests;
  final AgeRange? ageRange;
  final String? gender;
  final List<String>? locations;
  final Map<String, dynamic>? customFilters;

  TargetAudience({
    required this.mode,
    this.interests,
    this.ageRange,
    this.gender,
    this.locations,
    this.customFilters,
  });
}

/// Age range for targeting
class AgeRange {
  final int min;
  final int max;

  AgeRange({required this.min, required this.max});
}

/// Access control entry
class AccessControl {
  final String userId;
  final AccessLevel level;
  final DateTime grantedAt;
  final DateTime? expiresAt;

  AccessControl({
    required this.userId,
    required this.level,
    required this.grantedAt,
    this.expiresAt,
  });
}

/// Access levels
enum AccessLevel {
  view,       // Can view only
  comment,    // Can view and comment
  vote,       // Can view, comment, and vote
  full,       // All permissions
}