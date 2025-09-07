import 'dart:typed_data';

/// Media Upload Service 인터페이스
/// 
/// 미디어 업로드 기능의 도메인 포트(Port)
/// Clean Architecture에서 데이터 레이어 구현과 분리
abstract class IMediaUploadService {
  /// 이미지를 3가지 크기로 업로드 (original, display, thumbnail)
  /// 반환값: URLs와 aspect ratio 정보를 포함한 Map
  Future<Map<String, dynamic>> uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    String? sessionId,
    Function(String)? onModerationStatusUpdate,
    Function(String)? onRejected,
  });
  
  /// 이미지 업로드와 검열 완료까지 대기
  /// 반환값: 검열 통과한 URLs와 실패한 이미지 정보
  Future<Map<String, dynamic>> uploadAndWaitForModeration({
    required List<Uint8List> imageBytesList,
    required String box,
    String? customPath,
    String? sessionId,
    Function(int current, int total)? onProgress,
  });
  
  /// Firebase Storage URL에서 이미지 다운로드
  Future<Uint8List> downloadImageFromUrl(String url);
}