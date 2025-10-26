/// Voting Feature Dependency Injection Module
///
/// This module configures dependency injection for the Voting feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote/Local)
/// - Repositories 
/// - UseCases
/// - Providers
/// - Services/Ports

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== App Layer - Contracts =====
import '/app/contracts/vote_contract.dart';

// Cross-feature dependency removed - using port interface instead

// ===== Domain Layer =====
import '../domain/repositories/i_voting_repository.dart';
import '../domain/services/i_vote_service.dart';
import '../domain/services/i_vote_status_service.dart';
import '../domain/ports/i_vote_state_port.dart';
import '../domain/ports/i_notification_data_port.dart';
import '../domain/ports/i_vote_ui_delegate.dart';
import '../domain/services/i_box_calculator_service.dart';
import '../domain/services/i_vote_timer_service.dart';

// ===== Data Layer - DataSources =====
import '../data/datasources/i_voting_remote_datasource.dart';
import '../data/datasources/voting_remote_datasource_impl.dart';
import '../data/datasources/i_voting_local_datasource.dart';
import '../data/datasources/voting_local_datasource_impl.dart';

// ===== Data Layer - Repository Implementation =====
import '../data/repositories/voting_repository_impl.dart';
import '../data/adapters/vote_service_impl.dart';
import '../data/adapters/vote_status_service_impl.dart';
import '../data/adapters/vote_state_adapter.dart';
import '../data/adapters/notification_data_adapter.dart';
import '../data/adapters/box_calculator_adapter.dart';

// ===== Domain Layer - Dialog UseCases (11 total) =====
import '../domain/usecases/cast_vote_use_case.dart';
import '../domain/usecases/remove_vote_use_case.dart';
import '../domain/usecases/get_vote_counts_use_case.dart';
import '../domain/usecases/stream_vote_counts_use_case.dart';
import '../domain/usecases/check_user_vote_use_case.dart';
import '../domain/usecases/check_user_vote_status_use_case.dart';
import '../domain/usecases/get_vote_status_use_case.dart';
import '../domain/usecases/update_vote_status_use_case.dart';
import '../domain/usecases/submit_vote_use_case.dart';
import '../domain/usecases/request_vote_expansion_use_case.dart';
import '../domain/usecases/get_vote_history_use_case.dart';

// ===== Domain Layer - Chat Card UseCases (11 total) =====
// Imported with namespace to avoid class name conflicts with dialog usecases
import '../domain/usecases/chat_cards/voting_usecases.dart' as chat_cards;
import '../domain/usecases/chat_cards/watch_post_voting_use_case.dart';
import '../domain/repositories/i_voting_chat_repository.dart';
import '../data/repositories/voting_chat_repository_impl.dart';

// ===== Presentation Layer - Providers =====
// Removed: Old ChangeNotifier providers replaced with Riverpod

// ===== Coordinators & Helpers =====
import '../domain/coordinators/vote_state_coordinator.dart';
import '../data/adapters/vote_message_helper.dart';

/// Register all Voting feature dependencies
/// Call this function from main setupDependencyInjection()
void registerVotingModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Dialog Voting System =====
  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== VoteContract Registration =====
  _registerContract(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Chat Card Voting System =====
  // ===== Chat Card Repository Registration =====
  _registerChatCardRepository(getIt);

  // ===== Chat Card UseCases Registration =====
  _registerChatCardUseCases(getIt);

  // ===== Coordinators & Helpers =====
  _registerCoordinatorsAndHelpers(getIt);

  // ===== Providers Registration =====
  // Removed: Old ChangeNotifier providers replaced with Riverpod

  // ===== Ports & Services Registration =====
  _registerPortsAndServices(getIt);
}

/// Register Remote and Local DataSources
void _registerDataSources(GetIt getIt) {
  // Remote DataSource (Firebase)
  getIt.registerLazySingleton<IVotingRemoteDataSource>(
    () => VotingRemoteDataSourceImpl(
      firestore: FirebaseFirestore.instance,
    ),
  );

  // Local DataSource (Cache/SharedPreferences)
  getIt.registerLazySingleton<IVotingLocalDataSource>(
    () => VotingLocalDataSourceImpl(
      prefs: getIt<SharedPreferences>(),
    ),
  );
}

