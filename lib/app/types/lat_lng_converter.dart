import 'package:freezed_annotation/freezed_annotation.dart';
import 'lat_lng.dart';

/// LatLngConverter for Freezed 3.x compatibility
///
/// Converts between LatLng and Map<String, dynamic>
///
/// **Shared Converter**: Used by profile_info.dart and user_profile.dart
/// to eliminate code duplication for location field serialization.
///
/// **Usage**:
/// ```dart
/// @LatLngConverter()
/// LatLng? location,
/// ```
///
/// **Migration Note**: Replaces individual helper functions:
/// - `_latLngFromJson` (removed from profile_info.dart)
/// - `_latLngToJson` (removed from profile_info.dart)
/// - `_latLngFromJson` (removed from user_profile.dart)
/// - `_latLngToJson` (removed from user_profile.dart)
class LatLngConverter implements JsonConverter<LatLng?, Map<String, dynamic>?> {
  const LatLngConverter();

  @override
  LatLng? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    try {
      final latitude = json['latitude'] as num?;
      final longitude = json['longitude'] as num?;

      if (latitude == null || longitude == null) return null;

      return LatLng(
        latitude.toDouble(),
        longitude.toDouble(),
      );
    } catch (e) {
      // Invalid data format, return null
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(LatLng? latLng) {
    if (latLng == null) return null;

    return {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    };
  }
}
