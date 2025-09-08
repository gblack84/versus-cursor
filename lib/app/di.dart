/// Dependency Injection Configuration
/// 
/// This file configures dependency injection for the application
/// following Clean Architecture principles

import 'package:get_it/get_it.dart';
import '/features/voting/domain/repositories/posts_data_source.dart';
import '/features/posts/data/adapters/posts_data_source_impl.dart';

// Auth Feature DI
import '/features/auth/domain/services/i_auth_service.dart';
import '/features/auth/data/services/auth_service_impl.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
void setupDependencyInjection() {
  // Register Posts data source for Voting feature
  getIt.registerLazySingleton<PostsDataSource>(
    () => PostsDataSourceImpl.instance,
  );
  
  // Register Auth service
  getIt.registerLazySingleton<IAuthService>(
    () => AuthServiceImpl(),
  );
  
  // Add more dependency registrations here as needed
}