// ============================================
// APP UTILS - Barrel File (Re-exports)
// ============================================
//
// Refactored: 2025-11-11
// Before: 495 lines (monolithic Kitchen Sink file)
// After: Barrel file + 6 purpose-specific subdirectories (12 files)
//
// Purpose: Backward compatibility - re-exports all utilities
// Pattern: Barrel File (zero breaking changes)
//
// Structure:
// 1. datetime/     (1 file,  ~100 lines) - Date/time operations
// 2. platform/     (1 file,  ~110 lines) - Platform detection
// 3. collections/  (1 file,  ~270 lines) - List/Map/Iterable extensions
// 4. ui/           (1 file,  ~280 lines) - UI/UX utilities
// 5. logging/      (3 files, ~830 lines) - Logging utilities
// 6. helpers/      (5 files, ~420 lines) - Helper functions
//
// Note: Services (batch, idempotency, sharding) moved to /lib/services/ (2025-11-11)
//
// Industry Pattern: Pattern 2 (Subdirectory Structure)
// ============================================

import 'package:flutter/material.dart';

// ============================================
// RE-EXPORT UTILITIES (6 subdirectories)
// ============================================

// 1. DateTime utilities
/// DateTime formatting, manipulation, and extensions
export 'datetime/datetime_utils.dart';

// 2. Platform utilities
/// Platform detection and platform-specific operations
export 'platform/platform_utils.dart';

// 3. Collection extensions
/// List, Map, Iterable, String, and other collection extensions
export 'collections/collection_extensions.dart';

// 4. UI utilities
/// UI utilities: responsive, formatting, validation, app settings
export 'ui/ui_utils.dart';

// 5. Logging (MOVED 2025-11-12: core/utils/logging → services/logging)
/// Core logger for cross-feature logging (exports LogLevel enum)
export '/services/logging/logger_service.dart';

/// Debug logging with levels (dev/staging/prod)
export '/services/logging/debug_service.dart';

/// Migration tracking logger
export '/services/logging/migration_tracking_service.dart';

// 6. Helpers
/// Simple helper functions (datetime13day)
export 'helpers/custom_functions.dart';

/// Input debouncing utility
export 'helpers/debounce.dart';

/// Centralized error handling (MOVED 2025-11-12: core/utils/helpers → services/error)
export '/services/error/error_handler_service.dart';

/// File size utilities (formatBytes, etc.)
/// MOVED 2025-11-11: helpers/file_size_utils.dart → /services/storage/file_size_utils.dart
/// Now exported from /lib/core_exports.dart

/// Form state management controller
export 'helpers/form_field_controller.dart';

// ============================================
// RE-EXPORT TYPES
// ============================================

export '/core/types/lat_lng.dart';
export '/core/types/uploaded_file.dart'; // MOVED 2025-11-10: core/models → core/types
// export '/core/models/app_model.dart'; // DELETED 2025-11-10: Phase 10 완료

// ============================================
// RE-EXPORT DART/FLUTTER
// ============================================

export 'dart:math' show min, max;
export 'dart:typed_data' show Uint8List;
export 'dart:convert' show jsonEncode, jsonDecode;
export 'package:intl/intl.dart';
export 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseFirestore;
export 'package:page_transition/page_transition.dart';

// ============================================
// RE-EXPORT APP
// ============================================

export '/core/localization/app_localizations.dart';
export '/app/router/navigation/nav.dart';

// ============================================
// ROUTE OBSERVER (Global Instance)
// ============================================

/// Global route observer for navigation tracking
///
/// **Usage**: Attach to MaterialApp.navigatorObservers
///
/// **Example**:
/// ```dart
/// MaterialApp(
///   navigatorObservers: [routeObserver],
///   // ...
/// )
/// ```
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();
