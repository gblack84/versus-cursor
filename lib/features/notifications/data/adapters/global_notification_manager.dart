import 'dart:async';
// Domain imports only
import '../../domain/models/notification.dart' as domain;
import '../../domain/models/vote_notification.dart' as domain;
import '../../domain/handlers/i_notification_handler.dart';
// Data layer imports
import '../datasources/i_remote_notification_datasource.dart';
import '../datasources/i_local_notification_datasource.dart';
import 'notification_data_extractor.dart';
import '../../domain/services/i_notification_service.dart';
// Domain service interfaces (no cross-feature dependencies)
import '/core/domain/ports/i_user_service.dart';
import '/core/interfaces/features/i_vote_service.dart';
import '/core/utils/logger.dart';

/// 글로벌 알림 관리자 - 비즈니스 로직 전용
///
/// Clean Architecture에 따라 UI 로직은 INotificationHandler를 통해 위임하고
/// 알림 큐 관리, 데이터 처리, 비즈니스 로직만 담당합니다.
class GlobalNotificationManager {
  final INotificationHandler _notificationHandler;
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  final INotificationService _notificationService;
  final IUserService _userService;
  final IVoteService _voteService;

  GlobalNotificationManager({
    required INotificationHandler notificationHandler,
    required IRemoteNotificationDatasource remoteDatasource,
    required ILocalNotificationDatasource localDatasource,
    required INotificationService notificationService,
    required IUserService userService,
    required IVoteService voteService,
  })  : _notificationHandler = notificationHandler,
        _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _notificationService = notificationService,
        _userService = userService,
        _voteService = voteService;

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

