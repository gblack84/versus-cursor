import 'package:dartz/dartz.dart';
import '../models/character.dart';
import '../failures/profile_failures.dart';

/// Characters Repository 인터페이스
///
/// **책임**: 사용자 캐릭터/아바타 관리
abstract class ICharactersRepository {
  /// 사용자 캐릭터 조회
  Future<Either<ProfileFailure, Character?>> getUserCharacter(String userId);

  /// 사용자 캐릭터 설정
  Future<Either<ProfileFailure, void>> setUserCharacter(
    String userId,
    String characterId,
  );

  /// 사용자 캐릭터 삭제 (기본 캐릭터로 초기화)
  Future<Either<ProfileFailure, void>> clearUserCharacter(String userId);

  /// 사용자 캐릭터 실시간 감시
  Stream<Character?> watchUserCharacter(String userId);

  /// 이용 가능한 모든 캐릭터 조회
  Future<Either<ProfileFailure, List<Character>>> getAvailableCharacters();
}
