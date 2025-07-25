import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/components/notifications/voting_notification_dialog.dart';
import '/components/notifications/models/versus_box_size_data.dart';
import '/components/notifications/constants/voting_notification_constraints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '/core/nav/nav.dart';
import 'notification_service.dart';

/// 글로벌 알림 관리자
/// 
/// 앱 전체에서 알림을 표시하고 관리하는 싱글톤 클래스
class GlobalNotificationManager {
  static final GlobalNotificationManager _instance = GlobalNotificationManager._internal();
  static GlobalNotificationManager get instance => _instance;
  
  GlobalNotificationManager._internal();
  
  /// 알림 큐
  final List<NotificationsRecord> _notificationQueue = [];
  
  /// 현재 표시 중인 알림
  NotificationsRecord? _currentNotification;
  
  /// 알림 표시 중 여부
  bool _isShowingNotification = false;
  
  /// 스트림 구독
  StreamSubscription<List<NotificationsRecord>>? _notificationSubscription;
  
  /// 큐 처리 타이머
  Timer? _queueTimer;
  
  /// NotificationService와 연동 시작
  void startListening() {
    debugPrint('[GlobalNotificationManager] ========== 알림 매니저 시작 ==========');
    
    // NotificationService의 스트림 구독
    _notificationSubscription = NotificationService.instance.notificationsStream.listen(
      (notifications) {
        debugPrint('[GlobalNotificationManager] 새로운 알림 수신: ${notifications.length}개');
        _handleNewNotifications(notifications);
      },
      onError: (error) {
        debugPrint('[GlobalNotificationManager] ❌ 스트림 오류: $error');
      },
    );
    
    // 큐 처리 타이머 시작 (3초마다 체크)
    _queueTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _processQueue();
    });
  }
  
  /// 리스닝 중지
  void stopListening() {
    debugPrint('[GlobalNotificationManager] 알림 매니저 중지');
    _notificationSubscription?.cancel();
    _queueTimer?.cancel();
    _notificationQueue.clear();
    _currentNotification = null;
    _isShowingNotification = false;
  }
  
  /// 새로운 알림 처리
  void _handleNewNotifications(List<NotificationsRecord> notifications) {
    // 기존 큐에 없는 새로운 알림만 추가
    for (final notification in notifications) {
      if (!_notificationQueue.any((n) => n.reference.id == notification.reference.id)) {
        debugPrint('[GlobalNotificationManager] 큐에 알림 추가: ${notification.sourceId}');
        _notificationQueue.add(notification);
      }
    }
    
    // 큐 정렬 (생성 시간 기준)
    _notificationQueue.sort((a, b) => 
      (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now())
    );
    
    debugPrint('[GlobalNotificationManager] 현재 큐 크기: ${_notificationQueue.length}');
    
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
    debugPrint('[GlobalNotificationManager] 알림 표시 시작: ${notification.sourceId}');
    
    _showNotification(notification);
  }
  
  /// 알림 표시
  Future<void> _showNotification(NotificationsRecord notification) async {
    // Navigator context 가져오기
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('[GlobalNotificationManager] ❌ Navigator context를 가져올 수 없음');
      return;
    }
    
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
      String? descriptionA;
      String? descriptionB;
      double? aspectRatioA;
      double? aspectRatioB;
      String? layoutType;
      String? authorName;
      
      // 먼저 content 필드에서 데이터 파싱 시도
      if (notification.content.isNotEmpty) {
        try {
          debugPrint('[GlobalNotificationManager] content 필드 파싱 시도...');
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
              debugPrint('[GlobalNotificationManager] ✅ imageUrlsA 파싱 성공: ${imageUrlsA?.length}개');
              for (int i = 0; i < (imageUrlsA?.length ?? 0); i++) {
                debugPrint('[GlobalNotificationManager]   - imageUrlsA[$i]: ${imageUrlsA![i].substring(0, 50)}...');
              }
            }
            if (postData['imageUrlsB'] is List) {
              imageUrlsB = (postData['imageUrlsB'] as List).cast<String>();
              debugPrint('[GlobalNotificationManager] ✅ imageUrlsB 파싱 성공: ${imageUrlsB?.length}개');
              for (int i = 0; i < (imageUrlsB?.length ?? 0); i++) {
                debugPrint('[GlobalNotificationManager]   - imageUrlsB[$i]: ${imageUrlsB![i].substring(0, 50)}...');
              }
            }
            descriptionA = postData['descriptionA'];
            descriptionB = postData['descriptionB'];
            aspectRatioA = postData['aspectRatioA']?.toDouble();
            aspectRatioB = postData['aspectRatioB']?.toDouble();
            layoutType = postData['layoutType'];
            authorName = postData['authorName'];
            
            debugPrint('[GlobalNotificationManager] ✅ content 필드에서 데이터 파싱 성공');
            debugPrint('[GlobalNotificationManager] 파싱된 데이터:');
            debugPrint('[GlobalNotificationManager]   - question: $question');
            debugPrint('[GlobalNotificationManager]   - optionA: $optionA');
            debugPrint('[GlobalNotificationManager]   - optionB: $optionB');
            debugPrint('[GlobalNotificationManager]   - imageUrlsA: ${imageUrlsA?.length ?? 0}개');
            debugPrint('[GlobalNotificationManager]   - imageUrlsB: ${imageUrlsB?.length ?? 0}개');
            debugPrint('[GlobalNotificationManager]   - descriptionA: $descriptionA');
            debugPrint('[GlobalNotificationManager]   - descriptionB: $descriptionB');
            debugPrint('[GlobalNotificationManager]   - aspectRatioA: $aspectRatioA');
            debugPrint('[GlobalNotificationManager]   - aspectRatioB: $aspectRatioB');
            debugPrint('[GlobalNotificationManager]   - layoutType: $layoutType');
            debugPrint('[GlobalNotificationManager]   - authorName: $authorName');
          }
        } catch (e) {
          debugPrint('[GlobalNotificationManager] content 파싱 실패, 게시물 조회로 전환: $e');
        }
      }
      
      // content 파싱이 실패하거나 데이터가 없으면 게시물 직접 조회
      if (question.isEmpty) {
        debugPrint('[GlobalNotificationManager] 게시물 정보 조회 중...');
        final postDoc = await FirebaseFirestore.instance
            .collection('posts_record')
            .doc(notification.sourceId)
            .get();
        
        if (!postDoc.exists) {
          debugPrint('[GlobalNotificationManager] ❌ 게시물을 찾을 수 없음: ${notification.sourceId}');
          _isShowingNotification = false;
          return;
        }
        
        final postData = postDoc.data() as Map<String, dynamic>;
        
        // 실제 게시물 데이터 사용
        question = postData['questionTitle'] ?? postData['question_title'] ?? '';
        
        // descriptionA와 descriptionB 추출
        descriptionA = postData['descriptionA'] ?? '';
        descriptionB = postData['descriptionB'] ?? '';
        
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
          optionA = postData['option_a'] ?? postData['text_a'] ?? '';
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
          optionB = postData['option_b'] ?? postData['text_b'] ?? '';
        }
      }
      
      debugPrint('[GlobalNotificationManager] 투표 알림 표시');
      debugPrint('  - 질문: $question');
      debugPrint('  - 옵션A: $optionA');
      debugPrint('  - 옵션B: $optionB');
      debugPrint('  - 이미지A: ${imageUrlA != null ? "있음" : "없음"} (멀티: ${imageUrlsA?.length ?? 0}개)');
      debugPrint('  - 이미지B: ${imageUrlB != null ? "있음" : "없음"} (멀티: ${imageUrlsB?.length ?? 0}개)');
      
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
          
          debugPrint('[GlobalNotificationManager] VersusBoxSizeData 생성 성공');
          debugPrint('  - layoutType: ${sizeData.layoutType}');
          debugPrint('  - aspectRatioA: ${sizeData.aspectRatioA}');
          debugPrint('  - aspectRatioB: ${sizeData.aspectRatioB}');
        } catch (e) {
          debugPrint('[GlobalNotificationManager] VersusBoxSizeData 생성 실패: $e');
        }
      }
      
      // SafeArea 계산
      final screenWidth = MediaQuery.of(context).size.width;
      
      // 크기 제약 디버그 출력
      VotingNotificationConstraints.printConstraints(screenWidth);
      
      // 표준 showDialog를 사용하여 알림 표시 (Navigator context 문제 해결)
      debugPrint('[GlobalNotificationManager] VotingNotificationDialog 생성 전 최종 데이터:');
      debugPrint('  - imageUrlsA 전달: ${imageUrlsA?.length ?? 0}개');
      debugPrint('  - imageUrlsB 전달: ${imageUrlsB?.length ?? 0}개');
      
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,  // 검은색 반투명 배경
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,  // 좌우 4%씩 여백 = 92% 사용
              vertical: MediaQuery.of(context).size.height * 0.05  // 상하 5%씩 동적 여백
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
                descriptionA: descriptionA,
                descriptionB: descriptionB,
                sizeData: sizeData,  // 사이즈 데이터 전달
                showDebugInfo: false,  // 디버그 정보 비활성화
                authorName: authorName,  // 작성자 이름 전달
                onVote: (selectedOption) async {
                  debugPrint('[GlobalNotificationManager] 투표 완료: $selectedOption');
                  
                  // 알림을 읽음으로 표시
                  await _markAsRead(notification);
                  
                  // TODO: 실제 투표 로직 구현
                  // await _submitVote(notification.sourceId, selectedOption);
                  
                  _isShowingNotification = false;
                  _currentNotification = null;
                  
                  // 다이얼로그 닫기
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  // 다음 알림 처리
                  _processQueue();
                },
                onDismiss: () {
                  debugPrint('[GlobalNotificationManager] 알림 닫힘');
                  _isShowingNotification = false;
                  _currentNotification = null;
                  
                  // 다이얼로그 닫기
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
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
      debugPrint('[GlobalNotificationManager] ❌ 알림 표시 오류: $e');
      _isShowingNotification = false;
      _currentNotification = null;
    }
  }
  
  /// 알림을 읽음으로 표시
  Future<void> _markAsRead(NotificationsRecord notification) async {
    try {
      await notification.reference.update({
        'read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
      debugPrint('[GlobalNotificationManager] 알림 읽음 처리 완료');
    } catch (e) {
      debugPrint('[GlobalNotificationManager] ❌ 읽음 처리 실패: $e');
    }
  }
  
  /// 현재 큐 상태 반환
  int get queueLength => _notificationQueue.length;
  
  /// 현재 표시 중인지 여부
  bool get isShowingNotification => _isShowingNotification;
}