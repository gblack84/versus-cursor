import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import 'profile_module.dart';
// import 'posts_module.dart'; // REMOVED: Post Feature now uses post_di_module.dart
import 'auth_module.dart';
import 'chat_module.dart';
import 'voting_module.dart';
import 'notification_module.dart';
// import 'search_module.dart'; // REMOVED: Search Feature now uses search_di_module.dart
import '../../core/di/core_module.dart';

/// Main Dependency Injection Container
///
/// Centralizes all dependency registration and management
/// following the Feature-First Clean Architecture pattern
///
/// NOTE: This is the LEGACY DI system. The new system uses
/// setupDependencyInjection() from /app/di.dart
@Deprecated('Use setupDependencyInjection() from /app/di.dart instead')
class DIContainer {
  static final GetIt _serviceLocator = GetIt.instance;
  static bool _isInitialized = false;

  /// Get the global service locator instance
  static GetIt get sl => _serviceLocator;

  /// List of all feature modules to register
  static final List<FeatureModule> _modules = [
    CoreModule(),
    ProfileModule(),
    // PostsModule(), // REMOVED: Post Feature now uses registerPostModule()
    AuthModule(),
    ChatModule(),
    VotingModule(),
    NotificationModule(),
    // SearchModule(), // REMOVED: Search Feature now uses registerSearchModule()
  ];

  /// Initialize all dependencies
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Register all feature modules
      for (final module in _modules) {
        module.register(_serviceLocator);
        print('✅ ${module.name} module registered');
      }

      _isInitialized = true;
      print('✅ DI Container initialized successfully');
    } catch (e) {
      print('❌ DI Container initialization failed: $e');
      rethrow;
    }
  }

  /// Reset all dependencies (primarily for testing)
  static Future<void> reset() async {
    if (!_isInitialized) return;

    try {
      // Unregister all modules in reverse order
      for (final module in _modules.reversed) {
        module.unregister(_serviceLocator);
        print('🔄 ${module.name} module unregistered');
      }

      // Reset GetIt instance
      await _serviceLocator.reset();
      _isInitialized = false;
      print('🔄 DI Container reset successfully');
    } catch (e) {
      print('❌ DI Container reset failed: $e');
      rethrow;
    }
  }

  /// Check if the container is initialized
  static bool get isInitialized => _isInitialized;

  /// Get list of registered modules
  static List<String> get registeredModules =>
      _modules.where((m) => m.isInitialized).map((m) => m.name).toList();
}
