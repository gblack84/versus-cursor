import 'package:dartz/dartz.dart';
import '../entities/character.dart';
import '../failures/profile_failure.dart';

/// Characters Repository 인터페이스
///
/// **책임**: 사용 가능한 캐릭터/아바타 조회
///
/// **Phase 6 Cleanup**:
/// - getUserCharacter, setUserCharacter, clearUserCharacter 삭제
/// - watchUserCharacter 삭제 (Stream 미사용)
/// - 현재 시스템: photoUrl 직접 저장 (characterId 추적 안 함)
abstract class ICharactersRepository {
  /// 이용 가능한 모든 캐릭터 조회
  ///
  /// **Returns**:
  /// - `Right(List<Character>)`: 사용 가능한 캐릭터 목록
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, List<Character>>> getAvailableCharacters();
}
