import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/vote_timer_service.dart';
import '/models/vote_state.dart';
import '/auth/firebase_auth/auth_util.dart';

/// 투표 상태 통합 관리 서비스
/// 
/// Firebase, 타이머, 알림 상태를 통합하여 단일 진실의 소스(Single Source of Truth)를 제공합니다.
class VoteStateCoordinator {
  static final VoteStateCoordinator _instance = VoteStateCoordinator._internal();
  static VoteStateCoordinator get instance => _instance;
  
  VoteStateCoordinator._internal();
  
  final _voteTimerService = VoteTimerService();
  final _stateCache = <String, BehaviorSubject<VoteStateData>>{};
  final _subscriptions = <String, dynamic>{};
  
  /// 통합 상태 Stream 제공
  /// 
  /// Firebase 실시간 데이터, 타이머 상태, 사용자 투표 정보를 결합하여
  /// 통합된 투표 상태를 제공합니다.
  Stream<VoteStateData> getVoteStateStream({
    required String postId,
    required DateTime? voteEndTime,
    String? initialStatus,
    Map<String, dynamic>? userVotes,
  }) {
    // 캐시 확인
    if (_stateCache.containsKey(postId)) {
      return _stateCache[postId]!.stream;
    }
    
    // 새 BehaviorSubject 생성 (마지막 값 캐싱)
    final subject = BehaviorSubject<VoteStateData>();
    _stateCache[postId] = subject;
    
    // 현재 사용자 ID
    final currentUserId = currentUserUid;
    
    // 3개 Stream 결합
    final subscription = CombineLatestStream.combine3<DocumentSnapshot?, Duration?, String?, VoteStateData>(
      // 1. Firebase 실시간 상태
      FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .snapshots()
          .handleError((error) {
            if (kDebugMode) {
              print('[VoteStateCoordinator] Firebase error: $error');
            }
            return null;
          }),
      
      // 2. 타이머 상태 (voteEndTime이 있을 때만)
      voteEndTime != null 
          ? _voteTimerService.getRemainingTimeStream(postId, voteEndTime)
          : Stream.value(null),
      
      // 3. 초기 상태 (한 번만 방출)
      Stream.value(initialStatus),
      
      // 통합 상태 계산
      (postSnapshot, remainingTime, initStatus) {
        return _calculateUnifiedState(
          postSnapshot: postSnapshot,
          remainingTime: remainingTime,
          initialStatus: initStatus,
          voteEndTime: voteEndTime,
          userVotes: userVotes,
          currentUserId: currentUserId,
        );
      },
    ).listen(
      (stateData) {
        if (!subject.isClosed) {
          subject.add(stateData);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('[VoteStateCoordinator] Stream error: $error');
        }
        if (!subject.isClosed) {
          subject.addError(error);
        }
      },
    );
    
    // 구독 저장 (나중에 정리를 위해)
    _subscriptions[postId] = subscription;
    
    return subject.stream;
  }
  
