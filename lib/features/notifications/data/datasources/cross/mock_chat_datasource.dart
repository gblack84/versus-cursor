import '../i_chat_datasource.dart';
import '/features/posts/domain/models/posts_model.dart';

/// IChatDatasource의 Mock 구현체
///
/// Chat Feature가 아직 마이그레이션되지 않았으므로
/// 임시로 Mock 구현체를 사용합니다.
class MockChatDatasource implements IChatDatasource {
  MockChatDatasource();

  @override
  Future<void> createVoteRequestMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required PostsModel post,
  }) async {
    // TODO: Chat Feature 마이그레이션 후 실제 구현으로 교체
    print('[MockChatDatasource] createVoteRequestMessage called');
    print('  senderId: $senderId');
    print('  recipientId: $recipientId');
    print('  postId: $postId');

    // 실제 구현에서는 Firebase Firestore에 메시지 생성
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> updateVoteMessageStatus({
    required String postId,
    required String userId,
    required String status,
  }) async {
    // TODO: Chat Feature 마이그레이션 후 실제 구현으로 교체
    print('[MockChatDatasource] updateVoteMessageStatus called');
    print('  postId: $postId');
    print('  userId: $userId');
    print('  status: $status');

    // 실제 구현에서는 Firebase Firestore의 메시지 업데이트
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
