// ============================================
// FIRESTORE UTILITIES - Generic Core Layer
// ============================================
//
// This file contains ONLY generic, reusable Firestore utilities
// that are framework-agnostic and used across multiple features.
//
// Location: Core Layer
// Reason: Pure Dart generic utilities (GeoPoint conversion, safe operations, etc.)
//
// Legacy patterns moved to: /lib/services/firebase/legacy_firestore_record.dart
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '/app/types/lat_lng.dart';

// Re-export commonly used Firestore classes
export 'package:cloud_firestore/cloud_firestore.dart'
    show
        FirebaseFirestore,
        FieldValue,
        DocumentReference,
        CollectionReference,
        QuerySnapshot,
        Timestamp,
        GeoPoint,
        DocumentSnapshot,
        Query,
        FieldPath;

// ============================================
// GENERIC GEOPOINT EXTENSIONS
// ============================================

/// Convert LatLng to Firestore GeoPoint
extension GeoPointExtension on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}

/// Convert Firestore GeoPoint to LatLng
extension LatLngExtension on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

/// Convert list of LatLng to list of GeoPoint
List<GeoPoint>? convertToGeoPointList(List<LatLng>? list) =>
    list?.map((e) => e.toGeoPoint()).toList();

// ============================================
// GENERIC UTILITIES
// ============================================

/// Convert Firestore document path to DocumentReference
DocumentReference toRef(String ref) => FirebaseFirestore.instance.doc(ref);

/// Safe get with optional error reporting
///
/// Example:
/// ```dart
/// final user = safeGet(
///   () => UserProfile.fromFirestore(doc),
///   (e) => print('Error: $e'),
/// );
/// ```
T? safeGet<T>(T Function() func, [Function(dynamic)? reportError]) {
  try {
    return func();
  } catch (e) {
    reportError?.call(e);
  }
  return null;
}

/// Merge nested fields from Firestore (e.g., 'foo.bar' → { foo: { bar: value } })
///
/// Firestore supports nested field notation like:
/// ```dart
/// { 'user.name': 'John', 'user.age': 30 }
/// ```
///
/// This function converts it to:
/// ```dart
/// { 'user': { 'name': 'John', 'age': 30 } }
/// ```
Map<String, dynamic> mergeNestedFields(Map<String, dynamic> data) {
  final nestedData = data.where((k, _) => k.contains('.'));
  final fieldNames = nestedData.keys.map((k) => k.split('.').first).toSet();

  // Remove nested values (e.g. 'foo.bar') and merge them into a map
  data.removeWhere((k, _) => k.contains('.'));

  fieldNames.forEach((name) {
    final mergedValues = mergeNestedFields(
      nestedData
          .where((k, _) => k.split('.').first == name)
          .map((k, v) => MapEntry(k.split('.').skip(1).join('.'), v)),
    );
    final existingValue = data[name];
    data[name] = {
      if (existingValue != null && existingValue is Map)
        ...existingValue as Map<String, dynamic>,
      ...mergedValues,
    };
  });

  // Merge any nested maps inside any of the fields as well
  data.where((_, v) => v is Map).forEach((k, v) {
    data[k] = mergeNestedFields(v as Map<String, dynamic>);
  });

  return data;
}

// ============================================
// HELPER EXTENSIONS
// ============================================

/// Map.where extension for filtering map entries
extension _WhereMapExtension<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) test) =>
      Map.fromEntries(entries.where((e) => test(e.key, e.value)));
}
