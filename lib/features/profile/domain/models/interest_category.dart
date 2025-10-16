/// InterestCategory pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createInterestModelData() 제거 → InterestDto.toFirestore()로 이동
/// - InterestModelDocumentEquality 제거 → == operator 사용
/// - Interest → InterestCategory (2025-01-30): 네이밍 충돌 해결
///
/// Represents an interest category that users can select from Firestore collection
class InterestCategory {
  // ============= Core Fields =============
  final String interestId;
  final String nameInterest;
  final List<String> userIds;
  final List<String> subCategories;

  const InterestCategory({
    required this.interestId,
    required this.nameInterest,
    this.userIds = const [],
    this.subCategories = const [],
  });

  /// Create a copy of this InterestCategory with updated fields
  InterestCategory copyWith({
    String? interestId,
    String? nameInterest,
    List<String>? userIds,
    List<String>? subCategories,
  }) {
    return InterestCategory(
      interestId: interestId ?? this.interestId,
      nameInterest: nameInterest ?? this.nameInterest,
      userIds: userIds ?? this.userIds,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  String toString() => 'InterestCategory('
      'interestId: $interestId, '
      'nameInterest: $nameInterest, '
      'userIds: ${userIds.length} users, '
      'subCategories: ${subCategories.length} items'
      ')';

  @override
  int get hashCode => Object.hash(
        interestId,
        nameInterest,
        Object.hashAll(userIds),
        Object.hashAll(subCategories),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterestCategory &&
          runtimeType == other.runtimeType &&
          interestId == other.interestId &&
          nameInterest == other.nameInterest &&
          _listEquals(userIds, other.userIds) &&
          _listEquals(subCategories, other.subCategories);

  // Helper method for list equality comparison
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
