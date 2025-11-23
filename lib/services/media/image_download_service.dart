import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '/services/logging/logger_service.dart';

class ImageDownloadService {
  /// Firebase Storage URL에서 이미지를 다운로드하여 로컬 파일로 저장
  static Future<String> downloadImage(String imageUrl) async {
    try {
      // HTTP GET 요청으로 이미지 다운로드
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw Exception('이미지 다운로드 실패: HTTP ${response.statusCode}');
      }

      // 임시 디렉토리 가져오기
      final tempDir = await getTemporaryDirectory();

      // 파일명 생성 (timestamp 사용)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'edit_image_$timestamp.jpg';
      final filePath = path.join(tempDir.path, fileName);

      // 파일로 저장
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return filePath;
    } catch (e) {
      throw Exception('이미지 다운로드 중 오류 발생: $e');
    }
  }

  /// 임시 파일 정리 (편집 완료 후 호출)
  static Future<void> cleanupTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // 파일 삭제 실패는 무시 (임시 파일이므로)
      MediaLogger.mediaDeletionError(
        errorType: 'tempFileDeletionFailed',
        error: e,
        mediaUrl: filePath,
      );
    }
  }
}
