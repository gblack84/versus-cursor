import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/search/domain/repositories/i_search_repository.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';

/// Search Feature DI Module
///
/// Manages dependency injection for search-related services
/// following Clean Architecture principles
class SearchModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Search';

  @override
  void register(GetIt sl) {
    // Register ISearchRepository as lazy singleton
    if (!sl.isRegistered<ISearchRepository>()) {
      sl.registerLazySingleton<ISearchRepository>(
        () => SearchRepositoryImpl.instance,
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<ISearchRepository>()) {
      sl.unregister<ISearchRepository>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
