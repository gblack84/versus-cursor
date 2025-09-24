import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/voting/domain/repositories/i_voting_repository.dart';
import '../../features/voting/domain/ports/i_vote_service.dart';
import '../../features/voting/data/adapters/vote_service_impl.dart';
import '../../features/voting/domain/ports/i_vote_status_service.dart';
import '../../features/voting/data/adapters/vote_status_service_adapter.dart';
import '../../features/voting/domain/ports/i_vote_ui_delegate.dart';
import '../../features/voting/presentation/managers/vote_ui_manager.dart';
import '../../core/domain/ports/i_user_service.dart';

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
    // IVotingRepository is already registered in voting_di_module.dart
    // Skip registration here to avoid conflicts
    
    // Register IVoteStatusService adapter
    if (!sl.isRegistered<IVoteStatusService>()) {
      sl.registerLazySingleton<IVoteStatusService>(
        () => VoteStatusServiceAdapter(),
      );
    }
    
    // Register IVoteService implementation
    if (!sl.isRegistered<IVoteService>()) {
      sl.registerLazySingleton<IVoteService>(
        () => VoteServiceImpl(
          voteStatusService: sl<IVoteStatusService>(),
        ),
      );
    }
    
    // Register IVoteUIDelegate implementation
    if (!sl.isRegistered<IVoteUIDelegate>()) {
      sl.registerLazySingleton<IVoteUIDelegate>(
        () => VoteUIManager(
          userService: sl<IUserService>(),
        ),
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
