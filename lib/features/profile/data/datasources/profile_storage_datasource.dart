import 'dart:io';

/// Profile 이미지 Storage DataSource 인터페이스 (Clean Architecture v4.0)
///
/// **Data Layer Interface** - Firebase Storage와 직접 통신
///
/// **책임**:
/// - 프로필 이미지 업로드 (Firebase Storage)
/// - 프로필 이미지 삭제
/// - Storage URL 관리
///
/// **아키텍처 패턴**:
/// - DataSource: Raw 데이터 처리 (예외 직접 던짐)
/// - Repository: Either 패턴으로 감싸서 Domain Layer에 제공
/// - UseCase: Repository의 Either 결과 사용
///
/// **변경사항** (2025-01-29):
/// - IProfileStorageRepository implements 제거
/// - DataSource는 독립적인 인터페이스로 유지
/// - Repository 구현체가 DataSource를 사용하여 Either로 변환
abstract class IProfileStorageDataSource {
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
