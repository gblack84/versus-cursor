import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
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
    debugPrint('[GlobalNotificationManager] ========== 알림 매니저 시작 ==========');
    
    // 저장된 처리 기록 로드
    await _loadProcessedNotifications();
    
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
    
    // 정리 타이머 시작 (30분마다 오래된 기록 정리)
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      _cleanupProcessedNotifications();
    });
  }
  
  /// 리스닝 중지
  void stopListening() {
    debugPrint('[GlobalNotificationManager] 알림 매니저 중지');
    
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
        debugPrint('[GlobalNotificationManager] 이미 처리된 알림 무시: $notificationId');
        continue;
      }
      
      // 큐에 없는 경우만 추가
      if (!_notificationQueue.any((n) => n.reference.id == notificationId)) {
        debugPrint('[GlobalNotificationManager] 큐에 알림 추가: ${notification.sourceId}');
        _notificationQueue.add(notification);
      }
    }
    
    // 큐 정렬 (생성 시간 기준)
    _notificationQueue.sort((a, b) => 
      (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now())
    );
    
    debugPrint('[GlobalNotificationManager] 현재 큐 크기: ${_notificationQueue.length}');
    debugPrint('[GlobalNotificationManager] 처리된 알림 수: ${_processedNotificationIds.length}');
    
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
      debugPrint('[GlobalNotificationManager] Context 준비 실패, 알림 재시도 예약');
      // 5초 후 재시도
      Future.delayed(const Duration(seconds: 5), () {
        _notificationQueue.add(notification);
      });
      return;
    }
    
    // 알림을 처리 목록에 추가 (중복 표시 방지)
    final notificationId = notification.reference.id;
    _processedNotificationIds.add(notificationId);
    debugPrint('[GlobalNotificationManager] 알림을 처리 목록에 추가: $notificationId');
    
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
              debugPrint('[GlobalNotificationManager] ✅ imageUrlsA 파싱 성공: ${imageUrlsA.length}개');
              for (int i = 0; i < imageUrlsA.length; i++) {
                debugPrint('[GlobalNotificationManager]   - imageUrlsA[$i]: ${imageUrlsA[i].substring(0, 50)}...');
              }
            }
            if (postData['imageUrlsB'] is List) {
              imageUrlsB = (postData['imageUrlsB'] as List).cast<String>();
              debugPrint('[GlobalNotificationManager] ✅ imageUrlsB 파싱 성공: ${imageUrlsB.length}개');
              for (int i = 0; i < imageUrlsB.length; i++) {
                debugPrint('[GlobalNotificationManager]   - imageUrlsB[$i]: ${imageUrlsB[i].substring(0, 50)}...');
              }
            }
            description = postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'] ?? '';
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
            debugPrint('[GlobalNotificationManager]   - description: $description');
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
            .collection('posts')
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
          debugPrint('[GlobalNotificationManager] optionA Map 파싱 - title: $optionA, mediaUrls: ${imageUrlsA?.length ?? 0}개');
        } else {
          optionA = postData['option_a'] ?? postData['text_a'] ?? '';
          debugPrint('[GlobalNotificationManager] optionA 문자열 파싱: $optionA');
        }
        
        if (postData['optionB'] is Map) {
          final optionBData = postData['optionB'] as Map<String, dynamic>;
          optionB = optionBData['title'] ?? '';
          if (optionBData['mediaUrls'] is List && (optionBData['mediaUrls'] as List).isNotEmpty) {
            final mediaList = (optionBData['mediaUrls'] as List).cast<String>();
            imageUrlsB = mediaList;
            imageUrlB = mediaList.first; // 기존 호환성
          }
          debugPrint('[GlobalNotificationManager] optionB Map 파싱 - title: $optionB, mediaUrls: ${imageUrlsB?.length ?? 0}개');
        } else {
          optionB = postData['option_b'] ?? postData['text_b'] ?? '';
          debugPrint('[GlobalNotificationManager] optionB 문자열 파싱: $optionB');
        }
        
        // 작성자 이름 추출
        authorName = postData['authorName'] ?? postData['author_name'] ?? postData['author_display_name'] ?? '익명';
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
                  debugPrint('[GlobalNotificationManager] 투표 완료: $selectedOption');
                  
                  // 상태 즉시 업데이트 (권한 오류와 관계없이)
                  _isShowingNotification = false;
                  _currentNotification = null;
                  
                  // 다이얼로그 먼저 닫기
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  // 비동기로 알림을 읽음으로 표시 시도
                  _markAsRead(notification).then((_) {
                    debugPrint('[GlobalNotificationManager] 알림 읽음 처리 성공');
                  }).catchError((error) {
                    debugPrint('[GlobalNotificationManager] 알림 읽음 처리 실패 (무시): $error');
                  });
                  
                  // 실제 투표 로직 구현
                  await _submitVote(notification.sourceId, selectedOption);
                  
                  // 다음 알림 처리 (약간의 지연 후)
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _processQueue();
                  });
                },
                onDismiss: () {
                  debugPrint('[GlobalNotificationManager] 알림 닫힘');
                  _isShowingNotification = false;
                  _currentNotification = null;
                  
                  // 다이얼로그 닫기
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  // 닫힌 알림도 처리된 것으로 표시
                  _markAsRead(notification).catchError((error) {
                    debugPrint('[GlobalNotificationManager] 알림 읽음 처리 실패 (무시): $error');
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
      debugPrint('[GlobalNotificationManager] ❌ 알림 표시 오류: $e');
      _isShowingNotification = false;
      _currentNotification = null;
    }
  }
  
  /// 알림을 읽음으로 표시
  Future<void> _markAsRead(NotificationsModel notification) async {
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
      
      debugPrint('[GlobalNotificationManager] 처리 기록 정리 완료: $beforeCount -> ${_processedNotificationIds.length}');
      
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
      debugPrint('[GlobalNotificationManager] 저장된 처리 기록 로드: ${savedIds.length}개');
    } catch (e) {
      debugPrint('[GlobalNotificationManager] 처리 기록 로드 실패: $e');
    }
  }
  
  /// 처리된 알림 ID 저장
  Future<void> _saveProcessedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_processedIdsKey, _processedNotificationIds.toList());
      debugPrint('[GlobalNotificationManager] 처리 기록 저장 완료: ${_processedNotificationIds.length}개');
    } catch (e) {
      debugPrint('[GlobalNotificationManager] 처리 기록 저장 실패: $e');
    }
  }
  
  /// 현재 큐 상태 반환
  int get queueLength => _notificationQueue.length;
  
  /// 현재 표시 중인지 여부
  bool get isShowingNotification => _isShowingNotification;
  
  /// 실제 투표 처리
  /// 
  /// 클라이언트에서 직접 처리합니다.
  Future<void> _submitVote(String postId, String selectedOption) async {
    try {
      // currentUserReference 사용 (채팅에서 투표할 때와 동일)
      if (currentUserReference == null) {
        debugPrint('[GlobalNotificationManager] currentUserReference가 null');
        return;
      }
      
      // 사용자 문서 존재 확인
      final userDoc = await currentUserReference!.get();
      if (!userDoc.exists) {
        debugPrint('[GlobalNotificationManager] 사용자 문서가 존재하지 않음: ${currentUserReference!.path}');
        return;
      }
      
      debugPrint('[GlobalNotificationManager] 투표 시도');
      debugPrint('  - userId: ${currentUserUid}');
      debugPrint('  - userRef: ${currentUserReference!.path}');
      debugPrint('  - postId: $postId');
      debugPrint('  - option: $selectedOption');
      
      // 모든 작업을 하나의 트랜잭션으로 처리
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postRef = FirebaseFirestore.instance
            .collection('posts')
            .doc(postId);
        
        // 1. posts 문서 읽기
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }
        
        final currentData = postDoc.data() as Map<String, dynamic>;
        final voteCountField = selectedOption == 'A' ? 'vote_count_a' : 'vote_count_b';
        final votedUsersField = selectedOption == 'A' ? 'votedUserIDsA' : 'votedUserIDsB';
        final currentCount = (currentData[voteCountField] ?? 0) as int;
        final currentVotedUsersA = List<String>.from(currentData['votedUserIDsA'] ?? []);
        final currentVotedUsersB = List<String>.from(currentData['votedUserIDsB'] ?? []);
        
        // 2. 중복 투표 확인 (양쪽 모두 확인)
        if (currentVotedUsersA.contains(currentUserUid) || currentVotedUsersB.contains(currentUserUid)) {
          debugPrint('[GlobalNotificationManager] 이미 투표한 사용자입니다');
          throw Exception('이미 투표한 사용자입니다');
        }
        
        // 3. votes 서브컬렉션에 투표 문서 생성
        final voteRef = postRef.collection('votes').doc();
        final voteData = {
          'user': currentUserReference,  // currentUserReference 사용
          'option': selectedOption,
          'created_at': FieldValue.serverTimestamp(),
          'from_chat': false,  // 알림 기반 투표는 채팅이 아님
        };
        
        debugPrint('[GlobalNotificationManager] 📤 트랜잭션 내에서 투표 데이터 생성:');
        debugPrint('  - user (DocumentReference): ${currentUserReference!.path}');
        debugPrint('  - option: $selectedOption');
        debugPrint('  - voteRef: ${voteRef.path}');
        
        transaction.set(voteRef, voteData);
        
        // 4. posts 문서 업데이트
        final currentVotedUsers = selectedOption == 'A' ? currentVotedUsersA : currentVotedUsersB;
        currentVotedUsers.add(currentUserUid);
        
        final updateData = {
          voteCountField: currentCount + 1,
          votedUsersField: currentVotedUsers,
          'total_votes': (currentData['total_votes'] ?? 0) + 1,
          'last_vote_at': FieldValue.serverTimestamp(),
        };
        
        debugPrint('[GlobalNotificationManager] 📊 posts 문서 업데이트:');
        debugPrint('  - $voteCountField: ${currentCount + 1}');
        debugPrint('  - $votedUsersField에 사용자 추가');
        
        transaction.update(postRef, updateData);
      });
      
      debugPrint('[GlobalNotificationManager] ✅ 투표 저장 완료: $selectedOption (게시물: $postId)');
    } catch (e) {
      debugPrint('[GlobalNotificationManager] ❌ 투표 저장 실패: $e');
      // 에러는 무시하고 계속 진행 (UX 우선)
    }
  }
}