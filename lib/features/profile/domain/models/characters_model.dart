/// Characters pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createCharactersModelData() 제거 → CharactersDto.toFirestore()로 이동
/// - CharactersModelDocumentEquality 제거 → == operator 사용
///
/// Represents a character/avatar that users can select for their profile
class Characters {
  // ============= Core Fields =============
  final String charactersName;
  final String charactersImageUrl;

  const Characters({
    required this.charactersName,
    required this.charactersImageUrl,
  });

  /// Create a copy of this Characters with updated fields
  Characters copyWith({
    String? charactersName,
    String? charactersImageUrl,
  }) {
    return Characters(
      charactersName: charactersName ?? this.charactersName,
      charactersImageUrl: charactersImageUrl ?? this.charactersImageUrl,
    );
  }

  @override
  String toString() => 'Characters('
      'charactersName: $charactersName, '
      'charactersImageUrl: $charactersImageUrl'
      ')';

  @override
  int get hashCode => Object.hash(charactersName, charactersImageUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Characters &&
          runtimeType == other.runtimeType &&
          charactersName == other.charactersName &&
          charactersImageUrl == other.charactersImageUrl;
}

// Backward compatibility aliases
@Deprecated('Use Characters instead')
typedef CharactersModel = Characters;
