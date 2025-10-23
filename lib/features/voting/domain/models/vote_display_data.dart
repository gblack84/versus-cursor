import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_display_data.freezed.dart';
part 'vote_display_data.g.dart';

/// 투표 알림에서 추출된 데이터를 담는 클래스
///
/// **Clean Architecture v4.0 - Freezed Domain Entity**:
/// - Immutable value object with auto-generated copyWith
/// - JSON serialization support for caching/persistence
/// - Business logic in getters (isEmpty)
@freezed
sealed class VoteDisplayData with _$VoteDisplayData {
  const VoteDisplayData._();

  const factory VoteDisplayData({
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    @Default('') String description,
    double? aspectRatioA,
    double? aspectRatioB,
    String? layoutType,
    String? authorName,
  }) = _VoteDisplayData;

  factory VoteDisplayData.fromJson(Map<String, dynamic> json) =>
      _$VoteDisplayDataFromJson(json);

  /// Empty VoteDisplayData factory
  factory VoteDisplayData.empty() {
    return const VoteDisplayData(
      question: '',
      optionA: '',
      optionB: '',
      description: '',
    );
  }

  // ============================================================================
  // Business Logic
  // ============================================================================

  /// 필수 필드가 모두 비어있는지 확인
  bool get isEmpty => question.isEmpty && optionA.isEmpty && optionB.isEmpty;
}
