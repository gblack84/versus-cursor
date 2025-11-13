// ============================================
// COLLECTION EXTENSIONS - Core Utils
// ============================================
//
// Split from: /lib/core/utils/app_utils.dart
// Migration date: 2025-11-11
// Reason: SRP (Single Responsibility Principle) - collection operations only
//
// Purpose: Extensions for List, Map, Iterable, String, and other Dart types
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' show Color, TextEditingController, TextCapitalization;

// ============================================
// LIST EXTENSIONS
// ============================================

/// Filter list with predicate function
extension ListFilterExt<T> on List<T> {
  List<T> filterList(bool Function(T element) filter) =>
      where((element) => filter(element)).toList();
}

/// List manipulation: divide, chunk, addToStart, addToEnd
extension ListDivideExtension<T> on List<T> {
  /// Split list into chunks of specified size
  ///
  /// **Example**:
  /// ```dart
  /// [1, 2, 3, 4, 5].chunk(2);
  /// // Returns: [[1, 2], [3, 4], [5]]
  /// ```
  List<List<T>> chunk(int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += chunkSize) {
      int end = (i + chunkSize < length) ? i + chunkSize : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  /// Insert separator between elements
  ///
  /// **Example**:
  /// ```dart
  /// [1, 2, 3].divide(0);
  /// // Returns: [1, 0, 2, 0, 3]
  /// ```
  List<T> divide(T separator) {
    if (isEmpty) return this;
    final List<T> list = [];
    for (int i = 0; i < length; i++) {
      list.add(this[i]);
      if (i < length - 1) {
        list.add(separator);
      }
    }
    return list;
  }

  /// Add item to start of list (returns new list)
  List<T> addToStart(T item) {
    return [item, ...this];
  }

  /// Add item to end of list (returns new list)
  List<T> addToEnd(T item) {
    return [...this, item];
  }
}

// ============================================
// MAP EXTENSIONS
// ============================================

/// Map utilities for filtering nulls
extension MapExtensions on Map<String, dynamic> {
  /// Remove null values from map
  ///
  /// **Example**:
  /// ```dart
  /// {'a': 1, 'b': null, 'c': 3}.withoutNulls;
  /// // Returns: {'a': 1, 'c': 3}
  /// ```
  Map<String, dynamic> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value)),
      );
}

// ============================================
// ITERABLE EXTENSIONS
// ============================================

/// Iterable utilities for sorting and mapping
extension IterableExt<T> on Iterable<T> {
  /// Sort list by key function
  ///
  /// **Example**:
  /// ```dart
  /// users.sortedList(keyOf: (u) => u.age, desc: true);
  /// // Returns: users sorted by age descending
  /// ```
  List<T> sortedList<S extends Comparable>({
    S Function(T)? keyOf,
    bool desc = false,
  }) {
    final sortedAscending = toList()
      ..sort(keyOf == null ? null : ((a, b) => keyOf(a).compareTo(keyOf(b))));
    if (desc) {
      return sortedAscending.reversed.toList();
    }
    return sortedAscending;
  }

  /// Map with index
  ///
  /// **Example**:
  /// ```dart
  /// ['a', 'b', 'c'].mapIndexed((i, e) => '$i: $e');
  /// // Returns: ['0: a', '1: b', '2: c']
  /// ```
  List<S> mapIndexed<S>(S Function(int, T) func) => toList()
      .asMap()
      .map((index, value) => MapEntry(index, func(index, value)))
      .values
      .toList();
}

/// Filter out nulls from nullable iterable
extension IterableNullableExt<T> on Iterable<T?> {
  /// Remove null values and cast to non-nullable
  ///
  /// **Example**:
  /// ```dart
  /// [1, null, 2, null, 3].withoutNulls;
  /// // Returns: [1, 2, 3]
  /// ```
  List<T> get withoutNulls => where((e) => e != null).cast<T>().toList();
}

// ============================================
// TEXT EDITING CONTROLLER EXTENSION
// ============================================

/// TextEditingController safe text access
extension TextEditingControllerExt on TextEditingController? {
  /// Get text safely (returns empty string if null)
  String get text => this == null ? '' : this!.text;

  /// Set text safely (no-op if null)
  set text(String newText) => this?.text = newText;
}

// ============================================
// FIRESTORE EXTENSION
// ============================================

/// String to DocumentReference conversion
///
/// **⚠️ DEPRECATED**: Use FirebaseFirestore.instance.doc() directly
///
/// **Example** (deprecated):
/// ```dart
/// final ref = 'users/123'.ref;  // DocumentReference
/// ```
///
/// **Recommended**:
/// ```dart
/// final ref = FirebaseFirestore.instance.doc('users/123');
/// ```
@Deprecated('Use FirebaseFirestore.instance.doc() directly')
extension StringDocRef on String {
  DocumentReference get ref => FirebaseFirestore.instance.doc(this);
}

// ============================================
// DOUBLE EXTENSIONS
// ============================================

/// Double to string with no trailing zeros
extension DoubleStringExt on double {
  /// Convert to fixed decimal string, removing trailing zeros
  ///
  /// **Example**:
  /// ```dart
  /// 1.50.toStringAsFixedNoZero(2);  // Returns: "1.5"
  /// 1.00.toStringAsFixedNoZero(2);  // Returns: "1"
  /// 1.23.toStringAsFixedNoZero(2);  // Returns: "1.23"
  /// ```
  String toStringAsFixedNoZero(int fractionDigits) {
    final val = toStringAsFixed(fractionDigits);
    if (val.endsWith('0' * fractionDigits)) {
      return val.substring(0, val.length - fractionDigits - 1);
    }
    return val;
  }
}

/// Safe division for double
extension DoubleExtension on double {
  /// Divide with zero-check
  ///
  /// **Returns**: `this / divisor` if divisor != 0, otherwise 0.0
  ///
  /// **Example**:
  /// ```dart
  /// 10.0.divide(2.0);  // Returns: 5.0
  /// 10.0.divide(0.0);  // Returns: 0.0 (safe)
  /// ```
  double divide(double divisor) => divisor != 0 ? this / divisor : 0.0;
}

// ============================================
// STRING EXTENSIONS
// ============================================

/// String capitalization
extension StringCapitalizationExt on String {
  /// Apply TextCapitalization to string
  ///
  /// **Example**:
  /// ```dart
  /// 'hello world'.toCapitalization(TextCapitalization.words);
  /// // Returns: "Hello World"
  ///
  /// 'hello world'.toCapitalization(TextCapitalization.sentences);
  /// // Returns: "Hello world"
  /// ```
  String toCapitalization(TextCapitalization capitalization) {
    if (isEmpty) return this;

    switch (capitalization) {
      case TextCapitalization.words:
        return split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
      case TextCapitalization.sentences:
        if (isEmpty) return this;
        return this[0].toUpperCase() + substring(1);
      case TextCapitalization.characters:
        return toUpperCase();
      case TextCapitalization.none:
        return this;
    }
  }
}

// ============================================
// COLOR EXTENSION
// ============================================

/// Color alpha manipulation
extension ColorExtension on Color {
  /// Apply alpha factor to color
  ///
  /// **Example**:
  /// ```dart
  /// Colors.red.applyAlpha(0.5);  // 50% opacity
  /// ```
  Color applyAlpha(double factor) {
    return withAlpha((a * 255.0 * factor).round().clamp(0, 255));
  }
}
