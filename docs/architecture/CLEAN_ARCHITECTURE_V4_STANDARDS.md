# Clean Architecture v4.0 - Firebase-Centric Standards

> **Version**: 1.0.0
> **Last Updated**: 2025-10-30
> **Status**: Established Standard

## 📋 Overview

This document defines the **official standards** for Clean Architecture v4.0 implementation across all features in the Versus Space project. These standards are derived from analyzing 4 fully migrated features (Auth, Voting, Profile, Chat) and selecting majority patterns.

**Key Principles**:
- Firebase-Centric Architecture (direct Firebase SDK usage)
- Freezed for immutable value objects
- Either Pattern for functional error handling
- 3-Layer caching (Memory → Hive → Firestore)
- Idempotency for duplicate prevention
- Batch operations for performance

---

## 1. Directory Structure Standard

### Mandatory 3-Layer Architecture

```
lib/features/[feature_name]/
├── domain/                    # Pure Dart - Business Logic Layer
│   ├── entities/              # Freezed immutable value objects
│   │   ├── [entity].dart      # Domain entity (Freezed)
│   │   └── [entity]_extensions.dart  # 🔥 Firestore ↔ Entity conversion
│   ├── failures/              # Error handling
│   │   └── [feature]_failure.dart  # Freezed sealed class
│   ├── repositories/          # Repository contracts (Ports)
│   │   └── i_[feature]_repository.dart  # Interface with "I" prefix
│   └── usecases/              # Business operations
│       └── [subdomain]/       # Grouped by subdomain
│           └── [operation]_usecase.dart
│
├── data/                      # Infrastructure Layer
│   ├── repositories/          # Repository implementations (Adapters)
│   │   └── [feature]_repository_impl.dart
│   ├── services/              # Feature-specific services (Optional)
│   │   └── [service_name]_service.dart
│   └── (No datasources)       # ❌ Removed - Firebase direct access
│
├── presentation/              # UI Layer
│   ├── providers/             # Riverpod 2.x state management
│   │   └── [feature]_providers.dart
│   ├── screens/               # Page widgets
│   │   └── [screen]_widget.dart
│   └── widgets/               # Reusable UI components
│       └── [component]_widget.dart
│
└── di/                        # Dependency Injection
    └── [feature]_di_module.dart  # GetIt registration
```

### Key Standards

1. **Extension Location**: `/domain/entities/[entity]_extensions.dart`
   - ✅ Auth, Chat pattern
   - ❌ Not in `/data/extensions/` (Voting legacy)
   - ❌ Not in `/domain/models/` (Profile legacy)

2. **No DataSource Layer**: Direct Firebase access in Repository
   - DataSource abstraction removed in Clean Architecture v4.0
   - Repository directly uses `FirebaseFirestore.instance`

3. **UseCase Organization**: Grouped by subdomain
   - ✅ Profile pattern: `/usecases/profile/`, `/usecases/settings/`
   - ❌ Not flat structure (Auth/Chat/Voting legacy)

---

## 2. Domain Layer Standards

### 2.1 Entities (Freezed Pattern)

**Standard**: All domain entities MUST use Freezed sealed classes.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[entity].freezed.dart';
part '[entity].g.dart';

/// [Entity Description]
///
/// **Business Logic**:
/// - Method 1 description
/// - Method 2 description
@freezed
sealed class UserProfile with _$UserProfile {
  const UserProfile._();  // Private constructor for business methods

  const factory UserProfile({
    required String id,
    required String displayName,
    String? email,
    @Default([]) List<String> interests,
  }) = _UserProfile;

  // JSON serialization
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
    _$UserProfileFromJson(json);

  // ✅ Business Logic Methods (Rich Domain Model)
  bool get hasEmail => email != null && email!.isNotEmpty;

  int get interestCount => interests.length;

