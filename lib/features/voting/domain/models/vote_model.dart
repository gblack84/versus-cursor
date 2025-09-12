/// 개별 투표 정보를 담는 도메인 모델
class Vote {
  final String postId;
  final String userId;
  final String choice;
  final DateTime? timestamp;

  const Vote({
    required this.postId,
    required this.userId,
    required this.choice,
    this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'userId': userId,
    'choice': choice,
    'timestamp': timestamp?.millisecondsSinceEpoch,
  };

  factory Vote.fromJson(Map<String, dynamic> json) => Vote(
    postId: json['postId'] as String,
    userId: json['userId'] as String,
    choice: json['choice'] as String,
    timestamp: json['timestamp'] != null 
      ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int)
      : null,
  );
}