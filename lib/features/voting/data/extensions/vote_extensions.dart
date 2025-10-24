import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/vote.dart';

/// Firebase Firestore extension for Vote domain model
///
/// **Firebase Optimization Pattern**
/// Replaces VoteDto + VoteMapper pattern with direct conversion.
/// This eliminates intermediate layers while maintaining clean separation.
///
/// **Architecture Decision:**
/// Vote uses composite key pattern (postId + userId) instead of document ID.
/// - Document path: `posts/{postId}/votes/{userId}`
/// - userId serves as document ID
/// - postId is extracted from parent collection reference
///
/// **Field Removal Rationale:**
/// - ❌ `id` field: Removed - uses composite key, no need for separate ID
/// - ❌ `userInfo` field: Removed - dead code, always null in original mapper
///
/// See: /features/voting/data/models/vote_dto.dart (deleted)
/// See: /features/voting/data/mappers/vote_mapper.dart (deleted)
extension VoteFirestoreX on Vote {
  /// Convert Vote to Firestore-compatible map
  ///
  /// **Document Structure:**
  /// ```json
  /// {
  ///   "userId": "user_abc123",
  ///   "choice": "A",
  ///   "timestamp": Timestamp(...)
  /// }
  /// ```
  ///
  /// **Note:** `postId` is NOT stored in document - it's in the collection path
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'choice': choice,
        'timestamp': timestamp != null
            ? Timestamp.fromDate(timestamp!)
            : FieldValue.serverTimestamp(),
      };

  /// Create Vote from Firestore DocumentSnapshot
  ///
  /// **Path Extraction:**
  /// Given document reference: `posts/post123/votes/user456`
  /// - doc.id = "user456" (userId)
  /// - doc.reference.parent.parent.id = "post123" (postId)
  ///
  /// **Error Handling:**
  /// Throws exception if:
  /// - Document data is null
  /// - postId cannot be extracted from path (invalid subcollection structure)
  static Vote fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Vote document data is null for document: ${doc.id}');
    }

    // Extract postId from subcollection path: posts/{postId}/votes/{userId}
    final postId = doc.reference.parent.parent?.id ?? '';
    if (postId.isEmpty) {
      throw Exception(
        'Cannot extract postId from vote document path: ${doc.reference.path}',
      );
    }

    return Vote(
      postId: postId,
      userId: data['userId'] as String,
      choice: data['choice'] as String,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
