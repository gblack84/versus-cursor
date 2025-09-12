import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/ports/i_vote_status_service.dart';
import '../../domain/repositories/i_voting_repository.dart';

/// Implementation of IVoteStatusService using the voting repository
/// 
/// This adapter provides vote status operations by delegating to 
/// the voting repository following the Port-Adapter pattern
class VoteStatusServiceImpl implements IVoteStatusService {
  final IVotingRepository _repository;
  final FirebaseFirestore _firestore;
  
  VoteStatusServiceImpl({
    required IVotingRepository repository,
    FirebaseFirestore? firestore,
  }) : _repository = repository,
       _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
    try {
      await _repository.castVote(
        postId: postId,
        userId: userId,
        voteOption: choice,
      );
    } catch (e) {
      onError?.call(e.toString());
    }
  }
  
  @override
  Future<Map<String, dynamic>?> checkUserVoteStatus({
    required String postId,
    required String userId,
  }) async {
    final result = await _repository.checkUserVote(
      postId: postId,
      userId: userId,
    );
    
    if (result is Map<String, dynamic>) {
      return result;
    }
    return null;
  }
  
  @override
  Future<Map<String, dynamic>?> getVoteStatus({
    required String postId,
    required String userId,
  }) async {
    // Get vote status from repository
    final voteState = await _repository.checkUserVote(
      postId: postId,
      userId: userId,
    );
    
    if (voteState != null && voteState is Map<String, dynamic>) {
      return {
        'hasVoted': true,
        'voteOption': voteState['choice'] ?? voteState['voteOption'],
        'timestamp': voteState['timestamp'],
      };
    }
    
    return {
      'hasVoted': false,
      'voteOption': null,
      'timestamp': null,
    };
  }
  
  @override
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  }) async {
    final voteState = await _repository.checkUserVote(
      postId: postId,
      userId: userId,
    );
    return voteState != null;
  }
  
  @override
  Future<void> updateVoteCompletion({
    required String postId,
    required bool isCompleted,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'voteCompleted': isCompleted,
        'voteCompletedAt': isCompleted ? FieldValue.serverTimestamp() : null,
        'voteStatus': isCompleted ? 'completed' : 'active',
      });
    } catch (e) {
      throw Exception('Failed to update vote completion: $e');
    }
  }
}