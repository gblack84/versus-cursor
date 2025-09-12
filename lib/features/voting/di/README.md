# Voting Feature - Dependency Injection Module

> **최종 업데이트**: 2025-01-12  
> **버전**: 2.0.0 (Clean Architecture Complete)  
> **DI Framework**: GetIt 7.6.0+

## 📋 개요

Voting Feature의 Dependency Injection 모듈은 GetIt을 사용하여 모든 의존성을 중앙에서 관리합니다. Clean Architecture의 각 레이어 간 의존성을 명확하게 정의하고, 느슨한 결합을 유지합니다.

### 핵심 특징
- ✅ **GetIt Service Locator**: 타입 안전 의존성 주입
- ✅ **Layer Separation**: 각 레이어별 체계적 등록
- ✅ **Lifecycle Management**: Singleton/Factory 패턴 적절히 활용
- ✅ **Port-Adapter Pattern**: 외부 의존성 추상화
- ✅ **Dependency Graph**: 명확한 의존성 그래프 관리

## 🏗️ 디렉토리 구조

```
lib/features/voting/di/
└── voting_di_module.dart    # DI 설정 모듈
```

## 📊 의존성 등록 구조

```
registerVotingModule(GetIt getIt)
│
├── _registerDataSources()       # 데이터 소스 (2개)
│   ├── IVotingRemoteDataSource → VotingRemoteDataSourceImpl
│   └── IVotingLocalDataSource → VotingLocalDataSourceImpl
│
├── _registerRepository()        # Repository (1개)
│   └── IVotingRepository → VotingRepositoryImpl
│
├── _registerUseCases()          # Use Cases (14개)
│   ├── CastVoteUseCase
│   ├── RemoveVoteUseCase
│   ├── SubmitVoteUseCase
│   ├── GetVoteCountsUseCase
│   ├── StreamVoteCountsUseCase
│   ├── CheckUserVoteUseCase
│   ├── CheckUserVoteStatusUseCase
│   ├── GetVoteStatusUseCase
│   ├── UpdateVoteStatusUseCase
│   ├── GetRankingsUseCase
│   ├── StreamRankingsUseCase
│   ├── UpdateRankingsUseCase
│   ├── RequestVoteExpansionUseCase
│   └── GetVoteHistoryUseCase
│
├── _registerPortsAndServices()  # Ports & Services (6개)
│   ├── IVoteStatusService → VoteStatusServiceImpl
│   ├── IVoteService → VoteServiceImpl
│   ├── IVoteStatePort → VoteStateAdapter
│   ├── INotificationDataPort → NotificationDataAdapter
│   ├── IBoxCalculatorPort → BoxCalculatorAdapter
│   └── VoteDataExtractorService
│
├── _registerProviders()         # Providers (3개)
│   ├── VotingStateProvider
│   ├── VotingUIProvider
│   └── VotingDataProvider
│
├── _registerCoordinatorsAndHelpers() # Coordinators (2개)
│   ├── VoteStateCoordinator
│   └── VoteMessageHelper
│
├── _registerDependenciesAbstraction() # Dependencies (1개)
│   └── VotingDependencies → VotingDependenciesImpl
│
└── _registerStateManager()      # Manager (1개)
    └── VotingStateManager
```

## Integration Steps

### 1. Import the voting module in main di.dart

Add this import to `/Users/g_black/versus-cursor/lib/app/di.dart`:

```dart
// Import Voting Feature DI Module
import '/features/voting/di/voting_di_module.dart';
```

### 2. Register VoteTimerPort adapter (IMPORTANT)

**⚠️ Critical**: VoteTimerPort must be registered BEFORE the voting module to avoid dependency errors.

Add this to `di.dart` BEFORE calling `registerVotingModule()`:

```dart
// Posts Feature - VoteTimerService
import '/features/posts/data/adapters/vote/vote_timer_service.dart';

// Voting Feature - Port and Adapter
import '/features/voting/domain/ports/i_vote_timer_port.dart';
import '/features/voting/data/adapters/vote_timer_adapter.dart';

// In setupDependencyInjection():
// Register VoteTimerPort adapter BEFORE the voting module
getIt.registerLazySingleton<IVoteTimerPort>(
  () => VoteTimerAdapter(VoteTimerService()),
);
```

