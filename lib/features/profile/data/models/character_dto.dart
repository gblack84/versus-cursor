import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/character.dart';

/// Character DTO
///
/// **책임**: Firestore characters 컬렉션 문서 구조와 Dart 객체 간 변환
///
/// **변경사항** (2025-01-30):
/// - Characters 모델 → Character 모델로 변경
/// - characterType, createdAt 필드 추가
/// - 레거시 필드명 호환성 유지 (charactersName, charactersImageUrl)
class CharacterDto {
  final String? characterId;
  final String? name;
  final String? imageUrl;
  final String? description;
  final bool? isActive;
  final String? characterType;
  final Timestamp? createdAt;

  const CharacterDto({
    this.characterId,
    this.name,
    this.imageUrl,
    this.description,
    this.isActive,
    this.characterType,
    this.createdAt,
  });

  /// Firestore → DTO
  ///
  /// **호환성**: charactersName/name, charactersImageUrl/imageUrl 모두 지원
  factory CharacterDto.fromFirestore(Map<String, dynamic> data) {
    return CharacterDto(
      characterId: data['characterId'] as String?,
      name: data['name'] as String? ??
            data['charactersName'] as String? ??
            data['CharactersName'] as String?,  // 대문자 버전도 지원
      imageUrl: data['imageUrl'] as String? ??
                data['charactersImageUrl'] as String? ??
                data['CharactersImageUrl'] as String?,  // 대문자 버전도 지원
      description: data['description'] as String?,
      isActive: data['isActive'] as bool?,
      characterType: data['characterType'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
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
      if (characterType != null) 'characterType': characterType,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// DTO → Domain Model
  Character toDomain() {
    return Character(
      characterId: characterId ?? '',
      name: name ?? '',
      imageUrl: imageUrl ?? '',
      description: description,
      isActive: isActive ?? true,
      characterType: characterType,
      createdAt: createdAt?.toDate(),
    );
  }

  /// Domain Model → DTO
  factory CharacterDto.fromDomain(Character model) {
    return CharacterDto(
      characterId: model.characterId,
      name: model.name,
      imageUrl: model.imageUrl,
      description: model.description,
      isActive: model.isActive,
      characterType: model.characterType,
      createdAt: model.createdAt != null
        ? Timestamp.fromDate(model.createdAt!)
        : null,
    );
  }
}
