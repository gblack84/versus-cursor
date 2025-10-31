import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_params.freezed.dart';

/// ChatListStreamProvider 파라미터
///
/// **사용 예시**:
/// ```dart
/// final params = ChatListParams(userId: 'user123', limit: 50);
/// final asyncChats = ref.watch(chatListStreamProvider(params));
/// ```
@freezed
sealed class ChatListParams with _$ChatListParams {
  const ChatListParams._();

  const factory ChatListParams({
    required String userId,
    @Default(50) int limit,
    @Default('lastMessageAt') String orderBy,
    @Default(true) bool descending,
  }) = _ChatListParams;
}

/// ChatMessagesStreamProvider 파라미터
///
/// **사용 예시**:
/// ```dart
/// final params = ChatMessagesParams(chatId: 'chat123', limit: 30);
/// final asyncMessages = ref.watch(chatMessagesStreamProvider(params));
/// ```
@freezed
sealed class ChatMessagesParams with _$ChatMessagesParams {
  const ChatMessagesParams._();

  const factory ChatMessagesParams({
    required String chatId,
    @Default(30) int limit,
    @Default('timestamp') String orderBy,
    @Default(true) bool descending,
  }) = _ChatMessagesParams;
}

/// GetRecommendedFriendsStreamProvider 파라미터
///
/// **사용 예시**:
/// ```dart
/// final params = RecommendedFriendsParams(currentUserId: 'user123', limit: 20);
/// final asyncFriends = ref.watch(recommendedFriendsStreamProvider(params));
/// ```
@freezed
sealed class RecommendedFriendsParams with _$RecommendedFriendsParams {
  const RecommendedFriendsParams._();

  const factory RecommendedFriendsParams({
    required String currentUserId,
    @Default(20) int limit,
    @Default('totalAPoints') String sortBy,
  }) = _RecommendedFriendsParams;
}

/// SearchFriendsStreamProvider 파라미터
///
/// **사용 예시**:
/// ```dart
/// final params = SearchFriendsParams(currentUserId: 'user123', query: 'John');
/// final asyncResults = ref.watch(searchFriendsStreamProvider(params));
/// ```
@freezed
sealed class SearchFriendsParams with _$SearchFriendsParams {
  const SearchFriendsParams._();

  const factory SearchFriendsParams({
    required String currentUserId,
    required String query,
  }) = _SearchFriendsParams;
}
