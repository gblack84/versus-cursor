# 🔍 Search Feature - Algolia Converters

> **Feature-Specific Utilities**: Algolia search result conversion and serialization

**Location**: `lib/features/search/data/utils/algolia_converters.dart`

**Migration Date**: 2025-11-10 (Moved from `/lib/core/firebase/utils/schema_util.dart`)

---

## 📋 Overview

This directory contains **Algolia-specific converters** for transforming Algolia search results into app models. These utilities were migrated from Core to fix an architecture violation.

**Why Feature-Specific**:
- ✅ **Algolia-Only**: Only used by Search Feature, not generic/reusable
- ✅ **Feature Boundary**: Search Feature owns its data conversion logic
- ✅ **Clean Architecture**: Respects layer separation (no Core → Feature dependency)
- ✅ **Single Responsibility**: Focused on Algolia search result conversion

---

## 🏗️ Architecture Context

### Migration Reason

**Before (Architecture Violation)**:
```
lib/core/firebase/utils/schema_util.dart  ← Generic "Core" location
    ↓ (imports)
lib/features/search/...                   ← Feature-specific code

❌ PROBLEM: Core importing from Feature (reverse dependency)
❌ PROBLEM: Algolia-specific logic in "generic" Core utilities
```

**After (Clean Architecture)**:
```
lib/features/search/data/utils/algolia_converters.dart  ← Feature-specific location
    ↓ (uses)
lib/core/firebase/firestore_util.dart                    ← Generic utilities only

✅ SOLUTION: Feature contains its own conversion logic
✅ SOLUTION: Core remains pure and reusable
✅ SOLUTION: Proper dependency direction (Feature → Core, not Core → Feature)
```

---

## 🔧 Converters Provided

### 1. Algolia Struct Converter

**Purpose**: Convert Algolia search result data to app struct

**Function**:
```dart
dynamic convertAlgoliaStruct<T>(
  dynamic data,
  ParamType paramType,
  bool isList, {
  required StructBuilder<T> structBuilder,
})
```

**Handles**:
- Single objects from Algolia responses
- Lists of objects from Algolia responses
- Nested data structures
- Type conversion with StructBuilder

**Usage Example**:
```dart
// Algolia search result
final searchResults = await algolia
    .index('posts')
    .search('flutter')
    .getObjects();

// Convert to Post entities
final posts = searchResults.map((result) {
  return convertAlgoliaStruct<Post>(
    result,
    ParamType.DataStruct,
    false,
    structBuilder: (data) => Post.fromAlgolia(data),
  );
}).toList();
```

---

### 2. Algolia Parameter Converter

**Purpose**: Convert individual Algolia parameters to app types

**Function**:
```dart
dynamic convertAlgoliaParam<T>(
  dynamic data,
  ParamType paramType,
  bool isList, {
  StructBuilder<T>? structBuilder,
})
```

**Supported Types**:

| ParamType | Input | Output | Example |
|-----------|-------|--------|---------|
| `ParamType.int` | num | int | `42` |
| `ParamType.double` | num | double | `3.14` |
| `ParamType.DateTime` | int (ms) | DateTime | `1698739200000` → `2023-10-31` |
| `ParamType.LatLng` | `{"_geoloc": {"lat": 37.7749, "lng": -122.4194}}` | LatLng | Location object |
| `ParamType.Color` | String (CSS) | Color | `"#FF5733"` → `Color(0xFFFF5733)` |
| `ParamType.DocumentReference` | String (path) | DocumentReference | `"users/user123"` |

**DateTime Conversion**:
```dart
// Algolia stores timestamps as milliseconds since epoch
final timestamp = 1698739200000;
final dateTime = convertAlgoliaParam(
  timestamp,
  ParamType.DateTime,
  false,
); // → DateTime(2023, 10, 31)
```

**LatLng Conversion**:
```dart
// Algolia _geoloc format
final geoData = {
  "_geoloc": {
    "lat": 37.7749,
    "lng": -122.4194
  }
};

final location = convertAlgoliaParam(
  geoData,
  ParamType.LatLng,
  false,
); // → LatLng(37.7749, -122.4194)
```

**Color Conversion**:
```dart
// Algolia stores colors as CSS strings
final cssColor = "#FF5733";
final color = convertAlgoliaParam(
  cssColor,
  ParamType.Color,
  false,
); // → Color(0xFFFF5733)
```

