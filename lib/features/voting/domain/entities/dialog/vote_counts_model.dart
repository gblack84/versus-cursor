import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_counts_model.freezed.dart';
part 'vote_counts_model.g.dart';

/// 투표 수 정보를 담는 도메인 모델
@freezed
sealed class VoteCounts with _$VoteCounts {
  const VoteCounts._();

  const factory VoteCounts({
    required int votesA,
    required int votesB,
    required int totalVotes,
  }) = _VoteCounts;

  factory VoteCounts.fromJson(Map<String, dynamic> json) =>
      _$VoteCountsFromJson(json);
}
