import 'package:flutter/material.dart';

/// Service interface for responsive breakpoints (Chat Feature)
///
/// This interface abstracts the dependency on the UI services layer,
/// allowing the chat domain to calculate responsive sizes without
/// directly depending on the services implementation.
///
/// Clean Architecture Pattern:
/// - Domain Layer: This interface (abstraction)
/// - Data Layer: ResponsiveBreakpointsAdapter (implementation)
/// - Presentation Layer: Uses interface via DI (GetIt)
abstract class IResponsiveService {
  /// Get maximum message width based on device size
  ///
  /// **Parameters**:
  /// - `context`: BuildContext for MediaQuery
  ///
  /// **Returns**: Maximum width for message bubble
  ///
  /// **Used by**:
  /// - Chat message rendering
  /// - Message card sizing
  double getMaxMessageWidth(BuildContext context);

  /// Get message margin based on device size
  ///
  /// **Parameters**:
  /// - `context`: BuildContext for MediaQuery
  /// - `isMe`: Whether message is sent by current user
  ///
  /// **Returns**: EdgeInsets for message margin
  EdgeInsetsGeometry getMessageMargin(BuildContext context, bool isMe);
}
