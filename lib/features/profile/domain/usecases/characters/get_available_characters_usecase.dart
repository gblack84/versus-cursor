import '/core/types/result.dart';
import '../../repositories/i_characters_repository.dart';
import '../../models/character.dart';

/// 사용 가능한 캐릭터 목록 조회 UseCase
///
/// **책임**: 선택 가능한 전체 캐릭터 목록 조회
/// **의존성**: ICharactersRepository
/// **반환**: Result<List<Character>>
class GetAvailableCharactersUseCase {
  final ICharactersRepository _repository;

  GetAvailableCharactersUseCase({required ICharactersRepository repository})
      : _repository = repository;

  /// 사용 가능한 캐릭터 목록 조회
  ///
  /// **Returns**:
  /// - `ResultFailure(FirestoreRead)`: Firestore 읽기 실패
  /// - `Success(List<Character>)`: 캐릭터 목록 (활성 캐릭터만)
  Future<Result<List<Character>>> execute() async {
    return await _repository.getAvailableCharacters();
  }
}
