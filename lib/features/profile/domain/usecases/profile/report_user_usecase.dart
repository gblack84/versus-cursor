import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../failures/profile_failures.dart';

/// 사용자 신고 UseCase
///
/// **책임**: 부적절한 사용자 신고 처리
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, void>
class ReportUserUseCase {
  final IProfileRepository _repository;

  ReportUserUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 사용자 신고
  ///
  /// **Parameters**:
  /// - `userId`: 신고자 ID
  /// - `targetUserId`: 신고 대상 ID
  /// - `reason`: 신고 사유
  /// - `description`: 상세 설명 (선택)
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 자기 자신 신고 시도 또는 사유 누락
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(void)`: 신고 성공
  Future<Either<ProfileFailure, void>> execute(
    String userId,
    String targetUserId,
    String reason,
  ) async {
    // 자기 자신 신고 방지
    if (userId == targetUserId) {
      return Left(ValidationFailure(
        message: '자기 자신을 신고할 수 없습니다.',
      ));
    }

    // 신고 사유 검증
    if (reason.trim().isEmpty) {
      return Left(ValidationFailure(
        message: '신고 사유를 입력해주세요.',
      ));
    }

    try {
      await _repository.reportUser(userId, targetUserId, reason);
      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