### 3. Register the voting module

After registering VoteTimerPort, add the voting module registration:

```dart
/// Initialize dependency injection
Future<void> setupDependencyInjection() async {
  // ===== Core Dependencies =====
  
  // SharedPreferences initialization (existing)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // ===== Existing Feature Registrations =====
  // ... existing notifications, auth, etc.
  
  // ===== Voting Feature Prerequisites =====
  // IMPORTANT: Register VoteTimerPort BEFORE voting module
  getIt.registerLazySingleton<IVoteTimerPort>(
    () => VoteTimerAdapter(VoteTimerService()),
  );
  
  // ===== NEW: Register Voting Feature =====
  registerVotingModule(getIt);
  
  // ===== Continue with other registrations =====
  // ... rest of existing code
}
```

### 4. Complete integration example

Here's the complete `di.dart` file structure with all necessary imports and registrations:

```dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Existing imports...
// ... (keep all existing imports)

// Posts Feature - VoteTimerService
import '/features/posts/data/adapters/vote/vote_timer_service.dart';

// Voting Feature - Port and Adapter
import '/features/voting/domain/ports/i_vote_timer_port.dart';
import '/features/voting/data/adapters/vote_timer_adapter.dart';

// Voting Feature DI Module
import '/features/voting/di/voting_di_module.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> setupDependencyInjection() async {
  // ===== Core Dependencies =====
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // ===== Posts Feature =====
  getIt.registerLazySingleton<PostsDataSource>(
    () => PostsDataSourceImpl.instance,
  );

  // ===== Auth Feature =====
  getIt.registerLazySingleton<IAuthService>(
    () => AuthServiceImpl(),
  );

  // ===== Notifications Feature =====
  // ... (existing notifications registrations)
  
  // ===== Voting Feature DI =====
  
  // Register VoteTimerPort adapter BEFORE the voting module
  // This wraps the VoteTimerService from posts feature to avoid cross-feature dependency
  getIt.registerLazySingleton<IVoteTimerPort>(
    () => VoteTimerAdapter(VoteTimerService()),
  );
  
  // Register all Voting feature dependencies
  registerVotingModule(getIt);

  // ===== Continue with remaining registrations =====
  // ... rest of existing code
}
```

## What Gets Registered

The voting module registers all these dependencies:

### DataSources (2)
- `IVotingRemoteDataSource` → `VotingRemoteDataSourceImpl`
- `IVotingLocalDataSource` → `VotingLocalDataSourceImpl`

### Repository (1)
- `IVotingRepository` → `VotingRepositoryImpl`

### UseCases (14)
- `CastVoteUseCase`
- `RemoveVoteUseCase`
- `SubmitVoteUseCase`
- `GetVoteCountsUseCase`
- `StreamVoteCountsUseCase`
- `CheckUserVoteUseCase`
- `CheckUserVoteStatusUseCase`
- `GetVoteStatusUseCase`
- `UpdateVoteStatusUseCase`
- `GetRankingsUseCase`
- `StreamRankingsUseCase`
- `UpdateRankingsUseCase`
- `RequestVoteExpansionUseCase`
- `GetVoteHistoryUseCase`

### Providers (3)
- `VotingStateProvider`
- `VotingUIProvider`
- `VotingDataProvider`

### Coordinators & Helpers (2)
- `VoteStateCoordinator`
- `VoteMessageHelper`

## Usage Examples

### Using in Widgets
```dart
class VotingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<VotingStateProvider>(),
      child: Consumer<VotingStateProvider>(
        builder: (context, provider, child) {
          // Use the provider
          return VoteButton(
            onVote: (choice) => provider.castVote(
              postId: 'post123',
              userId: 'user456', 
              choice: choice,
            ),
          );
        },
      ),
    );
  }
}
```

### Using UseCase directly
```dart
class VotingService {
  final CastVoteUseCase _castVoteUseCase = getIt<CastVoteUseCase>();
  
  Future<void> vote(String postId, String userId, String choice) async {
    final params = CastVoteParams(
      postId: postId,
      userId: userId,  
      choice: choice,
    );
    
    final result = await _castVoteUseCase(params);
    // Handle result...
  }
}
```