**DocumentReference Conversion**:
```dart
// Algolia stores Firestore paths as strings
final path = "users/user123";
final ref = convertAlgoliaParam(
  path,
  ParamType.DocumentReference,
  false,
); // → FirebaseFirestore.instance.doc("users/user123")
```

---

### 3. Struct List Helper

**Purpose**: Extract list of structs from Algolia data

**Function**:
```dart
List<T>? getStructList<T>(
  dynamic value,
  StructBuilder<T> structBuilder,
)
```

**Usage Example**:
```dart
// Algolia nested results
final algoliaData = {
  "results": [
    {"id": "1", "title": "Post 1"},
    {"id": "2", "title": "Post 2"},
    {"id": "3", "title": "Post 3"},
  ]
};

// Extract and convert to Post entities
final posts = getStructList<Post>(
  algoliaData["results"],
  (data) => Post.fromAlgolia(data),
);
// → [Post("1", "Post 1"), Post("2", "Post 2"), Post("3", "Post 3")]
```

---

### 4. Color Converters

**Purpose**: Convert Algolia CSS color strings to Flutter Color objects

**Functions**:
```dart
// Single color
Color? getSchemaColor(dynamic value)

// List of colors
List<Color>? getColorsList(dynamic value)
```

**Usage Example**:
```dart
// Single color
final hexColor = "#FF5733";
final color = getSchemaColor(hexColor); // → Color(0xFFFF5733)

// Multiple colors
final colorList = ["#FF5733", "#3498DB", "#2ECC71"];
final colors = getColorsList(colorList);
// → [Color(0xFFFF5733), Color(0xFF3498DB), Color(0xFF2ECC71)]

// Also accepts Flutter Color objects directly
final flutterColor = Colors.red;
final color2 = getSchemaColor(flutterColor); // → Colors.red (passthrough)
```

---

### 5. Generic Data List Helper

**Purpose**: Extract typed list from Algolia data

**Function**:
```dart
List<T>? getDataList<T>(dynamic value)
```

**Usage Example**:
```dart
// Extract list of strings
final tagData = ["flutter", "dart", "mobile"];
final tags = getDataList<String>(tagData);
// → ["flutter", "dart", "mobile"]

// Extract list of integers
final voteData = [42, 100, 7];
final votes = getDataList<int>(voteData);
// → [42, 100, 7]
```

---

## 📦 Type Definitions

### StructBuilder

**Purpose**: Function type for building structs from Algolia data

```dart
typedef StructBuilder<T> = T Function(Map<String, dynamic> data);
```

**Usage**:
```dart
// Define StructBuilder for Post
final postBuilder = (Map<String, dynamic> data) => Post(
  id: data['objectID'] as String,
  title: data['title'] as String,
  content: data['content'] as String,
  createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
);

// Use with converter
final posts = convertAlgoliaStruct<Post>(
  searchResults,
  ParamType.DataStruct,
  true,
  structBuilder: postBuilder,
);
```

---

### BaseStruct

**Purpose**: Abstract base class for serializable structs

```dart
abstract class BaseStruct {
  Map<String, dynamic> toSerializableMap();
  String serialize() => json.encode(toSerializableMap());
}
```

**Usage**:
```dart
class SearchResult extends BaseStruct {
  final String id;
  final String title;
  final int score;

  SearchResult({
    required this.id,
    required this.title,
    required this.score,
  });

  @override
  Map<String, dynamic> toSerializableMap() {
    return {
      'id': id,
      'title': title,
      'score': score,
    };
  }
}

// Serialize to JSON
final result = SearchResult(id: '1', title: 'Post 1', score: 100);
final json = result.serialize(); // → '{"id":"1","title":"Post 1","score":100}'
```

---

## 🔄 Integration with Search Feature

### Search Repository Implementation

