// Profile Feature Failures
// Clean Architecture v4.0 - Domain Layer

import '/core/errors/failures.dart';

/// ProfileFailure sealed class
///
/// **Clean Architecture v4.0 - Result Pattern**:
/// - Sealed class로 컴파일 타임 타입 안전성 보장
/// - Core Failure 상속으로 Result<T>와 완벽 호환
/// - Switch 패턴 매칭으로 한국어 메시지 중앙 관리
///
/// **마이그레이션 (2025-01-20)**:
/// - Phase 3 Abstract class → Clean Architecture v4.0 Sealed class
/// - getUserMessage() 메서드 → message getter
/// - implements Exception 제거 → extends Failure
/// - 생성자 간소화 (message 파라미터 제거)
///
/// **9개 Failure 타입**:
/// - ValidationFailure: 입력 검증 실패
/// - ProfileNotFound: 프로필 없음
/// - FirestoreRead: Firestore 읽기 실패
/// - FirestoreWrite: Firestore 쓰기 실패
/// - StorageFailure: Storage 작업 실패
/// - NetworkFailure: 네트워크 오류
/// - PermissionDenied: 권한 거부
/// - CacheFailure: 캐시 작업 실패
/// - UnknownProfile: 알 수 없는 오류
sealed class ProfileFailure extends Failure {
  const ProfileFailure() : super(message: '');

  @override
  String get message {
    return switch (this) {
      // 입력 검증 실패
      ValidationFailure(:final field) => '입력 정보를 확인해주세요: $field',

      // 프로필 없음
      ProfileNotFound(:final userId) => userId != null
          ? '프로필을 찾을 수 없습니다 (UID: $userId)'
          : '프로필을 찾을 수 없습니다',

      // Firestore 읽기 실패
      FirestoreRead(:final operation) => '데이터 읽기 실패: $operation',

      // Firestore 쓰기 실패
      FirestoreWrite(:final operation) => '데이터 저장 실패: $operation',

      // Storage 작업 실패
      StorageFailure(:final operation) => '파일 처리 실패: $operation',

      // 네트워크 오류
      NetworkFailure() => '네트워크 연결을 확인해주세요',

      // 권한 거부
      PermissionDenied(:final resource) => '접근 권한이 없습니다: $resource',

      // 캐시 작업 실패
      CacheFailure(:final operation) => '캐시 작업 실패: $operation',

      // 알 수 없는 오류
      UnknownProfile(:final error) =>
        error ?? '알 수 없는 오류가 발생했습니다',
    };
  }
}

// ==================== Sealed Class Implementations ====================

/// 입력 검증 실패
///
/// **사용 예시**:
/// ```dart
/// if (userId.isEmpty) {
///   return ResultFailure(ValidationFailure('userId'));
/// }
/// ```
class ValidationFailure extends ProfileFailure {
  /// 검증 실패한 필드명
  final String field;

  const ValidationFailure(this.field) : super();
}

/// 프로필을 찾을 수 없음
///
/// **사용 예시**:
/// ```dart
/// if (profile == null) {
///   return ResultFailure(ProfileNotFound(userId: userId));
/// }
/// ```
class ProfileNotFound extends ProfileFailure {
  /// 조회 시도한 사용자 ID (optional)
  final String? userId;

  const ProfileNotFound({this.userId}) : super();
}

/// Firestore 읽기 실패
///
/// **사용 예시**:
/// ```dart
/// try {
///   final doc = await firestore.collection('users').doc(uid).get();
/// } catch (e) {
///   throw FirestoreRead('user document');
/// }
/// ```
class FirestoreRead extends ProfileFailure {
  /// 실패한 작업 설명
  final String operation;

  const FirestoreRead(this.operation) : super();
}

/// Firestore 쓰기 실패
///
/// **사용 예시**:
/// ```dart
/// try {
///   await firestore.collection('users').doc(uid).update(data);
/// } catch (e) {
///   throw FirestoreWrite('user profile update');
/// }
/// ```
class FirestoreWrite extends ProfileFailure {
  /// 실패한 작업 설명
  final String operation;

  const FirestoreWrite(this.operation) : super();
}

/// Firebase Storage 작업 실패
///
/// **사용 예시**:
/// ```dart
/// try {
///   final url = await storage.ref('profile/$uid.jpg').getDownloadURL();
/// } catch (e) {
///   throw StorageFailure('profile image upload');
/// }
/// ```
class StorageFailure extends ProfileFailure {
  /// 실패한 작업 설명
  final String operation;

  const StorageFailure(this.operation) : super();
}

/// 네트워크 연결 오류
///
/// **사용 예시**:
/// ```dart
/// if (!await hasNetwork()) {
///   return ResultFailure(NetworkFailure());
/// }
/// ```
class NetworkFailure extends ProfileFailure {
  const NetworkFailure() : super();
}

/// 권한 거부
///
/// **사용 예시**:
/// ```dart
/// if (!hasPermission) {
///   return ResultFailure(PermissionDenied('user profile'));
/// }
/// ```
class PermissionDenied extends ProfileFailure {
  /// 접근이 거부된 리소스
  final String resource;

  const PermissionDenied(this.resource) : super();
}

/// 캐시 작업 실패
///
/// **사용 예시**:
/// ```dart
/// try {
///   await cache.write('user_$uid', profile);
/// } catch (e) {
///   throw CacheFailure('profile caching');
/// }
/// ```
class CacheFailure extends ProfileFailure {
  /// 실패한 작업 설명
  final String operation;

  const CacheFailure(this.operation) : super();
}

/// 알 수 없는 오류
///
/// **사용 예시**:
/// ```dart
/// } catch (e) {
///   return ResultFailure(UnknownProfile(e.toString()));
/// }
/// ```
class UnknownProfile extends ProfileFailure {
  /// 에러 메시지 (optional)
  final String? error;

  const UnknownProfile([this.error]) : super();
}
