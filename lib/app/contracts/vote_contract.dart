import 'dart:async';

/// Voting Feature가 다른 Feature들에게 제공하는 계약
///
/// Posts, Notifications 등이 투표 데이터에 접근할 때 사용
/// Clean Architecture의 App Layer에서 Feature 간 통신을 위한 인터페이스
///
/// **Clean Architecture v4.0 - Slim Contract Pattern**:
/// - 9개 핵심 voting data 메서드만 제공
/// - Port 책임 (state, notification, UI)은 제거됨
/// - Repository를 통한 데이터 접근에만 집중
abstract class VoteContract {
  // ========================================
  // Vote Data Access Methods (9개)
  // ========================================

  /// 사용자가 특정 게시물에 투표했는지 확인
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  });

  /// 투표 생성
  Future<void> createVote({
    required String postId,
    required String userId,
    required String choice, // 'A' or 'B'
  });

  /// 투표 결과 조회
  Future<Map<String, int>> getVoteResults(String postId);

  /// 투표자 목록 조회
  Future<List<String>> getVoterIds(String postId);

  /// 실시간 투표 업데이트 스트림
  Stream<Map<String, int>> getVoteResultsStream(String postId);

  /// 투표 완료 처리
  Future<void> completeVoting(String postId);

  /// 투표 상태 조회 (진행중, 완료 등)
  Future<String> getVoteStatus(String postId);

  /// 랭킹 데이터 조회 (Posts에서 사용)
  Stream<List<Map<String, dynamic>>> getRankedPosts({
    String? category,
    int? limit,
  });

  /// 특정 게시물의 랭킹 데이터 조회
  Future<Map<String, dynamic>?> getRankedPostById(String postId);
}
