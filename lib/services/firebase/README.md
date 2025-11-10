# 🔥 Services Firebase - Legacy Firestore Record Pattern

> **DEPRECATED**: This pattern is being phased out in favor of Extension Pattern

**Location**: `lib/services/firebase/legacy_firestore_record.dart`

**Status**: ⚠️ Temporary location for legacy models migration

---

## 📋 Overview

This directory contains the **deprecated FirestoreRecord pattern** used by 4 legacy models during migration to Clean Architecture v4.0 + Firebase-Centric v2.0.

**Current Users**:
1. **ImageModerationModel** (services/moderation) - CRITICAL: Content moderation
2. **SearchesModel** (features/search) - Migrating to Extension Pattern
3. **EncodingsModel** (services/media) - DEPRECATED: Checking Firebase Functions dependency
4. **ClientModel** (core/models) - UNUSED: Safe to delete

---

## ⚠️ Why This Pattern Exists

### Historical Context

**Before (Legacy Pattern)**:
```dart
// Abstract base class for all Firestore models
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, this.snapshotData);

  Map<String, dynamic> snapshotData;
  DocumentReference reference;
}

// Model implementation
class UserModel extends FirestoreRecord {
  UserModel._(DocumentReference reference, Map<String, dynamic> data)
      : super(reference, data);

  static UserModel fromFirestore(DocumentSnapshot snapshot) {
    return UserModel._(
      snapshot.reference,
      mapFromFirestore(snapshot.data() as Map<String, dynamic>),
    );
  }

  String get displayName => snapshotData['displayName'] as String;
  String? get email => snapshotData['email'] as String?;
}
```

**Problems**:
- ❌ **Tight Coupling**: All models inherit from FirestoreRecord (Flutter dependency)
- ❌ **Not Pure Dart**: Cannot use in Domain layer (violates Clean Architecture)
- ❌ **Manual Mapping**: Every field access requires casting and null checks
- ❌ **No Type Safety**: snapshotData is Map<String, dynamic>
- ❌ **No Immutability**: Mutable state through snapshotData
- ❌ **Testing Difficulty**: Hard to mock and test

---

## ✅ Extension Pattern (Recommended)

### Why Extension Pattern?

**Advantages**:
- ✅ **Pure Dart**: Freezed entities work in Domain layer
- ✅ **Type Safe**: Strongly typed fields with compile-time checks
- ✅ **Immutable**: Freezed generates immutable classes with copyWith
- ✅ **Clean Architecture**: Clear separation of layers
- ✅ **Testable**: Easy to create test fixtures and mocks
- ✅ **Maintainable**: Single responsibility - Entity vs Conversion logic

**After (Extension Pattern)**:
```dart
// Domain Entity (Pure Dart, Immutable)
@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String displayName,
    String? email,
    required DateTime createdAt,
  }) = _User;
}

// Data Layer Extension (Firestore Conversion)
extension UserFirestore on User {
  /// Convert Firestore DocumentSnapshot to User entity
  static User fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return User(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert User entity to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Repository Implementation (Direct Firestore)
class UserRepositoryImpl implements IUserRepository {
  final FirebaseFirestore _firestore;

  Future<Either<ProfileFailure, User>> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return left(ProfileFailure.notFound());
      }

      return right(User.fromFirestore(doc));  // Extension method
    } on FirebaseException catch (e) {
      return left(ProfileFailure.serverError(e.message));
    }
  }

  Future<Either<ProfileFailure, void>> updateUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());  // Extension method

      return right(null);
    } on FirebaseException catch (e) {
      return left(ProfileFailure.serverError(e.message));
    }
  }
}
```

---

## 📦 Legacy Components

### FirestoreRecord Abstract Class

```dart
/// Abstract base class for legacy Firestore models
///
/// @deprecated Use Extension Pattern instead (fromFirestore/toFirestore)
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, this.snapshotData);

  /// Firestore document snapshot data
  Map<String, dynamic> snapshotData;

  /// Firestore document reference
  DocumentReference reference;
}
```

**Used By**:
- ImageModerationModel (services/moderation)
- SearchesModel (features/search)
- EncodingsModel (services/media)
- ClientModel (core/models)

---

### Legacy Converters

#### `mapFromFirestore()` - Firestore → App Model

Handles type conversions from Firestore to app model format:

