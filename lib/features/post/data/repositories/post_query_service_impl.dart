import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:algolia/algolia.dart';
import '../../../creation/domain/models/aggregates/post_creation.dart';
import '../../domain/repositories/i_post_query_service.dart';
import '../../../creation/data/utils/firestore_util.dart';

/// Implementation of post query service
/// 읽기 전용 복잡한 게시물 조회 처리 서비스 구현체
class PostQueryServiceImpl implements IPostQueryService {
  final FirebaseFirestore _firestore;
  final Algolia? _algolia;
  static const String _collection = 'posts';

  PostQueryServiceImpl({
    FirebaseFirestore? firestore,
    Algolia? algolia,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _algolia = algolia;

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  @override
  Future<List<PostCreation>> searchContent(SearchCriteria criteria) async {
    try {
      Query query = _postsCollection;

      // Apply filters
      if (criteria.category != null) {
        query = query.where('category', isEqualTo: criteria.category);
      }

      if (criteria.tags != null && criteria.tags!.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: criteria.tags);
      }

      if (criteria.isCompleted != null) {
        query = query.where('voteCompleted', isEqualTo: criteria.isCompleted);
      }

      if (criteria.startDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(criteria.startDate!));
      }

      if (criteria.endDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(criteria.endDate!));
      }

      // Apply sorting
      query = _applySorting(query, criteria.sortOrder);

      final snapshot = await query.get();
      return _convertToPostList(snapshot);
    } catch (e) {
      throw Exception('Failed to search content: $e');
    }
  }

  @override
  Future<List<PostCreation>> getContentByUser(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .where('creatorInfo.userid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return _convertToPostList(snapshot);
    } catch (e) {
      throw Exception('Failed to get content by user: $e');
    }
  }

  @override
  Future<List<PostCreation>> getTrendingContent({int limit = 20}) async {
    try {
      final snapshot = await _postsCollection
          .orderBy('stats.participantcount', descending: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return _convertToPostList(snapshot);
    } catch (e) {
      throw Exception('Failed to get trending content: $e');
    }
  }

  @override
  Future<PostCreation?> getContentById(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) return null;

      final data = PostsFirestoreUtil.mapFromFirestore(
        doc.data() as Map<String, dynamic>,
      );
      data['id'] = doc.id;
      return PostCreation.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get content by id: $e');
    }
  }

  @override
  Stream<PostCreation?> getContentStream(String contentId) {
    return _postsCollection.doc(contentId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final data = PostsFirestoreUtil.mapFromFirestore(
        doc.data() as Map<String, dynamic>,
      );
      data['id'] = doc.id;
      return PostCreation.fromJson(data);
    });
  }

  @override
  Stream<List<PostCreation>> getAllContentStream() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<PostCreation>> getContentByCategory(String category) {
    return _postsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<PostCreation>> getContentByTags(List<String> tags) {
    return _postsCollection
        .where('tags', arrayContainsAny: tags)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<PostCreation>> getRecentContent({int limit = 20}) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Future<PaginatedResult<PostCreation>> getContentPaginated({
    String? lastDocumentId,
    int pageSize = 10,
    SortOrder sortOrder = SortOrder.createdDesc,
  }) async {
    try {
      Query query = _postsCollection;
      query = _applySorting(query, sortOrder);
      query = query.limit(pageSize + 1); // Get one extra to check if there's more

      if (lastDocumentId != null) {
        final lastDoc = await _postsCollection.doc(lastDocumentId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;

      final hasMore = docs.length > pageSize;
      final items = docs.take(pageSize).map((doc) {
        final data = PostsFirestoreUtil.mapFromFirestore(
          doc.data() as Map<String, dynamic>,
        );
        data['id'] = doc.id;
        return PostCreation.fromJson(data);
      }).toList();

      final nextPageToken = hasMore && items.isNotEmpty
          ? items.last.id
          : null;

      // Get total count
      final countSnapshot = await _postsCollection.count().get();
      final totalCount = countSnapshot.count ?? 0;

      return PaginatedResult(
        items: items,
        nextPageToken: nextPageToken,
        hasMore: hasMore,
        totalCount: totalCount,
      );
    } catch (e) {
      throw Exception('Failed to get paginated content: $e');
    }
  }

  @override
  Future<List<PostCreation>> getFilteredContent(ContentFilter filter) async {
    try {
      Query query = _postsCollection;

      if (filter.isAnonymous != null) {
        query = query.where('isAnonymous', isEqualTo: filter.isAnonymous);
      }

      if (filter.isPremium != null) {
        query = query.where('premiumRequired', isEqualTo: filter.isPremium);
      }

      if (filter.visibility != null) {
        query = query.where('visibility', isEqualTo: filter.visibility);
      }

      if (filter.categories != null && filter.categories!.isNotEmpty) {
        query = query.where('category', whereIn: filter.categories);
      }

      if (filter.createdAfter != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(filter.createdAfter!));
      }

      if (filter.createdBefore != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(filter.createdBefore!));
      }

      if (filter.minParticipants != null) {
        query = query.where('stats.participantcount',
            isGreaterThanOrEqualTo: filter.minParticipants);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      return _convertToPostList(snapshot);
    } catch (e) {
      throw Exception('Failed to get filtered content: $e');
    }
  }

  @override
  Future<ContentStatistics> getContentStatistics() async {
    try {
      // Get total posts
      final totalSnapshot = await _postsCollection.count().get();
      final totalPosts = totalSnapshot.count ?? 0;

      // Get active posts (not completed)
      final activeSnapshot = await _postsCollection
          .where('voteCompleted', isEqualTo: false)
          .count()
          .get();
      final activePosts = activeSnapshot.count ?? 0;

      // Get completed votes
      final completedSnapshot = await _postsCollection
          .where('voteCompleted', isEqualTo: true)
          .count()
          .get();
      final completedVotes = completedSnapshot.count ?? 0;

      // Get posts by category
      final categoriesSnapshot = await _postsCollection.get();
      final postsByCategory = <String, int>{};

      for (final doc in categoriesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final category = data['category'] as String? ?? 'uncategorized';
          postsByCategory[category] = (postsByCategory[category] ?? 0) + 1;
        }
      }

      // Calculate average participation
      double totalParticipation = 0;
      int postCount = 0;

      for (final doc in categoriesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final participantCount =
              (data['stats'] as Map<String, dynamic>?)?['participantcount'] as int? ?? 0;
          totalParticipation += participantCount;
          postCount++;
        }
      }

      final averageParticipation = postCount > 0
          ? totalParticipation / postCount
          : 0.0;

      return ContentStatistics(
        totalPosts: totalPosts,
        activePosts: activePosts,
        completedVotes: completedVotes,
        postsByCategory: postsByCategory,
        averageParticipation: averageParticipation,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get content statistics: $e');
    }
  }

  @override
  Future<List<PostCreation>> fullTextSearch(String query, {int limit = 50}) async {
    try {
      // Use Algolia if available
      if (_algolia != null) {
        final index = _algolia!.instance.index('posts');
        final algoliaQuery = index.query(query);
        algoliaQuery.setHitsPerPage(limit);

        final snapshot = await algoliaQuery.getObjects();
        final posts = <PostCreation>[];

        for (final hit in snapshot.hits) {
          final data = hit.data;
          data['id'] = hit.objectID;
          posts.add(PostCreation.fromJson(data));
        }

        return posts;
      }

      // Fallback to Firestore text search
      final snapshot = await _postsCollection
          .where('questionTitle', isGreaterThanOrEqualTo: query)
          .where('questionTitle', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(limit)
          .get();

      return _convertToPostList(snapshot);
    } catch (e) {
      throw Exception('Failed to perform full-text search: $e');
    }
  }

  @override
  Future<List<PostCreation>> getSimilarContent(String contentId, {int limit = 10}) async {
    try {
      // Get the original post
      final originalPost = await getContentById(contentId);
      if (originalPost == null) {
        return [];
      }

      // Find posts with similar tags or category
      Query query = _postsCollection;

      if (originalPost.category != null) {
        query = query.where('category', isEqualTo: originalPost.category);
      }

      if (originalPost.tags != null && originalPost.tags!.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: originalPost.tags!.take(3).toList());
      }

      final snapshot = await query
          .limit(limit + 1) // Get one extra to exclude the original
          .get();

      final posts = _convertToPostList(snapshot);

      // Remove the original post from results
      posts.removeWhere((post) => post.id == contentId);

      return posts.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get similar content: $e');
    }
  }

  // Helper methods
  List<PostCreation> _convertToPostList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = PostsFirestoreUtil.mapFromFirestore(
        doc.data() as Map<String, dynamic>,
      );
      data['id'] = doc.id;
      return PostCreation.fromJson(data);
    }).toList();
  }

  Query _applySorting(Query query, SortOrder sortOrder) {
    switch (sortOrder) {
      case SortOrder.createdDesc:
        return query.orderBy('createdAt', descending: true);
      case SortOrder.createdAsc:
        return query.orderBy('createdAt', descending: false);
      case SortOrder.popularDesc:
        return query.orderBy('stats.participantcount', descending: true)
                   .orderBy('createdAt', descending: true);
      case SortOrder.popularAsc:
        return query.orderBy('stats.participantcount', descending: false)
                   .orderBy('createdAt', descending: true);
      case SortOrder.votesDesc:
        return query.orderBy('totalVotes', descending: true)
                   .orderBy('createdAt', descending: true);
      case SortOrder.votesAsc:
        return query.orderBy('totalVotes', descending: false)
                   .orderBy('createdAt', descending: true);
      case SortOrder.trendingDesc:
        // Trending is a calculated field, so we use participant count as proxy
        return query.orderBy('stats.participantcount', descending: true)
                   .orderBy('createdAt', descending: true);
    }
  }

  @override
  Stream<List<PostCreation>> getAnonymousPosts({int limit = 20}) {
    return _firestore
        .collection('posts')
        .where('isAnonymous', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<PostCreation>> getPremiumPosts({int limit = 20}) {
    return _firestore
        .collection('posts')
        .where('premiumRequired', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_convertToPostList);
  }
}
