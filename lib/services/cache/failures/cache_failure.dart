import 'package:freezed_annotation/freezed_annotation.dart';

part 'cache_failure.freezed.dart';

/// Cache 작업 실패 타입
///
/// Freezed Sealed Class로 모든 캐시 에러 케이스를 타입 안전하게 표현합니다.
///
/// **6가지 Failure 타입**:
/// - [CacheNotFound]: 캐시 항목 없음 (Cache miss)
/// - [CacheTypeMismatch]: 타입 불일치 (T와 실제 타입 다름)
/// - [CacheHiveError]: Hive 저장소 에러
/// - [CacheFirestoreError]: Firestore 동기화 에러
/// - [CacheSerializationError]: 직렬화/역직렬화 에러
/// - [CacheExpired]: 캐시 만료 (TTL 초과)
///
/// **사용 예시**:
/// ```dart
/// final result = await cacheService.get<UserProfile>('user_123');
///
/// result.fold(
///   (failure) => failure.when(
///     notFound: (_) => print('Cache miss'),
///     typeMismatch: (expected, actual) => print('Type error: $expected vs $actual'),
///     hiveError: (msg) => print('Hive error: $msg'),
///     firestoreError: (msg) => print('Firestore error: $msg'),
///     serializationError: (msg) => print('Serialization error: $msg'),
///     expired: () => print('Cache expired'),
///   ),
///   (profile) => print('Cache hit: ${profile.displayName}'),
/// );
/// ```
@freezed
sealed class CacheFailure with _$CacheFailure {
  /// 캐시 항목 없음 (Cache miss)
  ///
  /// L1 Memory, L2 Hive, L3 Firestore 모두에서 찾지 못한 경우
  ///
  /// **예시**:
  /// - 사용자가 처음 방문
  /// - 캐시 무효화 후 재조회
  /// - TTL 만료 후 자동 삭제
  const factory CacheFailure.notFound([String? message]) = CacheNotFound;

  /// 타입 불일치
  ///
  /// 캐시에 저장된 타입과 요청한 제네릭 타입이 다른 경우
  ///
  /// **예시**:
  /// ```dart
  /// // 저장: Map<String, dynamic>
  /// await cache.set('key', {'name': 'John'});
  ///
  /// // 조회: UserProfile (잘못된 타입)
  /// final result = await cache.get<UserProfile>('key');
  /// // → CacheTypeMismatch(expected: UserProfile, actual: Map<String, dynamic>)
  /// ```
  const factory CacheFailure.typeMismatch({
    required String expected,
    required String actual,
  }) = CacheTypeMismatch;

  /// Hive 저장소 에러
  ///
  /// L2 Hive Box 접근 실패, 손상된 Box, 디스크 공간 부족 등
  ///
  /// **예시**:
  /// - HiveError: Box has already been closed
  /// - HiveError: Corrupted box
  /// - HiveError: No space left on device
  const factory CacheFailure.hiveError(String message) = CacheHiveError;

  /// Firestore 동기화 에러
  ///
  /// L3 Firestore 읽기/쓰기 실패, 네트워크 오류, 권한 문제 등
  ///
  /// **예시**:
  /// - FirebaseException: permission-denied
  /// - FirebaseException: unavailable (네트워크 오류)
  /// - FirebaseException: deadline-exceeded (타임아웃)
  const factory CacheFailure.firestoreError(String message) = CacheFirestoreError;

  /// 직렬화/역직렬화 에러
  ///
  /// JSON 변환 실패, Freezed fromJson/toJson 에러 등
  ///
  /// **예시**:
  /// - TypeError: type 'String' is not a subtype of type 'int'
  /// - NoSuchMethodError: The method 'fromJson' was not found
  /// - FormatException: Invalid JSON
  const factory CacheFailure.serializationError(String message) = CacheSerializationError;

  /// 캐시 만료 (TTL 초과)
  ///
  /// 설정된 TTL(Time To Live)을 초과한 경우
  ///
  /// **예시**:
  /// ```dart
  /// // 5분 TTL로 저장
  /// await cache.set('key', value, ttl: Duration(minutes: 5));
  ///
  /// // 6분 후 조회
  /// final result = await cache.get('key');
  /// // → CacheExpired()
  /// ```
  const factory CacheFailure.expired() = CacheExpired;
}