  bool hasInterest(String interest) => interests.contains(interest);
}
```

**Key Points**:
- Use `sealed class` for type exhaustiveness
- Include `const UserProfile._()` for business methods
- Business logic belongs in the entity (Rich Domain Model)
- JSON serialization with `fromJson` only (no `toJson` in domain)

---

### 2.2 Extensions (Firestore ↔ Entity Conversion)

**Standard**: Extensions MUST be in `/domain/entities/[entity]_extensions.dart`.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '[entity].dart';

/// Extension for Firestore ↔ UserProfile conversion
///
/// **Responsibilities**:
/// - DocumentSnapshot → Entity (fromFirestore)
/// - Entity → Firestore Map (toFirestoreMap)
/// - Handle camelCase ↔ snake_case conversion
/// - Timestamp ↔ DateTime conversion
extension UserProfileFirestoreExtension on UserProfile {
  /// Convert Entity to Firestore Map
  ///
  /// **Firestore Fields** (camelCase):
  /// - id, displayName, email, interests, createdAt
  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'interests': interests,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create Entity from Firestore DocumentSnapshot
  ///
  /// **Backward Compatibility**:
  /// - Supports both camelCase and snake_case field names
  /// - Handles nullable fields with fallback values
  static UserProfile fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data is null: ${doc.id}');
    }

    return UserProfile(
      id: doc.id,
      displayName: data['displayName'] as String? ??
                   data['display_name'] as String? ?? '',
      email: data['email'] as String?,
      interests: (data['interests'] as List<dynamic>?)
                   ?.map((e) => e as String)
                   .toList() ?? [],
    );
  }
}
```

**Key Points**:
- Place in `/domain/entities/` (NOT `/data/extensions/`)
- Include both `toFirestoreMap()` instance method and `fromFirestore()` static method
- Support backward compatibility (camelCase + snake_case)
- Document Firestore field names in comments
- Handle nullable fields with fallback values

---

### 2.3 Failures (Error Handling)

**Standard**: All failures MUST use Freezed sealed classes.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '[feature]_failure.freezed.dart';

/// Sealed failure class for [Feature]
///
/// **Error Categories**:
/// - Network: Connection/timeout errors
/// - Server: Firebase/backend errors
/// - Validation: Input validation errors
/// - Unknown: Unexpected errors
@freezed
sealed class ProfileFailure with _$ProfileFailure {
  const ProfileFailure._();

  // Network Errors
  const factory ProfileFailure.network(String message) = _Network;
  const factory ProfileFailure.timeout(String message) = _Timeout;

  // Server Errors
  const factory ProfileFailure.serverError(String message) = _ServerError;
  const factory ProfileFailure.notFound(String message) = _NotFound;
  const factory ProfileFailure.permissionDenied(String message) = _PermissionDenied;

  // Validation Errors
  const factory ProfileFailure.invalidInput(String message) = _InvalidInput;
  const factory ProfileFailure.duplicateEntry(String message) = _DuplicateEntry;

  // Unknown
  const factory ProfileFailure.unknown(String message) = _Unknown;

  // ✅ User-friendly message getter
  String get message => when(
    network: (msg) => 'Network error: $msg',
    timeout: (msg) => 'Request timeout: $msg',
    serverError: (msg) => 'Server error: $msg',
    notFound: (msg) => 'Not found: $msg',
    permissionDenied: (msg) => 'Permission denied: $msg',
    invalidInput: (msg) => 'Invalid input: $msg',
    duplicateEntry: (msg) => 'Duplicate entry: $msg',
    unknown: (msg) => 'Unknown error: $msg',
  );
}
```

**Key Points**:
- Use `sealed class` for type exhaustiveness
- Include `const ProfileFailure._()` for business methods
- Group failures by category (Network, Server, Validation, Unknown)
- Provide `message` getter for user-friendly error messages
- Use `.when()` pattern for exhaustive error handling

---

### 2.4 Repository Interfaces (Ports)

**Standard**: Repository interfaces MUST use "I" prefix and return `Either<Failure, T>`.

```dart
import 'package:dartz/dartz.dart';
import '../entities/[entity].dart';
import '../failures/[feature]_failure.dart';