```dart
// lib/features/search/data/repositories/search_repository_impl.dart

import '../utils/algolia_converters.dart';
import '../adapters/serialization_util.dart';

class SearchRepositoryImpl implements ISearchRepository {
  final Algolia _algolia;

  Future<Either<SearchFailure, List<Post>>> searchPosts(String query) async {
    try {
      // Algolia search query
      final algoliaQuery = _algolia
          .index('posts')
          .search(query)
          .setHitsPerPage(20);

      final snapshot = await algoliaQuery.getObjects();

      // Convert Algolia results to Post entities
      final posts = snapshot.hits.map((hit) {
        return convertAlgoliaStruct<Post>(
          hit.data,
          ParamType.DataStruct,
          false,
          structBuilder: (data) => Post.fromAlgolia(data),
        );
      }).whereType<Post>().toList();

      return right(posts);
    } on AlgoliaError catch (e) {
      return left(SearchFailure.serverError(e.message));
    } catch (e) {
      return left(SearchFailure.unknown(e.toString()));
    }
  }

  Future<Either<SearchFailure, List<User>>> searchUsers(String query) async {
    try {
      final algoliaQuery = _algolia
          .index('users')
          .search(query)
          .setHitsPerPage(20);

      final snapshot = await algoliaQuery.getObjects();

      // Convert Algolia results to User entities
      final users = snapshot.hits.map((hit) {
        return convertAlgoliaStruct<User>(
          hit.data,
          ParamType.DataStruct,
          false,
          structBuilder: (data) => User.fromAlgolia(data),
        );
      }).whereType<User>().toList();

      return right(users);
    } on AlgoliaError catch (e) {
      return left(SearchFailure.serverError(e.message));
    } catch (e) {
      return left(SearchFailure.unknown(e.toString()));
    }
  }
}
```

---

### Entity Algolia Extensions

```dart
// lib/features/search/domain/entities/post_extensions.dart

extension PostAlgolia on Post {
  /// Convert Algolia hit to Post entity
  static Post fromAlgolia(Map<String, dynamic> data) {
    return Post(
      id: data['objectID'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),

      // Use Algolia converter for LatLng
      location: data['_geoloc'] != null
          ? convertAlgoliaParam(data, ParamType.LatLng, false) as LatLng?
          : null,

      // Use color converter
      themeColor: getSchemaColor(data['themeColor']),

      // Extract tags list
      tags: getDataList<String>(data['tags']) ?? [],
    );
  }
}
```

---

## ✅ When to Use

Use these converters when:

| Use Case | Converter | Example |
|----------|-----------|---------|
| **Algolia search results** | `convertAlgoliaStruct` | Converting search hits to entities |
| **Timestamp conversion** | `convertAlgoliaParam(ParamType.DateTime)` | Algolia timestamps to DateTime |
| **Location data** | `convertAlgoliaParam(ParamType.LatLng)` | Algolia `_geoloc` to LatLng |
| **Color data** | `getSchemaColor` / `getColorsList` | CSS strings to Flutter Colors |
| **Document references** | `convertAlgoliaParam(ParamType.DocumentReference)` | Firestore path strings to refs |
| **Nested structures** | `getStructList` | Extracting lists from Algolia data |

---

## ❌ When NOT to Use

**DON'T use for**:

1. **Firestore Direct Queries** → Use Extension Pattern (`fromFirestore`)
   ```dart
   // ❌ DON'T: Use Algolia converters for Firestore
   final doc = await firestore.collection('posts').doc(id).get();
   final post = convertAlgoliaStruct(doc.data(), ...); // Wrong!

   // ✅ DO: Use Extension Pattern
   final post = Post.fromFirestore(doc);
   ```

2. **Non-Algolia APIs** → Use API-specific converters
   ```dart
   // ❌ DON'T: Use for REST API responses
   final response = await http.get('https://api.example.com/posts');
   final posts = convertAlgoliaStruct(response.body, ...); // Wrong!

   // ✅ DO: Use API-specific converter
   final posts = Post.fromApiResponse(response.body);
   ```

3. **Generic Data Structures** → Use Core utilities
   ```dart
   // ❌ DON'T: Use Algolia converters for generic Map/List operations
   final data = {"key": "value"};
   final result = convertAlgoliaStruct(data, ...); // Wrong!

   // ✅ DO: Use standard Dart operations
   final result = MyModel.fromJson(data);
   ```

---

## 🔗 Dependencies

This file imports from:

- `/lib/app/router/navigation/serialization_util.dart` - ParamType enum
- `/lib/core/firebase/firestore_util.dart` - Generic utilities (safeGet, toRef)
- `/lib/core/utils/app_utils.dart` - Type casting (castToType)
- `package:from_css_color/from_css_color.dart` - CSS color parsing
- `package:flutter/material.dart` - Color class

---

## 📊 Re-Exports

This file re-exports commonly used classes:

```dart
export 'package:collection/collection.dart' show ListEquality;
export 'package:flutter/material.dart' show Color, Colors;
export 'package:from_css_color/from_css_color.dart';
```

**Why**:
- Convenience for Search Feature files
- Consistent import pattern across Search Feature
- Reduces import boilerplate

