# Notifications Feature - Presentation Layer

> **Version:** 2.0.0
> **Last Updated:** 2025-01-20
> **Architecture:** Clean Architecture v4.0 (Feature-First + Layered)

## 📋 개요

Notifications Feature의 Presentation Layer는 **사용자 인터페이스와 사용자 상호작용**을 담당하며, Clean Architecture의 가장 바깥 계층입니다.

### 핵심 원칙

```yaml
단방향 데이터 플로우: Domain → Presentation (UseCase를 통해서만)
프레임워크 의존성 허용: Flutter, Provider 사용 가능
비즈니스 로직 배제: UI 로직만 포함, 비즈니스 규칙은 Domain에
반응형 프로그래밍: StreamBuilder를 통한 실시간 UI 업데이트
```

### 핵심 기능

1. **실시간 알림 표시**
   - `NotificationOverlayProvider`: NotificationQueueService 스트림 구독
   - 타입별 다이얼로그 라우팅 (Voting, Social, System)
   - Port-Adapter 패턴으로 Voting Feature 통합

2. **알림 목록 화면**
   - `NotificationsListWidget`: 사용자의 모든 알림 표시
   - 실시간 업데이트 (StreamBuilder)
   - 읽음/읽지 않음 시각적 구분

3. **알림 뱃지**
   - `NotificationBadge`: 읽지 않은 알림 개수 표시
   - `NotificationAppBarAction`: AppBar 통합 위젯
   - 실시간 카운트 업데이트

4. **라우팅**
   - GoRouter 통합
   - 타입 안전 네비게이션

### 계층 역할

```
Presentation Layer
  ↓ 의존 (UseCase)
Domain Layer
  ↓ 의존 (Repository Interface)
Data Layer
```

---

## 🗂️ 디렉토리 구조

```
lib/features/notifications/presentation/
├── providers/                         # 상태 관리
│   ├── notification_badge_provider.dart      # 뱃지 상태 (AppBar용)
│   └── notification_overlay_provider.dart    # 실시간 알림 표시
│
├── screens/                          # 화면 위젯
│   └── notifications_list/
│       └── notifications_list_widget.dart    # 알림 목록 페이지
│
├── widgets/                          # 재사용 가능한 UI 컴포넌트
│   └── notification_badge.dart       # 뱃지 위젯
│
├── helpers/                          # UI 헬퍼
│   └── notification_display_helper.dart      # 아이콘/타이틀 매핑
│
└── routes/                           # 라우팅 설정
    └── notification_routes.dart      # GoRouter 통합
```

---

## 🎛️ Providers

### NotificationOverlayProvider

**위치:** `providers/notification_overlay_provider.dart`

**역할:** NotificationQueueService 스트림을 구독하여 실시간 알림을 다이얼로그로 표시

**주요 책임:**
- NotificationQueueService의 `showNotificationStream` 구독
- 알림 타입에 따라 적절한 다이얼로그 라우팅
- 사용자 액션 처리 (투표, 해제)
- MarkAsReadUseCase 호출하여 읽음 처리
- Port-Adapter 패턴으로 Voting Feature와 통합

**의존성:**

```dart
class NotificationOverlayProvider extends ChangeNotifier {
  final NotificationQueueService _queueService;
  final MarkAsReadUseCase _markAsRead;
  final INotificationDisplayPort _votingDisplayPort;  // Voting Feature Port
}
```

**핵심 메서드:**