/// CacheFailure Extension - 한국어 메시지 제공
extension CacheFailureX on CacheFailure {
  /// 사용자에게 표시할 한국어 에러 메시지
  ///
  /// **반환값**:
  /// - notFound: "캐시에 데이터가 없습니다"
  /// - typeMismatch: "타입 불일치: UserProfile 예상, Map<String, dynamic> 발견"
  /// - hiveError: "로컬 저장소 오류: Box has already been closed"
  /// - firestoreError: "서버 오류: permission-denied"
  /// - serializationError: "데이터 변환 오류: Invalid JSON"
  /// - expired: "캐시가 만료되었습니다"
  String get message => when(
        notFound: (msg) => msg ?? '캐시에 데이터가 없습니다',
        typeMismatch: (expected, actual) => '타입 불일치: $expected 예상, $actual 발견',
        hiveError: (msg) => '로컬 저장소 오류: $msg',
        firestoreError: (msg) => '서버 오류: $msg',
        serializationError: (msg) => '데이터 변환 오류: $msg',
        expired: () => '캐시가 만료되었습니다',
      );

  /// 영문 에러 메시지
  ///
  /// **반환값**:
  /// - notFound: "Cache entry not found"
  /// - typeMismatch: "Type mismatch: expected UserProfile, got Map<String, dynamic>"
  /// - hiveError: "Hive error: Box has already been closed"
  /// - firestoreError: "Firestore error: permission-denied"
  /// - serializationError: "Serialization error: Invalid JSON"
  /// - expired: "Cache entry expired"
  String get englishMessage => when(
        notFound: (msg) => msg ?? 'Cache entry not found',
        typeMismatch: (expected, actual) => 'Type mismatch: expected $expected, got $actual',
        hiveError: (msg) => 'Hive error: $msg',
        firestoreError: (msg) => 'Firestore error: $msg',
        serializationError: (msg) => 'Serialization error: $msg',
        expired: () => 'Cache entry expired',
      );

  /// 로그용 상세 메시지
  ///
  /// 디버깅 시 사용. 모든 컨텍스트 정보 포함.
  ///
  /// **반환값**:
  /// - notFound: "[CacheNotFound] Cache entry not found: user_123"
  /// - typeMismatch: "[CacheTypeMismatch] Expected UserProfile, got Map<String, dynamic>"
  /// - hiveError: "[CacheHiveError] Box has already been closed"
  /// - firestoreError: "[CacheFirestoreError] permission-denied"
  /// - serializationError: "[CacheSerializationError] Invalid JSON"
  /// - expired: "[CacheExpired] TTL exceeded"
  String get debugMessage => when(
        notFound: (msg) => '[CacheNotFound] ${msg ?? 'Cache entry not found'}',
        typeMismatch: (expected, actual) => '[CacheTypeMismatch] Expected $expected, got $actual',
        hiveError: (msg) => '[CacheHiveError] $msg',
        firestoreError: (msg) => '[CacheFirestoreError] $msg',
        serializationError: (msg) => '[CacheSerializationError] $msg',
        expired: () => '[CacheExpired] TTL exceeded',
      );

  /// 재시도 가능 여부
  ///
  /// **재시도 가능** (true):
  /// - firestoreError: 네트워크 오류, 타임아웃 등
  /// - hiveError: 일시적 파일 시스템 문제
  ///
  /// **재시도 불가** (false):
  /// - notFound: 데이터가 없음
  /// - typeMismatch: 타입 불일치
  /// - serializationError: 데이터 손상
  /// - expired: TTL 초과
  bool get isRetryable => when(
        notFound: (_) => false,
        typeMismatch: (_, __) => false,
        hiveError: (_) => true,
        firestoreError: (_) => true,
        serializationError: (_) => false,
        expired: () => false,
      );

  /// 심각도 레벨
  ///
  /// **Error (높음)**:
  /// - firestoreError: 서버 문제
  /// - hiveError: 로컬 저장소 손상
  /// - serializationError: 데이터 손상
  ///
  /// **Warning (중간)**:
  /// - typeMismatch: 타입 불일치
  ///
  /// **Info (낮음)**:
  /// - notFound: Cache miss (정상)
  /// - expired: TTL 초과 (정상)
  String get severity => when(
        notFound: (_) => 'INFO',
        typeMismatch: (_, __) => 'WARNING',
        hiveError: (_) => 'ERROR',
        firestoreError: (_) => 'ERROR',
        serializationError: (_) => 'ERROR',
        expired: () => 'INFO',
      );
}
