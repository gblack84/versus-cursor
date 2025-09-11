/// Event fired when a vote notification is tapped
class VoteNotificationTappedEvent {
  final String postId;
  final String notificationId;
  final Map<String, dynamic> metadata;

  VoteNotificationTappedEvent({
    required this.postId,
    required this.notificationId,
    required this.metadata,
  });
}

/// Event fired when a chat notification is tapped
class ChatNotificationTappedEvent {
  final String chatId;
  final String notificationId;
  final Map<String, dynamic> metadata;

  ChatNotificationTappedEvent({
    required this.chatId,
    required this.notificationId,
    required this.metadata,
  });
}

/// Event fired when a social notification is tapped
class SocialNotificationTappedEvent {
  final String userId;
  final String notificationId;
  final String type; // follow, like, comment, etc.
  final Map<String, dynamic> metadata;

  SocialNotificationTappedEvent({
    required this.userId,
    required this.notificationId,
    required this.type,
    required this.metadata,
  });
}
