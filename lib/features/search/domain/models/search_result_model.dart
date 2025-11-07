import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result_model.freezed.dart';
part 'search_result_model.g.dart';

/// Search Result Model
///
/// Unified search result for all types (posts, users, chats)
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 모델
/// - JSON serialization 자동 생성
/// - copyWith, ==, hashCode 자동 구현
/// - Union types 지원 (향후 타입별 분리 가능)
///
/// **Migration Status**: Migrated to Freezed (2025-11-07)
/// - ✅ Equatable 제거
/// - ✅ JSON serialization 추가
/// - ✅ Immutable pattern
@freezed
sealed class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String id,
    required String type, // 'post', 'user', 'chat'
    required String title,
    String? description,
    String? imageUrl,
    @Default(0.0) double relevanceScore,
    Map<String, dynamic>? metadata, // Type-specific data
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}
