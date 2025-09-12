/// Voting Feature Dependencies Implementation
///
/// GetIt-based implementation of VotingDependencies interface.
/// This class encapsulates all GetIt usage, keeping it isolated from
/// the presentation layer components.
import 'package:get_it/get_it.dart';
import 'voting_dependencies.dart';

// Import all UseCases
import '../../domain/usecases/cast_vote_use_case.dart';
import '../../domain/usecases/remove_vote_use_case.dart';
import '../../domain/usecases/submit_vote_use_case.dart';
import '../../domain/usecases/get_vote_counts_use_case.dart';
import '../../domain/usecases/stream_vote_counts_use_case.dart';
import '../../domain/usecases/check_user_vote_use_case.dart';
import '../../domain/usecases/check_user_vote_status_use_case.dart';
import '../../domain/usecases/get_vote_status_use_case.dart';
import '../../domain/usecases/update_vote_status_use_case.dart';
import '../../domain/usecases/get_rankings_use_case.dart';
import '../../domain/usecases/stream_rankings_use_case.dart';
import '../../domain/usecases/update_rankings_use_case.dart';
import '../../domain/usecases/request_vote_expansion_use_case.dart';
import '../../domain/usecases/get_vote_history_use_case.dart';

// Import Coordinators and Helpers
import '../../domain/coordinators/vote_state_coordinator.dart';
import '../../data/adapters/vote_message_helper.dart';

class VotingDependenciesImpl implements VotingDependencies {
  final GetIt _getIt;

  VotingDependenciesImpl({GetIt? getIt}) : _getIt = getIt ?? GetIt.instance;

  // ===== Generic UseCase Getter =====
  @override
  T getUseCase<T extends Object>() => _getIt<T>();

  // ===== Basic Vote Operations =====
  @override
  CastVoteUseCase get castVoteUseCase => _getIt<CastVoteUseCase>();

  @override
  RemoveVoteUseCase get removeVoteUseCase => _getIt<RemoveVoteUseCase>();

  @override
  SubmitVoteUseCase get submitVoteUseCase => _getIt<SubmitVoteUseCase>();

  // ===== Vote Counts Operations =====
  @override
  GetVoteCountsUseCase get getVoteCountsUseCase => _getIt<GetVoteCountsUseCase>();

  @override
  StreamVoteCountsUseCase get streamVoteCountsUseCase => _getIt<StreamVoteCountsUseCase>();

  // ===== User Vote Status Operations =====
  @override
  CheckUserVoteUseCase get checkUserVoteUseCase => _getIt<CheckUserVoteUseCase>();

  @override
  CheckUserVoteStatusUseCase get checkUserVoteStatusUseCase => _getIt<CheckUserVoteStatusUseCase>();

  @override
  GetVoteStatusUseCase get getVoteStatusUseCase => _getIt<GetVoteStatusUseCase>();

  @override
  UpdateVoteStatusUseCase get updateVoteStatusUseCase => _getIt<UpdateVoteStatusUseCase>();

  // ===== Rankings Operations =====
  @override
  GetRankingsUseCase get getRankingsUseCase => _getIt<GetRankingsUseCase>();

  @override
  StreamRankingsUseCase get streamRankingsUseCase => _getIt<StreamRankingsUseCase>();

  @override
  UpdateRankingsUseCase get updateRankingsUseCase => _getIt<UpdateRankingsUseCase>();

  // ===== Vote Expansion Operations =====
  @override
  RequestVoteExpansionUseCase get requestVoteExpansionUseCase => _getIt<RequestVoteExpansionUseCase>();

  // ===== Vote History Operations =====
  @override
  GetVoteHistoryUseCase get getVoteHistoryUseCase => _getIt<GetVoteHistoryUseCase>();

  // ===== Coordinators & Helpers =====
  @override
  VoteStateCoordinator get voteStateCoordinator => _getIt<VoteStateCoordinator>();

  @override
  VoteMessageHelper get voteMessageHelper => _getIt<VoteMessageHelper>();
}