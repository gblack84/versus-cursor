import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_search_repository.dart';
import '../../domain/failures/search_failure.dart';
import '../../domain/models/search_history.dart';
import '../../domain/models/ranking.dart';

/// Implementation of search repository
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Exception handling → Either<SearchFailure, T>
/// - Functional error handling with fpdart
///
/// **Phase 5 (2025-11-07)**: Extension Pattern (Applied early)
/// - Removed DTO and Mapper classes
/// - Using Ranking.fromFirestore() extension directly
class SearchRepositoryImpl implements ISearchRepository {
  static SearchRepositoryImpl? _instance;
  static SearchRepositoryImpl get instance =>
      _instance ??= SearchRepositoryImpl._();

  SearchRepositoryImpl._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== Search History Queries ==========

  @override
  Stream<Either<SearchFailure, List<SearchHistory>>> querySearches({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query query = _firestore.collection('searches');

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      if (singleRecord) {
        query = query.limit(1);
      }

      return query.snapshots().map((snapshot) {
        try {
          final models = snapshot.docs
              .map((doc) => SearchHistory.fromFirestore(doc))
              .toList();
          return right<SearchFailure, List<SearchHistory>>(models);
        } catch (e) {
          return left<SearchFailure, List<SearchHistory>>(SearchFailure.firestoreReadFailed(
            collection: 'searches',
            message: e.toString(),
          ));
        }
      }).handleError((e) {
        return left<SearchFailure, List<SearchHistory>>(SearchFailure.firestoreReadFailed(
          collection: 'searches',
          message: e.toString(),
        ));
      });
    } catch (e) {
      return Stream.value(left(SearchFailure.unexpected(e.toString())));
    }
  }

  @override
  Future<Either<SearchFailure, int>> querySearchesCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) async {
    try {
      Query query = _firestore.collection('searches');

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.count().get();
      return right(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreReadFailed(
        collection: 'searches',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  // ========== Search Operations ==========

  @override
  Future<Either<SearchFailure, void>> saveSearchQuery({
    required String userId,
    required String query,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // TODO: Implement search query saving
      return left(SearchFailure.unexpected('saveSearchQuery not implemented'));
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreWriteFailed(
        collection: 'search_history',
        operation: 'save',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, List<SearchHistory>>> getUserSearchHistory({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // TODO: Implement user search history
      return left(
          SearchFailure.unexpected('getUserSearchHistory not implemented'));
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreReadFailed(
        collection: 'search_history',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, void>> clearSearchHistory(String userId) async {
    try {
      // TODO: Implement clear search history
      return left(
          SearchFailure.unexpected('clearSearchHistory not implemented'));
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreWriteFailed(
        collection: 'search_history',
        operation: 'delete',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, void>> deleteSearchEntry(String searchId) async {
    try {
      // TODO: Implement delete search entry
      return left(
          SearchFailure.unexpected('deleteSearchEntry not implemented'));
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreWriteFailed(
        collection: 'search_history',
        operation: 'delete',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  // ========== Search Suggestions ==========

  @override
  Future<Either<SearchFailure, List<String>>> getSearchSuggestions({
    required String prefix,
    int limit = 5,
  }) async {
    try {
      // TODO: Implement search suggestions
      return left(
          SearchFailure.unexpected('getSearchSuggestions not implemented'));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, List<String>>> getPopularSearches({
    int limit = 10,
    Duration? inLastDuration,
  }) async {
    try {
      // TODO: Implement popular searches
      return left(
          SearchFailure.unexpected('getPopularSearches not implemented'));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  // ========== Full-Text Search Operations ==========

  @override
  Future<Either<SearchFailure, List<Map<String, dynamic>>>> searchPosts({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // TODO: Implement posts search with Algolia
      return left(SearchFailure.unexpected(
          'searchPosts not implemented - requires Algolia setup'));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, List<Map<String, dynamic>>>> searchUsers({
    required String query,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // TODO: Implement users search with Algolia
      return left(SearchFailure.unexpected(
          'searchUsers not implemented - requires Algolia setup'));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, List<Map<String, dynamic>>>> searchContent({
    required String query,
    required String contentType,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // TODO: Implement content search with Algolia
      return left(SearchFailure.unexpected(
          'searchContent not implemented - requires Algolia setup'));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  // ========== Rankings - Content Discovery ==========

  @override
  Future<Either<SearchFailure, void>> updateRankings() async {
    try {
      // TODO: Implement ranking update logic from voting data
      return left(SearchFailure.unexpected('updateRankings not implemented'));
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreWriteFailed(
        collection: 'rankings',
        operation: 'update',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<SearchFailure, List<Ranking>>> getTopRankings(
      {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('rankings')
          .orderBy('rank')
          .limit(limit)
          .get();

      // Phase 5: Direct extension usage (no DTO/Mapper)
      final rankings = snapshot.docs
          .map((doc) => RankingFirestore.fromFirestore(doc))
          .toList();

      return right(rankings);
    } on FirebaseException catch (e) {
      return left(SearchFailure.firestoreReadFailed(
        collection: 'rankings',
        message: e.message,
      ));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }

  @override
  Stream<Either<SearchFailure, List<Ranking>>> queryRankings({
    dynamic Function(dynamic)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query query = _firestore.collection('rankings');

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      if (singleRecord) {
        query = query.limit(1);
      }

      return query.snapshots().map((snapshot) {
        try {
          // Phase 5: Direct extension usage (no DTO/Mapper)
          final rankings = snapshot.docs
              .map((doc) => RankingFirestore.fromFirestore(doc))
              .toList();
          return right<SearchFailure, List<Ranking>>(rankings);
        } catch (e) {
          return left<SearchFailure, List<Ranking>>(SearchFailure.firestoreReadFailed(
            collection: 'rankings',
            message: e.toString(),
          ));
        }
      }).handleError((e) {
        return left<SearchFailure, List<Ranking>>(SearchFailure.firestoreReadFailed(
          collection: 'rankings',
          message: e.toString(),
        ));
      });
    } catch (e) {
      return Stream.value(left(SearchFailure.unexpected(e.toString())));
    }
  }

  // ========== Analytics ==========

  @override
  Future<Either<SearchFailure, Map<String, int>>> getSearchAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // TODO: Implement search analytics
      return left(
          SearchFailure.unexpected('getSearchAnalytics not implemented'));
    } catch (e) {
      return left(SearchFailure.unexpected(e.toString()));
    }
  }
}