  /// NotificationService와 연동 시작
  void startListening() async {
    Logger.info('알림 매니저 시작', tag: 'GlobalNotificationManager');

    // 저장된 처리 기록 로드
    await _loadProcessedNotifications();

    // NotificationService의 스트림 구독
    _notificationSubscription = _notificationService.notificationsStream.listen(
      (notifications) {
        Logger.debug('새 알림 수신: ${notifications.length}개',
            tag: 'GlobalNotificationManager');
        _handleNewNotifications(notifications);
      },
      onError: (error) {
        Logger.error('스트림 오류', error: error, tag: 'GlobalNotificationManager');
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
    Logger.info('알림 매니저 중지', tag: 'GlobalNotificationManager');

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
        Logger.logOnce(
            'notif_queued_$notificationId', '알림 큐에 추가: $notificationId',
            tag: 'GlobalNotificationManager');
      }
    }

    // 큐 정렬 (생성 시간 기준)
    _notificationQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    Logger.debug(
        '큐 크기: ${_notificationQueue.length}, 처리된: ${_processedNotificationIds.length}',
        tag: 'GlobalNotificationManager');

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

  /// 알림 표시 - UI 핸들러를 통해 처리
  Future<void> _showNotification(domain.Notification notification) async {
    // UI 컨텍스트 준비 대기
    final context = await _notificationHandler.waitForUIContext();

    if (context == null) {
      Logger.warning('UI 컨텍스트 준비 실패 - 재시도 예약',
          tag: 'GlobalNotificationManager');
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
      final displayData =
          await NotificationDataExtractor.extractVoteData(notification);

      if (displayData == null) {
        Logger.warning('알림 데이터 추출 실패', tag: 'GlobalNotificationManager');
        _isShowingNotification = false;
        return;
      }

      // Size data creation (optional) - sizeData는 현재 사용되지 않음
      // TODO: sizeData를 showVotingNotification에 전달하거나 제거 필요
      _notificationHandler.createSizeDataFromAspectRatios(
        context: context,
        aspectRatioA: displayData.aspectRatioA,
        aspectRatioB: displayData.aspectRatioB,
        layoutType: displayData.layoutType,
        hasImageA: displayData.hasImageA,
        hasImageB: displayData.hasImageB,
      );

      // UI 핸들러를 통해 알림 표시
      await _notificationHandler.showVotingNotification(
        notification: notification,
        context: context,
        displayData: displayData,
        onVote: (selectedOption) async {
          Logger.info('투표 완료: $selectedOption',
              tag: 'GlobalNotificationManager');

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
            Logger.warning('알림 읽음 처리 실패', tag: 'GlobalNotificationManager');
          });

          // 다음 알림 처리
          Future.delayed(const Duration(milliseconds: 500), () {
            _processQueue();
          });
        },
      );
    } catch (e) {
      Logger.error('알림 표시 오류', error: e, tag: 'GlobalNotificationManager');
      _isShowingNotification = false;
      _currentNotification = null;
    }
  }

  /// 알림을 읽음으로 표시
  Future<void> _markAsRead(domain.Notification notification) async {
    try {
      await _remoteDatasource.markAsRead(notification.id);
    } catch (e) {
      Logger.warning('읽음 처리 실패', tag: 'GlobalNotificationManager');
    }
  }

  /// 오래된 처리 기록 정리
  void _cleanupProcessedNotifications() {
    final beforeCount = _processedNotificationIds.length;

    // 메모리 사용을 줄이기 위해 최대 1000개까지만 유지
    if (_processedNotificationIds.length > 1000) {
      // 가장 오래된 항목들을 제거 (Set은 순서가 없으므로 모두 제거 후 최근 500개만 다시 추가)
      final recentIds = _processedNotificationIds
          .toList()
          .sublist(_processedNotificationIds.length - 500);
      _processedNotificationIds.clear();
      _processedNotificationIds.addAll(recentIds);

      Logger.debug(
          '처리 기록 정리: $beforeCount -> ${_processedNotificationIds.length}',
          tag: 'GlobalNotificationManager');

      // 정리 후 저장
      _saveProcessedNotifications();
    }
  }

  /// 처리된 알림 ID 로드
  Future<void> _loadProcessedNotifications() async {
    try {
      final savedIds = await _localDatasource.getProcessedNotificationIds();
      _processedNotificationIds.addAll(savedIds);
    } catch (e) {
      Logger.warning('처리 기록 로드 실패', tag: 'GlobalNotificationManager');
    }
  }

  /// 처리된 알림 ID 저장
  Future<void> _saveProcessedNotifications() async {
    try {
      await _localDatasource
          .saveProcessedNotificationIds(_processedNotificationIds);
    } catch (e) {
      Logger.warning('처리 기록 저장 실패', tag: 'GlobalNotificationManager');
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

  /// 큐 크기 반환
  int getQueueSize() => _notificationQueue.length;

  /// 처리된 알림 개수 반환
  int getProcessedNotificationCount() => _processedNotificationIds.length;

  /// 큐 비우기 (테스트용)
  void clearQueue() {
    _notificationQueue.clear();
    _currentNotification = null;
    _isShowingNotification = false;
    Logger.info('알림 큐 비움', tag: 'GlobalNotificationManager');
  }

  /// 실제 투표 처리 - IVoteService 사용
  Future<void> _submitVote(String postId, String selectedOption) async {
    try {
      // IVoteService.submitVote 호출
      await _voteService.submitVote(
        postId: postId,
        userId: _userService.currentUserId,
        choice: selectedOption,
        messageId: null, // 알림에서는 메시지 ID가 없음
        chatId: null, // 알림에서는 채팅 ID가 없음
        onError: (error) {
          Logger.warning('투표 처리 실패: $error', tag: 'GlobalNotificationManager');
        },
      );

      Logger.info('투표 처리 완료: postId=$postId, option=$selectedOption',
          tag: 'GlobalNotificationManager');
    } catch (e) {
      Logger.error('투표 저장 실패', error: e, tag: 'GlobalNotificationManager');
      // 에러는 무시하고 계속 진행 (UX 우선)
    }
  }
}
