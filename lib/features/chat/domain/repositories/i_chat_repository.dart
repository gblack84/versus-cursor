import 'dart:io';

import '../entities/chat.dart';
import '../entities/message.dart';

/// Repository interface for Chat-related operations (Clean Architecture v4.0)
///
/// **Dependency Inversion Principle 적용**:
/// - Firestore 의존성 완전 제거
/// - 순수 Dart 타입만 사용
/// - Infrastructure 구현 세부사항은 Data Layer에서 처리
abstract class IChatRepository {
  // Chat queries (Clean Architecture v4.0: Pure Domain Entity 반환)
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  });

  // Message queries (Clean Architecture v4.0: Pure Domain Entity 반환)
  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  /// Load more messages before a specific message (Clean Architecture v4.0)
  ///
  /// 페이지네이션을 위해 특정 메시지 이전의 메시지들을 로드
  /// UseCase는 messageId만 전달, Repository에서 Firestore DocumentSnapshot 처리
  /// Pure Domain Entity 반환
  Future<List<Message>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  });

  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  });

  // TODO: Group chat features - 향후 구현 예정
  // Group chat, group messages, chat history는 별도 마이그레이션 필요
  // 현재는 1:1 채팅만 Clean Architecture v4.0 마이그레이션 완료

  // CRUD operations (Clean Architecture v4.0: Pure Domain Entity 사용)
  Future<Chat?> getChat(String chatId);
  Future<void> createChat(Chat chat);
  Future<void> updateChat(Chat chat);
  Future<void> deleteChat(String chatId);

  // Message operations (Clean Architecture v4.0: Pure Domain Entity 사용)
  Future<void> sendMessage(String chatId, Message message);
  Future<void> deleteMessage(String chatId, String messageId);

  // Media upload operations (Clean Architecture v4.0)
  /// 채팅 미디어(이미지/비디오) 업로드
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [messageId]: 메시지 ID
  /// - [file]: 업로드할 파일 (이미지 또는 비디오)
  /// - [mediaType]: 미디어 타입 ('image' or 'video')
  ///
  /// **Returns**:
  /// - Firebase Storage에 업로드된 미디어의 다운로드 URL
  ///
  /// **Implementation**:
  /// - Data Layer에서 ChatMediaUploadService 사용
  /// - 이미지: 자동 압축 (2MB 이하)
  /// - 비디오: 썸네일 자동 생성
  Future<String> uploadMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType,
  });

  // Friends management operations (Clean Architecture v4.0)
  /// 친구 추천 목록 조회
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID
  /// - [sortBy]: 정렬 기준 필드 (기본: 'totalAPoints')
  /// - [limit]: 조회할 최대 개수 (기본: 20)
  ///
  /// **Returns**:
  /// - 추천 친구 목록 Stream (totalAPoints 기준 상위 랭킹)
  Stream<List<dynamic>> getRecommendedFriends({
    required String currentUserId,
    String sortBy = 'totalAPoints',
    int limit = 20,
  });

  /// 사용자 검색
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID
  /// - [query]: 검색어 (displayName 검색)
  ///
  /// **Returns**:
  /// - 검색된 사용자 목록 Stream
  Stream<List<dynamic>> searchUsers({
    required String currentUserId,
    required String query,
  });

  /// 친구 요청 보내기
  ///
  /// **Parameters**:
  /// - [fromUserId]: 요청 보내는 사용자 ID
  /// - [toUserId]: 요청 받는 사용자 ID
  ///
  /// **Returns**:
  /// - void (성공/실패는 Exception으로 처리)
  Future<void> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  });

  /// 사용자 팔로우
  ///
  /// **Parameters**:
  /// - [userId]: 팔로우하는 사용자 ID
  /// - [targetUserId]: 팔로우 대상 사용자 ID
  Future<void> followUser(String userId, String targetUserId);

  /// 사용자 언팔로우
  ///
  /// **Parameters**:
  /// - [userId]: 언팔로우하는 사용자 ID
  /// - [targetUserId]: 언팔로우 대상 사용자 ID
  Future<void> unfollowUser(String userId, String targetUserId);

  /// 팔로우 여부 확인
  ///
  /// **Parameters**:
  /// - [userId]: 확인하는 사용자 ID
  /// - [targetUserId]: 확인 대상 사용자 ID
  ///
  /// **Returns**:
  /// - true: 이미 팔로우 중, false: 팔로우 안 함
  Future<bool> isFollowing(String userId, String targetUserId);
}
