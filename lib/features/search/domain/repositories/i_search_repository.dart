import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_history_model.dart';
import '../models/ranking.dart';

/// Repository interface for Search-related operations
/// This interface defines the contract for search functionality
abstract class ISearchRepository {
  // Search history queries
  Stream<List<SearchesModel>> querySearches({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> querySearchesCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Search operations
  Future<void> saveSearchQuery({
    required String userId,
    required String query,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  });

  Future<List<SearchesModel>> getUserSearchHistory({
    required String userId,
    int limit = 10,
  });

  Future<void> clearSearchHistory(String userId);

  Future<void> deleteSearchEntry(String searchId);

  // Search suggestions
  Future<List<String>> getSearchSuggestions({
    required String prefix,
    int limit = 5,
  });

  Future<List<String>> getPopularSearches({
    int limit = 10,
    Duration? inLastDuration,
  });

  // Full-text search operations
  Future<List<Map<String, dynamic>>> searchPosts({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  Future<List<Map<String, dynamic>>> searchContent({
    required String query,
    required String contentType, // 'posts', 'users', 'all'
    int limit = 20,
    Map<String, dynamic>? filters,
  });

  // Rankings - Content Discovery
  /// Update rankings based on voting data
  Future<void> updateRankings();

  /// Get top-ranked posts by rank order
  Future<List<Ranking>> getTopRankings({int limit = 10});

  /// Stream rankings with optional query builder for filtering
  Stream<List<Ranking>> queryRankings({
    dynamic Function(dynamic)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  // Analytics
  Future<Map<String, int>> getSearchAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}
