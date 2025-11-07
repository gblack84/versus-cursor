import 'package:fpdart/fpdart.dart';
import '../entities/interest.dart';
import '../failures/profile_failure.dart';

/// Interests Repository 인터페이스
///
/// **책임**: 사용자 관심사 관리
/// **레거시 지원**: Firestore arrayUnion/arrayRemove 패턴 지원
abstract class IInterestsRepository {
  /// 사용자 관심사 전체 업데이트
  ///
  /// **제약사항**:
  /// - expertise: 최대 4개
  /// - hobbies: 최대 8개
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `interests`: 업데이트할 관심사 목록
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  /// - `Left(ProfileFailure.duplicateOperation)`: 이미 처리된 작업
  Future<Either<ProfileFailure, Unit>> updateUserInterests(
    String userId,
    List<Interest> interests, {
    String? eventId,
  });

  /// 관심사 개별 추가 (arrayUnion)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 370-380
  /// - hobbies_select_widget.dart: line 130-140
  ///
  /// [userId]: 사용자 ID
  /// [interest]: 추가할 관심사 (category: 'expertise' | 'hobby')
  ///
  /// **Returns**:
  /// - `Right(unit)`: 추가 성공
  /// - `Left(ProfileFailure)`: 추가 실패
  Future<Either<ProfileFailure, Unit>> addInterest({
    required String userId,
    required Interest interest,
  });

  /// 관심사 개별 제거 (arrayRemove)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 559-569
  /// - hobbies_select_widget.dart: line 319-329
  ///
  /// [userId]: 사용자 ID
  /// [interest]: 제거할 관심사 (category: 'expertise' | 'hobby')
  ///
  /// **Returns**:
  /// - `Right(unit)`: 제거 성공
  /// - `Left(ProfileFailure)`: 제거 실패
  Future<Either<ProfileFailure, Unit>> removeInterest({
    required String userId,
    required Interest interest,
  });

  /// 사용자 관심사 조회
  ///
  /// **Returns**:
  /// - `Right(List<Interest>)`: 사용자 관심사 목록
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, List<Interest>>> getUserInterests(
    String userId,
  );

  // Phase 6 Cleanup: watchUserInterests 삭제 (Stream 미사용)
}
