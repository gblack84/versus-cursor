import 'dart:async';

/// Global event bus for cross-feature communication
///
/// This singleton provides a publish-subscribe mechanism
/// for loose coupling between features
class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _streamController = StreamController<dynamic>.broadcast();

  /// Fire an event to all listeners
  void fire(dynamic event) {
    if (!_streamController.isClosed) {
      _streamController.add(event);
    }
  }

  /// Listen to events of a specific type
  Stream<T> on<T>() {
    return _streamController.stream.where((event) => event is T).cast<T>();
  }

  /// Dispose the event bus (call on app termination)
  void dispose() {
    _streamController.close();
  }
}
