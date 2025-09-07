/// Core Event System for Cross-Feature Communication
/// 
/// Features communicate through events to maintain isolation
/// and follow Clean Architecture principles

import 'dart:async';

/// Event Bus for cross-feature communication
class EventBus {
  factory EventBus() => _instance;
  EventBus._internal();
  static final EventBus _instance = EventBus._internal();
  
  final Map<Type, StreamController> _controllers = {};
  
  /// Publish an event
  void publish<T extends Event>(T event) {
    final controller = _controllers[T];
    if (controller != null) {
      controller.add(event);
    }
  }
  
  /// Subscribe to events of type T
  Stream<T> on<T extends Event>() {
    _controllers[T] ??= StreamController<T>.broadcast();
    return (_controllers[T] as StreamController<T>).stream;
  }
  
  /// Dispose all controllers
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

/// Base event class
abstract class Event {
  Event() : timestamp = DateTime.now();
  
  final DateTime timestamp;
}

/// User profile updated event
class UserProfileUpdatedEvent extends Event {
  UserProfileUpdatedEvent({
    required this.userId,
    required this.profile,
  });
  
  final String userId;
  final Map<String, dynamic> profile;
}

/// User cache invalidation event
class UserCacheInvalidationEvent extends Event {
  UserCacheInvalidationEvent({required this.userId});
  
  final String userId;
}

/// Post vote updated event
class PostVoteUpdatedEvent extends Event {
  PostVoteUpdatedEvent({
    required this.postId,
    required this.userId,
    required this.option,
  });
  
  final String postId;
  final String userId;
  final String option;
}