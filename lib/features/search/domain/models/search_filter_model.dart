import 'package:equatable/equatable.dart';

/// Search Filter Model
///
/// Encapsulates search filter criteria
///
/// **Current Status**: Basic structure (2025-01-20)
/// - Core filter fields defined
/// - Serialization pending
class SearchFilter extends Equatable {
  final List<String>? categories;
  final DateTime? startDate;
  final DateTime? endDate;
  final String sortBy; // 'relevance', 'date', 'popularity'
  final bool descending;

  const SearchFilter({
    this.categories,
    this.startDate,
    this.endDate,
    this.sortBy = 'relevance',
    this.descending = true,
  });

  // TODO: Add JSON serialization
  // Map<String, dynamic> toJson() {}
  // factory SearchFilter.fromJson(Map<String, dynamic> json) {}

  SearchFilter copyWith({
    List<String>? categories,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool? descending,
  }) {
    return SearchFilter(
      categories: categories ?? this.categories,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      sortBy: sortBy ?? this.sortBy,
      descending: descending ?? this.descending,
    );
  }

  @override
  List<Object?> get props => [categories, startDate, endDate, sortBy, descending];
}
