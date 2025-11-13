import 'package:flutter/material.dart';
import '/core/utils/ui/box_sizing/responsive_breakpoints.dart';
import '../../domain/services/i_responsive_service.dart';

/// Implementation of IResponsiveService that wraps ResponsiveBreakpoints
///
/// This adapter bridges the domain layer with the services layer,
/// providing responsive sizing functionality while maintaining
/// Clean Architecture boundaries.
///
/// **Pattern**: Adapter Pattern
/// - **Domain**: IResponsiveService (abstract interface)
/// - **Data**: ResponsiveBreakpointsAdapter (concrete implementation)
/// - **Services**: ResponsiveBreakpoints (global infrastructure)
///
/// **Responsibility**:
/// - Wraps ResponsiveBreakpoints.getMaxMessageWidth()
/// - Wraps ResponsiveBreakpoints.getMessageMargin()
/// - Provides Clean Architecture abstraction for Chat Feature
///
/// **Used by**:
/// - Chat Presentation Layer (via GetIt DI)
/// - Message rendering components
class ResponsiveBreakpointsAdapter implements IResponsiveService {
  @override
  double getMaxMessageWidth(BuildContext context) {
    return ResponsiveBreakpoints.getMaxMessageWidth(context);
  }

  @override
  EdgeInsetsGeometry getMessageMargin(BuildContext context, bool isMe) {
    return ResponsiveBreakpoints.getMessageMargin(context, isMe);
  }
}
