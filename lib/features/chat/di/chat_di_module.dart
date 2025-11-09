/// Chat Feature Dependency Injection Module
///
/// This module configures dependency injection for the Chat feature
/// following Clean Architecture v4.0 with Firebase-Centric v2.0:
/// - Repositories (Direct Firestore + Extension Pattern)
/// - Ports & Adapters (AI Service)
/// - UseCases
/// - Providers
///
/// **PHASE 5 Complete**: Extension Pattern 100% 적용
/// - DataSource/DTO/Mapper 제거 (1,790줄 삭제)
/// - Extension Pattern으로 Firestore ↔ Entity 직접 변환
/// - 코드 간소화 및 유지보수성 향상

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== Core Services =====
import '/core/utils/idempotency_service.dart';

// ===== PHASE 3: 3-Layer Caching =====
// Note: UnifiedCacheService는 Repository에서 직접 사용 (싱글톤)

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/i_chat_repository.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/chat_repository_impl.dart';

// ===== App Contracts =====
// Contract 패턴 완전 폐기 (2025-11-09)

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
// Note: All ChangeNotifier-based providers removed (Phase 2 Riverpod migration완료)
//       - ChatDetailProvider → Removed (Riverpod StreamProvider 사용)
//       - AIChatProvider → Removed (Riverpod StreamProvider 사용)
//       - ChatListProvider → Removed (Riverpod StreamProvider 사용)
//       - FriendsProvider → Removed (Phase 2: Riverpod StreamProvider 사용)

// ===== Presentation Layer - Controllers =====
import '../presentation/screens/chat_detail/chat_detail_controller_v2.dart';

/// Register all Chat feature dependencies
/// Call this function from main setupDependencyInjection()
void registerChatModule(GetIt getIt) {
  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== Port & Adapter Registration =====
  _registerPorts(getIt);

  // ===== Services Registration =====
  _registerServices(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

/// Register Repository implementation with Extension Pattern
///
/// **Firebase-Centric v2.0**:
/// - Direct Firestore access (no DataSource layer)
/// - Extension Pattern for Entity ↔ Firestore conversion
/// - Preserves PHASE 3 (3-Layer Caching) + PHASE 4 (Idempotency)
void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(
      idempotencyService: getIt<IdempotencyService>(),
      firestore: FirebaseFirestore.instance,
    ),
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

/// Register Services (Chat-specific services used across the feature)
void _registerServices(GetIt getIt) {
  // PHASE 3: 3-Layer Caching
  // UnifiedCacheService.instance를 Repository에서 직접 사용 (싱글톤)
  // ChatCacheService 래퍼 제거 - Auth/Voting/Profile과 동일한 패턴 사용

  // ChatMessageLifecycleService: 메시지 생명주기 관리 (읽음 처리 등)
  // Singleton으로 등록하여 전체 앱에서 공유
  getIt.registerLazySingleton<ChatMessageLifecycleService>(
    () => ChatMessageLifecycleService(),
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

  // PHASE 4: IdempotencyService removed (now in Repository)
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
///
/// ✅ Phase 2 Riverpod Migration 100% 완료:
/// - ChatDetailProvider → Removed (Riverpod StreamProvider 사용)
/// - AIChatProvider → Removed (Riverpod StreamProvider 사용)
/// - ChatListProvider → Removed (Riverpod StreamProvider 사용)
/// - FriendsProvider → Removed (Phase 2: Riverpod StreamProvider 사용)
///
/// 모든 UseCases는 chat_providers.dart에서 Riverpod Provider로 래핑됨
/// 모든 상태 관리는 Riverpod 2.x StreamProvider.autoDispose.family 사용
void _registerProviders(GetIt getIt) {
  // ChatDetailControllerV2 - manages chat messages in memory
  // ✅ 여전히 사용됨: ChatDetailWidget의 flutter_chat_ui 통합용
  // Note: flutter_chat_ui 라이브러리가 InMemoryChatController를 요구함
  getIt.registerFactory(
    () => ChatDetailControllerV2(),
  );
}
