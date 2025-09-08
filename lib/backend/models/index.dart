// =============================================================================
// DEPRECATED: This file is deprecated and will be removed in v2.0.0
// 이 파일은 deprecated되었으며 v2.0.0에서 제거될 예정입니다
// =============================================================================
//
// Migration Guide / 마이그레이션 가이드:
// ----------------------------------------------------------------------------
// All models have been moved to Feature-First Architecture
// 모든 모델이 Feature-First Architecture로 이동되었습니다
//
// Old imports → New imports:
// 
// UserProfile, AuthUser, ProfileInfo, UserSettings, UserStats:
//   import '/backend/models/index.dart';
//   → import '/features/profile/domain/models/user_models.dart';
//
// PostsModel, PostCore, PostContent, PostVoting, PostMetrics:
//   import '/backend/models/index.dart';  
//   → import '/features/posts/domain/models/post_models.dart';
//
// MessagesModel:
//   import '/backend/models/index.dart';
//   → import '/features/chat/domain/models/message_model.dart';
//
// NotificationModel:
//   import '/backend/models/index.dart';
//   → import '/features/notifications/domain/models/notification_model.dart';
//
// ----------------------------------------------------------------------------
// @Deprecated('Use feature-specific imports instead. Will be removed in v2.0.0')
// Migration deadline: 2025-06-30
// ----------------------------------------------------------------------------

// Export basic types for backward compatibility
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:flutter/material.dart' show Color, Colors;
export '/app/models/lat_lng.dart';

// ⚠️ WARNING: These exports are deprecated and will be removed
// ⚠️ 경고: 이 exports는 deprecated되었으며 제거될 예정입니다

// Posts models - Use '/features/posts/domain/models/post_models.dart' instead
export '/features/posts/data/models/posts_model.dart';

// User models - Use '/features/profile/domain/models/user_models.dart' instead  
// Note: Add exports here if needed for backward compatibility

// Chat models - Use '/features/chat/domain/models/message_model.dart' instead
// Note: Add exports here if needed for backward compatibility

// Notification models - Use '/features/notifications/domain/models/notification_model.dart' instead
// Note: Add exports here if needed for backward compatibility