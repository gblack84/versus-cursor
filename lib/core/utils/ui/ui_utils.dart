// ============================================
// UI UTILITIES - Core Utils
// ============================================
//
// Split from: /lib/core/utils/app_utils.dart
// Migration date: 2025-11-11
// Reason: SRP (Single Responsibility Principle) - UI/UX operations only
//
// Purpose: Responsive layout, formatting, validation, app-level settings
// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/app/app.dart';

// ============================================
// BOX SIZING UTILITIES - EXPORTS
// ============================================

/// Box sizing service for A vs B image layouts
export 'box_sizing/unified_box_calculator.dart';
export 'box_sizing/aspect_ratio_analyzer.dart';
export 'box_sizing/responsive_breakpoints.dart';
export 'box_sizing/models/box_sizes.dart';
export 'box_sizing/config/box_calculator_config.dart';
export 'box_sizing/config/responsive_config.dart';

// ============================================
// RESPONSIVE LAYOUT
// ============================================

/// Breakpoint for small screens (phones)
const kBreakpointSmall = 479.0;

/// Breakpoint for medium screens (tablets portrait)
const kBreakpointMedium = 767.0;

/// Breakpoint for large screens (tablets landscape)
const kBreakpointLarge = 991.0;

/// Check if screen width is mobile size
///
/// **Returns**: true if width < 479.0
bool isMobileWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kBreakpointSmall;

/// Determine widget visibility based on screen size
///
/// **Example**:
/// ```dart
/// Visibility(
///   visible: responsiveVisibility(
///     context: context,
///     phone: true,
///     tablet: false,  // Hide on tablets
///   ),
///   child: MobileOnlyWidget(),
/// )
/// ```
bool responsiveVisibility({
  required BuildContext context,
  bool phone = true,
  bool tablet = true,
  bool tabletLandscape = true,
  bool desktop = true,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kBreakpointSmall) {
    return phone;
  } else if (width < kBreakpointMedium) {
    return tablet;
  } else if (width < kBreakpointLarge) {
    return tabletLandscape;
  } else {
    return desktop;
  }
}

// ============================================
// WIDGET UTILITIES
// ============================================

/// Get widget's bounding box in global coordinates
///
/// **Returns**: Rect with widget position and size, or null if error
///
/// **Example**:
/// ```dart
/// final box = getWidgetBoundingBox(context);
/// if (box != null) {
///   UtilsLogger.uiOperation(
///     operation: 'getWidgetBoundingBox',
///     details: 'Widget at: ${box.left}, ${box.top}',
///   );
/// }
/// ```
Rect? getWidgetBoundingBox(BuildContext context) {
  try {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox!.localToGlobal(Offset.zero) & renderBox.size;
  } catch (_) {
    return null;
  }
}

/// Show snackbar with optional loading indicator
///
/// **Example**:
/// ```dart
/// showSnackbar(context, 'Saving...', loading: true);
/// showSnackbar(context, 'Saved!', duration: 2);
/// ```
void showSnackbar(
  BuildContext context,
  String message, {
  bool loading = false,
  int duration = 4,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (loading)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 10.0),
              child: Container(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          Text(message),
        ],
      ),
      duration: Duration(seconds: duration),
    ),
  );
}

// ============================================
// NUMBER FORMATTING
// ============================================

/// Number format types
enum FormatType {
  decimal,
  percent,
  scientific,
  compact,
  compactLong,
  custom,
}

/// Decimal separator types
enum DecimalType {
  automatic,
  periodDecimal,
  commaDecimal,
}

/// Format number with various options
///
/// **Example**:
/// ```dart
/// formatNumber(1234.5, formatType: FormatType.decimal);
/// // Returns: "1,234.5"
///
/// formatNumber(0.75, formatType: FormatType.percent);
/// // Returns: "75%"
///
/// formatNumber(1234567, formatType: FormatType.compact);
/// // Returns: "1.2M"
/// ```
String formatNumber(
  num? value, {
  required FormatType formatType,
  DecimalType? decimalType,
  String? currency,
  bool toLowerCase = false,
  String? format,
  String? locale,
}) {
  if (value == null) {
    return '';
  }
  var formattedValue = '';
  switch (formatType) {
    case FormatType.decimal:
      switch (decimalType!) {
        case DecimalType.automatic:
          formattedValue = NumberFormat.decimalPattern(locale).format(value);
          break;
        case DecimalType.periodDecimal:
          formattedValue = NumberFormat.decimalPattern('en_US').format(value);
          break;
        case DecimalType.commaDecimal:
          formattedValue = NumberFormat.decimalPattern('es_PA').format(value);
          break;
      }
      break;
    case FormatType.percent:
      formattedValue = NumberFormat.percentPattern(locale).format(value);
      break;
    case FormatType.scientific:
      formattedValue = NumberFormat.scientificPattern(locale).format(value);
      if (toLowerCase) {
        formattedValue = formattedValue.toLowerCase();
      }
      break;
    case FormatType.compact:
      formattedValue = NumberFormat.compact(locale: locale).format(value);
      break;
    case FormatType.compactLong:
      formattedValue = NumberFormat.compactLong(locale: locale).format(value);
      break;
    case FormatType.custom:
      final hasLocale = locale != null && locale.isNotEmpty;
      formattedValue =
          NumberFormat(format, hasLocale ? locale : null).format(value);
  }

  if (formattedValue.isEmpty) {
    return value.toString();
  }

  if (currency != null) {
    final currencySymbol = currency.isNotEmpty
        ? currency
        : NumberFormat.simpleCurrency(locale: locale).currencySymbol;
    formattedValue = '$currencySymbol$formattedValue';
  }

  return formattedValue;
}

// ============================================
// APP-LEVEL SETTINGS
// ============================================

/// Set app language/locale
///
/// **Example**:
/// ```dart
/// setAppLanguage(context, 'ko');  // Korean
/// setAppLanguage(context, 'en');  // English
/// ```
void setAppLanguage(BuildContext context, String language) =>
    VersusApp.of(context).setLocale(language);

/// Set app theme mode
///
/// **Example**:
/// ```dart
/// setDarkModeSetting(context, ThemeMode.dark);
/// setDarkModeSetting(context, ThemeMode.light);
/// setDarkModeSetting(context, ThemeMode.system);
/// ```
void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    VersusApp.of(context).setThemeMode(themeMode);

// ============================================
// VALIDATION REGEXES
// ============================================

/// Username validation regex
///
/// **Rules**:
/// - Must start with letter
/// - 3-17 characters total
/// - Letters, numbers, underscore, hyphen allowed
const kTextValidatorUsernameRegex = r'^[a-zA-Z][a-zA-Z0-9_-]{2,16}$';

/// Email validation regex (RFC 5322 compliant)
const kTextValidatorEmailRegex =
    "^(?:[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])\$";

/// Website URL validation regex
const kTextValidatorWebsiteRegex =
    r'(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

// ============================================
// MISC UTILITIES
// ============================================

/// Return value or default if null/empty
///
/// **Example**:
/// ```dart
/// valueOrDefault<String>(null, 'N/A');  // Returns: "N/A"
/// valueOrDefault<String>('', 'N/A');    // Returns: "N/A"
/// valueOrDefault<String>('hello', 'N/A');  // Returns: "hello"
/// ```
T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && value.isEmpty) || value == null ? defaultValue : value;
