import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for individual vote data
///
/// **Clean Architecture v4.0 - DTO Layer**:
/// - Firestore DocumentSnapshot → VoteDto 변환
/// - Firestore 타입을 순수 Dart 타입으로 변환
/// - Domain Entity로의 변환은 VoteMapper에서 처리
///
/// **역할**:
/// - DocumentReference → String id
/// - Timestamp → DateTime
/// - Firestore 의존성 격리
class VoteDto {
  /// 투표 문서 ID
  final String id;

  /// 게시물 ID
  final String postId;

  /// 사용자 ID
  final String userId;

  /// 투표 선택 (A 또는 B)
  final String choice;

  /// 투표 시간
  final DateTime? timestamp;

  /// 사용자 정보 (optional)
  final Map<String, dynamic>? userInfo;

  const VoteDto({
    required this.id,
    required this.postId,
    required this.userId,
    required this.choice,
    this.timestamp,
    this.userInfo,
  });

  /// Firestore DocumentSnapshot → VoteDto 변환
  ///
  /// **변환 내역**:
  /// - DocumentReference → String id
  /// - Timestamp → DateTime
  /// - null-safe 기본값 적용
  factory VoteDto.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    // Helper: Timestamp/DateTime 안전 변환
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    // postId는 parent document ID에서 추출
    final postId = snapshot.reference.parent.parent?.id ?? '';

    return VoteDto(
      id: snapshot.id,
      postId: postId,
      userId: data['userId'] as String? ?? '',
      choice: data['choice'] as String? ?? '',
      timestamp: parseDateTime(data['votedAt']),
      userInfo: data['userInfo'] as Map<String, dynamic>?,
    );
  }

  /// VoteDto → Firestore Document 변환
  ///
  /// **사용처**: Repository에서 투표 생성/업데이트 시 사용
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'choice': choice,
      if (timestamp != null) 'votedAt': Timestamp.fromDate(timestamp!),
      if (userInfo != null) 'userInfo': userInfo,
    };
  }

  /// VoteDto 복사 (일부 필드 변경)
  VoteDto copyWith({
    String? id,
    String? postId,
    String? userId,
    String? choice,
    DateTime? timestamp,
    Map<String, dynamic>? userInfo,
  }) {
    return VoteDto(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      choice: choice ?? this.choice,
      timestamp: timestamp ?? this.timestamp,
      userInfo: userInfo ?? this.userInfo,
    );
  }

  @override
  String toString() => 'VoteDto(id: $id, postId: $postId, userId: $userId, choice: $choice)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          postId == other.postId &&
          userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ postId.hashCode ^ userId.hashCode;
}
