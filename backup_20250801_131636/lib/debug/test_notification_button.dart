import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

/// 테스트용 알림 생성 버튼
/// 
/// 개발 중에만 사용하세요!
class TestNotificationButton extends StatelessWidget {
  const TestNotificationButton({super.key});

  Future<void> _createTestNotification(BuildContext context) async {
    try {
      final user = currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      debugPrint('[TestNotificationButton] 테스트 알림 생성 시작...');
      
      final now = Timestamp.now();
      final expiryTime = Timestamp.fromDate(
        DateTime.now().add(const Duration(minutes: 15))
      );
      
      final notificationData = {
        'notification_id': 'test_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': user.uid,
        'type': 'voting_request',
        'source_id': 'test_post_${DateTime.now().millisecondsSinceEpoch}',
        'content': {
          'title': '🧪 테스트 알림입니다!',
          'message': '테스트 모드로 생성된 알림입니다',
          'postData': {
            'questionTitle': '테스트 질문: 어떤 것을 선택하시겠습니까?',
            'optionA': '테스트 옵션 A',
            'optionB': '테스트 옵션 B',
            'imageUrlA': null,
            'imageUrlB': null,
            'authorName': '테스트 작성자',
            'category': 'test',
          }
        },
        'created_at': now,
        'read': false,
        'target_audience': 'test',
        'expiry_time': expiryTime,
        'interaction_type': 'vote',
        'targetReason': '🧪 테스트 알림 - UI/플로우 확인용',
      };
      
      debugPrint('[TestNotificationButton] Firestore에 저장 중...');
      
      final docRef = await FirebaseFirestore.instance
          .collection('notifications')
          .add(notificationData);
      
      debugPrint('[TestNotificationButton] ✅ 알림 생성 성공! ID: ${docRef.id}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 알림 생성됨! ID: ${docRef.id}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      debugPrint('[TestNotificationButton] ❌ 오류: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _createTestNotification(context),
        icon: const Icon(Icons.science),
        label: const Text('테스트 알림 생성'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}

/// 플로팅 테스트 버튼
class FloatingTestNotificationButton extends StatelessWidget {
  const FloatingTestNotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    // 개발 모드에서만 표시
    if (!const bool.fromEnvironment('dart.vm.product')) {
      return Positioned(
        bottom: 100,
        right: 16,
        child: FloatingActionButton(
          onPressed: () async {
            final button = TestNotificationButton();
            await button._createTestNotification(context);
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.science),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}