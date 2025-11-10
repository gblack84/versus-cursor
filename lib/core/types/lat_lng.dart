/// LatLng - 좌표 Value Object (Domain Primitive)
///
/// **위치**: Core Layer - 공유 타입
/// **사용처**: Profile Feature, Search Feature, Core utilities, Localization services
/// **패턴**: Immutable Value Object
///
/// **마이그레이션**: /app/types/ → /core/types/ (2025-11-10)
///
/// **두 가지 출처**:
/// - IP 기반 (CountryDetectionService): ±10-50km 정확도
/// - GPS 기반 (LocationService - 미래): ±5-10m 정확도
class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';

  String serialize() => '$latitude,$longitude';

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  @override
  bool operator ==(other) =>
      other is LatLng &&
      latitude == other.latitude &&
      longitude == other.longitude;
}
