// ============================================================================
// Chat Feature Export Hub
// Centralizes all chat-related model and repository exports
// ============================================================================

// Domain Models
export '../../domain/models/chats_model.dart';
export '../../domain/models/group_chats_model.dart';
export '../../domain/models/group_messages_model.dart';
export '../../domain/models/chat_history_model.dart';
export '../../domain/models/message.dart';

// Backend Models (to be migrated)
export '/backend/models/chat/messages_model.dart';

// Data Services
export '../services/chat_initialization_service.dart';
export '../services/chat_message_lifecycle_service.dart';

// Repository
export '../repositories/chat_repository_impl.dart';