```dart
// 스트림 리스닝 시작
void startListening() {
  _subscription = _queueService.showNotificationStream.listen(
    (notification) => _handleNotification(notification),
  );
}

// 스트림 리스닝 중지
void stopListening() {
  _subscription?.cancel();
}

// 알림 타입별 라우팅
void _handleNotification(Notification notification) {
  if (notification.type == NotificationTypes.votingRequest) {
    _showVotingDialog(notification);
  } else if (notification is SocialNotification) {
    _showSocialDialog(notification);
  } else if (notification is SystemNotification) {
    _showSystemDialog(notification);
  }
}

// Voting 다이얼로그 표시 (Port-Adapter 패턴)
Future<void> _showVotingDialog(Notification notification) async {
  await _votingDisplayPort.showVotingNotification(
    notification: notification,
    context: context,
    displayData: {},  // Voting Feature가 자체 데이터 추출
    onVote: (selectedOption) async {
      await _handleVote(notification, selectedOption);
    },
    onDismiss: (hasVoted) async {
      await _handleDismiss(notification);
    },
  );
}

// 투표 처리 (Voting Feature에서 실제 투표 수행)
Future<void> _handleVote(Notification notification, String selectedOption) async {
  // 1. 알림 읽음 처리 (Notification Feature 책임)
  await _markAsRead.call(MarkAsReadParams(
    notificationId: notification.id,
    userId: notification.userId,
  ));

  // 2. 다음 알림 표시 (300ms 지연)
  _queueService.notificationClosed(delayMilliseconds: 300);
}

// 알림 해제 처리
Future<void> _handleDismiss(Notification notification) async {
  await _markAsRead.call(MarkAsReadParams(
    notificationId: notification.id,
    userId: notification.userId,
  ));

  _queueService.notificationClosed(delayMilliseconds: 500);
}
```

**통합 구조:**

```
[NotificationQueueService]
        ↓ showNotificationStream
[NotificationOverlayProvider]
        ↓ 타입별 라우팅
┌───────┴────────┬──────────┐
│                │          │
Voting Dialog  Social    System
(via Port)     Dialog    Dialog
```

**사용 예시:**

```dart
// main.dart 또는 app_state.dart에서 초기화
final overlayProvider = NotificationOverlayProvider(
  queueService: getIt<NotificationQueueService>(),
  markAsRead: getIt<MarkAsReadUseCase>(),
  votingDisplayPort: getIt<INotificationDisplayPort>(),
);

// 앱 시작 시 리스닝 시작
overlayProvider.startListening();

// 앱 종료 시 정리
overlayProvider.dispose();  // stopListening 자동 호출
```

**에러 처리:**

```dart
// Navigator 컨텍스트 없을 때 재시도 로직
if (context == null) {
  Logger.warning('No navigator context - retrying in 5 seconds');
  Future.delayed(const Duration(seconds: 5), () {
    _showVotingDialog(notification);
  });
  return;
}

// 스트림 에러 처리
_subscription = _queueService.showNotificationStream.listen(
  (notification) => _handleNotification(notification),
  onError: (error) {
    Logger.error('Stream error', error: error);
    // 큐 서비스에 알림 처리 완료 신호
    _queueService.notificationClosed();
  },
);
```

### NotificationBadgeProvider (NotificationAppBarAction)

**위치:** `providers/notification_badge_provider.dart`

**역할:** AppBar에 표시할 알림 아이콘 및 뱃지 제공

**주요 책임:**
- 현재 사용자 ID 가져오기 (GetCurrentUserUseCase)
- 읽지 않은 알림 개수 실시간 감시 (WatchUnreadCountUseCase)
- 알림 목록 페이지로 네비게이션

**의존성:**

```dart
class NotificationAppBarAction extends StatelessWidget {
  // GetIt DI를 통해 UseCase 주입
  final getCurrentUser = GetIt.instance<GetCurrentUserUseCase>();
  final watchUnreadCount = GetIt.instance<WatchUnreadCountUseCase>();
}
```

**구현:**

```dart
@override
Widget build(BuildContext context) {
  final userId = getCurrentUser.currentUserId;

  if (userId.isEmpty) {
    // 로그인하지 않은 경우 0개로 표시
    return NotificationIconWithBadge(
      count: 0,
      onPressed: () => context.pushNamed('notificationsList'),
    );
  }

  // 실시간 읽지 않은 알림 개수 구독
  return StreamBuilder<int>(
    stream: watchUnreadCount.call(userId),
    initialData: 0,
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;
      return NotificationIconWithBadge(
        count: count,
        onPressed: () => context.pushNamed('notificationsList'),
      );
    },
  );
}
```

**사용 예시:**

```dart
// AppBar actions에 추가
AppBar(
  title: Text('홈'),
  actions: [
    NotificationAppBarAction(),  // 실시간 뱃지 표시
    IconButton(icon: Icon(Icons.settings), onPressed: () {}),
  ],
);

// 커스터마이징
NotificationAppBarAction(
  icon: Icons.notifications,
  iconColor: Colors.white,
  badgeColor: Colors.red,
  onPressed: () {
    // 커스텀 동작
    print('알림 아이콘 클릭');
  },
);
```

