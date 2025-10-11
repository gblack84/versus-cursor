/// JopsCategory pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - fromAlgolia(), search() 메서드 제거 → Repository로 이동
/// - createJopsCategoryModelData() 제거 → JopsCategoryDto.toFirestore()로 이동
/// - JopsCategoryModelDocumentEquality 제거 → == operator 사용
///
/// Represents a job category with searchable tags
class JopsCategory {
  // ============= Core Fields =============
  final String jopName;
  final String categoryRefA;
  final String categoryRefB;
  final List<String> searchTags;

  const JopsCategory({
    required this.jopName,
    required this.categoryRefA,
    required this.categoryRefB,
    this.searchTags = const [],
  });

  /// Create a copy of this JopsCategory with updated fields
  JopsCategory copyWith({
    String? jopName,
    String? categoryRefA,
    String? categoryRefB,
    List<String>? searchTags,
  }) {
    return JopsCategory(
      jopName: jopName ?? this.jopName,
      categoryRefA: categoryRefA ?? this.categoryRefA,
      categoryRefB: categoryRefB ?? this.categoryRefB,
      searchTags: searchTags ?? this.searchTags,
    );
  }

  @override
  String toString() => 'JopsCategory('
      'jopName: $jopName, '
      'categoryRefA: $categoryRefA, '
      'categoryRefB: $categoryRefB, '
      'searchTags: ${searchTags.length} tags'
      ')';

  @override
  int get hashCode => Object.hash(
        jopName,
        categoryRefA,
        categoryRefB,
        Object.hashAll(searchTags),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JopsCategory &&
          runtimeType == other.runtimeType &&
          jopName == other.jopName &&
          categoryRefA == other.categoryRefA &&
          categoryRefB == other.categoryRefB &&
          _listEquals(searchTags, other.searchTags);

  // Helper method for list equality comparison
  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// Backward compatibility aliases
@Deprecated('Use JopsCategory instead')
typedef JopsCategoryModel = JopsCategory;
