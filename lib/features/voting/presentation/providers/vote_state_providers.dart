/// Voting Feature - Vote State Riverpod Providers
///
/// **Riverpod Phase 2: Domain State Management**
/// - VoteStateCoordinator를 Provider로 변환
/// - Port-Adapter 패턴 유지
/// - BehaviorSubject 캐싱으로 Firebase 최적화
///
/// **Clean Architecture 준수:**
/// - GetIt DI를 통한 Port 주입 (Presentation이 Domain만 의존)
/// - Data 레이어 직접 참조 없음
///
/// **Provider 구조:**
/// - voteStatePortProvider: IVoteStatePort 인스턴스 제공 (GetIt 통합)
/// - voteStateCoordinatorProvider: VoteState 통합 관리

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';
import '/features/voting/domain/ports/i_vote_state_port.dart';
import '/features/voting/domain/entities/chat/vote_state.dart';
import '/features/voting/domain/constants/voting_constants.dart';
import '/app/di.dart';

// ============================================================================
// Vote State Port Provider
// ============================================================================

/// Vote State Port 인스턴스 제공
///
/// **DI 통합**: GetIt에서 IVoteStatePort 주입
/// Firebase 추상화 레이어 (Port-Adapter 패턴)
///
/// **사용법:**
/// ```dart
/// final port = ref.watch(voteStatePortProvider);
/// ```
final voteStatePortProvider = Provider<IVoteStatePort>((ref) {
  return getIt<IVoteStatePort>();
});

// ============================================================================
// Vote State Coordinator Provider
// ============================================================================

/// VoteStateCoordinator 클래스
///
/// **주요 기능:**
/// - BehaviorSubject 캐싱으로 Firebase 읽기 90% 절감
/// - Port-Adapter 패턴으로 Firebase 추상화
/// - postId별 독립적인 Stream 관리
/// - 자동 리소스 정리 (ref.onDispose)
///
/// **Before (싱글톤):**
/// ```dart
/// VoteStateCoordinator.instance.getVoteStateStream(...)
/// ```
///
/// **After (Riverpod):**
/// ```dart
/// ref.read(voteStateCoordinatorProvider).getVoteStateStream(...)
/// ```
class VoteStateCoordinator {
  final IVoteStatePort _port;
  final Map<String, BehaviorSubject<VoteStateData>> _stateCache = {};
  final Map<String, Stream<VoteStateData>> _subscriptions = {};

  VoteStateCoordinator(this._port);

  /// 투표 상태 Stream 가져오기 (캐싱 포함)
  ///
  /// **Firebase 최적화:**
  /// - 같은 postId의 Stream은 재사용 (BehaviorSubject 캐싱)
  /// - N개의 위젯이 같은 투표를 표시해도 Firebase는 1번만 읽음
  ///
  /// **사용법:**
  /// ```dart
  /// final stream = ref.read(voteStateCoordinatorProvider)
  ///   .getVoteStateStream(
  ///     postId: 'post123',
  ///     voteEndTime: DateTime.now().add(Duration(minutes: 10)),
  ///   );
  /// ```
  Stream<VoteStateData> getVoteStateStream({
    required String postId,
    required DateTime? voteEndTime,
    String? initialStatus,
    Map<String, dynamic>? userVotes,
  }) {
    // 이미 캐시된 Stream 확인
    if (_stateCache.containsKey(postId)) {
      if (kDebugMode) {
        print('[VoteStateCoordinator] Using cached stream for postId: $postId');
      }
      return _stateCache[postId]!.stream;
    }

    if (kDebugMode) {
      print('[VoteStateCoordinator] Creating new stream for postId: $postId');
    }

    // 새 BehaviorSubject 생성 (마지막 값 캐싱)
    final subject = _port.getOrCreateStateStream(postId);

    // 캐시에 추가
    _stateCache[postId] = subject;

    // 현재 사용자 ID
    final currentUserId = _port.getCurrentUserId();

    // Firebase 모니터링 시작
    _port.startMonitoringVoteState(
      postId: postId,
      voteEndTime: voteEndTime,
    );

    // Port에서 업데이트 스트림 구독
    final voteUpdatesStream = _port.streamVoteUpdates(postId);

    // 스트림 결합 및 상태 계산
    final combinedStream = voteUpdatesStream.asyncMap((voteData) async {
      return _convertToVoteStateData(
        voteData: voteData,
        voteEndTime: voteEndTime,
        currentUserId: currentUserId,
      );
    });

    // 구독 저장
    _subscriptions[postId] = combinedStream;

    // BehaviorSubject에 업데이트 전달
    combinedStream.listen(
      (stateData) {
        if (!subject.isClosed) {
          subject.add(stateData);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print('[VoteStateCoordinator] Stream error for $postId: $error');
        }
        if (!subject.isClosed) {
          subject.addError(error);
        }
      },
    );

    return subject.stream;
  }

