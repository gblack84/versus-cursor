import 'package:flutter/foundation.dart';
import '../../domain/models/vote_counts_model.dart';
import '../../domain/usecases/cast_vote_use_case.dart';
import '../../domain/usecases/remove_vote_use_case.dart';
import '../../domain/usecases/get_vote_counts_use_case.dart';
import '../../domain/usecases/check_user_vote_use_case.dart';
import '../../domain/usecases/stream_vote_counts_use_case.dart';
import '/core/errors/failures.dart';

/// 투표 상태를 관리하는 Provider
/// 
/// 주요 책임:
/// - 현재 사용자의 투표 상태 관리
/// - 투표 수 실시간 업데이트
/// - 투표 작업 처리 및 에러 핸들링
class VotingStateProvider extends ChangeNotifier {
  final CastVoteUseCase _castVoteUseCase;
  final RemoveVoteUseCase _removeVoteUseCase;
  final GetVoteCountsUseCase _getVoteCountsUseCase;
  final CheckUserVoteUseCase _checkUserVoteUseCase;
  final StreamVoteCountsUseCase _streamVoteCountsUseCase;

  // 상태 변수들
  String? _currentUserVote;
  VoteCounts? _voteCounts;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, Stream<VoteCounts>> _voteStreams = {};

  // Getters
  String? get currentUserVote => _currentUserVote;
  VoteCounts? get voteCounts => _voteCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasVoted => _currentUserVote != null;

  VotingStateProvider({
    required CastVoteUseCase castVoteUseCase,
    required RemoveVoteUseCase removeVoteUseCase,
    required GetVoteCountsUseCase getVoteCountsUseCase,
    required CheckUserVoteUseCase checkUserVoteUseCase,
    required StreamVoteCountsUseCase streamVoteCountsUseCase,
  })  : _castVoteUseCase = castVoteUseCase,
        _removeVoteUseCase = removeVoteUseCase,
        _getVoteCountsUseCase = getVoteCountsUseCase,
        _checkUserVoteUseCase = checkUserVoteUseCase,
        _streamVoteCountsUseCase = streamVoteCountsUseCase;

  /// 투표하기
  Future<void> castVote({
    required String postId,
    required String userId,
    required String choice,
  }) async {
    _setLoading(true);
    _clearError();

    final params = CastVoteParams(
      postId: postId,
      userId: userId,
      voteOption: choice,
    );

    final result = await _castVoteUseCase(params);
    
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (_) {
        _currentUserVote = choice;
        _updateVoteCounts(postId, choice, true);
      },
    );

    _setLoading(false);
  }

  /// 투표 취소하기
  Future<void> removeVote({
    required String postId,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    final previousVote = _currentUserVote;
    final params = RemoveVoteParams(postId: postId, userId: userId);
    final result = await _removeVoteUseCase(params);
    
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (_) {
        _currentUserVote = null;
        if (previousVote != null) {
          _updateVoteCounts(postId, previousVote, false);
        }
      },
    );

    _setLoading(false);
  }

  /// 투표 수 가져오기
  Future<void> loadVoteCounts(String postId) async {
    _setLoading(true);
    _clearError();

    final params = GetVoteCountsParams(
      queryBuilder: (query) => query.where('postId', isEqualTo: postId),
      limit: 1,
      singleRecord: true,
    );
    final result = await _getVoteCountsUseCase(params);
    
    result.fold(
      (failure) {
        _setError(_mapFailureToMessage(failure));
      },
      (counts) {
        // Take the first result since we're querying for a single post
        if (counts.isNotEmpty) {
          _voteCounts = counts.first;
        }
      },
    );

    _setLoading(false);
  }

  /// 사용자 투표 상태 확인
  Future<void> checkUserVote({
    required String postId,
    required String userId,
  }) async {
    final params = CheckUserVoteParams(postId: postId, userId: userId);
    final result = await _checkUserVoteUseCase(params);
    
    result.fold(
      (_) => _currentUserVote = null,
      (vote) => _currentUserVote = vote?.choice,
    );
    
    notifyListeners();
  }

  /// 투표 수 스트림 구독
  Stream<VoteCounts> subscribeToVoteCounts(String postId) {
    if (!_voteStreams.containsKey(postId)) {
      // Create params for the use case
      final params = StreamVoteCountsParams(
        queryBuilder: (query) => query.where('postId', isEqualTo: postId),
        limit: 1,
        singleRecord: true,
      );
      
      // Call the use case and transform the result
      final stream = _streamVoteCountsUseCase.call(params).asyncMap((either) async {
        return either.fold(
          (failure) {
            _setError(_mapFailureToMessage(failure));
            return _voteCounts ?? VoteCounts(votesA: 0, votesB: 0, totalVotes: 0);
          },
          (counts) {
            // Take the first result since we're querying for a single post
            return counts.isNotEmpty 
              ? counts.first 
              : VoteCounts(votesA: 0, votesB: 0, totalVotes: 0);
          },
        );
      });
      
      _voteStreams[postId] = stream;
    }
    
    // 스트림 구독하여 상태 업데이트
    _voteStreams[postId]!.listen((counts) {
      _voteCounts = counts;
      notifyListeners();
    });
    
    return _voteStreams[postId]!;
  }

  /// 투표 수 수동 업데이트 (낙관적 업데이트용)
  void _updateVoteCounts(String postId, String choice, bool increment) {
    if (_voteCounts == null) return;

    final currentCounts = _voteCounts!;
    if (choice == 'A') {
      _voteCounts = VoteCounts(
        votesA: currentCounts.votesA + (increment ? 1 : -1),
        votesB: currentCounts.votesB,
        totalVotes: currentCounts.totalVotes + (increment ? 1 : -1),
      );
    } else {
      _voteCounts = VoteCounts(
        votesA: currentCounts.votesA,
        votesB: currentCounts.votesB + (increment ? 1 : -1),
        totalVotes: currentCounts.totalVotes + (increment ? 1 : -1),
      );
    }
    notifyListeners();
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 메시지 설정
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// 에러 메시지 초기화
  void _clearError() {
    _errorMessage = null;
  }

  /// 실패를 메시지로 변환
  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return '네트워크 연결을 확인해주세요';
    } else if (failure is ServerFailure) {
      return '서버 오류가 발생했습니다';
    } else if (failure is NotFoundFailure) {
      return '투표를 찾을 수 없습니다';
    } else if (failure is PermissionFailure) {
      return '권한이 없습니다';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return '캐시 오류가 발생했습니다';
    } else {
      return failure.message;
    }
  }

  /// 리소스 정리
  @override
  void dispose() {
    _voteStreams.clear();
    super.dispose();
  }
}