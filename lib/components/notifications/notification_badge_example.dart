import 'package:flutter/material.dart';
import '/core/app_utils.dart';
import 'notification_badge.dart';
import 'notification_badge_provider.dart';

/// 알림 뱃지 사용 예제 모음
/// 
/// 다양한 상황에서 알림 뱃지를 사용하는 방법을 보여줍니다.
class NotificationBadgeExamples extends StatelessWidget {
  const NotificationBadgeExamples({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 뱃지 예제'),
        actions: [
          // 예제 1: AppBar에서 사용
          NotificationAppBarAction(
            onPressed: () {
              context.pushNamed('notifications_list');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '알림 뱃지 사용 예제',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // 예제 2: 기본 뱃지
            const Text('기본 뱃지:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            NotificationBadge(
              count: 5,
              child: Icon(Icons.notifications, size: 48),
            ),
            const SizedBox(height: 24),
            
            // 예제 3: 커스텀 색상
            const Text('커스텀 색상:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            NotificationBadge(
              count: 12,
              badgeColor: Colors.green,
              textColor: Colors.white,
              child: Icon(Icons.email, size: 48, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            
            // 예제 4: 큰 숫자 (99+)
            const Text('큰 숫자 표시:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            NotificationBadge(
              count: 150,
              child: Icon(Icons.message, size: 48, color: Colors.purple),
            ),
            const SizedBox(height: 24),
            
            // 예제 5: 실시간 업데이트
            const Text('실시간 업데이트 (NotificationBadgeProvider):', 
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            NotificationBadgeProvider(
              builder: (context, count) {
                return Row(
                  children: [
                    NotificationBadge(
                      count: count,
                      child: Icon(Icons.inbox, size: 48, color: Colors.orange),
                    ),
                    const SizedBox(width: 16),
                    Text('읽지 않은 알림: $count개'),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // 예제 6: 버튼과 함께 사용
            const Text('버튼과 함께:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            NotificationBadgeProvider(
              builder: (context, count) {
                return ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed('notifications_list');
                  },
                  icon: NotificationBadge(
                    count: count,
                    child: Icon(Icons.notifications_active),
                  ),
                  label: const Text('알림 보기'),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // 예제 7: BottomNavigationBar에서 사용
            const Text('BottomNavigationBar에서 사용:', 
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: NotificationBadgeProvider(
                builder: (context, count) {
                  return BottomNavigationBar(
                    items: [
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: '홈',
                      ),
                      BottomNavigationBarItem(
                        icon: NotificationBadge(
                          count: count,
                          child: Icon(Icons.notifications),
                        ),
                        label: '알림',
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: '프로필',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}