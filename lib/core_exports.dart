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

// ===== FROM COMMON FEATURE =====

// Theme & Styling (common/presentation/theme)
export 'features/common/presentation/theme/app_theme.dart';

// Animations (common/presentation/animations)
export 'features/common/presentation/animations/app_animations.dart';

// Widgets (common/presentation/widgets)
export 'features/common/presentation/widgets/app_widgets.dart';
export 'features/common/presentation/widgets/app_choice_chips.dart';
export 'features/common/presentation/widgets/app_icon_button.dart';
export 'features/common/presentation/widgets/app_media_display.dart';
export 'features/common/presentation/widgets/app_toggle_icon.dart';
export 'features/common/presentation/widgets/app_video_player.dart';
export 'features/common/presentation/widgets/app_web_view.dart';

// Localization (common/localization)
export 'features/common/localization/app_language_selector.dart';
export 'features/common/localization/app_localizations.dart';

// Utilities (common/utils)
export 'features/common/utils/app_utils.dart';
export 'features/common/utils/app_timer.dart';
export 'features/common/utils/custom_functions.dart';

// Domain Models (common/domain/models)
export 'features/common/domain/models/app_model.dart';
export 'features/common/domain/models/uploaded_file.dart';
export 'features/common/domain/models/upload_data.dart';
export 'features/common/domain/models/form_field_controller.dart';

// ===== FROM APP FEATURE =====

// Navigation (app/router/navigation)
export 'app/router/navigation/nav.dart';
export 'app/router/navigation/serialization_util.dart';

// App Models (app/models)
export 'app/models/lat_lng.dart';
export 'app/models/place.dart';