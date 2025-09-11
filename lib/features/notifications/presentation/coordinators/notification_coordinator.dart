import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/models/vote_notification.dart' as domain;
import '../../domain/value_objects/vote_options.dart' as domain;
import '../../domain/usecases/initialize_notifications_use_case.dart';
import '../../domain/usecases/start_notification_listening_use_case.dart';
import '../../domain/usecases/stop_notification_listening_use_case.dart';
import '/features/voting/presentation/managers/vote_ui_manager.dart';

/// 알림 시스템 코디네이터 (Clean Architecture)
///
/// UseCase를 통해 Business 로직을 처리하고 UI와 연결
/// Singleton 패턴 제거, DI를 통한 의존성 주입
class NotificationCoordinator {
  // UseCase 의존성
  final InitializeNotificationsUseCase _initializeUseCase;
  final StartNotificationListeningUseCase _startListeningUseCase;
  final StopNotificationListeningUseCase _stopListeningUseCase;

  bool _isInitialized = false;

  // Factory constructor with DI
  factory NotificationCoordinator() {
    return NotificationCoordinator._(
      initializeUseCase: GetIt.instance<InitializeNotificationsUseCase>(),
      startListeningUseCase:
          GetIt.instance<StartNotificationListeningUseCase>(),
      stopListeningUseCase: GetIt.instance<StopNotificationListeningUseCase>(),
    );
  }

  // Private constructor for dependency injection
  NotificationCoordinator._({
    required InitializeNotificationsUseCase initializeUseCase,
    required StartNotificationListeningUseCase startListeningUseCase,
    required StopNotificationListeningUseCase stopListeningUseCase,
  })  : _initializeUseCase = initializeUseCase,
        _startListeningUseCase = startListeningUseCase,
        _stopListeningUseCase = stopListeningUseCase;

  // Static instance getter for backward compatibility
  static NotificationCoordinator get instance => NotificationCoordinator();

  /// 알림 시스템 초기화
  ///
  /// app.dart의 initState에서 호출되어야 함
  Future<void> initialize({
    required String userId,
    BuildContext? context,
  }) async {
    if (_isInitialized) {
      debugPrint('[NotificationCoordinator] 이미 초기화됨');
      return;
    }

    try {
      debugPrint('[NotificationCoordinator] 초기화 시작: $userId');

      // 1. UI Manager 초기화
      final uiManager = VoteUIManager.instance;
      if (context != null) {
        uiManager.setContext(context);
      }

      // 2. UseCase를 통한 초기화 (Clean Architecture)
      await _initializeUseCase.execute(userId: userId);

      // 3. UseCase를 통한 리스닝 시작
      await _startListeningUseCase.execute(userId: userId);

      _isInitialized = true;
      debugPrint('[NotificationCoordinator] ✅ 초기화 완료');
    } catch (e, stack) {
      debugPrint('[NotificationCoordinator] ❌ 초기화 실패: $e');
      debugPrint('$stack');
      rethrow;
    }
  }

  /// 알림 시스템 종료
  ///
  /// app.dart의 dispose에서 호출되어야 함
  Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    debugPrint('[NotificationCoordinator] 종료 시작');

    try {
      // UseCase를 통한 정리 (Clean Architecture)
      // TODO: userId를 저장해두고 여기서 사용해야 함
      // 현재는 임시로 빈 문자열 사용 (실제 구현 시 수정 필요)
      await _stopListeningUseCase.execute(userId: '');

      VoteUIManager.instance.dispose();

      _isInitialized = false;
      debugPrint('[NotificationCoordinator] ✅ 종료 완료');
    } catch (e) {
      debugPrint('[NotificationCoordinator] ❌ 종료 중 오류: $e');
    }
  }

  /// 컨텍스트 업데이트
  ///
  /// 네비게이션 등으로 컨텍스트가 변경될 때 호출
  void updateContext(BuildContext context) {
    if (!_isInitialized) {
      debugPrint('[NotificationCoordinator] 초기화되지 않음 - 컨텍스트 업데이트 건너뜀');
      return;
    }

    VoteUIManager.instance.setContext(context);
    debugPrint('[NotificationCoordinator] 컨텍스트 업데이트됨');
  }

  /// 수동으로 알림 표시 (테스트용)
  Future<void> showTestNotification({
    required BuildContext context,
    required String postId,
    required String title,
    required String optionA,
    required String optionB,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationCoordinator가 초기화되지 않음');
    }

    // 테스트용 Notification 객체 생성
    final testNotification = domain.VoteNotification(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'test_user',
      postId: postId,
      postTitle: title,
      title: title,
      content: '$optionA vs $optionB',
      postContent: '$optionA vs $optionB',
      createdAt: DateTime.now(),
      isRead: false,
      voteOptions: domain.VoteOptions(
        optionATitle: optionA,
        optionBTitle: optionB,
        optionAImageUrls: [],
        optionBImageUrls: [],
      ),
      voteStartTime: DateTime.now(),
      voteEndTime: DateTime.now().add(const Duration(minutes: 10)),
    );

    await VoteUIManager.instance.showVotingNotification(
      notification: testNotification,
      context: context,
      question: title,
      optionA: optionA,
      optionB: optionB,
      imageUrlsA: [],
      imageUrlsB: [],
      onVote: (option) async {
        debugPrint('[NotificationCoordinator] 테스트 투표: $option');
      },
      onDismiss: (hasVoted) {
        debugPrint('[NotificationCoordinator] 테스트 알림 닫기: 투표했음=$hasVoted');
      },
    );
  }

  /// 알림 큐 상태 조회
  Map<String, dynamic> getQueueStatus() {
    // TODO: GlobalNotificationManager를 UseCase로 추상화해야 함
    // 현재는 임시 데이터 반환
    return {
      'initialized': _isInitialized,
      'queueSize': 0,
      'isShowingNotification': false,
      'hasUIContext': VoteUIManager.instance.hasContext,
    };
  }

  /// 처리된 알림 개수 조회
  int getProcessedCount() {
    // TODO: UseCase를 통한 조회로 변경 필요
    return 0;
  }

  /// 알림 큐 비우기
  void clearQueue() {
    // TODO: UseCase를 통한 처리로 변경 필요
    debugPrint('[NotificationCoordinator] 알림 큐 비우기 - UseCase 구현 필요');
  }
}
