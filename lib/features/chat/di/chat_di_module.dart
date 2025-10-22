/// Chat Feature Dependency Injection Module
///
/// This module configures dependency injection for the Chat feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote)
/// - Repositories
/// - Ports & Adapters (AI Service)
/// - UseCases
/// - Providers

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== Data Layer - DataSource Interfaces =====
import '../data/datasources/i_chat_remote_datasource.dart';

// ===== Data Layer - DataSource Implementations =====
import '../data/datasources/firebase_chat_remote_datasource.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_chat_repository.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/chat_repository_impl.dart';

// ===== App Contracts =====
import '/app/contracts/chat_contract.dart';

// ===== Domain Layer - Port Interfaces =====
import '../domain/ports/i_ai_service.dart';

// ===== Data Layer - Adapters =====
import '../data/adapters/gemini_ai_service.dart';

// ===== Data Layer - Services =====
import '../data/services/chat_message_lifecycle_service.dart';

// ===== Domain Layer - UseCases (10 total) =====
// Chat UseCases (6)
import '../domain/usecases/get_chat_messages_usecase.dart';
import '../domain/usecases/load_more_messages_usecase.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../domain/usecases/search_messages_usecase.dart';
import '../domain/usecases/get_chat_list_usecase.dart';
import '../domain/usecases/send_ai_query_usecase.dart';

// Friends Management UseCases (4)
import '../domain/usecases/get_recommended_friends_usecase.dart';
import '../domain/usecases/search_friends_usecase.dart';
import '../domain/usecases/send_friend_request_usecase.dart';
import '../domain/usecases/toggle_follow_usecase.dart';

// ===== Presentation Layer - Providers =====
import '../presentation/providers/chat_detail_provider.dart';
import '../presentation/providers/ai_chat_provider.dart';
import '../presentation/providers/chat_list_provider.dart';
import '../presentation/providers/friends_provider.dart';

// ===== Presentation Layer - Controllers =====
import '../presentation/screens/chat_detail/chat_detail_controller_v2.dart';

/// Register all Chat feature dependencies
/// Call this function from main setupDependencyInjection()
void registerChatModule(GetIt getIt) {
  // ===== DataSource Registration =====
  _registerDataSource(getIt);

  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== Contract Registration (Cross-Feature Communication) =====
  _registerContract(getIt);

  // ===== Port & Adapter Registration =====
  _registerPorts(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

/// Register Remote DataSource
void _registerDataSource(GetIt getIt) {
  // Remote DataSource (Firebase Firestore)
  getIt.registerLazySingleton<IChatRemoteDatasource>(
    () => FirebaseChatRemoteDatasource(
      firestore: FirebaseFirestore.instance,
    ),
  );
}

/// Register Repository implementation
void _registerRepository(GetIt getIt) {
  // Chat Repository
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(
      remoteDatasource: getIt<IChatRemoteDatasource>(),
    ),
  );
}

/// Register ChatContract for cross-feature communication
/// Uses Dual Interface Pattern - same instance as IChatRepository
void _registerContract(GetIt getIt) {
  // ChatContract: App-level interface for other Features to access Chat functionality
  // Same instance as IChatRepository, different interface type
  // Used by: Notification, Profile, Post, Voting Features
  getIt.registerLazySingleton<ChatContract>(
    () => getIt<IChatRepository>() as ChatRepositoryImpl,
  );
}

/// Register Port & Adapter for AI Service
/// Follows Dependency Inversion Principle - easy to swap AI providers
void _registerPorts(GetIt getIt) {
  // IAIService: Domain Layer 인터페이스 (Port)
  // GeminiAIService: Data Layer 구현체 (Adapter)
  // AI 제공자 교체 시 이 부분만 변경하면 됨
  getIt.registerLazySingleton<IAIService>(
    () => GeminiAIService(),
  );
}

/// Register all UseCases (10 total)
void _registerUseCases(GetIt getIt) {
  // ===== Chat UseCases (6) =====

  getIt.registerFactory(
    () => GetChatMessagesUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  getIt.registerFactory(
    () => LoadMoreMessagesUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  getIt.registerFactory(
    () => SendMessageUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  getIt.registerFactory(
    () => SearchMessagesUseCase(),
  );

  getIt.registerFactory(
    () => GetChatListUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  // SendAIQueryUseCase: AI 쿼리 전송 비즈니스 로직 (Clean Architecture v4.0)
  // IAIService 인터페이스에 의존하여 구현체 교체 가능
  getIt.registerFactory(
    () => SendAIQueryUseCase(
      aiService: getIt<IAIService>(),
    ),
  );

  // ===== Friends Management UseCases (4) =====

  getIt.registerFactory(
    () => GetRecommendedFriendsUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  getIt.registerFactory(
    () => SearchFriendsUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  getIt.registerFactory(
    () => SendFriendRequestUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );

  getIt.registerFactory(
    () => ToggleFollowUseCase(
      chatRepository: getIt<IChatRepository>(),
    ),
  );
}

/// Register Presentation Layer Providers
void _registerProviders(GetIt getIt) {
  // ChatDetailControllerV2 - manages chat messages in memory
  getIt.registerFactory(
    () => ChatDetailControllerV2(),
  );

  // ChatDetailProvider - manages chat detail screen state
  getIt.registerFactory(
    () => ChatDetailProvider(
      getMessagesUseCase: getIt<GetChatMessagesUseCase>(),
      loadMoreUseCase: getIt<LoadMoreMessagesUseCase>(),
      sendMessageUseCase: getIt<SendMessageUseCase>(),
      searchUseCase: getIt<SearchMessagesUseCase>(),
      lifecycleService: ChatMessageLifecycleService(),
      chatController: getIt<ChatDetailControllerV2>(),
    ),
  );

  // AIChatProvider: Clean Architecture v4.0 (AI 기능 통합)
  // IAIService 인터페이스에 의존하여 구현체 교체 가능
  getIt.registerFactory(
    () => AIChatProvider(
      getMessagesUseCase: getIt<GetChatMessagesUseCase>(),
      loadMoreUseCase: getIt<LoadMoreMessagesUseCase>(),
      searchUseCase: getIt<SearchMessagesUseCase>(),
      sendAIQueryUseCase: getIt<SendAIQueryUseCase>(),
      aiService: getIt<IAIService>(),
    ),
  );

  // ChatListProvider - manages chat list screen state
  getIt.registerFactory(
    () => ChatListProvider(
      getChatListUseCase: getIt<GetChatListUseCase>(),
    ),
  );

  // FriendsProvider - manages friends management screen state
  getIt.registerFactory(
    () => FriendsProvider(
      getRecommendedUseCase: getIt<GetRecommendedFriendsUseCase>(),
      searchUseCase: getIt<SearchFriendsUseCase>(),
      sendRequestUseCase: getIt<SendFriendRequestUseCase>(),
      toggleFollowUseCase: getIt<ToggleFollowUseCase>(),
    ),
  );
}
