import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/models/vote_notification.dart' as domain;
import '../../domain/value_objects/vote_options.dart' as domain;
import '../../domain/usecases/initialize_notifications_use_case.dart';
import '../../domain/usecases/start_notification_listening_use_case.dart';
import '../../domain/usecases/stop_notification_listening_use_case.dart';
import '../../domain/usecases/get_queue_status_use_case.dart';
import '../../domain/usecases/get_processed_count_use_case.dart';
import '../../domain/usecases/clear_queue_use_case.dart';
import '/core/interfaces/features/i_vote_service.dart';

/// 알림 시스템 코디네이터 (Clean Architecture)
///
/// UseCase를 통해 Business 로직을 처리하고 UI와 연결
/// Singleton 패턴 제거, DI를 통한 의존성 주입
class NotificationCoordinator {
  // UseCase 의존성
  final InitializeNotificationsUseCase _initializeUseCase;
  final StartNotificationListeningUseCase _startListeningUseCase;
  final StopNotificationListeningUseCase _stopListeningUseCase;
  final GetQueueStatusUseCase _getQueueStatusUseCase;
  final GetProcessedCountUseCase _getProcessedCountUseCase;
  final ClearQueueUseCase _clearQueueUseCase;
  
  // Replace VoteUIManager dependency with IVoteService
  final IVoteService _voteService;

  bool _isInitialized = false;
  String _currentUserId = '';

  // Factory constructor with DI
  factory NotificationCoordinator() {
    return NotificationCoordinator._(
      initializeUseCase: GetIt.instance<InitializeNotificationsUseCase>(),
      startListeningUseCase:
          GetIt.instance<StartNotificationListeningUseCase>(),
      stopListeningUseCase: GetIt.instance<StopNotificationListeningUseCase>(),
      getQueueStatusUseCase: GetIt.instance<GetQueueStatusUseCase>(),
      getProcessedCountUseCase: GetIt.instance<GetProcessedCountUseCase>(),
      clearQueueUseCase: GetIt.instance<ClearQueueUseCase>(),
      voteService: GetIt.instance<IVoteService>(),
    );
  }

  // Private constructor for dependency injection
  NotificationCoordinator._({
    required InitializeNotificationsUseCase initializeUseCase,
    required StartNotificationListeningUseCase startListeningUseCase,
    required StopNotificationListeningUseCase stopListeningUseCase,
    required GetQueueStatusUseCase getQueueStatusUseCase,
    required GetProcessedCountUseCase getProcessedCountUseCase,
    required ClearQueueUseCase clearQueueUseCase,
    required IVoteService voteService,
  })  : _initializeUseCase = initializeUseCase,
        _startListeningUseCase = startListeningUseCase,
        _stopListeningUseCase = stopListeningUseCase,
        _getQueueStatusUseCase = getQueueStatusUseCase,
        _getProcessedCountUseCase = getProcessedCountUseCase,
        _clearQueueUseCase = clearQueueUseCase,
        _voteService = voteService;

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

      // 1. Vote Service 초기화
      if (context != null) {
        _voteService.setUIContext(context);
      }
      await _voteService.initialize();

      // 2. UseCase를 통한 초기화 (Clean Architecture)
      await _initializeUseCase.execute(userId: userId);

      // 3. UseCase를 통한 리스닝 시작
      await _startListeningUseCase.execute(userId: userId);

      // 4. 현재 사용자 ID 저장
      _currentUserId = userId;

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
      await _stopListeningUseCase.execute(userId: _currentUserId);

      _voteService.dispose();

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

    _voteService.setUIContext(context);
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

    // TODO: Convert to IVoteService after implementing concrete IVoteNotification
    // This requires a complete refactoring as voting.VoteNotification needs to implement IVoteNotification
    debugPrint('[NotificationCoordinator] 테스트 알림 표시 - IVoteService 구현 필요');
    
    // Temporary implementation - show simple debug message
    // await _voteService.showVotingNotification(
    //   context: context,
    //   notification: testNotification, // Need to convert to IVoteNotification
    //   onVote: (optionA) async {
    //     debugPrint('[NotificationCoordinator] 테스트 투표: ${optionA ? 'A' : 'B'}');
    //   },
    //   onDismiss: (hasVoted) {
    //     debugPrint('[NotificationCoordinator] 테스트 알림 닫기: 투표했음=$hasVoted');
    //   },
    // );
  }

  /// 알림 큐 상태 조회
  Future<Map<String, dynamic>> getQueueStatus() async {
    // UseCase를 통한 큐 상태 조회
    final result = await _getQueueStatusUseCase(null);
    
    if (result.isSuccess) {
      final status = result.data!;
      // UI context 정보 추가
      status['hasUIContext'] = _voteService.hasUIContext;
      status['initialized'] = _isInitialized;
      return status;
    } else {
      // 에러 시 기본값 반환
      return {
        'initialized': _isInitialized,
        'queueSize': 0,
        'isShowingNotification': false,
        'hasUIContext': _voteService.hasUIContext,
        'error': result.error,
      };
    }
  }

  /// 처리된 알림 개수 조회
  Future<int> getProcessedCount() async {
    // UseCase를 통한 처리 개수 조회
    if (_currentUserId.isEmpty) {
      debugPrint('[NotificationCoordinator] 사용자 ID가 없음');
      return 0;
    }
    
    final result = await _getProcessedCountUseCase(_currentUserId);
    
    if (result.isSuccess) {
      return result.data ?? 0;
    } else {
      debugPrint('[NotificationCoordinator] 처리 개수 조회 실패: ${result.error}');
      return 0;
    }
  }

  /// 알림 큐 비우기
  Future<void> clearQueue() async {
    // UseCase를 통한 큐 비우기
    if (_currentUserId.isEmpty) {
      debugPrint('[NotificationCoordinator] 사용자 ID가 없음');
      return;
    }
    
    debugPrint('[NotificationCoordinator] 알림 큐 비우기 시작');
    final result = await _clearQueueUseCase(_currentUserId);
    
    if (result.isSuccess) {
      debugPrint('[NotificationCoordinator] ✅ 알림 큐 비우기 완료');
    } else {
      debugPrint('[NotificationCoordinator] ❌ 알림 큐 비우기 실패: ${result.error}');
    }
  }
}
