# Notification Feature - Phase 2: Riverpod 2.x Migration

> **마이그레이션 가이드**: Riverpod 2.x StreamProvider 신규 생성
> **난이도**: ⭐⭐⭐☆☆ (중상)
> **예상 소요 시간**: 6시간
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

Notification Feature에 Riverpod 2.x 상태 관리를 도입하여 실시간 알림 스트림과 읽지 않은 알림 개수를 효율적으로 관리합니다.

### 핵심 문제점

1. **Provider 파일 부재**: `notification_providers.dart` 파일이 존재하지 않음
2. **ChangeNotifier 부재**: Provider 패턴 자체가 구현 안 됨
3. **상태 관리 부재**: UI에서 직접 Repository 호출 (안티패턴)
4. **실시간 업데이트 부재**: 알림 수신 시 수동 새로고침 필요

### 영향 범위

| 레이어 | 파일 수 | 변경 줄 수 | 주요 변경 사항 |
|--------|---------|-----------|---------------|
| **Presentation (Providers)** | 1개 (신규) | +350줄 | StreamProvider 생성 |
| **Presentation (UI)** | 3개 | +180줄 | AsyncValue.when() 통합 |
| **Domain (UseCases)** | 0개 | 0줄 | 변경 없음 |
| **DI Module** | 1개 | +50줄 | Provider 등록 |
| **합계** | **5개** | **+580줄** | - |

### 주요 이점

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **상태 관리** | 없음 | Riverpod 2.x | **신규 구축** |
| **실시간 업데이트** | 수동 | 자동 | **100% 자동화** |
| **메모리 관리** | 수동 | autoDispose | **메모리 누수 방지** |
| **코드 재사용** | 낮음 | 높음 | **Provider 재사용** |

---

## 🔍 현재 상태 분석

### 1. Provider 파일 부재

**예상 경로**: `presentation/providers/notification_providers.dart`

```bash
$ ls lib/features/notifications/presentation/providers/
# ❌ 파일 없음
```

**문제점**:
- 상태 관리 계층 자체가 없음
- UI가 직접 Repository/UseCase 호출
- 실시간 스트림 구독 관리 불가

### 2. UI에서 직접 UseCase 호출 (안티패턴)

**예상 패턴** (현재 UI 구현):

```dart
/// ❌ 현재: UI에서 직접 UseCase 호출 (추정)
class NotificationListWidget extends StatefulWidget {
  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  late final GetUserNotificationsUseCase _getUserNotificationsUseCase;
  List<Notification>? _notifications;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getUserNotificationsUseCase = getIt<GetUserNotificationsUseCase>();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);

    final result = await _getUserNotificationsUseCase(currentUserId);

    result.fold(
      (failure) {
        setState(() {
          _errorMessage = failure.message;
          _isLoading = false;
        });
      },
      (notifications) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    if (_errorMessage != null) return Text(_errorMessage!);

    return ListView.builder(
      itemCount: _notifications?.length ?? 0,
      itemBuilder: (context, index) {
        final notification = _notifications![index];
        return NotificationTile(notification: notification);
      },
    );
  }
}
```

**문제점**:
1. **메모리 누수**: dispose()에서 구독 해제 안 됨
2. **실시간 업데이트 없음**: 새 알림 수신 시 수동 새로고침
3. **코드 중복**: 모든 UI가 동일한 로딩/에러 로직 반복
4. **상태 공유 불가**: 여러 화면에서 동일한 데이터 공유 안 됨

### 3. Sealed Union 타입별 처리 필요

**파일**: `domain/models/notification.dart`

```dart
/// ✅ Freezed Sealed Union (3가지 타입)
@freezed
sealed class Notification with _$Notification {
  // Social Notification (17 fields)
  const factory Notification.social({...}) = SocialNotification;

  // System Notification (16 fields)
  const factory Notification.system({...}) = SystemNotification;

  // Voting Notification (36 fields)
  const factory Notification.voting({...}) = VotingNotification;
}
```