/// Repository interface for [Feature]
///
/// **Responsibilities**:
/// - Define data access contracts
/// - Return Either<Failure, T> for error handling
/// - Support both Futures and Streams
abstract interface class IProfileRepository {
  /// Get user profile by ID
  ///
  /// **Returns**:
  /// - Right(UserProfile): Success
  /// - Left(ProfileFailure): Error
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId);

  /// Stream of user profile changes
  ///
  /// **Returns**:
  /// - Stream of Either<ProfileFailure, UserProfile>
  Stream<Either<ProfileFailure, UserProfile>> watchUserProfile(String userId);

  /// Update user profile
  ///
  /// **Parameters**:
  /// - userId: User ID
  /// - updates: Partial profile data
  /// - eventId: Idempotency key (UUID v4)
  ///
  /// **Returns**:
  /// - Right(unit): Success
  /// - Left(ProfileFailure): Error
  Future<Either<ProfileFailure, Unit>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
    String? eventId,
  });
}
```

**Key Points**:
- Use `abstract interface class` keyword
- Prefix with "I" (e.g., `IProfileRepository`)
- Return `Either<Failure, T>` from dartz package
- Use `Unit` for void success cases
- Document parameters and return values
- Include `eventId` for idempotent operations

---

### 2.5 UseCases

**Standard**: UseCases MUST be organized by subdomain in separate files.

**Directory Structure**:
```
usecases/
├── profile/
│   ├── get_user_profile_usecase.dart
│   ├── update_user_profile_usecase.dart
│   └── delete_user_profile_usecase.dart
├── settings/
│   ├── get_user_settings_usecase.dart
│   └── update_user_settings_usecase.dart
└── interests/
    ├── get_user_interests_usecase.dart
    └── update_user_interests_usecase.dart
```

**UseCase Template**:
```dart
import 'package:dartz/dartz.dart';
import '../../repositories/i_[feature]_repository.dart';
import '../../failures/[feature]_failure.dart';
import '../../entities/[entity].dart';

/// [Operation] UseCase
///
/// **Business Logic**:
/// - Validation rules
/// - Business rules
/// - Orchestration logic
class GetUserProfileUseCase {
  final IProfileRepository _repository;

  const GetUserProfileUseCase(this._repository);

  /// Execute the use case
  ///
  /// **Parameters**:
  /// - userId: User ID to fetch
  ///
  /// **Returns**:
  /// - Right(UserProfile): Success
  /// - Left(ProfileFailure): Error
  ///
  /// **Business Rules**:
  /// - userId must not be empty
  /// - Returns ProfileFailure.invalidInput if validation fails
  Future<Either<ProfileFailure, UserProfile>> call(String userId) async {
    // Validation
    if (userId.isEmpty) {
      return left(const ProfileFailure.invalidInput('User ID cannot be empty'));
    }

    // Delegate to repository
    return await _repository.getUserProfile(userId);
  }
}
```

**Key Points**:
- One UseCase per file
- Group by subdomain (e.g., `profile/`, `settings/`)
- Constructor injection of repository
- Use `call()` method for execution
- Include validation and business rules
- Delegate actual data access to repository
- Simple pass-through for basic operations

---

## 3. Data Layer Standards

### 3.1 Repository Implementation

**Standard**: Repository implementations MUST use Firebase SDK directly.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '/core/utils/batch_service.dart';
import '/core/utils/idempotency_service.dart';
import '/services/cache/unified_cache_service.dart';
import '../../domain/repositories/i_[feature]_repository.dart';
import '../../domain/entities/[entity].dart';
import '../../domain/entities/[entity]_extensions.dart';
import '../../domain/failures/[feature]_failure.dart';

/// Repository implementation for [Feature]
///
/// **Clean Architecture v4.0 - Firebase-Centric**:
/// - Direct Firebase SDK usage (no DataSource layer)
/// - Extension-based Firestore ↔ Entity conversion
/// - UnifiedCacheService for 3-layer caching
/// - BatchService for atomic operations
/// - IdempotencyService for duplicate prevention
class ProfileRepositoryImpl implements IProfileRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;
  final BatchService _batchService;
  final IdempotencyService _idempotencyService;

  ProfileRepositoryImpl({
    required FirebaseFirestore firestore,
    required BatchService batchService,
    required IdempotencyService idempotencyService,
  })  : _firestore = firestore,
        _batchService = batchService,
        _idempotencyService = idempotencyService;

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserProfile(String userId) async {
    try {
      // 1. Check cache first (L1: Memory, L2: Hive, L3: Firestore offline)
      final cachedProfile = await _cacheService.getUserProfile(userId);
      if (cachedProfile != null) {
        _logDebug('Cache hit for user: $userId');
        return right(cachedProfile);
      }

      // 2. Fetch from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        return left(const ProfileFailure.notFound('User profile not found'));
      }

      // 3. Convert to entity using Extension
      final profile = UserProfileFirestoreExtension.fromFirestore(doc);

      // 4. Cache the result
      await _cacheService.setUserProfile(userId, profile);

      _logDebug('Fetched and cached user: $userId');
      return right(profile);

    } on FirebaseException catch (e) {
      _logError('Firebase error: $e');
      return left(_mapFirebaseException(e));
    } catch (e) {
      _logError('Unexpected error: $e');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
    String? eventId,
  }) async {
    try {
      // Use IdempotencyService for duplicate prevention
      if (eventId != null) {
        await _idempotencyService.executeIdempotent<void>(
          entityType: 'profile_updates',
          entityId: userId,
          userId: userId,
          eventId: eventId,
          operation: (transaction) async {
            final docRef = _firestore.collection('users').doc(userId);
            transaction.update(docRef, updates);
          },
        );
      } else {
        // Direct update without idempotency
        await _firestore.collection('users').doc(userId).update(updates);
      }

      // Invalidate cache
      await _cacheService.invalidateUserProfile(userId);

      _logDebug('Updated user profile: $userId');
      return right(unit);

    } on IdempotencyViolation catch (e) {
      _logError('Idempotency violation: $e');
      return left(ProfileFailure.duplicateEntry(e.message));
    } on FirebaseException catch (e) {
      _logError('Firebase error: $e');
      return left(_mapFirebaseException(e));
    } catch (e) {
      _logError('Unexpected error: $e');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }

  // === Private Helpers ===

  /// Map Firebase exceptions to domain failures
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return ProfileFailure.permissionDenied(e.message ?? 'Permission denied');
      case 'not-found':
        return ProfileFailure.notFound(e.message ?? 'Document not found');
      case 'unavailable':
        return ProfileFailure.network(e.message ?? 'Network unavailable');
      case 'deadline-exceeded':
        return ProfileFailure.timeout(e.message ?? 'Request timeout');
      default:
        return ProfileFailure.serverError(e.message ?? 'Unknown server error');
    }
  }

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[ProfileRepository] $message');
    }
  }

  void _logError(String message) {
    debugPrint('[ProfileRepository] ❌ ERROR: $message');
  }
}
```

