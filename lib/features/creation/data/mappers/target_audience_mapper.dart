import '../dto/target_audience_dto.dart';
import '../../domain/models/target_audience.dart';

/// Mapper for converting between TargetAudience DTO and Domain model
///
/// This mapper handles the conversion from Presentation layer DTOs
/// to Domain layer models, following Clean Architecture separation.
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
}
