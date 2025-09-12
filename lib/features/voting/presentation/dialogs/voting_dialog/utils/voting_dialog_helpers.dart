import 'package:flutter/foundation.dart';

/// Helper utilities for the voting dialog
class VotingDialogHelpers {
  
  /// Extract effective image URLs for option A
  static List<String> getEffectiveImageUrlsA({
    List<String>? imageUrlsA,
    String? imageUrlA,
  }) {
    if (imageUrlsA != null && imageUrlsA.isNotEmpty) {
      return imageUrlsA;
    }
    if (imageUrlA != null) {
      return [imageUrlA];
    }
    return [];
  }

  /// Extract effective image URLs for option B
  static List<String> getEffectiveImageUrlsB({
    List<String>? imageUrlsB,
    String? imageUrlB,
  }) {
    if (imageUrlsB != null && imageUrlsB.isNotEmpty) {
      return imageUrlsB;
    }
    if (imageUrlB != null) {
      return [imageUrlB];
    }
    return [];
  }

  /// Get primary image URL from list
  static String? getPrimaryImageUrl(List<String> urls) {
    return urls.isNotEmpty ? urls.first : null;
  }

  /// Check if option B exists
  static bool hasBOption({
    String? imageUrlB,
    required String optionB,
  }) {
    return imageUrlB != null || optionB.isNotEmpty;
  }

  /// Check if option B has only text (no image)
  static bool hasOnlyTextB({
    String? imageUrlB,
    required String optionB,
  }) {
    return imageUrlB == null && optionB.isNotEmpty;
  }

  /// Format vote count for display
  static String formatVoteCount(int? count) {
    if (count == null) return '0';
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  /// Format vote percentage for display
  static String formatVotePercentage(double? percentage) {
    if (percentage == null) return '0%';
    return '${(percentage * 100).toStringAsFixed(0)}%';
  }

  /// Calculate vote percentages from counts
  static (double?, double?) calculatePercentages({
    int? voteCountA,
    int? voteCountB,
  }) {
    if (voteCountA == null || voteCountB == null) {
      return (null, null);
    }
    
    final total = voteCountA + voteCountB;
    if (total == 0) {
      return (0.5, 0.5); // Default to 50/50 if no votes
    }
    
    final percentageA = voteCountA / total;
    final percentageB = voteCountB / total;
    
    return (percentageA, percentageB);
  }

  /// Debug log for voting dialog
  static void debugLog(String message, {bool showDebugInfo = false}) {
    if (showDebugInfo && kDebugMode) {
      debugPrint('[VotingDialog] $message');
    }
  }
}