import 'package:riverpod_annotation/riverpod_annotation.dart';

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

part 'chat_providers.g.dart';

// ========================================
// UseCase Providers (GetIt Wrapping)
// ========================================

/// GetIt에 등록된 GetChatListUseCase를 Riverpod Provider로 제공
@riverpod
GetChatListUseCase getChatListUseCase(Ref ref) {
  return getIt<GetChatListUseCase>();
}

/// GetIt에 등록된 GetChatMessagesUseCase를 Riverpod Provider로 제공
@riverpod
GetChatMessagesUseCase getChatMessagesUseCase(Ref ref) {
  return getIt<GetChatMessagesUseCase>();
}

/// GetIt에 등록된 LoadMoreMessagesUseCase를 Riverpod Provider로 제공
@riverpod
LoadMoreMessagesUseCase loadMoreMessagesUseCase(Ref ref) {
  return getIt<LoadMoreMessagesUseCase>();
}

/// GetIt에 등록된 SendMessageUseCase를 Riverpod Provider로 제공
@riverpod
SendMessageUseCase sendMessageUseCase(Ref ref) {
  return getIt<SendMessageUseCase>();
}

/// GetIt에 등록된 SearchMessagesUseCase를 Riverpod Provider로 제공
@riverpod
SearchMessagesUseCase searchMessagesUseCase(Ref ref) {
  return getIt<SearchMessagesUseCase>();
}

/// GetIt에 등록된 SendAIQueryUseCase를 Riverpod Provider로 제공
@riverpod
SendAIQueryUseCase sendAIQueryUseCase(Ref ref) {
  return getIt<SendAIQueryUseCase>();
}

/// GetIt에 등록된 GetRecommendedFriendsUseCase를 Riverpod Provider로 제공
@riverpod
GetRecommendedFriendsUseCase getRecommendedFriendsUseCase(Ref ref) {
  return getIt<GetRecommendedFriendsUseCase>();
}

/// GetIt에 등록된 SearchFriendsUseCase를 Riverpod Provider로 제공
@riverpod
SearchFriendsUseCase searchFriendsUseCase(Ref ref) {
  return getIt<SearchFriendsUseCase>();
}

/// GetIt에 등록된 SendFriendRequestUseCase를 Riverpod Provider로 제공
@riverpod
SendFriendRequestUseCase sendFriendRequestUseCase(Ref ref) {
  return getIt<SendFriendRequestUseCase>();
}

/// GetIt에 등록된 ToggleFollowUseCase를 Riverpod Provider로 제공
@riverpod
ToggleFollowUseCase toggleFollowUseCase(Ref ref) {
  return getIt<ToggleFollowUseCase>();
}

// ========================================
// Service Providers
// ========================================

/// GetIt에 등록된 ChatMessageLifecycleService를 Riverpod Provider로 제공
@riverpod
ChatMessageLifecycleService chatMessageLifecycleService(Ref ref) {
  return getIt<ChatMessageLifecycleService>();
}

/// GetIt에 등록된 IAIService를 Riverpod Provider로 제공
@riverpod
IAIService aiService(Ref ref) {
  return getIt<IAIService>();
}

// ========================================
// Stream Providers
// ========================================

/// 채팅 목록 실시간 스트림 Provider
///
/// **Riverpod 3.x Stream 패턴**:
/// - @riverpod 어노테이션으로 StreamProvider 자동 생성
/// - family 파라미터 자동 처리 (params)
/// - autoDispose 기본 활성화
/// - ref.keepAlive()로 중복 리스너 방지
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
@riverpod
Stream<List<Chat>> chatListStream(
  Ref ref,
  ChatListParams params,
) async* {
  // UseCase를 통한 실시간 스트림 (캐시 우선 응답)
  final getChatListUseCase = ref.watch(getChatListUseCaseProvider);

  await for (final either in getChatListUseCase.execute(
    userId: params.userId,
    limit: params.limit,
  )) {
    // Either → Stream 변환
    yield* either.fold(
      (failure) => Stream<List<Chat>>.error(failure), // Left: Error
      (chats) async* {
        yield chats; // Right: Success
      },
    );
  }

  // keepAlive로 중복 리스너 방지
  ref.keepAlive();
}

/// 채팅 메시지 실시간 스트림 Provider
///
/// **동일한 Riverpod 3.x 패턴 적용**:
/// - @riverpod로 자동 StreamProvider 생성
/// - autoDispose로 자동 메모리 관리
/// - keepAlive()로 화면 전환 시에도 Stream 유지
@riverpod
Stream<List<Message>> chatMessagesStream(
  Ref ref,
  ChatMessagesParams params,
) async* {
  // UseCase를 통한 실시간 스트림 (캐시 우선 응답)
  final getChatMessagesUseCase = ref.watch(getChatMessagesUseCaseProvider);

  await for (final either in getChatMessagesUseCase.execute(
    chatId: params.chatId,
    limit: params.limit,
  )) {
    // Either → Stream 변환
    yield* either.fold(
      (failure) => Stream<List<Message>>.error(failure),
      (messages) async* {
        yield messages;
      },
    );
  }

  // keepAlive
  ref.keepAlive();
}

/// 추천 친구 목록 실시간 스트림 Provider
///
/// **Riverpod 3.x Stream 패턴**:
/// - @riverpod로 StreamProvider 자동 생성
/// - family 파라미터 자동 처리
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
@riverpod
Stream<List<UserProfile>> recommendedFriendsStream(
  Ref ref,
  RecommendedFriendsParams params,
) async* {
  final getRecommendedFriendsUseCase =
      ref.watch(getRecommendedFriendsUseCaseProvider);

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
}

/// 친구 검색 실시간 스트림 Provider
///
/// **동일한 Riverpod 3.x 패턴 적용**:
/// - @riverpod로 자동 StreamProvider 생성
/// - autoDispose로 자동 메모리 관리
/// - keepAlive()로 화면 전환 시에도 Stream 유지
///
/// **사용 예시**:
/// ```dart
/// final asyncResults = ref.watch(searchFriendsStreamProvider(
///   SearchFriendsParams(currentUserId: currentUserUid, query: 'John'),
/// ));
/// ```
@riverpod
Stream<List<UserProfile>> searchFriendsStream(
  Ref ref,
  SearchFriendsParams params,
) async* {
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
}

// ========================================
// Computed Providers
// ========================================

/// 읽지 않은 채팅 개수 Provider
///
/// **Riverpod 3.x Computed Provider 패턴**:
/// - @riverpod로 자동 Provider 생성
/// - chatListStream을 watch하여 자동 업데이트
/// - 읽지 않은 채팅만 필터링
@riverpod
int unreadChatCount(Ref ref, String userId) {
  final asyncChats = ref.watch(chatListStreamProvider(
    ChatListParams(userId: userId, limit: 50),
  ));

  return asyncChats.when(
    data: (chats) => chats.where((chat) => !chat.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
}

/// AI 채팅방 찾기 Provider
///
/// **Riverpod 3.x Computed Provider 패턴**:
/// - @riverpod로 자동 Provider 생성
/// - AI 채팅방만 필터링
/// - 없으면 null 반환
@riverpod
Chat? aiChat(Ref ref, String userId) {
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
}
