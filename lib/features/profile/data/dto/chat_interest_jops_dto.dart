import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/chat_interest_jops_model.dart';

/// ChatInterestJops DTO (Clean Architecture v4.0)
///
/// **책임**: Firestore 문서 구조와 Domain Model 간 변환
/// - fromFirestore(): Firestore Map → DTO
/// - toFirestore(): DTO → Firestore Map
/// - toDomain(): DTO → Domain Model
/// - fromDomain(): Domain Model → DTO
class ChatInterestJopsDto {
  final String? categoryA;
  final String? categoryB;
  final String? categoryC;
  final DateTime? timeStamp;

  const ChatInterestJopsDto({
    this.categoryA,
    this.categoryB,
    this.categoryC,
    this.timeStamp,
  });

  /// Firestore → DTO
  factory ChatInterestJopsDto.fromFirestore(Map<String, dynamic> data) {
    return ChatInterestJopsDto(
      categoryA: data['categoryA'] as String?,
      categoryB: data['categoryB'] as String?,
      categoryC: data['categoryC'] as String?,
      timeStamp: (data['timeStamp'] as Timestamp?)?.toDate(),
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (categoryA != null) 'categoryA': categoryA,
      if (categoryB != null) 'categoryB': categoryB,
      if (categoryC != null) 'categoryC': categoryC,
      if (timeStamp != null) 'timeStamp': Timestamp.fromDate(timeStamp!),
    };
  }

  /// DTO → Domain Model
  ChatInterestJops toDomain() {
    return ChatInterestJops(
      categoryA: categoryA ?? '',
      categoryB: categoryB ?? '',
      categoryC: categoryC ?? '',
      timeStamp: timeStamp,
    );
  }

  /// Domain Model → DTO
  factory ChatInterestJopsDto.fromDomain(ChatInterestJops model) {
    return ChatInterestJopsDto(
      categoryA: model.categoryA,
      categoryB: model.categoryB,
      categoryC: model.categoryC,
      timeStamp: model.timeStamp,
    );
  }
}
