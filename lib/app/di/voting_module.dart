import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/voting/domain/repositories/i_voting_repository.dart';
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
    // Register IVotingRepository as lazy singleton
    if (!sl.isRegistered<IVotingRepository>()) {
      sl.registerLazySingleton<IVotingRepository>(
        () => VotingRepositoryImpl.instance,
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IVotingRepository>()) {
      sl.unregister<IVotingRepository>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
