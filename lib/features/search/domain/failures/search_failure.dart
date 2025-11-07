import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_failure.freezed.dart';

/// Search Failure
///
/// Domain Layer - 검색 관련 실패 케이스 정의
/// Freezed Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
/// - Either<SearchFailure, T> 패턴으로 에러 처리
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Core Failure 인터페이스 의존성 제거
/// - 순수 Freezed sealed class로 전환
/// - getUserMessage()는 Extension으로 분리
@freezed
sealed class SearchFailure with _$SearchFailure {
  const SearchFailure._();

  // ========== Network Errors ==========

  /// 네트워크 연결 오류
  const factory SearchFailure.networkError([String? message]) = _NetworkError;

  /// 서버 응답 타임아웃
  const factory SearchFailure.timeout([String? message]) = _Timeout;

  // ========== Firestore Errors ==========

  /// Firestore 읽기 실패
  const factory SearchFailure.firestoreReadFailed({
    required String collection,
    String? message,
  }) = _FirestoreReadFailed;

  /// Firestore 쓰기 실패
  const factory SearchFailure.firestoreWriteFailed({
    required String collection,
    String? operation,
    String? message,
  }) = _FirestoreWriteFailed;

  // ========== Validation Errors ==========

  /// 잘못된 검색어
  const factory SearchFailure.invalidQuery([String? message]) = _InvalidQuery;

  /// 검색어 길이 부족
  const factory SearchFailure.queryTooShort({int? minLength}) = _QueryTooShort;

  // ========== Business Logic Errors ==========

  /// 검색 결과 없음
  const factory SearchFailure.notFound([String? message]) = _NotFound;

  /// 검색 결과 과다
  const factory SearchFailure.tooManyResults([String? message]) = _TooManyResults;

  /// 검색 인덱스 사용 불가
  const factory SearchFailure.indexUnavailable([String? message]) = _IndexUnavailable;

  // ========== Permission Errors ==========

  /// 검색 권한 부족
  const factory SearchFailure.insufficientPermissions([String? message]) = _InsufficientPermissions;

  // ========== Unknown Errors ==========

  /// 예상치 못한 오류
  const factory SearchFailure.unexpected([String? message]) = _Unexpected;
}
