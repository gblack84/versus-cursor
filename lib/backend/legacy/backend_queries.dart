// ============================================================================
// Legacy Backend Queries
// These functions are deprecated and should be replaced with repository pattern
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

// Import models temporarily until migration is complete
import '../../features/profile/domain/models/user_profile.dart';
import '../models/post/posts_model.dart';
// CommentsModel is now in features
import '../models/post/comments_model.dart';
import '../models/chat/messages_model.dart';
import '../../features/chat/domain/models/chats_model.dart';
import '../../features/notifications/domain/models/notifications_model.dart';
import '../../features/voting/domain/models/votes_model.dart';

// ============================================================================
// USER QUERIES (Deprecated - Use ProfileRepository)
// ============================================================================

@Deprecated('Use ProfileRepository.getUser() instead')
Stream<UserProfile> queryUsersRecord({
  Query Function(Query)? queryBuilder,
  DocumentReference? singleRecord,
  bool singleRecordBuilder = false,
}) {
  Query query = FirebaseFirestore.instance.collection('users');
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (singleRecord != null) {
    return singleRecord.snapshots().map((s) => UserProfile.fromSnapshot(s));
  }
  
  return query.snapshots().map((snapshot) {
    if (singleRecordBuilder && snapshot.docs.isNotEmpty) {
      return UserProfile.fromSnapshot(snapshot.docs.first);
    }
    // This is a simplified version - actual implementation would handle multiple records
    return UserProfile.fromSnapshot(snapshot.docs.first);
  });
}

@Deprecated('Use ProfileRepository.getUserFuture() instead')
Future<List<UserProfile>> queryUsersRecordOnce({
  Query Function(Query)? queryBuilder,
  DocumentReference? singleRecord,
  bool singleRecordBuilder = false,
}) async {
  Query query = FirebaseFirestore.instance.collection('users');
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  
  if (singleRecord != null) {
    final snapshot = await singleRecord.get();
    return [UserProfile.fromSnapshot(snapshot)];
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => UserProfile.fromSnapshot(doc)).toList();
}

// ============================================================================
// POST QUERIES (Deprecated - Use PostRepository)
// ============================================================================

@Deprecated('Use PostRepository.streamPosts() instead')
Stream<List<PostsModel>> queryPostsRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = FirebaseFirestore.instance.collection('posts');
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => PostsModel.fromSnapshot(doc)).toList();
  });
}

@Deprecated('Use PostRepository.getPosts() instead')
Future<List<PostsModel>> queryPostsRecordOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) async {
  Query query = FirebaseFirestore.instance.collection('posts');
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => PostsModel.fromSnapshot(doc)).toList();
}

// ============================================================================
// COMMENT QUERIES (Deprecated - Use PostRepository)
// ============================================================================

@Deprecated('Use PostRepository.streamComments() instead')
Stream<List<ContentCommentsModel>> queryCommentsRecord({
  Query Function(Query)? queryBuilder,
  DocumentReference? parent,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = parent != null
      ? parent.collection('comments')
      : FirebaseFirestore.instance.collectionGroup('comments');
      
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => ContentCommentsModel.fromSnapshot(doc)).toList();
  });
}

// ============================================================================
// CHAT QUERIES (Deprecated - Use ChatRepository)
// ============================================================================

@Deprecated('Use ChatRepository.streamChats() instead')
Stream<List<ChatsModel>> queryChatsRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = FirebaseFirestore.instance.collection('chats');
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => ChatsModel.fromSnapshot(doc)).toList();
  });
}

@Deprecated('Use ChatRepository.streamMessages() instead')
Stream<List<MessagesModel>> queryMessagesRecord({
  Query Function(Query)? queryBuilder,
  DocumentReference? parent,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = parent != null
      ? parent.collection('messages')
      : FirebaseFirestore.instance.collectionGroup('messages');
      
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => MessagesModel.fromSnapshot(doc)).toList();
  });
}

// ============================================================================
// NOTIFICATION QUERIES (Deprecated - Use NotificationRepository)
// ============================================================================

@Deprecated('Use NotificationRepository.streamNotifications() instead')
Stream<List<NotificationsModel>> queryNotificationsRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = FirebaseFirestore.instance.collection('notifications');
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => NotificationsModel.fromSnapshot(doc)).toList();
  });
}

// ============================================================================
// VOTE QUERIES (Deprecated - Use VotingRepository)
// ============================================================================

@Deprecated('Use VotingRepository.streamVotes() instead')
Stream<List<VotesModel>> queryVotesRecord({
  Query Function(Query)? queryBuilder,
  DocumentReference? parent,
  int limit = -1,
  bool singleRecord = false,
}) {
  Query query = parent != null
      ? parent.collection('votes')
      : FirebaseFirestore.instance.collectionGroup('votes');
      
  if (queryBuilder != null) {
    query = queryBuilder(query);
  }
  if (limit > 0) {
    query = query.limit(limit);
  }
  
  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => VotesModel.fromSnapshot(doc)).toList();
  });
}

// Add all other legacy query functions here...
// This is a simplified version - the actual file would contain all 50+ query functions