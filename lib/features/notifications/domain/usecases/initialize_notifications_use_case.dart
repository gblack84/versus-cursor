import '../repositories/i_notification_repository.dart';

/// 알림 시스템 초기화 UseCase
///
/// Clean Architecture 원칙에 따라 GlobalNotificationManager와
/// NotificationService 초기화를 Domain 레이어에서 캡슐화
class InitializeNotificationsUseCase {
  final INotificationRepository _repository;

  const InitializeNotificationsUseCase(this._repository);

  /// 알림 시스템 초기화 실행
  ///
  /// [userId] - 초기화할 사용자 ID
  /// Returns: 성공 시 true, 실패 시 Exception 발생
  Future<bool> execute({
    required String userId,
  }) async {
    try {
      // 입력 검증
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      // Repository를 통한 초기화
      await _repository.initializeNotificationSystem(
        userId: userId,
      );

      return true;
    } catch (e) {
      throw Exception('Failed to initialize notifications: ${e.toString()}');
    }
  }
}
