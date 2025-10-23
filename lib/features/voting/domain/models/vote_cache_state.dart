import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_cache_state.freezed.dart';
part 'vote_cache_state.g.dart';

/// Local cache에서 사용하는 간단한 투표 상태 모델
@freezed
sealed class VoteCacheState with _$VoteCacheState {
  const VoteCacheState._();

  const factory VoteCacheState({
    /// 사용자의 투표 선택 (A 또는 B)
    String? option,

    /// 투표한 시간
    DateTime? timestamp,

    /// 투표 완료 여부
    @Default(false) bool completed,
  }) = _VoteCacheState;

  factory VoteCacheState.fromJson(Map<String, dynamic> json) =>
      _$VoteCacheStateFromJson(json);
}
