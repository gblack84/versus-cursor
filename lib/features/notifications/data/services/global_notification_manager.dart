import 'dart:async';
import 'package:flutter/material.dart';
import '/core/types/layout_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Migrated from backend.dart - Direct model import
import '/features/notifications/domain/models/notifications_model.dart';
import '/features/auth/data/services/auth_util.dart';
import '/features/notifications/presentation/widgets/voting_notification_dialog.dart';
import '/features/notifications/presentation/models/versus_box_size_data.dart';
import '/core_exports.dart';
import 'notification_service.dart';
import '/features/posts/data/services/vote/vote_status_service.dart';
import '/features/posts/presentation/utils/debug_helper.dart';

/// 글로벌 알림 관리자
/// 
/// 앱 전체에서 알림을 표시하고 관리하는 싱글톤 클래스
class GlobalNotificationManager {
  static final GlobalNotificationManager _instance = GlobalNotificationManager._internal();
  static GlobalNotificationManager get instance => _instance;
  
  GlobalNotificationManager._internal();
  
  /// 알림 큐
  final List<NotificationsModel> _notificationQueue = [];
  
  /// 현재 표시 중인 알림
  NotificationsModel? _currentNotification;
  
  /// 알림 표시 중 여부
  bool _isShowingNotification = false;
  
  /// 처리된 알림 ID 세트 (중복 표시 방지)
  final Set<String> _processedNotificationIds = {};
  
