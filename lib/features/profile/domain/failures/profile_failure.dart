import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failures.dart';

part 'profile_failure.freezed.dart';

/// Profile Feature Failures
///
/// Domain Layer - 프로필 관련 실패 케이스 정의
/// Freezed Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
/// - Core Failure 인터페이스 구현으로 Result<T> 호환성 확보
///
/// **마이그레이션 (2025-01-29)**:
/// - Phase 1: Sealed class → @freezed sealed class
/// - Auth Feature 패턴 100% 일치
/// - 209줄 → 120줄 (42% 감소)
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
@freezed
sealed class ProfileFailure with _$ProfileFailure implements Failure {
  const ProfileFailure._();

  // Equatable implementation (required by Failure interface)
  @override
  List<Object?> get props => [message, code];

  @override
  String? get code => null;

  @override
  bool? get stringify => true;

  // ==================== Failure Factory Constructors ====================

  /// 입력 검증 실패
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (userId.isEmpty) {
  ///   return Result.failure(ProfileFailure.validation('userId'));
  /// }
  /// ```
  const factory ProfileFailure.validation(String field) = ValidationFailure;

  /// 프로필을 찾을 수 없음
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (profile == null) {
  ///   return Result.failure(ProfileFailure.profileNotFound(userId: userId));
  /// }
  /// ```
  const factory ProfileFailure.profileNotFound({String? userId}) = ProfileNotFound;

  /// Firestore 읽기 실패
  ///
  /// **사용 예시**:
  /// ```dart
  /// try {
  ///   final doc = await firestore.collection('users').doc(uid).get();
  /// } catch (e) {
  ///   return Result.failure(ProfileFailure.firestoreRead('user document'));
  /// }
  /// ```
  const factory ProfileFailure.firestoreRead(String operation) = FirestoreRead;

  /// Firestore 쓰기 실패
  ///
  /// **사용 예시**:
  /// ```dart
  /// try {
  ///   await firestore.collection('users').doc(uid).update(data);
  /// } catch (e) {
  ///   return Result.failure(ProfileFailure.firestoreWrite('user profile update'));
  /// }
  /// ```
  const factory ProfileFailure.firestoreWrite(String operation) = FirestoreWrite;

  /// Firebase Storage 작업 실패
  ///
  /// **사용 예시**:
  /// ```dart
  /// try {
  ///   final url = await storage.ref('profile/$uid.jpg').getDownloadURL();
  /// } catch (e) {
  ///   return Result.failure(ProfileFailure.storage('profile image upload'));
  /// }
  /// ```
  const factory ProfileFailure.storage(String operation) = StorageFailure;

  /// 네트워크 연결 오류
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (!await hasNetwork()) {
  ///   return Result.failure(ProfileFailure.network());
  /// }
  /// ```
  const factory ProfileFailure.network() = NetworkFailure;

  /// 권한 거부
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (!hasPermission) {
  ///   return Result.failure(ProfileFailure.permissionDenied('user profile'));
  /// }
  /// ```
  const factory ProfileFailure.permissionDenied(String resource) = PermissionDenied;

  /// 인증 필요 (로그인 안 됨)
  ///
  /// **사용 예시**:
  /// ```dart
  /// final uid = _authContract.getCurrentUserId();
  /// if (uid == null || uid.isEmpty) {
  ///   return Result.failure(ProfileFailure.authenticationRequired());
  /// }
  /// ```
  const factory ProfileFailure.authenticationRequired() = AuthenticationRequired;

  /// 권한 없음 (다른 사용자 리소스 접근 시도)
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (user.uid != currentUid) {
  ///   return Result.failure(ProfileFailure.unauthorizedAccess(
  ///     message: 'Cannot update other user profile'
  ///   ));
  /// }
  /// ```
  const factory ProfileFailure.unauthorizedAccess({
    @Default('권한이 없습니다') String message,
  }) = UnauthorizedAccess;

  /// 캐시 작업 실패
  ///
  /// **사용 예시**:
  /// ```dart
  /// try {
  ///   await cache.write('user_$uid', profile);
  /// } catch (e) {
  ///   return Result.failure(ProfileFailure.cache('profile caching'));
  /// }
  /// ```
  const factory ProfileFailure.cache(String operation) = CacheFailure;

  /// 중복 작업 시도 (Idempotency 위반)
  ///
  /// **사용 예시**:
  /// ```dart
  /// try {
  ///   await idempotencyService.executeIdempotent(...);
  /// } on IdempotencyViolation catch (e) {
  ///   return Result.failure(ProfileFailure.duplicateOperation(e.message));
  /// }
  /// ```
  const factory ProfileFailure.duplicateOperation(String message) = DuplicateOperation;

  /// 알 수 없는 오류
  ///
  /// **사용 예시**:
  /// ```dart
  /// } catch (e) {
  ///   return Result.failure(ProfileFailure.unknown(e.toString()));
  /// }
  /// ```
  const factory ProfileFailure.unknown([String? error]) = UnknownProfile;

  /// Convert to user-friendly message (Implements Failure.message)
  @override
  String get message {
    return when(
      validation: (field) => '입력 정보를 확인해주세요: $field',
      profileNotFound: (userId) => userId != null
          ? '프로필을 찾을 수 없습니다 (UID: $userId)'
          : '프로필을 찾을 수 없습니다',
      firestoreRead: (operation) => '데이터 읽기 실패: $operation',
      firestoreWrite: (operation) => '데이터 저장 실패: $operation',
      storage: (operation) => '파일 처리 실패: $operation',
      network: () => '네트워크 연결을 확인해주세요',
      permissionDenied: (resource) => '접근 권한이 없습니다: $resource',
      authenticationRequired: () => '로그인이 필요합니다',
      unauthorizedAccess: (msg) => msg,
      cache: (operation) => '캐시 작업 실패: $operation',
      duplicateOperation: (msg) => '이미 처리된 작업입니다: $msg',
      unknown: (error) => error ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
