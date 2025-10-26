import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_voting_dialog_repository.dart';
import '../../domain/failures/voting_failure.dart';
import '../../domain/entities/dialog/vote_expansion_request.dart';
import '../../domain/entities/dialog/weight.dart';
import '../datasources/i_voting_remote_datasource.dart';
import '../datasources/i_voting_local_datasource.dart';

/// Implementation of Dialog voting repository
///
/// **Clean Architecture v4.0 - Repository Pattern**:
/// - Implements IVotingDialogRepository interface
/// - Depends ONLY on DataSource layer (no Ports, no Services)
/// - Wraps DataSource calls in Either<Failure, T> for error handling
/// - No business logic - pure data access orchestration
///
/// **DataSource Dependencies**:
/// - IVotingRemoteDataSource: Firebase operations
/// - IVotingLocalDataSource: Local cache operations
///
/// **Removed Dependencies** (from legacy VotingRepositoryImpl):
/// - ❌ IVoteStatePort: Moved to Coordinator
/// - ❌ INotificationDataPort: Moved to App layer
/// - ❌ IVoteUIDelegate: Moved to Presentation layer
class VotingDialogRepositoryImpl implements IVotingDialogRepository {
  final IVotingRemoteDataSource _remoteDataSource;
  final IVotingLocalDataSource _localDataSource;