**Key Points**:
- Direct `FirebaseFirestore` injection (no DataSource)
- Use Extension for Firestore ↔ Entity conversion
- Integrate UnifiedCacheService for 3-layer caching
- Integrate BatchService for atomic operations
- Integrate IdempotencyService for duplicate prevention
- Map Firebase exceptions to domain failures
- Include debug logging with `_logDebug()` and `_logError()`
- Cache invalidation after updates

---

## 4. Service Integration Standards

### 4.1 UnifiedCacheService

**Location**: `/lib/services/cache/unified_cache_service.dart` (Global)

**Usage Pattern**:
```dart
// In Repository
final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

// Check cache
final cached = await _cacheService.getUserProfile(userId);
if (cached != null) return right(cached);

// Set cache after fetch
await _cacheService.setUserProfile(userId, profile);

// Invalidate cache after update
await _cacheService.invalidateUserProfile(userId);
```

**Cache Keys**:
- `user_profile_{userId}` - User profiles
- `chat_messages_{chatId}` - Chat messages
- `feed_posts` - Home feed posts

**Cache Layers**:
- L1: Memory Cache (< 10ms, 100 items, 5 min TTL)
- L2: Hive Local DB (10-30ms, persistent)
- L3: Firestore Offline (50-100ms, unlimited)

---

### 4.2 BatchService

**Location**: `/lib/core/utils/batch_service.dart` (Global)

**Usage Pattern**:
```dart
// Inject in Repository
final BatchService _batchService;

// Example 1: Generic batch operations
final operations = [
  BatchOperation.set(docRef1, data1),
  BatchOperation.update(docRef2, data2),
  BatchOperation.delete(docRef3),
];

await _batchService.executeBatch(
  operations: operations,
  onProgress: (completed, total) {
    debugPrint('Progress: $completed/$total');
  },
);

// Example 2: Use helper methods
await _batchService.updateFullProfile(
  userId: userId,
  profileData: profileData,
  settingsData: settingsData,
  interests: interests,
);

await _batchService.deleteUserAccount(
  userId: userId,
  chatIds: chatIds,
  postIds: postIds,
);

await _batchService.submitVoteWithCounters(
  postId: postId,
  userId: userId,
  voteOption: voteOption,
  currentCounterA: currentCounterA,
  currentCounterB: currentCounterB,
);
```

