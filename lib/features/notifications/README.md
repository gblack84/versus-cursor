# 🔔 Notifications Feature

> Feature-First Architecture 기반 알림 시스템 모듈

## 📋 개요

Notifications Feature는 실시간 알림, 푸시 알림, 인앱 알림을 관리합니다.
AI 기반 타겟팅과 실시간 알림 표시 기능을 제공합니다.

## 🏗️ 아키텍처

```
notifications/
├── data/                  # 데이터 레이어
│   ├── datasources/      # FCM, Firestore 알림
│   ├── repositories/     # NotificationRepository 구현
│   └── services/         # 알림 전송, 관리
│
├── domain/               # 도메인 레이어
│   ├── models/          # Notification, NotificationPreference
│   ├── repositories/    # NotificationRepository 인터페이스
│   └── usecases/        # 알림 전송, 읽음 처리
│
└── presentation/         # 프레젠테이션 레이어
    ├── screens/         # 알림 목록 화면
    ├── widgets/         # 알림 카드, 오버레이
    ├── models/          # UI 모델
    ├── constants/       # 알림 타입, 상수
    └── providers/       # NotificationProvider
```

## 🎯 주요 기능

### 알림 타입
- **투표 요청**: AI 타겟팅 기반 투표 요청
- **투표 완료**: 투표 결과 알림
- **채팅 메시지**: 새 메시지 알림
- **시스템 알림**: 공지, 업데이트

### AI 타겟팅 시스템
- **Quick Collection**: AI가 최적 사용자 추천
- **Public**: 랜덤 활성 사용자
- **Custom**: 필터 기반 선택
- **Test Mode**: 개발자 테스트용

### 실시간 알림
- **GlobalNotificationManager**: 전역 알림 관리
- **NotificationOverlay**: 팝업 알림 표시
- **NotificationService**: FCM 통합

## 📦 의존성

### 전역 서비스 사용
- `services/notification_service`: 알림 서비스
- `services/target_audience_service`: 타겟팅
- `backend/firebase`: FCM 설정
- `core/widgets`: 공통 UI 컴포넌트

### Firebase 서비스
```yaml
firebase_messaging: ^14.7.10
flutter_local_notifications: ^16.3.0
```

### Cloud Functions
```javascript
// 알림 관련 Functions
- onPostCreatedSendNotifications: 투표 생성 시 알림
- processVoteCompletion: 투표 완료 알림
```

## 🔄 상태 관리

### NotificationProvider
```dart
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  
  // 알림 목록
  List<NotificationModel> get notifications => _notifications;
  
  // 읽지 않은 알림 수
  int get unreadCount => _unreadCount;
  
  // 알림 추가
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }
  
  // 읽음 처리
  void markAsRead(String notificationId) {
    // 구현
  }
}
```

## 🔀 다른 Feature와의 통신

### Voting Feature 연동
```dart
// 투표 요청 알림 생성
final notification = VoteRequestNotification(
  postId: postId,
  targetUsers: aiSelectedUsers,
);
```

### Chat Feature 연동
```dart
// 새 메시지 알림
eventBus.on<NewMessageEvent>().listen((event) {
  notificationService.showMessageNotification(event);
});
```

## 🎨 UI 컴포넌트

### VotingNotificationDialog
- 투표 카드 표시
- A/B 옵션 미리보기
- 10분 타이머 표시
- 투표 참여 버튼

### NotificationOverlay
- 상단 팝업 표시
- 자동 닫기 (5초)
- 스와이프 제스처

## 📊 알림 분석

### NotificationAnalytics
- 알림 오픈율
- 클릭률 (CTR)
- 타겟팅 효과성
- 사용자 반응 시간

## 📋 API 레퍼런스

### UseCases
- `SendNotificationUseCase`: 알림 전송
- `GetNotificationsUseCase`: 알림 목록 조회
- `MarkAsReadUseCase`: 읽음 처리
- `UpdatePreferencesUseCase`: 알림 설정
- `DeleteNotificationUseCase`: 알림 삭제

### Models
- `NotificationModel`: 알림 정보
- `NotificationPreference`: 알림 설정
- `NotificationPayload`: FCM 페이로드
- `TargetAudience`: 타겟 정보

### Services
- `NotificationService`: 알림 전송/수신
- `TargetAudienceService`: AI 타겟팅
- `GlobalNotificationManager`: 전역 관리

## 🧪 테스트

```bash
# 유닛 테스트
flutter test test/features/notifications/domain/

# 위젯 테스트
flutter test test/features/notifications/presentation/

# FCM 테스트
flutter test test/features/notifications/integration/
```

## 📝 변경 이력

### v1.0.0 (2025-08-27)
- Feature-First Architecture 마이그레이션 완료
- AI 타겟팅 시스템 구현
- GlobalNotificationManager 통합
- 실시간 알림 오버레이 구현