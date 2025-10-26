import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_voting_chat_repository.dart';
import '../../domain/entities/chat/post_voting.dart';
import '../../domain/failures/voting_failure.dart';
import '../datasources/i_voting_remote_datasource.dart';
import '../datasources/i_voting_local_datasource.dart';
import '../adapters/post_voting_adapter.dart';

/// Implementation of VotingRepository for chat card voting system
///
/// **Clean Architecture v4.0 - Repository Implementation**:
/// - Implements VotingRepository interface from domain layer
/// - Uses DataSource pattern (Remote + Local)
/// - Returns Either<VotingFailure, Success> for error handling
/// - PostVoting domain model with business logic methods
/// - Real-time Firestore streams converted to VotingUpdate events
///
/// **Separation from VotingRepositoryImpl**:
/// - VotingRepositoryImpl: Dialog voting system (VoteContract)
/// - VotingChatRepositoryImpl: Chat card voting system (PostVoting)
class VotingChatRepositoryImpl implements VotingRepository {
  final IVotingRemoteDataSource _remoteDataSource;
  final IVotingLocalDataSource _localDataSource;
  final FirebaseFirestore _firestore;

  VotingChatRepositoryImpl({
    required IVotingRemoteDataSource remoteDataSource,
    required IVotingLocalDataSource localDataSource,
    FirebaseFirestore? firestore,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================================
  // Core Voting Operations
  // ============================================================================

  @override
  Future<Either<VotingFailure, PostVoting>> getVoting(String postId) async {
    try {
      // Try cache first
      final cachedData = await _localDataSource.getCachedVoteState(
        postId: postId,
        userId: '', // Not user-specific for post voting data
      );

      if (cachedData != null) {
        // TODO: Convert cached data to PostVoting
        // For now, fetch from remote
      }

      // Fetch from Firestore
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return const Left(NotFound());
      }

      final data = doc.data()!;
      final voting = PostVotingAdapter.fromFirestore(data, postId);

      // Cache the result
      await _cacheVotingData(voting);

      return Right(voting);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Firebase error: ${e.code} - ${e.message}');
      }
      return Left(_mapFirebaseException(e));
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Unexpected error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Stream<Either<VotingFailure, PostVoting>> watchPostVoting(String postId) {
    try {
      return _firestore
          .collection('posts')
          .doc(postId)
          .snapshots()
          .map((snapshot) {
        try {
          if (!snapshot.exists) {
            return const Left(NotFound());
          }

          final data = snapshot.data();
          if (data == null) {
            return const Left(NotFound());
          }

          final voting = PostVotingAdapter.fromFirestore(data, postId);
          return Right(voting);
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print('[VotingChatRepository] Firebase error: ${e.code}');
          }
          return Left(_mapFirebaseException(e));
        } catch (e) {
          if (kDebugMode) {
            print('[VotingChatRepository] Unexpected error: $e');
          }
          return Left(Unexpected(e.toString()));
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Stream error: $e');
      }
      return Stream.value(Left(Unexpected(e.toString())));
    }
  }

  @override
  Future<Either<VotingFailure, PostVoting>> castVote({
    required String postId,
    required String userId,
    required VoteOption option,
  }) async {
    try {
      // 1. Get current voting state
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());

      // 2. Check if user can vote
      if (!voting.canUserVote(userId)) {
        if (voting.hasUserVoted(userId)) {
          return const Left(AlreadyVoted());
        }
        if (!voting.isActive) {
          return const Left(VotingClosed());
        }
        return const Left(Unauthorized());
      }

      // 3. Use domain model's business logic
      final updatedVoting = voting.castVote(
        userId: userId,
        choice: option,
      );

      // 4. Update Firestore
      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      // 5. Update local cache
      await _cacheVotingData(updatedVoting);

      // 6. Add to vote history
      await _localDataSource.cacheVoteHistory(
        userId: userId,
        postId: postId,
        voteOption: option == VoteOption.A ? 'A' : 'B',
        votedAt: DateTime.now(),
      );

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Cast vote error: ${e.code}');
      }
      return Left(_mapFirebaseException(e));
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Cast vote unexpected error: $e');
      }
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, PostVoting>> startVoting({
    required String postId,
    required Duration duration,
  }) async {
    try {
      // 1. Get current voting state
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());

      // 2. Use domain model's business logic
      final updatedVoting = voting.startVoting(customTimeout: duration);

      // 3. Update Firestore
      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      // 4. Update cache
      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, PostVoting>> completeVoting(
      String postId) async {
    try {
      // 1. Get current voting state
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());

      // 2. Use domain model's business logic
      final updatedVoting = voting.completeVoting();

      // 3. Update Firestore
      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      // 4. Update cache
      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, PostVoting>> cancelVoting({
    required String postId,
    required String reason,
  }) async {
    try {
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      final updatedVoting = voting.cancelVoting(reason: reason);

      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, PostVoting>> markTimeout(String postId) async {
    try {
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      final updatedVoting = voting.timeoutVoting();

      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // Expansion & Notifications
  // ============================================================================

  @override
  Future<Either<VotingFailure, PostVoting>> expandReach({
    required String postId,
    required int points,
    required List<String> targetUserIds,
  }) async {
    try {
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      final updatedVoting = voting.updateExpansion(
        pointsUsed: points,
        userCount: targetUserIds.length,
        status: 'active',
      );

      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, void>> sendNotifications({
    required String postId,
    required List<String> recipientIds,
  }) async {
    try {
      // Mark notifications as sent
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult.map((_) {});
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      final updatedVoting = voting.markNotificationsSent();

      await _firestore.collection('posts').doc(postId).update(
            PostVotingAdapter.toFirestore(updatedVoting),
          );

      await _cacheVotingData(updatedVoting);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, PostVoting>> updateDisplayValues({
    required String postId,
    required int displayA,
    required int displayB,
    required int percentA,
    required int percentB,
  }) async {
    try {
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return votingResult;
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      final updatedVoting = voting.copyWith(
        displayVotesA: displayA,
        displayVotesB: displayB,
      );

      await _firestore.collection('posts').doc(postId).update({
        'displayVotesA': displayA,
        'displayVotesB': displayB,
      });

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // User Queries
  // ============================================================================

  @override
  Future<Either<VotingFailure, VotingStats>> getUserVotingStats(
      String userId) async {
    try {
      // Get user's vote history
      final historyResult = await _localDataSource.getCachedVoteHistory(userId);
      final history = historyResult ?? [];

      // Calculate stats
      int totalVotes = history.length;
      int optionAVotes =
          history.where((v) => v['voteOption'] == 'A').length;
      int optionBVotes =
          history.where((v) => v['voteOption'] == 'B').length;

      // Get participated polls count from Firestore
      final userVotesQuery = await _firestore
          .collectionGroup('votes')
          .where('userId', isEqualTo: userId)
          .get();

      final stats = VotingStats(
        totalVotes: totalVotes,
        optionAVotes: optionAVotes,
        optionBVotes: optionBVotes,
        participatedPolls: userVotesQuery.docs.length,
        createdPolls: 0, // TODO: Query created posts
        averageResponseTime: 0.0, // TODO: Calculate from timestamps
        categoryVotes: {}, // TODO: Categorize votes
      );

      return Right(stats);
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, bool>> hasUserVoted({
    required String postId,
    required String userId,
  }) async {
    try {
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return const Right(false);
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      return Right(voting.hasUserVoted(userId));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  @override
  Future<Either<VotingFailure, VoteOption?>> getUserVote({
    required String postId,
    required String userId,
  }) async {
    try {
      final votingResult = await getVoting(postId);
      if (votingResult.isLeft()) {
        return const Right(null);
      }

      final voting = votingResult.getOrElse(() => throw UnimplementedError());
      return Right(voting.getUserVote(userId));
    } catch (e) {
      return Left(Unexpected(e.toString()));
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Cache voting data locally
  Future<void> _cacheVotingData(PostVoting voting) async {
    try {
      // Convert PostVoting to cache format
      // Using vote state cache (temporary until dedicated cache is implemented)
      await _localDataSource.cacheVoteState(
        postId: voting.postId,
        userId: '', // Post-level cache, not user-specific
        voteState: _convertToVoteCacheState(voting),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Cache error: $e');
      }
      // Don't throw, caching is optional
    }
  }

  /// Convert PostVoting to VoteCacheState (temporary adapter)
  dynamic _convertToVoteCacheState(PostVoting voting) {
    // TODO: Implement proper conversion
    // For now, return a simple map representation
    return {
      'postId': voting.postId,
      'voteStatus': voting.voteStatus.toString(),
      'votesA': voting.votesA,
      'votesB': voting.votesB,
      'voteCompleted': voting.voteCompleted,
      'timestamp': DateTime.now(),
    };
  }

  /// Map FirebaseException to VotingFailure
  VotingFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const Unauthorized();
      case 'not-found':
        return const NotFound();
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkError();
      default:
        return ServerError();
    }
  }
}
