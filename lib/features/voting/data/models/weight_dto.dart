import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for Weight
///
/// Firestore 데이터 레이어에서 사용하는 DTO
/// DocumentReference 등 Firestore 타입 포함
class WeightDto {
  final DocumentReference reference;
  final String nameInterest;
  final int scoreInterest;

  WeightDto({
    required this.reference,
    required this.nameInterest,
    required this.scoreInterest,
  });

  /// Firestore DocumentSnapshot에서 DTO 생성
  factory WeightDto.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    return WeightDto(
      reference: snapshot.reference,
      nameInterest: data?['nameInterest'] as String? ?? '',
      scoreInterest: data?['scoreInterest'] as int? ?? 0,
    );
  }

  /// Firestore 저장을 위한 Map 변환
  Map<String, dynamic> toJson() {
    return {
      'nameInterest': nameInterest,
      'scoreInterest': scoreInterest,
    };
  }

  /// 데이터와 reference로 DTO 생성
  factory WeightDto.fromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) {
    return WeightDto(
      reference: reference,
      nameInterest: data['nameInterest'] as String? ?? '',
      scoreInterest: data['scoreInterest'] as int? ?? 0,
    );
  }

  /// Firestore 컬렉션 쿼리
  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('weights')
          : FirebaseFirestore.instance.collectionGroup('weights');

  /// Document reference 생성
  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('weights').doc(id);
}
