/// Dependency Injection Configuration
///
/// This file configures dependency injection for the application
/// following Clean Architecture principles

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import '/core/utils/idempotency_service.dart';
import '/core/utils/batch_service.dart';

// Feature DI Modules
import '/features/post/di/post_di_module.dart';
import '/features/voting/di/voting_di_module.dart';
import '/features/profile/di/profile_di_module.dart';
import '/features/auth/di/auth_di_module.dart';
import '/features/notifications/di/notification_di_module.dart';
import '/features/chat/di/chat_di_module.dart';
import '/features/creation/di/creation_di_module.dart';
import '/features/search/di/search_di_module.dart';

// ===== Post Feature DI Module =====
// Handled by /features/post/di/post_di_module.dart

// ===== Creation Feature DI Module =====
// Handled by /features/creation/di/creation_di_module.dart

// ===== Profile Feature DI Module =====
// Handled by /features/profile/di/profile_di_module.dart

// ===== Chat Feature DI Module =====
// Handled by /features/chat/di/chat_di_module.dart

// ===== Search Feature DI Module =====
// Handled by /features/search/di/search_di_module.dart


final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> setupDependencyInjection() async {
  // ===== Core Dependencies =====

  // SharedPreferences 인스턴스 초기화
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // IdempotencyService (for Auth, Voting, etc.)
  getIt.registerSingleton<IdempotencyService>(
    IdempotencyService(),
  );

  // BatchService (for atomic Firestore operations across all features)
  getIt.registerSingleton<BatchService>(
    BatchService(),
  );

  // ===== Auth Feature DI =====
  // Note: Auth registration moved to after Profile Feature registration
  // because Auth depends on UserContract (provided by Profile)

  // ===== Creation Feature DI =====
  // Note: CreationContract is registered internally by Creation Feature
  registerCreationModule(getIt);

  // ===== Post Feature DI (MUST BE REGISTERED BEFORE Voting) =====
  // Note: Post Feature provides VoteTimerService that Voting Feature uses
  registerPostModule(getIt);

  // ===== Voting Feature DI =====
  // Note: Registered AFTER Post because uses VoteTimerService from Post Feature
  // Note: VoteContract is registered internally by Voting Feature
  registerVotingModule(getIt);

  // ===== Notifications Feature DI =====
  // Note: Registered AFTER Voting because depends on SubmitVoteUseCase
  registerNotificationModule(getIt);

  // ===== Profile Feature DI =====
  // Note: Registered before Auth because Auth depends on UserContract
  registerProfileModule(getIt);

  // ===== Auth Feature DI =====
  // Note: Registered after Profile because Auth depends on UserContract
  registerAuthModule(getIt);

  // ===== Chat Feature DI =====
  registerChatModule(getIt);

  // ===== Search Feature DI =====
  registerSearchModule(getIt);

  // Add more dependency registrations here as needed
}
