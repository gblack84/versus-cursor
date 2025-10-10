/// Profile Feature의 모든 Failure 기본 클래스
///
/// **Phase 3 패턴**: `getUserMessage()` 메서드로 사용자 친화적 에러 메시지 제공
abstract class ProfileFailure implements Exception {
  final String message;

  const ProfileFailure({required this.message});

  /// 사용자에게 표시할 친화적 에러 메시지
  ///
  /// **예시**:
  /// - 개발자용: "Firestore read failed: permission denied"
  /// - 사용자용: "프로필을 불러올 수 없습니다. 다시 시도해주세요."
  String getUserMessage();

  @override
  String toString() => 'ProfileFailure: $message';
}

/// 유효성 검증 실패 Failure
class ValidationFailure extends ProfileFailure {
  const ValidationFailure({required String message}) : super(message: message);

  @override
  String getUserMessage() => '입력 정보를 확인해주세요: $message';
}

/// 프로필 미발견 Failure
class ProfileNotFoundFailure extends ProfileFailure {
  final String userId;

  const ProfileNotFoundFailure({required this.userId})
      : super(message: 'Profile not found for user: $userId');

  @override
  String getUserMessage() => '프로필을 찾을 수 없습니다.';
}

/// Firestore 읽기 실패 Failure
class FirestoreReadFailure extends ProfileFailure {
  const FirestoreReadFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() =>
      '데이터를 불러올 수 없습니다. 네트워크 연결을 확인해주세요.';
}

/// Firestore 쓰기 실패 Failure
class FirestoreWriteFailure extends ProfileFailure {
  const FirestoreWriteFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '저장에 실패했습니다. 다시 시도해주세요.';
}

/// Storage 업로드 실패 Failure
class StorageFailure extends ProfileFailure {
  const StorageFailure({required String message}) : super(message: message);

  @override
  String getUserMessage() => '이미지 업로드에 실패했습니다. 다시 시도해주세요.';
}

/// 네트워크 실패 Failure
class NetworkFailure extends ProfileFailure {
  const NetworkFailure({required String message}) : super(message: message);

  @override
  String getUserMessage() => '네트워크 연결을 확인해주세요.';
}

/// 권한 거부 Failure
class PermissionDeniedFailure extends ProfileFailure {
  const PermissionDeniedFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '접근 권한이 없습니다.';
}

/// 알 수 없는 Profile 에러 Failure
class UnknownProfileFailure extends ProfileFailure {
  const UnknownProfileFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '알 수 없는 오류가 발생했습니다. 다시 시도해주세요.';
}
