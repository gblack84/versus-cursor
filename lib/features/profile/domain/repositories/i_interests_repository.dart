import 'package:dartz/dartz.dart';
import '../models/interest.dart';
import '../failures/profile_failures.dart';

/// Interests Repository 인터페이스
///
/// **책임**: 사용자 관심사 관리
abstract class IInterestsRepository {
  /// 사용자 관심사 업데이트
  ///
  /// **제약사항**:
  /// - expertise: 최대 4개
  /// - hobbies: 최대 8개
  Future<Either<ProfileFailure, void>> updateUserInterests(
    String userId,
    List<Interest> interests,
  );

  /// 사용자 관심사 조회
  Future<Either<ProfileFailure, List<Interest>>> getUserInterests(
    String userId,
  );

  /// 사용자 관심사 실시간 감시
  Stream<List<Interest>> watchUserInterests(String userId);
}
