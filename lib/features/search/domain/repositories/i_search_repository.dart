import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_history_model.dart';

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

  // Analytics
  Future<Map<String, int>> getSearchAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
}
