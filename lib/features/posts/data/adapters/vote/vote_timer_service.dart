import 'dart:async';
import 'package:flutter/foundation.dart';
import '/core_exports.dart';

/// 투표 타이머 동기화 서비스
///
/// 모든 투표 카드 위젯이 동일한 남은 시간을 표시하도록
/// postId별로 단일 Timer를 관리하는 싱글톤 서비스
/// 서버 시간 동기화를 통해 모든 기기에서 동일한 시간 표시
class VoteTimerService extends ChangeNotifier {
  // 싱글톤 인스턴스
  static final VoteTimerService _instance = VoteTimerService._internal();
  factory VoteTimerService() => _instance;
  VoteTimerService._internal();

  // postId별 Stream Controller 관리
  final Map<String, StreamController<Duration>> _streamControllers = {};

  // postId별 Timer 관리 (자동 정리를 위해)
  final Map<String, Timer> _timers = {};

  // postId별 마지막 남은 시간 캐시 (즉시 표시용)
  final Map<String, Duration> _lastRemainingTimes = {};

  // 활성 리스너 수 추적 (메모리 관리용)
  final Map<String, int> _listenerCounts = {};

  // 서버 시간 동기화를 위한 오프셋
  Duration? _serverTimeOffset;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  /// 서버 시간과 동기화
  ///
  /// Firebase 서버 시간과 로컬 시간의 차이를 계산하여
  /// 모든 기기에서 동일한 시간을 사용하도록 함
  Future<void> syncServerTime() async {
    // 이미 동기화 중이거나 최근에 동기화했으면 스킵
    if (_isSyncing) return;
    if (_lastSyncTime != null &&
        DateTime.now().difference(_lastSyncTime!).inMinutes < 5) {
      return;
    }

    _isSyncing = true;

    try {
      // 로컬 시간 기록
      final localTimeBefore = DateTime.now();

      // 서버에 타임스탬프 요청
      final docRef =
          await FirebaseFirestore.instance.collection('timeSync').add({
        'timestamp': FieldValue.serverTimestamp(),
        'localTime': localTimeBefore.toIso8601String(),
      });

      // 서버 시간 받기
      final doc = await docRef.get();
      final serverTimestamp = doc.data()?['timestamp'] as Timestamp?;

      if (serverTimestamp != null) {
        final localTimeAfter = DateTime.now();
        final serverTime = serverTimestamp.toDate();

        // 네트워크 왕복 시간의 절반을 보정
        final networkLatency = localTimeAfter.difference(localTimeBefore);
        final estimatedServerTime = serverTime
            .add(Duration(milliseconds: networkLatency.inMilliseconds ~/ 2));

        // 오프셋 계산 (서버 시간 - 로컬 시간)
        _serverTimeOffset = estimatedServerTime.difference(localTimeAfter);
        _lastSyncTime = DateTime.now();

        if (kDebugMode) {
          print(
              '[VoteTimerService] Server time synced. Offset: ${_serverTimeOffset?.inSeconds} seconds');
        }

        // 문서 정리
        await docRef.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print('[VoteTimerService] Failed to sync server time: $e');
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// 동기화된 현재 시간 가져오기
  ///
  /// 서버 시간 오프셋이 있으면 적용하고, 없으면 로컬 시간 사용
  DateTime get synchronizedNow {
    final now = DateTime.now();
    if (_serverTimeOffset != null) {
      return now.add(_serverTimeOffset!);
    }
    return now;
  }

  /// 특정 투표의 남은 시간 Stream 가져오기
  ///
  /// 이미 존재하는 Stream이 있으면 재사용하고,
  /// 없으면 새로 생성하여 반환
  Stream<Duration> getRemainingTimeStream(String postId, DateTime voteEndTime) {
    // 서버 시간 동기화 시도 (비동기로 실행)
    syncServerTime();

    // 이미 Stream이 존재하면 재사용
    if (_streamControllers.containsKey(postId)) {
      _incrementListenerCount(postId);
      return _streamControllers[postId]!.stream;
    }

    // 새 Stream 생성
    _createTimerStream(postId, voteEndTime);

    // cleanup으로 인해 controller가 제거된 경우 체크
    // (이미 만료된 투표의 경우 _createTimerStream에서 즉시 cleanup 호출)
    if (!_streamControllers.containsKey(postId)) {
      // 만료된 투표에 대해 즉시 Duration.zero 스트림 반환
      if (kDebugMode) {
        print(
            '[VoteTimerService] Vote already expired for postId: $postId, returning zero duration stream');
      }
      return Stream.value(Duration.zero);
    }

    _incrementListenerCount(postId);
    return _streamControllers[postId]!.stream;
  }

  /// 캐시된 마지막 남은 시간 즉시 가져오기
  ///
  /// Stream 구독 전에 즉시 표시할 값이 필요한 경우 사용
  Duration? getCachedRemainingTime(String postId) {
    return _lastRemainingTimes[postId];
  }

  /// 특정 투표의 Timer Stream 생성
  void _createTimerStream(String postId, DateTime voteEndTime) {
    // Broadcast Stream Controller 생성
    final controller = StreamController<Duration>.broadcast(
      onCancel: () => _handleStreamCancel(postId),
    );
    _streamControllers[postId] = controller;

    // 초기 남은 시간 계산 (동기화된 시간 사용)
    final now = synchronizedNow;
    final initialRemaining = voteEndTime.difference(now);

    // 이미 만료된 경우
    if (initialRemaining.isNegative) {
      _lastRemainingTimes[postId] = Duration.zero;
      controller.add(Duration.zero);
      _cleanup(postId);
      return;
    }

    // 초기값 캐시 및 전송
    _lastRemainingTimes[postId] = initialRemaining;
    controller.add(initialRemaining);

    // 1초마다 업데이트하는 Timer 생성
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 동기화된 시간 사용
      final now = synchronizedNow;
      final remaining = voteEndTime.difference(now);

      if (remaining.isNegative || remaining.inSeconds <= 0) {
        // 타이머 만료
        _lastRemainingTimes[postId] = Duration.zero;
        if (!controller.isClosed) {
          controller.add(Duration.zero);
        }
        timer.cancel();
        _cleanup(postId);
      } else {
        // 남은 시간 업데이트
        _lastRemainingTimes[postId] = remaining;
        if (!controller.isClosed) {
          controller.add(remaining);
        }
      }
    });

    _timers[postId] = timer;

    if (kDebugMode) {
      print('[VoteTimerService] Timer created for postId: $postId');
      print(
          '[VoteTimerService] Initial remaining time: ${initialRemaining.inSeconds} seconds');
      print(
          '[VoteTimerService] Using synchronized time (offset: ${_serverTimeOffset?.inSeconds ?? 0} seconds)');
    }
  }

  /// 리스너 수 증가
  void _incrementListenerCount(String postId) {
    _listenerCounts[postId] = (_listenerCounts[postId] ?? 0) + 1;

    if (kDebugMode) {
      print(
          '[VoteTimerService] Listener added for $postId. Total: ${_listenerCounts[postId]}');
    }
  }

  /// 리스너 수 감소
  void _decrementListenerCount(String postId) {
    if (_listenerCounts.containsKey(postId)) {
      _listenerCounts[postId] = _listenerCounts[postId]! - 1;

      if (kDebugMode) {
        print(
            '[VoteTimerService] Listener removed for $postId. Remaining: ${_listenerCounts[postId]}');
      }

      // 모든 리스너가 해제되면 정리
      if (_listenerCounts[postId]! <= 0) {
        _cleanup(postId);
      }
    }
  }

  /// Stream 취소 핸들러
  void _handleStreamCancel(String postId) {
    _decrementListenerCount(postId);
  }

  /// 특정 투표의 Timer 및 관련 리소스 정리
  void _cleanup(String postId) {
    if (kDebugMode) {
      print('[VoteTimerService] Cleaning up resources for postId: $postId');
    }

    // Timer 정리
    _timers[postId]?.cancel();
    _timers.remove(postId);

    // Stream Controller 정리
    _streamControllers[postId]?.close();
    _streamControllers.remove(postId);

    // 캐시 정리 (선택적 - 일정 시간 유지할 수도 있음)
    Future.delayed(const Duration(minutes: 1), () {
      _lastRemainingTimes.remove(postId);
    });

    // 리스너 카운트 정리
    _listenerCounts.remove(postId);

    notifyListeners();
  }

  /// 모든 Timer 정리 (앱 종료 시)
  void disposeAll() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();

    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();

    _lastRemainingTimes.clear();
    _listenerCounts.clear();

    if (kDebugMode) {
      print('[VoteTimerService] All timers and resources disposed');
    }
  }

  /// 현재 활성 Timer 수 (디버깅용)
  int get activeTimerCount => _timers.length;

  /// 현재 활성 Stream 수 (디버깅용)
  int get activeStreamCount => _streamControllers.length;
}
