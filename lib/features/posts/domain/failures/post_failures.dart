import 'package:equatable/equatable.dart';

/// Base class for all failures in the Posts feature
/// Posts 기능의 모든 실패 케이스를 위한 기본 클래스
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Post creation failures
/// 게시물 생성 관련 실패
class CreatePostFailure extends Failure {
  const CreatePostFailure(String message, [String? code]) : super(message, code);
}

/// Image upload failures
/// 이미지 업로드 관련 실패
class ImageUploadFailure extends Failure {
  const ImageUploadFailure(String message, [String? code]) : super(message, code);
}

/// Moderation failures
/// 콘텐츠 검열 관련 실패
class ModerationFailure extends Failure {
  final List<String> rejectedReasons;

  const ModerationFailure(
    String message, {
    this.rejectedReasons = const [],
    String? code,
  }) : super(message, code);

  @override
  List<Object?> get props => [...super.props, rejectedReasons];
}

/// Target audience failures
/// 타겟 오디언스 관련 실패
class TargetAudienceFailure extends Failure {
  const TargetAudienceFailure(String message, [String? code]) : super(message, code);
}

/// Validation failures
/// 유효성 검사 관련 실패
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure(
    String message, {
    this.fieldErrors = const {},
    String? code,
  }) : super(message, code);

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Network failures
/// 네트워크 관련 실패
class NetworkFailure extends Failure {
  const NetworkFailure(String message, [String? code]) : super(message, code);
}

/// Permission failures
/// 권한 관련 실패
class PermissionFailure extends Failure {
  const PermissionFailure(String message, [String? code]) : super(message, code);
}

/// Server failures
/// 서버 관련 실패
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    String? code,
  }) : super(message, code);

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Cache failures
/// 캐시 관련 실패
class CacheFailure extends Failure {
  const CacheFailure(String message, [String? code]) : super(message, code);
}

/// Unknown failures
/// 알 수 없는 실패
class UnknownFailure extends Failure {
  const UnknownFailure(String message, [String? code]) : super(message, code);
}