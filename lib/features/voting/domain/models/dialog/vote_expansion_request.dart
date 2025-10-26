import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_expansion_request.freezed.dart';
part 'vote_expansion_request.g.dart';

/// 투표 확장 요청 도메인 모델
///
/// 순수 비즈니스 로직 레이어의 immutable 엔티티
/// 포인트를 사용하여 추가 사용자에게 투표 요청을 보낸 기록
@freezed
sealed class VoteExpansionRequest with _$VoteExpansionRequest {
  const VoteExpansionRequest._();

  const factory VoteExpansionRequest({
    /// 요청한 사용자 ID (필수)
    @Default('') String userId,

    /// 사용한 포인트 (필수)
    @Default(0) int pointsUsed,

    /// 추가로 요청한 사용자 수 (필수)
    @Default(0) int additionalUserCount,

    /// 생성 시간 (nullable)
    DateTime? createdAt,
  }) = _VoteExpansionRequest;

  factory VoteExpansionRequest.fromJson(Map<String, dynamic> json) =>
      _$VoteExpansionRequestFromJson(json);
}
