import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/repositories/i_post_repository.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../data/services/target_audience_service.dart';
import '../../data/services/image_upload_service.dart';
import '../../../services/moderation/image_moderation_service.dart';
import 'create_post_provider_v2.dart';
import 'feed_provider.dart';

/// Configuration for Posts feature providers and dependencies
///
/// This class handles the dependency injection setup for the Posts feature,
/// following Clean Architecture principles.
class PostsProviderConfig {
  static final GetIt _getIt = GetIt.instance;

  /// Initialize all Posts feature dependencies
  static Future<void> initialize() async {
    // Check if already initialized
    if (_getIt.isRegistered<CreatePostUseCase>()) {
      return;
    }

    // Register repositories
    _registerRepositories();

    // Register services
    _registerServices();

    // Register use cases
    _registerUseCases();

    // Register providers
    _registerProviders();
  }

  /// Register repository implementations
  static void _registerRepositories() {
    // Post Repository
    if (!_getIt.isRegistered<IPostRepository>()) {
      _getIt.registerLazySingleton<IPostRepository>(
        () => PostRepositoryImpl(),
      );
    }

    // Media Repository
    if (!_getIt.isRegistered<IMediaRepository>()) {
      _getIt.registerLazySingleton<IMediaRepository>(
        () => MediaRepositoryImpl(),
      );
    }
  }

  /// Register service implementations
  static void _registerServices() {
    // Target Audience Service
    if (!_getIt.isRegistered<TargetAudienceService>()) {
      _getIt.registerLazySingleton<TargetAudienceService>(
        () => TargetAudienceService(),
      );
    }

    // Image Upload Service
    if (!_getIt.isRegistered<ImageUploadService>()) {
      _getIt.registerLazySingleton<ImageUploadService>(
        () => ImageUploadService(),
      );
    }

    // Image Moderation Service
    if (!_getIt.isRegistered<ImageModerationService>()) {
      _getIt.registerLazySingleton<ImageModerationService>(
        () => ImageModerationService(),
      );
    }
  }

  /// Register use cases
  static void _registerUseCases() {
    // Create Post UseCase
    _getIt.registerFactory<CreatePostUseCase>(
      () => CreatePostUseCase(
        postRepository: _getIt<IPostRepository>(),
        mediaRepository: _getIt<IMediaRepository>(),
        targetAudienceService: _getIt<TargetAudienceService>(),
        imageUploadService: _getIt<ImageUploadService>(),
      ),
    );

    // Moderate Content UseCase
    _getIt.registerFactory<ModerateContentUseCase>(
      () => ModerateContentUseCase(),
    );

    // Get Feed UseCase
    _getIt.registerFactory<GetFeedUseCase>(
      () => GetFeedUseCase(
        postRepository: _getIt<IPostRepository>(),
      ),
    );
  }

  /// Register providers
  static void _registerProviders() {
    // Note: Providers are typically created per widget/screen
    // so we register them as factories, not singletons

    _getIt.registerFactory<CreatePostProviderV2>(
      () => CreatePostProviderV2(
        createPostUseCase: _getIt<CreatePostUseCase>(),
        moderateContentUseCase: _getIt<ModerateContentUseCase>(),
      ),
    );

    _getIt.registerFactory<FeedProvider>(
      () => FeedProvider(
        getFeedUseCase: _getIt<GetFeedUseCase>(),
      ),
    );
  }

  /// Get CreatePostProviderV2 instance
  static CreatePostProviderV2 getCreatePostProvider() {
    return _getIt<CreatePostProviderV2>();
  }

  /// Get FeedProvider instance
  static FeedProvider getFeedProvider() {
    return _getIt<FeedProvider>();
  }

  /// Create provider with dependency injection
  static T createProvider<T extends ChangeNotifier>() {
    if (T == CreatePostProviderV2) {
      return CreatePostProviderV2(
        createPostUseCase: _getIt<CreatePostUseCase>(),
        moderateContentUseCase: _getIt<ModerateContentUseCase>(),
      ) as T;
    } else if (T == FeedProvider) {
      return FeedProvider(
        getFeedUseCase: _getIt<GetFeedUseCase>(),
      ) as T;
    }
    throw UnimplementedError('Provider $T not configured');
  }

  /// Clean up resources
  static void dispose() {
    // GetIt will handle disposal of singletons
    // Providers should be disposed by their respective widgets
  }

  /// Reset all registrations (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }
}