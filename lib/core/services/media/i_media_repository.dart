import 'dart:io';
import 'dart:typed_data';

/// Media Repository Interface
/// 
/// 미디어 파일 관리를 추상화하는 인터페이스입니다.
/// Firebase Storage와 이미지/비디오 처리를 통합 관리합니다.
abstract interface class IMediaRepository {
  /// 이미지 업로드
  /// 
  /// [file] 업로드할 이미지 파일
  /// [path] Storage 경로 (기본값: uploads/images/)
  /// [compress] 압축 여부
  /// [maxWidth] 최대 너비 (압축 시)
  /// [quality] 압축 품질 (0-100)
  Future<String> uploadImage(
    File file, {
    String? path,
    bool compress = true,
    int maxWidth = 1920,
    int quality = 85,
  });
  
  /// 이미지 바이트 업로드
  /// 
  /// [bytes] 업로드할 이미지 바이트
  /// [fileName] 파일명
  /// [path] Storage 경로
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String fileName, {
    String? path,
  });
  
  /// 여러 이미지 업로드
  /// 
  /// [files] 업로드할 이미지 파일 목록
  /// [compress] 압축 여부
  /// 병렬 업로드로 성능 최적화
  Future<List<String>> uploadMultipleImages(
    List<File> files, {
    bool compress = true,
  });
  
  /// 비디오 업로드
  /// 
  /// [file] 업로드할 비디오 파일
  /// [path] Storage 경로 (기본값: uploads/videos/)
  /// [generateThumbnail] 썸네일 생성 여부
  Future<Map<String, String>> uploadVideo(
    File file, {
    String? path,
    bool generateThumbnail = true,
  });
  
  /// 파일 업로드
  /// 
  /// [file] 업로드할 파일
  /// [path] Storage 경로 (기본값: uploads/files/)
  Future<String> uploadFile(
    File file, {
    String? path,
  });
  
  /// 파일 다운로드
  /// 
  /// [url] 다운로드할 파일 URL
  /// [savePath] 저장 경로
  Future<File?> downloadFile(
    String url, {
    String? savePath,
  });
  
  /// 파일 삭제
  /// 
  /// [url] 삭제할 파일 URL
  Future<bool> deleteFile(String url);
  
  /// 여러 파일 삭제
  /// 
  /// [urls] 삭제할 파일 URL 목록
  Future<void> deleteMultipleFiles(List<String> urls);
  
  /// 썸네일 생성
  /// 
  /// [videoUrl] 비디오 URL
  /// [position] 썸네일 추출 위치
  Future<String> generateVideoThumbnail(
    String videoUrl, {
    Duration position = const Duration(seconds: 1),
  });
  
  /// 이미지 썸네일 생성
  /// 
  /// [imageUrl] 원본 이미지 URL
  /// [width] 썸네일 너비
  /// [height] 썸네일 높이
  Future<String> generateImageThumbnail(
    String imageUrl, {
    int width = 150,
    int? height,
  });
  
  /// 이미지 리사이징
  /// 
  /// [file] 리사이징할 이미지 파일
  /// [width] 목표 너비
  /// [height] 목표 높이
  /// [maintainAspectRatio] 비율 유지 여부
  Future<File> resizeImage(
    File file, {
    required int width,
    int? height,
    bool maintainAspectRatio = true,
  });
  
  /// 이미지 압축
  /// 
  /// [file] 압축할 이미지 파일
  /// [quality] 압축 품질 (0-100)
  Future<File> compressImage(
    File file, {
    int quality = 85,
  });
  
  /// 업로드 진행률 스트림
  /// 
  /// [taskId] 업로드 작업 ID
  /// 0.0 ~ 1.0 사이의 진행률
  Stream<double> uploadProgress(String taskId);
  
  /// 파일 메타데이터 조회
  /// 
  /// [url] 파일 URL
  /// 크기, 타입, 생성일 등 정보 반환
  Future<Map<String, dynamic>> getFileMetadata(String url);
  
  /// 파일 URL 서명
  /// 
  /// [url] 서명할 URL
  /// [expiration] 만료 시간
  /// 임시 접근 URL 생성
  Future<String> getSignedUrl(
    String url, {
    Duration expiration = const Duration(hours: 1),
  });
  
  /// 미디어 타입 확인
  /// 
  /// [file] 확인할 파일
  /// image, video, audio, document 등
  Future<String> getMediaType(File file);
  
  /// 파일 크기 확인
  /// 
  /// [file] 확인할 파일
  /// 바이트 단위 크기
  Future<int> getFileSize(File file);
  
  /// 업로드 취소
  /// 
  /// [taskId] 취소할 작업 ID
  Future<void> cancelUpload(String taskId);
  
  /// 모든 업로드 취소
  Future<void> cancelAllUploads();
  
  /// 캐시 정리
  /// 
  /// 임시 파일 및 캐시 정리
  Future<void> clearCache();
}