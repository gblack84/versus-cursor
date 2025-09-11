import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'i_media_repository.dart';

/// 미디어 타입 열거형
enum MediaType {
  image,
  video,
  audio,
  other,
}

/// MediaRepository 구현체
///
/// 미디어 업로드, 처리, 다운로드를 담당합니다.
/// Firebase Storage를 통합합니다.
class MediaRepositoryImpl implements IMediaRepository {
  MediaRepositoryImpl({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;
  final FirebaseStorage _storage;
  final Map<String, UploadTask> _uploadTasks = {};
  final Map<String, Stream<TaskSnapshot>> _progressStreams = {};

  // ================== 이미지 업로드 ==================

  @override
  Future<String> uploadImage(
    File file, {
    String? path,
    bool compress = true,
    int maxWidth = 1920,
    int quality = 85,
  }) async {
    try {
      final auth = GetIt.instance<FirebaseAuth>();
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다');
      }

      final bytes = await file.readAsBytes();
      Uint8List processedBytes = bytes;

      // 압축 처리
      if (compress) {
        final image = img.decodeImage(bytes);
        if (image != null) {
          img.Image resized = image;
          if (image.width > maxWidth) {
            resized = img.copyResize(image, width: maxWidth);
          }
          processedBytes = Uint8List.fromList(
            img.encodeJpg(resized, quality: quality),
          );
        }
      }

      // 경로 설정
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final uploadPath = path ?? 'uploads/images/$fileName';

      // Firebase Storage 업로드
      final ref = _storage.ref(uploadPath);
      final uploadTask = ref.putData(
        processedBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // 태스크 ID 생성 및 저장
      final taskId = DateTime.now().millisecondsSinceEpoch.toString();
      _uploadTasks[taskId] = uploadTask;
      _progressStreams[taskId] = uploadTask.snapshotEvents;

      // 업로드 완료 대기
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // 태스크 정리
      _uploadTasks.remove(taskId);
      _progressStreams.remove(taskId);

      return downloadUrl;
    } catch (e) {
      throw Exception('이미지 업로드 실패: $e');
    }
  }

  @override
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String fileName, {
    String? path,
  }) async {
    try {
      final auth = GetIt.instance<FirebaseAuth>();
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다');
      }

      // 경로 설정
      final uploadPath = path ?? 'uploads/images/$fileName';

      // Firebase Storage 업로드
      final ref = _storage.ref(uploadPath);
      final snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('이미지 바이트 업로드 실패: $e');
    }
  }

  @override
  Future<List<String>> uploadMultipleImages(
    List<File> files, {
    bool compress = true,
  }) async {
    try {
      final futures = files.map((file) => uploadImage(
            file,
            compress: compress,
          ));

      return await Future.wait(futures);
    } catch (e) {
      throw Exception('다중 이미지 업로드 실패: $e');
    }
  }

  // ================== 비디오 업로드 ==================

