import 'package:equatable/equatable.dart';
import 'search_filter_model.dart';

/// Search Query Model
///
/// Encapsulates all search request parameters
///
/// **Current Status**: Basic structure (2025-01-20)
/// - Core fields defined
/// - Serialization pending
class SearchQuery extends Equatable {
  final String query;
  final SearchFilter? filter;
  final int page;
  final int limit;

  const SearchQuery({
    required this.query,
    this.filter,
    this.page = 0,
    this.limit = 20,
  });

  // TODO: Add JSON serialization
  // Map<String, dynamic> toJson() {}
  // factory SearchQuery.fromJson(Map<String, dynamic> json) {}

  SearchQuery copyWith({
    String? query,
    SearchFilter? filter,
    int? page,
    int? limit,
  }) {
    return SearchQuery(
      query: query ?? this.query,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  List<Object?> get props => [query, filter, page, limit];
}
