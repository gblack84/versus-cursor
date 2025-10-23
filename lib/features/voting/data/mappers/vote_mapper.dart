import '../models/vote_dto.dart';
import '../../domain/models/vote.dart';

/// Mapper between VoteDto (Data Layer) and Vote (Domain Layer)
///
/// **Clean Architecture v4.0 - Mapper Pattern**:
/// - DTO (Infrastructure) ↔ Entity (Domain) 변환
/// - 계층 간 의존성 격리
/// - 단방향 변환 (DTO → Entity, Entity → DTO)
///
/// **역할**:
/// - toEntity: VoteDto → Vote (Repository → UseCase)
/// - toDto: Vote → VoteDto (UseCase → Repository)
///
/// **사용처**:
/// - Repository 구현체에서 Firestore 데이터를 Domain으로 변환
/// - UseCase에서 Domain 데이터를 Firestore로 저장
class VoteMapper {
  /// VoteDto → Vote (Domain Entity) 변환
  ///
  /// **Clean Architecture**:
  /// - Data Layer (DTO) → Domain Layer (Entity)
  /// - Firestore 타입 제거
  /// - 순수 Dart 타입만 사용
  ///
  /// **사용처**: Repository에서 Firestore 데이터 조회 후 Domain으로 전달
  static Vote toEntity(VoteDto dto) {
    return Vote(
      postId: dto.postId,
      userId: dto.userId,
      choice: dto.choice,
      timestamp: dto.timestamp,
    );
  }

  /// Vote (Domain Entity) → VoteDto 변환
  ///
  /// **Clean Architecture**:
  /// - Domain Layer (Entity) → Data Layer (DTO)
  /// - Firestore 저장을 위한 DTO 생성
  ///
  /// **사용처**: Repository에서 Domain 데이터를 Firestore에 저장
  ///
  /// **Note**: id는 Firestore에서 자동 생성되므로 빈 문자열
  static VoteDto toDto(Vote entity, {String id = ''}) {
    return VoteDto(
      id: id,
      postId: entity.postId,
      userId: entity.userId,
      choice: entity.choice,
      timestamp: entity.timestamp,
      userInfo: null, // userInfo는 별도 관리
    );
  }

  /// List<VoteDto> → List<Vote> 변환
  static List<Vote> toEntityList(List<VoteDto> dtos) {
    return dtos.map(toEntity).toList();
  }

  /// List<Vote> → List<VoteDto> 변환
  static List<VoteDto> toDtoList(List<Vote> entities) {
    return entities.map((e) => toDto(e)).toList();
  }
}
