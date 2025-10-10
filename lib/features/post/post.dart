// Post Feature Exports
// This file exports all public interfaces from the Post feature
// following Clean Architecture v4.0 principles

// ===== Domain Layer =====

// Domain Models
export 'domain/models/post_display.dart';

// Domain Repositories (Interfaces)
export 'domain/repositories/i_post_display_repository_v2.dart';
export 'domain/repositories/i_post_query_service.dart';

// Domain UseCases
export 'domain/usecases/get_feed_usecase.dart';
export 'domain/usecases/get_trending_posts_usecase.dart';
export 'domain/usecases/get_popular_posts_usecase.dart';
export 'domain/usecases/get_user_posts_usecase.dart';
export 'domain/usecases/get_post_detail_usecase.dart';

// ===== Data Layer =====

// Data DTOs (Data Transfer Objects)
export 'data/dto/post_display_dto.dart';

// Data Mappers
export 'data/mappers/post_display_mapper.dart';

// ===== Presentation Layer =====

// Presentation Screens
export 'presentation/screens/feed/home_page_widget.dart';

// Presentation Providers
export 'presentation/providers/feed_provider.dart';