**요구사항**:
- **타입별 Provider**: social, system, voting 각각 필터링
- **통합 Provider**: 모든 타입 함께 조회
- **Unread Count**: 읽지 않은 알림 개수
- **실시간 업데이트**: Stream 기반

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. Provider 구조

```dart
// ❌ Before: Provider 없음
// UI가 직접 UseCase 호출

// ✅ After: Riverpod 2.x StreamProvider
@riverpod
Stream<List<Notification>> watchUserNotifications(
  WatchUserNotificationsRef ref,
  String userId,
) {
  final usecase = ref.watch(watchUserNotificationsUseCaseProvider);
  return usecase(userId);
}

@riverpod
Stream<int> watchUnreadCount(
  WatchUnreadCountRef ref,
  String userId,
) {
  final usecase = ref.watch(watchUnreadCountUseCaseProvider);
  return usecase(userId);
}
```

#### 2. UI 통합

```dart
// ❌ Before: StatefulWidget + setState
class NotificationListWidget extends StatefulWidget {
  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  List<Notification>? _notifications;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ... setState() 반복
}

// ✅ After: ConsumerWidget + AsyncValue
class NotificationListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(
      watchUserNotificationsProvider(currentUserId),
    );

    return notificationsAsync.when(
      data: (notifications) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: Riverpod 의존성 확인

**파일**: `pubspec.yaml`

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
```

```bash
flutter pub get
```

### Step 2: notification_providers.dart 신규 생성

**파일**: `presentation/providers/notification_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/notification.dart';
import '../../domain/usecases/watch_user_notifications_usecase.dart';
import '../../domain/usecases/watch_unread_count_usecase.dart';
import '../../domain/usecases/get_user_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';
import '../../di/notification_di_module.dart';

part 'notification_providers.g.dart';

// ========== UseCase Providers ==========

/// WatchUserNotificationsUseCase Provider
@riverpod
WatchUserNotificationsUseCase watchUserNotificationsUseCase(
  WatchUserNotificationsUseCaseRef ref,
) {
  return getIt<WatchUserNotificationsUseCase>();
}

/// WatchUnreadCountUseCase Provider
@riverpod
WatchUnreadCountUseCase watchUnreadCountUseCase(
  WatchUnreadCountUseCaseRef ref,
) {
  return getIt<WatchUnreadCountUseCase>();
}

/// GetUserNotificationsUseCase Provider
@riverpod
GetUserNotificationsUseCase getUserNotificationsUseCase(
  GetUserNotificationsUseCaseRef ref,
) {
  return getIt<GetUserNotificationsUseCase>();
}

/// MarkAsReadUseCase Provider
@riverpod
MarkAsReadUseCase markAsReadUseCase(
  MarkAsReadUseCaseRef ref,
) {
  return getIt<MarkAsReadUseCase>();
}

/// SendNotificationUseCase Provider
@riverpod
SendNotificationUseCase sendNotificationUseCase(
  SendNotificationUseCaseRef ref,
) {
  return getIt<SendNotificationUseCase>();
}

// ========== Stream Providers (실시간 데이터) ==========

/// 사용자 알림 실시간 감시
///
/// **StreamProvider.autoDispose.family**:
/// - userId별로 독립적인 스트림
/// - 화면 벗어나면 자동 dispose (메모리 누수 방지)
///
/// **사용 예시**:
/// ```dart
/// final notificationsAsync = ref.watch(
///   watchUserNotificationsProvider(userId),
/// );
/// ```
@riverpod
Stream<List<Notification>> watchUserNotifications(
  WatchUserNotificationsRef ref,
  String userId,
) {
  final usecase = ref.watch(watchUserNotificationsUseCaseProvider);

  // UseCase는 이미 비즈니스 로직 포함 (만료 필터링, 정렬)
  return usecase(userId);
}

