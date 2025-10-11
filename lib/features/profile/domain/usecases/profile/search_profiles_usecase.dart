import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/profile_info.dart';
import '../../failures/profile_failures.dart';

/// 사용자 프로필 복합 검색 UseCase
///
/// **책임**: 거리, 나이, 관심사 기반 사용자 검색
/// **의존성**: IProfileRepository (Haversine 공식 사용)
/// **반환**: Either<ProfileFailure, List<UserProfile>>
class SearchProfilesUseCase {
  final IProfileRepository _repository;

  SearchProfilesUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 복합 검색 실행
  ///
  /// **Parameters**:
  /// - `lat`: 기준 위도
  /// - `lng`: 기준 경도
  /// - `radiusKm`: 검색 반경 (km)
  /// - `minAge`: 최소 나이 (선택)
  /// - `maxAge`: 최대 나이 (선택)
  /// - `interests`: 관심사 필터 (선택)
  /// - `limit`: 최대 결과 수 (기본 20)
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 잘못된 파라미터 (lat/lng 범위 초과)
  /// - `Left(FirestoreReadFailure)`: Firestore 쿼리 실패
  /// - `Right(List<ProfileInfo>)`: 검색 결과 (거리순 정렬)
  Future<Either<ProfileFailure, List<ProfileInfo>>> execute({
    required double lat,
    required double lng,
    required double radiusKm,
    int? minAge,
    int? maxAge,
    List<String>? interests,
    int limit = 20,
  }) async {
    // 위도/경도 범위 검증
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return Left(ValidationFailure(
        message: '잘못된 위도/경도 값입니다.',
      ));
    }

    try {
      // GeoPoint 생성
      final userLocation = GeoPoint(lat, lng);

      // Repository 검색 메서드 호출
      final result = await _repository.searchProfiles(
        userLocation: userLocation,
        maxDistance: radiusKm,
        minAge: minAge,
        maxAge: maxAge,
        interests: interests,
        limit: limit,
      );

      return Right(result);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
