import 'dart:io';

import 'package:dartz/dartz.dart';

import '../entities/chat.dart';
import '../entities/message.dart';
import '../failures/chat_failure.dart';

/// Repository interface for Chat-related operations (Clean Architecture v4.0)
///
/// **Dependency Inversion Principle 적용**:
/// - Firestore 의존성 완전 제거
/// - 순수 Dart 타입만 사용
/// - Infrastructure 구현 세부사항은 Data Layer에서 처리
///
/// **Phase 4 - Idempotency & CRUD Cleanup**:
/// - Either 패턴 적용 (명시적 에러 처리)
/// - eventId 파라미터 추가 (중복 방지)
/// - Transaction 기반 CRUD (서브컬렉션 정리)
abstract class IChatRepository {
  // Chat queries (Clean Architecture v4.0 + Phase 1: Either Pattern)
  /// 채팅 목록 실시간 스트림 (Phase 1: Either Pattern 완료)
  ///
  /// **Parameters**:
  /// - [userId]: 현재 사용자 ID (participantIds 필터링)
  /// - [limit]: 한 번에 로드할 채팅 개수 (기본값: 50)
  /// - [orderBy]: 정렬 기준 필드 (기본값: 'lastMessageAt')
  /// - [descending]: 내림차순 정렬 여부 (기본값: true)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Chat>>>`:
  ///   - Left: ChatFailure (캐시/네트워크 에러, ChatLoadFailed)
  ///   - Right: List<Chat> (성공)
  ///
  /// **Phase 3 Integration**: 3-Layer Cache-First 패턴 적용
  /// - L1 Memory → L2 Hive → L3 Firestore 순으로 조회
  /// - 캐시 히트 시 즉시 emit (10ms 이내)
  /// - Firestore 스트림으로 실시간 업데이트
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  });

  // Message queries (Clean Architecture v4.0 + Phase 1: Either Pattern)
  /// 채팅 메시지 실시간 스트림 (Phase 1: Either Pattern 완료)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [limit]: 한 번에 로드할 메시지 개수 (기본값: 30)
  /// - [orderBy]: 정렬 기준 필드 (기본값: 'timeStamp')
  /// - [descending]: 내림차순 정렬 여부 (기본값: true)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Message>>>`:
  ///   - Left: ChatFailure (캐시/네트워크 에러, MessageLoadFailed)
  ///   - Right: List<Message> (성공)
  ///
  /// **Phase 3 Integration**: 3-Layer Cache-First 패턴 적용
  /// - L1 Memory → L2 Hive → L3 Firestore 순으로 조회
  /// - 캐시 히트 시 즉시 emit (10ms 이내)
  /// - Firestore 스트림으로 실시간 업데이트
  Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({
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

  // ========== CRUD operations (Phase 4: Either Pattern + Idempotency) ==========

  /// 채팅 조회
  ///
  /// **Returns**: Either<ChatFailure, Chat>
  /// - Left: 채팅을 찾을 수 없음 (ChatNotFound)
  /// - Right: 채팅 엔티티
  Future<Either<ChatFailure, Chat>> getChat(String chatId);

  /// 채팅 생성 (중복 방지)
  ///
  /// **Parameters**:
  /// - [chat]: 생성할 채팅 엔티티
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  /// - IdempotencyService로 중복 생성 방지
  /// - Transaction으로 원자성 보장
  Future<Either<ChatFailure, Unit>> createChat({
    required Chat chat,
    required String eventId,
  });

  /// 채팅 업데이트 (중복 방지)
  ///
  /// **Parameters**:
  /// - [chat]: 업데이트할 채팅 엔티티
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  Future<Either<ChatFailure, Unit>> updateChat({
    required Chat chat,
    required String eventId,
  });

  /// 채팅 삭제 (서브컬렉션 포함, 중복 방지)
  ///
  /// **Parameters**:
  /// - [chatId]: 삭제할 채팅 ID
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  ///
  /// **Phase 4 - Complete Cleanup**:
  /// - messages 서브컬렉션 삭제
  /// - participants 서브컬렉션 삭제
  /// - chat 문서 삭제
  /// - Transaction으로 원자성 보장 (일부 실패 시 전체 롤백)
  Future<Either<ChatFailure, Unit>> deleteChat({
    required String chatId,
    required String eventId,
  });

  // ========== Message operations (Phase 4: Either Pattern + Idempotency) ==========

  /// 메시지 전송 (중복 방지)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [message]: 전송할 메시지 엔티티
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 전송 방지용)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  ///
  /// **Phase 4 - IdempotencyService Integration**:
  /// - 동일 eventId 재시도: 작업 스킵 (네트워크 재시도)
  /// - 다른 eventId 중복: IdempotencyViolation 발생
  /// - Transaction으로 메시지 + lastMessageAt 원자적 업데이트
  Future<Either<ChatFailure, Unit>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId,
  });

  /// 메시지 삭제 (중복 방지)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [messageId]: 삭제할 메시지 ID
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  Future<Either<ChatFailure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
    required String eventId,
  });

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

  // Friends management operations (Clean Architecture v4.0 + Phase 1: Either Pattern)
  /// 친구 추천 목록 조회 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID
  /// - [sortBy]: 정렬 기준 필드 (기본: 'totalAPoints')
  /// - [limit]: 조회할 최대 개수 (기본: 20)
  ///
  /// **Returns**:
  /// - Stream<Either<ChatFailure, List<UserProfile>>>
  ///   - Left: FriendLoadFailed (로드 실패)
  ///   - Right: List<UserProfile> (추천 친구 목록)
  Stream<Either<ChatFailure, List<dynamic>>> getRecommendedFriends({
    required String currentUserId,
    String sortBy = 'totalAPoints',
    int limit = 20,
  });

  /// 사용자 검색 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID
  /// - [query]: 검색어 (displayName 검색)
  ///
  /// **Returns**:
  /// - Stream<Either<ChatFailure, List<UserProfile>>>
  ///   - Left: SearchFailed (검색 실패)
  ///   - Right: List<UserProfile> (검색된 사용자 목록)
  Stream<Either<ChatFailure, List<dynamic>>> searchUsers({
    required String currentUserId,
    required String query,
  });

  /// 친구 요청 보내기 (Phase 1: Either Pattern + Idempotency)
  ///
  /// **Parameters**:
  /// - [fromUserId]: 요청 보내는 사용자 ID
  /// - [toUserId]: 요청 받는 사용자 ID
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**:
  /// - Either<ChatFailure, Unit>
  ///   - Left: FriendRequestFailed (친구 요청 실패)
  ///   - Right: Unit (성공)
  Future<Either<ChatFailure, Unit>> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
    required String eventId,
  });

  /// 사용자 팔로우 (Phase 1: Either Pattern + Idempotency)
  ///
  /// **Parameters**:
  /// - [userId]: 팔로우하는 사용자 ID
  /// - [targetUserId]: 팔로우 대상 사용자 ID
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**:
  /// - Either<ChatFailure, Unit>
  ///   - Left: FollowToggleFailed (팔로우 실패)
  ///   - Right: Unit (성공)
  Future<Either<ChatFailure, Unit>> followUser({
    required String userId,
    required String targetUserId,
    required String eventId,
  });

  /// 사용자 언팔로우 (Phase 1: Either Pattern + Idempotency)
  ///
  /// **Parameters**:
  /// - [userId]: 언팔로우하는 사용자 ID
  /// - [targetUserId]: 언팔로우 대상 사용자 ID
  /// - [eventId]: UUID v4 (클라이언트 생성, 중복 방지용)
  ///
  /// **Returns**:
  /// - Either<ChatFailure, Unit>
  ///   - Left: FollowToggleFailed (언팔로우 실패)
  ///   - Right: Unit (성공)
  Future<Either<ChatFailure, Unit>> unfollowUser({
    required String userId,
    required String targetUserId,
    required String eventId,
  });

  /// 팔로우 여부 확인 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [userId]: 확인하는 사용자 ID
  /// - [targetUserId]: 확인 대상 사용자 ID
  ///
  /// **Returns**:
  /// - Either<ChatFailure, bool>
  ///   - Left: Unexpected (조회 실패)
  ///   - Right: bool (true: 팔로우 중, false: 팔로우 안 함)
  Future<Either<ChatFailure, bool>> isFollowing({
    required String userId,
    required String targetUserId,
  });
}
