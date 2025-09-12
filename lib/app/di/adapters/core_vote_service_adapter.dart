import 'package:flutter/material.dart';
import '/core/interfaces/features/i_vote_service.dart' as core;
import '/features/voting/domain/ports/i_vote_service.dart' as voting;

/// Adapter that bridges Core IVoteService interface with Voting feature's IVoteService
/// 
/// This adapter allows notifications feature to use voting functionality
/// without direct feature-to-feature dependencies
class CoreVoteServiceAdapter implements core.IVoteService {
  final voting.IVoteService _votingService;
  
  CoreVoteServiceAdapter({
    required voting.IVoteService votingService,
  }) : _votingService = votingService;
  
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
    // Delegate to voting feature's service
    await _votingService.submitVote(
      postId: postId,
      userId: userId,
      choice: choice,
      messageId: messageId,
      chatId: chatId,
      onError: onError,
    );
  }
  
  @override
  Future<Map<String, dynamic>?> getVoteStatus(String postId) async {
    // TODO: Implement when voting feature provides this method
    // For now, return null to avoid breaking changes
    return null;
  }
  
  @override
  Future<bool> hasUserVoted({
    required String userId,
    required String postId,
  }) async {
    // TODO: Implement when voting feature provides this method
    // For now, return false to avoid breaking changes
    return false;
  }
  
  // Additional required methods from Core IVoteService
  
  @override
  Future<void> showVotingNotification({
    required BuildContext context,
    required core.IVoteNotification notification,
    required Future<void> Function(bool optionA) onVote,
    required void Function(bool hasVoted) onDismiss,
  }) async {
    // TODO: Implement UI display logic
    // This would typically delegate to a UI manager
  }
  
  @override
  Future<bool?> getUserVoteOption({
    required String userId,
    required String postId,
  }) async {
    // TODO: Implement when voting feature provides this method
    return null;
  }
  
  @override
  Future<core.VoteResult> castVote({
    required String userId,
    required String postId,
    required bool optionA,
    String? notificationId,
  }) async {
    // Convert to submitVote format
    final choice = optionA ? 'A' : 'B';
    try {
      await submitVote(
        postId: postId,
        userId: userId,
        choice: choice,
      );
      return core.VoteResult.success();
    } catch (e) {
      return core.VoteResult.failure(e.toString());
    }
  }
  
  @override
  Future<core.VoteResult> cancelVote({
    required String userId,
    required String postId,
  }) async {
    // TODO: Implement when voting feature provides this method
    return core.VoteResult.failure('Not implemented');
  }
  
  @override
  Stream<core.IVoteStatus> watchVoteStatus(String postId) {
    // TODO: Implement when voting feature provides this method
    return Stream.empty();
  }
  
  @override
  Stream<Duration> watchVoteTimer(String postId) {
    // TODO: Implement when voting feature provides this method
    return Stream.empty();
  }
  
  @override
  void setUIContext(BuildContext context) {
    // TODO: Store context for UI operations
  }
  
  @override
  bool get hasUIContext => false;
  
  @override
  Future<void> initialize() async {
    // TODO: Initialize voting system if needed
  }
  
  @override
  void dispose() {
    // TODO: Clean up resources if needed
  }
}