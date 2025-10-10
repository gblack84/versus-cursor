/// Dependency Injection Configuration
///
/// This file configures dependency injection for the application
/// following Clean Architecture principles

import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/app/contracts/auth_contract.dart';

// Voting Feature DI Module - TODO: Remove after migration
// import '/features/voting/di/voting_di_module.dart';
import '/features/voting/domain/ports/i_vote_service.dart' as voting;

// Auth Feature DI
import '/features/auth/data/datasources/i_auth_remote_datasource.dart';
import '/features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import '/features/auth/data/datasources/i_auth_local_datasource.dart';
import '/features/auth/data/datasources/auth_local_datasource.dart';
import '/features/auth/domain/repositories/i_auth_repository.dart';
import '/features/auth/data/repositories/auth_repository_impl.dart';
// Auth UseCases
import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_phone_usecase.dart';
import '/features/auth/domain/usecases/sign_out_usecase.dart';
import '/features/auth/domain/usecases/get_current_user_usecase.dart';
import '/features/auth/domain/usecases/password_management_usecase.dart';
import '/features/auth/domain/usecases/email_verification_usecase.dart';
import '/features/auth/domain/usecases/account_management_usecase.dart';
// Auth Provider
import '/features/auth/presentation/providers/auth_provider.dart' as app_auth;

// Notifications Feature DI
import '/features/notifications/domain/repositories/i_notification_repository.dart';
import '/features/notifications/data/repositories/notification_repository_impl.dart';
import '/features/notifications/domain/handlers/i_notification_handler.dart';
import '/features/notifications/presentation/adapters/notification_display_adapter.dart';
import '/features/notifications/domain/services/i_notification_service.dart';
// NOTE: UseCases are imported and registered in NotificationFactory

// Core Interface Implementations for Notifications
import '/core/interfaces/features/i_vote_service.dart' as core;
import '/core/interfaces/features/i_post_service.dart';
import 'di/adapters/core_vote_service_adapter.dart';
import '/features/notifications/data/adapters/mock_post_service_adapter.dart';

// Core Ports
import '/core/domain/ports/i_notification_display_port.dart';

// Voting UI & Adapters
import '/features/voting/domain/ports/i_vote_ui_delegate.dart';
import '/features/voting/presentation/managers/vote_ui_manager.dart';
import '/features/voting/presentation/handlers/vote_handler_impl.dart';
import '/features/notifications/data/adapters/notification_service.dart';
import '/features/notifications/data/datasources/i_remote_notification_datasource.dart';
import '/features/notifications/data/datasources/remote/firebase_notification_datasource.dart';
import '/features/notifications/data/datasources/i_local_notification_datasource.dart';
import '/features/notifications/data/datasources/local/shared_prefs_notification_datasource.dart';
import '/features/notifications/data/datasources/i_post_datasource.dart';
import '/features/notifications/data/datasources/cross/mock_post_datasource.dart';
import '/features/notifications/data/datasources/i_chat_datasource.dart';
import '/features/notifications/data/datasources/cross/mock_chat_datasource.dart';
import '/features/notifications/data/mappers/notification_mapper.dart';

// Posts Feature - VoteTimerService
import '/features/voting/domain/services/vote_timer_service.dart';

// Voting Feature - Port and Adapter
import '/features/voting/domain/ports/i_vote_timer_port.dart';
import '/features/voting/data/adapters/vote_timer_adapter.dart';

// ===== Post Feature Clean Architecture DI =====
// Note: Post Feature DI는 PostsModule에서 관리됩니다 (lib/app/di/posts_module.dart)

// ===== Creation Feature Clean Architecture DI =====
import '/features/creation/data/datasources/interfaces/i_post_creation_datasource.dart';
import '/features/creation/data/datasources/firebase_post_creation_datasource.dart';