**Usage**:
```dart
// Single import gets everything needed for Algolia conversion
import '../utils/algolia_converters.dart';

// Now have access to:
// - Color, Colors (Flutter)
// - fromCssColor() (from_css_color package)
// - ListEquality (collection package)
// - convertAlgoliaStruct, getSchemaColor, etc. (this file)
```

---

## 🎓 Best Practices

### ✅ DO

1. **Use StructBuilder for Complex Types**
   ```dart
   final posts = convertAlgoliaStruct<Post>(
     data,
     ParamType.DataStruct,
     false,
     structBuilder: (data) => Post.fromAlgolia(data),
   );
   ```

2. **Handle Null Safety**
   ```dart
   final location = data['_geoloc'] != null
       ? convertAlgoliaParam(data, ParamType.LatLng, false) as LatLng?
       : null;
   ```

3. **Use Type Filtering**
   ```dart
   final posts = snapshot.hits
       .map((hit) => convertAlgoliaStruct<Post>(...))
       .whereType<Post>()  // Filter out nulls
       .toList();
   ```

4. **Catch Conversion Errors**
   ```dart
   try {
     final result = convertAlgoliaParam(data, ParamType.DateTime, false);
   } catch (e) {
     print('Conversion error: $e');
     return null;
   }
   ```

---

### ❌ DON'T

1. **Don't Mix Algolia and Firestore Conversions**
   ```dart
   // ❌ WRONG: Using Algolia converter for Firestore
   final doc = await firestore.collection('posts').doc(id).get();
   final post = convertAlgoliaStruct(doc.data(), ...);

   // ✅ RIGHT: Use appropriate converter
   final post = Post.fromFirestore(doc);
   ```

2. **Don't Ignore Null Checks**
   ```dart
   // ❌ WRONG: Assuming data exists
   final color = convertAlgoliaParam(data['color'], ParamType.Color, false);

   // ✅ RIGHT: Check for null
   final color = data['color'] != null
       ? convertAlgoliaParam(data['color'], ParamType.Color, false)
       : null;
   ```

3. **Don't Use for Non-Algolia Data**
   ```dart
   // ❌ WRONG: Generic JSON parsing
   final json = jsonDecode(response.body);
   final result = convertAlgoliaStruct(json, ...);

   // ✅ RIGHT: Use appropriate parser
   final result = MyModel.fromJson(json);
   ```

---

## 📁 Related Files

| File | Purpose | Status |
|------|---------|--------|
| **`/lib/features/search/data/utils/algolia_converters.dart`** | Algolia converters (this file) | ✅ Active |
| **`/lib/features/search/data/adapters/serialization_util.dart`** | Algolia serialization | ✅ Active |
| **`/lib/core/firebase/firestore_util.dart`** | Generic Firestore utilities | ✅ Active |
| **`/lib/app/router/navigation/serialization_util.dart`** | ParamType enum | ✅ Active |
| **`/lib/core/utils/app_utils.dart`** | Type casting utilities | ✅ Active |

---

## 🔄 Migration History

### Before (Core Layer - Architecture Violation)

**Location**: `/lib/core/firebase/utils/schema_util.dart`

**Problems**:
- ❌ Core importing from Feature (reverse dependency)
- ❌ Algolia-specific logic in "generic" Core
- ❌ Not reusable across other Features
- ❌ Violates Clean Architecture principles

**Created**: Unknown (legacy code)

---

### After (Feature Data Layer - Clean Architecture)

**Location**: `/lib/features/search/data/utils/algolia_converters.dart`

**Benefits**:
- ✅ Feature owns its conversion logic
- ✅ Core remains pure and reusable
- ✅ Proper dependency direction (Feature → Core)
- ✅ Clear Feature boundary

**Migrated**: 2025-11-10 (Commit: d291b90d)

---

## 🔗 Further Reading

- [Search Feature README](/lib/features/search/README.md)
- [Core Firebase Utilities](/lib/core/firebase/README.md)
- [Clean Architecture Overview](/lib/CLAUDE.md#-아키텍처-개요)
- [Firebase-Centric v2.0](/lib/CLAUDE.md#firebase-centric-v20-핵심-변화)
- [Extension Pattern Guide](/lib/CLAUDE.md#왜-extension-vs-dtomapper)
- [Algolia Flutter Documentation](https://www.algolia.com/doc/api-client/getting-started/install/flutter/)

---

**Last Updated**: 2025-11-10
**Maintainer**: Search Feature Team
**Migration Status**: Phase 0 - Utilities Only (5%)
