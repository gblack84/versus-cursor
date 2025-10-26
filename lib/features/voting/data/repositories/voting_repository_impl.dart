import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_voting_repository.dart';
import '../../domain/models/dialog/vote_counts_model.dart';
import '../../domain/models/dialog/vote_expansion_request.dart';
import '../../domain/models/dialog/weight.dart';
import '../../domain/models/dialog/vote_cache_state.dart' as cache;
import '../../domain/models/chat/vote_state.dart';
import '../../domain/models/dialog/vote_notification.dart';
import '../../domain/models/dialog/versus_box_size_data.dart';
import '../../domain/ports/i_vote_state_port.dart';
import '../../domain/ports/i_notification_data_port.dart';
import '../../domain/ports/i_vote_ui_delegate.dart';
import '../datasources/i_voting_remote_datasource.dart';
import '../datasources/i_voting_local_datasource.dart';
import '../adapters/votecounts_adapter.dart';
import '/app/contracts/vote_contract.dart';

/// Implementation of voting repository using DataSource pattern
///
/// Implements both IVotingRepository (Domain) and VoteContract (App Layer)
/// following the NotificationRepositoryImpl pattern
class VotingRepositoryImpl implements IVotingRepository, VoteContract {
  final IVotingRemoteDataSource _remoteDataSource;
  final IVotingLocalDataSource _localDataSource;

  // Port dependencies for VoteContract implementation
  final IVoteStatePort _voteStatePort;
  final INotificationDataPort _notificationDataPort;
  final IVoteUIDelegate _voteUIDelegate;

