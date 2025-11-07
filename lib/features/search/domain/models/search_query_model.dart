import 'package:freezed_annotation/freezed_annotation.dart';
import 'search_filter_model.dart';

part 'search_query_model.freezed.dart';
part 'search_query_model.g.dart';

/// Search Query Model
///
/// Encapsulates all search request parameters
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
sealed class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    required String query,
    SearchFilter? filter,
    @Default(0) int page,
    @Default(20) int limit,
  }) = _SearchQuery;

  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);
}
