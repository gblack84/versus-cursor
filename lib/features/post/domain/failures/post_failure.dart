import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_failure.freezed.dart';

/// Post Feature의 모든 실패 타입을 정의하는 Sealed Class
///
/// **Either Pattern과 함께 사용**:
/// ```dart
/// final result = await getPostUseCase.execute(postId);
/// result.fold(
///   (failure) {
///     failure.when(
///       postNotFound: (postId) => print('Post $postId not found'),
///       networkError: () => print('Network error'),
///       ...
///     );
///   },
///   (post) => print('Success: ${post.id}'),
/// );
/// ```
@freezed
sealed class PostFailure with _$PostFailure {
  // ========== Network & Server Errors ==========

  /// 네트워크 연결 실패
  ///
  /// **발생 시나리오**:
  /// - 인터넷 연결 없음
  /// - Firestore 서버 접근 불가
  const factory PostFailure.networkError() = NetworkError;

  /// 서버 에러 (Firebase 서버 문제)
  ///
  /// **발생 시나리오**:
  /// - Firestore 내부 오류
  /// - Cloud Functions 실행 실패
  const factory PostFailure.serverError({String? message}) = ServerError;

  /// 요청 시간 초과
  ///
  /// **발생 시나리오**:
  /// - Firestore 쿼리가 10초 이상 소요
  /// - 네트워크 지연
  const factory PostFailure.timeout() = TimeoutError;

  // ========== Permission & Auth Errors ==========

  /// 권한 부족 (Firestore Security Rules 거부)
  ///
  /// **발생 시나리오**:
  /// - 로그인하지 않은 사용자가 게시물 작성 시도
  /// - 다른 사용자의 게시물 수정/삭제 시도
  const factory PostFailure.insufficientPermissions() = InsufficientPermissions;

  /// 인증되지 않은 사용자
  ///
  /// **발생 시나리오**:
  /// - Firebase Auth 토큰 만료
  /// - 로그아웃 상태에서 작업 시도
  const factory PostFailure.unauthorized() = Unauthorized;

  // ========== Resource Errors ==========

  /// 게시물을 찾을 수 없음
  ///
  /// **발생 시나리오**:
  /// - 존재하지 않는 postId로 조회
  /// - 삭제된 게시물 접근
  const factory PostFailure.postNotFound({required String postId}) = PostNotFound;

  /// 사용자를 찾을 수 없음
  ///
  /// **발생 시나리오**:
  /// - 존재하지 않는 userId로 게시물 조회
  /// - 탈퇴한 사용자의 게시물 조회
  const factory PostFailure.userNotFound({required String userId}) = UserNotFound;

  // ========== Validation Errors ==========

  /// 입력값이 유효하지 않음
  ///
  /// **발생 시나리오**:
  /// - 빈 제목 또는 내용
  /// - 잘못된 형식의 데이터
  const factory PostFailure.invalidInput({required String field}) = InvalidInput;

  /// 내용이 너무 긺
  ///
  /// **발생 시나리오**:
  /// - 제목/내용이 최대 길이 초과
  const factory PostFailure.contentTooLong({required int maxLength}) =
      ContentTooLong;

  // ========== Operation Errors ==========

  /// 게시물 생성 실패
  ///
  /// **발생 시나리오**:
  /// - Firestore 쓰기 권한 없음
  /// - 잘못된 데이터 형식
  const factory PostFailure.createFailed({String? reason}) = CreateFailed;

  /// 게시물 수정 실패
  ///
  /// **발생 시나리오**:
  /// - 존재하지 않는 게시물 수정 시도
  /// - 수정 권한 없음
  const factory PostFailure.updateFailed({String? reason}) = UpdateFailed;

  /// 게시물 삭제 실패
  ///
  /// **발생 시나리오**:
  /// - 존재하지 않는 게시물 삭제 시도
  /// - 삭제 권한 없음
  const factory PostFailure.deleteFailed({String? reason}) = DeleteFailed;

  // ========== Search & Query Errors ==========

  /// 검색 실패
  ///
  /// **발생 시나리오**:
  /// - 검색 쿼리가 너무 복잡
  /// - Firestore 쿼리 오류
  const factory PostFailure.searchFailed({String? query}) = SearchFailed;

  /// 쿼리 실행 실패
  ///
  /// **발생 시나리오**:
  /// - 잘못된 쿼리 파라미터
  /// - Firestore 쿼리 제한 초과
  const factory PostFailure.queryFailed({String? reason}) = QueryFailed;

  // ========== Unexpected ==========

  /// 예상치 못한 에러
  ///
  /// **발생 시나리오**:
  /// - 위 카테고리에 속하지 않는 모든 에러
  /// - 시스템 내부 오류
  const factory PostFailure.unexpected({
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) = Unexpected;
}
