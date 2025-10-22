/// Dependency Injection Configuration
///
/// This file configures dependency injection for the application
/// following Clean Architecture principles

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/app/contracts/vote_contract.dart';
import '/app/contracts/creation_contract.dart';

// Feature DI Modules
import '/features/post/di/post_di_module.dart';
import '/features/voting/di/voting_di_module.dart';
import '/features/voting/domain/repositories/i_voting_repository.dart';
import '/features/voting/data/repositories/voting_repository_impl.dart';
import '/features/voting/domain/services/i_vote_service.dart' as voting;
import '/features/creation/domain/repositories/i_post_creation_repository_v2.dart';
import '/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import '/features/profile/di/profile_di_module.dart';
import '/features/auth/di/auth_di_module.dart';
import '/features/notifications/di/notification_di_module.dart';
import '/features/chat/di/chat_di_module.dart';
import '/features/creation/di/creation_di_module.dart';
import '/features/search/di/search_di_module.dart';

// Core Interface Implementations for Cross-Feature Communication
import '/core/interfaces/features/i_vote_service.dart' as core;
import 'di/adapters/core_vote_service_adapter.dart';

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

  // ===== Auth Feature DI =====
  // Note: Auth registration moved to after Profile Feature registration
  // because Auth depends on UserContract (provided by Profile)

  // ===== Creation Feature DI =====
  registerCreationModule(getIt);

  // Register CreationContract (Cross-Feature Communication)
  // Same instance as IPostCreationRepositoryV2, different interface
  // Notification, Chat, Profile 등 다른 Feature가 포스트 생성 기능을 사용할 때 접근
  getIt.registerLazySingleton<CreationContract>(
    () => getIt<IPostCreationRepositoryV2>() as PostCreationRepositoryV2Impl,
  );

  // ===== Post Feature DI (MUST BE REGISTERED BEFORE Voting) =====
  // Note: Post Feature provides VoteTimerService that Voting Feature uses
  registerPostModule(getIt);

  // ===== Voting Feature DI =====
  // Note: Registered AFTER Post because uses VoteTimerService from Post Feature
  // Register all Voting feature dependencies
  // This will register voting.IVoteService and SubmitVoteUseCase internally
  registerVotingModule(getIt);

  // Register VoteContract (Cross-Feature Communication)
  // Same instance as IVotingRepository, different interface
  // Notifications, Posts 등 다른 Feature가 투표 기능을 사용할 때 접근
  getIt.registerLazySingleton<VoteContract>(
    () => getIt<IVotingRepository>() as VotingRepositoryImpl,
  );

  // ===== Notifications Feature DI =====
  // Note: Registered AFTER Voting because depends on SubmitVoteUseCase
  registerNotificationModule(getIt);

  // ===== Core Interface Bindings for Cross-Feature Communication =====
  
  // Register Core IVoteService using adapter pattern after voting module
  // This allows notifications to use voting functionality without direct dependency
  getIt.registerLazySingleton<core.IVoteService>(
    () => CoreVoteServiceAdapter(
      votingService: getIt<voting.IVoteService>(),
    ),
  );

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
