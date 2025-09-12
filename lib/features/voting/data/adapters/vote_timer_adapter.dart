import 'dart:async';
import '/features/voting/domain/ports/i_vote_timer_port.dart';

/// Adapter implementation for vote timer functionality
/// 
/// This adapter wraps the VoteTimerService from posts feature
/// to provide a clean abstraction through the port interface.
/// The actual service is injected via dependency injection to avoid
/// direct cross-feature dependencies.
class VoteTimerAdapter implements IVoteTimerPort {
  final dynamic _voteTimerService; // Injected from DI container

  VoteTimerAdapter(this._voteTimerService);

  @override
  void startTimer({
    required String postId,
    required DateTime voteEndTime,
  }) {
    _voteTimerService.startTimer(
      postId: postId,
      voteEndTime: voteEndTime,
    );
  }

  @override
  void stopTimer(String postId) {
    _voteTimerService.stopTimer(postId);
  }

  @override
  Stream<Duration> getRemainingTimeStream(String postId, DateTime voteEndTime) {
    return _voteTimerService.getRemainingTimeStream(postId, voteEndTime);
  }

  @override
  Duration? getCachedRemainingTime(String postId) {
    return _voteTimerService.getCachedRemainingTime(postId);
  }

  @override
  Future<void> syncServerTime() async {
    await _voteTimerService.syncServerTime();
  }

  @override
  DateTime get synchronizedNow => _voteTimerService.synchronizedNow;

  @override
  int get activeTimerCount => _voteTimerService.activeTimerCount;

  @override
  int get activeStreamCount => _voteTimerService.activeStreamCount;
}