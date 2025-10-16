import 'package:dartz/dartz.dart';
import '../models/interest.dart';
import '../failures/profile_failures.dart';

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
  Future<Either<ProfileFailure, void>> updateUserInterests(
    String userId,
    List<Interest> interests,
  );

  /// 관심사 개별 추가 (arrayUnion)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 370-380
  /// - hobbies_select_widget.dart: line 130-140
  ///
  /// [userId]: 사용자 ID
  /// [interest]: 추가할 관심사 (category: 'expertise' | 'hobby')
  Future<Either<ProfileFailure, void>> addInterest({
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
  Future<Either<ProfileFailure, void>> removeInterest({
    required String userId,
    required Interest interest,
  });

  /// 사용자 관심사 조회
  Future<Either<ProfileFailure, List<Interest>>> getUserInterests(
    String userId,
  );

  // Phase 6 Cleanup: watchUserInterests 삭제 (Stream 미사용)
}
