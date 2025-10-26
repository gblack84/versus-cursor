import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/app/contracts/vote_contract.dart';
import '../../domain/repositories/i_voting_dialog_repository.dart';

/// VoteContract Adapter
///
/// **Clean Architecture v4.0 - Adapter Pattern**:
/// - App Layer Contract를 Data Layer에서 구현
/// - IVotingDialogRepository에 의존 (Port 제거됨)
/// - Either<Failure, T>를 처리하여 Contract 시그니처에 맞춤
///
/// **책임**:
/// - VoteContract의 9개 메서드 구현
/// - Repository의 Either 결과를 Contract 반환 타입으로 변환
/// - 에러 처리 및 로깅
///
/// **Moved From**: app/contracts/implementations/ (new pattern)
/// **Reason**: Contract 구현은 Data layer에 위치
class VoteContractAdapter implements VoteContract {
  final IVotingDialogRepository _repository;

  VoteContractAdapter({
    required IVotingDialogRepository repository,
  }) : _repository = repository;

  // ========================================
  // Vote Data Access Methods (9개)
  // ========================================

  @override
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  }) async {
    try {
      final result = await _repository.checkUserVote(
        postId: postId,
        userId: userId,
      );

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('[VoteContractAdapter] hasUserVoted error: $failure');
          }
          return false; // 에러 시 투표 안 한 것으로 처리
        },
        (voteData) => voteData != null, // Map이 있으면 true
      );
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] hasUserVoted exception: $e');
      }
      return false;
    }
  }

  @override
  Future<void> createVote({
    required String postId,
    required String userId,
    required String choice,
  }) async {
    try {
      final result = await _repository.castVote(
        postId: postId,
        userId: userId,
        voteOption: choice,
      );

      result.fold(
        (failure) {
          if (kDebugMode) {
            print('[VoteContractAdapter] createVote error: $failure');
          }
          throw Exception('Failed to create vote: $failure');
        },
        (_) {
          if (kDebugMode) {
            print('[VoteContractAdapter] createVote success: postId=$postId, choice=$choice');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] createVote exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getVoteResults(String postId) async {
    try {
      final result = await _repository.getVoteCounts(postId);

      return result.fold(
        (failure) {
          if (kDebugMode) {
            print('[VoteContractAdapter] getVoteResults error: $failure');
          }
          return {'option1': 0, 'option2': 0};
        },
        (counts) {
          if (counts == null) return {'option1': 0, 'option2': 0};
          return {
            'option1': counts['option1'] as int? ?? 0,
            'option2': counts['option2'] as int? ?? 0,
          };
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] getVoteResults exception: $e');
      }
      return {'option1': 0, 'option2': 0};
    }
  }

  @override
  Future<List<String>> getVoterIds(String postId) async {
    try {
      // Repository에는 직접적인 getVoterIds가 없으므로
      // getUserVoteHistory로 대체 (모든 사용자의 투표 이력에서 해당 postId 필터링)
      // 실제로는 별도 구현이 필요할 수 있음

      // 임시: 빈 리스트 반환
      // TODO: Repository에 getVoterIds 메서드 추가 필요
      if (kDebugMode) {
        print('[VoteContractAdapter] getVoterIds not fully implemented yet');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] getVoterIds exception: $e');
      }
      return [];
    }
  }

  @override
  Stream<Map<String, int>> getVoteResultsStream(String postId) {
    try {
      return _repository
          .streamVoteCounts(
        queryBuilder: (query) =>
            (query as Query<Map<String, dynamic>>).where('postId', isEqualTo: postId),
        singleRecord: true,
      )
          .map((either) {
        return either.fold(
          (failure) {
            if (kDebugMode) {
              print('[VoteContractAdapter] getVoteResultsStream error: $failure');
            }
            return {'option1': 0, 'option2': 0};
          },
          (countsList) {
            if (countsList.isEmpty) return {'option1': 0, 'option2': 0};
            final counts = countsList.first;
            return {
              'option1': counts['option1'] as int? ?? 0,
              'option2': counts['option2'] as int? ?? 0,
            };
          },
        );
      });
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] getVoteResultsStream exception: $e');
      }
      return Stream.value({'option1': 0, 'option2': 0});
    }
  }

  @override
  Future<void> completeVoting(String postId) async {
    try {
      // Repository에는 completeVoting이 없으므로
      // 실제로는 Firebase Functions에서 처리되거나
      // 별도 구현 필요

      // TODO: Repository에 completeVoting 메서드 추가 필요
      if (kDebugMode) {
        print('[VoteContractAdapter] completeVoting called for postId=$postId');
        print('[VoteContractAdapter] This should be handled by Firebase Functions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] completeVoting exception: $e');
      }
      rethrow;
    }
  }

  @override
  Future<String> getVoteStatus(String postId) async {
    try {
      // Repository에는 getVoteStatus가 없으므로
      // getVoteCounts로 대체하거나 별도 구현 필요

      // TODO: Repository에 getVoteStatus 메서드 추가 필요
      // 임시로 'active' 반환
      if (kDebugMode) {
        print('[VoteContractAdapter] getVoteStatus not fully implemented yet');
      }
      return 'active';
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] getVoteStatus exception: $e');
      }
      return 'unknown';
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getRankedPosts({
    String? category,
    int? limit,
  }) {
    try {
      // Repository에는 랭킹 관련 메서드가 없으므로
      // streamVoteCounts를 활용하거나 별도 구현 필요

      // TODO: Repository에 getRankedPosts 메서드 추가 필요
      if (kDebugMode) {
        print('[VoteContractAdapter] getRankedPosts not fully implemented yet');
      }
      return Stream.value([]);
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] getRankedPosts exception: $e');
      }
      return Stream.value([]);
    }
  }

  @override
  Future<Map<String, dynamic>?> getRankedPostById(String postId) async {
    try {
      // Repository에는 랭킹 관련 메서드가 없으므로
      // getVoteCounts로 대체하거나 별도 구현 필요

      // TODO: Repository에 getRankedPostById 메서드 추가 필요
      if (kDebugMode) {
        print('[VoteContractAdapter] getRankedPostById not fully implemented yet');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[VoteContractAdapter] getRankedPostById exception: $e');
      }
      return null;
    }
  }
}
