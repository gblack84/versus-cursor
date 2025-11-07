import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/profile_failure.dart';

/// Profile Storage Repository 인터페이스 (Clean Architecture v4.0)
///
/// **Domain Layer Port** - Data Layer Adapter 구현 필요
///
/// **책임**:
/// - 프로필 이미지 업로드
/// - 프로필 이미지 삭제
/// - Storage URL 관리
///
/// **변경사항** (2025-01-20):
/// - Data Layer DataSource에서 Domain Layer Repository로 이동
/// - UseCase가 Domain의 Port에 의존하도록 수정
/// - 구현체는 Data Layer에 유지 (Dependency Inversion Principle)
abstract class IProfileStorageRepository {
  /// 프로필 이미지 업로드
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID (Storage 경로에 사용)
  /// - `imageFile`: 업로드할 이미지 파일
  ///
  /// **Returns**:
  /// - `Right(String)`: 업로드된 이미지의 다운로드 URL
  /// - `Left(ProfileFailure.storage)`: 업로드 실패
  Future<Either<ProfileFailure, String>> uploadProfileImage({
    required String userId,
    required File imageFile,
  });

  /// 프로필 이미지 삭제
  ///
  /// **Parameters**:
  /// - `imageUrl`: 삭제할 이미지 URL
  ///
  /// **Returns**:
  /// - `Right(true)`: 삭제 성공
  /// - `Left(ProfileFailure.storage)`: 삭제 실패
  Future<Either<ProfileFailure, bool>> deleteProfileImage(String imageUrl);
}
