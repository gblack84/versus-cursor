// Creation Data Layer Exports
// Legacy repository removed - 6개의 새로운 전문 리포지토리로 분해됨
// PostsModelAdapter removed - Using CreationFirestoreMapper instead (Feature-First principle)
export 'mappers/creation_firestore_mapper.dart';

// Repositories (Phase 2: Repository consolidation complete)
// Main Repository
export 'repositories/post_creation_repository_v2_impl.dart'; // Includes command operations

// Media Repository
export 'repositories/media_repository_impl.dart';

// Specialized Repositories
export 'repositories/content_metrics_repository_impl.dart';
export 'repositories/content_moderation_repository_impl.dart';
export 'repositories/content_visibility_repository_impl.dart';

// Service Implementations (will be refactored to proper services in Phase 5)
export 'repositories/media_upload_repository_impl.dart';
export 'repositories/image_processing_repository_impl.dart';
export 'repositories/target_audience_repository_impl.dart';

// Query Service moved to Post Feature
// - Previous: creation/data/repositories/creation_query_service_impl.dart
// - Current: post/data/repositories/post_query_service_impl.dart

// Services directory removed - All implementations moved to repositories/