## Notes

### Cross-Feature Dependency Resolution

The voting feature depends on `VoteTimerService` from the posts feature. To avoid direct cross-feature dependencies, we use the **Port-Adapter Pattern**:

```
posts/VoteTimerService → voting/VoteTimerAdapter → voting/IVoteTimerPort
```

**Key Points:**
- `IVoteTimerPort` is an interface (port) defined in the voting domain
- `VoteTimerAdapter` wraps the external `VoteTimerService` 
- The adapter is registered in `app/di.dart` BEFORE the voting module
- This maintains Clean Architecture boundaries

**Registration Order is Critical:**
```dart
// ✅ Correct: Register adapter first
getIt.registerLazySingleton<IVoteTimerPort>(...);
registerVotingModule(getIt);

// ❌ Wrong: Will cause StateError
registerVotingModule(getIt);
getIt.registerLazySingleton<IVoteTimerPort>(...);
```

### VoteNotification Model Conversion

When using voting notifications from other features, you may need to convert between different `VoteNotification` models:

```dart
// Convert from notifications domain to voting domain
final votingNotification = voting.VoteNotification(
  id: domainNotification.id,
  postId: domainNotification.postId,
  userId: 'user_id',
  type: 'vote_request',
  data: {
    'optionATitle': domainNotification.voteOptions.optionATitle,
    // ... map other fields
  },
  createdAt: DateTime.now(),
);
```

### Already Registered Dependencies
Some dependencies might already be registered in main `di.dart`:

- `IVoteUIDelegate` → `VoteUIManager.instance` (already in main di.dart)

### Future Improvements
1. Refactor `VoteStatusService` to use DI instead of static methods
2. Create proper implementation for `IVoteStatusService`
3. Add integration tests for the DI configuration
4. Consider using modules/feature flags for conditional registration

## Testing

The DI configuration can be tested with the integration test located at `/test/di_integration_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus_space/app/di.dart';
import 'package:versus_space/features/voting/domain/repositories/i_voting_repository.dart';
import 'package:versus_space/features/voting/domain/ports/i_vote_timer_port.dart';
import 'package:versus_space/features/voting/domain/ports/i_vote_status_service.dart';
import 'package:versus_space/features/voting/domain/ports/i_vote_service.dart';
import 'package:versus_space/features/voting/domain/usecases/cast_vote_use_case.dart';
import 'package:versus_space/features/voting/presentation/providers/voting_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Voting DI Integration Tests', () {
    late GetIt sl;

    setUpAll(() async {
      // Initialize SharedPreferences with test values
      SharedPreferences.setMockInitialValues({});
      
      // Setup DI
      await setupDependencyInjection();
      sl = GetIt.instance;
    });

    tearDownAll(() async {
      sl.reset();
    });

    group('Voting Feature DI', () {
      test('Core voting dependencies are registered', () {
        // Core voting dependencies
        expect(sl.isRegistered<IVoteTimerPort>(), isTrue,
            reason: 'IVoteTimerPort should be registered');
        expect(sl.isRegistered<IVotingRepository>(), isTrue,
            reason: 'IVotingRepository should be registered');
        expect(sl.isRegistered<IVoteStatusService>(), isTrue,
            reason: 'IVoteStatusService should be registered');
        expect(sl.isRegistered<IVoteService>(), isTrue,
            reason: 'IVoteService should be registered');
      });
      
      test('Voting UseCases are registered', () {
        expect(sl.isRegistered<CastVoteUseCase>(), isTrue,
            reason: 'CastVoteUseCase should be registered');
      });
      
      test('Voting Providers are registered', () {
        expect(sl.isRegistered<VotingStateProvider>(), isTrue,
            reason: 'VotingStateProvider should be registered');
      });
      
      test('Can resolve voting dependencies', () {
        // Try to resolve key dependencies
        expect(() => sl<IVoteTimerPort>(), returnsNormally,
            reason: 'Should be able to resolve IVoteTimerPort');
        expect(() => sl<IVotingRepository>(), returnsNormally,
            reason: 'Should be able to resolve IVotingRepository');
        expect(() => sl<CastVoteUseCase>(), returnsNormally,
            reason: 'Should be able to resolve CastVoteUseCase');
      });
    });
  });
}
```

