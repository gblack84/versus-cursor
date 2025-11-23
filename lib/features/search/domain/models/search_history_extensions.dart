part of 'search_history.dart';

/// SearchHistory Firestore Extensions
///
/// Firestore DocumentSnapshot ↔ SearchHistory Entity 변환
///
/// **Phase 5 (2025-11-22)**: Extension Pattern Migration
/// - 인라인 메서드 → Extension으로 분리
/// - Firebase-Centric Architecture v2.0
/// - Ranking Extension 패턴과 일관성 유지
extension SearchHistoryFirestore on SearchHistory {
  /// Firestore DocumentSnapshot → SearchHistory Entity
  ///
  /// **Usage**:
  /// ```dart
  /// final doc = await firestore.collection('searches').doc(id).get();
  /// final searchHistory = SearchHistoryFirestore.fromFirestore(doc);
  /// ```
  static SearchHistory fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SearchHistory(
      searchId: doc.id,
      userId: data['userId'] as String? ?? '',
      query: data['query'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate(),
    );
  }

  /// SearchHistory Entity → Firestore Map
  ///
  /// **Usage**:
  /// ```dart
  /// final searchHistory = SearchHistory(...);
  /// await firestore.collection('searches').doc(id).set(searchHistory.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'query': query,
      if (date != null) 'date': Timestamp.fromDate(date!),
    };
  }
}
