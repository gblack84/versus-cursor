// Chat Feature - Model Exports (Clean Architecture v4.0)
// This file exports all data models related to chat functionality

// Domain Entities (Pure Dart)
export '../../domain/entities/chat.dart';
export '../../domain/entities/message.dart';

// Domain Enums
export '../../domain/enums/message_delivery_status.dart';

// Data Transfer Objects (DTOs)
export '../dto/chat_dto.dart';
export '../dto/message_dto.dart';

// Note: Legacy Models (chats_model, messages_model, group_chats_model, etc.)
// have been removed as part of Clean Architecture v4.0 migration.
// 1:1 Chat now uses pure Domain Entities and DTOs.
// Group chat features will be migrated in a future phase.
