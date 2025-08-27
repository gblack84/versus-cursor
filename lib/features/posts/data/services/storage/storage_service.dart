import 'package:firebase_storage/firebase_storage.dart';
import '/features/posts/presentation/utils/debug_helper.dart';

/// Firebase Storage 관련 유틸리티 서비스
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 경로에서 모든 버전(original, display, thumbnail) 삭제
  static Future<bool> deleteAllImageVersions(String imagePath) async {
    try {
      DebugHelper.debug('이미지 삭제 시작: ${DebugHelper.maskData(imagePath)}', tag: 'StorageService');
      
      // 경로가 비어있는지 확인
      if (imagePath.isEmpty) {
        DebugHelper.warning('빈 경로', tag: 'StorageService');
        return false;
      }
      
      // 경로 파싱 (예: users/uid/posts/images/timestamp_box_type.jpg)
      final pathParts = imagePath.split('/');
      // 경로 파트 - 로그 제거
      
      if (pathParts.length < 5) {
        DebugHelper.warning('잘못된 경로 형식', tag: 'StorageService');
        return false;
      }

      final fileName = pathParts.last;
      final directory = pathParts.sublist(0, pathParts.length - 1).join('/');
      
      // 디렉토리 및 파일명 - 로그 제거
      
      // 파일명에서 타입 부분 제거 (예: 1234567890_A_original.jpg → 1234567890_A)
      String baseFileName = fileName;
      if (fileName.contains('_original.')) {
        baseFileName = fileName.replaceAll('_original', '');
      } else if (fileName.contains('_display.')) {
        baseFileName = fileName.replaceAll('_display', '');
      } else if (fileName.contains('_thumb.')) {
        baseFileName = fileName.replaceAll('_thumb', '');
      }
      
      // 기본 파일명 - 로그 제거
      
      // 확장자 분리
      final lastDotIndex = baseFileName.lastIndexOf('.');
      if (lastDotIndex > 0) {
        final nameWithoutExt = baseFileName.substring(0, lastDotIndex);
        final extension = baseFileName.substring(lastDotIndex);
        
        // 확장자 분리 - 로그 제거
        
        // 삭제할 파일 목록
        final filesToDelete = [
          '$directory/${nameWithoutExt}_original$extension',
          '$directory/${nameWithoutExt}_display$extension',
          '$directory/${nameWithoutExt}_thumb$extension',
        ];
        
        // 삭제할 파일들 - 로그 제거

        // 병렬로 삭제 시도
        final deleteResults = await Future.wait(
          filesToDelete.map((path) => _deleteFile(path)),
        );

        // 최소 하나 이상 삭제 성공했는지 확인
        final success = deleteResults.any((result) => result);
        
        DebugHelper.info('삭제 ${success ? "성공" : "실패"}', tag: 'StorageService');
        
        return success;
      } else {
        DebugHelper.warning('확장자를 찾을 수 없음', tag: 'StorageService');
        return false;
      }
    } catch (e) {
      DebugHelper.error('이미지 삭제 예외', error: e, tag: 'StorageService');
      return false;
    }
  }

  /// 단일 파일 삭제
  static Future<bool> _deleteFile(String path) async {
    try {
      // 파일 삭제 시도 - 로그 제거
      final ref = _storage.ref(path);
      
      // 파일 존재 여부 확인
      try {
        await ref.getMetadata();
        // 파일 존재 확인 - 로그 제거
      } catch (e) {
        // 메타데이터 확인 실패 - 로그 제거
      }
      
      await ref.delete();
      // 파일 삭제 성공 - 로그 제거
      return true;
    } catch (e) {
      // 파일이 없는 경우는 에러가 아님
      if (e.toString().contains('object-not-found')) {
        // 파일이 이미 없음 - 로그 제거
        return true;
      }
      DebugHelper.debug('파일 삭제 실패', tag: 'StorageService');
      return false;
    }
  }

  /// URL에서 Storage 경로 추출
  static String? getPathFromUrl(String url) {
    try {
      // Firebase Storage URL 패턴
      // https://firebasestorage.googleapis.com/v0/b/bucket-name/o/encoded-path?alt=media&token=...
      
      // URL 파싱 시작 - 로그 제거
      
      // 쿼리 파라미터 제거
      final urlWithoutQuery = url.split('?').first;
      // 쿼리 제거 - 로그 제거
      
      final uri = Uri.parse(urlWithoutQuery);
      final pathSegments = uri.pathSegments;
      
      // pathSegments - 로그 제거
      
      // pathSegments 예시: ['v0', 'b', 'versus-space-1lwwiw.appspot.com', 'o', 'users%2F...']
      if (pathSegments.length >= 5 && pathSegments[3] == 'o') {
        // 'o' 이후의 모든 세그먼트를 결합 (경로가 여러 세그먼트로 나뉠 수 있음)
        final encodedPathParts = pathSegments.sublist(4);
        final encodedPath = encodedPathParts.join('/');
        final decodedPath = Uri.decodeComponent(encodedPath);
        // 경로 디코딩 - 로그 제거
        return decodedPath;
      }
      
      DebugHelper.debug('URL 파싱 실패', tag: 'StorageService');
      return null;
    } catch (e) {
      DebugHelper.warning('URL 파싱 오류', tag: 'StorageService');
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