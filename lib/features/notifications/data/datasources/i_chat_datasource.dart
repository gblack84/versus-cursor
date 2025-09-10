import '/features/posts/domain/models/posts_model.dart';

/// Chat Feature와의 인터페이스
/// 
/// Notification Feature에서 채팅 기능이 필요한 경우
/// 이 인터페이스를 통해 접근합니다.
abstract class IChatDatasource {
  /// 투표 요청을 채팅 메시지로 생성
  Future<void> createVoteRequestMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required PostsModel post,
  });
  
  /// AI 채팅 메시지의 투표 상태 업데이트
  Future<void> updateVoteMessageStatus({
    required String postId,
    required String userId,
    required String status,
  });
}