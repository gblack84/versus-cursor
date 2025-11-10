// ============================================
// Temporary bridge file for gradual Core migration
// Created: 2025-08-26
// Updated: 2025-08-26 - Files distributed to Common and App
// TODO: Remove after all migrations complete
// ============================================
//
// This file temporarily re-exports all core files to allow
// gradual migration without breaking existing imports.
// Files have been copied to their new locations in Common and App features.
//
// Migration Status:
// - Total Core files: 22
// - Migrated to Common: 18
// - Migrated to App: 4
// - Remaining in Core: 0 (ready for removal)
// ============================================

// ===== FROM CORE =====

// Repository Interfaces (Updated: 2025-01-09 - Moved to Features)
export 'features/creation/domain/repositories/i_post_creation_repository_v2.dart';
export 'features/post/domain/repositories/i_post_display_repository_v2.dart';
export 'features/creation/domain/repositories/i_media_repository.dart';
export 'features/profile/domain/repositories/i_user_repository.dart';
export 'features/chat/domain/repositories/i_chat_repository.dart';
export 'features/notifications/domain/repositories/i_notification_repository.dart';
export 'features/search/domain/repositories/i_search_repository.dart';

// Theme & Styling
export 'core/theme/app_theme.dart';

// Widgets
export 'core/widgets/app_widgets.dart';
export 'core/widgets/app_choice_chips.dart';
export 'core/widgets/app_icon_button.dart';
export 'core/widgets/app_media_display.dart';
export 'core/widgets/app_toggle_icon.dart';
export 'core/widgets/app_video_player.dart';
export 'core/widgets/app_web_view.dart';

// Localization
export 'core/localization/app_localizations.dart';

// Utilities
export 'core/utils/app_utils.dart';
export 'core/utils/app_timer.dart';
export 'core/utils/batch_service.dart';
export 'core/utils/custom_functions.dart';

// Firebase utilities (Core - Generic)
export 'core/firebase/utils/firestore_util.dart';

// Firebase utilities (Services - Legacy Pattern)
// TODO: Remove after Extension Pattern migration complete
export 'services/firebase/legacy_firestore_record.dart';

// Search Feature utilities (Algolia-specific)
// Moved from Core to fix architecture violation (Core → Feature dependency)
export 'features/search/data/utils/algolia_converters.dart';

// Models
export 'core/models/app_model.dart';
export 'core/models/uploaded_file.dart';
export 'core/models/upload_data.dart';
export 'core/models/form_field_controller.dart';

// ===== FROM APP FEATURE =====

// Navigation (app/router/navigation)
export 'app/router/navigation/nav.dart';
export 'app/router/navigation/serialization_util.dart' hide appFromCssColor;

// App Types (app/types)
export 'app/types/lat_lng.dart';
