import '../models/target_audience_dto.dart';
import '../../domain/models/value_objects/target_audience.dart';

/// Mapper for converting between TargetAudience DTO and Domain model
///
/// This mapper handles the conversion from Presentation layer DTOs
/// to Domain layer models, following Clean Architecture separation.
///
/// **Enhanced with Firebase Compatibility**: Age group conversion helpers
/// for seamless integration with Firebase Functions (English ↔ Korean)
class TargetAudienceMapper {
  /// Converts TargetAudienceDto to TargetAudience domain model
  ///
  /// Creates a new domain model with proper defaults and timestamps.
  /// Status is set to 'pending' by default for new target audiences.
  static TargetAudience toDomain(TargetAudienceDto dto) {
    return TargetAudience(
      collectionType: dto.collectionType,
      targetCount: dto.targetCount,
      selectedInterests: dto.selectedInterests,
      selectedAgeGroup: dto.selectedAgeGroup,
      selectedGender: dto.selectedGender,
      activeUserOnly: dto.activeUserOnly,
      isPremium: dto.isPremium,
      createdAt: DateTime.now(),
      status: 'pending',
    );
  }

  /// Converts TargetAudience domain model back to DTO
  ///
  /// Useful for passing data back to Presentation layer if needed.
  static TargetAudienceDto toDto(TargetAudience domain) {
    return TargetAudienceDto(
      collectionType: domain.collectionType,
      targetCount: domain.targetCount,
      selectedInterests: domain.selectedInterests,
      selectedAgeGroup: domain.selectedAgeGroup,
      selectedGender: domain.selectedGender,
      activeUserOnly: domain.activeUserOnly,
      isPremium: domain.isPremium,
    );
  }

  // ============================================
  // Age Group Conversion Helpers
  // (Firebase Functions Compatibility)
  // ============================================

  /// Convert age group from Firebase format (English) to domain format (Korean)
  ///
  /// Firebase → Domain
  /// - 'all' → '전체'
  /// - '10s' → '10대'
  /// - '20s' → '20대'
  /// - '30s' → '30대'
  /// - '40s' → '40대'
  /// - '50s+' → '50대 이상'
  static String convertAgeGroupFromFirebase(String? ageGroup) {
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

  /// Convert age group from domain format (Korean) to Firebase format (English)
  ///
  /// Domain → Firebase
  /// - '전체' → 'all'
  /// - '10대' → '10s'
  /// - '20대' → '20s'
  /// - '30대' → '30s'
  /// - '40대' → '40s'
  /// - '50대 이상' → '50s+'
  static String convertAgeGroupToFirebase(String ageGroup) {
    if (ageGroup == '전체') return 'all';

    const ageMapping = {
      '10대': '10s',
      '20대': '20s',
      '30대': '30s',
      '40대': '40s',
      '50대 이상': '50s+',
    };

    return ageMapping[ageGroup] ?? 'all';
  }
}
