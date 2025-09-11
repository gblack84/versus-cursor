import 'package:cloud_firestore/cloud_firestore.dart';

/// Extension methods and utilities for DTO operations
extension TimestampExtensions on Timestamp {
  /// Convert Timestamp to DateTime
  DateTime toDateTime() => toDate();

  /// Check if timestamp is expired
  bool isExpired() => toDate().isBefore(DateTime.now());

  /// Get milliseconds since epoch
  int get milliseconds => millisecondsSinceEpoch;
}

extension DateTimeExtensions on DateTime {
  /// Convert DateTime to Firestore Timestamp
  Timestamp toTimestamp() => Timestamp.fromDate(this);

  /// Check if date is expired
  bool isExpired() => isBefore(DateTime.now());
}

/// Helper class for DTO conversions
class DtoHelper {
  /// Parse dynamic value to Timestamp
  static Timestamp? parseTimestamp(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value;
    } else if (value is DateTime) {
      return Timestamp.fromDate(value);
    } else if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      try {
        final date = DateTime.parse(value);
        return Timestamp.fromDate(date);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Parse dynamic value to DateTime
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Safely cast dynamic to Map<String, dynamic>
  static Map<String, dynamic>? parseMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    } else if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  /// Safely parse list of strings
  static List<String>? parseStringList(dynamic value) {
    if (value == null) return null;

    if (value is List<String>) {
      return value;
    } else if (value is List) {
      return value.whereType<String>().toList();
    }

    return null;
  }

  /// Ensure non-null with default value
  static T ensureNonNull<T>(T? value, T defaultValue) {
    return value ?? defaultValue;
  }

  /// Create timestamp for current time
  static Timestamp now() => Timestamp.now();

  /// Create timestamp with expiry duration
  static Timestamp expiryTime(Duration duration) {
    return Timestamp.fromDate(DateTime.now().add(duration));
  }
}