/// Register Repository implementation
void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<IVotingRepository>(
    () => VotingRepositoryImpl(
      remoteDataSource: getIt<IVotingRemoteDataSource>(),
      localDataSource: getIt<IVotingLocalDataSource>(),
      // VoteContract implementation dependencies
      voteStatePort: getIt<IVoteStatePort>(),
      notificationDataPort: getIt<INotificationDataPort>(),
      voteUIDelegate: getIt<IVoteUIDelegate>(),
    ),
  );
}

/// Register VoteContract (Cross-Feature Communication)
/// VotingRepositoryImpl implements both IVotingRepository and VoteContract (Dual Interface)
void _registerContract(GetIt getIt) {
  getIt.registerLazySingleton<VoteContract>(
    () => getIt<IVotingRepository>() as VotingRepositoryImpl,
  );
}

/// Register all UseCases (14 total)
void _registerUseCases(GetIt getIt) {
  // Basic Vote Operations
  getIt.registerFactory<CastVoteUseCase>(
    () => CastVoteUseCase(getIt<IVotingRepository>()),
  );

  getIt.registerFactory<RemoveVoteUseCase>(
    () => RemoveVoteUseCase(getIt<IVotingRepository>()),
  );

  getIt.registerFactory<SubmitVoteUseCase>(
    () => SubmitVoteUseCase(getIt<IVoteService>()),
  );

  // Vote Counts Operations
  getIt.registerFactory<GetVoteCountsUseCase>(
    () => GetVoteCountsUseCase(getIt<IVotingRepository>()),
  );

  getIt.registerFactory<StreamVoteCountsUseCase>(
    () => StreamVoteCountsUseCase(getIt<IVotingRepository>()),
  );

  // User Vote Status Operations
  getIt.registerFactory<CheckUserVoteUseCase>(
    () => CheckUserVoteUseCase(getIt<IVotingRepository>()),
  );

  getIt.registerFactory<CheckUserVoteStatusUseCase>(
    () => CheckUserVoteStatusUseCase(getIt<IVoteStatusService>()),
  );

  getIt.registerFactory<GetVoteStatusUseCase>(
    () => GetVoteStatusUseCase(getIt<IVoteStatusService>()),
  );

  getIt.registerFactory<UpdateVoteStatusUseCase>(
    () => UpdateVoteStatusUseCase(getIt<IVoteStatusService>()),
  );

  // Vote Expansion Operations
  getIt.registerFactory<RequestVoteExpansionUseCase>(
    () => RequestVoteExpansionUseCase(getIt<IVotingRepository>()),
  );

  // Vote History Operations
  getIt.registerFactory<GetVoteHistoryUseCase>(
    () => GetVoteHistoryUseCase(getIt<IVotingRepository>()),
  );
}

// Removed: _registerProviders function - replaced with Riverpod

/// Register Port adapters and Services
void _registerPortsAndServices(GetIt getIt) {
  // Register VoteStatusService implementation
  getIt.registerLazySingleton<IVoteStatusService>(
    () => VoteStatusServiceImpl(
      repository: getIt<IVotingRepository>(),
    ),
  );
  
  // Register Vote Service Port Implementation
  getIt.registerLazySingleton<IVoteService>(
    () => VoteServiceImpl(
      voteStatusService: getIt<IVoteStatusService>(),
    ),
  );
  
  // Register VoteTimerService adapter
  // Note: VoteTimerService must be registered in app/di.dart
  // to avoid cross-feature dependency
  if (!getIt.isRegistered<IVoteTimerService>()) {
    throw StateError(
      'IVoteTimerService must be registered in app/di.dart before VotingDIModule.init()'
    );
  }

  // Register VoteStatePort implementation
  getIt.registerLazySingleton<IVoteStatePort>(
    () => VoteStateAdapter(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      voteTimerPort: getIt<IVoteTimerService>(),
    ),
  );
  
  // Register NotificationDataPort implementation
  getIt.registerLazySingleton<INotificationDataPort>(
    () => NotificationDataAdapter(
      firestore: FirebaseFirestore.instance,
    ),
  );

  // Register BoxCalculatorService implementation
  getIt.registerLazySingleton<IBoxCalculatorService>(
    () => BoxCalculatorAdapter(),
  );
}