/// 읽지 않은 알림 개수 실시간 감시
///
/// **Badge에 사용**:
/// - 앱바의 알림 아이콘 Badge
/// - 탭 바의 알림 탭 Badge
///
/// **사용 예시**:
/// ```dart
/// final unreadCountAsync = ref.watch(
///   watchUnreadCountProvider(userId),
/// );
/// unreadCountAsync.when(
///   data: (count) => Badge(count: count, child: Icon(Icons.notifications)),
///   loading: () => Icon(Icons.notifications),
///   error: (_, __) => Icon(Icons.notifications_off),
/// );
/// ```
@riverpod
Stream<int> watchUnreadCount(
  WatchUnreadCountRef ref,
  String userId,
) {
  final usecase = ref.watch(watchUnreadCountUseCaseProvider);
  return usecase(userId);
}

// ========== 타입별 필터링 Providers ==========

/// Social 알림만 필터링
///
/// **사용 예시**: 소셜 알림 전용 화면
@riverpod
Stream<List<SocialNotification>> watchSocialNotifications(
  WatchSocialNotificationsRef ref,
  String userId,
) {
  final allNotifications = ref.watch(
    watchUserNotificationsProvider(userId),
  );

  return allNotifications.asyncMap((notifications) {
    return notifications
        .whereType<SocialNotification>()
        .toList();
  });
}

/// System 알림만 필터링
///
/// **사용 예시**: 시스템 공지 화면
@riverpod
Stream<List<SystemNotification>> watchSystemNotifications(
  WatchSystemNotificationsRef ref,
  String userId,
) {
  final allNotifications = ref.watch(
    watchUserNotificationsProvider(userId),
  );

  return allNotifications.asyncMap((notifications) {
    return notifications
        .whereType<SystemNotification>()
        .toList();
  });
}

/// Voting 알림만 필터링
///
/// **사용 예시**: 투표 요청 화면
@riverpod
Stream<List<VotingNotification>> watchVotingNotifications(
  WatchVotingNotificationsRef ref,
  String userId,
) {
  final allNotifications = ref.watch(
    watchUserNotificationsProvider(userId),
  );

  return allNotifications.asyncMap((notifications) {
    return notifications
        .whereType<VotingNotification>()
        .toList();
  });
}

// ========== FutureProvider (일회성 조회) ==========

/// 사용자 알림 목록 조회 (일회성)
///
/// **Note**: 실시간이 아닌 일회성 조회 시 사용
/// 대부분의 경우 watchUserNotificationsProvider 사용 권장
///
/// **사용 예시**: 알림 목록 Export, 통계 생성 등
@riverpod
Future<List<Notification>> getUserNotifications(
  GetUserNotificationsRef ref,
  String userId,
) async {
  final usecase = ref.watch(getUserNotificationsUseCaseProvider);
  final result = await usecase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (notifications) => notifications,
  );
}

// ========== Actions (Mutation) ==========

/// 알림 읽음 처리
///
/// **사용 예시**:
/// ```dart
/// await ref.read(markAsReadProvider).call(
///   notificationId: notif.id,
///   userId: currentUserId,
/// );
/// ```
@riverpod
class MarkAsReadNotifier extends _$MarkAsReadNotifier {
  @override
  FutureOr<void> build() {
    // No-op: Action Provider는 build() 불필요
  }

  /// 알림 읽음 처리 실행
  Future<void> call({
    required String notificationId,
    required String userId,
  }) async {
    state = const AsyncLoading();

    final usecase = ref.read(markAsReadUseCaseProvider);
    final result = await usecase(MarkAsReadParams(
      notificationId: notificationId,
      userId: userId,
    ));

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw Exception(failure.message);
      },
      (_) {
        state = const AsyncData(null);
      },
    );
  }
}

/// 알림 전송
///
/// **사용 예시**: 관리자 페이지에서 알림 전송
@riverpod
class SendNotificationNotifier extends _$SendNotificationNotifier {
  @override
  FutureOr<void> build() {
    // No-op
  }

