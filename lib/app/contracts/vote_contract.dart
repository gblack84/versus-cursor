import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '/features/voting/domain/models/chat/vote_state.dart';
import '/features/voting/domain/models/dialog/vote_notification.dart';
import '/features/voting/domain/models/dialog/versus_box_size_data.dart';

/// Voting Feature가 다른 Feature들에게 제공하는 계약
///
/// Posts, Notifications 등이 투표 데이터에 접근할 때 사용
/// Clean Architecture의 App Layer에서 Feature 간 통신을 위한 인터페이스
abstract class VoteContract {
  // ========================================
  // 기존 메서드 (9개) - 유지
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

  // ========================================
  // 신규 메서드 (13개) - Port 통합
  // ========================================

  // --- From IVoteStatePort (8개) ---

  /// 특정 게시물의 투표 상태 스트림 가져오기 또는 생성
  BehaviorSubject<VoteStateData> getOrCreateStateStream(String postId);

  /// 현재 로그인한 사용자 ID 가져오기
  String? getCurrentUserId();

  /// 사용자 인증 상태 확인
  bool isAuthenticated();

  /// 투표 상태 업데이트
  void updateVoteState({
    required String postId,
    required VoteStateData stateData,
  });

  /// Firebase에서 투표 상태 모니터링 시작
  void startMonitoringVoteState({
    required String postId,
    required DateTime? voteEndTime,
  });

  /// 투표 상태 모니터링 중지
  void stopMonitoringVoteState(String postId);

  /// Firebase에서 투표 업데이트 실시간 스트림
  Stream<Map<String, dynamic>> streamVoteUpdates(String postId);

  /// 리소스 정리
  void dispose();

  // --- From INotificationDataPort (2개) ---

  /// 게시물 데이터 조회
  Future<Map<String, dynamic>?> getPostData(String postId);

  /// 알림 콘텐츠 파싱
  Map<String, dynamic>? parseNotificationContent(String content);

  // --- From IVoteUIDelegate (3개) ---

  /// 투표 알림 UI 표시
  Future<void> showVotingNotification({
    required VoteNotification notification,
    required BuildContext context,
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? description,
    String? authorName,
    VersusBoxSizeData? sizeData,
    required Future<void> Function(String selectedOption) onVote,
    required void Function(bool hasVoted) onDismiss,
  });

  /// UI 컨텍스트 사용 가능 여부 확인
  bool isUIContextAvailable();

  /// UI 컨텍스트가 준비될 때까지 대기
  Future<BuildContext?> waitForUIContext({
    Duration timeout = const Duration(seconds: 10),
  });
}
