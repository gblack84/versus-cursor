import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/app/di.dart';
import '/features/chat/domain/entities/chat.dart';
import '/features/chat/domain/entities/message.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/chat/domain/usecases/get_chat_list_usecase.dart';
import '/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '/features/chat/domain/usecases/load_more_messages_usecase.dart';
import '/features/chat/domain/usecases/send_message_usecase.dart';
import '/features/chat/domain/usecases/search_messages_usecase.dart';
import '/features/chat/domain/usecases/send_ai_query_usecase.dart';
import '/features/chat/domain/usecases/get_recommended_friends_usecase.dart';
import '/features/chat/domain/usecases/search_friends_usecase.dart';
import '/features/chat/domain/usecases/send_friend_request_usecase.dart';
import '/features/chat/domain/usecases/toggle_follow_usecase.dart';
import '/features/chat/data/services/chat_message_lifecycle_service.dart';
import '/features/chat/domain/ports/i_ai_service.dart';
import '/core/constants/app_constants.dart';
import 'chat_params.dart';

// ========================================
// UseCase Providers (GetIt Wrapping)
// ========================================

/// GetIt에 등록된 GetChatListUseCase를 Riverpod Provider로 제공
final getChatListUseCaseProvider = Provider<GetChatListUseCase>((ref) {
  return getIt<GetChatListUseCase>();
});

/// GetIt에 등록된 GetChatMessagesUseCase를 Riverpod Provider로 제공
final getChatMessagesUseCaseProvider = Provider<GetChatMessagesUseCase>((ref) {
  return getIt<GetChatMessagesUseCase>();
});

/// GetIt에 등록된 LoadMoreMessagesUseCase를 Riverpod Provider로 제공
final loadMoreMessagesUseCaseProvider = Provider<LoadMoreMessagesUseCase>((ref) {
  return getIt<LoadMoreMessagesUseCase>();
});

/// GetIt에 등록된 SendMessageUseCase를 Riverpod Provider로 제공
final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return getIt<SendMessageUseCase>();
});

/// GetIt에 등록된 SearchMessagesUseCase를 Riverpod Provider로 제공
final searchMessagesUseCaseProvider = Provider<SearchMessagesUseCase>((ref) {
  return getIt<SearchMessagesUseCase>();
});

/// GetIt에 등록된 SendAIQueryUseCase를 Riverpod Provider로 제공
final sendAIQueryUseCaseProvider = Provider<SendAIQueryUseCase>((ref) {
  return getIt<SendAIQueryUseCase>();
});

/// GetIt에 등록된 ChatMessageLifecycleService를 Riverpod Provider로 제공
final chatMessageLifecycleServiceProvider = Provider<ChatMessageLifecycleService>((ref) {
  return getIt<ChatMessageLifecycleService>();
});

/// GetIt에 등록된 IAIService를 Riverpod Provider로 제공
final aiServiceProvider = Provider<IAIService>((ref) {
  return getIt<IAIService>();
});

// ========== Chat List Stream Provider ==========

/// 채팅 목록 실시간 스트림 Provider
///
/// **Riverpod StreamProvider.autoDispose.family 패턴 적용**:
/// - StreamProvider.autoDispose.family
/// - 즉시 emit으로 로딩 개선
/// - keepAlive()로 중복 리스너 방지
///
/// **사용 예시**:
/// ```dart
/// final asyncChats = ref.watch(chatListStreamProvider(
///   ChatListParams(userId: currentUserUid, limit: 50),
/// ));
///
/// asyncChats.when(
///   data: (chats) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error: error),
/// );
/// ```
final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    // UseCase를 통한 실시간 스트림 (캐시 우선 응답)
    // Note: getChatListUseCaseProvider는 Step 5에서 정의됨
    final getChatListUseCase = ref.watch(getChatListUseCaseProvider);

    await for (final either in getChatListUseCase.execute(
      userId: params.userId,
      limit: params.limit,
    )) {
      // 3. Either → Stream 변환
      yield* either.fold(
        (failure) => Stream<List<Chat>>.error(failure), // Left: Error
        (chats) async* {
          yield chats; // Right: Success
        },
      );
    }

    // 4. keepAlive로 중복 리스너 방지
    ref.keepAlive();
  },
);

// ========== Chat Messages Stream Provider ==========

/// 채팅 메시지 실시간 스트림 Provider
///
/// **동일한 패턴 적용**:
/// - autoDispose로 자동 메모리 관리
/// - keepAlive()로 화면 전환 시에도 Stream 유지
final chatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<Message>, ChatMessagesParams>(
  (ref, params) async* {
    // UseCase를 통한 실시간 스트림 (캐시 우선 응답)
    final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);

    await for (final either in getChatMessagesUseCase.execute(
      chatId: params.chatId,
      limit: params.limit,
    )) {
      // 3. Either → Stream 변환
      yield* either.fold(
        (failure) => Stream<List<Message>>.error(failure),
        (messages) async* {
          yield messages;
        },
      );
    }

    // 4. keepAlive
    ref.keepAlive();
  },
);