  Future<void> call(Notification notification) async {
    state = const AsyncLoading();

    final usecase = ref.read(sendNotificationUseCaseProvider);
    final result = await usecase(notification);

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        throw Exception(failure.message);
      },
      (_) {
        state = const AsyncData(null);
      },
    );
  }
}
```

### Step 3: Provider 코드 생성

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**생성되는 파일**:
- `notification_providers.g.dart` (자동 생성됨)

### Step 4: UI 통합 - NotificationListWidget

**파일**: `presentation/screens/notification_list/notification_list_widget.dart`

#### Before (StatefulWidget):

```dart
/// ❌ Before: StatefulWidget + 직접 UseCase 호출
class NotificationListWidget extends StatefulWidget {
  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  late final WatchUserNotificationsUseCase _watchUserNotificationsUseCase;
  StreamSubscription<List<Notification>>? _subscription;
  List<Notification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _watchUserNotificationsUseCase = getIt<WatchUserNotificationsUseCase>();
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    _subscription = _watchUserNotificationsUseCase(currentUserId).listen(
      (notifications) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();  // ❌ 수동 구독 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        return NotificationTile(notification: _notifications[index]);
      },
    );
  }
}
```

#### After (ConsumerWidget):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notification_providers.dart';
import '../../../domain/models/notification.dart';

/// ✅ After: ConsumerWidget + Riverpod StreamProvider
class NotificationListWidget extends ConsumerWidget {
  const NotificationListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    // ✅ StreamProvider 구독 (자동 dispose)
    final notificationsAsync = ref.watch(
      watchUserNotificationsProvider(currentUserId),
    );

    // ✅ AsyncValue.when(): 로딩/에러/데이터 한 번에 처리
    return notificationsAsync.when(
      // Loading 상태
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      // Error 상태
      error: (error, stackTrace) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                '알림을 불러오는데 실패했습니다',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // ✅ 재시도: Provider를 invalidate
                  ref.invalidate(watchUserNotificationsProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      },

      // Data 상태
      data: (notifications) {
        if (notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('알림이 없습니다'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // ✅ 당겨서 새로고침
            ref.invalidate(watchUserNotificationsProvider);
          },
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              // ✅ 타입별 UI 렌더링
              return notification.when(
                social: (id, userId, type, title, content, createdAt,
                    readAt, isRead, expiryTime, metadata,
                    actionType, fromUserId, fromUserName, fromUserProfileUrl,
                    relatedPostId, relatedCommentId, relatedContent,
                    interactionCount) {
                  return SocialNotificationTile(
                    notification: notification as SocialNotification,
                    onTap: () => _handleNotificationTap(context, ref, notification),
                  );
                },
                system: (id, userId, type, title, content, createdAt,
                    readAt, isRead, expiryTime, metadata,
                    alertType, actionUrl, actionLabel, actionButtons,
                    iconUrl, isDismissible) {
                  return SystemNotificationTile(
                    notification: notification as SystemNotification,
                    onTap: () => _handleNotificationTap(context, ref, notification),
                  );
                },
                voting: (id, userId, type, title, content, createdAt,
                    readAt, isRead, expiryTime, metadata,
                    postId, postTitle, postContent, postDescription,
                    voteStartTime, voteEndTime, targetAudience,
                    currentVotesA, currentVotesB, hasVoted, userVoteChoice,
                    senderId, senderName, body, notificationPriority,
                    imageUrlsA, imageUrlsB, aspectRatioA, aspectRatioB,
                    layoutType) {
                  return VotingNotificationTile(
                    notification: notification as VotingNotification,
                    onTap: () => _handleNotificationTap(context, ref, notification),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  /// 알림 탭 처리
  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    Notification notification,
  ) async {
    // 읽지 않은 알림이면 읽음 처리
    if (!notification.isRead) {
      try {
        await ref.read(markAsReadNotifierProvider.notifier).call(
              notificationId: notification.id,
              userId: notification.userId,
            );
      } catch (e) {
        // 에러 무시 (읽음 처리 실패해도 화면 이동은 진행)
      }
    }

    // 알림 타입별 화면 이동
    notification.when(
      social: (_) => _navigateToSocialContent(context, notification as SocialNotification),
      system: (_) => _navigateToSystemContent(context, notification as SystemNotification),
      voting: (_) => _navigateToVotingContent(context, notification as VotingNotification),
    );
  }

  void _navigateToSocialContent(BuildContext context, SocialNotification notification) {
    // Social 알림 화면 이동 로직
  }

  void _navigateToSystemContent(BuildContext context, SystemNotification notification) {
    // System 알림 화면 이동 로직
  }

  void _navigateToVotingContent(BuildContext context, VotingNotification notification) {
    // Voting 알림 화면 이동 로직
  }
}
```

