# 🔥 Core Firebase Utilities

> Generic, reusable Firestore utilities for application-wide use

**Location**: `lib/core/firebase/firestore_util.dart`

**Philosophy**: Pure Dart, framework-agnostic utilities used across Features for Firestore operations. Minimal and focused on generic operations only.

---

## 📋 Overview

This directory contains **generic Firestore utilities** that are:
- ✅ **Pure Dart**: Framework-independent, no Flutter/Feature coupling
- ✅ **Reusable**: Used across multiple Features (Auth, Profile, Chat, etc.)
- ✅ **Minimal**: Only essential, non-domain-specific operations
- ✅ **Well-tested**: Stable utilities with clear interfaces

---

## 🔧 Utilities Provided

### **1. GeoPoint ↔ LatLng Conversion**

Extensions for seamless conversion between Firestore GeoPoint and Flutter LatLng:

```dart
// GeoPoint → LatLng
extension LatLngExtension on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

// LatLng → GeoPoint
extension GeoPointExtension on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}

// List conversion
List<GeoPoint>? convertToGeoPointList(List<LatLng>? list) =>
    list?.map((e) => e.toGeoPoint()).toList();
```

**Usage Example**:
```dart
// Reading from Firestore
final geoPoint = doc.data()['location'] as GeoPoint;
final latLng = geoPoint.toLatLng();

// Writing to Firestore
final latLng = LatLng(37.7749, -122.4194);
await doc.update({'location': latLng.toGeoPoint()});
```

---

### **2. Safe Execution with Error Handling**

Execute functions safely with optional error reporting:

```dart
T? safeGet<T>(T Function() func, [Function(dynamic)? reportError]) {
  try {
    return func();
  } catch (e) {
    reportError?.call(e);
  }
  return null;
}
```

**Usage Example**:
```dart
// Safely parse Firestore data
final user = safeGet(
  () => UserProfile.fromFirestore(doc),
  (e) => logger.error('Failed to parse user: $e'),
);

if (user != null) {
  // Use parsed user
}
```

---

### **3. Merge Nested Firestore Fields**

Convert Firestore nested field notation to nested Maps:

```dart
Map<String, dynamic> mergeNestedFields(Map<String, dynamic> data) {
  // Converts: { 'user.name': 'John', 'user.age': 30 }
  // To:       { 'user': { 'name': 'John', 'age': 30 } }
}
```

**Usage Example**:
```dart
// Firestore query with nested fields
final snapshot = await collection
    .where('user.name', isEqualTo: 'John')
    .get();

// Merge nested fields for easier processing
final data = mergeNestedFields(snapshot.data()!);
print(data['user']['name']); // 'John'
```

---

### **4. DocumentReference Helper**

Convert string path to DocumentReference:

```dart
DocumentReference toRef(String ref) => FirebaseFirestore.instance.doc(ref);
```

**Usage Example**:
```dart
// Convert path string to reference
final userRef = toRef('users/user123');
final doc = await userRef.get();
```

---

## 📦 Re-Exported Firestore Classes

This file re-exports commonly used Firestore classes for convenience:

```dart
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
```

**Usage**:
```dart
// No need to import cloud_firestore directly
import '/core/firebase/firestore_util.dart';

// These are already available:
FirebaseFirestore.instance.collection('users');
FieldValue.serverTimestamp();
```

---

## ✅ When to Use

Use these utilities when you need:

| Use Case | Example |
|----------|---------|
| **GeoPoint/LatLng conversion** | Converting location data between Flutter and Firestore |
| **Safe function execution** | Parsing Firestore data with error handling |
| **Nested field handling** | Processing Firestore queries with dot notation |
| **DocumentReference operations** | Converting string paths to Firestore references |
| **Generic Firestore operations** | Operations used across multiple Features |

---

## ❌ When NOT to Use

**DON'T use for**:

1. **Feature-specific logic** → Use Extension Pattern in Feature's Data Layer
2. **Data serialization/deserialization** → Use Extension Pattern (`fromFirestore`/`toFirestore`)
3. **Complex data transformations** → Use Repository pattern
4. **Legacy patterns** → See `/lib/services/firebase/legacy_firestore_record.dart` (deprecated)

---

## 🔄 Alternative: Extension Pattern (Recommended)

For most Firestore operations, use **Extension Pattern** instead:

```dart
// ✅ RECOMMENDED: Extension Pattern
// Location: lib/features/profile/data/extensions/user_profile_extensions.dart

extension UserProfileFirestore on UserProfile {
  /// Convert Firestore DocumentSnapshot to UserProfile entity
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: data['photoUrl'] as String?,
    );
  }

  /// Convert UserProfile entity to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrl': photoUrl,
    };
  }
}
```

