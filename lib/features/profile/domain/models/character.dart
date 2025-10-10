/// 사용자 캐릭터/아바타 도메인 모델
///
/// **책임**: 사용자가 선택 가능한 캐릭터 정보 표현
class Character {
  const Character({
    required this.characterId,
    required this.name,
    required this.imageUrl,
    this.description,
    this.isActive = true,
    this.characterType,
    this.createdAt,
  });

  /// 캐릭터 고유 ID
  final String characterId;

  /// 캐릭터 이름
  final String name;

  /// 캐릭터 이미지 URL
  final String imageUrl;

  /// 캐릭터 설명
  final String? description;

  /// 활성 상태 (사용 가능 여부)
  final bool isActive;

  /// 캐릭터 타입 (기본, 프리미엄 등)
  final String? characterType;

  /// 생성일
  final DateTime? createdAt;

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      characterId: json['characterId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      characterType: json['characterType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'characterId': characterId,
      'name': name,
      'imageUrl': imageUrl,
      if (description != null) 'description': description,
      'isActive': isActive,
      if (characterType != null) 'characterType': characterType,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
