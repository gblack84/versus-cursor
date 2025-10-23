import '../models/weight_dto.dart';
import '../../domain/models/weight.dart';

/// WeightDto ↔ Weight 변환을 담당하는 Mapper
///
/// Data Layer DTO와 Domain Layer Entity 간 변환
class WeightMapper {
  /// DTO → Domain Entity 변환
  static Weight toDomain(WeightDto dto) {
    return Weight(
      nameInterest: dto.nameInterest,
      scoreInterest: dto.scoreInterest,
    );
  }

  /// Domain Entity → DTO 변환 (reference 필요)
  ///
  /// [entity] Domain 엔티티
  /// [reference] Firestore document reference
  static WeightDto toDto(
    Weight entity,
    dynamic reference,
  ) {
    return WeightDto(
      reference: reference,
      nameInterest: entity.nameInterest,
      scoreInterest: entity.scoreInterest,
    );
  }

  /// DTO 리스트 → Domain 리스트 변환
  static List<Weight> toDomainList(List<WeightDto> dtos) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }
}
