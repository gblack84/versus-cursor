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

// Theme & Styling
export 'core/theme/app_theme.dart';

// Animations
export 'core/animations/app_animations.dart';

// Widgets
export 'core/widgets/app_widgets.dart';
export 'core/widgets/app_choice_chips.dart';
export 'core/widgets/app_icon_button.dart';
export 'core/widgets/app_media_display.dart';
export 'core/widgets/app_toggle_icon.dart';
export 'core/widgets/app_video_player.dart';
export 'core/widgets/app_web_view.dart';

// Localization
export 'core/localization/app_language_selector.dart';
export 'core/localization/app_localizations.dart';

// Utilities
export 'core/utils/app_utils.dart';
export 'core/utils/app_timer.dart';
export 'core/utils/custom_functions.dart';

// Models
export 'core/models/app_model.dart';
export 'core/models/uploaded_file.dart';
export 'core/models/upload_data.dart';
export 'core/models/form_field_controller.dart';

// ===== FROM APP FEATURE =====

// Navigation (app/router/navigation)
export 'app/router/navigation/nav.dart';
export 'app/router/navigation/serialization_util.dart';

// App Models (app/models)
export 'app/models/lat_lng.dart';
export 'app/models/place.dart';