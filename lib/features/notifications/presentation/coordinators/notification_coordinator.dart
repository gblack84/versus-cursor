import 'package:flutter/material.dart';
import '../../data/adapters/global_notification_manager.dart';
import '../../data/adapters/notification_service.dart';
import '../managers/notification_ui_manager.dart';
import '../managers/i_notification_ui_delegate.dart';

/// 알림 시스템 코디네이터
/// 
/// UI 레이어와 Business 레이어를 연결하고 조율하는 역할
/// app.dart에서 초기화되어 전체 알림 시스템을 통합 관리
class NotificationCoordinator {
  static final NotificationCoordinator _instance = NotificationCoordinator._internal();
  static NotificationCoordinator get instance => _instance;
  
  NotificationCoordinator._internal();
  
  bool _isInitialized = false;
  
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
      final uiManager = NotificationUIManager.instance;
      if (context != null) {
        uiManager.setContext(context);
      }
      
      // 2. Global Notification Manager에 UI 대리자 설정
      GlobalNotificationManager.instance.setUIDelegate(uiManager);
      
      // 3. Notification Service 시작
      NotificationService.instance.startListening(userId);
      
      // 4. Global Notification Manager 시작
      GlobalNotificationManager.instance.startListening();
      
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
  void dispose() {
    if (!_isInitialized) {
      return;
    }
    
    debugPrint('[NotificationCoordinator] 종료 시작');
    
    try {
      // 역순으로 정리
      GlobalNotificationManager.instance.stopListening();
      NotificationService.instance.stopListening();
      NotificationUIManager.instance.dispose();
      
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
    
    NotificationUIManager.instance.setContext(context);
    debugPrint('[NotificationCoordinator] 컨텍스트 업데이트됨');
  }
  
  /// 수동으로 알림 표시 (테스트용)
  Future<void> showTestNotification({
    required String postId,
    required String title,
    required String optionA,
    required String optionB,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationCoordinator가 초기화되지 않음');
    }
    
    await NotificationUIManager.instance.showVotingNotification(
      notificationId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      postTitle: title,
      optionA: optionA,
      optionB: optionB,
      imageUrlsA: [],
      imageUrlsB: [],
      voteEndTime: DateTime.now().add(const Duration(minutes: 10)),
      onVote: (option) {
        debugPrint('[NotificationCoordinator] 테스트 투표: $option');
      },
      onDismiss: () {
        debugPrint('[NotificationCoordinator] 테스트 알림 닫기');
      },
    );
  }
  
  /// 알림 큐 상태 조회
  Map<String, dynamic> getQueueStatus() {
    return {
      'initialized': _isInitialized,
      'queueSize': GlobalNotificationManager.instance.getQueueSize(),
      'isShowingNotification': GlobalNotificationManager.instance.isShowingNotification,
      'hasUIContext': NotificationUIManager.instance.hasContext,
    };
  }
  
  /// 처리된 알림 개수 조회
  int getProcessedCount() {
    return GlobalNotificationManager.instance.getProcessedNotificationCount();
  }
  
  /// 알림 큐 비우기
  void clearQueue() {
    GlobalNotificationManager.instance.clearQueue();
    debugPrint('[NotificationCoordinator] 알림 큐 비움');
  }
}