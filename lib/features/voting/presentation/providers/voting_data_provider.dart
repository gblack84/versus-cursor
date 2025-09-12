import 'package:flutter/material.dart';
import '../../domain/models/vote_model.dart';
import '../../domain/models/vote_counts_model.dart';
import '../../domain/models/rankings_model.dart';
import '../../domain/usecases/stream_vote_counts_use_case.dart';
import '../../domain/usecases/stream_rankings_use_case.dart';
import '../../domain/usecases/get_vote_history_use_case.dart';

/// 투표 데이터 캐싱 및 동기화를 관리하는 Provider
/// 
/// 주요 책임:
/// - 투표 데이터 캐싱 관리
/// - 실시간 데이터 동기화
/// - 메모리 효율적인 캐시 관리
/// - 오프라인 지원
class VotingDataProvider extends ChangeNotifier {
  final StreamVoteCountsUseCase _streamVoteCountsUseCase;
  final StreamRankingsUseCase _streamRankingsUseCase;
  final GetVoteHistoryUseCase _getVoteHistoryUseCase;

  // 캐시 저장소
  final Map<String, VoteCounts> _voteCountsCache = {};
  final Map<String, Vote> _userVotesCache = {};
  final List<RankingsModel> _rankingsCache = [];
  final Map<String, List<Vote>> _voteHistoryCache = {};
  
  // 스트림 구독 관리
  final Map<String, dynamic> _activeStreams = {};
  
  // 캐시 유효성 관리
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  
  // 상태 변수
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  int _cacheHitCount = 0;
  int _cacheMissCount = 0;

  // Getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  double get cacheHitRate => 
    (_cacheHitCount + _cacheMissCount) > 0 
      ? _cacheHitCount / (_cacheHitCount + _cacheMissCount) 
      : 0.0;
  int get cachedItemsCount => 
    _voteCountsCache.length + _userVotesCache.length + _rankingsCache.length;

  VotingDataProvider({
    required StreamVoteCountsUseCase streamVoteCountsUseCase,
    required StreamRankingsUseCase streamRankingsUseCase,
    required GetVoteHistoryUseCase getVoteHistoryUseCase,
  })  : _streamVoteCountsUseCase = streamVoteCountsUseCase,
        _streamRankingsUseCase = streamRankingsUseCase,
        _getVoteHistoryUseCase = getVoteHistoryUseCase;

  /// 투표 수 가져오기 (캐시 우선)
  VoteCounts? getVoteCounts(String postId) {
    if (_isValidCache(postId)) {
      _cacheHitCount++;
      return _voteCountsCache[postId];
    }
    
    _cacheMissCount++;
    _subscribeToVoteCounts(postId);
    return null;
  }

  /// 사용자 투표 정보 가져오기 (캐시 우선)
  Vote? getUserVote(String postId, String userId) {
    final key = '${postId}_$userId';
    if (_userVotesCache.containsKey(key)) {
      _cacheHitCount++;
      return _userVotesCache[key];
    }
    
    _cacheMissCount++;
    return null;
  }

  /// 랭킹 데이터 가져오기
  List<RankingsModel> getRankings() {
    if (_rankingsCache.isNotEmpty && _isValidCache('rankings')) {
      _cacheHitCount++;
      return List.unmodifiable(_rankingsCache);
    }
    
    _cacheMissCount++;
    _subscribeToRankings();
    return [];
  }

  /// 투표 이력 가져오기
  Future<List<Vote>> getVoteHistory(String userId) async {
    if (_voteHistoryCache.containsKey(userId) && _isValidCache('history_$userId')) {
      _cacheHitCount++;
      return _voteHistoryCache[userId]!;
    }

    _cacheMissCount++;
    final result = await _getVoteHistoryUseCase(userId);
    
    result.fold(
      (_) => [],
      (history) {
        _voteHistoryCache[userId] = history;
        _updateCacheTimestamp('history_$userId');
      },
    );
    
    return _voteHistoryCache[userId] ?? [];
  }

  /// 투표 수 캐시 업데이트
  void updateVoteCountsCache(String postId, VoteCounts counts) {
    _voteCountsCache[postId] = counts;
    _updateCacheTimestamp(postId);
    notifyListeners();
  }

