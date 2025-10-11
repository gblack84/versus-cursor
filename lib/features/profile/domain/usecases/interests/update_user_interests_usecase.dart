import 'package:dartz/dartz.dart';
import '../../failures/profile_failures.dart';
import '../../repositories/i_interests_repository.dart';
import '../../models/interest.dart';

/// 사용자 관심사 업데이트 UseCase
///
/// **책임**:
/// - 관심사 데이터 유효성 검증
/// - Repository를 통한 관심사 업데이트
/// - 에러 처리 및 Failure 변환
class UpdateUserInterestsUseCase {
  final IInterestsRepository _repository;

  UpdateUserInterestsUseCase({
    required IInterestsRepository repository,
  }) : _repository = repository;

  /// 관심사 업데이트 실행
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `expertise`: 전문분야 리스트 (최대 4개)
  /// - `hobbies`: 취미 리스트 (최대 8개)
  ///
  /// **Returns**:
  /// - `Right(void)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  Future<Either<ProfileFailure, void>> execute({
    required String userId,
    required List<String> expertise,
    required List<String> hobbies,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }

      // 2. 전문분야 검증 (최대 4개)
      if (expertise.length > 4) {
        return Left(
            ValidationFailure(message: 'Maximum 4 expertise areas allowed'));
      }

      // 3. 취미 검증 (최대 8개)
      if (hobbies.length > 8) {
        return Left(ValidationFailure(message: 'Maximum 8 hobbies allowed'));
      }

      // 4. Interest 객체로 변환
      final expertiseInterests = expertise
          .map((name) => Interest(
                id: name.toLowerCase().replaceAll(' ', '_'),
                name: name,
                category: 'expertise',
                weight: 0.5,
                selectedAt: DateTime.now(),
              ))
          .toList();

      final hobbiesInterests = hobbies
          .map((name) => Interest(
                id: name.toLowerCase().replaceAll(' ', '_'),
                name: name,
                category: 'hobby',
                weight: 0.5,
                selectedAt: DateTime.now(),
              ))
          .toList();

      final allInterests = [...expertiseInterests, ...hobbiesInterests];

      // 5. Repository를 통한 업데이트
      return await _repository.updateUserInterests(userId, allInterests);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
