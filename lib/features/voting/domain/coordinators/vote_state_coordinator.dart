import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/i_voting_chat_repository.dart';
import '../entities/chat/vote_state.dart';
import '../entities/chat/post_voting.dart';
import '../constants/voting_constants.dart';

/// 투표 상태 통합 관리 서비스
///
/// **Clean Architecture v4.0 - Port 제거**:
/// - Repository에 직접 의존 (Port 레이어 제거)
/// - 단일 진실의 소스(Single Source of Truth) 제공
/// - BehaviorSubject를 통한 상태 캐싱
class VoteStateCoordinator {
  static VoteStateCoordinator? _instance;
  static VoteStateCoordinator get instance {
    _instance ??= VoteStateCoordinator._internal(
      repository: null, // DI에서 주입받아야 함
      auth: null,
    );
    return _instance!;
  }

  final VotingRepository? _repository;
  final FirebaseAuth? _auth;
  final _stateCache = <String, BehaviorSubject<VoteStateData>>{};
  final _subscriptions = <String, Stream<VoteStateData>>{};

  VoteStateCoordinator._internal({
    VotingRepository? repository,
    FirebaseAuth? auth,
  }) : _repository = repository,
       _auth = auth;

  /// DI를 통한 초기화
  static void initialize({
    required VotingRepository repository,
    FirebaseAuth? auth,
  }) {
    _instance = VoteStateCoordinator._internal(
      repository: repository,
      auth: auth ?? FirebaseAuth.instance,
    );
  }

  /// 통합 상태 Stream 제공
  ///
  /// Repository를 통해 투표 상태를 통합하여 제공합니다.
  Stream<VoteStateData> getVoteStateStream({
    required String postId,
    required DateTime? voteEndTime,
    String? initialStatus,
    Map<String, dynamic>? userVotes,
  }) {
    // Repository가 없으면 에러 스트림 반환
    if (_repository == null) {
      if (kDebugMode) {
        print('[VoteStateCoordinator] Repository not initialized');
      }
      return Stream.error('VoteStateCoordinator not properly initialized');
    }

    // 캐시 확인
    if (_stateCache.containsKey(postId)) {
      return _stateCache[postId]!.stream;
    }

    // 새 BehaviorSubject 생성 (마지막 값 캐싱)
    final subject = BehaviorSubject<VoteStateData>.seeded(
      const VoteStateData(
        state: VoteState.votingRequest,
        hasUserVoted: false,
        userChoice: null,
        remainingTime: null,
        voteResults: null,
      ),
    );
    _stateCache[postId] = subject;

    // 현재 사용자 ID
    final currentUserId = _auth?.currentUser?.uid;

    // Repository에서 업데이트 스트림 구독
    final voteUpdatesStream = _repository!.watchPostVoting(postId)
        .map((either) => either.fold(
              (failure) {
                if (kDebugMode) {
                  print('[VoteStateCoordinator] Stream error: $failure');
                }
                return <String, dynamic>{};
              },
              (postVoting) => {
                'voteStatus': postVoting.voteStatus.toString(),
                'voteCompleted': postVoting.voteCompleted,
                'votedUserIdsA': postVoting.votedUserIdsA,
                'votedUserIdsB': postVoting.votedUserIdsB,
                'votesA': postVoting.votesA,
                'votesB': postVoting.votesB,
                'voteEndTime': postVoting.voteEndTime,
              },
            ));
    
    // 스트림 결합 및 상태 계산
    final combinedStream = voteUpdatesStream.asyncMap((voteData) async {
      // 사용자 투표 여부 확인
      bool hasUserVoted = false;
      String? userChoice;
      
      if (currentUserId != null) {
        // 투표 데이터에서 사용자 투표 정보 확인
        final votedUsersA = List<String>.from((voteData['votedUserIDsA'] ?? []) as List);
        final votedUsersB = List<String>.from((voteData['votedUserIDsB'] ?? []) as List);
        
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
    // 구독 제거
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
    // 모든 구독 정리
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
    if (_repository == null) {
      throw StateError('VoteStateCoordinator not properly initialized');
    }

    final userId = _auth?.currentUser?.uid;
    if (userId == null) {
      throw StateError('User not authenticated');
    }

    final option = voteOption == 'A' ? VoteOption.A : VoteOption.B;

    final result = await _repository!.castVote(
      postId: postId,
      userId: userId,
      option: option,
    );

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('[VoteStateCoordinator] submitVote failed: $failure');
        }
        throw Exception('Failed to submit vote: $failure');
      },
      (_) {
        if (kDebugMode) {
          print('[VoteStateCoordinator] submitVote success');
        }
      },
    );
  }

  /// 사용자 투표 여부 확인
  Future<bool> hasUserVoted(String postId) async {
    if (_repository == null) {
      return false;
    }

    final userId = _auth?.currentUser?.uid;
    if (userId == null) {
      return false;
    }

    // TODO: VotingRepository에 hasUserVoted 메서드 추가 필요
    // 임시: getVoting으로 대체하여 votedUserIds 확인
    final result = await _repository!.getVoting(postId);

    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('[VoteStateCoordinator] hasUserVoted failed: $failure');
        }
        return false;
      },
      (postVoting) {
        return postVoting.votedUserIdsA.contains(userId) ||
            postVoting.votedUserIdsB.contains(userId);
      },
    );
  }
}