  VotingRepositoryImpl({
    required IVotingRemoteDataSource remoteDataSource,
    required IVotingLocalDataSource localDataSource,
    required IVoteStatePort voteStatePort,
    required INotificationDataPort notificationDataPort,
    required IVoteUIDelegate voteUIDelegate,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _voteStatePort = voteStatePort,
        _notificationDataPort = notificationDataPort,
        _voteUIDelegate = voteUIDelegate;

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================

  @override
  Future<int> queryVotecountsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryVotecountsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<VoteCounts>> queryVotecounts({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryVotecounts(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    ).map((models) => VoteCountsAdapter.fromFirestoreList(models));
  }

  @override
  Future<List<VoteCounts>> queryVotecountsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    final models = await _remoteDataSource.queryVotecountsOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
    return VoteCountsAdapter.fromFirestoreList(models);
  }

  // ============================================================================
  // Vote Expansion Requests Queries
  // ============================================================================

  @override
  Future<int> queryVoteExpansionRequestsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryVoteExpansionRequestsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<VoteExpansionRequest>> queryVoteExpansionRequests({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryVoteExpansionRequests(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Future<List<VoteExpansionRequest>> queryVoteExpansionRequestsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    return await _remoteDataSource.queryVoteExpansionRequestsOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  // ============================================================================
  // Weights Queries
  // ============================================================================

  @override
  Future<int> queryWeightsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryWeightsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<Weight>> queryWeights({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryWeights(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Future<List<Weight>> queryWeightsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    return await _remoteDataSource.queryWeightsOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  // ============================================================================
  // Voting Operations
  // ============================================================================

  @override
  Future<void> castVote({
    required String postId,
    required String userId,
    required String voteOption,
  }) async {
    // Cast vote to remote
    await _remoteDataSource.castVote(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
    );
    
    // Update local cache
    await _localDataSource.cacheVoteState(
      postId: postId,
      userId: userId,
      voteState: cache.VoteCacheState(
        option: voteOption,
        timestamp: DateTime.now(),
        completed: false,
      ),
    );
    
    // Add to vote history
    await _localDataSource.cacheVoteHistory(
      userId: userId,
      postId: postId,
      voteOption: voteOption,
      votedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeVote({
    required String postId,
    required String userId,
  }) async {
    // Remove vote from remote
    await _remoteDataSource.removeVote(
      postId: postId,
      userId: userId,
    );
    
    // Remove from local cache
    await _localDataSource.removeCachedVoteState(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<dynamic> checkUserVote({
    required String postId,
    required String userId,
  }) async {
    // Check local cache first
    final cachedState = await _localDataSource.getCachedVoteState(
      postId: postId,
      userId: userId,
    );
    
    if (cachedState != null) {
      return {
        'choice': cachedState.option,
        'voteOption': cachedState.option,
        'timestamp': cachedState.timestamp?.millisecondsSinceEpoch,
      };
    }
    
    // If not in cache, check remote
    // For now, return null if not found in cache
    return null;
  }

  @override
  Future<VoteCounts?> getVoteCounts(String postId) async {
    // Try to get from cache first
    final cached = await _localDataSource.getCachedVoteCounts(postId);
    if (cached != null) {
      // Check if cache is still valid (e.g., less than 5 minutes old)
      final cacheTime = await _localDataSource.getVoteCountsCacheTime(postId);
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime).inMinutes < 5) {
        return VoteCountsAdapter.fromFirestore(cached);
      }
    }
    
    // Get from remote
    final voteCountsModel = await _remoteDataSource.getVoteCounts(postId);
    
    // Cache the result if not null
    if (voteCountsModel != null) {
      await _localDataSource.cacheVoteCounts(
        postId: postId,
        voteCounts: voteCountsModel,
      );
      return VoteCountsAdapter.fromFirestore(voteCountsModel);
    }
    
    return null;
  }

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================

  @override
  Future<void> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  }) async {
    await _remoteDataSource.requestVoteExpansion(
      postId: postId,
      userId: userId,
      additionalTime: additionalTime,
    );
  }

  @override
  Future<void> approveVoteExpansion(String requestId) async {
    await _remoteDataSource.approveVoteExpansion(requestId);
  }

  @override
  Future<void> rejectVoteExpansion(String requestId) async {
    await _remoteDataSource.rejectVoteExpansion(requestId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserVoteHistory(String userId) async {
    try {
      // Try to get from local cache first
      final cachedHistory = await _localDataSource.getCachedVoteHistory(userId);
      if (cachedHistory != null && cachedHistory.isNotEmpty) {
        return cachedHistory;
      }

      // If not in cache, get from remote
      final remoteHistory = await _remoteDataSource.getUserVotes(userId);

      // Cache the result
      if (remoteHistory.isNotEmpty) {
        await _localDataSource.cacheUserVoteHistory(userId, remoteHistory);
      }

      return remoteHistory;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  // ============================================================================
  // VoteContract Implementation (App Layer)
  // ============================================================================

  // --- 9 Existing VoteContract Methods ---

  @override
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  }) async {
    // Check if user has voted using VoteStatePort
    return await _voteStatePort.hasUserVoted(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<void> createVote({
    required String postId,
    required String userId,
    required String choice,
  }) async {
    // Submit vote through VoteStatePort
    await _voteStatePort.submitVote(
      postId: postId,
      userId: userId,
      voteOption: choice,
    );
  }

  @override
  Future<Map<String, int>> getVoteResults(String postId) async {
    // Get vote results from remote datasource
    final voteCountsModel = await _remoteDataSource.getVoteCounts(postId);
    if (voteCountsModel == null) {
      return {'A': 0, 'B': 0};
    }

    return {
      'A': voteCountsModel.votesA ?? 0,
      'B': voteCountsModel.votesB ?? 0,
    };
  }

  @override
  Future<List<String>> getVoterIds(String postId) async {
    // Get voter IDs from remote datasource
    final voteCountsModel = await _remoteDataSource.getVoteCounts(postId);
    if (voteCountsModel == null) {
      return [];
    }

    // Combine votedUserIdsA and votedUserIdsB
    final votersA = List<String>.from(voteCountsModel.votedUserIDsA ?? []);
    final votersB = List<String>.from(voteCountsModel.votedUserIDsB ?? []);

    return [...votersA, ...votersB];
  }

  @override
  Stream<Map<String, int>> getVoteResultsStream(String postId) {
    // Get real-time vote results stream
    return _voteStatePort.streamVoteUpdates(postId).map((voteData) {
      return {
        'A': voteData['votesA'] as int? ?? 0,
        'B': voteData['votesB'] as int? ?? 0,
      };
    });
  }

  @override
  Future<void> completeVoting(String postId) async {
    // Mark voting as completed via VoteStatePort
    // The Port will handle the Firebase update
    _voteStatePort.stopMonitoringVoteState(postId);
  }

  @override
  Future<String> getVoteStatus(String postId) async {
    // Get vote status from post data via NotificationDataPort
    final postData = await _notificationDataPort.getPostData(postId);
    if (postData == null) {
      return 'unknown';
    }

    // Extract status from post data
    final voteCompleted = postData['voteCompleted'] as bool? ?? false;
    if (voteCompleted) {
      return 'completed';
    }

    final voteEndTime = postData['voteEndTime'] as Timestamp?;
    if (voteEndTime != null) {
      final endTime = voteEndTime.toDate();
      if (DateTime.now().isAfter(endTime)) {
        return 'expired';
      }
      return 'inProgress';
    }

    return postData['voteStatus'] as String? ?? 'unknown';
  }

  @override
  Stream<List<Map<String, dynamic>>> getRankedPosts({
    String? category,
    int? limit,
  }) {
    // TODO: Ranking functionality has been moved to Search Feature
    // Posts feature should use Search feature's ranking functionality instead
    // This method is kept for VoteContract compatibility but should be refactored
    throw UnimplementedError(
      'Ranking functionality has been migrated to Search Feature. '
      'Please use Search feature\'s getRankings methods instead.'
    );
  }

  @override
  Future<Map<String, dynamic>?> getRankedPostById(String postId) async {
    // TODO: Ranking functionality has been moved to Search Feature
    // Posts feature should use Search feature's ranking functionality instead
    // This method is kept for VoteContract compatibility but should be refactored
    throw UnimplementedError(
      'Ranking functionality has been migrated to Search Feature. '
      'Please use Search feature\'s getRankings methods instead.'
    );
  }

  // --- 13 New VoteContract Methods from Ports ---

  // From IVoteStatePort (8 methods)

  @override
  BehaviorSubject<VoteStateData> getOrCreateStateStream(String postId) {
    return _voteStatePort.getOrCreateStateStream(postId);
  }

  @override
  String? getCurrentUserId() {
    return _voteStatePort.getCurrentUserId();
  }

  @override
  bool isAuthenticated() {
    return _voteStatePort.isAuthenticated();
  }

  @override
  void updateVoteState({
    required String postId,
    required VoteStateData stateData,
  }) {
    _voteStatePort.updateVoteState(
      postId: postId,
      stateData: stateData,
    );
  }

  @override
  void startMonitoringVoteState({
    required String postId,
    required DateTime? voteEndTime,
  }) {
    _voteStatePort.startMonitoringVoteState(
      postId: postId,
      voteEndTime: voteEndTime,
    );
  }

  @override
  void stopMonitoringVoteState(String postId) {
    _voteStatePort.stopMonitoringVoteState(postId);
  }

  @override
  Stream<Map<String, dynamic>> streamVoteUpdates(String postId) {
    return _voteStatePort.streamVoteUpdates(postId);
  }

  @override
  void dispose() {
    _voteStatePort.dispose();
  }

  // From INotificationDataPort (2 methods)

  @override
  Future<Map<String, dynamic>?> getPostData(String postId) {
    return _notificationDataPort.getPostData(postId);
  }

  @override
  Map<String, dynamic>? parseNotificationContent(String content) {
    return _notificationDataPort.parseNotificationContent(content);
  }

  // From IVoteUIDelegate (3 methods)

  @override
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
  }) {
    return _voteUIDelegate.showVotingNotification(
      notification: notification,
      context: context,
      question: question,
      optionA: optionA,
      optionB: optionB,
      imageUrlA: imageUrlA,
      imageUrlB: imageUrlB,
      imageUrlsA: imageUrlsA,
      imageUrlsB: imageUrlsB,
      description: description,
      authorName: authorName,
      sizeData: sizeData,
      onVote: onVote,
      onDismiss: onDismiss,
    );
  }

  @override
  bool isUIContextAvailable() {
    return _voteUIDelegate.isUIContextAvailable();
  }

  @override
  Future<BuildContext?> waitForUIContext({
    Duration timeout = const Duration(seconds: 10),
  }) {
    return _voteUIDelegate.waitForUIContext(timeout: timeout);
  }
}