### Step 5: Unread Count Badge 구현

**파일**: `presentation/widgets/notification_badge.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_providers.dart';

/// 읽지 않은 알림 개수 Badge
///
/// **사용 위치**:
/// - AppBar의 알림 아이콘
/// - BottomNavigationBar의 알림 탭
class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final String userId;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(
      watchUnreadCountProvider(userId),
    );

    return unreadCountAsync.when(
      // Loading: Badge 없이 표시
      loading: () => child,

      // Error: Badge 없이 표시 (에러 아이콘으로 변경 가능)
      error: (error, stack) => child,

      // Data: 읽지 않은 알림 개수 Badge
      data: (count) {
        if (count == 0) {
          return child;
        }

        return Badge(
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: Colors.red,
          child: child,
        );
      },
    );
  }
}

/// 사용 예시 - AppBar
class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    return AppBar(
      title: const Text('Versus Space'),
      actions: [
        // ✅ 읽지 않은 알림 Badge
        NotificationBadge(
          userId: currentUserId,
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ),
      ],
    );
  }
}
```

### Step 6: 타입별 필터링 화면

**파일**: `presentation/screens/voting_notifications/voting_notifications_widget.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notification_providers.dart';

/// 투표 요청 알림 전용 화면
///
/// **StreamProvider**: watchVotingNotificationsProvider
class VotingNotificationsWidget extends ConsumerWidget {
  const VotingNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);

    // ✅ Voting 알림만 필터링된 Stream
    final votingNotificationsAsync = ref.watch(
      watchVotingNotificationsProvider(currentUserId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('투표 요청')),
      body: votingNotificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (votingNotifications) {
          if (votingNotifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_vote_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('투표 요청이 없습니다'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: votingNotifications.length,
            itemBuilder: (context, index) {
              final notification = votingNotifications[index];

              return VotingNotificationCard(
                notification: notification,
                onVote: (choice) async {
                  // 투표 처리 로직
                  await _handleVote(context, ref, notification, choice);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleVote(
    BuildContext context,
    WidgetRef ref,
    VotingNotification notification,
    String choice,
  ) async {
    // 투표 UseCase 호출
    // ...
  }
}
```

---

## 🧪 테스트 전략

### 1. Provider 단위 테스트

