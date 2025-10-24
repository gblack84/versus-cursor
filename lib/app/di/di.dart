/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정
///
/// 이 파일은 레거시 DI 시스템의 export 파일입니다.
/// 신규 시스템은 /app/di.dart를 사용합니다 (현재 파일이 아닙니다).
///
/// 삭제 조건:
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
/// - 모든 import 경로가 신규 시스템으로 변경 완료 시
///
/// 관련 이슈: Firebase 최적화 마이그레이션

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
export 'creation_module.dart';