  @override
  Future<Map<String, String>> uploadVideo(
    File file, {
    String? path,
    bool generateThumbnail = true,
  }) async {
    try {
      final auth = GetIt.instance<FirebaseAuth>();
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다');
      }

      final bytes = await file.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final uploadPath = path ?? 'uploads/videos/$fileName';

      // 비디오 업로드
      final ref = _storage.ref(uploadPath);
      final snapshot = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'video/mp4'),
      );
      final videoUrl = await snapshot.ref.getDownloadURL();

      final result = <String, String>{
        'videoUrl': videoUrl,
      };

      // 썸네일 생성 (현재는 플레이스홀더)
      if (generateThumbnail) {
        // 실제 구현에서는 video_compress 패키지를 사용하여 썸네일 생성
        result['thumbnailUrl'] = videoUrl; // 임시
      }

      return result;
    } catch (e) {
      throw Exception('비디오 업로드 실패: $e');
    }
  }

  // ================== 파일 관리 ==================

  @override
  Future<String> uploadFile(
    File file, {
    String? path,
  }) async {
    try {
      final auth = GetIt.instance<FirebaseAuth>();
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다');
      }

      final bytes = await file.readAsBytes();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final uploadPath = path ?? 'uploads/files/$fileName';

      final ref = _storage.ref(uploadPath);
      final snapshot = await ref.putData(bytes);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('파일 업로드 실패: $e');
    }
  }

  @override
  Future<File?> downloadFile(
    String url, {
    String? savePath,
  }) async {
    try {
      final ref = _storage.refFromURL(url);
      const maxSize = 100 * 1024 * 1024; // 100MB
      final bytes = await ref.getData(maxSize);

      if (bytes == null) return null;

      // 저장 경로 설정
      final fileName = Uri.parse(url).pathSegments.last;
      final localPath = savePath ?? '${Directory.systemTemp.path}/$fileName';

      final file = File(localPath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteMultipleFiles(List<String> urls) async {
    for (final url in urls) {
      await deleteFile(url);
    }
  }

  // ================== 썸네일 생성 ==================

  @override
  Future<String> generateVideoThumbnail(
    String videoUrl, {
    Duration position = const Duration(seconds: 1),
  }) async {
    // 실제 구현에서는 video_compress 패키지를 사용
    // 현재는 플레이스홀더 반환
    return videoUrl;
  }

  @override
  Future<String> generateImageThumbnail(
    String imageUrl, {
    int width = 150,
    int? height,
  }) async {
    try {
      // 이미지 다운로드
      final file = await downloadFile(imageUrl);
      if (file == null) throw Exception('이미지 다운로드 실패');

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('이미지 디코딩 실패');

      // 썸네일 생성
      final thumbnail = img.copyResize(
        image,
        width: width,
        height: height,
      );

      final thumbnailBytes = Uint8List.fromList(
        img.encodeJpg(thumbnail, quality: 85),
      );

      // 썸네일 업로드
      final thumbnailFileName =
          'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await uploadImageBytes(
        thumbnailBytes,
        thumbnailFileName,
        path: 'uploads/thumbnails/$thumbnailFileName',
      );
    } catch (e) {
      throw Exception('썸네일 생성 실패: $e');
    }
  }

  // ================== 이미지 처리 ==================

  @override
  Future<File> resizeImage(
    File file, {
    required int width,
    int? height,
    bool maintainAspectRatio = true,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('이미지 디코딩 실패');

      final resized = img.copyResize(
        image,
        width: width,
        height: height,
        maintainAspect: maintainAspectRatio,
      );

      final resizedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: 85),
      );

      final resizedFile = File('${file.path}_resized.jpg');
      await resizedFile.writeAsBytes(resizedBytes);

      return resizedFile;
    } catch (e) {
      throw Exception('이미지 리사이징 실패: $e');
    }
  }

  @override
  Future<File> compressImage(
    File file, {
    int quality = 85,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('이미지 디코딩 실패');

      final compressedBytes = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );

      final compressedFile = File('${file.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('이미지 압축 실패: $e');
    }
  }

  // ================== 진행률 및 메타데이터 ==================

  @override
  Stream<double> uploadProgress(String taskId) {
    final stream = _progressStreams[taskId];
    if (stream == null) {
      return Stream.value(0.0);
    }

    return stream.map((snapshot) {
      return snapshot.bytesTransferred / snapshot.totalBytes;
    });
  }

  @override
  Future<Map<String, dynamic>> getFileMetadata(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      final metadata = await ref.getMetadata();

      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated?.toIso8601String(),
        'updated': metadata.updated?.toIso8601String(),
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      throw Exception('메타데이터 조회 실패: $e');
    }
  }

  @override
  Future<String> getSignedUrl(
    String url, {
    Duration expiration = const Duration(hours: 1),
  }) async {
    // Firebase Storage는 이미 서명된 URL을 제공
    // 추가 서명이 필요한 경우 구현
    return url;
  }

  // ================== 유틸리티 ==================

  @override
  Future<String> getMediaType(File file) async {
    final extension = path.extension(file.path).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        return 'image';
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        return 'video';
      case '.mp3':
      case '.wav':
      case '.aac':
        return 'audio';
      default:
        return 'other';
    }
  }

  @override
  Future<int> getFileSize(File file) async {
    try {
      final stat = await file.stat();
      return stat.size;
    } catch (e) {
      throw Exception('파일 크기 확인 실패: $e');
    }
  }

  bool isValidMediaType(File file, List<MediaType> allowedTypes) {
    final extension = path.extension(file.path).toLowerCase();
    MediaType type;

    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.webp':
        type = MediaType.image;
        break;
      case '.mp4':
      case '.mov':
      case '.avi':
      case '.mkv':
        type = MediaType.video;
        break;
      case '.mp3':
      case '.wav':
      case '.aac':
        type = MediaType.audio;
        break;
      default:
        type = MediaType.other;
    }

    return allowedTypes.contains(type);
  }

  @override
  Future<void> clearCache() async {
    // 캐시 정리 구현
    // 현재는 플레이스홀더
  }

  @override
  Future<void> cancelUpload(String taskId) async {
    final task = _uploadTasks[taskId];
    if (task != null) {
      await task.cancel();
      _uploadTasks.remove(taskId);
      _progressStreams.remove(taskId);
    }
  }

  @override
  Future<void> cancelAllUploads() async {
    for (final task in _uploadTasks.values) {
      await task.cancel();
    }
    _uploadTasks.clear();
    _progressStreams.clear();
  }

  // Helper 메서드들 - IMediaRepository 인터페이스에 없음
  Future<String> getStorageUrl(String path) async {
    try {
      final ref = _storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Storage URL 가져오기 실패: $e');
    }
  }

  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> listFiles(String path) async {
    try {
      final ref = _storage.ref(path);
      final result = await ref.listAll();

      final urls = <String>[];
      for (final item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      throw Exception('파일 목록 조회 실패: $e');
    }
  }

  Future<int> getDirectorySize(String path) async {
    try {
      final ref = _storage.ref(path);
      final result = await ref.listAll();

      int totalSize = 0;
      for (final item in result.items) {
        final metadata = await item.getMetadata();
        totalSize += metadata.size ?? 0;
      }

      // 하위 디렉토리 크기 계산
      for (final prefix in result.prefixes) {
        totalSize += await getDirectorySize(prefix.fullPath);
      }

      return totalSize;
    } catch (e) {
      throw Exception('디렉토리 크기 계산 실패: $e');
    }
  }
}
