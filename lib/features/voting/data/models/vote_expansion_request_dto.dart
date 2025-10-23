import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for VoteExpansionRequest
///
/// Firestore 데이터 레이어에서 사용하는 DTO
/// DocumentReference, Timestamp 등 Firestore 타입 포함
class VoteExpansionRequestDto {
  final DocumentReference reference;
  final String userId;
  final int pointsUsed;
  final int additionalUserCount;
  final Timestamp? createdAt;

  VoteExpansionRequestDto({
    required this.reference,
    required this.userId,
    required this.pointsUsed,
    required this.additionalUserCount,
    this.createdAt,
  });

  /// Firestore DocumentSnapshot에서 DTO 생성
  factory VoteExpansionRequestDto.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    return VoteExpansionRequestDto(
      reference: snapshot.reference,
      userId: data?['userId'] as String? ?? '',
      pointsUsed: data?['pointsUsed'] as int? ?? 0,
      additionalUserCount: data?['additionalUserCount'] as int? ?? 0,
      createdAt: data?['createdAt'] as Timestamp?,
    );
  }

  /// Firestore 저장을 위한 Map 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pointsUsed': pointsUsed,
      'additionalUserCount': additionalUserCount,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// 데이터와 reference로 DTO 생성
  factory VoteExpansionRequestDto.fromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) {
    return VoteExpansionRequestDto(
      reference: reference,
      userId: data['userId'] as String? ?? '',
      pointsUsed: data['pointsUsed'] as int? ?? 0,
      additionalUserCount: data['additionalUserCount'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// Firestore 컬렉션 쿼리
  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('voteExpansionRequests')
          : FirebaseFirestore.instance.collectionGroup('voteExpansionRequests');

  /// Document reference 생성
  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('voteExpansionRequests').doc(id);
}