  /// 사용자 투표 캐시 업데이트
  void updateUserVoteCache(String postId, String userId, Vote? vote) {
    final key = '${postId}_$userId';
    if (vote != null) {
      _userVotesCache[key] = vote;
    } else {
      _userVotesCache.remove(key);
    }
    notifyListeners();
  }

  /// 랭킹 캐시 업데이트
  void updateRankingsCache(List<RankingsModel> rankings) {
    _rankingsCache.clear();
    _rankingsCache.addAll(rankings);
    _updateCacheTimestamp('rankings');
    notifyListeners();
  }

  /// 투표 수 스트림 구독
  void _subscribeToVoteCounts(String postId) {
    if (_activeStreams.containsKey('counts_$postId')) return;

    final params = StreamVoteCountsParams(postId: postId);
    final stream = _streamVoteCountsUseCase(params);
    
    _activeStreams['counts_$postId'] = stream.listen((result) {
      result.fold(
        (_) => {}, // 에러 무시
        (countsList) {
          if (countsList.isNotEmpty) {
            // VotecountsModel을 VoteCounts로 변환
            final model = countsList.first;
            final counts = VoteCounts(
              votesA: model.votesA ?? 0,
              votesB: model.votesB ?? 0,
              totalVotes: (model.votesA ?? 0) + (model.votesB ?? 0),
            );
            updateVoteCountsCache(postId, counts);
          }
        },
      );
    });
  }

  /// 랭킹 스트림 구독
  void _subscribeToRankings() {
    if (_activeStreams.containsKey('rankings')) return;

    final params = StreamRankingsParams(limit: 100);
    final stream = _streamRankingsUseCase(params);
    
    _activeStreams['rankings'] = stream.listen((result) {
      result.fold(
        (_) => {}, // 에러 무시
        (rankings) => updateRankingsCache(rankings),
      );
    });
  }

  /// 캐시 유효성 검사
  bool _isValidCache(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key]!;
    final now = DateTime.now();
    return now.difference(timestamp) < _cacheValidDuration;
  }

  /// 캐시 타임스탬프 업데이트
  void _updateCacheTimestamp(String key) {
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 전체 캐시 동기화
  Future<void> syncAllData() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // 랭킹 데이터 동기화
      _subscribeToRankings();
      
      // 활성 투표 수 스트림 재구독
      final postIds = _voteCountsCache.keys.toList();
      for (final postId in postIds) {
        _subscribeToVoteCounts(postId);
      }

      _lastSyncTime = DateTime.now();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// 캐시 정리 (메모리 관리)
  void clearExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheValidDuration) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _cacheTimestamps.remove(key);
      
      if (key.startsWith('history_')) {
        _voteHistoryCache.remove(key.substring(8));
      } else if (key == 'rankings') {
        _rankingsCache.clear();
      } else {
        _voteCountsCache.remove(key);
      }
    }

    if (expiredKeys.isNotEmpty) {
      notifyListeners();
    }
  }

  /// 특정 포스트의 캐시 무효화
  void invalidatePostCache(String postId) {
    _voteCountsCache.remove(postId);
    _cacheTimestamps.remove(postId);
    
    // 관련 사용자 투표도 제거
    final keysToRemove = _userVotesCache.keys
        .where((key) => key.startsWith('${postId}_'))
        .toList();
    
    for (final key in keysToRemove) {
      _userVotesCache.remove(key);
    }
    
    notifyListeners();
  }

  /// 캐시 통계 초기화
  void resetCacheStatistics() {
    _cacheHitCount = 0;
    _cacheMissCount = 0;
    notifyListeners();
  }

  /// 전체 캐시 초기화
  void clearAllCache() {
    _voteCountsCache.clear();
    _userVotesCache.clear();
    _rankingsCache.clear();
    _voteHistoryCache.clear();
    _cacheTimestamps.clear();
    resetCacheStatistics();
    notifyListeners();
  }

  /// 리소스 정리
  @override
  void dispose() {
    // 모든 스트림 구독 취소
    for (final subscription in _activeStreams.values) {
      if (subscription != null) {
        subscription.cancel();
      }
    }
    _activeStreams.clear();
    
    // 캐시 정리
    clearAllCache();
    
    super.dispose();
  }
}