**When to Use**:
- Multiple Firestore writes that should succeed/fail together
- Bulk operations (notifications, updates)
- Atomic counters (votes, likes)
- Account deletion with cleanup

**Performance Impact**:
- Notifications: 100x improvement (100 writes → 1 batch)
- Profile: 3x speed, 66% fewer network calls
- Auth: Atomic account deletion

---

### 4.3 IdempotencyService

**Location**: `/lib/core/utils/idempotency_service.dart` (Global)

**Usage Pattern**:
```dart
// Inject in Repository
final IdempotencyService _idempotencyService;

// In idempotent operation
await _idempotencyService.executeIdempotent<void>(
  entityType: 'votes',          // Entity collection name
  entityId: postId,              // Entity ID
  userId: userId,                // User performing action
  eventId: eventId,              // Client-generated UUID v4
  operation: (transaction) async {
    // Your Firestore transaction code here
    transaction.set(voteRef, voteData);
    transaction.update(postRef, counterUpdates);
  },
);
```

**When to Use**:
- **Chat**: Message send (prevent duplicate messages)
- **Voting**: Vote submission (prevent duplicate votes)
- **Profile**: Profile update (prevent duplicate updates)
- **Auth**: Account deletion (prevent duplicate deletions)

**How It Works**:
1. Client generates `eventId = Uuid().v4()`
2. Service checks `idempotency` collection for existing record
3. If same `eventId` exists → Skip operation (network retry)
4. If different `eventId` exists → Throw `IdempotencyViolation` (actual duplicate)
5. If no record → Execute operation + store `eventId`

**Cleanup**:
- Automatic via Cloud Functions after operation completes
- Manual via `cleanupIdempotency()` after 24 hours

---

## 5. Presentation Layer Standards

### 5.1 Riverpod 2.x Providers

**Standard**: Use Riverpod 2.x with `.family` for parameterized providers.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/di/di.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/entities/user_profile.dart';

// === UseCase Providers (GetIt wrappers) ===

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>(
  (ref) => getIt<GetUserProfileUseCase>(),
);

// === Stream Providers with Family ===

/// Stream of user profile
///
/// **Parameters**:
/// - userId: User ID to watch
///
/// **Returns**:
/// - UserProfile or null if not found
/// - Errors are logged but not thrown
final userProfileStreamProvider = StreamProvider.autoDispose.family<UserProfile?, String>(
  (ref, userId) async* {
    final useCase = ref.watch(getUserProfileUseCaseProvider);

    yield null; // Initial loading state

    await for (final result in useCase.watchUserProfile(userId)) {
      result.fold(
        (failure) {
          debugPrint('[Provider] Error: ${failure.message}');
          // Don't throw - just log the error
        },
        (profile) {
          yield profile;
        },
      );
    }

    ref.keepAlive(); // Keep stream alive
  },
);

// === State Providers ===

final profileLoadingProvider = StateProvider<bool>((ref) => false);
final profileErrorProvider = StateProvider<String?>((ref) => null);

// === Param Classes for Family Providers ===

class ProfileStreamParams {
  final String userId;
  final bool includeSettings;

