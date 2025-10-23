import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vote_expansion_request_dto.dart';
import '../../domain/models/vote_expansion_request.dart';

/// VoteExpansionRequestDto ↔ VoteExpansionRequest 변환을 담당하는 Mapper
///
/// Data Layer DTO와 Domain Layer Entity 간 변환
/// DateTime ↔ Timestamp 변환 처리
class VoteExpansionRequestMapper {
  /// DTO → Domain Entity 변환
  static VoteExpansionRequest toDomain(VoteExpansionRequestDto dto) {
    return VoteExpansionRequest(
      userId: dto.userId,
      pointsUsed: dto.pointsUsed,
      additionalUserCount: dto.additionalUserCount,
      createdAt: dto.createdAt?.toDate(),
    );
  }

  /// Domain Entity → DTO 변환 (reference 필요)
  ///
  /// [entity] Domain 엔티티
  /// [reference] Firestore document reference
  static VoteExpansionRequestDto toDto(
    VoteExpansionRequest entity,
    dynamic reference,
  ) {
    return VoteExpansionRequestDto(
      reference: reference,
      userId: entity.userId,
      pointsUsed: entity.pointsUsed,
      additionalUserCount: entity.additionalUserCount,
      createdAt: entity.createdAt != null
          ? Timestamp.fromDate(entity.createdAt!)
          : null,
    );
  }

  /// DTO 리스트 → Domain 리스트 변환
  static List<VoteExpansionRequest> toDomainList(
    List<VoteExpansionRequestDto> dtos,
  ) {
    return dtos.map((dto) => toDomain(dto)).toList();
  }
}
