import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_content_moderation_repository.dart';
import '../../domain/usecases/moderate_content_usecase.dart';

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
  Future<void> reportContent(
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
    } catch (e) {
      throw Exception('Failed to report content: $e');
    }
  }

  @override
  Future<ModerationResult> moderateContent(String contentId) async {
    try {
      // Use existing ModerateContentUseCase if available
      if (_moderateUseCase != null) {
        final result = await _moderateUseCase!.moderateText(
          text: contentId,
          context: 'post_content',
        );

        return result.fold(
          (failure) => ModerationResult(
            contentId: contentId,
            isApproved: false,
            violations: [failure.message],
            confidenceScore: 0.0,
            blockReason: failure.message,
            moderatedAt: DateTime.now(),
          ),
          (decision) => ModerationResult(
            contentId: contentId,
            isApproved: decision.isApproved,
            violations: decision.reason != null ? [decision.reason!] : [],
            confidenceScore: decision.confidence,
            blockReason: decision.reason,
            moderatedAt: DateTime.now(),
          ),
        );
      }

      // Fallback: Simple moderation without AI
      return ModerationResult(
        contentId: contentId,
        isApproved: true,
        violations: [],
        confidenceScore: 1.0,
        moderatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to moderate content: $e');
    }
  }

  @override
  Future<void> blockContent(String contentId, String reason) async {
    try {
      await _postsCollection.doc(contentId).update({
        'isBlocked': true,
        'blockReason': reason,
        'blockedAt': FieldValue.serverTimestamp(),
        'visibility': 2, // private
        'moderationStatus': 'blocked',
      });
    } catch (e) {
      throw Exception('Failed to block content: $e');
    }
  }

  @override
  Future<void> unblockContent(String contentId) async {
    try {
      await _postsCollection.doc(contentId).update({
        'isBlocked': false,
        'blockReason': FieldValue.delete(),
        'blockedAt': FieldValue.delete(),
        'visibility': 0, // public
        'moderationStatus': 'approved',
      });
    } catch (e) {
      throw Exception('Failed to unblock content: $e');
    }
  }

  @override
  Future<void> appealModeration(
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
    } catch (e) {
      throw Exception('Failed to appeal moderation: $e');
    }
  }

  @override
  Future<List<ModerationAction>> getModerationHistory(String contentId) async {
    try {
      final snapshot = await _reportsCollection
          .where('contentId', isEqualTo: contentId)
          .orderBy('reportedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
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
    } catch (e) {
      throw Exception('Failed to get moderation history: $e');
    }
  }

  @override
  Future<bool> isContentSafe(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      return !(data['isBlocked'] ?? false) &&
             (data['moderationStatus'] != 'blocked');
    } catch (e) {
      throw Exception('Failed to check content safety: $e');
    }
  }

  @override
  Stream<List<ReportedContent>> getReportedContent({int limit = 50}) {
    return _postsCollection
        .where('isReported', isEqualTo: true)
        .orderBy('lastReportedAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
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

      return Future.wait(futures);
    });
  }

  @override
  Future<void> processModerationQueue() async {
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
        final result = await moderateContent(contentId);

        // Update report status
        await reportDoc.reference.update({
          'status': result.isApproved ? 'approved' : 'rejected',
          'processedAt': FieldValue.serverTimestamp(),
        });

        // Update content if needed
        if (!result.isApproved && result.blockReason != null) {
          await blockContent(contentId, result.blockReason!);
        }
      }
    } catch (e) {
      throw Exception('Failed to process moderation queue: $e');
    }
  }

  @override
  Future<void> updateModerationStatus(
    String contentId,
    ModerationStatus status,
  ) async {
    try {
      await _postsCollection.doc(contentId).update({
        'moderationStatus': status.toString().split('.').last,
        'moderationUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update moderation status: $e');
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