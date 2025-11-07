import 'package:freezed_annotation/freezed_annotation.dart';

part 'algolia_result_model.freezed.dart';
part 'algolia_result_model.g.dart';

/// Algolia Search Result Model
///
/// Wrapper for Algolia API response
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 모델
/// - JSON serialization 자동 생성
/// - copyWith, ==, hashCode 자동 구현
/// - Custom getters 지원
///
/// **Migration Status**: Migrated to Freezed (2025-11-07)
/// - ✅ Equatable 제거
/// - ✅ JSON serialization 추가
/// - ✅ Immutable pattern
/// - ✅ Custom getters (hasMore, isEmpty)
@freezed
sealed class AlgoliaResult with _$AlgoliaResult {
  const AlgoliaResult._();

  const factory AlgoliaResult({
    required List<dynamic> hits,
    required int totalHits,
    required int page,
    required int nbPages,
    @Default(20) int hitsPerPage,
  }) = _AlgoliaResult;

  factory AlgoliaResult.fromJson(Map<String, dynamic> json) =>
      _$AlgoliaResultFromJson(json);

  // Custom getters
  bool get hasMore => page < nbPages - 1;
  bool get isEmpty => hits.isEmpty;
}
