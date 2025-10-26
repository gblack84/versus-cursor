/// Voting Feature Dependency Injection Module
///
/// **Clean Architecture v4.0 - DI Configuration**:
/// - Two Repository implementations:
///   * VotingDialogRepositoryImpl - Dialog voting system
///   * VotingChatRepositoryImpl - Chat card voting system (PostVoting-based)
/// - VoteContractAdapter - Implements VoteContract using IVotingDialogRepository
/// - VoteStateCoordinator - Centralized state management with Repository
/// - No Port/Service layer - simplified architecture

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== App Layer - Contracts =====
import '/app/contracts/vote_contract.dart';

// ===== Domain Layer =====
import '../domain/repositories/i_voting_dialog_repository.dart';
import '../domain/repositories/i_voting_chat_repository.dart';

// ===== Data Layer - DataSources =====
import '../data/datasources/i_voting_remote_datasource.dart';
import '../data/datasources/voting_remote_datasource_impl.dart';
import '../data/datasources/i_voting_local_datasource.dart';
import '../data/datasources/voting_local_datasource_impl.dart';

// ===== Data Layer - Repository Implementations =====
import '../data/repositories/voting_dialog_repository_impl.dart';
import '../data/repositories/voting_chat_repository_impl.dart';

// ===== Data Layer - Adapters =====
import '../data/adapters/vote_contract_adapter.dart';
import '../data/adapters/box_calculator_adapter.dart';

// ===== Domain Layer - Services =====
import '../domain/services/i_box_calculator_service.dart';
import '../domain/services/i_vote_timer_service.dart';

// ===== Data Layer - Services =====
import '../data/services/vote_timer_service.dart';

// ===== Domain Layer - Dialog UseCases =====
import '../domain/usecases/cast_vote_use_case.dart';
import '../domain/usecases/remove_vote_use_case.dart';
import '../domain/usecases/get_vote_counts_use_case.dart';
import '../domain/usecases/stream_vote_counts_use_case.dart';
import '../domain/usecases/check_user_vote_use_case.dart';
import '../domain/usecases/request_vote_expansion_use_case.dart';
import '../domain/usecases/get_vote_history_use_case.dart';

// ===== Domain Layer - Chat Card UseCases =====
import '../domain/usecases/chat_cards/voting_usecases.dart' as chat_cards;
import '../domain/usecases/chat_cards/watch_post_voting_use_case.dart';

// ===== Coordinators & Helpers =====
import '../domain/coordinators/vote_state_coordinator.dart';
import '../data/adapters/vote_message_helper.dart';

/// Register all Voting feature dependencies
/// Call this function from main setupDependencyInjection()
void registerVotingModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Repository Registration =====
  _registerRepositories(getIt);

  // ===== VoteContract Registration =====
  _registerContract(getIt);

  // ===== UseCases Registration =====
  _registerDialogUseCases(getIt);
  _registerChatCardUseCases(getIt);

  // ===== Coordinators & Helpers =====
  _registerCoordinatorsAndHelpers(getIt);
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

/// Register Repository implementations
void _registerRepositories(GetIt getIt) {
  // Dialog Voting Repository (for voting dialogs)
  getIt.registerLazySingleton<IVotingDialogRepository>(
    () => VotingDialogRepositoryImpl(
      remoteDataSource: getIt<IVotingRemoteDataSource>(),
      localDataSource: getIt<IVotingLocalDataSource>(),
    ),
  );

  // Chat Card Voting Repository (PostVoting-based for chat cards)
  getIt.registerLazySingleton<VotingRepository>(
    () => VotingChatRepositoryImpl(
      remoteDataSource: getIt<IVotingRemoteDataSource>(),
      localDataSource: getIt<IVotingLocalDataSource>(),
      firestore: FirebaseFirestore.instance,
    ),
  );
}

/// Register VoteContract (Cross-Feature Communication)
///
/// **Clean Architecture v4.0 - Adapter Pattern**:
/// - VoteContractAdapter implements VoteContract
/// - Uses IVotingDialogRepository for data access
/// - No Port dependencies
void _registerContract(GetIt getIt) {
  getIt.registerLazySingleton<VoteContract>(
    () => VoteContractAdapter(
      repository: getIt<IVotingDialogRepository>(),
    ),
  );
}

/// Register Dialog System UseCases
void _registerDialogUseCases(GetIt getIt) {
  // Basic Vote Operations - Using IVotingDialogRepository
  getIt.registerFactory<CastVoteUseCase>(
    () => CastVoteUseCase(getIt<IVotingDialogRepository>()),
  );

  getIt.registerFactory<RemoveVoteUseCase>(
    () => RemoveVoteUseCase(getIt<IVotingDialogRepository>()),
  );

  // Vote Counts Operations
  getIt.registerFactory<GetVoteCountsUseCase>(
    () => GetVoteCountsUseCase(getIt<IVotingDialogRepository>()),
  );

  getIt.registerFactory<StreamVoteCountsUseCase>(
    () => StreamVoteCountsUseCase(getIt<IVotingDialogRepository>()),
  );

  // User Vote Status Operations
  getIt.registerFactory<CheckUserVoteUseCase>(
    () => CheckUserVoteUseCase(getIt<IVotingDialogRepository>()),
  );

  // Vote Expansion Operations
  getIt.registerFactory<RequestVoteExpansionUseCase>(
    () => RequestVoteExpansionUseCase(getIt<IVotingDialogRepository>()),
  );

  // Vote History Operations
  getIt.registerFactory<GetVoteHistoryUseCase>(
    () => GetVoteHistoryUseCase(getIt<IVotingDialogRepository>()),
  );
}

/// Register Chat Card UseCases
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

/// Register Coordinators and Helper classes
void _registerCoordinatorsAndHelpers(GetIt getIt) {
  // Initialize VoteStateCoordinator with VotingRepository
  VoteStateCoordinator.initialize(
    repository: getIt<VotingRepository>(),
    auth: FirebaseAuth.instance,
  );

  // Vote State Coordinator - uses singleton pattern
  getIt.registerLazySingleton<VoteStateCoordinator>(
    () => VoteStateCoordinator.instance,
  );

  // Vote Message Helper - handles vote-related message operations
  getIt.registerLazySingleton<VoteMessageHelper>(
    () => VoteMessageHelper(),
  );

  // Box Calculator Service - handles voting component size calculations
  getIt.registerLazySingleton<IBoxCalculatorService>(
    () => BoxCalculatorAdapter(),
  );

  // Vote Timer Service - handles voting timer synchronization
  getIt.registerLazySingleton<IVoteTimerService>(
    () => VoteTimerService(),
  );
}