// ========== Computed Providers ==========

/// 읽지 않은 채팅 개수 Provider
///
/// **Computed Provider 패턴**:
/// - chatListStreamProvider를 watch하여 자동 업데이트
/// - 읽지 않은 채팅만 필터링
final unreadChatCountProvider = Provider.autoDispose.family<int, String>(
  (ref, userId) {
    final asyncChats = ref.watch(chatListStreamProvider(
      ChatListParams(userId: userId, limit: 50),
    ));

    return asyncChats.when(
      data: (chats) => chats.where((chat) => !chat.isRead).length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  },
);

/// AI 채팅방 찾기 Provider
///
/// **Computed Provider 패턴**:
/// - AI 채팅방만 필터링
/// - 없으면 null 반환
final aiChatProvider = Provider.autoDispose.family<Chat?, String>(
  (ref, userId) {
    final asyncChats = ref.watch(chatListStreamProvider(
      ChatListParams(userId: userId, limit: 50),
    ));

    return asyncChats.when(
      data: (chats) {
        try {
          return chats.firstWhere(
            (chat) =>
                chat.participantIds.contains(AppConstants.aiUserId) ||
                chat.chatType == 'aiChat',
          );
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (_, __) => null,
    );
  },
);

// ========================================
// Friends Management - UseCase Providers
// ========================================

/// GetIt에 등록된 GetRecommendedFriendsUseCase를 Riverpod Provider로 제공
final getRecommendedFriendsUseCaseProvider = Provider<GetRecommendedFriendsUseCase>((ref) {
  return getIt<GetRecommendedFriendsUseCase>();
});

/// GetIt에 등록된 SearchFriendsUseCase를 Riverpod Provider로 제공
final searchFriendsUseCaseProvider = Provider<SearchFriendsUseCase>((ref) {
  return getIt<SearchFriendsUseCase>();
});

/// GetIt에 등록된 SendFriendRequestUseCase를 Riverpod Provider로 제공
final sendFriendRequestUseCaseProvider = Provider<SendFriendRequestUseCase>((ref) {
  return getIt<SendFriendRequestUseCase>();
});

/// GetIt에 등록된 ToggleFollowUseCase를 Riverpod Provider로 제공
final toggleFollowUseCaseProvider = Provider<ToggleFollowUseCase>((ref) {
  return getIt<ToggleFollowUseCase>();
});

// ========================================
// Friends Management - Stream Providers
// ========================================

/// 추천 친구 목록 실시간 스트림 Provider
///
/// **Riverpod StreamProvider.autoDispose.family 패턴 적용**:
/// - StreamProvider.autoDispose.family
/// - Either → Stream 변환
/// - keepAlive()로 중복 리스너 방지
///
/// **사용 예시**:
/// ```dart
/// final asyncFriends = ref.watch(recommendedFriendsStreamProvider(
///   RecommendedFriendsParams(currentUserId: currentUserUid, limit: 20),
/// ));
///
/// asyncFriends.when(
///   data: (friends) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => ErrorWidget(error: error),
/// );
/// ```
final recommendedFriendsStreamProvider =
    StreamProvider.autoDispose.family<List<UserProfile>, RecommendedFriendsParams>(
  (ref, params) async* {
    final getRecommendedFriendsUseCase = ref.watch(getRecommendedFriendsUseCaseProvider);

    await for (final either in getRecommendedFriendsUseCase.execute(
      currentUserId: params.currentUserId,
      limit: params.limit,
    )) {
      yield* either.fold(
        (failure) => Stream<List<UserProfile>>.error(failure),
        (friends) async* {
          yield friends;
        },
      );
    }

    ref.keepAlive();
  },
);

/// 친구 검색 실시간 스트림 Provider
///
/// **동일한 패턴 적용**:
/// - autoDispose로 자동 메모리 관리
/// - keepAlive()로 화면 전환 시에도 Stream 유지
///
/// **사용 예시**:
/// ```dart
/// final asyncResults = ref.watch(searchFriendsStreamProvider(
///   SearchFriendsParams(currentUserId: currentUserUid, query: 'John'),
/// ));
/// ```
final searchFriendsStreamProvider =
    StreamProvider.autoDispose.family<List<UserProfile>, SearchFriendsParams>(
  (ref, params) async* {
    final searchFriendsUseCase = ref.watch(searchFriendsUseCaseProvider);

    await for (final either in searchFriendsUseCase.execute(
      currentUserId: params.currentUserId,
      query: params.query,
    )) {
      yield* either.fold(
        (failure) => Stream<List<UserProfile>>.error(failure),
        (results) async* {
          yield results;
        },
      );
    }

    ref.keepAlive();
  },
);