final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> setupDependencyInjection() async {
  // ===== Core Dependencies =====

  // SharedPreferences 인스턴스 초기화
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ===== Auth Feature DI =====

  // 1. DataSource 등록
  getIt.registerLazySingleton<IAuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      googleSignIn: GoogleSignIn(),
    ),
  );

  getIt.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDataSource(
      prefs: getIt<SharedPreferences>(),
    ),
  );

  // 2. Repository 등록
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<IAuthRemoteDataSource>(),
      localDataSource: getIt<IAuthLocalDataSource>(),
    ),
  );

  // 3. AuthContract 등록
  getIt.registerLazySingleton<AuthContract>(
    () => getIt<IAuthRepository>() as AuthRepositoryImpl, // AuthRepositoryImpl이 AuthContract 구현
  );

  // 4. 핵심 UseCase 등록 (10개로 통합)
  getIt.registerFactory(() => SignInWithEmailUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => SignUpWithEmailUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => SignInWithGoogleUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => SignInWithAppleUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => SignInWithPhoneUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => SignOutUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => GetCurrentUserUseCase(
    getIt<IAuthRepository>()  // positional argument
  ));
  getIt.registerFactory(() => PasswordManagementUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => EmailVerificationUseCase(
    repository: getIt<IAuthRepository>()
  ));
  getIt.registerFactory(() => AccountManagementUseCase(
    repository: getIt<IAuthRepository>()
  ));

  // 5. AuthProvider 등록 (싱글톤)
  getIt.registerLazySingleton<app_auth.AuthProvider>(
    () => app_auth.AuthProvider(),
  );

  // 6. Legacy Auth Service 제거 완료 (2025-01-29)

  // ===== Post Feature DI =====
  // Note: Post Feature의 모든 DI는 PostsModule에서 관리됩니다
  // - DataSource, Repository, UseCases, Provider
  // - /lib/app/di/posts_module.dart 참조

  // ===== Creation Feature DI (Clean Architecture V2) =====

  // 1. DataSource 등록
  getIt.registerLazySingleton<IPostCreationDataSource>(
    () => FirebasePostCreationDataSource(
      firestore: FirebaseFirestore.instance,
    ),
  );

  // 2. Repository는 posts_module.dart에서 등록됨

  // TODO: Register UseCases when they are refactored to use V2 repositories
  // getIt.registerFactory(() => CreatePostUseCase(
  //   postRepository: getIt<IPostCreationRepositoryV2>(),
  //   mediaRepository: getIt<IMediaRepository>(),
  //   targetAudienceService: getIt<TargetAudienceService>(),
  //   imageUploadService: getIt<ImageUploadService>(),
  // ));

  // ===== Contract 기반 Feature 간 통신 =====

  // Posts Feature가 PostContract를 구현하면 등록:
  // getIt.registerLazySingleton<PostContract>(
  //   () => getIt<PostRepositoryImpl>(), // PostRepositoryImpl이 PostContract 구현
  // );

  // Notification Feature가 NotificationContract를 구현하면 등록:
  // getIt.registerLazySingleton<NotificationContract>(
  //   () => getIt<NotificationRepositoryImpl>(),
  // );

  // ===== Notifications Feature DI =====

  // DataSource 등록
  getIt.registerLazySingleton<IRemoteNotificationDatasource>(
    () => FirebaseNotificationDatasource(
      firestore: FirebaseFirestore.instance,
    ),
  );

  getIt.registerLazySingleton<ILocalNotificationDatasource>(
    () => SharedPrefsNotificationDatasource(
      prefs: getIt<SharedPreferences>(),
    ),
  );

  // Cross-feature DataSource (임시 Mock 구현)
  getIt.registerLazySingleton<IPostDatasource>(
    () => MockPostDatasource(),
  );

  getIt.registerLazySingleton<IChatDatasource>(
    () => MockChatDatasource(),
  );
  
  // ===== Core Interface Adapters =====
  // NOTE: These must be registered AFTER Voting DI Module
  
  // Register Mock Post Service (until Posts feature is migrated)
  getIt.registerLazySingleton<IPostService>(
    () => MockPostServiceAdapter(),
  );
  
  // Register Core Vote Service Adapter (will be registered after Voting module below)

  // Mapper 등록
  getIt.registerLazySingleton<NotificationMapper>(
    () => NotificationMapper(),
  );

  // Register Repository implementation
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: getIt<IRemoteNotificationDatasource>(),
      localDatasource: getIt<ILocalNotificationDatasource>(),
    ),
  );

  // NOTE: UseCases are now registered by NotificationFactory
  // See: /lib/app/di/factories/notification_factory.dart

  // Register Port Implementation for cross-feature communication
  // The VoteHandlerImpl now implements INotificationDisplayPort instead of INotificationHandler
  getIt.registerLazySingleton<INotificationDisplayPort>(
    () => VoteHandlerImpl(uiManager: VoteUIManager.instance),
  );

  // Register Notification Handler with Adapter pattern
  // This adapter delegates to the Port implementation to avoid circular dependencies
  getIt.registerLazySingleton<INotificationHandler>(
    () => NotificationDisplayAdapter(
      port: getIt<INotificationDisplayPort>(),
    ),
  );

  // Register UI Delegate for Voting Feature
  getIt.registerLazySingleton<IVoteUIDelegate>(
    () => VoteUIManager.instance,
  );

  // GlobalNotificationManager is now registered in NotificationModule

  // Register Services (인터페이스로 등록)
  getIt.registerLazySingleton<INotificationService>(
    () => NotificationService(
      repository: getIt<INotificationRepository>(),
      chatDatasource: getIt<IChatDatasource>(),
    ),
  );

  // ===== Voting Feature DI =====
  
  // Register VoteTimerPort adapter BEFORE the voting module
  // This wraps the VoteTimerService from posts feature to avoid cross-feature dependency
  getIt.registerLazySingleton<IVoteTimerPort>(
    () => VoteTimerAdapter(VoteTimerService()),
  );
  
  // Register all Voting feature dependencies
  // This will register voting.IVoteService internally
  // TODO: Remove after Voting feature migration to Contract pattern
  // registerVotingModule(getIt);

  // ===== Core Interface Bindings for Cross-Feature Communication =====
  
  // Register Core IVoteService using adapter pattern after voting module
  // This allows notifications to use voting functionality without direct dependency
  getIt.registerLazySingleton<core.IVoteService>(
    () => CoreVoteServiceAdapter(
      votingService: getIt<voting.IVoteService>(),
    ),
  );
  
  // Register Core IPostService using mock implementation
  // TODO: Replace with real implementation when Posts feature provides one
  getIt.registerLazySingleton<IPostService>(
    () => MockPostServiceAdapter(),
  );

  // Add more dependency registrations here as needed
}
