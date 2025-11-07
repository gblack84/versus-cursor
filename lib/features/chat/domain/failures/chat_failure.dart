import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failures.dart';

part 'chat_failure.freezed.dart';

/// Chat Feature Failures
///
/// Domain Layer - 채팅 관련 실패 케이스 정의
/// Freezed Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
/// - Core Failure 인터페이스 구현으로 Either<T> 호환성 확보
///
/// **16개 Failure 타입**:
/// - Message Errors (4): MessageSendFailed, MessageLoadFailed, MessageDeleteFailed, InvalidMessageContent
/// - Chat Room Errors (3): ChatNotFound, ChatCreationFailed, ChatLoadFailed
/// - Participant Errors (2): ParticipantNotFound, ParticipantLoadFailed
/// - AI Errors (3): AIQueryFailed, AIStreamingError, AINotInitialized
/// - Search Errors (1): SearchFailed
/// - Friend System Errors (3): FriendRequestFailed, FriendLoadFailed, FollowToggleFailed
/// - Network & Permission Errors (3): NetworkError, PermissionDenied, ServerError
/// - Generic Error (1): Unexpected
///
/// **사용 현황 (8/16 사용 중)**:
/// ✅ MessageSendFailed, InvalidMessageContent, ChatNotFound, ChatCreationFailed
/// ✅ AIQueryFailed, SearchFailed, FriendLoadFailed, Unexpected
/// ⏳ TODO: MessageLoadFailed, MessageDeleteFailed, ChatLoadFailed, ParticipantNotFound
/// ⏳ TODO: ParticipantLoadFailed, AIStreamingError, AINotInitialized, FriendRequestFailed, FollowToggleFailed
@freezed
sealed class ChatFailure with _$ChatFailure implements Failure {
  const ChatFailure._();

  // Equatable implementation (required by Failure interface)
  @override
  List<Object?> get props => [message, code];

  @override
  String? get code => null;

  @override
  bool? get stringify => true;

  // ========== Message Errors ==========

  /// 메시지 전송 실패
  ///
  /// **사용 위치**:
  /// - Repository: sendMessage (L516)
  /// - UseCase: SendMessageUseCase
  const factory ChatFailure.messageSendFailed() = MessageSendFailed;

  /// 메시지 로드 실패
  ///
  /// **TODO**: Stream 에러 처리 시 사용 예정
  const factory ChatFailure.messageLoadFailed() = MessageLoadFailed;

  /// 메시지 삭제 실패
  ///
  /// **TODO**: 메시지 삭제 기능 구현 시 사용 예정
  const factory ChatFailure.messageDeleteFailed() = MessageDeleteFailed;

  /// 유효하지 않은 메시지 내용
  ///
  /// **사용 위치**:
  /// - UseCase: SendMessageUseCase (L73, L78)
  /// - UseCase: SendAIQueryUseCase (L55)
  const factory ChatFailure.invalidMessageContent() = InvalidMessageContent;

  // ========== Chat Room Errors ==========

  /// 채팅방을 찾을 수 없음
  ///
  /// **사용 위치**:
  /// - Repository: getChat (L279)
  /// - Repository: deleteChat (L395)
  /// - Repository: sendMessage (L477)
  const factory ChatFailure.chatNotFound() = ChatNotFound;

  /// 채팅방 생성 실패
  ///
  /// **사용 위치**:
  /// - Repository: createChat (L326)
  const factory ChatFailure.chatCreationFailed() = ChatCreationFailed;

  /// 채팅방 목록 로드 실패
  ///
  /// **TODO**: Stream 에러 처리 시 사용 예정
  const factory ChatFailure.chatLoadFailed() = ChatLoadFailed;

  // ========== Participant Errors ==========

  /// 참여자를 찾을 수 없음
  ///
  /// **TODO**: 참여자 관리 기능 구현 시 사용 예정
  const factory ChatFailure.participantNotFound() = ParticipantNotFound;