  /// VoteStateData 변환 로직
  ///
  /// Firebase 데이터 → UI 상태 변환
  VoteStateData _convertToVoteStateData({
    required Map<String, dynamic> voteData,
    required DateTime? voteEndTime,
    required String? currentUserId,
  }) {
    // 사용자 투표 여부 확인
    bool hasUserVoted = false;
    String? userChoice;

    if (currentUserId != null) {
      // 투표 데이터에서 사용자 투표 정보 확인
      final votedUsersA =
          List<String>.from(voteData['votedUserIDsA'] ?? []);
      final votedUsersB =
          List<String>.from(voteData['votedUserIDsB'] ?? []);

      if (votedUsersA.contains(currentUserId)) {
        hasUserVoted = true;
        userChoice = 'A';
      } else if (votedUsersB.contains(currentUserId)) {
        hasUserVoted = true;
        userChoice = 'B';
      }
    }

    // 타이머 상태 확인
    final isTimerExpired =
        voteEndTime != null && DateTime.now().isAfter(voteEndTime);

    // 투표 상태 결정
    VoteState state;
    if (voteData['voteCompleted'] == true || isTimerExpired) {
      state = VoteState.completed;
    } else if (voteData['voteStatus'] == 'expired') {
      state = VoteState.expired;
    } else if (voteData['voteStatus'] ==
        VotingConstants.cardStatusVotingRequest) {
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

  /// 특정 postId 리소스 정리
  ///
  /// **사용법:**
  /// ```dart
  /// @override
  /// void dispose() {
  ///   ref.read(voteStateCoordinatorProvider).disposePost(widget.postId);
  ///   super.dispose();
  /// }
  /// ```
  void disposePost(String postId) {
    if (kDebugMode) {
      print('[VoteStateCoordinator] Disposing resources for postId: $postId');
    }

    // 모니터링 중지
    _port.stopMonitoringVoteState(postId);
    _subscriptions.remove(postId);

    // Subject 닫기
    _stateCache[postId]?.close();

    // 캐시에서 제거
    _stateCache.remove(postId);
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
  ///
  /// **사용법:**
  /// ```dart
  /// await ref.read(voteStateCoordinatorProvider).submitVote(
  ///   postId: 'post123',
  ///   voteOption: 'A',
  /// );
  /// ```
  Future<void> submitVote({
    required String postId,
    required String voteOption,
  }) async {
    final userId = _port.getCurrentUserId();
    if (userId == null) {
      throw StateError('User not authenticated');
    }

    await _port.submitVote(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
    );
  }

  /// 사용자 투표 여부 확인
  Future<bool> hasUserVoted(String postId) async {
    final userId = _port.getCurrentUserId();
    if (userId == null) {
      return false;
    }

    return await _port.hasUserVoted(
      postId: postId,
      userId: userId,
    );
  }

  /// 리소스 정리
  void dispose() {
    if (kDebugMode) {
      print('[VoteStateCoordinator] Disposing all resources');
    }

    // 모든 모니터링 중지
    for (final postId in _subscriptions.keys) {
      _port.stopMonitoringVoteState(postId);
    }
    _subscriptions.clear();

    // 모든 Subject 닫기
    for (final subject in _stateCache.values) {
      subject.close();
    }
    _stateCache.clear();
  }
}

/// Vote State Coordinator Provider
///
/// **사용법:**
/// ```dart
/// // Stream 가져오기
/// final stream = ref.read(voteStateCoordinatorProvider)
///   .getVoteStateStream(postId: 'post123', voteEndTime: ...);
///
/// // 캐시 확인
/// final hasCache = ref.read(voteStateCoordinatorProvider)
///   .hasCache('post123');
///
/// // 투표 제출
/// await ref.read(voteStateCoordinatorProvider)
///   .submitVote(postId: 'post123', voteOption: 'A');
/// ```
final voteStateCoordinatorProvider = Provider<VoteStateCoordinator>((ref) {
  final port = ref.watch(voteStatePortProvider);
  final coordinator = VoteStateCoordinator(port);

  // 자동 리소스 정리
  ref.onDispose(() {
    coordinator.dispose();
  });

  return coordinator;
});
