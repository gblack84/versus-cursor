import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/weight.dart';

/// Firebase Firestore extension for Weight domain model
///
/// **Firebase Optimization Pattern**
/// Replaces WeightDto pattern with direct conversion.
///
/// **Document Structure:**
/// ```json
/// {
///   "nameInterest": "Technology",
///   "scoreInterest": 85
/// }
/// ```
///
/// **Field Removal Rationale:**
/// - ❌ `reference` field: Removed - available via DocumentSnapshot, not stored
///
/// See: /features/voting/data/models/weight_dto.dart (to be deleted)
extension WeightFirestoreX on Weight {
  /// Convert Weight to Firestore-compatible map
  ///
  /// Note: DocumentReference is not stored, obtained from snapshot
  Map<String, dynamic> toFirestore() => {
        'nameInterest': nameInterest,
        'scoreInterest': scoreInterest,
      };

  /// Create Weight from Firestore DocumentSnapshot
  ///
  /// **Error Handling:**
  /// Provides default values for missing fields (nameInterest: '', scoreInterest: 0)
  static Weight fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Weight document data is null for document: ${doc.id}');
    }

    return Weight(
      nameInterest: data['nameInterest'] as String? ?? '',
      scoreInterest: data['scoreInterest'] as int? ?? 0,
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