**Why Extension Pattern?**
- ✅ **Type-safe**: Strongly typed conversions
- ✅ **Feature-scoped**: Logic stays within Feature boundary
- ✅ **Maintainable**: Clear separation of concerns
- ✅ **Testable**: Easy to mock and test

---

## 📍 Related Files

| File | Purpose | Status |
|------|---------|--------|
| **`/lib/core/firebase/firestore_util.dart`** | Generic utilities (this file) | ✅ Active |
| **`/lib/services/firebase/legacy_firestore_record.dart`** | Legacy pattern (FirestoreRecord) | ⚠️ Deprecated |
| **`/lib/features/search/data/utils/algolia_converters.dart`** | Algolia-specific converters | ✅ Active |
| **`/lib/app/router/navigation/serialization_util.dart`** | ParamType enum, route serialization | ✅ Active |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│              (UI, Widgets, Screens)                         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│     (Entities, UseCases, Repository Interfaces)             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Extension Pattern (Recommended)             │   │
│  │  fromFirestore() / toFirestore()                    │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │ (Use when needed)                 │
│  ┌──────────────────────▼──────────────────────────────┐   │
│  │        Core Firebase Utils (Generic)                │   │
│  │  - GeoPoint ↔ LatLng extensions                     │   │
│  │  - safeGet(), toRef()                               │   │
│  │  - mergeNestedFields()                              │   │
│  └──────────────────────┬──────────────────────────────┘   │
└─────────────────────────┼────────────────────────────────────┘
                          │
                          ▼
                 Firebase SDK (cloud_firestore)
```

---

## 📚 Examples by Feature

### **Profile Feature**
```dart
// ✅ Extension Pattern (Feature Data Layer)
// lib/features/profile/data/extensions/user_profile_extensions.dart

extension UserProfileFirestore on UserProfile {
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      // Uses GeoPoint extension from core/firebase
      location: (data['location'] as GeoPoint?)?.toLatLng(),
    );
  }
}
```

### **Chat Feature**
```dart
// ✅ Extension Pattern + safeGet
// lib/features/chat/data/extensions/message_extensions.dart

extension MessageFirestore on Message {
  static Message fromFirestore(DocumentSnapshot doc) {
    return safeGet(
      () {
        final data = doc.data() as Map<String, dynamic>;
        return Message(
          id: doc.id,
          text: data['text'] as String,
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      },
      (e) => logger.error('Failed to parse message: $e'),
    ) ?? Message.empty();
  }
}
```

---

## 🔧 Migration Guide

### **From Legacy FirestoreRecord Pattern**

If you have code using the deprecated `FirestoreRecord` pattern:

**Before (Legacy)**:
```dart
// ❌ DEPRECATED
class UserModel extends FirestoreRecord {
  UserModel._(DocumentReference reference, Map<String, dynamic> data)
      : super(reference, data);

  static UserModel fromFirestore(DocumentSnapshot snapshot) {
    return UserModel._(
      snapshot.reference,
      mapFromFirestore(snapshot.data() as Map<String, dynamic>),
    );
  }
}
```

**After (Extension Pattern)**:
```dart
// ✅ RECOMMENDED
@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String displayName,
  }) = _User;
}

extension UserFirestore on User {
  static User fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return User(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
    };
  }
}
```

**Migration Steps**:
1. Create Freezed entity in `domain/entities/`
2. Create Extension in `data/extensions/`
3. Update Repository to use Extension
4. Remove FirestoreRecord inheritance

**See Also**: `/lib/services/firebase/README.md` for Legacy pattern details

---

## 📝 Best Practices

### **✅ DO**
- Use Extension Pattern for Feature-specific Firestore operations
- Use `safeGet()` for error-prone parsing operations
- Use GeoPoint extensions for location data
- Keep utilities generic and framework-independent

### **❌ DON'T**
- Add Feature-specific logic to core utilities
- Use Legacy FirestoreRecord pattern (deprecated)
- Bypass Repository pattern for direct Firestore access
- Create complex data transformations in utilities

---

## 🔗 Further Reading

- [Clean Architecture Overview](/lib/CLAUDE.md#-아키텍처-개요)
- [Extension Pattern Guide](/lib/CLAUDE.md#왜-extension-vs-dtomapper)
- [Firebase-Centric v2.0](/lib/CLAUDE.md#firebase-centric-v20-핵심-변화)
- [3-Layer Caching](/lib/CLAUDE.md#-캐싱-시스템-상세)

---

**Last Updated**: 2025-11-10
**Maintainer**: Core Architecture Team
