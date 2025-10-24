/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정
///
/// 이 파일은 레거시 DI 시스템의 기반 인터페이스입니다.
/// 신규 시스템은 각 Feature의 DI 모듈이 직접 등록됩니다.
///
/// 삭제 조건:
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
/// - 모든 FeatureModule 구현체가 제거된 후
///
/// 관련 이슈: Firebase 최적화 마이그레이션

import 'package:get_it/get_it.dart';

/// Base interface for all feature modules in the DI system
/// Defines the contract for registering and unregistering dependencies
abstract class FeatureModule {
  /// Unique name identifier for this module
  String get name;

  /// Register all dependencies for this module
  void register(GetIt serviceLocator);

  /// Unregister all dependencies for this module
  void unregister(GetIt serviceLocator);

  /// Check if the module has been initialized
  bool get isInitialized;
}
