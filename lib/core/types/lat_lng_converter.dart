import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/types/lat_lng.dart';

/// LatLngConverter for Freezed 3.x compatibility
///
/// **위치**: Core Layer - 공유 Converter
/// **사용처**: Profile Feature (user_profile.dart, profile_info.dart)
///
/// **Usage**:
/// ```dart
/// @LatLngConverter()
/// LatLng? location,
/// ```
///
/// **마이그레이션**: /app/types/ → /core/types/ (2025-11-10)
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
