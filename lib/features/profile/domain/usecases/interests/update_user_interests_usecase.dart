import '/core/types/result.dart';
import '../../failures/profile_failure.dart';
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
  /// - `Success(void)`: 업데이트 성공
  /// - `ResultFailure(ProfileFailure)`: 업데이트 실패
  Future<Result<void>> execute({
    required String userId,
    required List<String> expertise,
    required List<String> hobbies,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }

      // 2. 전문분야 검증 (최대 4개)
      if (expertise.length > 4) {
        return ResultFailure(ValidationFailure('expertise.length'));
      }

      // 3. 취미 검증 (최대 8개)
      if (hobbies.length > 8) {
        return ResultFailure(ValidationFailure('hobbies.length'));
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
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }

  /// Interest 추가 (개별 아이템)
  ///
  /// **Week 7**: @Deprecated 메서드 대체용
  /// - ProfileProvider.addInterestLegacy() 대체
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `interest`: 추가할 관심사/취미
  /// - `category`: 'expertise' 또는 'hobby'
  ///
  /// **Returns**:
  /// - `Success(void)`: 추가 성공
  /// - `ResultFailure(ProfileFailure)`: 추가 실패
  Future<Result<void>> addInterest({
    required String userId,
    required String interest,
    required String category,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }
      if (interest.isEmpty) {
        return ResultFailure(ValidationFailure('interest'));
      }
      if (category != 'expertise' && category != 'hobby') {
        return ResultFailure(ValidationFailure('category'));
      }

      // 2. Interest 객체 생성
      final interestObj = Interest(
        id: interest.toLowerCase().replaceAll(' ', '_'),
        name: interest,
        category: category,
        weight: 0.5,
        selectedAt: DateTime.now(),
      );

      // 3. Repository를 통한 추가
      return await _repository.addInterest(
        userId: userId,
        interest: interestObj,
      );
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }

  /// Interest 제거 (개별 아이템)
  ///
  /// **Week 7**: @Deprecated 메서드 대체용
  /// - ProfileProvider.removeInterestLegacy() 대체
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `interest`: 제거할 관심사/취미
  /// - `category`: 'expertise' 또는 'hobby'
  ///
  /// **Returns**:
  /// - `Success(void)`: 제거 성공
  /// - `ResultFailure(ProfileFailure)`: 제거 실패
  Future<Result<void>> removeInterest({
    required String userId,
    required String interest,
    required String category,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }
      if (interest.isEmpty) {
        return ResultFailure(ValidationFailure('interest'));
      }
      if (category != 'expertise' && category != 'hobby') {
        return ResultFailure(ValidationFailure('category'));
      }

      // 2. Interest 객체 생성
      final interestObj = Interest(
        id: interest.toLowerCase().replaceAll(' ', '_'),
        name: interest,
        category: category,
        weight: 0.5,
        selectedAt: DateTime.now(),
      );

      // 3. Repository를 통한 제거
      return await _repository.removeInterest(
        userId: userId,
        interest: interestObj,
      );
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