  /// 통합 상태 계산 로직
  VoteStateData _calculateUnifiedState({
    DocumentSnapshot? postSnapshot,
    Duration? remainingTime,
    String? initialStatus,
    DateTime? voteEndTime,
    Map<String, dynamic>? userVotes,
    String? currentUserId,
  }) {
    // 1. 타이머 종료 체크 (최우선)
    final isTimerExpired = remainingTime != null && remainingTime.inSeconds <= 0;
    
    // Firebase 데이터 파싱
    Map<String, dynamic>? firebaseData;
    if (postSnapshot != null && postSnapshot.exists) {
      firebaseData = postSnapshot.data() as Map<String, dynamic>?;
    }
    
    // 사용자 투표 정보 확인
    bool hasUserVoted = false;
    String? userChoice;
    
    if (currentUserId != null) {
      // Firebase 데이터에서 확인
      if (firebaseData != null) {
        final votedUsersA = List<String>.from(firebaseData['votedUserIDsA'] ?? []);
        final votedUsersB = List<String>.from(firebaseData['votedUserIDsB'] ?? []);
        
        if (votedUsersA.contains(currentUserId)) {
          hasUserVoted = true;
          userChoice = 'A';
        } else if (votedUsersB.contains(currentUserId)) {
          hasUserVoted = true;
          userChoice = 'B';
        }
      }
      
      // userVotes 매개변수에서도 확인
      if (!hasUserVoted && userVotes != null) {
        final userVote = userVotes[currentUserId] as Map<String, dynamic>?;
        if (userVote != null) {
          hasUserVoted = true;
          userChoice = userVote['option'] as String?;
        }
      }
    }
    
    // 타이머가 만료되었으면 즉시 completed 상태로
    if (isTimerExpired) {
      // Firebase 데이터가 아직 업데이트되지 않았어도 completed로 표시
      return VoteStateData(
        state: VoteState.completed,
        remainingTime: Duration.zero,
        isTimerExpired: true,
        voteEndTime: voteEndTime,
        hasUserVoted: hasUserVoted,
        userChoice: userChoice,
        voteResults: _extractVoteResults(firebaseData),
      );
    }
    
    // 2. Firebase 데이터 확인
    if (firebaseData != null) {
      // vote_completed 필드 확인
      if (firebaseData['vote_completed'] == true || 
          firebaseData['voteCompleted'] == true) {
        return VoteStateData(
          state: VoteState.completed,
          remainingTime: Duration.zero,
          voteResults: _extractVoteResults(firebaseData),
          voteEndTime: voteEndTime,
          hasUserVoted: hasUserVoted,
          userChoice: userChoice,
        );
      }
      
      // vote_status 또는 voteStatus 필드 확인
      final voteStatus = firebaseData['vote_status'] ?? 
                        firebaseData['voteStatus'] ?? 
                        initialStatus;
      
      return VoteStateData(
        state: _mapStatusToState(voteStatus),
        remainingTime: remainingTime,
        voteEndTime: voteEndTime,
        hasUserVoted: hasUserVoted,
        userChoice: userChoice,
      );
    }
    
    // 3. 초기 상태 사용
    return VoteStateData(
      state: _mapStatusToState(initialStatus ?? 'in_progress'),
      remainingTime: remainingTime,
      voteEndTime: voteEndTime,
      hasUserVoted: hasUserVoted,
      userChoice: userChoice,
    );
  }
  
  /// Firebase 데이터에서 투표 결과 추출
  Map<String, dynamic> _extractVoteResults(Map<String, dynamic>? data) {
    if (data == null) return {};
    
    return {
      'votesA': data['display_votes_a'] ?? data['votes_a'] ?? data['votesA'] ?? 0,
      'votesB': data['display_votes_b'] ?? data['votes_b'] ?? data['votesB'] ?? 0,
      'actualVotesA': data['actual_votes_a'] ?? data['votes_a'] ?? 0,
      'actualVotesB': data['actual_votes_b'] ?? data['votes_b'] ?? 0,
      'percentA': data['display_percent_a'] ?? data['percentA'] ?? 0,
      'percentB': data['display_percent_b'] ?? data['percentB'] ?? 0,
      'totalVotes': data['total_votes'] ?? data['totalVotes'] ?? 0,
      'winner': data['winner'] ?? _calculateWinner(data),
    };
  }
  
  /// 승자 계산
  String _calculateWinner(Map<String, dynamic> data) {
    final votesA = data['display_votes_a'] ?? data['votes_a'] ?? 0;
    final votesB = data['display_votes_b'] ?? data['votes_b'] ?? 0;
    
    if (votesA > votesB) return 'A';
    if (votesB > votesA) return 'B';
    return 'draw';
  }
  
  /// 문자열 상태를 Enum으로 변환
  VoteState _mapStatusToState(String? status) {
    switch (status) {
      case 'voting_request':
        return VoteState.votingRequest;
      case 'completed':
        return VoteState.completed;
      case 'expired':
        return VoteState.expired;
      case 'not_participated':
        return VoteState.notParticipated;
      case 'in_progress':
      default:
        return VoteState.inProgress;
    }
  }
  
  /// 특정 투표의 리소스 정리
  void dispose(String postId) {
    // 구독 취소
    _subscriptions[postId]?.cancel();
    _subscriptions.remove(postId);
    
    // Subject 닫기
    _stateCache[postId]?.close();
    _stateCache.remove(postId);
    
    if (kDebugMode) {
      print('[VoteStateCoordinator] Disposed resources for postId: $postId');
    }
  }
  
  /// 전체 캐시 정리
  void disposeAll() {
    // 모든 구독 취소
    for (final subscription in _subscriptions.values) {
      subscription?.cancel();
    }
    _subscriptions.clear();
    
    // 모든 Subject 닫기
    for (final subject in _stateCache.values) {
      subject.close();
    }
    _stateCache.clear();
    
    if (kDebugMode) {
      print('[VoteStateCoordinator] Disposed all resources');
    }
  }
  
  /// 캐시된 마지막 상태 가져오기 (동기)
  VoteStateData? getCachedState(String postId) {
    return _stateCache[postId]?.valueOrNull;
  }
  
  /// 캐시 상태 확인
  bool hasCache(String postId) {
    return _stateCache.containsKey(postId);
  }
}