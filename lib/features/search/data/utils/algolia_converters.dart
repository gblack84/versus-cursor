// ============================================
// ALGOLIA CONVERTERS - Search Feature Specific
// ============================================
//
// Migrated from: /lib/core/firebase/utils/schema_util.dart
// Migration date: 2025-11-10
// Reason: Search Feature specific (Algolia), architecture violation fixed
//
// Location: Search Feature Data Layer
// Purpose: Convert Algolia search results to app models
//
// Previous location (Core) violated Clean Architecture:
// - Core importing from Feature (reverse dependency)
// - Algolia-specific logic (not generic/reusable)
// ============================================

import 'dart:convert';

import 'package:from_css_color/from_css_color.dart' as css_color;
import 'package:flutter/material.dart' show Color;
import '/app/router/navigation/serialization_util.dart' show ParamType;
import '/core/utils/app_utils.dart' show castToType;
import '../adapters/serialization_util.dart';

export 'package:collection/collection.dart' show ListEquality;
export 'package:flutter/material.dart' show Color, Colors;
export 'package:from_css_color/from_css_color.dart';

// ============================================
// TYPE DEFINITIONS
// ============================================

/// Struct builder function type
typedef StructBuilder<T> = T Function(Map<String, dynamic> data);

/// Base struct for serialization
abstract class BaseStruct {
  Map<String, dynamic> toSerializableMap();
  String serialize() => json.encode(toSerializableMap());
}

// ============================================
// ALGOLIA CONVERTERS
// ============================================

/// Convert Algolia search result data to app struct
///
/// Handles both single objects and lists from Algolia responses.
/// Used by Search Feature to convert Algolia JSON to Dart models.
dynamic convertAlgoliaStruct<T>(
  dynamic data,
  ParamType paramType,
  bool isList, {
  required StructBuilder<T> structBuilder,
}) {
  if (data == null) {
    return null;
  } else if (isList) {
    if (data is! Iterable) {
      return null;
    }
    return data
        .map<T>((e) => convertAlgoliaStruct<T>(
              e,
              paramType,
              false,
              structBuilder: structBuilder,
            ))
        .toList();
  } else if (data is Map<String, dynamic>) {
    return structBuilder(data);
  } else {
    return convertAlgoliaParam<T>(
      data,
      paramType,
      isList,
      structBuilder: structBuilder,
    );
  }
}

/// Get list of structs from Algolia data
List<T>? getStructList<T>(
  dynamic value,
  StructBuilder<T> structBuilder,
) =>
    value is! List
        ? null
        : value
            .where((e) => e is Map<String, dynamic>)
            .map((e) => structBuilder(e as Map<String, dynamic>))
            .toList();

/// Get Color from CSS color string (Algolia format)
Color? getSchemaColor(dynamic value) => value is String
    ? css_color.fromCssColor(value)
    : value is Color
        ? value
        : null;

/// Get list of Colors from Algolia data
List<Color>? getColorsList(dynamic value) => value is! List
    ? null
    : value.map(getSchemaColor).where((e) => e != null).cast<Color>().toList();

/// Get typed list from Algolia data
List<T>? getDataList<T>(dynamic value) =>
    value is! List ? null : value.map((e) => castToType<T>(e)!).toList();
