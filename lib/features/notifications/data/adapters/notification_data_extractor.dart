import '../../domain/models/notification.dart' as domain;
import '../../domain/models/vote_notification.dart' as domain;
import '../../domain/models/notification_display_data.dart';

/// Service for extracting display data from notifications
///
/// This service handles the extraction of vote data from notifications
/// and converts it into a format suitable for UI display.
class NotificationDataExtractor {
  /// Extract vote data from a notification
  static Future<NotificationDisplayData?> extractVoteData(
    domain.Notification notification,
  ) async {
    try {
      // Extract data based on notification type
      final Map<String, dynamic> voteData = {};

      if (notification is domain.VoteNotification) {
        // Extract from VoteNotification
        voteData['question'] = notification.postTitle;
        voteData['optionA'] = notification.voteOptions.optionATitle;
        voteData['optionB'] = notification.voteOptions.optionBTitle;
        voteData['imageUrlA'] =
            notification.voteOptions.optionAImageUrls.isNotEmpty
                ? notification.voteOptions.optionAImageUrls.first
                : null;
        voteData['imageUrlB'] =
            notification.voteOptions.optionBImageUrls.isNotEmpty
                ? notification.voteOptions.optionBImageUrls.first
                : null;
        voteData['imageUrlsA'] = notification.voteOptions.optionAImageUrls;
        voteData['imageUrlsB'] = notification.voteOptions.optionBImageUrls;
        voteData['description'] = notification.postDescription;
        voteData['authorName'] = notification.senderName;
        voteData['aspectRatioA'] = notification.voteOptions.optionAAspectRatio;
        voteData['aspectRatioB'] = notification.voteOptions.optionBAspectRatio;
        voteData['layoutType'] = notification.voteOptions.layoutType;
        voteData['postId'] = notification.postId;
      } else {
        // Extract from generic notification metadata map
        final data = notification.metadata;
        if (data.isEmpty) {
          return null;
        }

        voteData['question'] = data['question'] ?? '';
        voteData['optionA'] = data['optionA'] ?? '';
        voteData['optionB'] = data['optionB'] ?? '';
        voteData['imageUrlA'] = data['imageUrlA'];
        voteData['imageUrlB'] = data['imageUrlB'];
        voteData['imageUrlsA'] = data['imageUrlsA'];
        voteData['imageUrlsB'] = data['imageUrlsB'];
        voteData['description'] = data['description'];
        voteData['authorName'] = data['authorName'];
        voteData['aspectRatioA'] = data['aspectRatioA'];
        voteData['aspectRatioB'] = data['aspectRatioB'];
        voteData['layoutType'] = data['layoutType'];
        voteData['postId'] = data['postId'];
      }

      // Validate required fields
      if (voteData['question'] == null || voteData['question'].isEmpty) {
        return null;
      }

      return NotificationDisplayData.fromVoteData(voteData);
    } catch (e) {
      // Log error but don't throw - return null to indicate extraction failure
      print('Error extracting vote data: $e');
      return null;
    }
  }
}
