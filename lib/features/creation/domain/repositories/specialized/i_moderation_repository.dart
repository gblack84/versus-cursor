import 'package:fpdart/fpdart.dart';
import '../../failures/creation_failures.dart';

/// Repository interface for content moderation and policy enforcement
/// AI 검열 시스템과 연동되는 콘텐츠 정책 적용 Repository
abstract class IContentModerationRepository {
  /// Report content for violation
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  Future<Either<ModerationRepositoryFailure, Unit>> reportContent(
    String contentId,
    String userId,
    ReportReason reason,
  );

  /// Moderate content using AI
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, ModerationResult>`
  Future<Either<ModerationRepositoryFailure, ModerationResult>> moderateContent(String contentId);

  /// Block/hide content
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  Future<Either<ModerationRepositoryFailure, Unit>> blockContent(String contentId, String reason);

  /// Unblock content
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  Future<Either<ModerationRepositoryFailure, Unit>> unblockContent(String contentId);

  /// Appeal moderation decision
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  Future<Either<ModerationRepositoryFailure, Unit>> appealModeration(
    String contentId,
    String userId,
    String reason,
  );

  /// Get moderation history
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, List<ModerationAction>>`
  Future<Either<ModerationRepositoryFailure, List<ModerationAction>>> getModerationHistory(
    String contentId,
  );

  /// Check if content is safe
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  /// - `Right(unit)` if safe
  /// - `Left(failure)` if unsafe or check failed
  Future<Either<ModerationRepositoryFailure, Unit>> isContentSafe(String contentId);

  /// Get reported content list
  ///
  /// **Returns**: Stream of `Either<ModerationRepositoryFailure, List<ReportedContent>>`
  Stream<Either<ModerationRepositoryFailure, List<ReportedContent>>> getReportedContent({
    int limit = 50,
  });

  /// Process moderation queue
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  Future<Either<ModerationRepositoryFailure, Unit>> processModerationQueue();

  /// Update moderation status
  ///
  /// **Returns**: `Either<ModerationRepositoryFailure, Unit>`
  Future<Either<ModerationRepositoryFailure, Unit>> updateModerationStatus(
    String contentId,
    ModerationStatus status,
  );
}

/// Report reasons
enum ReportReason {
  inappropriate,
  spam,
  harassment,
  violence,
  sexualContent,
  hateSpeech,
  misinformation,
  copyright,
  other,
}

/// Moderation result
class ModerationResult {
  final String contentId;
  final bool isApproved;
  final List<String> violations;
  final double confidenceScore;
  final String? blockReason;
  final DateTime moderatedAt;

  ModerationResult({
    required this.contentId,
    required this.isApproved,
    required this.violations,
    required this.confidenceScore,
    this.blockReason,
    required this.moderatedAt,
  });
}

/// Moderation action record
class ModerationAction {
  final String actionId;
  final String contentId;
  final String actionType;
  final String reason;
  final String moderatorId;
  final DateTime timestamp;

  ModerationAction({
    required this.actionId,
    required this.contentId,
    required this.actionType,
    required this.reason,
    required this.moderatorId,
    required this.timestamp,
  });
}

/// Reported content data
class ReportedContent {
  final String contentId;
  final String title;
  final int reportCount;
  final List<ReportReason> reasons;
  final DateTime firstReportedAt;
  final ModerationStatus status;

  ReportedContent({
    required this.contentId,
    required this.title,
    required this.reportCount,
    required this.reasons,
    required this.firstReportedAt,
    required this.status,
  });
}

/// Moderation status
enum ModerationStatus {
  pending,
  underReview,
  approved,
  rejected,
  blocked,
  appealed,
  resolved,
}