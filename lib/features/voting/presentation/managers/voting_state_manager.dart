/// Voting State Manager
///
/// This class manages the coordination between AppState and Voting Feature providers.
/// It acts as a bridge to maintain feature independence while enabling state synchronization.
import 'package:flutter/foundation.dart';
import '../providers/voting_state_provider.dart';
import '../providers/voting_data_provider.dart';
import '../providers/voting_ui_provider.dart';
import '../dependencies/voting_dependencies.dart';

/// Manages voting feature state and coordinates with app-level state
class VotingStateManager extends ChangeNotifier {
  static VotingStateManager? _instance;
  
  // Provider instances
  late final VotingStateProvider _stateProvider;
  late final VotingDataProvider _dataProvider;
  late final VotingUIProvider _uiProvider;
  
  // Dependencies
  final VotingDependencies _dependencies;
  
  // State synchronization flags
  bool _isInitialized = false;
  bool _isSyncing = false;
  
  /// Private constructor for singleton
  VotingStateManager._({
    required VotingDependencies dependencies,
    required VotingStateProvider stateProvider,
    required VotingDataProvider dataProvider,
    required VotingUIProvider uiProvider,
  })  : _dependencies = dependencies,
        _stateProvider = stateProvider,
        _dataProvider = dataProvider,
        _uiProvider = uiProvider {
    _setupListeners();
  }
  
  /// Factory constructor for singleton instance
  factory VotingStateManager({
    required VotingDependencies dependencies,
    required VotingStateProvider stateProvider,
    required VotingDataProvider dataProvider,
    required VotingUIProvider uiProvider,
  }) {
    _instance ??= VotingStateManager._(
      dependencies: dependencies,
      stateProvider: stateProvider,
      dataProvider: dataProvider,
      uiProvider: uiProvider,
    );
    return _instance!;
  }
  
  /// Get singleton instance
  static VotingStateManager? get instance => _instance;
  
  /// Reset singleton instance (useful for testing)
  static void reset() {
    _instance?.dispose();
    _instance = null;
  }
  
  // ===== Getters for external access =====
  
  VotingStateProvider get stateProvider => _stateProvider;
  VotingDataProvider get dataProvider => _dataProvider;
  VotingUIProvider get uiProvider => _uiProvider;
  
  bool get isInitialized => _isInitialized;
  bool get isSyncing => _isSyncing;
  
  // ===== Consolidated state getters =====
  
  /// Check if currently voting
  bool get isVoting => _stateProvider.isLoading;
  
  /// Get current user's vote for a post
  String? getUserVote(String postId) => _stateProvider.currentUserVote;
  
  /// Check if voting dialog is visible
  bool get isDialogVisible => _uiProvider.isDialogVisible;
  
  /// Get cached vote counts
  dynamic getVoteCounts(String postId) => _dataProvider.getVoteCounts(postId);
  
  // ===== Initialization =====
  
  /// Initialize the voting state manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Sync initial data if needed
      await _dataProvider.syncAllData();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize VotingStateManager: $e');
      }
      rethrow;
    }
  }
  
  // ===== State Management Methods =====
  
  /// Submit a vote
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String option,
  }) async {
    _isSyncing = true;
    notifyListeners();
    
    try {
      // Cast vote through state provider
      await _stateProvider.castVote(
        postId: postId,
        userId: userId,
        choice: option,  // Changed from 'option' to 'choice'
      );
      
      // Invalidate cache for this post
      _dataProvider.invalidatePostCache(postId);
      
      // Update UI state
      _uiProvider.selectOption(option);  // Changed from setSelectedOption to selectOption
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to submit vote: $e');
      }
      _uiProvider.showError('투표 실패: ${e.toString()}');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Show voting dialog
  void showVotingDialog({
    required String postId,
    required String question,
    required String optionA,
    required String optionB,
  }) {
    _uiProvider.openDialog();  // Changed from showDialog to openDialog
    // Additional dialog setup if needed
  }
  
  /// Hide voting dialog
  void hideVotingDialog() {
    _uiProvider.closeDialog();  // Changed from hideDialog to closeDialog
    _uiProvider.clearSelection();  // Changed from resetInteraction to clearSelection
  }
  
  /// Toggle voting layout
  void toggleVotingLayout() {
    _uiProvider.toggleFullScreenMode();  // Changed from toggleLayout to toggleFullScreenMode
  }
  
  /// Load vote history for user
  Future<void> loadVoteHistory(String userId) async {
    _isSyncing = true;
    notifyListeners();
    
    try {
      final history = await _dataProvider.getVoteHistory(userId);
      // Process history if needed
      if (kDebugMode) {
        debugPrint('Loaded ${history.length} votes for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load vote history: $e');
      }
      _uiProvider.showError('투표 기록 로드 실패');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  /// Stream vote counts for a post
  Stream<dynamic> streamVoteCounts(String postId) {
    // This returns a stream that UI can listen to
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return _dataProvider.getVoteCounts(postId);
    }).where((counts) => counts != null);
  }
  
  // ===== Private Methods =====
  
  /// Setup listeners for provider changes
  void _setupListeners() {
    // Listen to state provider changes
    _stateProvider.addListener(_onStateProviderChanged);
    
    // Listen to data provider changes
    _dataProvider.addListener(_onDataProviderChanged);
    
    // Listen to UI provider changes
    _uiProvider.addListener(_onUIProviderChanged);
  }
  
  /// Handle state provider changes
  void _onStateProviderChanged() {
    // Propagate important state changes
    if (!_isSyncing) {
      notifyListeners();
    }
  }
  
  /// Handle data provider changes
  void _onDataProviderChanged() {
    // Handle cache updates or data changes
    if (!_isSyncing) {
      notifyListeners();
    }
  }
  
  /// Handle UI provider changes
  void _onUIProviderChanged() {
    // Handle UI state changes that might affect other parts
    if (!_isSyncing) {
      notifyListeners();
    }
  }
  
  // ===== Cleanup =====
  
  @override
  void dispose() {
    // Remove listeners
    _stateProvider.removeListener(_onStateProviderChanged);
    _dataProvider.removeListener(_onDataProviderChanged);
    _uiProvider.removeListener(_onUIProviderChanged);
    
    super.dispose();
  }
  
  // ===== AppState Bridge Methods =====
  
  /// Sync with AppState if needed
  /// This method can be called from AppState to trigger voting-related updates
  void syncWithAppState(Map<String, dynamic> appStateData) {
    // Extract any voting-related data from AppState
    // This maintains separation while allowing coordination
    
    if (appStateData.containsKey('currentPostId')) {
      final postId = appStateData['currentPostId'] as String;
      // Preload vote data for current post
      _dataProvider.getVoteCounts(postId);
    }
    
    if (appStateData.containsKey('userId')) {
      final userId = appStateData['userId'] as String;
      // Check user's vote status
      _stateProvider.checkUserVote(postId: '', userId: userId);
    }
  }
  
  /// Export voting state for AppState
  /// Returns a map of voting-related state that AppState might need
  Map<String, dynamic> exportState() {
    return {
      'isVoting': isVoting,
      'isDialogVisible': isDialogVisible,
      'hasActiveVotes': _stateProvider.hasVoted,
      'cachedVotesCount': _dataProvider.cachedItemsCount,
      'lastSyncTime': _dataProvider.lastSyncTime?.toIso8601String(),
    };
  }
}