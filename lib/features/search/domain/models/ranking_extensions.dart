part of 'ranking.dart';

/// Ranking Firestore Extensions
///
/// Firestore DocumentSnapshot ↔ Ranking Entity 변환
///
/// **Phase 5 (2025-11-07)**: Extension Pattern Migration
/// - DTO/Mapper 제거
/// - Extension 메서드로 직접 변환
/// - Firebase-Centric Architecture v2.0
extension RankingFirestore on Ranking {
  /// Firestore DocumentSnapshot → Ranking Entity
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await firestore.collection('rankings').doc(id).get();
  /// final ranking = RankingFirestore.fromFirestore(doc);
  /// ```
  static Ranking fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Ranking(
      rankingId: doc.id,
      type: data['type'] as String? ?? 'daily',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  /// Ranking Entity → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final ranking = Ranking(...);
  /// await firestore.collection('rankings').doc(id).set(ranking.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      if (date != null) 'date': Timestamp.fromDate(date!),
    };
  }
}