  /// 참여자 정보 로드 실패
  ///
  /// **TODO**: 참여자 관리 기능 구현 시 사용 예정
  const factory ChatFailure.participantLoadFailed() = ParticipantLoadFailed;

  // ========== AI Errors ==========

  /// AI 쿼리 실패
  ///
  /// **사용 위치**:
  /// - UseCase: SendAIQueryUseCase (L63)
  const factory ChatFailure.aiQueryFailed() = AIQueryFailed;

  /// AI 스트리밍 오류
  ///
  /// **TODO**: AI 스트리밍 중 에러 처리 시 사용 예정
  const factory ChatFailure.aiStreamingError() = AIStreamingError;

  /// AI 서비스 초기화 안 됨
  ///
  /// **TODO**: AI 초기화 검증 시 사용 예정
  const factory ChatFailure.aiNotInitialized() = AINotInitialized;

  // ========== Search Errors ==========

  /// 검색 실패
  ///
  /// **사용 위치**:
  /// - Repository: searchUsers (L640)
  const factory ChatFailure.searchFailed() = SearchFailed;

  // ========== Friend System Errors ==========

  /// 친구 요청 실패
  ///
  /// **TODO**: sendFriendRequest 구현 시 사용 예정
  const factory ChatFailure.friendRequestFailed() = FriendRequestFailed;

  /// 친구 목록 로드 실패
  ///
  /// **사용 위치**:
  /// - Repository: getRecommendedFriends (L612)
  const factory ChatFailure.friendLoadFailed() = FriendLoadFailed;

  /// 팔로우 토글 실패
  ///
  /// **TODO**: followUser/unfollowUser 구현 시 사용 예정
  const factory ChatFailure.followToggleFailed() = FollowToggleFailed;

  // ========== Network & Permission Errors ==========

  /// 네트워크 오류
  ///
  /// **사용 예시**: FirebaseException (unavailable, deadline-exceeded)
  const factory ChatFailure.networkError() = NetworkError;

  /// 권한 없음
  ///
  /// **사용 예시**: FirebaseException (permission-denied, unauthenticated)
  const factory ChatFailure.permissionDenied() = PermissionDenied;

  /// 서버 오류
  ///
  /// **사용 예시**: FirebaseException (기타 오류)
  const factory ChatFailure.serverError() = ServerError;

  // ========== Generic Error ==========

  /// 예기치 않은 오류
  ///
  /// **사용 위치**: Repository (모든 catch 블록), UseCase
  const factory ChatFailure.unexpected([String? errorMessage]) = Unexpected;

  /// Convert to user-friendly message (Implements Failure.message)
  @override
  String get message {
    return when(
      messageSendFailed: () => '메시지 전송에 실패했습니다',
      messageLoadFailed: () => '메시지를 불러오는데 실패했습니다',
      messageDeleteFailed: () => '메시지 삭제에 실패했습니다',
      invalidMessageContent: () => '유효하지 않은 메시지 내용입니다',
      chatNotFound: () => '채팅방을 찾을 수 없습니다',
      chatCreationFailed: () => '채팅방 생성에 실패했습니다',
      chatLoadFailed: () => '채팅방 목록을 불러오는데 실패했습니다',
      participantNotFound: () => '참여자를 찾을 수 없습니다',
      participantLoadFailed: () => '참여자 정보를 불러오는데 실패했습니다',
      aiQueryFailed: () => 'AI 질문에 실패했습니다',
      aiStreamingError: () => 'AI 응답 생성 중 오류가 발생했습니다',
      aiNotInitialized: () => 'AI 서비스가 초기화되지 않았습니다',
      searchFailed: () => '검색에 실패했습니다',
      friendRequestFailed: () => '친구 요청에 실패했습니다',
      friendLoadFailed: () => '친구 목록을 불러오는데 실패했습니다',
      followToggleFailed: () => '팔로우 처리에 실패했습니다',
      networkError: () => '네트워크 연결 오류가 발생했습니다',
      permissionDenied: () => '권한이 없습니다',
      serverError: () => '서버 오류가 발생했습니다',
      unexpected: (errorMessage) =>
          errorMessage ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
