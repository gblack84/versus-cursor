import 'dart:async';

/// Voting Feature가 다른 Feature들에게 제공하는 계약
///
/// 실제로는 vote_contract.dart를 사용하지만
/// voting 시스템에서 사용하는 랭킹 관련 데이터를 위한 추가 계약
abstract class VotingContract {
  /// 랭킹된 게시물 목록 조회
  Stream<List<Map<String, dynamic>>> getRankedPosts({
    String? category,
    int? limit,
  });

  /// 특정 게시물의 랭킹 데이터 조회
  Future<Map<String, dynamic>?> getRankedPostById(String postId);
}

/// Posts feature가 Voting feature에 제공하는 데이터 접근 인터페이스
///
/// Voting feature는 이 인터페이스를 통해 랭킹 데이터를 조회합니다
abstract class RankedPostsDataSource {
  /// 랭킹된 게시물 목록 조회
  Stream<List<RankedPostsData>> getRankedPosts({
    String? category,
    int? limit,
  });

  /// 특정 게시물의 랭킹 데이터 조회
  Future<RankedPostsData?> getRankedPostById(String postId);
}

/// 랭킹 데이터 DTO
class RankedPostsData {
  final String postId;
  final int rank;
  final double score;
  final int votesA;
  final int votesB;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? category;

  RankedPostsData({
    required this.postId,
    required this.rank,
    required this.score,
    required this.votesA,
    required this.votesB,
    this.createdAt,
    this.updatedAt,
    this.category,
  });
}