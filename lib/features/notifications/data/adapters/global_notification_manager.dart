import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Business logic imports only
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/notifications/domain/models/vote_notification.dart' as domain;
import '/features/notifications/presentation/managers/i_notification_ui_delegate.dart';
import '/features/notifications/presentation/managers/notification_ui_manager.dart';
import '/features/notifications/presentation/models/versus_box_size_data.dart';
import '/features/auth/data/adapters/auth_util.dart';
import 'notification_service.dart';
import '/features/posts/data/adapters/vote/vote_status_service.dart';
import '/features/posts/presentation/utils/debug_helper.dart';

/// 글로벌 알림 관리자 - 비즈니스 로직 전용
/// 
/// Clean Architecture에 따라 UI 로직은 NotificationUIManager에 위임하고
/// 알림 큐 관리, 데이터 처리, 비즈니스 로직만 담당합니다.
class GlobalNotificationManager {
  static final GlobalNotificationManager _instance = GlobalNotificationManager._internal();
  static GlobalNotificationManager get instance => _instance;
  
  GlobalNotificationManager._internal() {
    // UI 대리자 주입 (기본값으로 NotificationUIManager 사용)
    _uiDelegate = NotificationUIManager.instance;
  }
  
  /// UI 대리자 (의존성 주입 가능)
  late INotificationUIDelegate _uiDelegate;
  
  /// UI 대리자 설정 (테스트나 커스텀 UI를 위한 의존성 주입)
  void setUIDelegate(INotificationUIDelegate delegate) {
    _uiDelegate = delegate;
  }
  
  /// 알림 큐
  final List<domain.Notification> _notificationQueue = [];
  
  /// 현재 표시 중인 알림
  domain.Notification? _currentNotification;
  
  /// 알림 표시 중 여부
  bool _isShowingNotification = false;
  
  /// 처리된 알림 ID 세트 (중복 표시 방지)
  final Set<String> _processedNotificationIds = {};
  
  /// 스트림 구독
  StreamSubscription<List<domain.Notification>>? _notificationSubscription;
  
  /// 큐 처리 타이머
  Timer? _queueTimer;
  
  /// 정리 타이머
  Timer? _cleanupTimer;
  
  /// SharedPreferences 키
  static const String _processedIdsKey = 'processed_notification_ids';
  
