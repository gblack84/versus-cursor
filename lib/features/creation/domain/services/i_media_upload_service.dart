import 'dart:typed_data';
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failure.dart';

/// Media Upload Service 인터페이스
///
/// 미디어 업로드 기능의 도메인 포트(Port)
/// Clean Architecture에서 데이터 레이어 구현과 분리
abstract class IMediaUploadService {
  /// 이미지를 3가지 크기로 업로드 (original, display, thumbnail)
  /// 반환값: Either<MediaRepositoryFailure, Map<String, dynamic>>
  /// - Right: URLs와 aspect ratio 정보를 포함한 Map
  /// - Left: MediaRepositoryFailure
  Future<Either<CreationFailure, Map<String, dynamic>>>
  uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    String? sessionId,
    Function(String)? onModerationStatusUpdate,
    Function(String)? onRejected,
  });

  /// 이미지 업로드와 검열 완료까지 대기
  /// 반환값: Either<MediaRepositoryFailure, Map<String, dynamic>>
  /// - Right: 검열 통과한 URLs와 실패한 이미지 정보
  /// - Left: MediaRepositoryFailure
  Future<Either<CreationFailure, Map<String, dynamic>>>
  uploadAndWaitForModeration({
    required List<Uint8List> imageBytesList,
    required String box,
    String? customPath,
    String? sessionId,
    Function(int current, int total)? onProgress,
  });

  /// Firebase Storage URL에서 이미지 다운로드
  /// 반환값: Either<MediaRepositoryFailure, Uint8List>
  /// - Right: 다운로드된 이미지 바이트
  /// - Left: MediaRepositoryFailure
  Future<Either<CreationFailure, Uint8List>> downloadImageFromUrl(String url);
}