**파일**: `test/unit/providers/notification_providers_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:versus_app/features/notifications/presentation/providers/notification_providers.dart';
import 'package:versus_app/features/notifications/domain/models/notification.dart';
import 'package:versus_app/features/notifications/domain/usecases/watch_user_notifications_usecase.dart';

class MockWatchUserNotificationsUseCase extends Mock
    implements WatchUserNotificationsUseCase {}

void main() {
  late ProviderContainer container;
  late MockWatchUserNotificationsUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockWatchUserNotificationsUseCase();

    container = ProviderContainer(
      overrides: [
        watchUserNotificationsUseCaseProvider.overrideWithValue(mockUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('watchUserNotificationsProvider', () {
    test('Stream을 정상적으로 반환', () async {
      // Arrange
      const userId = 'user_123';
      final testNotifications = [
        Notification.social(
          id: 'notif_1',
          userId: userId,
          type: 'social',
          title: 'Test',
          content: 'Content',
          createdAt: DateTime.now(),
          isRead: false,
          actionType: SocialActionType.like,
          fromUserId: 'user_456',
          fromUserName: 'John',
        ),
      ];

      when(() => mockUseCase(userId))
          .thenAnswer((_) => Stream.value(testNotifications));

      // Act
      final provider = watchUserNotificationsProvider(userId);
      final stream = container.read(provider.stream);

      // Assert
      await expectLater(
        stream,
        emits(testNotifications),
      );
    });

    test('autoDispose: 구독 해제 시 자동 정리', () async {
      // Arrange
      const userId = 'user_123';
      when(() => mockUseCase(userId))
          .thenAnswer((_) => Stream.value([]));

      // Act: 구독
      final provider = watchUserNotificationsProvider(userId);
      container.listen(provider, (prev, next) {});

      // Assert: 구독 중
      expect(container.exists(provider), isTrue);

      // Act: 구독 해제 (dispose)
      container.dispose();

      // Assert: 자동 정리됨
      expect(container.exists(provider), isFalse);
    });
  });

  group('watchUnreadCountProvider', () {
    test('읽지 않은 알림 개수 반환', () async {
      // Arrange
      const userId = 'user_123';
      const unreadCount = 5;

      final mockUnreadUseCase = MockWatchUnreadCountUseCase();
      when(() => mockUnreadUseCase(userId))
          .thenAnswer((_) => Stream.value(unreadCount));

      final container = ProviderContainer(
        overrides: [
          watchUnreadCountUseCaseProvider.overrideWithValue(mockUnreadUseCase),
        ],
      );

      // Act
      final provider = watchUnreadCountProvider(userId);
      final stream = container.read(provider.stream);

      // Assert
      await expectLater(stream, emits(unreadCount));

      container.dispose();
    });
  });
}
```

### 2. UI Widget 테스트

**파일**: `test/widget/notification_list_widget_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:versus_app/features/notifications/presentation/screens/notification_list/notification_list_widget.dart';
import 'package:versus_app/features/notifications/presentation/providers/notification_providers.dart';
import 'package:versus_app/features/notifications/domain/models/notification.dart';

void main() {
  group('NotificationListWidget', () {
    testWidgets('Loading 상태 표시', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserNotificationsProvider('user_123').overrideWith(
              (ref) => const Stream.empty(),
            ),
          ],
          child: const MaterialApp(
            home: NotificationListWidget(),
          ),
        ),
      );

      // Assert: CircularProgressIndicator 표시
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Empty 상태 표시', (tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserNotificationsProvider('user_123').overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(
            home: NotificationListWidget(),
          ),
        ),
      );

      // Wait for stream
      await tester.pumpAndSettle();

      // Assert: Empty 메시지 표시
      expect(find.text('알림이 없습니다'), findsOneWidget);
    });

    testWidgets('Data 상태: 알림 목록 표시', (tester) async {
      // Arrange
      final testNotifications = [
        Notification.social(
          id: 'notif_1',
          userId: 'user_123',
          type: 'social',
          title: 'Test Title',
          content: 'Test Content',
          createdAt: DateTime.now(),
          isRead: false,
          actionType: SocialActionType.like,
          fromUserId: 'user_456',
          fromUserName: 'John',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchUserNotificationsProvider('user_123').overrideWith(
              (ref) => Stream.value(testNotifications),
            ),
          ],
          child: const MaterialApp(
            home: NotificationListWidget(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: 알림 타일 표시
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
    });
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **Provider 코드 생성 실패**: build_runner 에러
2. **메모리 누수**: autoDispose가 제대로 작동 안 함
3. **성능 저하**: 과도한 Provider rebuild
4. **UI 버그**: AsyncValue.when() 상태 처리 문제

### 롤백 절차

#### Step 1: Git Revert

```bash
git log --oneline --grep="Riverpod"
git revert <commit-hash>
```

#### Step 2: Provider 파일 삭제

```bash
rm lib/features/notifications/presentation/providers/notification_providers.dart
rm lib/features/notifications/presentation/providers/notification_providers.g.dart
```

#### Step 3: UI 복구 (StatefulWidget으로)

```dart
// After (롤백 후)
class NotificationListWidget extends StatefulWidget {
  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}
