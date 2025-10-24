import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/vote_expansion_request.dart';

/// Firebase Firestore extension for VoteExpansionRequest domain model
///
/// **Firebase Optimization Pattern**
/// Replaces VoteExpansionRequestDto pattern with direct conversion.
///
/// **Document Structure:**
/// ```json
/// {
///   "userId": "user_abc123",
///   "pointsUsed": 100,
///   "additionalUserCount": 50,
///   "createdAt": Timestamp(...)
/// }
/// ```
///
/// **Field Removal Rationale:**
/// - ❌ `reference` field: Removed - available via DocumentSnapshot, not stored
///
/// **Type Conversion:**
/// - `createdAt`: Timestamp (Firestore) ↔ DateTime (Domain)
///
/// See: /features/voting/data/models/vote_expansion_request_dto.dart (to be deleted)
extension VoteExpansionRequestFirestoreX on VoteExpansionRequest {
  /// Convert VoteExpansionRequest to Firestore-compatible map
  ///
  /// **Timestamp Conversion:**
  /// - DateTime → Timestamp for Firestore storage
  /// - null values handled with conditional map entries
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{
      'userId': userId,
      'pointsUsed': pointsUsed,
      'additionalUserCount': additionalUserCount,
    };

    // Only add createdAt if not null
    if (createdAt != null) {
      map['createdAt'] = Timestamp.fromDate(createdAt!);
    }

    return map;
  }

  /// Create VoteExpansionRequest from Firestore DocumentSnapshot
  ///
  /// **Timestamp Conversion:**
  /// - Firestore Timestamp → DateTime
  /// - Handles null createdAt gracefully
  ///
  /// **Error Handling:**
  /// Provides default values for missing fields
  static VoteExpansionRequest fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception(
        'VoteExpansionRequest document data is null for document: ${doc.id}',
      );
    }

    return VoteExpansionRequest(
      userId: data['userId'] as String? ?? '',
      pointsUsed: data['pointsUsed'] as int? ?? 0,
      additionalUserCount: data['additionalUserCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Helper: Get DocumentReference from snapshot
  ///
  /// Utility for code that needs DocumentReference.
  /// Not stored in domain model, accessed from snapshot context.
  static DocumentReference getReferenceFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) =>
      doc.reference;
}
