import 'dart:async';

/// Posts Feature가 다른 Feature들에게 제공하는 계약
///
/// Notifications, Voting 등이 Posts 데이터에 접근할 때 사용
abstract class PostContract {
  /// 게시물 데이터 조회
  Future<Map<String, dynamic>?> getPost(String postId);

  /// 게시물 존재 여부 확인
  Future<bool> postExists(String postId);

  /// 게시물 작성자 ID 조회
  Future<String?> getPostCreatorId(String postId);

  /// 투표 수 업데이트 (Voting feature에서 사용)
  Future<void> updatePostVotes({
    required String postId,
    required int votesA,
    required int votesB,
  });

  /// 타겟 오디언스와 함께 게시물 생성 (Notifications에서 사용)
  Future<String> createPostWithTargetAudience({
    required Map<String, dynamic> postData,
    required Map<String, dynamic> targetAudience,
  });

  /// 알림 상태 업데이트 (Notifications에서 사용)
  Future<void> updatePostNotificationStatus({
    required String postId,
    required bool notificationsSent,
    DateTime? notificationsSentAt,
  });

  /// 사용자의 게시물 목록 조회
  Future<List<Map<String, dynamic>>> getUserPosts(String userId);

  /// 타겟 오디언스 통계를 위한 사용자 게시물 조회
  Future<List<Map<String, dynamic>>> getUserPostsWithTargetAudience({
    required String userId,
    int limit = 100,
  });
}