### Running the Tests

```bash
# Run the integration test
flutter test test/di_integration_test.dart

# Run with verbose output
flutter test test/di_integration_test.dart -v

# Run all tests including DI tests
flutter test
```

## Troubleshooting

### Common DI Integration Errors and Solutions

#### 1. StateError: IVoteTimerPort is not registered
**Error Message:**
```
StateError: GetIt: Object/Type <IVoteTimerPort> is not registered inside GetIt.
```

**Solution:**
Register IVoteTimerPort BEFORE calling `registerVotingModule()`:
```dart
// ✅ Correct order
getIt.registerLazySingleton<IVoteTimerPort>(
  () => VoteTimerAdapter(VoteTimerService()),
);
registerVotingModule(getIt);

// ❌ Wrong order - will cause StateError
registerVotingModule(getIt);
getIt.registerLazySingleton<IVoteTimerPort>(...);
```

#### 2. VoteServiceImpl Constructor Error
**Error Message:**
```
The named parameter 'voteStatusService' is required, but there's no corresponding argument.
```

**Solution:**
Ensure VoteServiceImpl registration includes the voteStatusService parameter:
```dart
// In notification_module.dart
sl.registerLazySingleton<IVoteService>(
  () => VoteServiceImpl(
    voteStatusService: sl.get(),  // ✅ Add this parameter
  ),
);
```

#### 3. VoteNotification Type Mismatch
**Error Message:**
```
The argument type 'VoteNotification' can't be assigned to the parameter type 'VoteNotification'.
```

**Solution:**
Convert between different VoteNotification models from different features:
```dart
// Convert from notifications domain to voting domain
import 'package:versus_space/features/notifications/domain/models/vote_notification.dart' as notifications;
import 'package:versus_space/features/voting/domain/models/vote_notification.dart' as voting;

final votingNotification = voting.VoteNotification(
  id: notificationsDomainNotification.id,
  postId: notificationsDomainNotification.postId,
  // ... map other fields
);
```

#### 4. Dependency Resolution Order Issues
**Error Message:**
```
GetIt: Object/Type <IVotingRepository> is not registered inside GetIt.
```

**Solution:**
Ensure dependencies are registered in the correct order:
1. Core services (SharedPreferences, Firebase)
2. Cross-feature dependencies (IVoteTimerPort)
3. Feature modules (registerVotingModule)
4. Higher-level services that depend on features

#### 5. Circular Dependency Error
**Error Message:**
```
GetIt: Circular dependency detected
```

**Solution:**
- Review dependency graph for circular references
- Use lazy registration where appropriate
- Consider using factory registration instead of singleton for some services

#### 6. Test Environment Registration Failures
**Error Message:**
```
MissingPluginException(No implementation found for method getAll on channel plugins.flutter.io/shared_preferences)
```

**Solution:**
Initialize test environment properly:
```dart
TestWidgetsFlutterBinding.ensureInitialized();
SharedPreferences.setMockInitialValues({});
```

#### 7. Missing Import Statements
**Error Message:**
```
The name 'VoteTimerService' isn't a type
```

**Solution:**
Ensure all necessary imports are included in di.dart:
```dart
// Posts Feature - VoteTimerService
import '/features/posts/data/adapters/vote/vote_timer_service.dart';

// Voting Feature - Port and Adapter
import '/features/voting/domain/ports/i_vote_timer_port.dart';
import '/features/voting/data/adapters/vote_timer_adapter.dart';
```

### Debugging Tips

1. **Check Registration Order:**
   ```dart
   print('Registered types: ${getIt.allReadyTypes()}');
   ```

2. **Verify Specific Registration:**
   ```dart
   if (getIt.isRegistered<IVoteTimerPort>()) {
     print('IVoteTimerPort is registered');
   }
   ```

3. **Use Verbose Error Messages:**
   ```dart
   try {
     getIt<IVoteTimerPort>();
   } catch (e) {
     print('Failed to resolve IVoteTimerPort: $e');
   }
   ```

4. **Reset GetIt in Tests:**
   ```dart
   tearDown(() {
     getIt.reset();
   });
   ```