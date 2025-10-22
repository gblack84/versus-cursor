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

// ===== Domain Layer - UseCases (14 total) =====
import '../domain/usecases/cast_vote_use_case.dart';
import '../domain/usecases/remove_vote_use_case.dart';
import '../domain/usecases/get_vote_counts_use_case.dart';
import '../domain/usecases/stream_vote_counts_use_case.dart';
import '../domain/usecases/check_user_vote_use_case.dart';
import '../domain/usecases/check_user_vote_status_use_case.dart';
import '../domain/usecases/get_vote_status_use_case.dart';
import '../domain/usecases/update_vote_status_use_case.dart';
import '../domain/usecases/submit_vote_use_case.dart';
import '../domain/usecases/get_rankings_use_case.dart';
import '../domain/usecases/stream_rankings_use_case.dart';
import '../domain/usecases/update_rankings_use_case.dart';
import '../domain/usecases/request_vote_expansion_use_case.dart';
import '../domain/usecases/get_vote_history_use_case.dart';

// ===== Presentation Layer - Providers =====
import '../presentation/providers/voting_state_provider.dart';
import '../presentation/providers/voting_ui_provider.dart';
import '../presentation/providers/voting_data_provider.dart';

// ===== Presentation Layer - Managers =====
import '../presentation/managers/voting_state_manager.dart';

// ===== Domain Layer - Services =====
import '../domain/services/vote_data_extractor_service.dart';

// ===== Coordinators & Helpers =====
import '../domain/coordinators/vote_state_coordinator.dart';
import '../data/adapters/vote_message_helper.dart';

// ===== Dependencies Abstraction =====
import '../presentation/dependencies/voting_dependencies.dart';
import '../presentation/dependencies/voting_dependencies_impl.dart';

/// Register all Voting feature dependencies
/// Call this function from main setupDependencyInjection()
void registerVotingModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);
  
  // ===== Repository Registration =====
  _registerRepository(getIt);
  
  // ===== UseCases Registration =====
  _registerUseCases(getIt);
  
  // ===== Coordinators & Helpers =====
  _registerCoordinatorsAndHelpers(getIt);
  
  // ===== Dependencies Abstraction Registration =====
  _registerDependenciesAbstraction(getIt);
  
  // ===== Providers Registration =====
  _registerProviders(getIt);
  
  // ===== State Manager Registration =====
  _registerStateManager(getIt);
  
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

  // Rankings Operations
  getIt.registerFactory<GetRankingsUseCase>(
    () => GetRankingsUseCase(getIt<IVotingRepository>()),
  );

  getIt.registerFactory<StreamRankingsUseCase>(
    () => StreamRankingsUseCase(getIt<IVotingRepository>()),
  );

  getIt.registerFactory<UpdateRankingsUseCase>(
    () => UpdateRankingsUseCase(getIt<IVotingRepository>()),
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

/// Register Presentation Layer Providers (3 total)
void _registerProviders(GetIt getIt) {
  // State Provider - manages voting states
  getIt.registerLazySingleton<VotingStateProvider>(
    () => VotingStateProvider(
      castVoteUseCase: getIt<CastVoteUseCase>(),
      removeVoteUseCase: getIt<RemoveVoteUseCase>(),
      checkUserVoteUseCase: getIt<CheckUserVoteUseCase>(),
      getVoteCountsUseCase: getIt<GetVoteCountsUseCase>(),
      streamVoteCountsUseCase: getIt<StreamVoteCountsUseCase>(),
    ),
  );

  // UI Provider - manages UI states and interactions
  getIt.registerLazySingleton<VotingUIProvider>(
    () => VotingUIProvider(),
  );

  // Data Provider - manages data operations and caching
  getIt.registerLazySingleton<VotingDataProvider>(
    () => VotingDataProvider(
      streamVoteCountsUseCase: getIt<StreamVoteCountsUseCase>(),
      streamRankingsUseCase: getIt<StreamRankingsUseCase>(),
      getVoteHistoryUseCase: getIt<GetVoteHistoryUseCase>(),
    ),
  );
}

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
  
  // Register VoteDataExtractorService
  getIt.registerLazySingleton<VoteDataExtractorService>(
    () => VoteDataExtractorService(
      notificationDataPort: getIt<INotificationDataPort>(),
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

/// Register Dependencies Abstraction Layer
void _registerDependenciesAbstraction(GetIt getIt) {
  // Register VotingDependencies interface implementation
  // This encapsulates all GetIt usage for the presentation layer
  getIt.registerLazySingleton<VotingDependencies>(
    () => VotingDependenciesImpl(getIt: getIt),
  );
}

/// Register Voting State Manager
void _registerStateManager(GetIt getIt) {
  // Register VotingStateManager as singleton
  // This manages coordination between AppState and Voting providers
  getIt.registerLazySingleton<VotingStateManager>(
    () => VotingStateManager(
      dependencies: getIt<VotingDependencies>(),
      stateProvider: getIt<VotingStateProvider>(),
      dataProvider: getIt<VotingDataProvider>(),
      uiProvider: getIt<VotingUIProvider>(),
    ),
  );
}