  /// NotificationService와 연동 시작
  void startListening() async {
    DebugHelper.info('알림 매니저 시작', tag: 'GlobalNotificationManager');
    
    // 저장된 처리 기록 로드
    await _loadProcessedNotifications();
    
    // NotificationService의 스트림 구독
    _notificationSubscription = NotificationService.instance.notificationsStream.listen(
      (notifications) {
        DebugHelper.debug('새 알림 수신: ${notifications.length}개', tag: 'GlobalNotificationManager');
        _handleNewNotifications(notifications);
      },
      onError: (error) {
        DebugHelper.error('스트림 오류', error: error, tag: 'GlobalNotificationManager');
      },
    );
    
    // 큐 처리 타이머 시작 (3초마다 체크)
    _queueTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _processQueue();
    });
    
    // 정리 타이머 시작 (30분마다 오래된 기록 정리)
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupProcessedNotifications();
    });
  }
  
  /// 리스닝 중지
  void stopListening() {
    DebugHelper.info('알림 매니저 중지', tag: 'GlobalNotificationManager');
    
    // 처리 기록 저장
    _saveProcessedNotifications();
    
    _notificationSubscription?.cancel();
    _queueTimer?.cancel();
    _cleanupTimer?.cancel();
    _notificationQueue.clear();
    _currentNotification = null;
    _isShowingNotification = false;
    // 세션 종료 시 처리 기록은 유지 (다음 세션에서 사용하기 위해)
    // _processedNotificationIds.clear();
  }
  
  /// 새로운 알림 처리
  void _handleNewNotifications(List<domain.Notification> notifications) {
    // 기존 큐에 없고, 이미 처리되지 않은 새로운 알림만 추가
    for (final notification in notifications) {
      final notificationId = notification.id;
      
      // 이미 처리된 알림은 무시
      if (_processedNotificationIds.contains(notificationId)) {
        continue;
      }
      
      // 큐에 없는 경우만 추가
      if (!_notificationQueue.any((n) => n.id == notificationId)) {
        _notificationQueue.add(notification);
        DebugHelper.logOnce(
          'notif_queued_$notificationId',
          '알림 큐에 추가: ${DebugHelper.maskSensitive(notificationId)}',
          tag: 'GlobalNotificationManager',
          level: LogLevel.DEBUG
        );
      }
    }
    
    // 큐 정렬 (생성 시간 기준)
    _notificationQueue.sort((a, b) => 
      a.createdAt.compareTo(b.createdAt)
    );
    
    DebugHelper.debug('큐 크기: ${_notificationQueue.length}, 처리된: ${_processedNotificationIds.length}', tag: 'GlobalNotificationManager');
    
    // 즉시 처리 시도
    _processQueue();
  }
  
  /// 큐 처리
  void _processQueue() {
    // 이미 표시 중이면 대기
    if (_isShowingNotification) {
      return;
    }
    
    // 큐가 비어있으면 종료
    if (_notificationQueue.isEmpty) {
      return;
    }
    
    // 다음 알림 가져오기
    final notification = _notificationQueue.removeAt(0);
    _showNotification(notification);
  }
  
  /// 알림 표시 - UI 대리자를 통해 처리
  Future<void> _showNotification(domain.Notification notification) async {
    // UI 컨텍스트 준비 대기
    final context = await _uiDelegate.waitForUIContext();
    
    if (context == null) {
      DebugHelper.warning('UI 컨텍스트 준비 실패 - 재시도 예약', tag: 'GlobalNotificationManager');
      // 5초 후 재시도
      Future.delayed(const Duration(seconds: 5), () {
        _notificationQueue.add(notification);
      });
      return;
    }
    
    // 알림을 처리 목록에 추가 (중복 표시 방지)
    final notificationId = notification.id;
    _processedNotificationIds.add(notificationId);
    
    // 처리 기록 저장 (비동기로 처리하여 UI 블로킹 방지)
    _saveProcessedNotifications();
    
    _isShowingNotification = true;
    _currentNotification = notification;
    
    try {
      // 데이터 추출은 NotificationDataExtractor를 사용
      final voteData = await NotificationDataExtractor.extractVoteData(notification);
      
      if (voteData.isEmpty) {
        DebugHelper.warning('알림 데이터 추출 실패', tag: 'GlobalNotificationManager');
        _isShowingNotification = false;
        return;
      }
      
      // UI 대리자에 NotificationUIManager가 있으면 sizeData 생성
      VersusBoxSizeData? sizeData;
      if (_uiDelegate is NotificationUIManager) {
        final uiManager = _uiDelegate as NotificationUIManager;
        sizeData = uiManager.createSizeDataFromAspectRatios(
          context: context,
          aspectRatioA: voteData.aspectRatioA,
          aspectRatioB: voteData.aspectRatioB,
          layoutType: voteData.layoutType,
          hasImageA: voteData.imageUrlA != null,
          hasImageB: voteData.imageUrlB != null,
        );
      }
      
      // UI 대리자를 통해 알림 표시
      await _uiDelegate.showVotingNotification(
        notification: notification,
        context: context,
        question: voteData.question,
        optionA: voteData.optionA,
        optionB: voteData.optionB,
        imageUrlA: voteData.imageUrlA,
        imageUrlB: voteData.imageUrlB,
        imageUrlsA: voteData.imageUrlsA,
        imageUrlsB: voteData.imageUrlsB,
        description: voteData.description,
        authorName: voteData.authorName,
        sizeData: sizeData,
        onVote: (selectedOption) async {
          DebugHelper.info('투표 완료: $selectedOption', tag: 'GlobalNotificationManager');
          
          // 상태 즉시 업데이트
          _isShowingNotification = false;
          _currentNotification = null;
          
          // 알림을 읽음으로 표시
          await _markAsRead(notification);
          
          // 실제 투표 로직 처리
          if (notification is domain.VoteNotification) {
            await _submitVote(notification.postId, selectedOption);
          }
          
          // 다음 알림 처리
          Future.delayed(const Duration(milliseconds: 300), () {
            _processQueue();
          });
        },
        onDismiss: (hasVoted) {
          _isShowingNotification = false;
          _currentNotification = null;
          
          // 닫힌 알림도 처리된 것으로 표시
          _markAsRead(notification).catchError((error) {
            DebugHelper.warning('알림 읽음 처리 실패', tag: 'GlobalNotificationManager');
          });
          
          // 다음 알림 처리
          Future.delayed(const Duration(milliseconds: 500), () {
            _processQueue();
          });
        },
      );
    } catch (e) {
      DebugHelper.error('알림 표시 오류', error: e, tag: 'GlobalNotificationManager');
      _isShowingNotification = false;
      _currentNotification = null;
    }
  }
  
  /// 알림을 읽음으로 표시
  Future<void> _markAsRead(domain.Notification notification) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notification.id)
          .update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      DebugHelper.warning('읽음 처리 실패', tag: 'GlobalNotificationManager');
    }
  }
  
  /// 오래된 처리 기록 정리
  void _cleanupProcessedNotifications() {
    final beforeCount = _processedNotificationIds.length;
    
    // 메모리 사용을 줄이기 위해 최대 1000개까지만 유지
    if (_processedNotificationIds.length > 1000) {
      // 가장 오래된 항목들을 제거 (Set은 순서가 없으므로 모두 제거 후 최근 500개만 다시 추가)
      final recentIds = _processedNotificationIds.toList().sublist(
        _processedNotificationIds.length - 500
      );
      _processedNotificationIds.clear();
      _processedNotificationIds.addAll(recentIds);
      
      DebugHelper.debug('처리 기록 정리: $beforeCount -> ${_processedNotificationIds.length}', tag: 'GlobalNotificationManager');
      
      // 정리 후 저장
      _saveProcessedNotifications();
    }
  }
  
  /// 처리된 알림 ID 로드
  Future<void> _loadProcessedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList(_processedIdsKey) ?? [];
      _processedNotificationIds.addAll(savedIds);
    } catch (e) {
      DebugHelper.warning('처리 기록 로드 실패', tag: 'GlobalNotificationManager');
    }
  }
  
  /// 처리된 알림 ID 저장
  Future<void> _saveProcessedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_processedIdsKey, _processedNotificationIds.toList());
    } catch (e) {
      DebugHelper.warning('처리 기록 저장 실패', tag: 'GlobalNotificationManager');
    }
  }
  
  /// 현재 큐 상태 반환
  int get queueLength => _notificationQueue.length;
  
  /// 현재 표시 중인지 여부
  bool get isShowingNotification => _isShowingNotification;
  
  /// 현재 표시 중인 알림 반환
  domain.Notification? get currentNotification => _currentNotification;
  
  /// 디버그 정보 반환
  Map<String, dynamic> getDebugInfo() {
    return {
      'isShowingNotification': _isShowingNotification,
      'queueLength': _notificationQueue.length,
      'processedCount': _processedNotificationIds.length,
      'currentNotificationId': _currentNotification?.id,
      'currentNotificationType': _currentNotification?.type,
    };
  }
  
  /// 실제 투표 처리 - VoteStatusService 사용
  Future<void> _submitVote(String postId, String selectedOption) async {
    try {
      // VoteStatusService.submitVote 호출
      await VoteStatusService.submitVote(
        postId: postId,
        userId: currentUserUid,
        choice: selectedOption,
        messageId: null,  // 알림에서는 메시지 ID가 없음
        chatId: null,     // 알림에서는 채팅 ID가 없음
        onError: (error) {
          DebugHelper.warning('투표 처리 실패: $error', tag: 'GlobalNotificationManager');
        },
      );
      
      DebugHelper.info('투표 처리 완료: postId=$postId, option=$selectedOption', tag: 'GlobalNotificationManager');
    } catch (e) {
      DebugHelper.error('투표 저장 실패', error: e, tag: 'GlobalNotificationManager');
      // 에러는 무시하고 계속 진행 (UX 우선)
    }
  }
}