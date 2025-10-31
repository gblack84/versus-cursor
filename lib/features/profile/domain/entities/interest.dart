import 'package:freezed_annotation/freezed_annotation.dart';

part 'interest.freezed.dart';
part 'interest.g.dart';

/// 사용자 관심사 도메인 모델
///
/// **책임**: 사용자의 관심 분야 표현 (직무, 전문성, 취미)
///
/// **제약사항**:
/// - expertise (전문성): 최대 4개
/// - hobbies (취미): 최대 8개
@freezed
sealed class Interest with _$Interest {
  const Interest._();

  const factory Interest({
    /// 관심사 고유 ID
    required String id,

    /// 관심사 이름
    required String name,

    /// 관심사 카테고리 (job, expertise, hobby)
    required String category,

    /// 가중치 (우선순위, 0.0 ~ 1.0)
    @Default(0.5) double weight,

    /// 선택된 날짜
    DateTime? selectedAt,
  }) = _Interest;

  factory Interest.fromJson(Map<String, dynamic> json) =>
      _$InterestFromJson(json);

  /// String으로부터 간단한 Interest 객체 생성
  ///
  /// UI 표시 목적으로 String 리스트를 Interest로 변환할 때 사용
  factory Interest.fromString(String name, String category) {
    return Interest(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      category: category,
    );
  }
}
