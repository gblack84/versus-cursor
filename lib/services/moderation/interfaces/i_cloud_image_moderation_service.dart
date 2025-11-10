import '../models/image_moderation_model.dart';

/// Port interface for Cloud Image Moderation Service
///
/// Provides Firestore-based image moderation status management:
/// - Check moderation status
/// - Wait for moderation completion
/// - Watch real-time moderation updates
/// - Validate image safety
///
/// **Port-Adapter Pattern**:
/// - This is the Port (interface/contract)
/// - CloudImageModerationService is the Adapter (implementation)
///
/// **Benefits**:
/// - Dependency Inversion: Domain depends on interface, not implementation
/// - Testability: Easy to create mock implementations
/// - Flexibility: Can swap implementations at runtime
abstract class ICloudImageModerationService {
  /// Check image moderation status from Firestore
  ///
  /// Queries Firestore `imageModeration` collection for moderation results.
  ///
  /// **Parameters**:
  /// - [filePath]: Storage file path (e.g., "users/123/posts/image.jpg")
  ///
  /// **Returns**: Moderation model if exists, null otherwise
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<ICloudImageModerationService>();
  /// final status = await service.checkModerationStatus('users/123/posts/image.jpg');
  ///
  /// if (status != null) {
  ///   print('Status: ${status.moderationStatus}');
  /// }
  /// ```
  Future<ImageModerationModel?> checkModerationStatus(String filePath);

  /// Wait for moderation completion with polling
  ///
  /// Polls Firestore every [pollInterval] until moderation completes
  /// or [timeout] is reached.
  ///
  /// **Parameters**:
  /// - [filePath]: Storage file path
  /// - [timeout]: Maximum wait time (default: 30 seconds)
  /// - [pollInterval]: Polling interval (default: 1 second)
  ///
  /// **Returns**: Completed moderation result, or null if timeout
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<ICloudImageModerationService>();
  /// final result = await service.waitForModeration(
  ///   'users/123/posts/image.jpg',
  ///   timeout: Duration(seconds: 30),
  /// );
  ///
  /// if (result != null && result.moderationStatus == 'approved') {
  ///   print('Image approved!');
  /// }
  /// ```
  Future<ImageModerationModel?> waitForModeration(
    String filePath, {
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(seconds: 1),
  });

  /// Watch moderation status in real-time
  ///
  /// Returns a Stream that emits moderation status updates from Firestore.
  ///
  /// **Parameters**:
  /// - [filePath]: Storage file path
  ///
  /// **Returns**: Stream of moderation status updates
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<ICloudImageModerationService>();
  /// service.watchModerationStatus('users/123/posts/image.jpg').listen((status) {
  ///   if (status != null) {
  ///     print('Status changed: ${status.moderationStatus}');
  ///   }
  /// });
  /// ```
  Stream<ImageModerationModel?> watchModerationStatus(String filePath);

  /// Check if image is safe (approved)
  ///
  /// **Parameters**:
  /// - [moderation]: Moderation model to check
  ///
  /// **Returns**: true if approved, false otherwise
  ///   - Returns true if moderation is null (no result = assume safe)
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<ICloudImageModerationService>();
  /// final status = await service.checkModerationStatus('path/to/image.jpg');
  ///
  /// if (service.isImageSafe(status)) {
  ///   print('Image is safe to display');
  /// }
  /// ```
  bool isImageSafe(ImageModerationModel? moderation);

  /// Check if image is rejected
  ///
  /// **Parameters**:
  /// - [moderation]: Moderation model to check
  ///
  /// **Returns**: true if rejected, false otherwise
  ///   - Returns false if moderation is null
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<ICloudImageModerationService>();
  /// final status = await service.checkModerationStatus('path/to/image.jpg');
  ///
  /// if (service.isImageRejected(status)) {
  ///   print('Image rejected: Community guidelines violation');
  /// }
  /// ```
  bool isImageRejected(ImageModerationModel? moderation);
}
