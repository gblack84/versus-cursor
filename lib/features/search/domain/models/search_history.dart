import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'search_history.freezed.dart';
part 'search_history.g.dart';

/// Search history tracking
///
/// Records user search queries for search history and analytics.
/// Stored in Firestore 'searches' collection.
@freezed
sealed class SearchHistory with _$SearchHistory {
  const SearchHistory._();

  const factory SearchHistory({
    required String searchId,
    required String userId,
    required String query,
    DateTime? date,
  }) = _SearchHistory;

  factory SearchHistory.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryFromJson(json);

  /// Firestore → Entity
  ///
  /// Converts Firestore DocumentSnapshot to SearchHistory entity.
  /// Uses document ID as searchId.
  factory SearchHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SearchHistory(
      searchId: doc.id,
      userId: data['userId'] as String? ?? '',
      query: data['query'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  /// Entity → Firestore
  ///
  /// Converts SearchHistory entity to Firestore-compatible Map.
  /// Omits searchId as it's stored as document ID.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'query': query,
      if (date != null) 'date': Timestamp.fromDate(date!),
    };
  }
}
