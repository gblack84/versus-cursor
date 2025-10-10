import 'package:dartz/dartz.dart';
import '../../repositories/i_characters_repository.dart';
import '../../models/character.dart';
import '../../failures/profile_failures.dart';

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
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<Character>)`: 캐릭터 목록 (활성 캐릭터만)
  Future<Either<ProfileFailure, List<Character>>> execute() async {
    return await _repository.getAvailableCharacters();
  }
}
