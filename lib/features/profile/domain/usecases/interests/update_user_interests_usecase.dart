import 'package:dartz/dartz.dart';
import '../../failures/profile_failure.dart';
import '../../repositories/i_interests_repository.dart';
import '../../entities/interest.dart';

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
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  ///   - `ProfileFailure.duplicateOperation`: 이미 처리된 작업 (eventId 중복)
  ///
  /// **Phase 1.3**: IdempotencyService 지원 추가
  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
    required List<String> expertise,
    required List<String> hobbies,
    String? eventId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      // 2. 전문분야 검증 (최대 4개)
      if (expertise.length > 4) {
        return left(ProfileFailure.validation('expertise.length'));
      }

      // 3. 취미 검증 (최대 8개)
      if (hobbies.length > 8) {
        return left(ProfileFailure.validation('hobbies.length'));
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

      // 5. Repository를 통한 업데이트 (이미 Either 반환)
      return await _repository.updateUserInterests(userId, allInterests, eventId: eventId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
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
  /// - `Right(unit)`: 추가 성공
  /// - `Left(ProfileFailure)`: 추가 실패
  Future<Either<ProfileFailure, Unit>> addInterest({
    required String userId,
    required String interest,
    required String category,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }
      if (interest.isEmpty) {
        return left(ProfileFailure.validation('interest'));
      }
      if (category != 'expertise' && category != 'hobby') {
        return left(ProfileFailure.validation('category'));
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
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
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
  /// - `Right(unit)`: 제거 성공
  /// - `Left(ProfileFailure)`: 제거 실패
  Future<Either<ProfileFailure, Unit>> removeInterest({
    required String userId,
    required String interest,
    required String category,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }
      if (interest.isEmpty) {
        return left(ProfileFailure.validation('interest'));
      }
      if (category != 'expertise' && category != 'hobby') {
        return left(ProfileFailure.validation('category'));
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
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
