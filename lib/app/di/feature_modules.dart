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