// ============================================================================
// Profile Feature Export Hub
// Centralizes all profile-related model and repository exports
// ============================================================================

// Domain Models
export '../../domain/models/user_profile.dart';
export '../../domain/models/friends_list_model.dart';
export '../../domain/models/characters_model.dart';
export '../../domain/models/interest_model.dart';
export '../../domain/models/jops_category_model.dart';
export '../../domain/models/jops_name_model.dart';
export '../../domain/models/chat_interest_jops_model.dart';

// Backend Models (to be migrated)
export '/backend/models/user/users_model.dart';
export '/backend/models/user/settings_model.dart';

// Data Services
export '../services/user_cache_service.dart';

// Repository
export '../repositories/profile_repository_impl.dart';