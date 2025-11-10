// ============================================
// LEGACY FIRESTORE RECORD PATTERN
// Temporary location for legacy models migration
// ============================================
//
// This file contains the deprecated FirestoreRecord pattern
// used by 4 legacy models:
// 1. ImageModerationModel (CRITICAL - content moderation)
// 2. SearchesModel (Search Feature - migrating to Extension Pattern)
// 3. EncodingsModel (DEPRECATED - checking Firebase Functions dependency)
// 4. ClientModel (UNUSED - safe to delete)
//
// TODO: Migrate all models to Extension Pattern (Phase 5)
// After migration complete, this file can be deleted.
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Color;
import '/core/types/lat_lng.dart';
import '/app/router/navigation/serialization_util.dart'
    show AppColorSerialization;
import '/core/firebase/firestore_util.dart'
    show mergeNestedFields, GeoPointExtension, LatLngExtension;

export 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentSnapshot, DocumentReference, Timestamp, GeoPoint;

// ============================================
// TYPE DEFINITIONS
// ============================================

/// Record builder function type for creating model instances from Firestore snapshots
typedef RecordBuilder<T> = T Function(DocumentSnapshot snapshot);

// ============================================
// LEGACY FIRESTORE RECORD PATTERN
// ============================================

/// Abstract base class for legacy Firestore models
///
/// Used by 4 models:
/// - ImageModerationModel (services/moderation)
/// - SearchesModel (features/search)
/// - EncodingsModel (services/media)
/// - ClientModel (core/models - unused)
///
/// @deprecated Use Extension Pattern instead (fromFirestore/toFirestore)
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, this.snapshotData);

  /// Firestore document snapshot data
  Map<String, dynamic> snapshotData;

  /// Firestore document reference
  DocumentReference reference;
}

// ============================================
// LEGACY CONVERTERS
// ============================================

/// Convert Firestore data to app model format
///
/// Handles:
/// - Timestamp → DateTime conversion
/// - GeoPoint → LatLng conversion
/// - Nested data recursion
///
/// @deprecated Use Extension Pattern instead
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) =>
    mergeNestedFields(data).map((key, value) {
      // Handle Timestamp → DateTime
      if (value is Timestamp) {
        value = value.toDate();
      }
      // Handle list of Timestamp
      if (value is Iterable && value.isNotEmpty && value.first is Timestamp) {
        value = value.map((v) => (v as Timestamp).toDate()).toList();
      }
      // Handle GeoPoint → LatLng
      if (value is GeoPoint) {
        value = value.toLatLng();
      }
      // Handle list of GeoPoint
      if (value is Iterable && value.isNotEmpty && value.first is GeoPoint) {
        value = value.map((v) => (v as GeoPoint).toLatLng()).toList();
      }
      // Handle nested data
      if (value is Map) {
        value = mapFromFirestore(value as Map<String, dynamic>);
      }
      // Handle list of nested data
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapFromFirestore(v as Map<String, dynamic>))
            .toList();
      }
      return MapEntry(key, value);
    });

/// Convert app model to Firestore format
///
/// Handles:
/// - LatLng → GeoPoint conversion
/// - Color → CSS String conversion
/// - Nested data recursion
///
/// @deprecated Use Extension Pattern instead
Map<String, dynamic> mapToFirestore(Map<String, dynamic> data) =>
    data.map((key, value) {
      // Handle LatLng → GeoPoint
      if (value is LatLng) {
        value = value.toGeoPoint();
      }
      // Handle list of LatLng
      if (value is Iterable && value.isNotEmpty && value.first is LatLng) {
        value = value.map((v) => (v as LatLng).toGeoPoint()).toList();
      }
      // Handle Color → CSS String
      if (value is Color) {
        value = AppColorSerialization(value).toCssString();
      }
      // Handle list of Color
      if (value is Iterable && value.isNotEmpty && value.first is Color) {
        value = value
            .map((v) => AppColorSerialization(v as Color).toCssString())
            .toList();
      }
      // Handle nested data
      if (value is Map) {
        value = mapToFirestore(value as Map<String, dynamic>);
      }
      // Handle list of nested data
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapToFirestore(v as Map<String, dynamic>))
            .toList();
      }
      return MapEntry(key, value);
    });
