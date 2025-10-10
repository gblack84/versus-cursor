import '../../domain/models/post_display.dart';
import '../../domain/repositories/i_post_display_repository_v2.dart';
import '../datasources/interfaces/i_post_display_datasource.dart';
import '../dto/post_display_dto.dart';
import '../mappers/post_display_mapper.dart';

/// Implementation of IPostDisplayRepositoryV2
///
/// This implementation uses DataSource to isolate Firebase dependencies
/// and converts raw data to PostDisplay models.
class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;

  PostDisplayRepositoryV2Impl({
    required IPostDisplayDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _dataSource.queryPosts(
      queryBuilder: queryBuilder ?? (params) => params,
      limit: singleRecord ? 1 : limit > 0 ? limit : null,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Future<PostDisplay?> getPost(String postId) async {
    final data = await _dataSource.getPost(postId);
    if (data == null) return null;

    final id = data['id'] as String;
    final dto = PostDisplayDto.fromFirestore(data, id);
    return PostDisplayMapper.toDomain(dto);
  }

  @override
  Stream<PostDisplay?> streamPost(String postId) {
    // Stream a single post by querying with ID filter
    return _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'where': {'id': postId},
      },
      limit: 1,
    ).map((dataList) {
      if (dataList.isEmpty) return null;

      final data = dataList.first;
      final id = data['id'] as String;
      final dto = PostDisplayDto.fromFirestore(data, id);
      return PostDisplayMapper.toDomain(dto);
    });
  }

  @override
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20}) {
    // Get recent posts and sort by engagement
    return _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'orderBy': 'createdAt',
        'descending': true,
      },
      limit: 100, // Get recent 100 posts
    ).map((dataList) {
      final posts = dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();

      // Sort by engagement (likes + comments + shares)
      posts.sort((a, b) {
        final engagementA = a.totalEngagement;
        final engagementB = b.totalEngagement;
        return engagementB.compareTo(engagementA);
      });

      // Return top N posts
      return posts.take(limit).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getUserPosts({
    required String userId,
    int limit = -1,
  }) {
    return _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'where': {'userid': userId},
        'orderBy': 'createdAt',
        'descending': true,
      },
      limit: limit > 0 ? limit : null,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getPostsByCategory({
    required String category,
    int limit = -1,
  }) {
    return _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'where': {'category': category},
        'orderBy': 'createdAt',
        'descending': true,
      },
      limit: limit > 0 ? limit : null,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1}) {
    return _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'where': {'voteStatus': 'in_progress'},
        'orderBy': 'voteStartTime',
        'descending': true,
      },
      limit: limit > 0 ? limit : null,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Future<List<PostDisplay>> searchPosts({
    required String query,
    int limit = 20,
  }) async {
    // Simple text search - in production, use Algolia or similar
    // Get recent posts and filter client-side
    final dataList = await _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'orderBy': 'createdAt',
        'descending': true,
      },
      limit: 200,
    ).first; // Get first emission of stream

    final posts = dataList.map((data) {
      final id = data['id'] as String;
      final dto = PostDisplayDto.fromFirestore(data, id);
      return PostDisplayMapper.toDomain(dto);
    }).where((post) {
      final searchLower = query.toLowerCase();
      final titleMatch = post.questionTitle.toLowerCase().contains(searchLower);
      final descMatch = post.description?.toLowerCase().contains(searchLower) ?? false;
      return titleMatch || descMatch;
    }).take(limit).toList();

    return posts;
  }

  @override
  Future<void> incrementViewCount(String postId) async {
    // Increment view count through DataSource
    await _dataSource.updatePostMetrics(postId, {
      'viewCount': {'increment': 1}, // Custom increment format for DataSource
    });
  }

  @override
  Future<List<PostDisplay>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  }) async {
    // Simple recommendation: Get recent posts excluding user's own
    final dataList = await _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'where': {
          'userid': {'operator': 'isNotEqualTo', 'value': userId},
        },
        'orderBy': 'createdAt',
        'descending': true,
      },
      limit: limit * 2,
    ).first; // Get first emission

    final posts = dataList.map((data) {
      final id = data['id'] as String;
      final dto = PostDisplayDto.fromFirestore(data, id);
      return PostDisplayMapper.toDomain(dto);
    }).toList();

    // Shuffle and return limited results for variety
    posts.shuffle();
    return posts.take(limit).toList();
  }

  @override
  Future<List<PostDisplay>> getPostsByIds(List<String> postIds) async {
    if (postIds.isEmpty) return [];

    final dataList = await _dataSource.getPostsByIds(postIds);
    return dataList.map((data) {
      final id = data['id'] as String;
      final dto = PostDisplayDto.fromFirestore(data, id);
      return PostDisplayMapper.toDomain(dto);
    }).toList();
  }

  @override
  Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1}) {
    return _dataSource.queryPosts(
      queryBuilder: (params) => {
        ...params,
        'where': {'voteStatus': 'completed'},
        'orderBy': 'voteEndTime',
        'descending': true,
      },
      limit: limit > 0 ? limit : null,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getPopularPosts({
    int limit = 20,
    Duration? timeWindow,
  }) {
    return _dataSource.queryPosts(
      queryBuilder: (params) {
        final queryParams = <String, dynamic>{
          ...params,
          'orderBy': 'likecount',
          'descending': true,
        };

        // If time window specified, add date filter
        if (timeWindow != null) {
          final cutoffDate = DateTime.now().subtract(timeWindow);
          queryParams['where'] = {
            'createdAt': {
              'operator': 'isGreaterThan',
              'value': cutoffDate,
            },
          };
        }

        return queryParams;
      },
      limit: limit,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Stream<List<PostDisplay>> getPostsAfter({
    required String lastPostId,
    int limit = 20,
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
  }) {
    return _dataSource.queryPosts(
      queryBuilder: (params) {
        final baseQuery = queryBuilder?.call(params) ?? params;
        return {
          ...baseQuery,
          'startAfterId': lastPostId,
        };
      },
      limit: limit,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
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
    return _dataSource.queryPosts(
      queryBuilder: (params) {
        final queryParams = <String, dynamic>{...params};
        final whereConditions = <String, dynamic>{};

        if (userId != null) {
          whereConditions['userid'] = userId;
        }

        if (status != null) {
          whereConditions['status'] = status;
        }

        if (isAnonymous != null) {
          whereConditions['isAnonymous'] = isAnonymous;
        }

        if (createdAfter != null) {
          whereConditions['createdAt'] = {
            'operator': 'isGreaterThan',
            'value': createdAfter,
          };
        }

        if (createdBefore != null) {
          // If createdAfter already exists, we need to handle range query
          if (createdAfter != null) {
            // Firebase limitation: use createdBefore as secondary filter
            // This would require compound query support in DataSource
            whereConditions['createdAt'] = {
              'operator': 'isGreaterThan',
              'value': createdAfter,
            };
          } else {
            whereConditions['createdAt'] = {
              'operator': 'isLessThan',
              'value': createdBefore,
            };
          }
        }

        if (whereConditions.isNotEmpty) {
          queryParams['where'] = whereConditions;
        }

        queryParams['orderBy'] = 'createdAt';
        queryParams['descending'] = true;

        return queryParams;
      },
      limit: limit,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }
}