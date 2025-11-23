import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'search_history.freezed.dart';
part 'search_history.g.dart';
part 'search_history_extensions.dart';

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
}
