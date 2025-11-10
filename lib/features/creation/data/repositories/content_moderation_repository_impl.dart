import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/specialized/i_moderation_repository.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/failures/creation_failure.dart';
import '../../domain/failures/creation_failure_extensions.dart'; // Extension for getUserMessage()

/// Implementation of content moderation repository
/// AI 검열 시스템과 연동되는 콘텐츠 정책 적용 구현체
class ContentModerationRepositoryImpl implements IContentModerationRepository {
  final FirebaseFirestore _firestore;
  final ModerateContentUseCase? _moderateUseCase;
  static const String _collection = 'posts';
  static const String _reportsCollectionName = 'reports';

  ContentModerationRepositoryImpl({
    FirebaseFirestore? firestore,
    ModerateContentUseCase? moderateUseCase,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _moderateUseCase = moderateUseCase;

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  CollectionReference get _reportsCollection =>
      _firestore.collection(_reportsCollectionName);

  @override
  Future<Either<CreationFailure, Unit>> reportContent(
    String contentId,
    String userId,
    ReportReason reason,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update post report count
      final postRef = _postsCollection.doc(contentId);
      batch.update(postRef, {
        'reportedBy': FieldValue.arrayUnion([userId]),
        'reportCount': FieldValue.increment(1),
        'isReported': true,
        'lastReportedAt': FieldValue.serverTimestamp(),
      });

      // Create report record
      final reportRef = _reportsCollection.doc();
      batch.set(reportRef, {
        'contentId': contentId,
        'reportedBy': userId,
        'reason': reason.toString().split('.').last,
        'reportedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await batch.commit();
      return right(unit);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'reportContent',
        // message:'Failed to report content: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'reportContent',
        // message:'Unexpected error while reporting content: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, ContentModerationResult>> moderateContent(String contentId) async {
    try {
      // Use existing ModerateContentUseCase if available
      if (_moderateUseCase != null) {
        final result = await _moderateUseCase.moderateText(
          text: contentId,
          context: 'post_content',
        );

        return result.fold(
          (failure) => right(ContentModerationResult(
            contentId: contentId,
            isApproved: false,
            violations: [failure.getUserMessage()],
            confidenceScore: 0.0,
            blockReason: failure.getUserMessage(),
            moderatedAt: DateTime.now(),
          )),
          (decision) => right(ContentModerationResult(
            contentId: contentId,
            isApproved: decision.isApproved,
            violations: decision.reason != null ? [decision.reason!] : [],
            confidenceScore: decision.confidence,
            blockReason: decision.reason,
            moderatedAt: DateTime.now(),
          )),
        );
      }

      // Fallback: Simple moderation without AI
      return right(ContentModerationResult(
        contentId: contentId,
        isApproved: true,
        violations: [],
        confidenceScore: 1.0,
        moderatedAt: DateTime.now(),
      ));
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'moderateContent',
        // message:'Failed to moderate content: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'moderateContent',
        // message:'Unexpected error during moderation: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> blockContent(String contentId, String reason) async {
    try {
      await _postsCollection.doc(contentId).update({
        'isBlocked': true,
        'blockReason': reason,
        'blockedAt': FieldValue.serverTimestamp(),
        'visibility': 2, // private
        'moderationStatus': 'blocked',
      });
      return right(unit);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'blockContent',
        // message:'Failed to block content: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'blockContent',
        // message:'Unexpected error while blocking content: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> unblockContent(String contentId) async {
    try {
      await _postsCollection.doc(contentId).update({
        'isBlocked': false,
        'blockReason': FieldValue.delete(),
        'blockedAt': FieldValue.delete(),
        'visibility': 0, // public
        'moderationStatus': 'approved',
      });
      return right(unit);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'unblockContent',
        // message:'Failed to unblock content: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'unblockContent',
        // message:'Unexpected error while unblocking content: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> appealModeration(
    String contentId,
    String userId,
    String reason,
  ) async {
    try {
      final appealRef = _reportsCollection.doc();
      await appealRef.set({
        'contentId': contentId,
        'appealedBy': userId,
        'appealReason': reason,
        'appealedAt': FieldValue.serverTimestamp(),
        'type': 'appeal',
        'status': 'pending',
      });

      await _postsCollection.doc(contentId).update({
        'moderationStatus': 'appealed',
        'appealedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'appealModeration',
        // message:'Failed to appeal moderation: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'appealModeration',
        // message:'Unexpected error while appealing moderation: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, List<ModerationAction>>> getModerationHistory(String contentId) async {
    try {
      final snapshot = await _reportsCollection
          .where('contentId', isEqualTo: contentId)
          .orderBy('reportedAt', descending: true)
          .get();

      final actions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ModerationAction(
          actionId: doc.id,
          contentId: contentId,
          actionType: data['type'] ?? 'report',
          reason: data['reason'] ?? data['appealReason'] ?? '',
          moderatorId: data['reportedBy'] ?? data['appealedBy'] ?? 'system',
          timestamp: (data['reportedAt'] ?? data['appealedAt'] as Timestamp).toDate(),
        );
      }).toList();

      return right(actions);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'getModerationHistory',
        // message:'Failed to get moderation history: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'getModerationHistory',
        // message:'Unexpected error while getting moderation history: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> isContentSafe(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        return left(CreationFailure.moderationRepositoryFailed(
          moderationStep: 'isContentSafe',
          // message:'Content not found',
          // code:'not-found',
        ));
      }

      final data = doc.data() as Map<String, dynamic>;
      final isSafe = !(data['isBlocked'] ?? false) &&
                     (data['moderationStatus'] != 'blocked');

      if (isSafe) {
        return right(unit);
      } else {
        return left(CreationFailure.moderationRepositoryFailed(
          moderationStep: 'isContentSafe',
          // message:'Content is not safe',
          // code:'content-blocked',
        ));
      }
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'isContentSafe',
        // message:'Failed to check content safety: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'isContentSafe',
        // message:'Unexpected error while checking content safety: $e',
      ));
    }
  }

  @override
  Stream<Either<CreationFailure, List<ReportedContent>>> getReportedContent({int limit = 50}) {
    try {
      return _postsCollection
          .where('isReported', isEqualTo: true)
          .orderBy('lastReportedAt', descending: true)
          .limit(limit)
          .snapshots()
          .asyncMap((snapshot) async {
        try {
          final futures = snapshot.docs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;

            // Get report reasons
            final reports = await _reportsCollection
                .where('contentId', isEqualTo: doc.id)
                .get();

            final reasons = reports.docs
                .map((r) {
                  final data = r.data() as Map<String, dynamic>?;
                  return data != null && data['reason'] != null
                      ? _parseReportReason(data['reason'])
                      : ReportReason.other;
                })
                .toSet()
                .toList();

            return ReportedContent(
              contentId: doc.id,
              title: data['questionTitle'] ?? '',
              reportCount: data['reportCount'] ?? 0,
              reasons: reasons,
              firstReportedAt: (data['lastReportedAt'] as Timestamp?)?.toDate() ??
                              DateTime.now(),
              status: _parseModerationStatus(data['moderationStatus'] ?? 'pending'),
            );
          }).toList();

          final results = await Future.wait(futures);
          return right<CreationFailure, List<ReportedContent>>(results);
        } on FirebaseException {
          return left<CreationFailure, List<ReportedContent>>(
            CreationFailure.moderationRepositoryFailed(
              moderationStep: 'getReportedContent',
            ),
          );
        } catch (_) {
          return left<CreationFailure, List<ReportedContent>>(
            CreationFailure.moderationRepositoryFailed(
              moderationStep: 'getReportedContent',
            ),
          );
        }
      });
    } catch (_) {
      return Stream.value(
        left(CreationFailure.moderationRepositoryFailed(
          moderationStep: 'getReportedContent',
          // message:'Failed to create stream: $e',
        )),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> processModerationQueue() async {
    try {
      // Get pending reports
      final pendingReports = await _reportsCollection
          .where('status', isEqualTo: 'pending')
          .limit(10)
          .get();

      for (final reportDoc in pendingReports.docs) {
        final reportData = reportDoc.data() as Map<String, dynamic>;
        final contentId = reportData['contentId'];

        // Moderate content
        final moderationResult = await moderateContent(contentId);

        await moderationResult.fold(
          (failure) async {
            // On failure, mark report as error
            await reportDoc.reference.update({
              'status': 'error',
              'errorMessage': failure.message,
              'processedAt': FieldValue.serverTimestamp(),
            });
          },
          (result) async {
            // Update report status
            await reportDoc.reference.update({
              'status': result.isApproved ? 'approved' : 'rejected',
              'processedAt': FieldValue.serverTimestamp(),
            });

            // Update content if needed
            if (!result.isApproved && result.blockReason != null) {
              await blockContent(contentId, result.blockReason!);
            }
          },
        );
      }

      return right(unit);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'processModerationQueue',
        // message:'Failed to process moderation queue: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'processModerationQueue',
        // message:'Unexpected error while processing moderation queue: $e',
      ));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> updateModerationStatus(
    String contentId,
    ModerationStatus status,
  ) async {
    try {
      await _postsCollection.doc(contentId).update({
        'moderationStatus': status.toString().split('.').last,
        'moderationUpdatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'updateModerationStatus',
        // message:'Failed to update moderation status: ${e.message}',
        // code:e.code,
      ));
    } catch (_) {
      return left(CreationFailure.moderationRepositoryFailed(
        moderationStep: 'updateModerationStatus',
        // message:'Unexpected error while updating moderation status: $e',
      ));
    }
  }

  // Helper methods
  ReportReason _parseReportReason(String? reasonStr) {
    if (reasonStr == null) return ReportReason.other;
    return ReportReason.values.firstWhere(
      (reason) => reason.toString().split('.').last == reasonStr,
      orElse: () => ReportReason.other,
    );
  }

  ModerationStatus _parseModerationStatus(String statusStr) {
    return ModerationStatus.values.firstWhere(
      (status) => status.toString().split('.').last == statusStr,
      orElse: () => ModerationStatus.pending,
    );
  }
}