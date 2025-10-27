/// Voting Feature Dependency Injection Module
///
/// **Firebase-Centric Architecture v1.0 - DI Configuration**:
/// - Two Repository implementations:
///   * VotingDialogRepositoryImpl - Dialog voting system
///   * VotingChatRepositoryImpl - Chat card voting system (PostVoting-based)
/// - Direct Firebase SDK injection (no remote DataSource abstraction)
/// - UseCase-based state management with StreamProvider
/// - Extension-based Firestore ↔ Domain conversion

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== Domain Layer =====
import '../domain/repositories/i_voting_dialog_repository.dart';
import '../domain/repositories/i_voting_chat_repository.dart';

// ===== Data Layer - DataSources =====
import '../data/datasources/i_voting_local_datasource.dart';
import '../data/datasources/voting_local_datasource_impl.dart';

// ===== Data Layer - Repository Implementations =====
import '../data/repositories/voting_dialog_repository_impl.dart';
import '../data/repositories/voting_chat_repository_impl.dart';

// ===== Data Layer - Adapters =====
import '../data/adapters/box_calculator_adapter.dart';

// ===== Domain Layer - Services =====
import '../domain/services/i_box_calculator_service.dart';
import '../domain/services/i_vote_timer_service.dart';

// ===== Data Layer - Services =====
import '../data/services/vote_timer_service.dart';

// ===== Domain Layer - UseCases =====
import '../domain/usecases/watch_vote_state_use_case.dart';
import '../domain/usecases/submit_vote_use_case.dart';

// ===== Coordinators & Helpers =====

/// Register all Voting feature dependencies
/// Call this function from main setupDependencyInjection()
void registerVotingModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Repository Registration =====
  _registerRepositories(getIt);

  // ===== UseCases Registration (2 Active UseCases) =====
  _registerChatCardUseCases(getIt);

  // ===== Coordinators & Helpers =====
  _registerCoordinatorsAndHelpers(getIt);
}

/// Register Local DataSource only
///
/// **Firebase-Centric Architecture v1.0**:
/// - No remote DataSource abstraction
/// - Repository directly uses FirebaseFirestore.instance
/// - Local DataSource for caching only
void _registerDataSources(GetIt getIt) {
  // Local DataSource (Cache/SharedPreferences)
  getIt.registerLazySingleton<IVotingLocalDataSource>(
    () => VotingLocalDataSourceImpl(
      prefs: getIt<SharedPreferences>(),
    ),
  );
}

/// Register Repository implementations
///
/// **Firebase-Centric Architecture v1.0**:
/// - Direct FirebaseFirestore.instance injection
/// - No remote DataSource abstraction layer
/// - Extension-based Firestore ↔ Domain conversion
void _registerRepositories(GetIt getIt) {
  // Dialog Voting Repository (for voting dialogs)
  getIt.registerLazySingleton<IVotingDialogRepository>(
    () => VotingDialogRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      localDataSource: getIt<IVotingLocalDataSource>(),
    ),
  );

  // Chat Card Voting Repository (PostVoting-based for chat cards)
  getIt.registerLazySingleton<VotingRepository>(
    () => VotingChatRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      localDataSource: getIt<IVotingLocalDataSource>(),
    ),
  );
}

/// Register Active UseCases
///
/// **Clean Architecture v4.0 - Active UseCases Only**:
/// Only 2 UseCases remain after removing dead code:
/// - SubmitVoteUseCase: Vote submission (replaces Coordinator.submitVote)
/// - WatchVoteStateUseCase: Real-time state stream (replaces Coordinator.getVoteStateStream)
void _registerChatCardUseCases(GetIt getIt) {
  // 1. Watch Vote State (Coordinator.getVoteStateStream 대체)
  getIt.registerFactory<WatchVoteStateUseCase>(
    () => WatchVoteStateUseCase(getIt<VotingRepository>()),
  );

  // 2. Submit Vote (Coordinator.submitVote 대체)
  getIt.registerFactory<SubmitVoteUseCase>(
    () => SubmitVoteUseCase(getIt<VotingRepository>()),
  );
}

/// Register Coordinators and Helper classes
void _registerCoordinatorsAndHelpers(GetIt getIt) {
  // Box Calculator Service - handles voting component size calculations
  getIt.registerLazySingleton<IBoxCalculatorService>(
    () => BoxCalculatorAdapter(),
  );

  // Vote Timer Service - handles voting timer synchronization
  getIt.registerLazySingleton<IVoteTimerService>(
    () => VoteTimerService(),
  );
}
