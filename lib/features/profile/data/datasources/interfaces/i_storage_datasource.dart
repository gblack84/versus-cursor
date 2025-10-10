/// Storage DataSource 인터페이스
///
/// **책임**: Firebase Storage 이미지 업로드/삭제
abstract class IStorageDataSource {
  /// 프로필 이미지 업로드
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `imageBytes`: 이미지 바이트 데이터
  /// - `fileName`: 파일명
  ///
  /// **Returns**: 업로드된 이미지 URL
  Future<String> uploadProfileImage({
    required String userId,
    required List<int> imageBytes,
    required String fileName,
  });

  /// 프로필 이미지 삭제
  Future<void> deleteProfileImage(String imageUrl);
}
