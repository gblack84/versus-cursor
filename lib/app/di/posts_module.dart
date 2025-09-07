import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/posts/domain/repositories/i_post_repository.dart';
import '../../features/posts/data/repositories/post_repository_impl.dart';

/// Posts Feature DI Module
/// 
/// Manages dependency injection for posts-related services
/// following Clean Architecture principles
class PostsModule implements FeatureModule {
  static bool _isInitialized = false;
  
  @override
  String get name => 'Posts';
  
  @override
  void register(GetIt sl) {
    // Register IPostRepository as lazy singleton
    if (!sl.isRegistered<IPostRepository>()) {
      sl.registerLazySingleton<IPostRepository>(
        () => PostRepositoryImpl(),
      );
    }
    
    _isInitialized = true;
  }
  
  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IPostRepository>()) {
      sl.unregister<IPostRepository>();
    }
    _isInitialized = false;
  }
  
  @override
  bool get isInitialized => _isInitialized;
}