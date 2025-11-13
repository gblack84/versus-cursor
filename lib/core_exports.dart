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
export 'services/media/app_video_player.dart'; // MOVED 2025-11-12: core/widgets → services/media (external SDK)
export 'core/widgets/app_web_view.dart';

// Localization
export 'core/localization/app_localizations.dart';

// Utilities
export 'core/utils/app_utils.dart';
// export 'core/utils/app_timer.dart'; // DELETED 2025-11-11: AppTimer 제거 (stop_watch_timer 직접 사용)
export 'services/batch/batch_service.dart'; // MOVED 2025-11-11: core/utils/services → services/batch
export 'core/utils/helpers/custom_functions.dart';

// Firebase utilities (Services - External SDK)
export 'services/firebase/firestore_utils.dart'; // MOVED 2025-11-12: core/firebase → services/firebase

// Search Feature utilities (Algolia-specific)
// Moved from Core to fix architecture violation (Core → Feature dependency)
export 'features/search/data/utils/algolia_converters.dart';

// Models (DEPRECATED: Moved to core/types/)
// export 'core/models/app_model.dart'; // DELETED 2025-11-10: Phase 10 완료
export 'core/types/uploaded_file.dart'; // MOVED 2025-11-10: core/models → core/types
// export 'core/models/upload_data.dart'; // DELETED 2025-11-10: Moved to Profile Feature

// Form Controllers (Utilities)
export 'core/utils/helpers/form_field_controller.dart'; // MOVED 2025-11-10: core/models → core/utils → core/utils/helpers

// File Size Utils (Service - MOVED 2025-11-11: core/utils/helpers → services/storage)
export 'services/storage/file_size_utils.dart';

// ===== FROM APP FEATURE =====

// Navigation (app/router/navigation)
export 'app/router/navigation/nav.dart';
export 'app/router/navigation/serialization_util.dart' hide appFromCssColor;

// Core Types (core/types) - Domain Primitives
export 'core/types/lat_lng.dart';
