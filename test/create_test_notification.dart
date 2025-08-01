import 'package:cloud_firestore/cloud_firestore.dart';

/// 테스트용 알림을 수동으로 생성하는 스크립트
/// 
/// 사용법:
/// 1. 이 파일을 Flutter 프로젝트에서 실행
/// 2. createTestNotification() 함수 호출
/// 3. NotificationService가 알림을 감지하는지 확인
Future<void> createTestNotification({
  required String userId,
  required String postId,
}) async {
  try {
    print('[테스트 알림 생성] 시작...');
    
    final now = Timestamp.now();
    final expiryTime = Timestamp.fromDate(
      DateTime.now().add(const Duration(minutes: 15))
    );
    
    final notificationData = {
      // 기본 필드
      'notification_id': 'test_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'type': 'voting_request',
      'source_id': postId,
      
      // 콘텐츠
      'content': {
        'title': '🧪 테스트 알림입니다!',
        'message': '테스트 모드로 생성된 알림입니다',
        'postData': {
          'questionTitle': '테스트 질문입니다',
          'optionA': '옵션 A',
          'optionB': '옵션 B',
          'imageUrlA': null,
          'imageUrlB': null,
          'authorName': '테스트 작성자',
          'category': 'test',
        }
      },
      
      // 메타데이터
      'created_at': now,
      'read': false,
      'target_audience': 'test',
      'expiry_time': expiryTime,
      'interaction_type': 'vote',
      
      // 추가 정보
      'targetReason': '🧪 테스트 알림 - UI/플로우 확인용',
    };
    
    print('[테스트 알림 생성] 데이터 준비 완료');
    print('  - user_id: $userId');
    print('  - source_id: $postId');
    print('  - expiry_time: ${expiryTime.toDate()}');
    
    // Firestore에 저장
    final docRef = await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationData);
    
    print('[테스트 알림 생성] ✅ 성공! 문서 ID: ${docRef.id}');
    print('[테스트 알림 생성] NotificationService가 이 알림을 감지해야 합니다');
    
  } catch (e) {
    print('[테스트 알림 생성] ❌ 오류: $e');
  }
}

/// 여러 개의 테스트 알림 생성
Future<void> createMultipleTestNotifications({
  required String userId,
  required String postId,
  int count = 5,
}) async {
  print('[테스트 알림 생성] $count개의 알림을 생성합니다...');
  
  for (int i = 0; i < count; i++) {
    await createTestNotification(
      userId: userId,
      postId: '$postId${i + 1}',
    );
    
    // 각 알림 사이에 짧은 딜레이
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  print('[테스트 알림 생성] 모든 알림 생성 완료');
}

/// 기존 알림 확인
Future<void> checkExistingNotifications(String userId) async {
  try {
    print('[알림 확인] 기존 알림 조회 중...');
    
    final querySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('type', isEqualTo: 'voting_request')
        .where('read', isEqualTo: false)
        .where('expiry_time', isGreaterThan: Timestamp.now())
        .orderBy('expiry_time', descending: false)
        .orderBy('created_at', descending: true)
        .get();
    
    print('[알림 확인] 조회된 알림 수: ${querySnapshot.docs.length}');
    
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      print('  - ID: ${doc.id}');
      print('    source_id: ${data['source_id']}');
      print('    created_at: ${(data['created_at'] as Timestamp?)?.toDate()}');
      print('    expiry_time: ${(data['expiry_time'] as Timestamp?)?.toDate()}');
      print('    target_audience: ${data['target_audience']}');
    }
    
  } catch (e) {
    print('[알림 확인] ❌ 오류: $e');
  }
}