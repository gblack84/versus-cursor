import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/ports/i_vote_state_port.dart';
import '../../domain/services/i_vote_timer_service.dart';
import '../../domain/models/vote_state.dart';

/// Firebase-based implementation of IVoteStatePort
///
/// This adapter encapsulates all Firebase dependencies,
/// keeping them isolated in the data layer.
class VoteStateAdapter implements IVoteStatePort {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final IVoteTimerService _voteTimerPort;
  final Map<String, BehaviorSubject<VoteStateData>> _stateCache = {};
  final Map<String, StreamSubscription<DocumentSnapshot>> _subscriptions = {};

  VoteStateAdapter({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required IVoteTimerService voteTimerPort,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _voteTimerPort = voteTimerPort;
  
  @override
  BehaviorSubject<VoteStateData> getOrCreateStateStream(String postId) {
    return _stateCache.putIfAbsent(
      postId,
      () => BehaviorSubject<VoteStateData>.seeded(
        const VoteStateData(
          state: VoteState.votingRequest,
          hasUserVoted: false,
          userChoice: null,
          remainingTime: null,
          voteResults: null,
        ),
      ),
    );
  }
  
  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
  
  @override
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }
  
  @override
  void updateVoteState({
    required String postId,
    required VoteStateData stateData,
  }) {
    final stream = getOrCreateStateStream(postId);
    if (!stream.isClosed) {
      stream.add(stateData);
    }
  }
  
  @override
  void startMonitoringVoteState({
    required String postId,
    required DateTime? voteEndTime,
  }) {
    // Stop any existing subscription
    stopMonitoringVoteState(postId);
    
    // Start timer if vote end time exists
    if (voteEndTime != null) {
      _voteTimerPort.startTimer(
        postId: postId,
        voteEndTime: voteEndTime,
      );
    }
    
    // Subscribe to Firestore updates
    final subscription = _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _handleFirestoreUpdate(postId, snapshot.data() ?? {});
      }
    });
    
    _subscriptions[postId] = subscription;
  }
  
  @override
  void stopMonitoringVoteState(String postId) {
    _subscriptions[postId]?.cancel();
    _subscriptions.remove(postId);
    _voteTimerPort.stopTimer(postId);
  }
  
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String voteOption,
  }) async {
    // Create vote document
    final voteRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('votes')
        .doc(userId);
    
    await voteRef.set({
      'userId': userId,
      'voteOption': voteOption,
      'votedAt': FieldValue.serverTimestamp(),
    });
    
    // Update post vote counts
    final postRef = _firestore.collection('posts').doc(postId);
    final field = voteOption == 'A' ? 'votesA' : 'votesB';
    
    await postRef.update({
      field: FieldValue.increment(1),
      'totalVotes': FieldValue.increment(1),
    });
  }
  
  @override
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  }) async {
    final voteDoc = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('votes')
        .doc(userId)
        .get();
    
    return voteDoc.exists;
  }
  
  @override
  Future<Map<String, dynamic>> getVoteResults(String postId) async {
    final postDoc = await _firestore
        .collection('posts')
        .doc(postId)
        .get();
    
    if (!postDoc.exists) {
      return {'votesA': 0, 'votesB': 0, 'totalVotes': 0};
    }
    
    final data = postDoc.data() ?? {};
    return {
      'votesA': data['votesA'] ?? 0,
      'votesB': data['votesB'] ?? 0,
      'totalVotes': data['totalVotes'] ?? 0,
    };
  }
  
  @override
  Stream<Map<String, dynamic>> streamVoteUpdates(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }
  
  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Close all streams
    for (final stream in _stateCache.values) {
      stream.close();
    }
    _stateCache.clear();
    
    // Note: Timer service cleanup is handled by the service itself
    // via DI container lifecycle management
  }
  
  void _handleFirestoreUpdate(String postId, Map<String, dynamic> data) {
    final stream = getOrCreateStateStream(postId);
    final currentState = stream.value;
    
    // Update state with Firestore data
    final updatedState = VoteStateData(
      state: _determineVoteState(data),
      hasUserVoted: currentState.hasUserVoted,
      userChoice: currentState.userChoice,
      remainingTime: currentState.remainingTime,
      voteResults: {
        'votesA': data['votesA'] ?? 0,
        'votesB': data['votesB'] ?? 0,
        'totalVotes': data['totalVotes'] ?? 0,
      },
      voteEndTime: data['voteEndTime'] != null 
          ? (data['voteEndTime'] as Timestamp).toDate()
          : null,
      isTimerExpired: data['voteCompleted'] ?? false,
    );
    
    updateVoteState(postId: postId, stateData: updatedState);
  }
  
  VoteState _determineVoteState(Map<String, dynamic> data) {
    if (data['voteCompleted'] == true) {
      return VoteState.completed;
    } else if (data['voteStartTime'] != null) {
      return VoteState.inProgress;
    } else {
      return VoteState.votingRequest;
    }
  }
}