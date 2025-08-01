import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage 관련 유틸리티 서비스
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 경로에서 모든 버전(original, display, thumbnail) 삭제
  static Future<bool> deleteAllImageVersions(String imagePath) async {
    try {
      print('[StorageService] ========== 삭제 시작 ==========');
      print('[StorageService] 원본 경로: $imagePath');
      
      // 경로가 비어있는지 확인
      if (imagePath.isEmpty) {
        print('[StorageService] 에러: 빈 경로');
        return false;
      }
      
      // 경로 파싱 (예: users/uid/posts/images/timestamp_box_type.jpg)
      final pathParts = imagePath.split('/');
      print('[StorageService] 경로 파트: $pathParts');
      
      if (pathParts.length < 5) {
        print('[StorageService] 에러: 경로가 너무 짧음 (최소 5개 필요, 현재 ${pathParts.length}개)');
        return false;
      }

      final fileName = pathParts.last;
      final directory = pathParts.sublist(0, pathParts.length - 1).join('/');
      
      print('[StorageService] 디렉토리: $directory');
      print('[StorageService] 파일명: $fileName');
      
      // 파일명에서 타입 부분 제거 (예: 1234567890_A_original.jpg → 1234567890_A)
      String baseFileName = fileName;
      if (fileName.contains('_original.')) {
        baseFileName = fileName.replaceAll('_original', '');
      } else if (fileName.contains('_display.')) {
        baseFileName = fileName.replaceAll('_display', '');
      } else if (fileName.contains('_thumb.')) {
        baseFileName = fileName.replaceAll('_thumb', '');
      }
      
      print('[StorageService] 기본 파일명: $baseFileName');
      
      // 확장자 분리
      final lastDotIndex = baseFileName.lastIndexOf('.');
      if (lastDotIndex > 0) {
        final nameWithoutExt = baseFileName.substring(0, lastDotIndex);
        final extension = baseFileName.substring(lastDotIndex);
        
        print('[StorageService] 확장자 제외 이름: $nameWithoutExt');
        print('[StorageService] 확장자: $extension');
        
        // 삭제할 파일 목록
        final filesToDelete = [
          '$directory/${nameWithoutExt}_original$extension',
          '$directory/${nameWithoutExt}_display$extension',
          '$directory/${nameWithoutExt}_thumb$extension',
        ];
        
        print('[StorageService] 삭제할 파일들:');
        for (final file in filesToDelete) {
          print('[StorageService]   - $file');
        }

        // 병렬로 삭제 시도
        final deleteResults = await Future.wait(
          filesToDelete.map((path) => _deleteFile(path)),
        );

        // 최소 하나 이상 삭제 성공했는지 확인
        final success = deleteResults.any((result) => result);
        
        print('[StorageService] 삭제 결과: ${success ? "성공" : "실패"}');
        print('[StorageService] 개별 결과: $deleteResults');
        print('[StorageService] ========== 삭제 완료 ==========');
        
        return success;
      } else {
        print('[StorageService] 에러: 확장자를 찾을 수 없음');
        return false;
      }
    } catch (e) {
      print('[StorageService] 이미지 삭제 중 예외 발생!');
      print('[StorageService] 예외: $e');
      print('[StorageService] 스택 트레이스: ${StackTrace.current}');
      return false;
    }
  }

  /// 단일 파일 삭제
  static Future<bool> _deleteFile(String path) async {
    try {
      print('[StorageService] 파일 삭제 시도: $path');
      final ref = _storage.ref(path);
      
      // 파일 존재 여부 확인
      try {
        await ref.getMetadata();
        print('[StorageService] 파일 존재 확인됨: $path');
      } catch (e) {
        print('[StorageService] 파일 메타데이터 확인 실패: $e');
      }
      
      await ref.delete();
      print('[StorageService] 파일 삭제 성공: $path');
      return true;
    } catch (e) {
      // 파일이 없는 경우는 에러가 아님
      if (e.toString().contains('object-not-found')) {
        print('[StorageService] 파일이 이미 없음: $path');
        return true;
      }
      print('[StorageService] 파일 삭제 실패: $path');
      print('[StorageService] 에러 상세: $e');
      print('[StorageService] 에러 타입: ${e.runtimeType}');
      return false;
    }
  }

  /// URL에서 Storage 경로 추출
  static String? getPathFromUrl(String url) {
    try {
      // Firebase Storage URL 패턴
      // https://firebasestorage.googleapis.com/v0/b/bucket-name/o/encoded-path?alt=media&token=...
      
      print('[StorageService] URL 파싱 시작: $url');
      
      // 쿼리 파라미터 제거
      final urlWithoutQuery = url.split('?').first;
      print('[StorageService] 쿼리 제거된 URL: $urlWithoutQuery');
      
      final uri = Uri.parse(urlWithoutQuery);
      final pathSegments = uri.pathSegments;
      
      print('[StorageService] pathSegments: $pathSegments');
      print('[StorageService] pathSegments 길이: ${pathSegments.length}');
      
      // pathSegments 예시: ['v0', 'b', 'versus-space-1lwwiw.appspot.com', 'o', 'users%2F...']
      if (pathSegments.length >= 5 && pathSegments[3] == 'o') {
        // 'o' 이후의 모든 세그먼트를 결합 (경로가 여러 세그먼트로 나뉠 수 있음)
        final encodedPathParts = pathSegments.sublist(4);
        final encodedPath = encodedPathParts.join('/');
        final decodedPath = Uri.decodeComponent(encodedPath);
        print('[StorageService] 인코딩된 경로: $encodedPath');
        print('[StorageService] 디코딩된 경로: $decodedPath');
        return decodedPath;
      }
      
      print('[StorageService] URL 파싱 실패 - 올바른 형식이 아님');
      return null;
    } catch (e) {
      print('[StorageService] URL 파싱 중 오류: $e');
      print('[StorageService] 오류 타입: ${e.runtimeType}');
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