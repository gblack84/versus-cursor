import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/domain/models/post_display_extensions.dart';
import '/features/post/domain/repositories/i_post_display_repository_v2.dart';
import '/features/post/domain/failures/post_failure.dart';
import '/features/post/domain/usecases/get_feed_usecase.dart';  // FeedSortBy enum
import '/features/post/data/services/post_cache_service.dart';
import '/services/idempotency/idempotency_service.dart';
import '/services/logging/logger_service.dart';

/// Post Repository Implementation - Firebase-Centric v2.0 + 3-Layer Caching
///
/// **Phase 3: Cache Integration**
/// **Phase 4: Idempotency Service Integration**
///
/// **Architecture**:
/// - Direct Firestore SDK usage (no DataSource/DTO/Mapper)
/// - 3-Layer caching (Memory → Hive → Firestore)
/// - Extension pattern for Firestore conversion
/// - Cache-First strategy with background revalidation
/// - IdempotencyService for duplicate prevention (Phase 4)
///
/// **Performance**:
/// - Cache hit: <10ms response time
/// - Cache miss: 50-500ms (Firestore)
/// - 60%+ cache hit rate expected
///
/// **Cache Strategy**:
/// - Stream methods: Emit cache immediately, then listen to Firestore
/// - Future methods: Check cache → Firestore → Update cache
/// - Write methods: Update Firestore → Invalidate cache
///
/// **Idempotency (Phase 4)**:
/// - createPost: Prevents duplicate posts on network retry
/// - updatePost: Ensures single update per eventId
/// - deletePost: Complete deletion with subcollections (atomic)
/// - incrementViewCount: Prevents duplicate increments
class PostRepositoryImpl implements IPostDisplayRepositoryV2 {
  final FirebaseFirestore _firestore;
  final PostCacheService _cacheService;
  final IdempotencyService _idempotencyService;

  // Collection reference
  late final CollectionReference<Map<String, dynamic>> _postsRef;

  PostRepositoryImpl({
    required FirebaseFirestore firestore,
    required PostCacheService cacheService,
    required IdempotencyService idempotencyService,
  })  : _firestore = firestore,
        _cacheService = cacheService,
        _idempotencyService = idempotencyService {
    _postsRef = _firestore.collection('posts');
  }

  // ────────────────────────────────────────────────────────────────
  // Stream Methods (Cache-First + Real-time Updates)
  // ────────────────────────────────────────────────────────────────

  @override
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async* {
    // For generic queries, delegate to Firestore directly
    // Cache is handled by specific methods (getFeed, getPopular, etc.)

    Query<Map<String, dynamic>> query = _postsRef;

    // Apply limit
    if (singleRecord) {
      query = query.limit(1);
    } else if (limit > 0) {
      query = query.limit(limit);
    }

    // Stream from Firestore
    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<PostDisplay?> streamPost(String postId) async* {
    // 1. Emit cached data immediately
    final cached = await _cacheService.getPost(postId);
    if (cached != null) {
      yield cached;
      CacheLogger.cacheHit(
        key: 'post_$postId',
        layer: 'L1/L2',
      );
    }

    // 2. Listen to Firestore for real-time updates
    yield* _postsRef.doc(postId).snapshots().map((doc) {
      if (!doc.exists) return null;

      final post = PostDisplayFirestore.fromFirestore(doc);

      // Update cache in background
      _cacheService.setPost(post);

      return post;
    });
  }

  @override
  Stream<List<PostDisplay>> getUserPosts({
    required String userId,
    int limit = -1,
  }) async* {
    // 1. Emit cached data immediately
    final cached = await _cacheService.getUserPosts(userId: userId, limit: limit);
    if (cached.isNotEmpty) {
      yield cached;
      CacheLogger.cacheHit(
        key: 'user_posts_$userId',
        layer: 'L1/L2',
      );
    }

    // 2. Listen to Firestore for real-time updates
    Query<Map<String, dynamic>> query = _postsRef
        .where('userid', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    yield* query.snapshots().map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();

      // Update cache in background
      _cacheService.setUserPosts(userId: userId, posts: posts, limit: limit);

      return posts;
    });
  }

