/// JopsName pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createJopsNameModelData() 제거 → JopsNameDto.toFirestore()로 이동
/// - JopsNameModelDocumentEquality 제거 → == operator 사용
///
/// Represents a specific job name within a category
class JopsName {
  // ============= Core Fields =============
  final String name;
  final String categoryRef;

  const JopsName({
    required this.name,
    required this.categoryRef,
  });

  /// Create a copy of this JopsName with updated fields
  JopsName copyWith({
    String? name,
    String? categoryRef,
  }) {
    return JopsName(
      name: name ?? this.name,
      categoryRef: categoryRef ?? this.categoryRef,
    );
  }

  @override
  String toString() => 'JopsName('
      'name: $name, '
      'categoryRef: $categoryRef'
      ')';

  @override
  int get hashCode => Object.hash(name, categoryRef);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JopsName &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          categoryRef == other.categoryRef;
}

// Backward compatibility aliases
@Deprecated('Use JopsName instead')
typedef JopsNameModel = JopsName;
