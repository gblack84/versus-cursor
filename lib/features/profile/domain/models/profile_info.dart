import 'package:freezed_annotation/freezed_annotation.dart';
import '/app/models/lat_lng.dart';

part 'profile_info.freezed.dart';
part 'profile_info.g.dart';

/// LatLng JSON 변환 함수
LatLng? _latLngFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return LatLng(
    (json['latitude'] as num).toDouble(),
    (json['longitude'] as num).toDouble(),
  );
}

Map<String, dynamic>? _latLngToJson(LatLng? latLng) {
  if (latLng == null) return null;
  return {
    'latitude': latLng.latitude,
    'longitude': latLng.longitude,
  };
}

/// ProfileInfo Domain Model
/// Clean Architecture - Domain Layer Entity
///
/// **변경사항** (2025-01-20):
/// - Freezed sealed class로 전환 (131줄 → 51줄, 61% 감소)
/// - copyWith, toString, hashCode, == 자동 생성
/// - fromJson/toJson 자동 생성
/// - 36줄의 boilerplate 코드 제거
///
/// **이전 변경사항** (2025-01-20):
/// - Firebase 의존성 제거: GeoPoint → LatLng
/// - fromDocument(), toFirestore() 메서드 제거 → DTO로 이동 예정
///
/// This model contains user profile display information,
/// separated from authentication concerns (AuthUser) and
/// statistics (UserStats) for better separation of concerns.
@freezed
sealed class ProfileInfo with _$ProfileInfo {
  const factory ProfileInfo({
    // Core Fields
    required String userId, // Foreign key to AuthUser.uid
    required String displayName,
    String? photoUrl,

    // Profile Details
    String? shortDescription,
    String? gender,
    DateTime? dateOfBirth,
    @Default('en') String language,

    // Lists
    @Default([]) List<String> interests,
    @Default([]) List<String> expertise,

    // Location
    @JsonKey(fromJson: _latLngFromJson, toJson: _latLngToJson) LatLng? location,
  }) = _ProfileInfo;

  factory ProfileInfo.fromJson(Map<String, dynamic> json) =>
      _$ProfileInfoFromJson(json);
}