  const ProfileStreamParams({
    required this.userId,
    this.includeSettings = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileStreamParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          includeSettings == other.includeSettings;

  @override
  int get hashCode => userId.hashCode ^ includeSettings.hashCode;
}
```

**Key Points**:
- Use `StreamProvider.autoDispose.family` for parameterized streams
- Wrap GetIt dependencies with `Provider`
- Use `StateProvider` for simple state (loading, error)
- Implement param classes with `==` and `hashCode` for caching
- Use `ref.keepAlive()` for cache management
- Don't throw errors in providers - use error state instead

---

## 6. Dependency Injection Standards

### 6.1 DI Module Structure

**Standard**: Each feature MUST have a dedicated DI module.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../domain/repositories/i_[feature]_repository.dart';
import '../domain/usecases/[subdomain]/[operation]_usecase.dart';
import '../data/repositories/[feature]_repository_impl.dart';

/// DI Module for [Feature]
///
/// **Registration Order**:
/// 1. Repositories (LazySingleton)
/// 2. UseCases (Factory)
/// 3. Services (Optional, LazySingleton)
void register[Feature]Module(GetIt getIt) {
  _registerRepositories(getIt);
  _registerUseCases(getIt);
}

void _registerRepositories(GetIt getIt) {
  // Repository Implementation
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      batchService: getIt<BatchService>(),
      idempotencyService: getIt<IdempotencyService>(),
    ),
  );
}

void _registerUseCases(GetIt getIt) {
  // Profile UseCases
  getIt.registerFactory<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(getIt<IProfileRepository>()),
  );

  getIt.registerFactory<UpdateUserProfileUseCase>(
    () => UpdateUserProfileUseCase(getIt<IProfileRepository>()),
  );

  // Settings UseCases
  getIt.registerFactory<GetUserSettingsUseCase>(
    () => GetUserSettingsUseCase(getIt<IProfileRepository>()),
  );
}
```

**Key Points**:
- One module per feature
- Register repositories as `LazySingleton`
- Register use cases as `Factory`
- Inject global services (BatchService, IdempotencyService)
- Group use cases by subdomain in comments

---

### 6.2 Global Services Registration

**Standard**: Core services MUST be registered in `/lib/app/di/di.dart`.

```dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/utils/batch_service.dart';
import '/core/utils/idempotency_service.dart';
import '/services/cache/unified_cache_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDI() async {
  // === Core Services (Singleton) ===

  // BatchService
  getIt.registerLazySingleton<BatchService>(
    () => BatchService(firestore: FirebaseFirestore.instance),
  );

  // IdempotencyService
  getIt.registerLazySingleton<IdempotencyService>(
    () => IdempotencyService(firestore: FirebaseFirestore.instance),
  );

  // UnifiedCacheService (already initialized as singleton)
  // No registration needed - use UnifiedCacheService.instance

  // === Feature Modules ===

  registerAuthModule(getIt);
  registerProfileModule(getIt);
  registerVotingModule(getIt);
  registerChatModule(getIt);
}
```

**Key Points**:
- Register core services before feature modules
- Use `LazySingleton` for services
- UnifiedCacheService uses its own singleton pattern
- Call feature modules in dependency order

---

## 7. Migration Checklist

Use this checklist when migrating a new feature to Clean Architecture v4.0:

### Domain Layer
- [ ] Entities use Freezed sealed classes
- [ ] Extensions are in `/domain/entities/[entity]_extensions.dart`
- [ ] Failures use Freezed sealed classes
- [ ] Repository interface uses "I" prefix
- [ ] Repository returns `Either<Failure, T>`
- [ ] UseCases organized by subdomain
- [ ] UseCases use constructor injection
- [ ] UseCases have validation logic

### Data Layer
- [ ] No DataSource layer (direct Firebase access)
- [ ] Repository implementation uses Firebase SDK
- [ ] Repository integrates UnifiedCacheService
- [ ] Repository integrates BatchService
- [ ] Repository integrates IdempotencyService
- [ ] Repository maps Firebase exceptions to Failures
- [ ] Repository includes debug logging

### Presentation Layer
- [ ] Providers use Riverpod 2.x
- [ ] Stream providers use `.autoDispose.family`
- [ ] Param classes implement `==` and `hashCode`
- [ ] Error handling in providers (don't throw)
- [ ] Use `ref.keepAlive()` for cache management

### Dependency Injection
- [ ] Feature DI module created
- [ ] Repositories registered as `LazySingleton`
- [ ] UseCases registered as `Factory`
- [ ] Global services injected
- [ ] Module registered in `/lib/app/di/di.dart`

### Documentation
- [ ] Feature README.md updated
- [ ] Migration notes added to CLAUDE.md
- [ ] Architecture diagram updated (if needed)

---

## 8. Code Generation Commands

```bash
# Generate Freezed code
flutter pub run build_runner build --delete-conflicting-outputs

# Generate Freezed code (watch mode)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean build cache
flutter pub run build_runner clean

# Analyze code
flutter analyze

# Run tests
flutter test
```

---

## 9. References

- **Freezed**: https://pub.dev/packages/freezed
- **Dartz**: https://pub.dev/packages/dartz
- **Riverpod**: https://riverpod.dev/
- **GetIt**: https://pub.dev/packages/get_it
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

---

## 10. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-10-30 | Initial standards established from 4-feature analysis |

---

**Note**: This document is the **official reference** for all Clean Architecture v4.0 implementations. Any deviations must be documented and justified.
