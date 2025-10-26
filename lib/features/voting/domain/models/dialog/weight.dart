import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight.freezed.dart';
part 'weight.g.dart';

/// 관심사 가중치 도메인 모델
///
/// 순수 비즈니스 로직 레이어의 immutable 엔티티
@freezed
sealed class Weight with _$Weight {
  const Weight._();

  const factory Weight({
    /// 관심사 이름 (필수)
    @Default('') String nameInterest,

    /// 관심사 점수 (필수)
    @Default(0) int scoreInterest,
  }) = _Weight;

  factory Weight.fromJson(Map<String, dynamic> json) => _$WeightFromJson(json);
}