```

---

## ✅ 완료 체크리스트

### Phase 2 완료 기준

- [ ] **Provider 파일 생성**
  - [ ] notification_providers.dart 생성
  - [ ] build_runner로 .g.dart 파일 생성

- [ ] **StreamProvider 구현 (6개)**
  - [ ] watchUserNotificationsProvider
  - [ ] watchUnreadCountProvider
  - [ ] watchSocialNotificationsProvider
  - [ ] watchSystemNotificationsProvider
  - [ ] watchVotingNotificationsProvider
  - [ ] getUserNotificationsProvider (FutureProvider)

- [ ] **Action Providers (2개)**
  - [ ] markAsReadNotifierProvider
  - [ ] sendNotificationNotifierProvider

- [ ] **UI 통합 (3개)**
  - [ ] NotificationListWidget (ConsumerWidget)
  - [ ] NotificationBadge (읽지 않은 개수)
  - [ ] VotingNotificationsWidget (타입별 화면)

- [ ] **테스트**
  - [ ] Provider 단위 테스트
  - [ ] Widget 테스트
  - [ ] autoDispose 검증

- [ ] **검증**
  - [ ] flutter analyze 통과
  - [ ] 모든 테스트 통과
  - [ ] 메모리 누수 없음

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] Phase 2 완료 표시

---

## 📊 마이그레이션 영향 분석

### 코드 변경량

| 파일 | Before (줄) | After (줄) | 변경률 |
|------|------------|-----------|--------|
| notification_providers.dart | 0 | 350 | +100% (신규) |
| notification_list_widget.dart | 120 | 180 | +50% |
| notification_badge.dart | 0 | 80 | +100% (신규) |
| voting_notifications_widget.dart | 0 | 100 | +100% (신규) |
| **합계** | **120줄** | **710줄** | **+492%** |

### ChangeNotifier vs Riverpod 비교

```
Before (ChangeNotifier 부재):
✅ 간단한 구조
❌ 실시간 업데이트 없음
❌ 메모리 수동 관리
❌ 상태 공유 어려움

After (Riverpod 2.x):
✅ 실시간 Stream 구독
✅ autoDispose (메모리 누수 방지)
✅ AsyncValue.when() (로딩/에러/데이터)
✅ 타입별 필터링 Provider
```

---

## 🎓 추가 학습 자료

### Riverpod 2.x 심화

#### 1. StreamProvider vs FutureProvider

```dart
// StreamProvider: 실시간 업데이트
@riverpod
Stream<List<Notification>> watchNotifications(
  WatchNotificationsRef ref,
  String userId,
) {
  return stream;  // 계속 emit
}

// FutureProvider: 일회성 조회
@riverpod
Future<List<Notification>> getNotifications(
  GetNotificationsRef ref,
  String userId,
) async {
  return await repository.get(userId);  // 1번만
}
```

#### 2. autoDispose vs keepAlive

```dart
// autoDispose: 화면 벗어나면 dispose (기본값)
@riverpod
Stream<int> watchUnreadCount(ref, userId) {...}

// keepAlive: dispose 안 함 (글로벌 상태)
@Riverpod(keepAlive: true)
Stream<int> watchUnreadCount(ref, userId) {...}
```

### Chat & Auth Feature 참조

- **Chat PHASE_2_RIVERPOD.md**: StreamProvider 패턴
- **Auth Feature**: Riverpod 2.x 활용 예시

---

## 📌 다음 단계

Phase 2 완료 후 **Phase 3: Cache Integration**으로 이동합니다.

**Phase 3 주요 작업**:
- SharedPreferences → UnifiedCacheService
- 3-Layer 캐싱 (Memory, Hive, Firestore)
- ILocalNotificationDatasource 제거

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
