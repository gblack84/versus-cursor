import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/cache_keys.dart';

/// Service for managing pending operations (offline support)
///
/// **Phase 2 Migration Note**:
/// - Standalone service (not part of cache migration)
/// - Manages offline vote queue independently
/// - Uses SharedPreferences for simple queue storage
class PendingOperationsService {
  final SharedPreferences _prefs;

  PendingOperationsService({required SharedPreferences prefs})
      : _prefs = prefs;
  
  /// Cache a pending vote operation
  Future<void> cachePendingVote({
    required String postId,
    required String userId,
    required String voteOption,
    required DateTime timestamp,
    OperationType type = OperationType.cast,
  }) async {
    final pendingVotes = await getPendingVotes();
    
    // Check if there's already a pending vote for this post/user
    pendingVotes.removeWhere((v) => 
        v.postId == postId && v.userId == userId);
    
    // Add new pending vote
    pendingVotes.add(PendingVoteOperation(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
      timestamp: timestamp,
      type: type,
    ));
    
    await _savePendingVotes(pendingVotes);
  }
  
  /// Get all pending vote operations
  Future<List<PendingVoteOperation>> getPendingVotes() async {
    final jsonString = _prefs.getString(CacheKeys.pendingVotesKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return _deserializePendingVotes(jsonList);
    } catch (e) {
      // If cache is corrupted, remove it
      await clearPendingOperations();
      return [];
    }
  }
  
  /// Remove a pending vote operation
  Future<void> removePendingVote({
    required String postId,
    required String userId,
  }) async {
    final pendingVotes = await getPendingVotes();
    pendingVotes.removeWhere((v) => 
        v.postId == postId && v.userId == userId);
    
    if (pendingVotes.isEmpty) {
      await _prefs.remove(CacheKeys.pendingVotesKey);
    } else {
      await _savePendingVotes(pendingVotes);
    }
  }
  
  /// Clear all pending operations
  Future<void> clearPendingOperations() async {
    await _prefs.remove(CacheKeys.pendingVotesKey);
  }
  
  /// Check if there are pending operations
  bool hasPendingOperations() {
    return _prefs.containsKey(CacheKeys.pendingVotesKey);
  }
  
  /// Get count of pending operations
  Future<int> getPendingOperationsCount() async {
    final pendingVotes = await getPendingVotes();
    return pendingVotes.length;
  }
  
  /// Get pending votes for a specific user
  Future<List<PendingVoteOperation>> getUserPendingVotes(String userId) async {
    final allPending = await getPendingVotes();
    return allPending.where((v) => v.userId == userId).toList();
  }
  
  /// Get pending votes older than specified duration
  Future<List<PendingVoteOperation>> getOldPendingVotes(Duration age) async {
    final allPending = await getPendingVotes();
    final cutoff = DateTime.now().subtract(age);
    return allPending.where((v) => v.timestamp.isBefore(cutoff)).toList();
  }
  
  /// Batch remove multiple pending operations
  Future<void> batchRemovePendingVotes(
    List<PendingVoteOperation> toRemove,
  ) async {
    final pendingVotes = await getPendingVotes();
    
    for (final vote in toRemove) {
      pendingVotes.removeWhere((v) => 
          v.postId == vote.postId && v.userId == vote.userId);
    }
    
    if (pendingVotes.isEmpty) {
      await _prefs.remove(CacheKeys.pendingVotesKey);
    } else {
      await _savePendingVotes(pendingVotes);
    }
  }
  
  // Helper methods
  Future<void> _savePendingVotes(List<PendingVoteOperation> votes) async {
    final jsonList = _serializePendingVotes(votes);
    final encoded = jsonEncode(jsonList);
    await _prefs.setString(CacheKeys.pendingVotesKey, encoded);
  }
  
  List<Map<String, dynamic>> _serializePendingVotes(
    List<PendingVoteOperation> votes,
  ) {
    return votes.map((v) => {
      'postId': v.postId,
      'userId': v.userId,
      'voteOption': v.voteOption,
      'timestamp': v.timestamp.toIso8601String(),
      'type': v.type.toString().split('.').last,
    }).toList();
  }
  
  List<PendingVoteOperation> _deserializePendingVotes(List<dynamic> jsonList) {
    return jsonList.map((json) => PendingVoteOperation(
      postId: json['postId'] as String,
      userId: json['userId'] as String,
      voteOption: json['voteOption'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: OperationType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => OperationType.cast,
      ),
    )).toList();
  }
}

/// Pending vote operation model for offline support
class PendingVoteOperation {
  final String postId;
  final String userId;
  final String voteOption;
  final DateTime timestamp;
  final OperationType type;

  PendingVoteOperation({
    required this.postId,
    required this.userId,
    required this.voteOption,
    required this.timestamp,
    required this.type,
  });
}

/// Operation type for pending operations
enum OperationType {
  cast,
  remove,
  update,
}