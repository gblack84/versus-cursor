import 'search_failure.dart';

/// Search Failure Extensions
///
/// Custom methods for SearchFailure that provide:
/// - getUserMessage(): 한국어 사용자 친화적 메시지
///
/// **Freezed Limitation Workaround**:
/// Freezed는 커스텀 메서드를 지원하지 않으므로 Extension으로 분리
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
extension SearchFailureExtensions on SearchFailure {
  /// 사용자에게 보여줄 한국어 메시지
  ///
  /// 각 Failure 타입에 맞는 상세한 한국어 메시지 반환
  String getUserMessage() {
    return when(
      // Network Errors
      networkError: (message) => message ?? '네트워크 연결을 확인해주세요',
      timeout: (message) => message ?? '검색 시간이 초과되었습니다',

      // Firestore Errors
      firestoreReadFailed: (collection, message) {
        if (message != null && message.isNotEmpty) {
          return message;
        }
        return '데이터 조회에 실패했습니다';
      },
      firestoreWriteFailed: (collection, operation, message) {
        if (message != null && message.isNotEmpty) {
          return message;
        }
        return '데이터 저장에 실패했습니다';
      },

      // Validation Errors
      invalidQuery: (message) => message ?? '잘못된 검색어입니다',
      queryTooShort: (minLength) =>
          '검색어는 최소 ${minLength ?? 2}자 이상이어야 합니다',

      // Business Logic Errors
      notFound: (message) => message ?? '검색 결과를 찾을 수 없습니다',
      tooManyResults: (message) =>
          message ?? '검색 결과가 너무 많습니다. 검색어를 구체화해주세요',
      indexUnavailable: (message) => message ?? '검색 서비스를 사용할 수 없습니다',

      // Permission Errors
      insufficientPermissions: (message) => message ?? '검색 권한이 없습니다',

      // Unknown Errors
      unexpected: (message) => message ?? '예상치 못한 오류가 발생했습니다',
    );
  }
}
