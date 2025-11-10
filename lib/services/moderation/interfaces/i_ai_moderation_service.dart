import 'package:flutter/material.dart';
import '../models/moderation_result.dart';

/// Port interface for AI Moderation Service
///
/// Provides unified AI-based content moderation:
/// - Perspective API (text toxicity)
/// - Vision API (image safety)
/// - Gemini AI (content logic and context)
///
/// **Port-Adapter Pattern**:
/// - This is the Port (interface/contract)
/// - AIModerationService is the Adapter (implementation)
///
/// **Benefits**:
/// - Dependency Inversion: Domain depends on interface, not implementation
/// - Testability: Easy to create mock implementations
/// - Flexibility: Can swap implementations at runtime
abstract class IAIModerationService {
  /// Moderate post content with AI services
  ///
  /// Performs 3-stage moderation:
  /// 1. Perspective API - Text toxicity detection
  /// 2. Gemini AI - Content logic and context validation
  /// 3. Result integration and decision
  ///
  /// **Parameters**:
  /// - [request]: Content to moderate (text, images, metadata)
  /// - [onProgressUpdate]: Progress callback for UI updates
  ///
  /// **Returns**: Unified moderation result with violations and severity
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<IAIModerationService>();
  /// final result = await service.moderatePostContent(
  ///   request: ModerationRequest(
  ///     userId: userId,
  ///     questionTitle: '어떤 영화가 더 재미있나요?',
  ///     titleA: '어벤져스',
  ///     titleB: '인터스텔라',
  ///   ),
  ///   onProgressUpdate: (message) => print(message),
  /// );
  ///
  /// if (result.isValid) {
  ///   // Content approved
  /// } else {
  ///   // Content rejected - show violations
  /// }
  /// ```
  Future<AIModerationResult> moderatePostContent({
    required ModerationRequest request,
    Function(String)? onProgressUpdate,
  });

  /// Show moderation result dialog to user
  ///
  /// Displays user-friendly dialog based on moderation result severity:
  /// - **pass**: No dialog (content approved)
  /// - **warning**: Yellow dialog with suggestions
  /// - **error**: Red dialog with violations and block
  ///
  /// **Parameters**:
  /// - [context]: BuildContext for dialog
  /// - [result]: Moderation result to display
  ///
  /// **Example**:
  /// ```dart
  /// final service = getIt<IAIModerationService>();
  /// await service.showModerationDialog(context, result);
  /// ```
  Future<void> showModerationDialog(
    BuildContext context,
    AIModerationResult result,
  );
}
