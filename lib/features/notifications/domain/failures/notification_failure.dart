import '/core/errors/failures.dart';

/// Notification Failure
///
/// Domain Layer - 알림 관련 실패 케이스 정의
/// Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Failure Pattern**:
/// - Sealed Class 패턴으로 타입 안전성 보장
/// - Core Failure 상속으로 Result<T> 호환성 확보
/// - Pattern Matching으로 누락 케이스 컴파일 체크
/// - 중앙 집중식 에러 메시지 관리
sealed class NotificationFailure extends Failure {
  const NotificationFailure() : super(message: '');

  /// Convert to user-friendly message (Override Failure.message)
  @override
  String get message {
    return switch (this) {
      // Notification CRUD errors
      NotificationNotFound() => '알림을 찾을 수 없습니다',
      NotificationLoadFailed() => '알림을 불러오는데 실패했습니다',
      NotificationSendFailed() => '알림 전송에 실패했습니다',
      NotificationCreateFailed() => '알림 생성에 실패했습니다',
      NotificationUpdateFailed() => '알림 업데이트에 실패했습니다',
      NotificationDeleteFailed() => '알림 삭제에 실패했습니다',

      // Validation errors
      InvalidNotificationData() => '유효하지 않은 알림 데이터입니다',
      NotificationExpired() => '만료된 알림입니다',

      // Special operations errors
      BroadcastFailed() => '알림 브로드캐스트에 실패했습니다',
      GroupingFailed() => '알림 그룹화에 실패했습니다',
      StreamingFailed() => '알림 스트리밍에 실패했습니다',
      InitializationFailed() => '알림 시스템 초기화에 실패했습니다',

      // Network & Permission errors
      NetworkError() => '네트워크 연결을 확인해주세요',
      PermissionDenied() => '알림 권한이 없습니다',
      ServerError() => '서버 오류가 발생했습니다',

      // Generic error
      Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// ==================== Notification CRUD Errors ====================

/// 알림을 찾을 수 없음
class NotificationNotFound extends NotificationFailure {
  const NotificationNotFound() : super();
}

/// 알림 로드 실패
class NotificationLoadFailed extends NotificationFailure {
  const NotificationLoadFailed() : super();
}

/// 알림 전송 실패
class NotificationSendFailed extends NotificationFailure {
  const NotificationSendFailed() : super();
}

/// 알림 생성 실패
class NotificationCreateFailed extends NotificationFailure {
  const NotificationCreateFailed() : super();
}

/// 알림 업데이트 실패
class NotificationUpdateFailed extends NotificationFailure {
  const NotificationUpdateFailed() : super();
}

/// 알림 삭제 실패
class NotificationDeleteFailed extends NotificationFailure {
  const NotificationDeleteFailed() : super();
}

// ==================== Validation Errors ====================

/// 유효하지 않은 알림 데이터
class InvalidNotificationData extends NotificationFailure {
  const InvalidNotificationData() : super();
}

/// 만료된 알림
class NotificationExpired extends NotificationFailure {
  const NotificationExpired() : super();
}

// ==================== Special Operations Errors ====================

/// 알림 브로드캐스트 실패
class BroadcastFailed extends NotificationFailure {
  const BroadcastFailed() : super();
}

/// 알림 그룹화 실패
class GroupingFailed extends NotificationFailure {
  const GroupingFailed() : super();
}

/// 알림 스트리밍 실패
class StreamingFailed extends NotificationFailure {
  const StreamingFailed() : super();
}

/// 알림 시스템 초기화 실패
class InitializationFailed extends NotificationFailure {
  const InitializationFailed() : super();
}

// ==================== Network & Permission Errors ====================

/// 네트워크 오류
class NetworkError extends NotificationFailure {
  const NetworkError() : super();
}

/// 권한 없음
class PermissionDenied extends NotificationFailure {
  const PermissionDenied() : super();
}

/// 서버 오류
class ServerError extends NotificationFailure {
  const ServerError() : super();
}

// ==================== Generic Error ====================

/// 예기치 않은 오류
class Unexpected extends NotificationFailure {
  final String? errorMessage;
  const Unexpected([this.errorMessage]) : super();
}