```dart
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) =>
    mergeNestedFields(data).map((key, value) {
      // Timestamp → DateTime
      if (value is Timestamp) {
        value = value.toDate();
      }

      // List<Timestamp> → List<DateTime>
      if (value is Iterable && value.isNotEmpty && value.first is Timestamp) {
        value = value.map((v) => (v as Timestamp).toDate()).toList();
      }

      // GeoPoint → LatLng
      if (value is GeoPoint) {
        value = value.toLatLng();
      }

      // List<GeoPoint> → List<LatLng>
      if (value is Iterable && value.isNotEmpty && value.first is GeoPoint) {
        value = value.map((v) => (v as GeoPoint).toLatLng()).toList();
      }

      // Recursive nested data
      if (value is Map) {
        value = mapFromFirestore(value as Map<String, dynamic>);
      }

      // List of nested data
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapFromFirestore(v as Map<String, dynamic>))
            .toList();
      }

      return MapEntry(key, value);
    });
```

**Conversions**:
- ✅ Timestamp → DateTime
- ✅ GeoPoint → LatLng
- ✅ Nested Map recursion
- ✅ List handling

---

#### `mapToFirestore()` - App Model → Firestore

Handles type conversions from app model to Firestore format:

```dart
Map<String, dynamic> mapToFirestore(Map<String, dynamic> data) =>
    data.map((key, value) {
      // LatLng → GeoPoint
      if (value is LatLng) {
        value = value.toGeoPoint();
      }

      // List<LatLng> → List<GeoPoint>
      if (value is Iterable && value.isNotEmpty && value.first is LatLng) {
        value = value.map((v) => (v as LatLng).toGeoPoint()).toList();
      }

      // Color → CSS String
      if (value is Color) {
        value = AppColorSerialization(value).toCssString();
      }

      // List<Color> → List<String>
      if (value is Iterable && value.isNotEmpty && value.first is Color) {
        value = value
            .map((v) => AppColorSerialization(v as Color).toCssString())
            .toList();
      }

      // Recursive nested data
      if (value is Map) {
        value = mapToFirestore(value as Map<String, dynamic>);
      }

      // List of nested data
      if (value is Iterable && value.isNotEmpty && value.first is Map) {
        value = value
            .map((v) => mapToFirestore(v as Map<String, dynamic>))
            .toList();
      }

      return MapEntry(key, value);
    });
```

**Conversions**:
- ✅ LatLng → GeoPoint
- ✅ Color → CSS String
- ✅ Nested Map recursion
- ✅ List handling

---

## 🔄 Migration Guide

### Step-by-Step Migration

#### 1. Create Freezed Entity (Domain Layer)

```dart
// lib/features/profile/domain/entities/user_profile.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String displayName,
    String? email,
    String? photoUrl,
    required DateTime createdAt,
    @Default(0) int voteCount,
    @Default([]) List<String> followers,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
```

#### 2. Create Extension (Data Layer)

```dart
// lib/features/profile/data/extensions/user_profile_extensions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

extension UserProfileFirestore on UserProfile {
  /// Convert Firestore DocumentSnapshot to UserProfile entity
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      voteCount: data['voteCount'] as int? ?? 0,
      followers: (data['followers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convert UserProfile entity to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'voteCount': voteCount,
      'followers': followers,
    };
  }
}
```

#### 3. Update Repository Implementation

**Before (Legacy)**:
```dart
class ProfileRepositoryImpl implements IProfileRepository {
  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);  // Legacy pattern
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection('users')
        .doc(user.reference.id)
        .update(user.snapshotData);  // Direct Map access
  }
}
```

**After (Extension Pattern)**:
```dart
class ProfileRepositoryImpl implements IProfileRepository {
  Future<Either<ProfileFailure, UserProfile>> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        return left(ProfileFailure.notFound());
      }

      return right(UserProfile.fromFirestore(doc));  // Extension
    } on FirebaseException catch (e) {
      return left(ProfileFailure.serverError(e.message));
    }
  }

  Future<Either<ProfileFailure, void>> updateUser(UserProfile user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toFirestore());  // Extension

      return right(null);
    } on FirebaseException catch (e) {
      return left(ProfileFailure.serverError(e.message));
    }
  }
}
```

#### 4. Update Repository Interface (Domain Layer)

```dart
// lib/features/profile/domain/repositories/i_profile_repository.dart

import 'package:fpdart/fpdart.dart';
import '../entities/user_profile.dart';
import '../failures/profile_failure.dart';

abstract class IProfileRepository {
  Future<Either<ProfileFailure, UserProfile>> getUser(String uid);
  Future<Either<ProfileFailure, void>> updateUser(UserProfile user);
  Stream<Either<ProfileFailure, UserProfile>> watchUser(String uid);
}
```

#### 5. Run Code Generation

```bash
# Generate Freezed and JSON serialization
dart run build_runner build --delete-conflicting-outputs

# Or watch mode for development
dart run build_runner watch --delete-conflicting-outputs
```

#### 6. Update Tests

