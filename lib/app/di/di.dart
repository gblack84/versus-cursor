/// Dependency Injection Module
///
/// This module provides centralized dependency injection for the Versus Space app
/// following Clean Architecture principles with Feature-First organization.
///
/// Architecture:
/// - Features register their own dependencies via FeatureModule interface
/// - Core dependencies are registered separately
/// - Each feature maintains strict boundaries (data -> domain -> presentation)
///
/// Usage:
/// ```dart
/// import '/app/di/di.dart';
///
/// // Access services via service locator
/// final userRepo = sl<IUserRepository>();
/// ```

// Main exports
export 'injection.dart';
export 'service_locator.dart';
export 'feature_modules.dart';

// Feature modules
export 'profile_module.dart';
