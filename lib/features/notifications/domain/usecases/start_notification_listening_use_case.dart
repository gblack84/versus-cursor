import '../models/notification.dart';
import '../repositories/i_notification_repository.dart';

/// 알림 리스닝 시작 UseCase
///
/// Clean Architecture 원칙에 따라 실시간 알림 스트림 관리를
/// Domain 레이어에서 처리
class StartNotificationListeningUseCase {
  final INotificationRepository _repository;

  const StartNotificationListeningUseCase(this._repository);

  /// 알림 리스닝 시작
  ///
  /// [userId] - 리스닝할 사용자 ID
  /// Returns: Stream<Notification>
  Future<Stream<Notification>> execute({
    required String userId,
  }) async {
    try {
      // 입력 검증
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      // Repository를 통한 리스닝 시작
      final stream = await _repository.startListening(
        userId: userId,
      );

      return stream;
    } catch (e) {
      throw Exception(
          'Failed to start notification listening: ${e.toString()}');
    }
  }
}