---

## 📱 Screens

### NotificationsListWidget

**위치:** `screens/notifications_list/notifications_list_widget.dart`

**역할:** 사용자의 모든 알림을 목록으로 표시하는 전체 화면

**주요 기능:**
- 실시간 알림 목록 표시 (StreamBuilder)
- 읽음/읽지 않음 시각적 구분
- 만료된 알림 흐리게 표시
- 알림 클릭 시 읽음 처리
- 빈 상태 UI (알림 없을 때)

**의존성:**

```dart
class _NotificationsListWidgetState extends State<NotificationsListWidget> {
  late final WatchUserNotificationsUseCase _watchUserNotifications;
  late final MarkAsReadUseCase _markAsRead;
  late final AuthContract _authContract;

  @override
  void initState() {
    super.initState();
    _watchUserNotifications = GetIt.instance<WatchUserNotificationsUseCase>();
    _markAsRead = GetIt.instance<MarkAsReadUseCase>();
    _authContract = GetIt.instance<AuthContract>();
  }
}
```

**UI 구조:**

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('알림'),
      centerTitle: true,
    ),
    body: SafeArea(
      child: StreamBuilder<List<Notification>>(
        stream: _watchUserNotifications.call(
          _authContract.getCurrentUserId() ?? '',
        ),
        builder: (context, snapshot) {
          // 로딩 상태
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;

          // 빈 상태
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          // 알림 목록
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        },
      ),
    ),
  );
}
```

**알림 아이템 UI:**

```dart
Widget _buildNotificationItem(Notification notification) {
  final isExpired = notification.isExpired;

  return Opacity(
    opacity: notification.isRead || isExpired ? 0.6 : 1.0,
    child: InkWell(
      onTap: isExpired ? null : () async {
        // 읽음 처리
        if (!notification.isRead) {
          await _markAsRead.call(MarkAsReadParams(
            notificationId: notification.id,
            userId: _authContract.getCurrentUserId()!,
          ));
        }

        // TODO: 알림 상세 보기 또는 관련 게시물로 이동
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : Theme.of(context).primaryColor.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Icon(
              NotificationDisplayHelper.getIcon(notification.type),
              size: 40.0,
            ),
            SizedBox(width: 16.0),
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    notification.content,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            // 읽음 표시
            if (!notification.isRead)
              Container(
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
```

**빈 상태 UI:**

```dart
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_none,
          size: 72.0,
          color: Colors.grey,
        ),
        SizedBox(height: 16.0),
        Text(
          '알림이 없습니다',
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}
```

**시각적 상태:**

```yaml
읽지 않은 알림:
  - opacity: 1.0 (선명)
  - fontWeight: bold
  - 배경색: primaryColor.withOpacity(0.1)
  - 파란색 점 표시

읽은 알림:
  - opacity: 0.6 (흐림)
  - fontWeight: normal
  - 배경색: transparent
  - 점 없음

만료된 알림:
  - opacity: 0.6 (흐림)
  - onTap: null (클릭 불가)
  - 배경색: transparent
```

---

## 🧩 Widgets

### NotificationBadge

**위치:** `widgets/notification_badge.dart`

**역할:** 알림 개수를 표시하는 뱃지 위젯 (재사용 가능)

**Props:**

```dart
class NotificationBadge extends StatelessWidget {
  final Widget child;           // 뱃지를 표시할 자식 위젯
  final int count;              // 알림 개수
  final Color? badgeColor;      // 뱃지 배경색 (기본: error color)
  final Color? textColor;       // 텍스트 색상 (기본: white)
  final double? size;           // 뱃지 크기 (기본: 18.0)
  final bool showZero;          // 0일 때도 표시 여부 (기본: false)
  final Alignment alignment;    // 뱃지 위치 (기본: topRight)
  final EdgeInsets padding;     // 내부 패딩
}
```

**주요 로직:**

```dart
@override
Widget build(BuildContext context) {
  // 0일 때 뱃지 숨김 (showZero가 false인 경우)
  if (count <= 0 && !showZero) {
    return child;
  }

  // 99보다 큰 숫자는 99+로 표시
  final displayCount = count > 99 ? '99+' : count.toString();

  return Stack(
    alignment: alignment,
    children: [
      child,
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: padding,
          constraints: BoxConstraints(
            minWidth: size,
            minHeight: size,
          ),
          decoration: BoxDecoration(
            color: badgeColor ?? Theme.of(context).colorScheme.error,
            // 99+는 사각형, 그 외는 원형
            shape: count > 99 ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: count > 99 ? BorderRadius.circular(size / 2) : null,
          ),
          child: Center(
            child: Text(
              displayCount,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
```

**사용 예시:**

```dart
// 기본 사용
NotificationBadge(
  count: 5,
  child: Icon(Icons.notifications),
);

// 커스터마이징
NotificationBadge(
  count: 120,
  badgeColor: Colors.red,
  textColor: Colors.white,
  size: 20.0,
  child: Icon(Icons.mail),
);

// 0일 때도 표시
NotificationBadge(
  count: 0,
  showZero: true,
  child: Icon(Icons.notifications),
);
```

### NotificationIconWithBadge

**위치:** `widgets/notification_badge.dart` (같은 파일)

**역할:** 아이콘과 뱃지를 함께 표시하는 헬퍼 위젯

**Props:**

```dart
class NotificationIconWithBadge extends StatelessWidget {
  final int count;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final Color? badgeColor;
  final VoidCallback? onPressed;
}
```

**구현:**

```dart
@override
Widget build(BuildContext context) {
  return IconButton(
    icon: NotificationBadge(
      count: count,
      badgeColor: badgeColor,
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor,
      ),
    ),
    onPressed: onPressed,
  );
}
```

**사용 예시:**

```dart
// AppBar에서 사용
NotificationIconWithBadge(
  count: 12,
  icon: Icons.notifications_outlined,
  iconSize: 24.0,
  onPressed: () {
    context.pushNamed('notificationsList');
  },
);
```

---

## 🛠️ Helpers

### NotificationDisplayHelper

**위치:** `helpers/notification_display_helper.dart`

**역할:** 알림 타입별 UI 정보 제공 (아이콘, 타이틀)

**유틸리티 메서드:**

```dart
class NotificationDisplayHelper {
  // 타입별 한글 타이틀
  static String getTitle(String type) {
    switch (type) {
      case NotificationTypes.votingRequest:
        return '투표 요청';
      case NotificationTypes.postLiked:
        return '좋아요';
      case NotificationTypes.commentAdded:
        return '댓글';
      case NotificationTypes.friendRequest:
        return '친구 요청';
      case NotificationTypes.systemAlert:
        return '시스템 알림';
      case NotificationTypes.postCompleted:
        return '투표 완료';
      case NotificationTypes.achievementUnlocked:
        return '업적 달성';
      default:
        return '알림';
    }
  }

  // 타입별 Material 아이콘
  static IconData getIcon(String type) {
    switch (type) {
      case NotificationTypes.votingRequest:
        return Icons.how_to_vote;
      case NotificationTypes.postLiked:
        return Icons.favorite;
      case NotificationTypes.commentAdded:
        return Icons.comment;
      case NotificationTypes.friendRequest:
        return Icons.person_add;
      case NotificationTypes.systemAlert:
        return Icons.info;
      case NotificationTypes.postCompleted:
        return Icons.check_circle;
      case NotificationTypes.achievementUnlocked:
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  // Private 생성자 (유틸리티 클래스)
  NotificationDisplayHelper._();
}
```

**사용 예시:**

```dart
// 알림 목록에서 타이틀 표시
final title = NotificationDisplayHelper.getTitle(notification.type);
Text(title);

// 알림 목록에서 아이콘 표시
final icon = NotificationDisplayHelper.getIcon(notification.type);
Icon(icon, size: 40.0);
```

**확장 가능성:**

```dart
// 타입별 색상 추가 예시
static Color getColor(String type) {
  switch (type) {
    case NotificationTypes.votingRequest:
      return Colors.blue;
    case NotificationTypes.postLiked:
      return Colors.red;
    case NotificationTypes.systemAlert:
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
```

---

## 🧭 Routes

### NotificationRoutes

**위치:** `routes/notification_routes.dart`

**역할:** Notification Feature의 모든 라우트 정의 및 GoRouter 통합

**라우트 정의:**

```dart
class NotificationRoutes {
  // Private 생성자 (정적 클래스)
  NotificationRoutes._();

  // GoRoute 리스트
  static List<GoRoute> get routes => [
    GoRoute(
      name: 'notificationsList',
      path: '/notifications',
      builder: (context, state) => NotificationsListWidget(),
    ),
  ];

  // 라우트 이름 상수 (타입 안전)
  static const String notificationsList = 'notificationsList';

  // 라우트 경로 상수
  static const String notificationsListPath = '/notifications';
}
```

**메인 라우터 통합:**

```dart
// app/router/app_router.dart
final router = GoRouter(
  routes: [
    ...HomeRoutes.routes,
    ...NotificationRoutes.routes,  // Notification Feature 라우트 추가
    ...ProfileRoutes.routes,
  ],
);
```

**타입 안전 네비게이션:**

```dart
// 이름으로 네비게이션 (권장)
context.pushNamed(NotificationRoutes.notificationsList);

// 경로로 직접 네비게이션
context.push(NotificationRoutes.notificationsListPath);

// go_router context extension 사용
context.goNamed('notificationsList');
```

**향후 확장:**

```dart
// 알림 상세 페이지 추가 예시
GoRoute(
  name: 'notificationDetail',
  path: '/notifications/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return NotificationDetailWidget(notificationId: id);
  },
),
```

---

## 📊 데이터 플로우

### 실시간 알림 표시 플로우

```
[Firebase Functions]
  └─> 알림 생성
        ↓
[Firestore notifications 컬렉션]
  └─> 문서 추가
        ↓
[NotificationRepositoryImpl]
  └─> watchUserNotifications 스트림
        ↓
[NotificationService]
  └─> NotificationQueueService에 전달
        ↓
[NotificationQueueService]
  └─> 큐에 추가 및 순차적 표시
        ↓ showNotificationStream
[NotificationOverlayProvider]
  ├─> Voting: _votingDisplayPort.showVotingNotification()
  ├─> Social: _showSocialDialog()
  └─> System: _showSystemDialog()
        ↓
[사용자 UI]
  └─> 다이얼로그 표시
        ↓
[사용자 액션: 투표 또는 해제]
  └─> onVote() / onDismiss()
        ↓
[MarkAsReadUseCase]
  └─> 알림 읽음 처리
        ↓
[NotificationQueueService.notificationClosed()]
  └─> 다음 알림 표시
```

### 알림 목록 화면 플로우

```
[사용자가 알림 목록 페이지 진입]
  ↓
[NotificationsListWidget]
  └─> WatchUserNotificationsUseCase.call(userId)
        ↓
[Repository.watchUserNotifications()]
  └─> Firestore 실시간 스트림
        ↓
[StreamBuilder]
  ├─> snapshot.hasData == false → 로딩
  ├─> notifications.isEmpty → 빈 상태 UI
  └─> notifications.isNotEmpty → ListView
        ↓
[알림 아이템 탭]
  └─> MarkAsReadUseCase.call()
        ↓
[Repository.markAsRead()]
  └─> Firestore 업데이트
        ↓
[스트림 자동 업데이트]
  └─> UI 다시 렌더링 (읽음 상태 반영)
```

### 뱃지 카운트 플로우

```
[AppBar 렌더링]
  ↓
[NotificationAppBarAction]
  └─> GetCurrentUserUseCase.currentUserId
        ↓
[WatchUnreadCountUseCase.call(userId)]
  └─> Repository.watchUnreadCount(userId)
        ↓
[Firestore 실시간 쿼리]
  └─> where('userId', isEqualTo: userId)
      .where('isRead', isEqualTo: false)
        ↓
[StreamBuilder]
  └─> snapshot.data → count
        ↓
[NotificationIconWithBadge]
  └─> 뱃지 표시 (count > 0일 때만)
```

---

## 🎨 UI/UX 패턴

### 로딩 상태

```dart
if (!snapshot.hasData) {
  return Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).primaryColor,
      ),
    ),
  );
}
```

### 빈 상태

```dart
if (notifications.isEmpty) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_none, size: 72.0, color: Colors.grey),
        SizedBox(height: 16.0),
        Text('알림이 없습니다', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
```

### 에러 상태

```dart
if (snapshot.hasError) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 72.0, color: Colors.red),
        SizedBox(height: 16.0),
        Text('알림을 불러올 수 없습니다'),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () => setState(() {}),  // 재시도
          child: Text('다시 시도'),
        ),
      ],
    ),
  );
}
```

### 실시간 업데이트 애니메이션

```dart
// ListView.builder에 AnimatedList 적용 예시
AnimatedList(
  key: _listKey,
  initialItemCount: notifications.length,
  itemBuilder: (context, index, animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _buildNotificationItem(notifications[index]),
    );
  },
);
```

---

## 🔗 Feature 간 통합

### Voting Feature 통합 (Port-Adapter 패턴)

**통합 포인트:** `NotificationOverlayProvider._showVotingDialog()`

**Port 인터페이스:**

```dart
// core/domain/ports/i_notification_display_port.dart
abstract class INotificationDisplayPort {
  Future<void> showVotingNotification({
    required Notification notification,  // 베이스 Notification
    required BuildContext context,
    required Map<String, dynamic> displayData,
    required Future<void> Function(String) onVote,
    required void Function(bool hasVoted) onDismiss,
  });
}
```

**Voting Feature 구현체:**

```dart
// features/voting/data/adapters/voting_notification_display_adapter.dart
class VotingNotificationDisplayAdapter implements INotificationDisplayPort {
  @override
  Future<void> showVotingNotification({...}) async {
    // 1. Notification → VoteNotification 캐스팅
    final voteNotif = notification as VoteNotification;

    // 2. Voting Feature 자체 데이터 추출
    final question = voteNotif.data['question'];
    final optionA = voteNotif.data['optionA'];
    // ...

    // 3. Voting Feature UI 표시
    await NotificationOverlay.showVoting(
      context: context,
      question: question,
      optionA: optionA,
      optionB: optionB,
      onVote: onVote,
      onDismiss: onDismiss,
    );
  }
}
```

**DI 등록:**

```dart
// app/di.dart
getIt.registerLazySingleton<INotificationDisplayPort>(
  () => VotingNotificationDisplayAdapter(),
);
```

**호출 시퀀스:**

```
1. NotificationOverlayProvider receives Notification
2. Checks type == NotificationTypes.votingRequest
3. Calls _votingDisplayPort.showVotingNotification()
4. Voting Feature casts to VoteNotification
5. Voting Feature extracts its own data
6. Voting Feature shows its own UI
7. User votes → onVote callback
8. NotificationOverlayProvider marks as read
```

### Auth Feature 통합

```dart
// AuthContract를 통해 현재 사용자 ID 가져오기
final authContract = GetIt.instance<AuthContract>();
final userId = authContract.getCurrentUserId();