  VotingDialogRepositoryImpl({
    required IVotingRemoteDataSource remoteDataSource,
    required IVotingLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  // ============================================================================
  // Basic Vote Operations (CRUD)
  // ============================================================================

  @override
  Future<Either<VotingFailure, void>> castVote({
    required String postId,
    required String userId,
    required String voteOption,
    String? messageId,
    String? chatId,
  }) async {
    try {
      await _remoteDataSource.castVote(
        postId: postId,
        userId: userId,
        voteOption: voteOption,
        messageId: messageId,
        chatId: chatId,
      );

      if (kDebugMode) {
        print('[DialogRepo] castVote success: postId=$postId, choice=$voteOption');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] castVote error: $e');
      }

      // Parse error message to determine failure type
      final errorStr = e.toString();
      if (errorStr.contains('이미 투표')) {
        return const Left(AlreadyVoted());
      } else if (errorStr.contains('찾을 수 없')) {
        return const Left(NotFound());
      } else {
        return Left(Unexpected(errorStr));
      }
    }
  }

  @override
  Future<Either<VotingFailure, void>> removeVote({
    required String postId,
    required String userId,
  }) async {
    try {
      await _remoteDataSource.removeVote(
        postId: postId,
        userId: userId,
      );

      if (kDebugMode) {
        print('[DialogRepo] removeVote success: postId=$postId, userId=$userId');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] removeVote error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, Map<String, dynamic>?>> checkUserVote({
    required String postId,
    required String userId,
  }) async {
    try {
      // Try local cache first
      final cachedHistory = await _localDataSource.getCachedVoteHistory(userId);

      if (cachedHistory != null) {
        final userVote = cachedHistory.firstWhere(
          (vote) => vote['postId'] == postId,
          orElse: () => <String, dynamic>{},
        );

        if (userVote.isNotEmpty) {
          if (kDebugMode) {
            print('[DialogRepo] checkUserVote cache hit: postId=$postId');
          }
          return Right(userVote);
        }
      }

      // Fallback to remote
      final voteHistory = await _remoteDataSource.getUserVotes(userId);
      final userVote = voteHistory.firstWhere(
        (vote) => vote['postId'] == postId,
        orElse: () => <String, dynamic>{},
      );

      if (userVote.isEmpty) {
        return const Right(null);
      }

      // Cache the complete history
      await _localDataSource.cacheUserVoteHistory(userId, voteHistory);

      return Right(userVote);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] checkUserVote error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================

  @override
  Future<Either<VotingFailure, Map<String, dynamic>?>> getVoteCounts(
    String postId,
  ) async {
    try {
      final counts = await _remoteDataSource.getVoteCounts(postId);

      if (kDebugMode) {
        print('[DialogRepo] getVoteCounts success: postId=$postId, counts=$counts');
      }

      return Right(counts as Map<String, dynamic>?);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCounts error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Stream<Either<VotingFailure, List<Map<String, dynamic>>>> streamVoteCounts({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      return _remoteDataSource
          .queryVotecounts(
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      )
          .map((counts) {
        final result =
            counts.map((c) => c as Map<String, dynamic>).toList();

        if (kDebugMode) {
          print('[DialogRepo] streamVoteCounts emit: ${result.length} items');
        }

        return Right(result) as Either<VotingFailure, List<Map<String, dynamic>>>;
      }).handleError((e) {
        if (kDebugMode) {
          print('[DialogRepo] streamVoteCounts error: $e');
        }
        return Left(Unexpected(e.toString()));
      });
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] streamVoteCounts error: $e');
      }
      return Stream.value(
        Left(Unexpected(e.toString())),
      );
    }
  }

  @override
  Future<Either<VotingFailure, List<Map<String, dynamic>>>> getVoteCountsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    try {
      final counts = await _remoteDataSource.queryVotecountsOnce(
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

      final result = counts.map((c) => c as Map<String, dynamic>).toList();

      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsOnce success: ${result.length} items');
      }

      return Right(result);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsOnce error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, int>> getVoteCountsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) async {
    try {
      final count = await _remoteDataSource.queryVotecountsCount(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsCount success: count=$count');
      }

      return Right(count);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsCount error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // User Vote History
  // ============================================================================

  @override
  Future<Either<VotingFailure, List<Map<String, dynamic>>>> getUserVoteHistory(
    String userId,
  ) async {
    try {
      final history = await _remoteDataSource.getUserVotes(userId);

      if (kDebugMode) {
        print('[DialogRepo] getUserVoteHistory success: ${history.length} votes');
      }

      return Right(history);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getUserVoteHistory error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================

  @override
  Future<Either<VotingFailure, void>> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  }) async {
    try {
      await _remoteDataSource.requestVoteExpansion(
        postId: postId,
        userId: userId,
        additionalTime: additionalTime,
      );

      if (kDebugMode) {
        print('[DialogRepo] requestVoteExpansion success: postId=$postId, time=$additionalTime');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] requestVoteExpansion error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, void>> approveVoteExpansion(
    String requestId,
  ) async {
    try {
      await _remoteDataSource.approveVoteExpansion(requestId);

      if (kDebugMode) {
        print('[DialogRepo] approveVoteExpansion success: requestId=$requestId');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] approveVoteExpansion error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, void>> rejectVoteExpansion(
    String requestId,
  ) async {
    try {
      await _remoteDataSource.rejectVoteExpansion(requestId);

      if (kDebugMode) {
        print('[DialogRepo] rejectVoteExpansion success: requestId=$requestId');
      }

      return const Right(null);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] rejectVoteExpansion error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Stream<Either<VotingFailure, List<VoteExpansionRequest>>>
      streamVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      return _remoteDataSource
          .queryVoteExpansionRequests(
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      )
          .map((requests) {
        if (kDebugMode) {
          print('[DialogRepo] streamVoteExpansionRequests emit: ${requests.length} items');
        }

        return Right(requests) as Either<VotingFailure, List<VoteExpansionRequest>>;
      }).handleError((e) {
        if (kDebugMode) {
          print('[DialogRepo] streamVoteExpansionRequests error: $e');
        }
        return Left(Unexpected(e.toString()));
      });
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] streamVoteExpansionRequests error: $e');
      }
      return Stream.value(
        Left(Unexpected(e.toString())),
      );
    }
  }

  @override
  Future<Either<VotingFailure, List<VoteExpansionRequest>>>
      getVoteExpansionRequestsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    try {
      final requests = await _remoteDataSource.queryVoteExpansionRequestsOnce(
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsOnce success: ${requests.length} items');
      }

      return Right(requests);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsOnce error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, int>> getVoteExpansionRequestsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) async {
    try {
      final count = await _remoteDataSource.queryVoteExpansionRequestsCount(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsCount success: count=$count');
      }

      return Right(count);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsCount error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // Weights Operations
  // ============================================================================

  @override
  Stream<Either<VotingFailure, List<Weight>>> streamWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      return _remoteDataSource
          .queryWeights(
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      )
          .map((weights) {
        if (kDebugMode) {
          print('[DialogRepo] streamWeights emit: ${weights.length} items');
        }

        return Right(weights) as Either<VotingFailure, List<Weight>>;
      }).handleError((e) {
        if (kDebugMode) {
          print('[DialogRepo] streamWeights error: $e');
        }
        return Left(Unexpected(e.toString()));
      });
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] streamWeights error: $e');
      }
      return Stream.value(
        Left(Unexpected(e.toString())),
      );
    }
  }

  @override
  Future<Either<VotingFailure, List<Weight>>> getWeightsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    try {
      final weights = await _remoteDataSource.queryWeightsOnce(
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

      if (kDebugMode) {
        print('[DialogRepo] getWeightsOnce success: ${weights.length} items');
      }

      return Right(weights);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getWeightsOnce error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, int>> getWeightsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) async {
    try {
      final count = await _remoteDataSource.queryWeightsCount(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      if (kDebugMode) {
        print('[DialogRepo] getWeightsCount success: count=$count');
      }

      return Right(count);
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getWeightsCount error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }
}
