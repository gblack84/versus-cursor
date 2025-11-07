import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_filter_model.freezed.dart';
part 'search_filter_model.g.dart';

/// Search Filter Model
///
/// Encapsulates search filter criteria
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 모델
/// - JSON serialization 자동 생성
/// - copyWith, ==, hashCode 자동 구현
///
/// **Migration Status**: Migrated to Freezed (2025-11-07)
/// - ✅ Equatable 제거
/// - ✅ JSON serialization 추가
/// - ✅ Immutable pattern
@freezed
sealed class SearchFilter with _$SearchFilter {
  const factory SearchFilter({
    List<String>? categories,
    DateTime? startDate,
    DateTime? endDate,
    @Default('relevance') String sortBy, // 'relevance', 'date', 'popularity'
    @Default(true) bool descending,
  }) = _SearchFilter;

  factory SearchFilter.fromJson(Map<String, dynamic> json) =>
      _$SearchFilterFromJson(json);
}
