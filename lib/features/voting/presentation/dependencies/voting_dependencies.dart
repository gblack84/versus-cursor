/// Voting Feature Dependencies Interface
///
/// This interface abstracts all dependencies required by the Voting feature's
/// presentation layer, removing direct GetIt references and enabling
/// dependency injection and testing.
abstract class VotingDependencies {
  // ===== Generic UseCase Getter =====
  /// Generic method to get any UseCase by type
  T getUseCase<T extends Object>();

  // ===== Basic Vote Operations =====
  /// UseCase for casting a vote
  dynamic get castVoteUseCase;

  /// UseCase for removing a vote
  dynamic get removeVoteUseCase;

  /// UseCase for submitting a vote
  dynamic get submitVoteUseCase;

  // ===== Vote Counts Operations =====
  /// UseCase for getting vote counts
  dynamic get getVoteCountsUseCase;

  /// UseCase for streaming vote counts
  dynamic get streamVoteCountsUseCase;

  // ===== User Vote Status Operations =====
  /// UseCase for checking if user has voted
  dynamic get checkUserVoteUseCase;

  /// UseCase for checking user vote status
  dynamic get checkUserVoteStatusUseCase;

  /// UseCase for getting vote status
  dynamic get getVoteStatusUseCase;

  /// UseCase for updating vote status
  dynamic get updateVoteStatusUseCase;

  // ===== Vote Expansion Operations =====
  /// UseCase for requesting vote expansion
  dynamic get requestVoteExpansionUseCase;

  // ===== Vote History Operations =====
  /// UseCase for getting vote history
  dynamic get getVoteHistoryUseCase;

  // ===== Coordinators & Helpers =====
  /// Vote state coordinator for managing vote states
  dynamic get voteStateCoordinator;

  /// Vote message helper for handling vote messages
  dynamic get voteMessageHelper;
}