import 'dart:async';

/// Vote timer management port interface
/// 
/// This interface abstracts timer functionality to remove
/// cross-feature dependency on posts feature
abstract class IVoteTimerPort {
  /// Start a timer for a specific post
  void startTimer({
    required String postId,
    required DateTime voteEndTime,
  });

  /// Stop a timer for a specific post
  void stopTimer(String postId);

  /// Get remaining time stream for a post
  Stream<Duration> getRemainingTimeStream(String postId, DateTime voteEndTime);

  /// Get cached remaining time
  Duration? getCachedRemainingTime(String postId);

  /// Sync server time for accurate timer
  Future<void> syncServerTime();

  /// Get synchronized current time
  DateTime get synchronizedNow;

  /// Get active timer count (for debugging)
  int get activeTimerCount;

  /// Get active stream count (for debugging)
  int get activeStreamCount;
}