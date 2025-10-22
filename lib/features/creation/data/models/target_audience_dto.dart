/// Data Transfer Object for target audience from Presentation layer
/// Converts UI layer data format to Domain layer format
class TargetAudienceDto {
  final String collectionType;
  final int targetCount;
  final bool isPremium;
  final List<String> selectedInterests;
  final String selectedAgeGroup;
  final String selectedGender;
  final bool activeUserOnly;

  const TargetAudienceDto({
    required this.collectionType,
    required this.targetCount,
    required this.isPremium,
    required this.selectedInterests,
    required this.selectedAgeGroup,
    required this.selectedGender,
    required this.activeUserOnly,
  });

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

  @override
  String toString() {
    return 'TargetAudienceDto(collectionType: $collectionType, '
        'targetCount: $targetCount, isPremium: $isPremium, '
        'selectedInterests: $selectedInterests, selectedAgeGroup: $selectedAgeGroup, '
        'selectedGender: $selectedGender, activeUserOnly: $activeUserOnly)';
  }
}
