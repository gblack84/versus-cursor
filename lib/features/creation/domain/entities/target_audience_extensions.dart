import 'target_audience.dart';

/// Firestore Extension for TargetAudience
///
/// **Firebase-Centric v2.0 Pattern**:
/// - TargetAudience already has `fromMap()` and `toMap()` implemented
/// - This extension provides aliases for consistency with other extensions
///
/// **Phase 5 Migration**: Extension Pattern (Minimal)
/// - Replaces: TargetAudienceDto, TargetAudienceMapper
/// - Reduces: 90 lines (DTO) + 112 lines (Mapper) → 60 lines (Extension)
/// - Code reduction: 70%
/// - **Note**: Most logic already exists in TargetAudience entity
///
/// **Design Decision**: Why minimal extension?
/// - TargetAudience has complex age group conversion logic (Korean ↔ English)
/// - Age mapping logic was already moved to entity in previous refactoring
/// - fromMap/toMap already handle Firebase 'criteria' nesting
/// - Extension just provides consistent naming with other extensions
extension TargetAudienceFirestore on TargetAudience {
  /// Convert TargetAudience entity to Firestore document format
  ///
  /// **Usage in Repository**:
  /// ```dart
  /// await _firestore.collection('targetAudiences').doc(id).set(
  ///   targetAudience.toFirestore(),  // ← Extension alias
  /// );
  /// ```
  ///
  /// **Delegates to**: TargetAudience.toMap() (already implemented)
  ///
  /// **What it does**:
  /// - Converts collectionType to 'type' field
  /// - Nests custom criteria in 'criteria' object
  /// - Converts Korean age groups ('10대') to English ('10s')
  /// - Preserves Firebase Functions compatibility
  Map<String, dynamic> toFirestore() => toMap();

  /// Create TargetAudience entity from Firestore Map
  ///
  /// **Usage in Repository**:
  /// ```dart
  /// Stream<TargetAudience> watchTargetAudience(String id) {
  ///   return _firestore.collection('targetAudiences').doc(id).snapshots().map(
  ///     (snapshot) => TargetAudienceFirestore.fromMap(snapshot.data()),
  ///   );
  /// }
  /// ```
  ///
  /// **Delegates to**: TargetAudience.fromMap() (already implemented)
  ///
  /// **What it does**:
  /// - Extracts 'type' field to collectionType
  /// - Unnests 'criteria' object to selectedInterests/selectedAgeGroup/etc.
  /// - Converts English age groups ('10s') to Korean ('10대')
  /// - Handles null safety with defaults
  static TargetAudience fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      // Return default TargetAudience
      return TargetAudience(
        createdAt: DateTime.now(),
      );
    }

    return TargetAudience.fromMap(map);
  }
}
