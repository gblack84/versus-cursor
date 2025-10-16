import 'dart:io';
import '../../domain/repositories/i_profile_storage_repository.dart';

/// Profile 이미지 Storage DataSource 인터페이스 (Clean Architecture v4.0)
///
/// **Data Layer Adapter** - Domain Layer Port 구현
///
/// **책임**:
/// - 프로필 이미지 업로드 (Firebase Storage)
/// - 프로필 이미지 삭제
/// - Storage URL 관리
///
/// **변경사항** (2025-01-20):
/// - Domain Repository 인터페이스 구현으로 변경
/// - Dependency Inversion Principle 적용
/// - UseCase는 Domain Port에 의존, 구현은 Data Layer에 존재
abstract class IProfileStorageDataSource implements IProfileStorageRepository {
  /// 프로필 이미지 업로드
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID (Storage 경로에 사용)
  /// - `imageFile`: 업로드할 이미지 파일
  ///
  /// **Returns**: 업로드된 이미지의 다운로드 URL
  ///
  /// **Throws**: 업로드 실패 시 Exception
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  });

  /// 프로필 이미지 삭제
  ///
  /// **Parameters**:
  /// - `imageUrl`: 삭제할 이미지 URL
  ///
  /// **Returns**: 삭제 성공 여부
  Future<bool> deleteProfileImage(String imageUrl);
}
