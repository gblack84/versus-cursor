import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../core/repositories/voting_repository.dart';
import '../../features/voting/data/repositories/voting_repository_impl.dart';

/// Voting Feature DI Module
/// 
/// Manages dependency injection for voting-related services
/// following Clean Architecture principles
class VotingModule implements FeatureModule {
  static bool _isInitialized = false;
  
  @override
  String get name => 'Voting';
  
  @override
  void register(GetIt sl) {
    // Register VotingRepository as lazy singleton
    if (!sl.isRegistered<VotingRepository>()) {
      sl.registerLazySingleton<VotingRepository>(
        () => VotingRepositoryImpl.instance,
      );
    }
    
    _isInitialized = true;
  }
  
  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<VotingRepository>()) {
      sl.unregister<VotingRepository>();
    }
    _isInitialized = false;
  }
  
  @override
  bool get isInitialized => _isInitialized;
}