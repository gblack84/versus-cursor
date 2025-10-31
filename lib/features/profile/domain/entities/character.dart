import 'package:freezed_annotation/freezed_annotation.dart';

part 'character.freezed.dart';
part 'character.g.dart';

/// 사용자 캐릭터/아바타 도메인 모델
///
/// **책임**: 사용자가 선택 가능한 캐릭터 정보 표현
@freezed
sealed class Character with _$Character {
  const factory Character({
    /// 캐릭터 고유 ID
    required String characterId,

    /// 캐릭터 이름
    required String name,

    /// 캐릭터 이미지 URL
    required String imageUrl,

    /// 캐릭터 설명
    String? description,

    /// 활성 상태 (사용 가능 여부)
    @Default(true) bool isActive,

    /// 캐릭터 타입 (기본, 프리미엄 등)
    String? characterType,

    /// 생성일
    DateTime? createdAt,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
}