```dart
// test/features/profile/domain/entities/user_profile_test.dart

void main() {
  group('UserProfile', () {
    test('fromFirestore converts DocumentSnapshot correctly', () {
      // Arrange
      final doc = MockDocumentSnapshot();
      when(doc.id).thenReturn('user123');
      when(doc.data()).thenReturn({
        'displayName': 'John Doe',
        'email': 'john@example.com',
        'createdAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'voteCount': 42,
      });

      // Act
      final user = UserProfile.fromFirestore(doc);

      // Assert
      expect(user.uid, 'user123');
      expect(user.displayName, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.voteCount, 42);
    });

    test('toFirestore converts entity to Map correctly', () {
      // Arrange
      final user = UserProfile(
        uid: 'user123',
        displayName: 'John Doe',
        email: 'john@example.com',
        createdAt: DateTime(2024, 1, 1),
        voteCount: 42,
      );

      // Act
      final data = user.toFirestore();

      // Assert
      expect(data['displayName'], 'John Doe');
      expect(data['email'], 'john@example.com');
      expect(data['createdAt'], isA<Timestamp>());
      expect(data['voteCount'], 42);
    });
  });
}
```

---

## 📊 Migration Status

### Completed Migrations (6 Features)

| Feature | Status | Phase | Migration Date | Notes |
|---------|--------|-------|----------------|-------|
| **Auth** | ✅ Complete | Phase 1-5 | 2025-11-06 | AuthUser entity + Extension |
| **Profile** | ✅ Complete | Phase 1-7 | 2025-11-07 | 3 models + 3-Layer cache |
| **Chat** | ✅ Complete | Phase 1-5 | 2025-11-08 | Message, Chat entities |
| **Notifications** | ✅ Complete | Phase 1-5 | 2025-11-08 | Sealed Union (3 types) |
| **Creation** | ✅ Complete | Phase 1-5 | 2025-11-07 | PostCreation + AI |
| **Voting** | ✅ Complete | Phase 1-7 | 2025-11-06 | Vote, VoteDialog entities |

### Pending Migrations (4 Models)

| Model | Location | Status | Priority | Notes |
|-------|----------|--------|----------|-------|
| **ImageModerationModel** | services/moderation | 🔴 CRITICAL | HIGH | Content moderation system |
| **SearchesModel** | features/search | 🟡 IN PROGRESS | MEDIUM | Search Feature migration |
| **EncodingsModel** | services/media | 🟢 CHECK | LOW | Check Firebase Functions dependency |
| **ClientModel** | core/models | ⚪ UNUSED | DELETE | Safe to remove |

---

## 🎯 Migration Roadmap

### Phase 1: Low-Risk Deletions (1 week)

**Goal**: Remove unused ClientModel

**Tasks**:
1. ✅ Verify ClientModel has no references (use `flutter analyze` + `grep -r "ClientModel"`)
2. ✅ Delete `lib/core/models/client_model.dart`
3. ✅ Update imports in any test files
4. ✅ Run tests: `flutter test`
5. ✅ Commit: `chore: Remove unused ClientModel (Legacy pattern cleanup)`

---

### Phase 2: Search Feature Migration (2 weeks)

**Goal**: Migrate SearchesModel to Extension Pattern

**Tasks**:
1. **Create Freezed Entity** (3 days)
   ```dart
   // lib/features/search/domain/entities/search_query.dart
   @freezed
   class SearchQuery with _$SearchQuery {
     const factory SearchQuery({
       required String id,
       required String query,
       required String userId,
       required DateTime createdAt,
       @Default([]) List<String> results,
     }) = _SearchQuery;
   }
   ```

2. **Create Extension** (2 days)
   ```dart
   // lib/features/search/data/extensions/search_query_extensions.dart
   extension SearchQueryFirestore on SearchQuery {
     static SearchQuery fromFirestore(DocumentSnapshot doc) { ... }
     Map<String, dynamic> toFirestore() { ... }
   }
   ```

3. **Update Repository** (3 days)
   - Replace SearchesModel with SearchQuery
   - Use Extension methods
   - Add Either<Failure, T> error handling

4. **Update Providers** (2 days)
   - Migrate to Riverpod 3.x
   - Use StreamProvider for real-time search

5. **Testing** (2 days)
   - Unit tests for Entity
   - Repository tests
   - Integration tests

6. **Documentation** (1 day)
   - Update Search Feature README
   - Add migration notes

---

### Phase 3: EncodingsModel Dependency Check (1 week)

**Goal**: Determine if EncodingsModel is still needed

**Tasks**:
1. **Analyze Firebase Functions** (2 days)
   ```bash
   cd firebase/functions
   grep -r "encodings" .
   grep -r "EncodingsModel" .
   ```

