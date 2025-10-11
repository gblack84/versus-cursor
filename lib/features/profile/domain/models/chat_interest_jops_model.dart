/// ChatInterestJops pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createChatInterestJopsModelData() 제거 → ChatInterestJopsDto.toFirestore()로 이동
/// - ChatInterestJopsModelDocumentEquality 제거 → == operator 사용
/// - parentReference 제거 (Firebase-specific)
///
/// Represents chat interest/job categories with timestamp
class ChatInterestJops {
  // ============= Core Fields =============
  final String categoryA;
  final String categoryB;
  final String categoryC;
  final DateTime? timeStamp;

  const ChatInterestJops({
    this.categoryA = '',
    this.categoryB = '',
    this.categoryC = '',
    this.timeStamp,
  });

  /// Create a copy of this ChatInterestJops with updated fields
  ChatInterestJops copyWith({
    String? categoryA,
    String? categoryB,
    String? categoryC,
    DateTime? timeStamp,
  }) {
    return ChatInterestJops(
      categoryA: categoryA ?? this.categoryA,
      categoryB: categoryB ?? this.categoryB,
      categoryC: categoryC ?? this.categoryC,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  @override
  String toString() => 'ChatInterestJops('
      'categoryA: $categoryA, '
      'categoryB: $categoryB, '
      'categoryC: $categoryC, '
      'timeStamp: $timeStamp'
      ')';

  @override
  int get hashCode => Object.hash(
        categoryA,
        categoryB,
        categoryC,
        timeStamp,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatInterestJops &&
          runtimeType == other.runtimeType &&
          categoryA == other.categoryA &&
          categoryB == other.categoryB &&
          categoryC == other.categoryC &&
          timeStamp == other.timeStamp;
}

// Backward compatibility aliases
@Deprecated('Use ChatInterestJops instead')
typedef ChatInterestJopsModel = ChatInterestJops;
