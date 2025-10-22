import '/core/errors/failures.dart';

/// Chat Failure
///
/// Domain Layer - 채팅 관련 실패 케이스 정의
/// Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Failure Pattern**:
/// - Sealed Class 패턴으로 타입 안전성 보장
/// - Core Failure 상속으로 Result<T> 호환성 확보
/// - Pattern Matching으로 누락 케이스 컴파일 체크
/// - 중앙 집중식 에러 메시지 관리
sealed class ChatFailure extends Failure {
  const ChatFailure() : super(message: '');

  /// Convert to user-friendly message (Override Failure.message)
  @override
  String get message {
    return switch (this) {
      // Message errors
      MessageSendFailed() => '메시지 전송에 실패했습니다',
      MessageLoadFailed() => '메시지를 불러오는데 실패했습니다',
      MessageDeleteFailed() => '메시지 삭제에 실패했습니다',
      InvalidMessageContent() => '유효하지 않은 메시지 내용입니다',

      // Chat room errors
      ChatNotFound() => '채팅방을 찾을 수 없습니다',
      ChatCreationFailed() => '채팅방 생성에 실패했습니다',
      ChatLoadFailed() => '채팅방 목록을 불러오는데 실패했습니다',

      // Participant errors
      ParticipantNotFound() => '참여자를 찾을 수 없습니다',
      ParticipantLoadFailed() => '참여자 정보를 불러오는데 실패했습니다',

      // AI errors
      AIQueryFailed() => 'AI 질문에 실패했습니다',
      AIStreamingError() => 'AI 응답 생성 중 오류가 발생했습니다',
      AINotInitialized() => 'AI 서비스가 초기화되지 않았습니다',

      // Search errors
      SearchFailed() => '검색에 실패했습니다',

      // Friend system errors
      FriendRequestFailed() => '친구 요청에 실패했습니다',
      FriendLoadFailed() => '친구 목록을 불러오는데 실패했습니다',
      FollowToggleFailed() => '팔로우 처리에 실패했습니다',

      // Network & Permission errors
      NetworkError() => '네트워크 연결 오류가 발생했습니다',
      PermissionDenied() => '권한이 없습니다',
      ServerError() => '서버 오류가 발생했습니다',

      // Generic error
      Unexpected(:final errorMessage) => errorMessage ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// ==================== Message Errors ====================

/// 메시지 전송 실패
class MessageSendFailed extends ChatFailure {
  const MessageSendFailed() : super();
}

/// 메시지 로드 실패
class MessageLoadFailed extends ChatFailure {
  const MessageLoadFailed() : super();
}

/// 메시지 삭제 실패
class MessageDeleteFailed extends ChatFailure {
  const MessageDeleteFailed() : super();
}

/// 유효하지 않은 메시지 내용
class InvalidMessageContent extends ChatFailure {
  const InvalidMessageContent() : super();
}

// ==================== Chat Room Errors ====================

/// 채팅방을 찾을 수 없음
class ChatNotFound extends ChatFailure {
  const ChatNotFound() : super();
}

/// 채팅방 생성 실패
class ChatCreationFailed extends ChatFailure {
  const ChatCreationFailed() : super();
}

/// 채팅방 목록 로드 실패
class ChatLoadFailed extends ChatFailure {
  const ChatLoadFailed() : super();
}

// ==================== Participant Errors ====================

/// 참여자를 찾을 수 없음
class ParticipantNotFound extends ChatFailure {
  const ParticipantNotFound() : super();
}

/// 참여자 정보 로드 실패
class ParticipantLoadFailed extends ChatFailure {
  const ParticipantLoadFailed() : super();
}

// ==================== AI Errors ====================

/// AI 쿼리 실패
class AIQueryFailed extends ChatFailure {
  const AIQueryFailed() : super();
}

/// AI 스트리밍 오류
class AIStreamingError extends ChatFailure {
  const AIStreamingError() : super();
}

/// AI 서비스 초기화 안 됨
class AINotInitialized extends ChatFailure {
  const AINotInitialized() : super();
}

// ==================== Search Errors ====================

/// 검색 실패
class SearchFailed extends ChatFailure {
  const SearchFailed() : super();
}

// ==================== Friend System Errors ====================

/// 친구 요청 실패
class FriendRequestFailed extends ChatFailure {
  const FriendRequestFailed() : super();
}

/// 친구 목록 로드 실패
class FriendLoadFailed extends ChatFailure {
  const FriendLoadFailed() : super();
}

/// 팔로우 토글 실패
class FollowToggleFailed extends ChatFailure {
  const FollowToggleFailed() : super();
}

// ==================== Network & Permission Errors ====================

/// 네트워크 오류
class NetworkError extends ChatFailure {
  const NetworkError() : super();
}

/// 권한 없음
class PermissionDenied extends ChatFailure {
  const PermissionDenied() : super();
}

/// 서버 오류
class ServerError extends ChatFailure {
  const ServerError() : super();
}

// ==================== Generic Error ====================

/// 예기치 않은 오류
class Unexpected extends ChatFailure {
  final String? errorMessage;
  const Unexpected([this.errorMessage]) : super();
}
