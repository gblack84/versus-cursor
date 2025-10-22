// Notifications Feature - Model Exports
// This file exports all data models related to notifications functionality
//
// Note: VoteNotification and VoteNotificationDto have been moved to Voting Feature
// as part of Clean Architecture separation

// DTO Models
export 'notification_dto.dart';
export 'system_notification_dto.dart';
export 'social_notification_dto.dart';
export 'dto_extensions.dart';

// Domain Models (Freezed sealed union)
export '../../domain/models/notification.dart';
export '../../domain/models/notification_extensions.dart';
