import 'package:flutter/material.dart';
import '../../../creation/domain/models/aggregates/post_creation.dart';
import '../../../creation/domain/repositories/i_post_creation_repository_v2.dart';
import '../../../creation/domain/repositories/specialized/i_metrics_repository.dart'
    show IContentMetricsRepository, ContentMetrics, MetricsUpdate, InteractionType;
import '../../../creation/domain/repositories/specialized/i_moderation_repository.dart'
    show IContentModerationRepository, ModerationResult, ReportReason;
import '../../../creation/domain/repositories/specialized/i_visibility_repository.dart'
    show IContentVisibilityRepository, VisibilityLevel, TargetAudience;
import '../../domain/repositories/i_post_query_service.dart';

/// Aggregate Provider for Post Feature
///
/// This provider manages post-related operations across the entire lifecycle.
/// It coordinates multiple repositories for CRUD operations, metrics,
/// moderation, and visibility. This will be refactored to use UseCases
/// during the Post Feature migration to Clean Architecture.
///
/// Note: Previously CreationAggregateProvider, moved from Creation to Post feature
/// as it handles post lifecycle management rather than just creation.
class PostAggregateProvider extends ChangeNotifier {
  final IPostCreationRepositoryV2 _creationRepository;
  final IContentMetricsRepository _metricsRepository;
  final IContentModerationRepository _moderationRepository;
  final IContentVisibilityRepository _visibilityRepository;
  final IPostQueryService _queryService;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<PostCreation> _posts = [];
  PostCreation? _currentPost;
  Map<String, ContentMetrics> _metricsCache = {};

  PostAggregateProvider({
    required IPostCreationRepositoryV2 creationRepository,
    required IContentMetricsRepository metricsRepository,
    required IContentModerationRepository moderationRepository,
    required IContentVisibilityRepository visibilityRepository,
    required IPostQueryService queryService,
  })  : _creationRepository = creationRepository,
        _metricsRepository = metricsRepository,
        _moderationRepository = moderationRepository,
        _visibilityRepository = visibilityRepository,
        _queryService = queryService;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PostCreation> get posts => _posts;
  PostCreation? get currentPost => _currentPost;

  // ============= Command Operations =============

  /// Create new content post
  Future<String?> createContent(PostCreation post) async {
    _setLoading(true);
    try {
      // First, moderate the content
      final moderationResult = await _moderationRepository.moderateContent(
        post.id ?? 'temp',
      );

      if (!moderationResult.isApproved) {
        _setError('Content was rejected: ${moderationResult.blockReason}');
        return null;
      }

      // Create the post
      final postId = await _creationRepository.createContent(post);

      // Set initial visibility
      await _visibilityRepository.setVisibility(
        postId,
        VisibilityLevel.public,
      );

      // Initialize metrics
      await _metricsRepository.incrementViewCount(postId);

      _clearError();
      notifyListeners();
      return postId;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing content
  Future<bool> updateContent(String contentId, PostCreation post) async {
    _setLoading(true);
    try {
      await _creationRepository.updateContent(contentId, post);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete content
  Future<bool> deleteContent(String contentId) async {
    _setLoading(true);
    try {
      await _creationRepository.deleteContent(contentId);
      _posts.removeWhere((p) => p.id == contentId);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============= Voting Operations =============

  // ============= Query Operations =============

  /// Load posts for feed
  Future<void> loadPosts({int limit = 20}) async {
    _setLoading(true);
    try {
      _posts = await _queryService.getTrendingContent(limit: limit);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Search content
  Future<List<PostCreation>> searchContent(String query) async {
    try {
      final results = await _queryService.fullTextSearch(query);
      return results;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  /// Get content by ID
  Future<PostCreation?> getContentById(String contentId) async {
    try {
      _currentPost = await _queryService.getContentById(contentId);

      if (_currentPost != null) {
        // Increment view count
        await _metricsRepository.incrementViewCount(contentId);

        // Cache metrics
        final metrics = await _metricsRepository.getEngagementMetrics(contentId);
        _metricsCache[contentId] = metrics;
      }

      notifyListeners();
      return _currentPost;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Get content stream
  Stream<PostCreation?> getContentStream(String contentId) {
    return _queryService.getContentStream(contentId);
  }

  // ============= Metrics Operations =============

  /// Get engagement metrics
  Future<ContentMetrics?> getEngagementMetrics(String contentId) async {
    if (_metricsCache.containsKey(contentId)) {
      return _metricsCache[contentId];
    }

    try {
      final metrics = await _metricsRepository.getEngagementMetrics(contentId);
      _metricsCache[contentId] = metrics;
      return metrics;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Watch metrics updates
  Stream<MetricsUpdate> watchMetrics(String contentId) {
    return _metricsRepository.watchMetrics(contentId);
  }

  // ============= Moderation Operations =============

  /// Report content
  Future<bool> reportContent(String contentId, String userId, ReportReason reason) async {
    try {
      await _moderationRepository.reportContent(contentId, userId, reason);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Check if content is safe
  Future<bool> isContentSafe(String contentId) async {
    try {
      return await _moderationRepository.isContentSafe(contentId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============= Visibility Operations =============

  /// Set content visibility
  Future<bool> setVisibility(String contentId, VisibilityLevel level) async {
    try {
      await _visibilityRepository.setVisibility(contentId, level);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update target audience
  Future<bool> updateTargetAudience(String contentId, TargetAudience audience) async {
    try {
      await _visibilityRepository.updateTargetAudience(contentId, audience);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Check if user can view content
  Future<bool> canUserView(String contentId, String userId) async {
    try {
      return await _visibilityRepository.canUserView(contentId, userId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============= Helper Methods =============

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Clear all cached data
  void clearCache() {
    _metricsCache.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}