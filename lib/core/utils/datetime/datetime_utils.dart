// ============================================
// DATETIME UTILITIES - Core Utils
// ============================================
//
// Split from: /lib/core/utils/app_utils.dart
// Migration date: 2025-11-11
// Reason: SRP (Single Responsibility Principle) - datetime operations only
//
// Purpose: Date and time formatting, manipulation, and extensions
// ============================================

import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

// ============================================
// FORMATTING
// ============================================

/// Format DateTime to string with locale support
///
/// **Supports two modes**:
/// - `format == "relative"`: Uses timeago package (e.g., "2 hours ago")
/// - `format == other`: Uses DateFormat from intl (e.g., "yyyy-MM-dd")
///
/// **Example**:
/// ```dart
/// dateTimeFormat('relative', DateTime.now().subtract(Duration(hours: 2)));
/// // Returns: "2 hours ago"
///
/// dateTimeFormat('yyyy-MM-dd', DateTime.now());
/// // Returns: "2025-11-11"
/// ```
String dateTimeFormat(String format, DateTime? dateTime, {String? locale}) {
  if (dateTime == null) {
    return '';
  }
  if (format == 'relative') {
    _setTimeagoLocales();
    return timeago.format(dateTime, locale: locale, allowFromNow: true);
  }
  return DateFormat(format, locale).format(dateTime);
}

void _setTimeagoLocales() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('de_short', timeago.DeShortMessages());
}

// ============================================
// MANIPULATION
// ============================================

/// Create a copy of DateTime (deep copy)
///
/// Returns null if input is null, otherwise creates new DateTime
/// with same millisecondsSinceEpoch
DateTime? dateCopy(DateTime? dateTime) => dateTime != null
    ? DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch)
    : null;

/// Get current timestamp
DateTime getCurrentTimestamp() => DateTime.now();

// ============================================
// EXTENSIONS
// ============================================

/// Comparison operators for DateTime
///
/// **Example**:
/// ```dart
/// final now = DateTime.now();
/// final future = now.add(Duration(hours: 1));
///
/// if (now < future) {
///   UtilsLogger.datetimeOperation(
///     operation: 'comparison',
///     result: 'now is before future',
///   );  // This logs
/// }
/// ```
extension DateTimeComparisonOperators on DateTime {
  bool operator <(DateTime other) => isBefore(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator <=(DateTime other) => this < other || isAtSameMomentAs(other);
  bool operator >=(DateTime other) => this > other || isAtSameMomentAs(other);
}

/// DateTime convenience methods
///
/// **Example**:
/// ```dart
/// final date = DateTime(2025, 11, 11, 14, 30);
/// final start = date.startOfDay;  // 2025-11-11 00:00:00
/// final end = date.endOfDay;      // 2025-11-11 23:59:59
/// ```
extension DateTimeExtension on DateTime? {
  DateTime get startOfDay => DateTime(this!.year, this!.month, this!.day);
  DateTime get endOfDay =>
      DateTime(this!.year, this!.month, this!.day, 23, 59, 59, 999);
}
