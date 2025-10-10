import 'package:cloud_firestore/cloud_firestore.dart';

/// Friend DTO
///
/// **책임**: Firestore friendsList 컬렉션 문서 구조와 Dart 객체 간 변환
class FriendDto {
  final String? userId;
  final String? friendId;
  final DateTime? createdAt;

  const FriendDto({
    this.userId,
    this.friendId,
    this.createdAt,
  });

  /// Firestore → DTO
  factory FriendDto.fromFirestore(Map<String, dynamic> data) {
    return FriendDto(
      userId: data['userId'] as String?,
      friendId: data['friendId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (friendId != null) 'friendId': friendId,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
