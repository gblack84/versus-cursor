/// Moderation Services Dependency Injection Module
///
/// This module configures dependency injection for all moderation services
/// following Port-Adapter Pattern and Clean Architecture principles.
///
/// **Architecture**:
/// - Port-Adapter Pattern: Interfaces (Ports) → Implementations (Adapters)
/// - Dependency Injection: Constructor injection for all dependencies
/// - Clean Architecture: Services depend on abstractions, not concretions
///
/// **Registered Services** (5 total):
/// 1. IPerspectiveApiService → PerspectiveApiService (Text toxicity detection)
/// 2. IGeminiModerationService → GeminiModerationService (AI content validation)
/// 3. ICloudImageModerationService → CloudImageModerationService (Image moderation)
/// 4. IAIModerationService → AIModerationService (Orchestrator)
/// 5. IImageModerationService → ImageModerationService (Creation Feature - Cloud Vision API)
///
/// **Dependencies**:
/// - FirebaseFunctions (region: asia-northeast3) for Gemini Cloud Functions
/// - FirebaseFirestore for image moderation status tracking
/// - PerspectiveApiService for text toxicity analysis
///
/// **Phase 3: DI Module Registration** ✅
/// - Created: 2025-11-10
/// - Pattern: Feature-agnostic global service registration
/// - Location: /lib/services/moderation/di/ (Package-Based Services)

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

// ===== Interfaces (Ports) =====
import '../interfaces/i_ai_moderation_service.dart';
import '../interfaces/i_gemini_moderation_service.dart';
import '../interfaces/i_cloud_image_moderation_service.dart';
import '../perspective_api_service.dart'; // Contains IPerspectiveApiService
import '/features/creation/domain/services/i_image_moderation_service.dart'; // Creation Feature Image Moderation

// ===== Implementations (Adapters) =====
import '../ai_moderation_service.dart';
import '../text/gemini_service.dart';
import '../cloud_image_moderation_service.dart';
import '../image_moderation_service.dart'; // Creation Feature Image Moderation Implementation

/// Register all Moderation services and dependencies
///
/// **Call from**: main setupDependencyInjection()
/// **Order**: Can be called anytime (no feature dependencies)
///
/// **Registration Strategy**:
/// - Firebase services: LazySingleton (shared instances)
/// - Moderation services: LazySingleton (stateful, expensive to create)
///
/// **Why LazySingleton?**
/// - Services maintain state (API connections, caching)
/// - Expensive initialization (Firebase instances, HTTP clients)
/// - Thread-safe singleton pattern needed
/// - No need for multiple instances per request
void registerModerationModule(GetIt getIt) {
  // ===== Firebase Dependencies =====
  _registerFirebaseDependencies(getIt);

  // ===== Moderation Services =====
  _registerModerationServices(getIt);
}

/// Register Firebase service instances
///
/// **Firebase Dependencies**:
/// - FirebaseFunctions (region: asia-northeast3) for Gemini AI Cloud Functions
/// - FirebaseFirestore for image moderation Firestore collection
///
/// **Why specific region?**
/// - Gemini Cloud Functions deployed in asia-northeast3 (Seoul)
/// - Lower latency for Korean users
/// - Compliance with data residency requirements
void _registerFirebaseDependencies(GetIt getIt) {
  // Register FirebaseFunctions with specific region
  // Only register if not already registered (avoid conflicts with other modules)
  if (!getIt.isRegistered<FirebaseFunctions>()) {
    getIt.registerLazySingleton<FirebaseFunctions>(
      () => FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
    );
  }

  // Register FirebaseFirestore
  // Only register if not already registered (shared across features)
  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }
}

/// Register all moderation service implementations
///
/// **Registration Order** (dependency graph):
/// 1. PerspectiveApiService (no dependencies)
/// 2. GeminiModerationService (depends on FirebaseFunctions)
/// 3. CloudImageModerationService (depends on FirebaseFirestore)
/// 4. AIModerationService (depends on Perspective + Gemini)
///
/// **Port-Adapter Pattern**:
/// - Register interface (Port) → concrete implementation (Adapter)
/// - Consumers depend on interface, not implementation
/// - Easy to swap implementations for testing or different environments
void _registerModerationServices(GetIt getIt) {
  // 1. Perspective API Service (Text Toxicity Detection)
  //    Uses factory constructor for environment-based API key injection
  getIt.registerLazySingleton<IPerspectiveApiService>(
    () => PerspectiveApiService.fromEnvironment(),
  );

  // 2. Gemini Moderation Service (AI Content Validation)
  //    Depends on: FirebaseFunctions (Cloud Functions region: asia-northeast3)
  getIt.registerLazySingleton<IGeminiModerationService>(
    () => GeminiModerationService(
      functions: getIt<FirebaseFunctions>(),
    ),
  );

  // 3. Cloud Image Moderation Service (Image Safety Check)
  //    Depends on: FirebaseFirestore (imageModeration collection)
  getIt.registerLazySingleton<ICloudImageModerationService>(
    () => CloudImageModerationService(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // 4. AI Moderation Service (Orchestrator)
  //    Depends on: PerspectiveApiService + GeminiModerationService
  //    Orchestrates all moderation checks in correct order:
  //    - Step 1: Perspective API (text toxicity) - fast, cheap
  //    - Step 2: Gemini AI (context validation) - slow, expensive (only if Step 1 passes)
  getIt.registerLazySingleton<IAIModerationService>(
    () => AIModerationService(
      perspectiveService: getIt<IPerspectiveApiService>(),
      geminiService: getIt<IGeminiModerationService>(),
    ),
  );

  // 5. Image Moderation Service (Creation Feature - Cloud Vision API)
  //    Depends on: FirebaseFunctions (Cloud Functions region: asia-northeast3)
  //    Used by: ImageProcessingRepositoryImpl, ModerateContentUseCase, PostCreationRepositoryV2Impl
  //    Note: Different from CloudImageModerationService - this uses Cloud Vision API for content analysis
  getIt.registerLazySingleton<IImageModerationService>(
    () => ImageModerationService(
      functions: getIt<FirebaseFunctions>(),
    ),
  );
}
