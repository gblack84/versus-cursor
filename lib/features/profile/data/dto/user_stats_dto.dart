/// UserStats DTO
///
/// **책임**: Firestore 문서 구조와 Dart 객체 간 변환
class UserStatsDto {
  final String? userId;
  final int? pointsA;
  final int? pointsQ;
  final int? totalAPoints;
  final int? totalQPoints;
  final int? anonymousPostsCount;
  final int? anonymousCommentsCount;
  final int? anonymousQuestionCount;

  const UserStatsDto({
    this.userId,
    this.pointsA,
    this.pointsQ,
    this.totalAPoints,
    this.totalQPoints,
    this.anonymousPostsCount,
    this.anonymousCommentsCount,
    this.anonymousQuestionCount,
  });

  /// Firestore → DTO
  factory UserStatsDto.fromFirestore(Map<String, dynamic> data) {
    return UserStatsDto(
      userId: data['userId'] as String?,
      pointsA: data['pointsA'] as int?,
      pointsQ: data['pointsQ'] as int?,
      totalAPoints: data['totalAPoints'] as int?,
      totalQPoints: data['totalQPoints'] as int?,
      anonymousPostsCount: data['anonymousPostsCount'] as int?,
      anonymousCommentsCount: data['anonymousCommentsCount'] as int?,
      anonymousQuestionCount: data['anonymousQuestionCount'] as int?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (pointsA != null) 'pointsA': pointsA,
      if (pointsQ != null) 'pointsQ': pointsQ,
      if (totalAPoints != null) 'totalAPoints': totalAPoints,
      if (totalQPoints != null) 'totalQPoints': totalQPoints,
      if (anonymousPostsCount != null)
        'anonymousPostsCount': anonymousPostsCount,
      if (anonymousCommentsCount != null)
        'anonymousCommentsCount': anonymousCommentsCount,
      if (anonymousQuestionCount != null)
        'anonymousQuestionCount': anonymousQuestionCount,
    };
  }
}