// 알림 UseCase 호출
final notifications = await getNotifications.call(
  GetNotificationsParams(userId: userId),
);
```

### Navigation 통합

```dart
// appNavigatorKey를 통한 전역 네비게이션
final context = appNavigatorKey.currentContext;
if (context != null) {
  await showDialog(context: context, builder: ...);
}
```

---

## 🧪 테스트 전략

### Widget 테스트

```dart
group('NotificationBadge Widget', () {
  testWidgets('count가 0일 때 뱃지를 표시하지 않는다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationBadge(
          count: 0,
          child: Icon(Icons.notifications),
        ),
      ),
    );

    // 뱃지 컨테이너를 찾을 수 없어야 함
    expect(find.byType(Container), findsNothing);
  });

  testWidgets('count가 99보다 크면 99+로 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationBadge(
          count: 150,
          child: Icon(Icons.notifications),
        ),
      ),
    );

    expect(find.text('99+'), findsOneWidget);
  });
});
```

### Provider 테스트

```dart
group('NotificationOverlayProvider', () {
  late MockNotificationQueueService mockQueueService;
  late MockMarkAsReadUseCase mockMarkAsRead;
  late NotificationOverlayProvider provider;

  setUp(() {
    mockQueueService = MockNotificationQueueService();
    mockMarkAsRead = MockMarkAsReadUseCase();
    provider = NotificationOverlayProvider(
      queueService: mockQueueService,
      markAsRead: mockMarkAsRead,
      votingDisplayPort: mockVotingDisplayPort,
    );
  });

  test('startListening은 스트림을 구독한다', () {
    // Arrange
    when(() => mockQueueService.showNotificationStream)
      .thenAnswer((_) => Stream.value(mockNotification));

    // Act
    provider.startListening();

    // Assert
    verify(() => mockQueueService.showNotificationStream).called(1);
  });

  test('handleVote는 알림을 읽음 처리하고 큐를 닫는다', () async {
    // Arrange
    when(() => mockMarkAsRead.call(any()))
      .thenAnswer((_) async => Result.success(null));
    when(() => mockQueueService.notificationClosed(any()))
      .thenReturn(null);

    // Act
    await provider._handleVote(mockNotification, 'A');

    // Assert
    verify(() => mockMarkAsRead.call(any())).called(1);
    verify(() => mockQueueService.notificationClosed(
      delayMilliseconds: 300,
    )).called(1);
  });
});
```

### Integration 테스트

```dart
group('Notifications List Integration', () {
  testWidgets('알림 목록을 표시하고 클릭 시 읽음 처리한다', (tester) async {
    // Arrange
    final mockNotifications = [
      SystemNotification(
        id: 'notif1',
        userId: 'user1',
        createdAt: DateTime.now(),
        isRead: false,
        title: 'Test',
        content: 'Test',
        alertType: SystemAlertType.info,
      ),
    ];

    when(() => mockRepository.watchUserNotifications(any()))
      .thenAnswer((_) => Stream.value(mockNotifications));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsListWidget(),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - 알림 표시 확인
    expect(find.text('Test'), findsOneWidget);

    // Act - 알림 클릭
    await tester.tap(find.text('Test'));
    await tester.pumpAndSettle();

    // Assert - 읽음 처리 호출 확인
    verify(() => mockMarkAsRead.call(any())).called(1);
  });
});
```

---

## 🔗 관련 문서

### Feature 내부 문서
- [Domain Layer](../domain/README.md) - UseCase 및 비즈니스 로직
- [Data Layer](../data/README.md) - Repository 구현 및 데이터 소스
- [Feature Root](../README.md) - Notifications Feature 전체 개요

### 다른 Feature와의 통합
- [Voting Feature](../../voting/presentation/README.md) - Port-Adapter 패턴 통합
- [Auth Feature](../../auth/README.md) - AuthContract 사용
- [App Layer](../../../../app/README.md) - DI, Router, Contracts

### 프로젝트 전체 문서
- [Clean Architecture Guide](../../../../docs/architecture/clean-architecture.md)
- [Presentation Layer Best Practices](../../../../docs/architecture/presentation-layer.md)
- [Provider Pattern Guide](../../../../docs/patterns/provider-pattern.md)
- [Widget Testing Guide](../../../../docs/testing/widget-testing.md)

---

## 📝 변경 이력

### v2.0.0 (2025-01-20)
- ✅ Presentation Layer README.md 신규 작성
- ✅ NotificationOverlayProvider 상세 문서화
- ✅ NotificationBadge 위젯 가이드 추가
- ✅ Port-Adapter 패턴 통합 설명
- ✅ 테스트 전략 및 예시 추가

### v1.3.0 (2025-01-18)
- NotificationOverlayProvider 구현
- Port-Adapter 패턴 적용 (Voting Feature 통합)
- 실시간 알림 표시 시스템 완성

### v1.2.0 (2025-01-15)
- NotificationAppBarAction 추가
- NotificationBadge 위젯 구현
- 읽지 않은 알림 개수 실시간 표시

### v1.1.0 (2025-01-10)
- NotificationsListWidget 구현
- StreamBuilder 기반 실시간 업데이트
- NotificationDisplayHelper 추가

### v1.0.0 (2025-01-05)
- 초기 Presentation Layer 구현
- GoRouter 통합
- 기본 화면 및 위젯 구성

---

## 👥 기여자

- Feature Owner: Frontend Team
- UI/UX Designer: Design Team
- Architecture Lead: Clean Architecture Team

**마지막 업데이트:** 2025-01-20
**문서 버전:** 2.0.0
