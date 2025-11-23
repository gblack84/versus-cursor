import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_characters_repository.dart';
import '../../entities/character.dart';
import '../../failures/profile_failure.dart';

/// 사용 가능한 캐릭터 목록 조회 UseCase
///
/// **책임**: 선택 가능한 전체 캐릭터 목록 조회
/// **의존성**: ICharactersRepository
/// **반환**: Either<ProfileFailure, List<Character>>
class GetAvailableCharactersUseCase {
  final ICharactersRepository _repository;

  GetAvailableCharactersUseCase({required ICharactersRepository repository})
      : _repository = repository;

  /// 사용 가능한 캐릭터 목록 조회
  ///
  /// **Returns**:
  /// - `Left(FirestoreRead)`: Firestore 읽기 실패
  /// - `Right(List<Character>)`: 캐릭터 목록 (활성 캐릭터만)
  Future<Either<ProfileFailure, List<Character>>> execute() async {
    DevLogger.checkpoint('Calling repository.getAvailableCharacters', tag: 'GetAvailableCharacters');

    try {
      final result = await _repository.getAvailableCharacters();

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'GetAvailableCharacters'),
        (characters) => DevLogger.result(isSuccess: true, data: '${characters.length} characters', tag: 'GetAvailableCharacters'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'GetAvailableCharacters');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'GetAvailableCharacters');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