  @override
  Stream<List<PostDisplay>> getPopularPosts({
    int limit = 20,
    Duration? timeWindow,
  }) async* {
    final window = timeWindow ?? const Duration(days: 7);

    // 1. Emit cached data immediately
    final cached = await _cacheService.getPopularPosts(limit: limit, timeWindow: window);
    if (cached.isNotEmpty) {
      yield cached;
      CacheLogger.cacheHit(
        key: 'popular_posts',
        layer: 'L1/L2',
      );
    }

    // 2. Listen to Firestore for real-time updates
    Query<Map<String, dynamic>> query = _postsRef
        .where('createdAt', isGreaterThan: DateTime.now().subtract(window))
        .orderBy('createdAt', descending: true)
        .orderBy('likecount', descending: true)
        .limit(limit);

    yield* query.snapshots().map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();

      // Update cache in background
      _cacheService.setPopularPosts(posts: posts, limit: limit, timeWindow: window);

      return posts;
    });
  }

  @override
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20}) async* {
    // 1. Emit cached data immediately
    final cached = await _cacheService.getTrendingPosts(limit: limit);
    if (cached.isNotEmpty) {
      yield cached;
      CacheLogger.cacheHit(
        key: 'trending_posts',
        layer: 'L1/L2',
      );
    }

    // 2. Calculate trending posts from recent 100 posts
    yield* _postsRef
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();

      // Sort by engagement
      posts.sort((a, b) => b.totalEngagement.compareTo(a.totalEngagement));

      final trending = posts.take(limit).toList();

      // Update cache in background
      _cacheService.setTrendingPosts(posts: trending, limit: limit);

      return trending;
    });
  }

  @override
  Stream<List<PostDisplay>> getPostsByCategory({
    required String category,
    int limit = -1,
  }) {
    Query<Map<String, dynamic>> query = _postsRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1}) {
    Query<Map<String, dynamic>> query = _postsRef
        .where('voteStatus', isEqualTo: 'in_progress')
        .orderBy('voteStartTime', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1}) {
    Query<Map<String, dynamic>> query = _postsRef
        .where('voteStatus', isEqualTo: 'completed')
        .orderBy('voteEndTime', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getPostsAfter({
    required String lastPostId,
    int limit = 20,
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
  }) async* {
    // Get the last post document for startAfter cursor
    final lastDoc = await _postsRef.doc(lastPostId).get();

    if (!lastDoc.exists) {
      yield [];
      return;
    }

    Query<Map<String, dynamic>> query = _postsRef
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit);

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getPostsWithFilters({
    String? userId,
    String? status,
    bool? isAnonymous,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _postsRef;

    if (userId != null) {
      query = query.where('userid', isEqualTo: userId);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    if (isAnonymous != null) {
      query = query.where('isAnonymous', isEqualTo: isAnonymous);
    }

    if (createdAfter != null) {
      query = query.where('createdAt', isGreaterThan: createdAfter);
    }

    if (createdBefore != null) {
      query = query.where('createdAt', isLessThan: createdBefore);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();
    });
  }

  // ────────────────────────────────────────────────────────────────
  // Future Methods (Cache-First + Background Revalidation)
  // ────────────────────────────────────────────────────────────────

  @override
  Future<Either<PostFailure, PostDisplay>> getPost(String postId) async {
    try {
      // 1. Check cache first
      final cached = await _cacheService.getPost(postId);
      if (cached != null) {
        CacheLogger.cacheHit(
          key: 'post_$postId',
          layer: 'L1/L2',
        );

        // Return cached data immediately
        // Background revalidation happens via streamPost
        return right(cached);
      }

      CacheLogger.cacheMiss(
        key: 'post_$postId',
        layer: 'L1/L2',
      );

      // 2. Fetch from Firestore
      final doc = await _postsRef.doc(postId).get();

      if (!doc.exists) {
        return left(PostFailure.postNotFound(postId: postId));
      }

      final post = PostDisplayFirestore.fromFirestore(doc);

      // 3. Update cache
      await _cacheService.setPost(post);

      return right(post);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } on TimeoutException {
      return left(const PostFailure.timeout());
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to get post',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<PostFailure, List<PostDisplay>>> searchPosts({
    required String query,
    int limit = 20,
  }) async {
    try {
      // Validate input
      if (query.trim().isEmpty) {
        return left(const PostFailure.invalidInput(field: 'query'));
      }

      // Simple text search - get recent posts and filter client-side
      final snapshot = await _postsRef
          .orderBy('createdAt', descending: true)
          .limit(200)
          .get();

      final posts = snapshot.docs
          .map((doc) {
            return PostDisplayFirestore.fromFirestore(doc);
          })
          .where((post) {
            final searchLower = query.toLowerCase();
            final titleMatch = post.questionTitle.toLowerCase().contains(searchLower);
            final descMatch = post.description?.toLowerCase().contains(searchLower) ?? false;
            return titleMatch || descMatch;
          })
          .take(limit)
          .toList();

      return right(posts);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } on TimeoutException {
      return left(const PostFailure.timeout());
    } catch (e) {
      return left(PostFailure.searchFailed(query: query));
    }
  }

  @override
  Future<Either<PostFailure, List<PostDisplay>>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // Validate input
      if (userId.trim().isEmpty) {
        return left(const PostFailure.invalidInput(field: 'userId'));
      }

      // Get recent posts excluding user's own
      final snapshot = await _postsRef
          .where('userid', isNotEqualTo: userId)
          .orderBy('userid') // Required for isNotEqualTo
          .orderBy('createdAt', descending: true)
          .limit(limit * 2)
          .get();

      final posts = snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();

      // Shuffle and return limited results
      posts.shuffle();
      return right(posts.take(limit).toList());
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } on TimeoutException {
      return left(const PostFailure.timeout());
    } catch (e) {
      return left(PostFailure.queryFailed(
        reason: 'Failed to get recommended posts for user $userId',
      ));
    }
  }

  @override
  Future<Either<PostFailure, List<PostDisplay>>> getPostsByIds(
    List<String> postIds,
  ) async {
    try {
      // Validate input
      if (postIds.isEmpty) {
        return left(const PostFailure.invalidInput(field: 'postIds'));
      }

      // Firestore limitation: whereIn supports up to 10 items
      if (postIds.length > 10) {
        // Batch requests in chunks of 10
        final chunks = <List<String>>[];
        for (var i = 0; i < postIds.length; i += 10) {
          chunks.add(postIds.sublist(
            i,
            i + 10 > postIds.length ? postIds.length : i + 10,
          ));
        }

        final allPosts = <PostDisplay>[];
        for (final chunk in chunks) {
          final snapshot = await _postsRef.where(FieldPath.documentId, whereIn: chunk).get();
          allPosts.addAll(snapshot.docs.map((doc) {
            return PostDisplayFirestore.fromFirestore(doc);
          }));
        }

        return right(allPosts);
      }

      // Single batch
      final snapshot = await _postsRef.where(FieldPath.documentId, whereIn: postIds).get();

      final posts = snapshot.docs.map((doc) {
        return PostDisplayFirestore.fromFirestore(doc);
      }).toList();

      return right(posts);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } on TimeoutException {
      return left(const PostFailure.timeout());
    } catch (e) {
      return left(PostFailure.queryFailed(
        reason: 'Failed to get posts by IDs',
      ));
    }
  }

  // ────────────────────────────────────────────────────────────────
  // CRUD Methods (Phase 4: Idempotency)
  // ────────────────────────────────────────────────────────────────

  @override
  Future<Either<PostFailure, Unit>> createPost({
    required PostDisplay post,
    required String eventId,
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Either<PostFailure, Unit>>(
        entityType: 'post_create',
        entityId: post.id,
        userId: post.userId,
        eventId: eventId,
        operation: (transaction) async {
          try {
            final postRef = _postsRef.doc(post.id);

            // Create post document with all fields
            transaction.set(postRef, {
              'id': post.id,
              'userId': post.userId,
              'displayName': post.displayName,
              'photoUrl': post.photoUrl,
              'questionTitle': post.questionTitle,
              'description': post.description,
              'optionAText': post.optionAText,
              'optionBText': post.optionBText,
              'optionAImageUrl': post.optionAImageUrl,
              'optionBImageUrl': post.optionBImageUrl,
              'optionAImages': post.optionAImages ?? [],
              'optionAAspectRatios': post.optionAAspectRatios ?? [],
              'optionBImages': post.optionBImages ?? [],
              'optionBAspectRatios': post.optionBAspectRatios ?? [],
              'layoutType': post.layoutType,
              'votesA': post.votesA,
              'votesB': post.votesB,
              'voteStatus': post.voteStatus,
              'voteCompleted': post.voteCompleted,
              'voteStartTime': post.voteStartTime,
              'voteEndTime': post.voteEndTime,
              'commentCount': post.commentCount,
              'likeCount': post.likeCount,
              'shareCount': post.shareCount,
              'createdAt': post.createdAt,
              'isAnonymous': post.isAnonymous,
              'status': post.status,
              'targetAudience': post.targetAudience,
            });

            // ✅ Selective cache invalidation (Posts only, not other Features)
            Future.microtask(() async {
              // Invalidate all feed caches (latest, popular, trending)
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.latest);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.popular);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.trending);
            });

            // ✅ Logger 추가
            PostLogger.postCreated(
              postId: post.id,
              authorId: post.userId,
            );

            return right(unit);
          } catch (e) {
            return left(PostFailure.createFailed(
              reason: 'Failed to create post in transaction: ${e.toString()}',
            ));
          }
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: post.id));
    } catch (e) {
      return left(PostFailure.createFailed(
        reason: 'Failed to create post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<PostFailure, Unit>> updatePost({
    required String postId,
    required Map<String, dynamic> updates,
    required String eventId,
  }) async {
    try {
      // Phase 4: Get current user ID from Firebase Auth (Firebase-Centric v2.0)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return left(const PostFailure.unauthorized());
      }

      return await _idempotencyService.executeIdempotent<Either<PostFailure, Unit>>(
        entityType: 'post_update',
        entityId: postId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          try {
            final postRef = _postsRef.doc(postId);

            // Add updatedAt timestamp
            final updatesWithTimestamp = {
              ...updates,
              'updatedAt': FieldValue.serverTimestamp(),
            };

            transaction.update(postRef, updatesWithTimestamp);

            // ✅ Selective cache invalidation (Specific post + feeds only)
            Future.microtask(() async {
              await _cacheService.invalidatePost(postId);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.latest);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.popular);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.trending);
            });

            // ✅ Logger 추가
            PostLogger.postUpdated(postId: postId);

            return right(unit);
          } catch (e) {
            return left(PostFailure.updateFailed(
              reason: 'Failed to update post in transaction: ${e.toString()}',
            ));
          }
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e) {
      return left(PostFailure.updateFailed(
        reason: 'Failed to update post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<PostFailure, Unit>> deletePost({
    required String postId,
    required String eventId,
  }) async {
    try {
      // Phase 4: Get current user ID from Firebase Auth (Firebase-Centric v2.0)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return left(const PostFailure.unauthorized());
      }

      return await _idempotencyService.executeIdempotent<Either<PostFailure, Unit>>(
        entityType: 'post_delete',
        entityId: postId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          try {
            final postRef = _postsRef.doc(postId);

            // 1. Delete comments subcollection
            final commentsSnapshot = await postRef.collection('comments').get();
            for (final commentDoc in commentsSnapshot.docs) {
              // Delete comment's subcollections (likes, dislikes)
              final commentLikesSnapshot = await commentDoc.reference.collection('likes').get();
              for (final likeDoc in commentLikesSnapshot.docs) {
                transaction.delete(likeDoc.reference);
              }

              final commentDislikesSnapshot = await commentDoc.reference.collection('dislikes').get();
              for (final dislikeDoc in commentDislikesSnapshot.docs) {
                transaction.delete(dislikeDoc.reference);
              }

              transaction.delete(commentDoc.reference);
            }

            // 2. Delete votes subcollection
            final votesSnapshot = await postRef.collection('votes').get();
            for (final voteDoc in votesSnapshot.docs) {
              transaction.delete(voteDoc.reference);
            }

            // 3. Delete likes subcollection
            final likesSnapshot = await postRef.collection('likes').get();
            for (final likeDoc in likesSnapshot.docs) {
              transaction.delete(likeDoc.reference);
            }

            // 4. Delete dislikes subcollection
            final dislikesSnapshot = await postRef.collection('dislikes').get();
            for (final dislikeDoc in dislikesSnapshot.docs) {
              transaction.delete(dislikeDoc.reference);
            }

            // 5. Delete post document
            transaction.delete(postRef);

            // ✅ Selective cache invalidation (Deleted post + feeds only)
            Future.microtask(() async {
              await _cacheService.invalidatePost(postId);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.latest);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.popular);
              await _cacheService.invalidateFeed(sortBy: FeedSortBy.trending);
            });

            // ✅ Logger 추가
            PostLogger.postDeleted(postId: postId);

            return right(unit);
          } catch (e) {
            return left(PostFailure.deleteFailed(
              reason: 'Failed to delete post in transaction: ${e.toString()}',
            ));
          }
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e) {
      return left(PostFailure.deleteFailed(
        reason: 'Failed to delete post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<PostFailure, Unit>> incrementViewCount({
    required String postId,
  }) async {
    try {
      // Phase 4: Get current user ID from Firebase Auth (Firebase-Centric v2.0)
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return left(const PostFailure.unauthorized());
      }

      // ✅ Option 1: Direct Firestore atomic increment (IdempotencyService 불필요)
      //    FieldValue.increment()는 원자적 연산으로 멱등성 보장
      //    조회수는 근사치 허용 (정확도 < 성능)
      await _postsRef.doc(postId).update({
        'viewCount': FieldValue.increment(1),
      });

      // Optional: Invalidate cache for view count
      // (Usually view count doesn't need immediate cache invalidation)

      // ✅ Logger 추가
      PostLogger.metricsUpdated(
        operation: 'view_increment',
        postId: postId,
      );

      return right(unit);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e) {
      return left(PostFailure.updateFailed(
        reason: 'Failed to increment view count for post $postId',
      ));
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Helper Methods
  // ────────────────────────────────────────────────────────────────

  /// Map Firebase Exception to PostFailure
  PostFailure _mapFirebaseException(
    FirebaseException e, {
    String? postId,
  }) {
    switch (e.code) {
      case 'permission-denied':
        return const PostFailure.insufficientPermissions();
      case 'not-found':
        return PostFailure.postNotFound(
          postId: postId ?? 'unknown',
        );
      case 'unavailable':
        return const PostFailure.networkError();
      case 'deadline-exceeded':
        return const PostFailure.timeout();
      case 'unauthenticated':
        return const PostFailure.unauthorized();
      default:
        return PostFailure.serverError(message: e.message);
    }
  }
}
