import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_voting_chat_repository.dart';
import '../../domain/entities/chat/post_voting.dart';
import '../../domain/entities/dialog/vote_counts_model.dart';
import '../../domain/failures/voting_failure.dart';
import '../../domain/entities/post_voting_extensions.dart';
import '../extensions/firestore_error_extensions.dart';
import '../../../../services/cache/unified_cache_service.dart';

/// Implementation of VotingRepository for chat card voting system
///
/// **Firebase-Centric Architecture v1.0 - Repository Implementation**:
/// - Implements VotingRepository interface from domain layer
/// - Direct Firebase SDK access (no Port-Adapter abstraction)
/// - Extension-based Firestore ↔ Domain conversion
/// - Returns Either<VotingFailure, Success> for error handling
/// - PostVoting domain model with business logic methods
/// - Real-time Firestore streams with reactive updates
/// - UnifiedCacheService for 3-Layer caching
///
/// **Separation from VotingDialogRepositoryImpl**:
/// - VotingDialogRepositoryImpl: Dialog voting system (VoteContract)
/// - VotingChatRepositoryImpl: Chat card voting system (PostVoting)
class VotingChatRepositoryImpl implements IVotingChatRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

  VotingChatRepositoryImpl({
    required FirebaseFirestore firestore,
  })  : _firestore = firestore;

  // ============================================================================
  // Core Voting Operations
  // ============================================================================

  @override
  Future<Either<VotingFailure, PostVoting>> getVoting(String postId) async {
    try {
      // Note: PostVoting 전체는 캐시하지 않고, VoteCounts만 캐시
      // Real-time 업데이트가 중요하므로 항상 Firestore에서 가져옴
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return const Left(VotingFailure.notFound());
      }

      final data = doc.data()!;

      // ✅ Extension-based conversion
      final voting = PostVotingFirestoreExtension.fromFirestore(data, postId);

      // Cache VoteCounts only
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
            return const Left(VotingFailure.notFound());
          }

          final data = snapshot.data();
          if (data == null) {
            return const Left(VotingFailure.notFound());
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
          return const Left(VotingFailure.alreadyVoted());
        }
        if (!voting.isActive) {
          return const Left(VotingFailure.votingClosed());
        }
        return const Left(VotingFailure.unauthorized());
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

      // 6. Add to vote history (3-Layer cache)
      try {
        final history = await _cacheService.getVoteHistory(userId) ?? [];
        final newEntry = {
          'postId': postId,
          'voteOption': option == VoteOption.A ? 'A' : 'B',
          'votedAt': DateTime.now().toIso8601String(),
        };
        history.add(newEntry);
        await _cacheService.setVoteHistory(userId, history);
      } catch (e) {
        if (kDebugMode) {
          print('[VotingChatRepository] Failed to cache vote history: $e');
        }
        // Don't fail the vote if caching fails
      }

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
      // Get user's vote history from 3-Layer cache
      final history = await _cacheService.getVoteHistory(userId) ?? [];

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

  /// Cache voting data to 3-Layer cache
  Future<void> _cacheVotingData(PostVoting voting) async {
    try {
      // ✅ VoteCounts만 캐싱 (PostVoting 전체는 캐시하지 않음)
      // Real-time 업데이트가 중요하므로 VoteCounts만 캐시
      await _cacheService.setVoteCounts(
        voting.postId,
        VoteCounts(
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
