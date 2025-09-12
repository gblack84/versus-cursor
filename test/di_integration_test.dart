import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus_space/app/di.dart';
import 'package:versus_space/features/voting/domain/repositories/i_voting_repository.dart';
import 'package:versus_space/features/voting/domain/ports/i_vote_timer_port.dart';
import 'package:versus_space/features/voting/domain/ports/i_vote_status_service.dart';
import 'package:versus_space/features/voting/domain/ports/i_vote_service.dart';
import 'package:versus_space/features/voting/domain/usecases/cast_vote_use_case.dart';
import 'package:versus_space/features/voting/presentation/providers/voting_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Voting DI Integration Tests', () {
    late GetIt sl;

    setUpAll(() async {
      // Initialize SharedPreferences with test values
      SharedPreferences.setMockInitialValues({});
      
      // Setup DI
      await setupDependencyInjection();
      sl = GetIt.instance;
    });

    tearDownAll(() async {
      sl.reset();
    });

    group('Voting Feature DI', () {
      test('Core voting dependencies are registered', () {
        // Core voting dependencies
        expect(sl.isRegistered<IVoteTimerPort>(), isTrue,
            reason: 'IVoteTimerPort should be registered');
        expect(sl.isRegistered<IVotingRepository>(), isTrue,
            reason: 'IVotingRepository should be registered');
        expect(sl.isRegistered<IVoteStatusService>(), isTrue,
            reason: 'IVoteStatusService should be registered');
        expect(sl.isRegistered<IVoteService>(), isTrue,
            reason: 'IVoteService should be registered');
      });
      
      test('Voting UseCases are registered', () {
        expect(sl.isRegistered<CastVoteUseCase>(), isTrue,
            reason: 'CastVoteUseCase should be registered');
      });
      
      test('Voting Providers are registered', () {
        expect(sl.isRegistered<VotingStateProvider>(), isTrue,
            reason: 'VotingStateProvider should be registered');
      });
      
      test('Can resolve voting dependencies', () {
        // Try to resolve key dependencies
        expect(() => sl<IVoteTimerPort>(), returnsNormally,
            reason: 'Should be able to resolve IVoteTimerPort');
        expect(() => sl<IVotingRepository>(), returnsNormally,
            reason: 'Should be able to resolve IVotingRepository');
        expect(() => sl<CastVoteUseCase>(), returnsNormally,
            reason: 'Should be able to resolve CastVoteUseCase');
      });
    });
  });
}