2. **Check Firestore Rules** (1 day)
   ```bash
   grep -r "encodings" firebase/firestore.rules
   ```

3. **Decision Tree** (1 day):
   - **If used by Firebase Functions**: Keep as-is, document dependency
   - **If deprecated**: Add deprecation notice, plan removal
   - **If unused**: Delete immediately

4. **Documentation** (2 days)
   - Document findings in services/media/README.md
   - Update CLAUDE.md with status

---

### Phase 4: ImageModerationModel Migration (3 weeks)

**Goal**: Migrate critical content moderation to Extension Pattern

**Priority**: HIGH (Content safety feature)

**Tasks**:
1. **Analyze Current Usage** (3 days)
   - Map all ImageModerationModel references
   - Identify Perspective API integration points
   - Document Cloud Vision API usage

2. **Create Freezed Entity** (3 days)
   ```dart
   // lib/services/moderation/domain/entities/image_moderation_result.dart
   @freezed
   class ImageModerationResult with _$ImageModerationResult {
     const factory ImageModerationResult({
       required String imageId,
       required String userId,
       required DateTime analyzedAt,
       required bool isApproved,
       required SafetyScores safetyScores,
       String? rejectionReason,
     }) = _ImageModerationResult;
   }

   @freezed
   class SafetyScores with _$SafetyScores {
     const factory SafetyScores({
       required double adult,
       required double violence,
       required double racy,
       required double medical,
       required double spoof,
     }) = _SafetyScores;
   }
   ```

3. **Create Extension** (2 days)
   ```dart
   extension ImageModerationResultFirestore on ImageModerationResult {
     static ImageModerationResult fromFirestore(DocumentSnapshot doc) { ... }
     Map<String, dynamic> toFirestore() { ... }
   }
   ```

4. **Update Moderation Service** (5 days)
   - Replace ImageModerationModel
   - Integrate Perspective API properly
   - Add comprehensive error handling

5. **Testing** (5 days)
   - **CRITICAL**: Extensive testing required
   - Mock Perspective API responses
   - Test all rejection scenarios
   - Integration tests with Creation Feature

6. **Documentation** (2 days)
   - services/moderation/README.md
   - API integration guide
   - Safety threshold configuration

---

## 🚨 Critical Considerations

### ImageModerationModel Migration

**Why This Is Critical**:
- ⚠️ **User Safety**: Content moderation system
- ⚠️ **Legal Compliance**: May have regulatory requirements
- ⚠️ **API Integration**: Perspective API + Cloud Vision API
- ⚠️ **High Traffic**: Every image upload goes through this

**Pre-Migration Checklist**:
- [ ] Backup current moderation rules
- [ ] Document all API thresholds
- [ ] Set up staging environment testing
- [ ] Prepare rollback plan
- [ ] Monitor error rates during migration

**Testing Requirements**:
- [ ] Test with 100+ sample images (safe + unsafe)
- [ ] Verify Perspective API integration
- [ ] Test Cloud Vision API responses
- [ ] Check rate limiting handling
- [ ] Validate error recovery

---

## 📁 Related Files

| File | Purpose | Status |
|------|---------|--------|
| **`/lib/services/firebase/legacy_firestore_record.dart`** | Legacy pattern (this file) | ⚠️ Temporary |
| **`/lib/core/firebase/firestore_util.dart`** | Generic utilities | ✅ Active |
| **`/lib/features/search/data/utils/algolia_converters.dart`** | Algolia-specific | ✅ Active |
| **`/lib/services/moderation/image_moderation_model.dart`** | Content moderation | 🔴 Needs migration |
| **`/lib/features/search/data/models/searches_model.dart`** | Search queries | 🟡 Migrating |
| **`/lib/services/media/encodings_model.dart`** | Media encoding | 🟢 Check dependency |
| **`/lib/core/models/client_model.dart`** | UNUSED | ⚪ Delete |

---

## 🔗 Further Reading

- [Clean Architecture Overview](/lib/CLAUDE.md#-아키텍처-개요)
- [Extension Pattern Guide](/lib/CLAUDE.md#왜-extension-vs-dtomapper)
- [Firebase-Centric v2.0](/lib/CLAUDE.md#firebase-centric-v20-핵심-변화)
- [Core Firebase Utilities](/lib/core/firebase/README.md)
- [Auth Feature Migration](/lib/features/auth/README.md)
- [Profile Feature Migration](/lib/features/profile/README.md)

---

**Last Updated**: 2025-11-10
**Maintainer**: Core Architecture Team
**Migration Status**: 6/10 Features Complete (60%)
