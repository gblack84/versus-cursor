/// 투표 수 정보를 담는 도메인 모델
class VoteCounts {
  final int votesA;
  final int votesB;
  final int totalVotes;

  const VoteCounts({
    required this.votesA,
    required this.votesB,
    required this.totalVotes,
  });

  Map<String, dynamic> toJson() => {
    'votesA': votesA,
    'votesB': votesB,
    'totalVotes': totalVotes,
  };

  factory VoteCounts.fromJson(Map<String, dynamic> json) => VoteCounts(
    votesA: json['votesA'] as int,
    votesB: json['votesB'] as int,
    totalVotes: json['totalVotes'] as int,
  );
}