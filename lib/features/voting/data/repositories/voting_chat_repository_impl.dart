import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_voting_chat_repository.dart';
import '../../domain/entities/chat/post_voting.dart';
import '../../domain/entities/dialog/vote_counts_model.dart';
import '../../domain/failures/voting_failure.dart';
import '../datasources/i_voting_local_datasource.dart';
import '../extensions/post_voting_extensions.dart';
import '../extensions/firestore_error_extensions.dart';

/// Implementation of VotingRepository for chat card voting system
///
/// **Firebase-Centric Architecture v1.0 - Repository Implementation**:
/// - Implements VotingRepository interface from domain layer
/// - Direct Firebase SDK access (no Port-Adapter abstraction)
/// - Extension-based Firestore ↔ Domain conversion
/// - Returns Either<VotingFailure, Success> for error handling
/// - PostVoting domain model with business logic methods
/// - Real-time Firestore streams with reactive updates
///
/// **Separation from VotingDialogRepositoryImpl**:
/// - VotingDialogRepositoryImpl: Dialog voting system (VoteContract)
/// - VotingChatRepositoryImpl: Chat card voting system (PostVoting)
class VotingChatRepositoryImpl implements VotingRepository {
  final FirebaseFirestore _firestore;
  final IVotingLocalDataSource _localDataSource;

  VotingChatRepositoryImpl({
    required FirebaseFirestore firestore,
    required IVotingLocalDataSource localDataSource,
  })  : _firestore = firestore,
        _localDataSource = localDataSource;

  // ============================================================================
  // Core Voting Operations
  // ============================================================================

  @override
  Future<Either<VotingFailure, PostVoting>> getVoting(String postId) async {
    try {
      // ✅ PostVoting 캐시 확인
      final cachedVoting = await _localDataSource.getCachedPostVoting(
        postId,
        maxAge: const Duration(minutes: 5),
      );

      if (cachedVoting != null) {
        // ✅ 캐시 히트: 즉시 반환
        return Right(cachedVoting);
      }

      // 캐시 미스: Firestore에서 가져오기
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return const Left(NotFound());
      }

      final data = doc.data()!;

      // ✅ Extension-based conversion
      final voting = PostVotingFirestoreExtension.fromFirestore(data, postId);

      // Cache the result
      await _cacheVotingData(voting);

      return Right(voting);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Firebase error: ${e.code} - ${e.message}');
      }
      // ✅ Extension-based error handling
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Unexpected error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Stream<Either<VotingFailure, PostVoting>> watchPostVoting(String postId) {
    try {
      // ✅ Real-time Firestore snapshot stream
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

          // ✅ Extension-based conversion
          final voting = PostVotingFirestoreExtension.fromFirestore(data, postId);
          return Right(voting);
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print('[VotingChatRepository] Firebase error: ${e.code}');
          }
          // ✅ Extension-based error handling
          return Left(e.toVotingFailure());
        } catch (e) {
          if (kDebugMode) {
            print('[VotingChatRepository] Unexpected error: $e');
          }
          return Left(e.toString().toVotingFailure());
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Stream error: $e');
      }
      return Stream.value(Left(e.toString().toVotingFailure()));
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

      // 2. Check if user can vote (domain business logic)
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

      // 4. ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
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
      // ✅ Extension-based error handling
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Cast vote unexpected error: $e');
      }
      return Left(e.toString().toVotingFailure());
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

      // 3. ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
          );

      // 4. Update cache
      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // 3. ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
          );

      // 4. Update cache
      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
          );

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
          );

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
          );

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // ✅ Update Firestore with Extension method
      await _firestore.collection('posts').doc(postId).update(
            updatedVoting.toFirestore(),
          );

      await _cacheVotingData(updatedVoting);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // ✅ Direct Firebase update (specific fields only)
      await _firestore.collection('posts').doc(postId).update({
        'displayVotesA': displayA,
        'displayVotesB': displayB,
      });

      await _cacheVotingData(updatedVoting);

      return Right(updatedVoting);
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
    }
  }

  // ============================================================================
  // User Queries
  // ============================================================================

  @override
  Future<Either<VotingFailure, VotingStats>> getUserVotingStats(
      String userId) async {
    try {
      // Get user's vote history from local cache
      final historyResult = await _localDataSource.getCachedVoteHistory(userId);
      final history = historyResult ?? [];

      // Calculate stats
      int totalVotes = history.length;
      int optionAVotes =
          history.where((v) => v['voteOption'] == 'A').length;
      int optionBVotes =
          history.where((v) => v['voteOption'] == 'B').length;

      // ✅ Get participated polls count from Firestore (collectionGroup query)
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
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // Use domain model's business logic
      return Right(voting.hasUserVoted(userId));
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
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

      // Use domain model's business logic
      return Right(voting.getUserVote(userId));
    } on FirebaseException catch (e) {
      return Left(e.toVotingFailure());
    } catch (e) {
      return Left(e.toString().toVotingFailure());
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Cache voting data locally
  Future<void> _cacheVotingData(PostVoting voting) async {
    try {
      // ✅ PostVoting 전체 캐싱
      await _localDataSource.cachePostVoting(voting);

      // ✅ 추가: VoteCounts도 별도 캐싱 (빠른 접근용)
      await _localDataSource.cacheVoteCounts(
        postId: voting.postId,
        voteCounts: VoteCounts(
          votesA: voting.votesA,
          votesB: voting.votesB,
          totalVotes: voting.totalVotes,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[VotingChatRepository] Cache error: $e');
      }
      // Don't throw, caching is optional
    }
  }
}
