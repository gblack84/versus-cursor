import '../repositories/i_notification_repository.dart';

/// 알림 리스닝 중지 UseCase
///
/// Clean Architecture 원칙에 따라 리소스 정리 및 스트림 종료를
/// Domain 레이어에서 처리
class StopNotificationListeningUseCase {
  final INotificationRepository _repository;

  const StopNotificationListeningUseCase(this._repository);

  /// 알림 리스닝 중지
  ///
  /// [userId] - 중지할 사용자 ID
  /// Returns: 성공 시 true, 실패 시 Exception 발생
  Future<bool> execute({
    required String userId,
  }) async {
    try {
      // 입력 검증
      if (userId.isEmpty) {
        throw ArgumentError('User ID cannot be empty');
      }

      // Repository를 통한 리스닝 중지
      await _repository.stopListening(
        userId: userId,
      );

      return true;
    } catch (e) {
      throw Exception('Failed to stop notification listening: ${e.toString()}');
    }
  }
}
