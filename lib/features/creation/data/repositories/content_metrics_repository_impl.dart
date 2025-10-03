import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/specialized/i_metrics_repository.dart';

/// Implementation of content metrics repository
/// CQRS 패턴 - Query 모델로 읽기 전용 통계 관리 구현체
class ContentMetricsRepositoryImpl implements IContentMetricsRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'posts';

  ContentMetricsRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  @override
  Future<void> incrementViewCount(String contentId) async {
    try {
      await _postsCollection.doc(contentId).update({
        'stats.viewCount': FieldValue.increment(1),
        'stats.lastViewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  @override
  Future<ContentMetrics> getEngagementMetrics(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        throw Exception('Content not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};

      return ContentMetrics(
        viewCount: stats['viewCount'] ?? 0,
        participantCount: stats['participantcount'] ?? 0,
        commentCount: stats['commentCount'] ?? 0,
        shareCount: stats['shareCount'] ?? 0,
        engagementRate: _calculateEngagementRate(stats),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get engagement metrics: $e');
    }
  }

  @override
  Future<double> getTrendingScore(String contentId) async {
    try {
      final metrics = await getEngagementMetrics(contentId);
      final doc = await _postsCollection.doc(contentId).get();
      final data = doc.data() as Map<String, dynamic>;

      final createdAt = (data['createdAt'] as Timestamp).toDate();
      final ageInHours = DateTime.now().difference(createdAt).inHours;

      // Trending score algorithm
      // Higher engagement in shorter time = higher score
      final score = (metrics.participantCount * 2 +
                    metrics.commentCount * 1.5 +
                    metrics.viewCount * 0.5) /
                   (ageInHours + 2); // +2 to avoid division by zero

      return score;
    } catch (e) {
      throw Exception('Failed to calculate trending score: $e');
    }
  }

  @override
  Stream<MetricsUpdate> watchMetrics(String contentId) {
    return _postsCollection.doc(contentId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Content not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      return MetricsUpdate(
        contentId: contentId,
        metrics: data['stats'] ?? {},
        timestamp: DateTime.now(),
      );
    });
  }

  @override
  Future<ContentMetrics> getPostMetrics(String contentId) async {
    return getEngagementMetrics(contentId);
  }

  @override
  Future<void> updateStats(String contentId, Map<String, dynamic> stats) async {
    try {
      final updateData = <String, dynamic>{};
      stats.forEach((key, value) {
        updateData['stats.$key'] = value;
      });
      updateData['stats.lastUpdatedAt'] = FieldValue.serverTimestamp();

      await _postsCollection.doc(contentId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update stats: $e');
    }
  }

  @override
  Stream<List<TrendingContent>> getTrendingContent({int limit = 20}) {
    return _postsCollection
        .orderBy('stats.participantcount', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
      final futures = snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final score = await getTrendingScore(doc.id);

        return TrendingContent(
          contentId: doc.id,
          title: data['questionTitle'] ?? '',
          trendingScore: score,
          participantCount: data['stats']?['participantcount'] ?? 0,
          trendingAt: DateTime.now(),
        );
      }).toList();

      final results = await Future.wait(futures);
      results.sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
      return results.take(limit).toList();
    });
  }

  @override
  Stream<List<PopularContent>> getPopularByCategory(
    String category, {
    int limit = 10,
  }) {
    return _postsCollection
        .where('category', isEqualTo: category)
        .orderBy('stats.viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return PopularContent(
          contentId: doc.id,
          title: data['questionTitle'] ?? '',
          category: category,
          viewCount: data['stats']?['viewCount'] ?? 0,
          popularityScore: _calculatePopularityScore(data['stats'] ?? {}),
        );
      }).toList();
    });
  }

  @override
  Future<void> recordInteraction(
    String contentId,
    String userId,
    InteractionType type,
  ) async {
    try {
      final batch = _firestore.batch();
      final postRef = _postsCollection.doc(contentId);

      // Update interaction count
      final statField = _getStatFieldForInteraction(type);
      if (statField != null) {
        batch.update(postRef, {
          'stats.$statField': FieldValue.increment(1),
        });
      }

      // Record interaction in subcollection
      final interactionRef = postRef.collection('interactions').doc();
      batch.set(interactionRef, {
        'userId': userId,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to record interaction: $e');
    }
  }

  @override
  Future<List<UserInteraction>> getInteractionHistory(
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

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserInteraction(
          userId: userId,
          type: _parseInteractionType(data['type']),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          metadata: data['metadata'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get interaction history: $e');
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