  /// 스트림 구독
  StreamSubscription<List<NotificationsModel>>? _notificationSubscription;
  
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
  void _handleNewNotifications(List<NotificationsModel> notifications) {
    // 기존 큐에 없고, 이미 처리되지 않은 새로운 알림만 추가
    for (final notification in notifications) {
      final notificationId = notification.reference.id;
      
      // 이미 처리된 알림은 무시
      if (_processedNotificationIds.contains(notificationId)) {
        continue;
      }
      
      // 큐에 없는 경우만 추가
      if (!_notificationQueue.any((n) => n.reference.id == notificationId)) {
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
      (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now())
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
  
  /// 알림 표시
  Future<void> _showNotification(NotificationsModel notification) async {
    // Navigator와 인증 상태가 모두 준비될 때까지 대기
    int attempts = 0;
    BuildContext? context;
    
    while (attempts < 20) {  // 최대 10초 대기
      context = appNavigatorKey.currentContext;
      final user = FirebaseAuth.instance.currentUser;
      
      if (context != null && user != null) {
        // 모든 조건이 충족됨
        break;
      }
      
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    if (context == null) {
      DebugHelper.warning('Context 준비 실패 - 재시도 예약', tag: 'GlobalNotificationManager');
      // 5초 후 재시도
      Future.delayed(const Duration(seconds: 5), () {
        _notificationQueue.add(notification);
      });
      return;
    }
    
    // 알림을 처리 목록에 추가 (중복 표시 방지)
    final notificationId = notification.reference.id;
    _processedNotificationIds.add(notificationId);
    
    // 처리 기록 저장 (비동기로 처리하여 UI 블로킹 방지)
    _saveProcessedNotifications();
    
    _isShowingNotification = true;
    _currentNotification = notification;
    
    try {
      String question = '';
      String optionA = '';
      String optionB = '';
      String? imageUrlA;
      String? imageUrlB;
      List<String>? imageUrlsA;
      List<String>? imageUrlsB;
      String? description;
      double? aspectRatioA;
      double? aspectRatioB;
      String? layoutType;
      String? authorName;
      
      // 먼저 content 필드에서 데이터 파싱 시도
      if (notification.content.isNotEmpty) {
        try {
          final contentData = jsonDecode(notification.content) as Map<String, dynamic>;
          
          if (contentData.containsKey('postData')) {
            final postData = contentData['postData'] as Map<String, dynamic>;
            question = postData['questionTitle'] ?? '';
            optionA = postData['optionA'] ?? '';
            optionB = postData['optionB'] ?? '';
            imageUrlA = postData['imageUrlA'];
            imageUrlB = postData['imageUrlB'];
            // 멀티이미지 지원 추가
            if (postData['imageUrlsA'] is List) {
              imageUrlsA = (postData['imageUrlsA'] as List).cast<String>();
              }
            if (postData['imageUrlsB'] is List) {
              imageUrlsB = (postData['imageUrlsB'] as List).cast<String>();
            }
            description = postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'] ?? '';
            aspectRatioA = postData['aspectRatioA']?.toDouble();
            aspectRatioB = postData['aspectRatioB']?.toDouble();
            layoutType = postData['layoutType'];
            authorName = postData['authorName'];
          }
        } catch (e) {
          // content 파싱 실패 시 posts 조회로 진행
        }
      }
      
      // content 파싱이 실패하거나 데이터가 없으면 게시물 직접 조회
      if (question.isEmpty) {
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(notification.sourceId)
            .get();
        
        if (!postDoc.exists) {
          DebugHelper.warning('게시물을 찾을 수 없음', tag: 'GlobalNotificationManager');
          _isShowingNotification = false;
          return;
        }
        
        final postData = postDoc.data() as Map<String, dynamic>;
        
        // 실제 게시물 데이터 사용
        question = postData['questionTitle'] ?? '';
        
        // description 추출
        description = postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'] ?? '';
        
        // optionA와 optionB는 객체 형태로 저장됨
        if (postData['optionA'] is Map) {
          final optionAData = postData['optionA'] as Map<String, dynamic>;
          optionA = optionAData['title'] ?? '';
          if (optionAData['mediaUrls'] is List && (optionAData['mediaUrls'] as List).isNotEmpty) {
            final mediaList = (optionAData['mediaUrls'] as List).cast<String>();
            imageUrlsA = mediaList;
            imageUrlA = mediaList.first; // 기존 호환성
          }
        } else {
          optionA = postData['optionA'] ?? postData['textA'] ?? '';
        }
        
        if (postData['optionB'] is Map) {
          final optionBData = postData['optionB'] as Map<String, dynamic>;
          optionB = optionBData['title'] ?? '';
          if (optionBData['mediaUrls'] is List && (optionBData['mediaUrls'] as List).isNotEmpty) {
            final mediaList = (optionBData['mediaUrls'] as List).cast<String>();
            imageUrlsB = mediaList;
            imageUrlB = mediaList.first; // 기존 호환성
          }
        } else {
          optionB = postData['optionB'] ?? postData['textB'] ?? '';
        }
        
        // 작성자 이름 추출
        authorName = postData['authorName'] ?? postData['authorDisplayName'] ?? '익명';
      }
      
      DebugHelper.logOnce(
        'notif_show_$notificationId',
        '투표 알림 표시: ${DebugHelper.maskSensitive(notificationId)}',
        tag: 'GlobalNotificationManager',
        level: LogLevel.INFO
      );
      
      // VersusBoxSizeData 생성 (비율 정보가 있는 경우)
      VersusBoxSizeData? sizeData;
      if (aspectRatioA != null || aspectRatioB != null) {
        try {
          // 레이아웃 타입 파싱
          LayoutType parsedLayoutType = LayoutType.horizontal;
          if (layoutType != null) {
            parsedLayoutType = LayoutType.values.firstWhere(
              (e) => e.name == layoutType,
              orElse: () => LayoutType.horizontal,
            );
          }
          
          // 기본 박스 크기 (화면 크기에 따라 동적으로 설정) - 더 크게 설정
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;
          final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);
          
          sizeData = VersusBoxSizeData(
            layoutType: parsedLayoutType,
            aspectRatioA: aspectRatioA,
            aspectRatioB: aspectRatioB,
            originalSizeA: baseSize,
            originalSizeB: baseSize,
            screenWidth: MediaQuery.of(context).size.width,
            createdAt: DateTime.now(),
            hasImageA: imageUrlA != null,
            hasImageB: imageUrlB != null,
          );
        } catch (e) {
          DebugHelper.warning('VersusBoxSizeData 생성 실패', tag: 'GlobalNotificationManager');
        }
      }
      
      // 표준 showDialog를 사용하여 알림 표시 (Navigator context 문제 해결)
      
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,  // 검은색 반투명 배경
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(dialogContext).size.width * 0.04,  // 좌우 4%씩 여백 = 92% 사용
              vertical: MediaQuery.of(dialogContext).size.height * 0.05  // 상하 5%씩 동적 여백
            ),
            alignment: Alignment.topCenter,
            child: VotingNotificationDialog(
                question: question,
                optionA: optionA,
                optionB: optionB,
                imageUrlA: imageUrlA,
                imageUrlB: imageUrlB,
                imageUrlsA: imageUrlsA, // 멀티이미지 지원
                imageUrlsB: imageUrlsB, // 멀티이미지 지원
                description: description,
                sizeData: sizeData,  // 사이즈 데이터 전달
                showDebugInfo: false,  // 디버그 정보 비활성화
                authorName: authorName,  // 작성자 이름 전달
                onVote: (selectedOption) async {
                  DebugHelper.info('투표 완료: $selectedOption', tag: 'GlobalNotificationManager');
                  
                  // 상태 즉시 업데이트 (권한 오류와 관계없이)
                  _isShowingNotification = false;
                  _currentNotification = null;
                  
                  // 다이얼로그 먼저 닫기
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  // 비동기로 알림을 읽음으로 표시 시도
                  _markAsRead(notification).then((_) {
                  }).catchError((error) {
                  });
                  
                  // 실제 투표 로직 구현
                  await _submitVote(notification.sourceId, selectedOption);
                  
                  // 다음 알림 처리 (약간의 지연 후)
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _processQueue();
                  });
                },
                onDismiss: (hasVoted) {
                  _isShowingNotification = false;
                  _currentNotification = null;
                  
                  // 다이얼로그 닫기
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  // 닫힌 알림도 처리된 것으로 표시
                  _markAsRead(notification).catchError((error) {
                  });
                  
                  // 다음 알림 처리
                  Future.delayed(const Duration(milliseconds: 500), () {
                    _processQueue();
                  });
                },
              ),
            );
        },
      );
    } catch (e) {
      DebugHelper.error('알림 표시 오류', error: e, tag: 'GlobalNotificationManager');
      _isShowingNotification = false;
      _currentNotification = null;
    }
  }
  
  /// 알림을 읽음으로 표시
  Future<void> _markAsRead(NotificationsModel notification) async {
    try {
      await notification.reference.update({
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
  NotificationsModel? get currentNotification => _currentNotification;
  
  /// 디버그 정보 반환
  Map<String, dynamic> getDebugInfo() {
    return {
      'isShowingNotification': _isShowingNotification,
      'queueLength': _notificationQueue.length,
      'processedCount': _processedNotificationIds.length,
      'currentNotificationId': _currentNotification?.reference.id,
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