import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../ports/i_vote_state_port.dart';
import '../entities/chat/vote_state.dart';
import '../constants/voting_constants.dart';

/// 투표 상태 통합 관리 서비스
///
/// Port-Adapter 패턴을 통해 외부 의존성을 추상화하고
/// 단일 진실의 소스(Single Source of Truth)를 제공합니다.
class VoteStateCoordinator {
  static VoteStateCoordinator? _instance;
  static VoteStateCoordinator get instance {
    _instance ??= VoteStateCoordinator._internal(
      port: null, // DI에서 주입받아야 함
    );
    return _instance!;
  }

  final IVoteStatePort? _port;
  final _stateCache = <String, BehaviorSubject<VoteStateData>>{};
  final _subscriptions = <String, Stream<VoteStateData>>{};

  VoteStateCoordinator._internal({IVoteStatePort? port}) : _port = port;

  /// DI를 통한 초기화
  static void initialize(IVoteStatePort port) {
    _instance = VoteStateCoordinator._internal(port: port);
  }

  /// 통합 상태 Stream 제공
  ///
  /// Port를 통해 추상화된 데이터 소스들을 결합하여
  /// 통합된 투표 상태를 제공합니다.
  Stream<VoteStateData> getVoteStateStream({
    required String postId,
    required DateTime? voteEndTime,
    String? initialStatus,
    Map<String, dynamic>? userVotes,
  }) {
    // Port가 없으면 에러 스트림 반환
    if (_port == null) {
      if (kDebugMode) {
        print('[VoteStateCoordinator] Port not initialized');
      }
      return Stream.error('VoteStateCoordinator not properly initialized');
    }

    // 캐시 확인
    if (_stateCache.containsKey(postId)) {
      return _stateCache[postId]!.stream;
    }

    // 새 BehaviorSubject 생성 (마지막 값 캐싱)
    final subject = _port!.getOrCreateStateStream(postId);
    _stateCache[postId] = subject;

    // 현재 사용자 ID
    final currentUserId = _port!.getCurrentUserId();

    // 투표 상태 모니터링 시작
    _port!.startMonitoringVoteState(
      postId: postId,
      voteEndTime: voteEndTime,
    );

    // Port에서 업데이트 스트림 구독
    final voteUpdatesStream = _port!.streamVoteUpdates(postId);
    
    // 스트림 결합 및 상태 계산
    final combinedStream = voteUpdatesStream.asyncMap((voteData) async {
      // 사용자 투표 여부 확인
      bool hasUserVoted = false;
      String? userChoice;
      
      if (currentUserId != null) {
        // 투표 데이터에서 사용자 투표 정보 확인
        final votedUsersA = List<String>.from(voteData['votedUserIDsA'] ?? []);
        final votedUsersB = List<String>.from(voteData['votedUserIDsB'] ?? []);
        
        if (votedUsersA.contains(currentUserId)) {
          hasUserVoted = true;
          userChoice = 'A';
        } else if (votedUsersB.contains(currentUserId)) {
          hasUserVoted = true;
          userChoice = 'B';
        }
      }
      
      // 타이머 상태 확인
      final isTimerExpired = voteEndTime != null && 
          DateTime.now().isAfter(voteEndTime);
      
      // 투표 상태 결정
      VoteState state;
      if (voteData['voteCompleted'] == true || isTimerExpired) {
        state = VoteState.completed;
      } else if (voteData['voteStatus'] == 'expired') {
        state = VoteState.expired;
      } else if (voteData['voteStatus'] == VotingConstants.cardStatusVotingRequest) {
        state = VoteState.votingRequest;
      } else {
        state = VoteState.inProgress;
      }
      
      return VoteStateData(
        state: state,
        hasUserVoted: hasUserVoted,
        userChoice: userChoice,
        voteEndTime: voteEndTime,
        isTimerExpired: isTimerExpired,
        remainingTime: isTimerExpired ? Duration.zero : null,
        voteResults: _extractVoteResults(voteData),
      );
    });
    
    // 스트림 구독 저장
    _subscriptions[postId] = combinedStream;
    
    // 상태 업데이트 리스닝
    combinedStream.listen(
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

    return subject.stream;
  }

  /// 투표 데이터에서 결과 추출
  Map<String, dynamic> _extractVoteResults(Map<String, dynamic>? data) {
    if (data == null) return {};

    return {
      'votesA': data['votesA'] ?? 0,
      'votesB': data['votesB'] ?? 0,
      'actualVotesA': data['votesA'] ?? 0,
      'actualVotesB': data['votesB'] ?? 0,
      'percentA': data['percentA'] ?? 0,
      'percentB': data['percentB'] ?? 0,
      'totalVotes': data['totalVotes'] ?? 0,
      'winner': data['winner'] ?? _calculateWinner(data),
    };
  }

  /// 승자 계산
  String _calculateWinner(Map<String, dynamic> data) {
    final votesA = data['votesA'] ?? 0;
    final votesB = data['votesB'] ?? 0;

    if (votesA > votesB) return 'A';
    if (votesB > votesA) return 'B';
    return 'draw';
  }

  /// 문자열 상태를 Enum으로 변환
  VoteState _mapStatusToState(String? status) {
    switch (status) {
      case VotingConstants.cardStatusVotingRequest:
        return VoteState.votingRequest;
      case VotingConstants.cardStatusCompleted:
        return VoteState.completed;
      case 'expired':
        return VoteState.expired;
      case 'notParticipated':
        return VoteState.notParticipated;
      case VotingConstants.cardStatusVoting:
      default:
        return VoteState.inProgress;
    }
  }

  /// 특정 투표의 리소스 정리
  void dispose(String postId) {
    // 모니터링 중지
    _port?.stopMonitoringVoteState(postId);
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
    // 모든 모니터링 중지
    for (final postId in _subscriptions.keys) {
      _port?.stopMonitoringVoteState(postId);
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

  /// 투표 제출
  Future<void> submitVote({
    required String postId,
    required String voteOption,
  }) async {
    if (_port == null) {
      throw StateError('VoteStateCoordinator not properly initialized');
    }
    
    final userId = _port!.getCurrentUserId();
    if (userId == null) {
      throw StateError('User not authenticated');
    }
    
    await _port!.submitVote(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
    );
  }

  /// 사용자 투표 여부 확인
  Future<bool> hasUserVoted(String postId) async {
    if (_port == null) {
      return false;
    }
    
    final userId = _port!.getCurrentUserId();
    if (userId == null) {
      return false;
    }
    
    return await _port!.hasUserVoted(
      postId: postId,
      userId: userId,
    );
  }
}
