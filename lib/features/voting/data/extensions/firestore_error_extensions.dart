import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/failures/voting_failure.dart';

/// Firebase Exception → VotingFailure 변환 Extension
///
/// **Firebase-Centric Architecture v1.0**:
/// - Repository에서 Firebase Exception을 Domain Failure로 변환
/// - 각 Firebase 에러 코드를 적절한 VotingFailure로 매핑
/// - 사용자 친화적인 에러 메시지 제공
///
/// **사용 예시**:
/// ```dart
/// try {
///   await _firestore.collection('posts').doc(postId).get();
/// } on FirebaseException catch (e) {
///   return Left(e.toVotingFailure());  // ✅ Extension 사용
/// }
/// ```
extension FirebaseErrorExtension on FirebaseException {
  /// Firebase Exception → VotingFailure 변환
  ///
  /// **매핑 규칙**:
  /// - `permission-denied`: 권한 거부 (인증 필요 또는 권한 부족)
  /// - `not-found`: 문서가 존재하지 않음 (삭제되었거나 잘못된 ID)
  /// - `already-exists`: 이미 존재함 (중복 생성 시도)
  /// - `unavailable`: 네트워크 오류 또는 서버 다운
  /// - `deadline-exceeded`: 타임아웃 (느린 네트워크)
  /// - `resource-exhausted`: 할당량 초과 (Firestore 쿼리 제한)
  /// - `invalid-argument`: 잘못된 인자 (필드 타입 불일치)
  /// - `unauthenticated`: 인증되지 않은 사용자
  /// - 기타: 예상치 못한 에러
  VotingFailure toVotingFailure() {
    switch (code) {
      // 권한 관련 에러
      case 'permission-denied':
        return VotingFailure.permissionDenied(
          message ?? '해당 작업을 수행할 권한이 없습니다',
        );

      case 'unauthenticated':
        return const VotingFailure.unauthenticated();

      // 데이터 관련 에러
      case 'not-found':
        return const VotingFailure.notFound();

      case 'already-exists':
        return VotingFailure.alreadyExists(
          message ?? '이미 존재하는 데이터입니다',
        );

      // 네트워크 관련 에러
      case 'unavailable':
        return const VotingFailure.networkError();

      case 'deadline-exceeded':
        return const VotingFailure.timeout();

      // 할당량 관련 에러
      case 'resource-exhausted':
        return VotingFailure.quotaExceeded(
          message ?? 'Firestore 할당량을 초과했습니다',
        );

      // 입력 검증 에러
      case 'invalid-argument':
        return VotingFailure.invalidArgument(
          message ?? '잘못된 요청 파라미터입니다',
        );

      case 'failed-precondition':
        return VotingFailure.failedPrecondition(
          message ?? '사전 조건이 충족되지 않았습니다',
        );

      // 기타 에러
      case 'cancelled':
        return const VotingFailure.cancelled();

      case 'aborted':
        return const VotingFailure.aborted();

      default:
        return VotingFailure.unexpected(
          message ?? 'Firebase 에러: $code',
        );
    }
  }
}

/// String 에러 메시지 → VotingFailure 변환 Extension
///
/// **사용 케이스**: try-catch에서 일반 Exception 처리 시
///
/// **사용 예시**:
/// ```dart
/// } catch (e) {
///   return Left(e.toString().toVotingFailure());
/// }
/// ```
extension StringErrorExtension on String {
  VotingFailure toVotingFailure() {
    final errorStr = toLowerCase();

    // 한국어 에러 메시지 패턴 매칭
    if (errorStr.contains('이미 투표')) {
      return const VotingFailure.alreadyVoted();
    } else if (errorStr.contains('찾을 수 없')) {
      return const VotingFailure.notFound();
    } else if (errorStr.contains('권한')) {
      return VotingFailure.permissionDenied(this);
    } else if (errorStr.contains('네트워크') || errorStr.contains('연결')) {
      return const VotingFailure.networkError();
    } else if (errorStr.contains('시간 초과') || errorStr.contains('timeout')) {
      return const VotingFailure.timeout();
    }

    // 기본: Unexpected
    return VotingFailure.unexpected(this);
  }
}
