// ============================================
// TYPE CONVERTERS - Search Feature Specific
// ============================================
//
// Moved from: /lib/core/utils/app_utils.dart
// Migration date: 2025-11-11
// Reason: Feature-specific utility (primary usage in Search Feature)
//
// Location: Search Feature Data Layer
// Purpose: Type conversion for Algolia search results
// ============================================

/// Safely cast dynamic value to specified type
///
/// **Usage**: Primarily for Algolia search result conversion
///
/// **Supported types**:
/// - String: Converts any value to string via toString()
/// - int: Parses from double/string, returns null on failure
/// - double: Parses from int/string, returns null on failure
/// - bool: Parses from string ("true"/"1"), int (0=false), or bool
/// - DateTime: Parses from DateTime/string/int (milliseconds)
///
/// **Returns**: Typed value or null if conversion fails
///
/// **Example**:
/// ```dart
/// final age = castToType<int>("25");  // Returns: 25
/// final date = castToType<DateTime>(1234567890000);  // Returns: DateTime
/// final invalid = castToType<int>("abc");  // Returns: null
/// ```
T? castToType<T>(dynamic value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case String:
      return value.toString() as T;
    case int:
      if (value is int) return value as T;
      if (value is double) return value.toInt() as T;
      if (value is String) return int.tryParse(value) as T?;
      break;
    case double:
      if (value is double) return value as T;
      if (value is int) return value.toDouble() as T;
      if (value is String) return double.tryParse(value) as T?;
      break;
    case bool:
      if (value is bool) return value as T;
      if (value is String) {
        return (value.toLowerCase() == 'true' || value == '1') as T;
      }
      if (value is int) return (value != 0) as T;
      break;
    case DateTime:
      if (value is DateTime) return value as T;
      if (value is String) return DateTime.tryParse(value) as T?;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value) as T;
      break;
  }

  // Try direct cast as last resort
  try {
    return value as T;
  } catch (_) {
    return null;
  }
}
