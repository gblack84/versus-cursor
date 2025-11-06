import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/i_post_metrics_repository.dart';
import '../../domain/failures/post_failure.dart';
import '/core/utils/idempotency_service.dart';
import '/core/utils/shard_utils.dart';

/// Implementation of post metrics repository
/// CQRS 패턴 - Query 모델로 읽기 전용 통계 관리 구현체
///
/// **Migrated from**: `lib/features/creation/data/repositories/content_metrics_repository_impl.dart`
/// **Migration Date**: 2025-11-06
/// **Reason**: Metrics are displayed and used in Post screens
class PostMetricsRepositoryImpl implements IPostMetricsRepository {
  final FirebaseFirestore _firestore;
  final IdempotencyService _idempotencyService;
  final ShardUtils _shardUtils;
  static const String _collection = 'posts';

  PostMetricsRepositoryImpl({
    FirebaseFirestore? firestore,
    IdempotencyService? idempotencyService,
    ShardUtils? shardUtils,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _idempotencyService =
            idempotencyService ?? IdempotencyService(firestore: firestore ?? FirebaseFirestore.instance),
        _shardUtils = shardUtils ?? ShardUtils(firestore: firestore ?? FirebaseFirestore.instance);

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  @override
  Future<Either<PostFailure, Unit>> incrementViewCount(String contentId) async {
    try {
      await _postsCollection.doc(contentId).update({
        'stats.viewCount': FieldValue.increment(1),
        'stats.lastViewedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException catch (e) {
      return left(PostFailure.metricsOperationFailed(
        operation: 'incrementViewCount',
        reason: e.message,
      ));
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Unexpected error incrementing view count',
        error: e,
      ));
    }
  }

  @override
  Future<Either<PostFailure, ContentMetrics>> getEngagementMetrics(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        return left(PostFailure.postNotFound(postId: contentId));
      }

      final data = doc.data() as Map<String, dynamic>;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};

      final metrics = ContentMetrics(
        viewCount: stats['viewCount'] ?? 0,
        participantCount: stats['participantcount'] ?? 0,
        commentCount: stats['commentCount'] ?? 0,
        shareCount: stats['shareCount'] ?? 0,
        engagementRate: _calculateEngagementRate(stats),
        lastUpdated: DateTime.now(),
      );
      return right(metrics);
    } on FirebaseException catch (e) {
      return left(PostFailure.metricsOperationFailed(
        operation: 'getEngagementMetrics',
        reason: e.message,
      ));
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Unexpected error getting engagement metrics',
        error: e,
      ));
    }
  }

  @override
  Future<Either<PostFailure, double>> getTrendingScore(String contentId) async {
    try {
      final metricsResult = await getEngagementMetrics(contentId);
      return metricsResult.fold(
        (failure) => left(failure),
        (metrics) async {
          try {
            final doc = await _postsCollection.doc(contentId).get();
            if (!doc.exists) {
              return left(PostFailure.postNotFound(postId: contentId));
            }

            final data = doc.data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final ageInHours = DateTime.now().difference(createdAt).inHours;

            // Trending score algorithm
            // Higher engagement in shorter time = higher score
            final score = (metrics.participantCount * 2 +
                          metrics.commentCount * 1.5 +
                          metrics.viewCount * 0.5) /
                         (ageInHours + 2); // +2 to avoid division by zero

            return right(score);
          } on FirebaseException catch (e) {
            return left(PostFailure.metricsOperationFailed(
              operation: 'getTrendingScore',
              reason: e.message,
            ));
          }
        },
      );
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Unexpected error calculating trending score',
        error: e,
      ));
    }
  }

  @override
  Stream<Either<PostFailure, MetricsUpdate>> watchMetrics(String contentId) {
    return _postsCollection.doc(contentId).snapshots().map((doc) {
      try {
        if (!doc.exists) {
          return left(PostFailure.postNotFound(postId: contentId));
        }

        final data = doc.data() as Map<String, dynamic>;
        final update = MetricsUpdate(
          contentId: contentId,
          metrics: data['stats'] ?? {},
          timestamp: DateTime.now(),
        );
        return right(update);
      } catch (e) {
        return left(PostFailure.unexpected(
          message: 'Unexpected error watching metrics',
          error: e,
        ));
      }
    });
  }

  @override
  Future<Either<PostFailure, ContentMetrics>> getPostMetrics(String contentId) async {
    return getEngagementMetrics(contentId);
  }

  @override
  Future<Either<PostFailure, Unit>> updateStats(
    String contentId,
    Map<String, dynamic> stats,
  ) async {
    try {
      final updateData = <String, dynamic>{};
      stats.forEach((key, value) {
        updateData['stats.$key'] = value;
      });
      updateData['stats.lastUpdatedAt'] = FieldValue.serverTimestamp();

      await _postsCollection.doc(contentId).update(updateData);
      return right(unit);
    } on FirebaseException catch (e) {
      return left(PostFailure.metricsOperationFailed(
        operation: 'updateStats',
        reason: e.message,
      ));
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Unexpected error updating stats',
        error: e,
      ));
    }
  }

  @override
  Stream<Either<PostFailure, List<TrendingContent>>> getTrendingContent({int limit = 20}) {
    return _postsCollection
        .orderBy('stats.participantcount', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      try {
        final futures = snapshot.docs.map((doc) async {
          final data = doc.data() as Map<String, dynamic>;
          final scoreResult = await getTrendingScore(doc.id);

          return scoreResult.fold(
            (failure) => null,
            (score) => TrendingContent(
              contentId: doc.id,
              title: data['questionTitle'] ?? '',
              trendingScore: score,
              participantCount: data['stats']?['participantcount'] ?? 0,
              trendingAt: DateTime.now(),
            ),
          );
        }).toList();

        final results = await Future.wait(futures);
        final validResults = results.whereType<TrendingContent>().toList();
        validResults.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
        return right(validResults.take(limit).toList());
      } catch (e) {
        return left(PostFailure.unexpected(
          message: 'Unexpected error getting trending content',
          error: e,
        ));
      }
    });
  }

  @override
  Stream<Either<PostFailure, List<PopularContent>>> getPopularByCategory(
    String category, {
    int limit = 10,
  }) {
    return _postsCollection
        .where('category', isEqualTo: category)
        .orderBy('stats.viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      try {
        final popularList = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          return PopularContent(
            contentId: doc.id,
            title: data['questionTitle'] ?? '',
            category: category,
            viewCount: data['stats']?['viewCount'] ?? 0,
            popularityScore: _calculatePopularityScore(data['stats'] ?? {}),
          );
        }).toList();

        return right(popularList);
      } catch (e) {
        return left(PostFailure.unexpected(
          message: 'Unexpected error getting popular content',
          error: e,
        ));
      }
    });
  }

  @override
  Future<Either<PostFailure, Unit>> recordInteraction(
    String contentId,
    String userId,
    InteractionType type, {
    String? eventId, // 🆕 Idempotency
  }) async {
    try {
      final actualEventId = eventId ?? const Uuid().v4();

      // ✅ Idempotency + Sharded Counter 적용
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'interactions',
        entityId: contentId,
        userId: userId,
        eventId: actualEventId,
        operation: (transaction) async {
          final postRef = _postsCollection.doc(contentId);

          // ✨ Sharded Counter 증가
          final statField = _getStatFieldForInteraction(type);
          if (statField != null) {
            _shardUtils.incrementShard(
              transaction,
              counterType: 'interaction',
              entityId: contentId,
              userId: userId,
              field: statField,
            );
          }

          // Record interaction in subcollection
          final interactionRef = postRef.collection('interactions').doc(userId);
          transaction.set(interactionRef, {
            'userId': userId,
            'type': type.toString().split('.').last,
            'eventId': actualEventId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        },
      );
      return right(unit);
    } on FirebaseException catch (e) {
      return left(PostFailure.metricsOperationFailed(
        operation: 'recordInteraction',
        reason: e.message,
      ));
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Unexpected error recording interaction',
        error: e,
      ));
    }
  }

  @override
  Future<Either<PostFailure, List<UserInteraction>>> getInteractionHistory(
    String contentId,
    String userId,
  ) async {
    try {
      final snapshot = await _postsCollection
          .doc(contentId)
          .collection('interactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final interactions = snapshot.docs.map((doc) {
        final data = doc.data();
        return UserInteraction(
          userId: userId,
          type: _parseInteractionType(data['type']),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          metadata: data['metadata'],
        );
      }).toList();

      return right(interactions);
    } on FirebaseException catch (e) {
      return left(PostFailure.metricsOperationFailed(
        operation: 'getInteractionHistory',
        reason: e.message,
      ));
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Unexpected error getting interaction history',
        error: e,
      ));
    }
  }

  // Helper methods
  double _calculateEngagementRate(Map<String, dynamic> stats) {
    final viewCount = stats['viewCount'] ?? 1; // Avoid division by zero
    final interactions = (stats['participantcount'] ?? 0) +
                        (stats['commentCount'] ?? 0) +
                        (stats['shareCount'] ?? 0);
    return (interactions / viewCount) * 100;
  }

  double _calculatePopularityScore(Map<String, dynamic> stats) {
    return (stats['viewCount'] ?? 0) * 1.0 +
           (stats['participantcount'] ?? 0) * 3.0 +
           (stats['commentCount'] ?? 0) * 2.0 +
           (stats['shareCount'] ?? 0) * 4.0;
  }

  String? _getStatFieldForInteraction(InteractionType type) {
    switch (type) {
      case InteractionType.view:
        return 'viewCount';
      case InteractionType.vote:
        return 'participantcount';
      case InteractionType.comment:
        return 'commentCount';
      case InteractionType.share:
        return 'shareCount';
      case InteractionType.like:
        return 'likeCount';
      case InteractionType.dislike:
        return 'dislikeCount';
      case InteractionType.report:
        return 'reportCount';
    }
  }

  InteractionType _parseInteractionType(String typeStr) {
    return InteractionType.values.firstWhere(
      (type) => type.toString().split('.').last == typeStr,
      orElse: () => InteractionType.view,
    );
  }
}
