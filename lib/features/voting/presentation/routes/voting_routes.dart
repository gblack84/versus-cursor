/// Voting Feature Routes Configuration
///
/// This file defines all routes for the Voting feature following
/// Clean Architecture principles. Routes are self-contained and
/// can be imported by the app's main router.
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

// Import Voting Feature screens and dialogs
import '../overlays/in_app_notification_dialog.dart';
import '../dialogs/voting_dialog_refactored.dart';

/// Voting Feature route paths
class VotingRoutePaths {
  static const String votingNotification = '/voting/notification';
  static const String votingResults = '/voting/results';
  static const String votingRankings = '/voting/rankings';
  static const String votingHistory = '/voting/history';
  static const String votingCreate = '/voting/create';
}

/// Voting Feature route names
class VotingRouteNames {
  static const String votingNotification = 'VotingNotification';
  static const String votingResults = 'VotingResults';
  static const String votingRankings = 'VotingRankings';
  static const String votingHistory = 'VotingHistory';
  static const String votingCreate = 'VotingCreate';
}

/// Voting Feature routes configuration
class VotingRoutes {
  /// Returns all voting feature routes
  static List<RouteBase> get routes => [
    // Voting notification dialog route
    GoRoute(
      path: VotingRoutePaths.votingNotification,
      name: VotingRouteNames.votingNotification,
      pageBuilder: (context, state) {
        // Extract notification data from state.extra
        final notificationData = state.extra as Map<String, dynamic>?;
        
        return MaterialPage(
          fullscreenDialog: true,
          child: _buildNotificationDialog(notificationData),
        );
      },
    ),
    
    // Voting results screen route
    GoRoute(
      path: VotingRoutePaths.votingResults,
      name: VotingRouteNames.votingResults,
      pageBuilder: (context, state) {
        final postId = state.pathParameters['postId'] ?? '';
        
        return MaterialPage(
          child: _VotingResultsScreen(postId: postId),
        );
      },
    ),
    
    // Rankings screen route
    GoRoute(
      path: VotingRoutePaths.votingRankings,
      name: VotingRouteNames.votingRankings,
      pageBuilder: (context, state) {
        return const MaterialPage(
          child: _VotingRankingsScreen(),
        );
      },
    ),
    
    // Voting history screen route
    GoRoute(
      path: VotingRoutePaths.votingHistory,
      name: VotingRouteNames.votingHistory,
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId'] ?? '';
        
        return MaterialPage(
          child: _VotingHistoryScreen(userId: userId),
        );
      },
    ),
    
    // Vote creation screen route
    GoRoute(
      path: VotingRoutePaths.votingCreate,
      name: VotingRouteNames.votingCreate,
      pageBuilder: (context, state) {
        return const MaterialPage(
          child: _VoteCreationScreen(),
        );
      },
    ),
  ];

  /// Navigate to voting notification
  static void goToVotingNotification(BuildContext context, Map<String, dynamic> notificationData) {
    context.pushNamed(
      VotingRouteNames.votingNotification,
      extra: notificationData,
    );
  }

  /// Navigate to voting results
  static void goToVotingResults(BuildContext context, String postId) {
    context.pushNamed(
      VotingRouteNames.votingResults,
      pathParameters: {'postId': postId},
    );
  }

  /// Navigate to rankings
  static void goToRankings(BuildContext context) {
    context.pushNamed(VotingRouteNames.votingRankings);
  }

  /// Navigate to voting history
  static void goToVotingHistory(BuildContext context, String userId) {
    context.pushNamed(
      VotingRouteNames.votingHistory,
      pathParameters: {'userId': userId},
    );
  }

  /// Navigate to vote creation
  static void goToVoteCreation(BuildContext context) {
    context.pushNamed(VotingRouteNames.votingCreate);
  }
}

// ===== Helper functions to build screens =====

Widget _buildNotificationDialog(Map<String, dynamic>? notificationData) {
  if (notificationData == null) {
    return const Center(
      child: Text('Invalid notification data'),
    );
  }

  // Extract data from notification
  final title = notificationData['title'] as String? ?? '새로운 투표';
  final message = notificationData['message'] as String? ?? '투표에 참여해주세요';
  final postId = notificationData['postId'] as String? ?? '';

  // Use the existing InAppNotificationDialog or VotingNotificationDialog
  if (notificationData.containsKey('question')) {
    // Full voting notification with question and options
    return VotingNotificationDialog(
      question: notificationData['question'] as String? ?? '',
      optionA: notificationData['optionA'] as String? ?? '',
      optionB: notificationData['optionB'] as String? ?? '',
      imageUrlA: notificationData['imageUrlA'] as String?,
      imageUrlB: notificationData['imageUrlB'] as String?,
      onVote: (option) {
        // Handle vote action
        if (kDebugMode) {
          debugPrint('Voted for option: $option');
        }
      },
      onDismiss: (hasVoted) {
        // Handle dismiss action
        if (kDebugMode) {
          debugPrint('Dialog dismissed. Has voted: $hasVoted');
        }
      },
    );
  } else {
    // Simple notification dialog
    return InAppNotificationDialog(
      title: title,
      message: message,
      onTap: () {
        // Navigate to voting screen
        if (kDebugMode) {
          debugPrint('Navigate to post: $postId');
        }
      },
    );
  }
}

// ===== Placeholder screens (to be implemented) =====

class _VotingResultsScreen extends StatelessWidget {
  final String postId;

  const _VotingResultsScreen({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투표 결과'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.poll, size: 64),
            const SizedBox(height: 16),
            Text('투표 결과: $postId'),
            const SizedBox(height: 8),
            const Text('(구현 예정)'),
          ],
        ),
      ),
    );
  }
}

class _VotingRankingsScreen extends StatelessWidget {
  const _VotingRankingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('순위'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64),
            SizedBox(height: 16),
            Text('투표 순위'),
            SizedBox(height: 8),
            Text('(구현 예정)'),
          ],
        ),
      ),
    );
  }
}

class _VotingHistoryScreen extends StatelessWidget {
  final String userId;

  const _VotingHistoryScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투표 기록'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64),
            const SizedBox(height: 16),
            Text('사용자 투표 기록: $userId'),
            const SizedBox(height: 8),
            const Text('(구현 예정)'),
          ],
        ),
      ),
    );
  }
}

class _VoteCreationScreen extends StatelessWidget {
  const _VoteCreationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투표 만들기'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_box, size: 64),
            SizedBox(height: 16),
            Text('새 투표 만들기'),
            SizedBox(height: 8),
            Text('(구현 예정)'),
          ],
        ),
      ),
    );
  }
}