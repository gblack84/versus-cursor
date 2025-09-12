/// Local cache에서 사용하는 간단한 투표 상태 모델
class VoteState {
  /// 사용자의 투표 선택 (A 또는 B)
  final String? option;
  
  /// 투표한 시간
  final DateTime? timestamp;
  
  /// 투표 완료 여부
  final bool completed;

  VoteState({
    this.option,
    this.timestamp,
    this.completed = false,
  });

  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
    'option': option,
    'timestamp': timestamp?.toIso8601String(),
    'completed': completed,
  };

  /// JSON에서 생성
  factory VoteState.fromJson(Map<String, dynamic> json) => VoteState(
    option: json['option'] as String?,
    timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp'] as String)
        : null,
    completed: json['completed'] as bool? ?? false,
  );
}