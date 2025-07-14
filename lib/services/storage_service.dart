import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage 관련 유틸리티 서비스
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 경로에서 모든 버전(original, display, thumbnail) 삭제
  static Future<bool> deleteAllImageVersions(String imagePath) async {
    try {
      print('[StorageService] 삭제 시작 - 원본 경로: $imagePath');
      
      // 경로 파싱 (예: users/uid/posts/images/timestamp_box_type.jpg)
      final pathParts = imagePath.split('/');
      if (pathParts.length < 5) {
        print('[StorageService] 잘못된 이미지 경로: $imagePath');
        return false;
      }

      final fileName = pathParts.last;
      final directory = pathParts.sublist(0, pathParts.length - 1).join('/');
      
      // 파일명에서 타입 부분 제거 (예: 1234567890_A_original.jpg → 1234567890_A)
      String baseFileName = fileName;
      if (fileName.contains('_original.')) {
        baseFileName = fileName.replaceAll('_original', '');
      } else if (fileName.contains('_display.')) {
        baseFileName = fileName.replaceAll('_display', '');
      } else if (fileName.contains('_thumb.')) {
        baseFileName = fileName.replaceAll('_thumb', '');
      }
      
      // 확장자 분리
      final lastDotIndex = baseFileName.lastIndexOf('.');
      if (lastDotIndex > 0) {
        final nameWithoutExt = baseFileName.substring(0, lastDotIndex);
        final extension = baseFileName.substring(lastDotIndex);
        
        // 삭제할 파일 목록
        final filesToDelete = [
          '$directory/${nameWithoutExt}_original$extension',
          '$directory/${nameWithoutExt}_display$extension',
          '$directory/${nameWithoutExt}_thumb$extension',
        ];
        
        print('[StorageService] 삭제할 파일들:');
        for (final file in filesToDelete) {
          print('  - $file');
        }

        // 병렬로 삭제 시도
        final deleteResults = await Future.wait(
          filesToDelete.map((path) => _deleteFile(path)),
        );

        // 최소 하나 이상 삭제 성공했는지 확인
        final success = deleteResults.any((result) => result);
        
        if (success) {
          print('[StorageService] 이미지 삭제 완료: $baseFileName');
        } else {
          print('[StorageService] 이미지 삭제 실패: $baseFileName');
        }
        
        return success;
      }
      
      return false;
    } catch (e) {
      print('[StorageService] 이미지 삭제 중 오류: $e');
      return false;
    }
  }

  /// 단일 파일 삭제
  static Future<bool> _deleteFile(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.delete();
      print('[StorageService] 파일 삭제 성공: $path');
      return true;
    } catch (e) {
      // 파일이 없는 경우는 에러가 아님
      if (e.toString().contains('object-not-found')) {
        print('[StorageService] 파일이 이미 없음: $path');
        return true;
      }
      print('[StorageService] 파일 삭제 실패: $path - $e');
      return false;
    }
  }

  /// URL에서 Storage 경로 추출
  static String? getPathFromUrl(String url) {
    try {
      // Firebase Storage URL 패턴
      // https://firebasestorage.googleapis.com/v0/b/bucket-name/o/encoded-path?alt=media&token=...
      
      print('[StorageService] URL 파싱 시작: $url');
      
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      print('[StorageService] pathSegments: $pathSegments');
      print('[StorageService] pathSegments 길이: ${pathSegments.length}');
      
      // pathSegments 예시: ['v0', 'b', 'versus-space-1lwwiw.appspot.com', 'o', 'users%2F...']
      if (pathSegments.length > 4 && pathSegments[3] == 'o') {
        // encoded path 디코딩
        final encodedPath = pathSegments[4];
        final decodedPath = Uri.decodeComponent(encodedPath);
        print('[StorageService] 추출된 경로: $decodedPath');
        return decodedPath;
      }
      
      print('[StorageService] URL 파싱 실패 - 올바른 형식이 아님');
      return null;
    } catch (e) {
      print('[StorageService] URL 파싱 중 오류: $e');
      return null;
    }
  }

  /// URL에서 이미지 삭제
  static Future<bool> deleteImageFromUrl(String url) async {
    final path = getPathFromUrl(url);
    if (path != null) {
      return await deleteAllImageVersions(path);
    }
    return false;
  }

  /// 여러 URL의 이미지 삭제
  static Future<Map<String, bool>> deleteMultipleImages(List<String> urls) async {
    final results = <String, bool>{};
    
    // 병렬 처리로 성능 향상
    await Future.wait(
      urls.map((url) async {
        results[url] = await deleteImageFromUrl(url);
      }),
    );
    
    return results;
  }
}