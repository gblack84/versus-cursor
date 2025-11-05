import 'package:freezed_annotation/freezed_annotation.dart';

part 'target_audience_dto.freezed.dart';

/// Data Transfer Object for target audience from Presentation layer
/// Converts UI layer data format to Domain layer format
///
/// **Architecture Note**: This DTO is largely redundant as the Domain layer
/// TargetAudience already contains all these fields. Consider eliminating
/// this DTO in future refactoring and passing Domain model directly.
@freezed
sealed class TargetAudienceDto with _$TargetAudienceDto {
  const factory TargetAudienceDto({
    required String collectionType,
    required int targetCount,
    required bool isPremium,
    required List<String> selectedInterests,
    required String selectedAgeGroup,
    required String selectedGender,
    required bool activeUserOnly,
  }) = _TargetAudienceDto;

  /// Factory constructor for creating from Provider's Map
  /// Converts UI layer keys to Domain layer format
  factory TargetAudienceDto.fromProviderMap(Map<String, dynamic> map) {
    return TargetAudienceDto(
      collectionType: map['type'] as String, // UI 'type' → Domain 'collectionType'
      targetCount: map['targetCount'] as int? ?? 100,
      isPremium: map['isPremium'] as bool? ?? false,
      selectedInterests: map['criteria'] != null
          ? List<String>.from(map['criteria']['interests'] ?? [])
          : const [],
      selectedAgeGroup: map['criteria'] != null
          ? _convertAgeGroupFromMap(map['criteria']['ageGroup'])
          : '전체',
      selectedGender: map['criteria'] != null
          ? map['criteria']['gender'] as String? ?? 'all'
          : 'all',
      activeUserOnly: map['criteria'] != null
          ? map['criteria']['activeUserOnly'] as bool? ?? true
          : true,
    );
  }

  /// Convert age group from English to Korean (UI layer uses Korean)
  static String _convertAgeGroupFromMap(String? ageGroup) {
    if (ageGroup == null) return '전체';

    const ageMapping = {
      'all': '전체',
      '10s': '10대',
      '20s': '20대',
      '30s': '30대',
      '40s': '40대',
      '50s+': '50대 이상',
    };

    return ageMapping[ageGroup] ?? '전체';
  }
}
