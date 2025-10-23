import '../models/ranking_dto.dart';
import '../../domain/models/ranking.dart';

/// Mapper between RankingDto (Data Layer) and Ranking (Domain Layer)
///
/// **Clean Architecture v4.0 - Mapper Pattern**:
/// - DTO (Infrastructure) ↔ Entity (Domain) 변환
/// - 계층 간 의존성 격리
/// - 단방향 변환 (DTO → Entity, Entity → DTO)
///
/// **역할**:
/// - toEntity: RankingDto → Ranking (Repository → UseCase)
/// - toDto: Ranking → RankingDto (UseCase → Repository)
///
/// **사용처**:
/// - Repository 구현체에서 Firestore 데이터를 Domain으로 변환
/// - UseCase에서 Domain 데이터를 Firestore로 저장
class RankingMapper {
  /// RankingDto → Ranking (Domain Entity) 변환
  ///
  /// **Clean Architecture**:
  /// - Data Layer (DTO) → Domain Layer (Entity)
  /// - Firestore 타입 제거
  /// - 순수 Dart 타입만 사용
  ///
  /// **사용처**: Repository에서 Firestore 데이터 조회 후 Domain으로 전달
  static Ranking toEntity(RankingDto dto) {
    return Ranking(
      rankingId: dto.rankingId,
      type: dto.type,
      date: dto.date,
    );
  }

  /// Ranking (Domain Entity) → RankingDto 변환
  ///
  /// **Clean Architecture**:
  /// - Domain Layer (Entity) → Data Layer (DTO)
  /// - Firestore 저장을 위한 DTO 생성
  ///
  /// **사용처**: Repository에서 Domain 데이터를 Firestore에 저장
  ///
  /// **Note**: id는 Firestore에서 자동 생성되므로 빈 문자열
  static RankingDto toDto(Ranking entity, {String id = ''}) {
    return RankingDto(
      id: id,
      rankingId: entity.rankingId,
      type: entity.type,
      date: entity.date,
    );
  }

  /// List<RankingDto> → List<Ranking> 변환
  static List<Ranking> toEntityList(List<RankingDto> dtos) {
    return dtos.map(toEntity).toList();
  }

  /// List<Ranking> → List<RankingDto> 변환
  static List<RankingDto> toDtoList(List<Ranking> entities) {
    return entities.map((e) => toDto(e)).toList();
  }
}
