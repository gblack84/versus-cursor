import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/notification.dart';
import '../../domain/usecases/watch_user_notifications_usecase.dart';
import '../../domain/usecases/watch_unread_count_usecase.dart';
import '../../domain/usecases/get_user_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';

part 'notification_providers.g.dart';

// ========== UseCase Providers ==========

/// WatchUserNotificationsUseCase Provider
///
/// GetIt DI에서 UseCase 인스턴스를 가져옵니다.
@riverpod
WatchUserNotificationsUseCase watchUserNotificationsUseCase(Ref ref) {
  return GetIt.instance<WatchUserNotificationsUseCase>();
}

/// WatchUnreadCountUseCase Provider
///
/// GetIt DI에서 UseCase 인스턴스를 가져옵니다.
@riverpod
WatchUnreadCountUseCase watchUnreadCountUseCase(Ref ref) {
  return GetIt.instance<WatchUnreadCountUseCase>();
}

/// GetUserNotificationsUseCase Provider
///
/// GetIt DI에서 UseCase 인스턴스를 가져옵니다.
@riverpod
GetUserNotificationsUseCase getUserNotificationsUseCase(Ref ref) {
  return GetIt.instance<GetUserNotificationsUseCase>();
}

/// MarkAsReadUseCase Provider
///
/// GetIt DI에서 UseCase 인스턴스를 가져옵니다.
@riverpod
MarkAsReadUseCase markAsReadUseCase(Ref ref) {
  return GetIt.instance<MarkAsReadUseCase>();
}

/// SendNotificationUseCase Provider
///
/// GetIt DI에서 UseCase 인스턴스를 가져옵니다.
@riverpod
SendNotificationUseCase sendNotificationUseCase(Ref ref) {
  return GetIt.instance<SendNotificationUseCase>();
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
  Ref ref,
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
  Ref ref,
  String userId,
) {
  final usecase = ref.watch(watchUnreadCountUseCaseProvider);
  return usecase(userId);
}

// ========== 타입별 필터링 Providers ==========

/// Social 알림만 필터링
///
/// **사용 예시**: 소셜 알림 전용 화면
/// **반환 타입**: Notification 리스트 (런타임에 SocialNotification만 포함)
@riverpod
Stream<List<Notification>> watchSocialNotifications(
  Ref ref,
  String userId,
) {
  final usecase = ref.watch(watchUserNotificationsUseCaseProvider);

  // UseCase에서 스트림을 가져와 필터링
  return usecase(userId).asyncMap((notifications) {
    return notifications
        .whereType<SocialNotification>()
        .cast<Notification>()
        .toList();
  });
}

/// System 알림만 필터링
///
/// **사용 예시**: 시스템 공지 화면
/// **반환 타입**: Notification 리스트 (런타임에 SystemNotification만 포함)
@riverpod
Stream<List<Notification>> watchSystemNotifications(
  Ref ref,
  String userId,
) {
  final usecase = ref.watch(watchUserNotificationsUseCaseProvider);

  return usecase(userId).asyncMap((notifications) {
    return notifications
        .whereType<SystemNotification>()
        .cast<Notification>()
        .toList();
  });
}

/// Voting 알림만 필터링
///
/// **사용 예시**: 투표 요청 화면
/// **반환 타입**: Notification 리스트 (런타임에 VotingNotification만 포함)
@riverpod
Stream<List<Notification>> watchVotingNotifications(
  Ref ref,
  String userId,
) {
  final usecase = ref.watch(watchUserNotificationsUseCaseProvider);

  return usecase(userId).asyncMap((notifications) {
    return notifications
        .whereType<VotingNotification>()
        .cast<Notification>()
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
  Ref ref,
  GetUserNotificationsParams params,
) async {
  final usecase = ref.watch(getUserNotificationsUseCaseProvider);
  final result = await usecase(params);

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
/// await ref.read(markAsReadNotifierProvider.notifier).call(
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

  /// 알림 전송 실행
  Future<void> call(SendNotificationParams params) async {
    state = const AsyncLoading();

    final usecase = ref.read(sendNotificationUseCaseProvider);
    final result = await usecase(params);

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
