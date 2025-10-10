/// Character DTO
///
/// **책임**: Firestore characters 컬렉션 문서 구조와 Dart 객체 간 변환
class CharacterDto {
  final String? characterId;
  final String? name;
  final String? imageUrl;
  final String? description;
  final bool? isActive;

  const CharacterDto({
    this.characterId,
    this.name,
    this.imageUrl,
    this.description,
    this.isActive,
  });

  /// Firestore → DTO
  factory CharacterDto.fromFirestore(Map<String, dynamic> data) {
    return CharacterDto(
      characterId: data['characterId'] as String?,
      name: data['name'] as String?,
      imageUrl: data['imageUrl'] as String?,
      description: data['description'] as String?,
      isActive: data['isActive'] as bool?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (characterId != null) 'characterId': characterId,
      if (name != null) 'name': name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    };
  }
}
