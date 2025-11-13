import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../models/search_history.dart';
import '../models/ranking.dart';
import '../failures/search_failure.dart';

/// Repository interface for Search-related operations
/// This interface defines the contract for search functionality
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Future<T> → Future<Either<SearchFailure, T>>
/// - Stream<T> → Stream<Either<SearchFailure, T>>
/// - Clean Architecture v4.0 - Functional Error Handling
abstract class ISearchRepository {
  // ========== Search History Queries ==========

  /// Query searches with optional filters
  /// Returns Stream for real-time updates
  Stream<Either<SearchFailure, List<SearchHistory>>> querySearches({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Count searches matching query
  Future<Either<SearchFailure, int>> querySearchesCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // ========== Search Operations ==========

  /// Save search query to history
  Future<Either<SearchFailure, void>> saveSearchQuery({
    required String userId,
    required String query,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  });

  /// Get user's search history
  Future<Either<SearchFailure, List<SearchHistory>>> getUserSearchHistory({
    required String userId,
    int limit = 10,
  });

  /// Clear all search history for user
  Future<Either<SearchFailure, void>> clearSearchHistory(String userId);

  /// Delete specific search entry
  Future<Either<SearchFailure, void>> deleteSearchEntry(String searchId);

  // ========== Search Suggestions ==========

  /// Get search suggestions based on prefix
  Future<Either<SearchFailure, List<String>>> getSearchSuggestions({
    required String prefix,
    int limit = 5,
  });

  /// Get popular searches
  Future<Either<SearchFailure, List<String>>> getPopularSearches({
    int limit = 10,
    Duration? inLastDuration,
  });

  // ========== Full-Text Search Operations ==========

  /// Search posts
  Future<Either<SearchFailure, List<Map<String, dynamic>>>> searchPosts({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  /// Search users
  Future<Either<SearchFailure, List<Map<String, dynamic>>>> searchUsers({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  /// Search content by type
  Future<Either<SearchFailure, List<Map<String, dynamic>>>> searchContent({
    required String query,
    required String contentType, // 'posts', 'users', 'all'
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  // ========== Rankings - Content Discovery ==========

  /// Update rankings based on voting data
  Future<Either<SearchFailure, void>> updateRankings();

  /// Get top-ranked posts by rank order
  Future<Either<SearchFailure, List<Ranking>>> getTopRankings({int limit = 10});

  /// Stream rankings with optional query builder for filtering
  Stream<Either<SearchFailure, List<Ranking>>> queryRankings({
    dynamic Function(dynamic)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  // ========== Analytics ==========

  /// Get search analytics for date range
  Future<Either<SearchFailure, Map<String, int>>> getSearchAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}
