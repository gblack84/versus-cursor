import 'package:dartz/dartz.dart';
import '../../repositories/i_characters_repository.dart';
import '../../models/character.dart';
import '../../failures/profile_failures.dart';

/// 사용자 캐릭터 설정 UseCase
///
/// **책임**: 사용자 캐릭터/아바타 변경
/// **의존성**: ICharactersRepository
/// **반환**: Either<ProfileFailure, Character>
class SetUserCharacterUseCase {
  final ICharactersRepository _repository;

  SetUserCharacterUseCase({required ICharactersRepository repository})
      : _repository = repository;

  /// 사용자 캐릭터 설정
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `characterId`: 선택할 캐릭터 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(CharacterNotFoundFailure)`: 캐릭터가 존재하지 않음
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(Character)`: 설정된 캐릭터 정보
  Future<Either<ProfileFailure, Character>> execute({
    required String userId,
    required String characterId,
  }) async {
    return await _repository.setUserCharacter(
      userId: userId,
      characterId: characterId,
    );
  }
}
