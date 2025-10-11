import 'package:dartz/dartz.dart';
import '../../repositories/i_characters_repository.dart';
import '../../models/character.dart';
import '../../failures/profile_failures.dart';

/// 사용자 캐릭터 조회 UseCase
///
/// **책임**: 사용자가 선택한 캐릭터/아바타 조회
/// **의존성**: ICharactersRepository
/// **반환**: Either<ProfileFailure, Character>
class GetUserCharacterUseCase {
  final ICharactersRepository _repository;

  GetUserCharacterUseCase({required ICharactersRepository repository})
      : _repository = repository;

  /// 사용자 캐릭터 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(CharacterNotFoundFailure)`: 캐릭터 미설정
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(Character)`: 캐릭터 정보
  Future<Either<ProfileFailure, Character>> execute(String userId) async {
    final result = await _repository.getUserCharacter(userId);

    return result.fold(
      (failure) => Left(failure),
      (character) => character != null
          ? Right(character)
          : Left(ProfileNotFoundFailure(userId: userId)),
    );
  }
}