/// Register Coordinators and Helper classes
void _registerCoordinatorsAndHelpers(GetIt getIt) {
  // Initialize VoteStateCoordinator with Port
  VoteStateCoordinator.initialize(getIt<IVoteStatePort>());
  
  // Vote State Coordinator - uses singleton pattern
  getIt.registerLazySingleton<VoteStateCoordinator>(
    () => VoteStateCoordinator.instance,
  );

  // Vote Message Helper - handles vote-related message operations
  getIt.registerLazySingleton<VoteMessageHelper>(
    () => VoteMessageHelper(),
  );
}

// Removed: _registerStateManager function - replaced with Riverpod
// Removed: _registerDependenciesAbstraction function - unused dead code (2025-01-24)

// ============================================================================
// Chat Card Voting System Registration
// ============================================================================

/// Register Chat Card Repository (VotingChatRepositoryImpl)
///
/// **Separation from Dialog System**:
/// - Dialog: VotingRepositoryImpl implements IVotingRepository + VoteContract
/// - Chat Card: VotingChatRepositoryImpl implements VotingRepository (PostVoting-based)
void _registerChatCardRepository(GetIt getIt) {
  getIt.registerLazySingleton<VotingRepository>(
    () => VotingChatRepositoryImpl(
      remoteDataSource: getIt<IVotingRemoteDataSource>(),
      localDataSource: getIt<IVotingLocalDataSource>(),
      firestore: FirebaseFirestore.instance,
    ),
  );
}

/// Register Chat Card UseCases (11 total)
///
/// **PostVoting-based UseCases for Chat Card Voting**:
/// These UseCases use PostVoting domain model with rich business logic
/// and are completely separate from Dialog voting system UseCases.
void _registerChatCardUseCases(GetIt getIt) {
  // 1. Watch PostVoting (Real-time state stream for chat cards)
  getIt.registerFactory<WatchPostVotingUseCase>(
    () => WatchPostVotingUseCase(getIt<VotingRepository>()),
  );

  // 2. Cast Vote
  getIt.registerFactory<chat_cards.CastVoteUseCase>(
    () => chat_cards.CastVoteUseCase(getIt<VotingRepository>()),
  );

  // 3. Start Voting
  getIt.registerFactory<chat_cards.StartVotingUseCase>(
    () => chat_cards.StartVotingUseCase(getIt<VotingRepository>()),
  );

  // 4. Complete Voting
  getIt.registerFactory<chat_cards.CompleteVotingUseCase>(
    () => chat_cards.CompleteVotingUseCase(getIt<VotingRepository>()),
  );

  // 5. Get Voting State
  getIt.registerFactory<chat_cards.GetVotingUseCase>(
    () => chat_cards.GetVotingUseCase(getIt<VotingRepository>()),
  );

  // 6. Has User Voted
  getIt.registerFactory<chat_cards.HasUserVotedUseCase>(
    () => chat_cards.HasUserVotedUseCase(getIt<VotingRepository>()),
  );

  // 7. Expand Voting Reach
  getIt.registerFactory<chat_cards.ExpandVotingReachUseCase>(
    () => chat_cards.ExpandVotingReachUseCase(getIt<VotingRepository>()),
  );

  // 8. Get User Voting Stats
  getIt.registerFactory<chat_cards.GetUserVotingStatsUseCase>(
    () => chat_cards.GetUserVotingStatsUseCase(getIt<VotingRepository>()),
  );

  // 10. Cancel Voting
  getIt.registerFactory<chat_cards.CancelVotingUseCase>(
    () => chat_cards.CancelVotingUseCase(getIt<VotingRepository>()),
  );

  // 11. Send Voting Notifications
  getIt.registerFactory<chat_cards.SendVotingNotificationsUseCase>(
    () => chat_cards.SendVotingNotificationsUseCase(getIt<VotingRepository>()),
  );
}