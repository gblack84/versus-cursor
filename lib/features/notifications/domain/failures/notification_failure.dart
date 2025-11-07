import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failures.dart';

part 'notification_failure.freezed.dart';

/// Notification Feature Failures
///
/// Domain Layer - 알림 관련 실패 케이스 정의
/// Freezed Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
/// - Core Failure 인터페이스 구현으로 Either<T> 호환성 확보
///
/// **16개 Failure 타입**:
/// - Notification CRUD Errors (6): NotificationNotFound, NotificationLoadFailed, NotificationSendFailed, NotificationCreateFailed, NotificationUpdateFailed, NotificationDeleteFailed
/// - Validation Errors (2): InvalidNotificationData, NotificationExpired
/// - Special Operations Errors (4): BroadcastFailed, GroupingFailed, StreamingFailed, InitializationFailed
/// - Network & Permission Errors (3): NetworkError, PermissionDenied, ServerError
/// - Generic Error (1): Unexpected
///
/// **사용 현황 (8/16 사용 중)**:
/// ✅ NotificationNotFound, NotificationLoadFailed, PermissionDenied, NetworkError
/// ✅ ServerError, Unexpected, NotificationSendFailed, InvalidNotificationData
/// ⏳ TODO: NotificationCreateFailed, NotificationUpdateFailed, NotificationDeleteFailed, NotificationExpired
/// ⏳ TODO: BroadcastFailed, GroupingFailed, StreamingFailed, InitializationFailed
@freezed
sealed class NotificationFailure with _$NotificationFailure implements Failure {
  const NotificationFailure._();

  // Equatable implementation (required by Failure interface)
  @override
  List<Object?> get props => [message, code];

  @override
  String? get code => null;

  @override
  bool? get stringify => true;

  // ========== Notification CRUD Errors ==========

  /// 알림을 찾을 수 없음
  ///
  /// **사용 위치**:
  /// - Repository: getNotification (L82)
  /// - Repository: markAsRead (L208, L242)
  const factory NotificationFailure.notificationNotFound() = NotificationNotFound;

  /// 알림 로드 실패
  ///
  /// **사용 위치**:
  /// - Repository: getNotifications (L132, L156)
  /// - Repository: getUnreadCount (L176)
  /// - Repository: watchNotifications (L318)
  const factory NotificationFailure.notificationLoadFailed() = NotificationLoadFailed;

  /// 알림 전송 실패
  ///
  /// **사용 위치**:
  /// - Repository: sendNotificationToUser (L444)
  const factory NotificationFailure.notificationSendFailed() = NotificationSendFailed;

  /// 알림 생성 실패
  ///
  /// **TODO**: 알림 생성 기능 구현 시 사용 예정
  const factory NotificationFailure.notificationCreateFailed() = NotificationCreateFailed;

  /// 알림 업데이트 실패
  ///
  /// **TODO**: 알림 업데이트 기능 구현 시 사용 예정
  const factory NotificationFailure.notificationUpdateFailed() = NotificationUpdateFailed;

  /// 알림 삭제 실패
  ///
  /// **TODO**: 알림 삭제 기능 구현 시 사용 예정
  const factory NotificationFailure.notificationDeleteFailed() = NotificationDeleteFailed;

  // ========== Validation Errors ==========

  /// 유효하지 않은 알림 데이터
  ///
  /// **사용 위치**:
  /// - UseCase: SendNotificationUseCase (L63)
  const factory NotificationFailure.invalidNotificationData() = InvalidNotificationData;

  /// 만료된 알림
  ///
  /// **TODO**: 알림 만료 검증 기능 구현 시 사용 예정
  const factory NotificationFailure.notificationExpired() = NotificationExpired;

  // ========== Special Operations Errors ==========

  /// 알림 브로드캐스트 실패
  ///
  /// **TODO**: 브로드캐스트 기능 구현 시 사용 예정
  const factory NotificationFailure.broadcastFailed() = BroadcastFailed;

  /// 알림 그룹화 실패
  ///
  /// **TODO**: 그룹화 기능 구현 시 사용 예정
  const factory NotificationFailure.groupingFailed() = GroupingFailed;

  /// 알림 스트리밍 실패
  ///
  /// **TODO**: 스트리밍 에러 처리 시 사용 예정
  const factory NotificationFailure.streamingFailed() = StreamingFailed;

  /// 알림 시스템 초기화 실패
  ///
  /// **TODO**: 초기화 검증 시 사용 예정
  const factory NotificationFailure.initializationFailed() = InitializationFailed;

  // ========== Network & Permission Errors ==========

  /// 네트워크 오류
  ///
  /// **사용 위치**:
  /// - Repository: watchNotifications (L321, L334, L347, L360, L373)
  /// - Repository: sendNotificationToUser (L447, L477)
  const factory NotificationFailure.networkError() = NetworkError;

  /// 권한 없음
  ///
  /// **사용 위치**:
  /// - Repository: watchNotifications (L324, L337, L350, L363, L376, L389, L402)
  /// - Repository: sendNotificationToUser (L450, L480, L493, L506, L519, L532, L545, L558)
  const factory NotificationFailure.permissionDenied() = PermissionDenied;

  /// 서버 오류
  ///
  /// **사용 위치**:
  /// - Repository: watchNotifications (L327, L340, L353, L366, L379)
  /// - Repository: sendNotificationToUser (L453, L483)
  const factory NotificationFailure.serverError() = ServerError;

  // ========== Generic Error ==========

  /// 예기치 않은 오류
  ///
  /// **사용 위치**: Repository (모든 catch 블록), UseCase
  const factory NotificationFailure.unexpected([String? errorMessage]) = Unexpected;

  /// Convert to user-friendly message (Implements Failure.message)
  @override
  String get message {
    return when(
      notificationNotFound: () => '알림을 찾을 수 없습니다',
      notificationLoadFailed: () => '알림을 불러오는데 실패했습니다',
      notificationSendFailed: () => '알림 전송에 실패했습니다',
      notificationCreateFailed: () => '알림 생성에 실패했습니다',
      notificationUpdateFailed: () => '알림 업데이트에 실패했습니다',
      notificationDeleteFailed: () => '알림 삭제에 실패했습니다',
      invalidNotificationData: () => '유효하지 않은 알림 데이터입니다',
      notificationExpired: () => '만료된 알림입니다',
      broadcastFailed: () => '알림 브로드캐스트에 실패했습니다',
      groupingFailed: () => '알림 그룹화에 실패했습니다',
      streamingFailed: () => '알림 스트리밍에 실패했습니다',
      initializationFailed: () => '알림 시스템 초기화에 실패했습니다',
      networkError: () => '네트워크 연결을 확인해주세요',
      permissionDenied: () => '알림 권한이 없습니다',
      serverError: () => '서버 오류가 발생했습니다',
      unexpected: (errorMessage) =>
          errorMessage ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
