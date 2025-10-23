import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for ranking data
///
/// **Clean Architecture v4.0 - DTO Layer**:
/// - Firestore DocumentSnapshot → RankingDto 변환
/// - Firestore 타입을 순수 Dart 타입으로 변환
/// - Domain Entity로의 변환은 RankingMapper에서 처리
///
/// **역할**:
/// - DocumentReference → String id
/// - Timestamp → DateTime
/// - Firestore 의존성 격리
class RankingDto {
  /// 랭킹 문서 ID
  final String id;

  /// 랭킹 ID (비즈니스 식별자)
  /// Note: Original field has typo "rakingId" but we normalize to "rankingId"
  final String rankingId;

  /// 랭킹 유형 (예: 'daily', 'weekly', 'monthly')
  final String type;

  /// 랭킹 날짜
  final DateTime? date;

  const RankingDto({
    required this.id,
    required this.rankingId,
    required this.type,
    this.date,
  });

  /// Firestore DocumentSnapshot → RankingDto 변환
  ///
  /// **변환 내역**:
  /// - DocumentReference → String id
  /// - Timestamp → DateTime
  /// - null-safe 기본값 적용
  /// - Field typo "rakingId" → "rankingId" 정규화
  factory RankingDto.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    // Helper: Timestamp/DateTime 안전 변환
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return RankingDto(
      id: snapshot.id,
      // Handle typo in Firestore field name "rakingId"
      rankingId: data['rakingId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      date: parseDateTime(data['date']),
    );
  }

  /// RankingDto → Firestore Document 변환
  ///
  /// **사용처**: Repository에서 랭킹 생성/업데이트 시 사용
  /// Note: Uses original typo "rakingId" for backward compatibility
  Map<String, dynamic> toFirestore() {
    return {
      'rakingId': rankingId, // Keep typo for backward compatibility
      'type': type,
      if (date != null) 'date': Timestamp.fromDate(date!),
    };
  }

  /// RankingDto 복사 (일부 필드 변경)
  RankingDto copyWith({
    String? id,
    String? rankingId,
    String? type,
    DateTime? date,
  }) {
    return RankingDto(
      id: id ?? this.id,
      rankingId: rankingId ?? this.rankingId,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }

  @override
  String toString() => 'RankingDto(id: $id, rankingId: $rankingId, type: $type, date: $date)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankingDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          rankingId == other.rankingId;

  @override
  int get hashCode => id.hashCode ^ rankingId.hashCode;
}
