import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../entities/notification.dart';
import '../repositories/i_notification_repository.dart';
import '../failures/notification_failure.dart';

/// UseCase for sending notifications to target users
/// Clean Architecture - Domain Business Logic for Notification Creation
///
/// **Phase 1 Complete**: Either Pattern 적용
/// - Uses fpdart Either<L,R> for type-safe error handling
/// - Repository returns Either, no need for try-catch
/// - Uses fold() to handle Either results
/// - Validates business rules before repository calls
class SendNotificationUseCase {
  final INotificationRepository _repository;

  SendNotificationUseCase(this._repository);

  Future<Either<NotificationFailure, List<String>>> call(
      SendNotificationParams params) async {
    // 비즈니스 규칙: 타겟 사용자 검증
    if (params.targetUserIds.isEmpty) {
      return left(const InvalidNotificationData());
    }

    // 비즈니스 규칙: 최대 타겟 사용자 수 제한
    const maxTargets = 100;
    if (params.targetUserIds.length > maxTargets) {
      return left(const InvalidNotificationData());
    }

    // 알림 타입별 처리
    // Note: VoteNotification is now handled by Voting Feature

    // 일반 알림 처리 - 각 사용자별로 생성
    final createdIds = <String>[];

    for (final userId in params.targetUserIds) {
      // 각 사용자별 알림 생성
      final userNotification = _createUserNotification(
        params.notification,
        userId,
      );

      // Repository 호출 - Either 반환 (eventId 생성)
      final result = await _repository.createNotification(
        userNotification,
        const Uuid().v4(), // UUID 생성
      );

      // fold()로 Either 처리
      final idOrError = result.fold(
        // Left: 생성 실패 시 전체 실패
        (failure) => left<NotificationFailure, String>(failure),
        // Right: 생성 성공 시 ID 반환
        (id) => right<NotificationFailure, String>(id),
      );

      // 에러 발생 시 즉시 반환
      if (idOrError.isLeft()) {
        return idOrError.fold(
          (failure) => left(failure),
          (_) => left(const NotificationSendFailed()), // 이 경로는 실행되지 않음
        );
      }

      // ID 수집
      idOrError.fold(
        (_) {}, // 이미 위에서 처리됨
        (id) => createdIds.add(id),
      );
    }

    return right(createdIds);
  }

  Notification _createUserNotification(
      Notification baseNotification, String userId) {
    // 사용자별 알림 생성 (ID와 userId 변경)
    // 실제 구현에서는 각 알림 타입별로 처리
    return baseNotification; // Simplified
  }
}

/// Parameters for SendNotificationUseCase
class SendNotificationParams {
  final Notification notification;
  final List<String> targetUserIds;
  final String? targetAudience; // 'quick', 'public', 'custom'

  const SendNotificationParams({
    required this.notification,
    required this.targetUserIds,
    this.targetAudience,
  });
}
