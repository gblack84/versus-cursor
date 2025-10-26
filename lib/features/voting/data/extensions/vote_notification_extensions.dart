import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/dialog/vote_notification.dart';
import '../../domain/entities/dialog/vote_options.dart';
import '/app/contracts/notification_types.dart';

/// Firebase Firestore extension for VoteNotification domain model
///
/// **Firebase Optimization Pattern**
/// Replaces VoteNotificationDto pattern with direct conversion.
///
/// **Complex Conversions:**
/// 1. Timestamp ↔ DateTime for all time fields
/// 2. optionA/optionB Maps ↔ VoteOptions Value Object
/// 3. targetAudience Map ↔ String (JSON serialization)
/// 4. priority int ↔ NotificationPriority enum
///
/// **Document Structure:**
/// ```json
/// {
///   "id": "notification_123",
///   "userId": "user_abc",
///   "postId": "post_xyz",
///   "optionA": {"title": "...", "imageUrls": [...]},
///   "optionB": {"title": "...", "imageUrls": [...]},
///   "voteStartTime": Timestamp(...),
///   "voteEndTime": Timestamp(...),
///   ...
/// }
/// ```
///
/// See: /features/voting/data/models/vote_notification_dto.dart (to be deleted)
extension VoteNotificationFirestoreX on VoteNotification {
  /// Convert VoteNotification to Firestore-compatible map
  ///
  /// **Value Object Decomposition:**
  /// VoteOptions → optionA/optionB separate maps
  Map<String, dynamic> toFirestore() {
    return {
      // Base notification fields
      'userId': userId,
      'type': NotificationTypes.votingRequest,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      'metadata': metadata,

      // Vote specific fields
      'postId': postId,
      'postTitle': postTitle,
      'postContent': postContent,
      if (postDescription != null) 'postDescription': postDescription,
      if (senderId != null) 'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      if (body != null) 'body': body,

      // VoteOptions decomposition to optionA/optionB
      'optionA': {
        'title': voteOptions.optionATitle,
        if (voteOptions.optionADescription != null)
          'description': voteOptions.optionADescription,
        'imageUrls': voteOptions.optionAImageUrls,
        if (voteOptions.optionAAspectRatio != null)
          'aspectRatio': voteOptions.optionAAspectRatio,
      },
      'optionB': {
        'title': voteOptions.optionBTitle,
        if (voteOptions.optionBDescription != null)
          'description': voteOptions.optionBDescription,
        'imageUrls': voteOptions.optionBImageUrls,
        if (voteOptions.optionBAspectRatio != null)
          'aspectRatio': voteOptions.optionBAspectRatio,
      },

      // Vote time fields
      'voteStartTime': Timestamp.fromDate(voteStartTime),
      'voteEndTime': Timestamp.fromDate(voteEndTime),

      // Vote counts
      if (currentVotesA != null) 'votesA': currentVotesA,
      if (currentVotesB != null) 'votesB': currentVotesB,

      // User vote state
      'hasVoted': hasVoted,
      if (userVoteChoice != null) 'userVoteChoice': userVoteChoice,

      // Layout information
      'layoutType': voteOptions.layoutType,

      // Target audience (serialized as string)
      if (targetAudience != null) 'targetAudience': targetAudience,

      // Priority (enum to int)
      'priority': notificationPriority.weight,
    };
  }

  /// Create VoteNotification from Firestore DocumentSnapshot
  ///
  /// **Complex Parsing:**
  /// - optionA/optionB maps → VoteOptions value object
  /// - Multiple Timestamp → DateTime conversions
  /// - targetAudience map → JSON string
  static VoteNotification fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception(
        'VoteNotification document data is null for document: ${doc.id}',
      );
    }

    // Parse optionA and optionB into VoteOptions
    final optionA = data['optionA'] as Map<String, dynamic>? ?? {};
    final optionB = data['optionB'] as Map<String, dynamic>? ?? {};

    final voteOptions = VoteOptions(
      optionATitle: optionA['title'] as String? ?? '',
      optionBTitle: optionB['title'] as String? ?? '',
      optionADescription: optionA['description'] as String?,
      optionBDescription: optionB['description'] as String?,
      optionAImageUrls: (optionA['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      optionBImageUrls: (optionB['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      optionAAspectRatio: (optionA['aspectRatio'] as num?)?.toDouble(),
      optionBAspectRatio: (optionB['aspectRatio'] as num?)?.toDouble(),
      relatedInterests: (data['relatedInterests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      metadata: data['voteMetadata'] as Map<String, dynamic>? ?? {},
    );

    // Parse priority enum
    final priorityValue = data['priority'] as int? ?? 2;
    final priority = NotificationPriority.fromWeight(priorityValue);

    return VoteNotification(
      // Required fields with doc.id
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',

      // Optional common fields
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      expiryTime: (data['expiryTime'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},

      // Required vote fields
      postId: data['postId'] as String? ?? '',
      postTitle: data['postTitle'] as String? ?? '',
      postContent: data['postContent'] as String? ?? '',
      voteOptions: voteOptions,
      voteStartTime:
          (data['voteStartTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      voteEndTime:
          (data['voteEndTime'] as Timestamp?)?.toDate() ?? DateTime.now(),

      // Optional vote fields
      postDescription: data['postDescription'] as String?,
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      body: data['body'] as String?,
      targetAudience: data['targetAudience'] as String?,
      currentVotesA: data['votesA'] as int?,
      currentVotesB: data['votesB'] as int?,
      hasVoted: data['hasVoted'] as bool? ?? false,
      userVoteChoice: data['userVoteChoice'] as String?,
      notificationPriority: priority,
    );
  }
}

/// NOTE: NotificationPriority enum already has weight property and fromWeight method
/// defined in /app/contracts/notification_types.dart:
/// - low(1), medium(2), high(3), urgent(4)
/// - static fromWeight(int weight) method available
