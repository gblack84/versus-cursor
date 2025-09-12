import 'package:rxdart/rxdart.dart';
import '../models/vote_state.dart';

/// Vote state coordination port interface
/// 
/// This interface abstracts the vote state coordination logic,
/// removing direct Firebase dependencies from the domain layer.
/// Follows the Port-Adapter pattern for Clean Architecture compliance.
abstract class IVoteStatePort {
  /// Get or create a vote state stream for a specific post
  BehaviorSubject<VoteStateData> getOrCreateStateStream(String postId);
  
  /// Get the current user ID
  String? getCurrentUserId();
  
  /// Check if user is authenticated
  bool isAuthenticated();
  
  /// Update vote state with timer information
  void updateVoteState({
    required String postId,
    required VoteStateData stateData,
  });
  
  /// Start monitoring vote state from Firebase
  void startMonitoringVoteState({
    required String postId,
    required DateTime? voteEndTime,
  });
  
  /// Stop monitoring vote state
  void stopMonitoringVoteState(String postId);
  
  /// Submit a vote
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String voteOption,
  });
  
  /// Check if user has voted
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  });
  
  /// Get vote results
  Future<Map<String, dynamic>> getVoteResults(String postId);
  
  /// Stream vote updates from Firebase
  Stream<Map<String, dynamic>> streamVoteUpdates(String postId);
  
  /// Clean up resources
  void dispose();
}