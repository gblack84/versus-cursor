import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../failures/chat_failure.dart';
import '../entities/message.dart';

/// AI 채팅방 메시지 검색 UseCase
///
/// **기존 코드 연결**:
/// - chat_detail_widget_v2.dart의 _performSearch() 로직을 UseCase로 이동
/// - 클라이언트 사이드 검색 (Firestore 쿼리 불필요)
///
/// **사용 예시**:
/// ```dart
/// final useCase = SearchMessagesUseCase();
/// final result = useCase.execute(
///   allMessages: messages,
///   query: 'AI',
/// );
///
/// result.fold(
///   (failure) => ChatLogger.searchError(error: failure, query: 'AI'),
///   (filtered) => ChatLogger.messagesSearched(count: filtered.length, query: 'AI'),
/// );
/// ```
class SearchMessagesUseCase {
  /// 로컬 메시지 목록에서 검색어 필터링
  ///
  /// **Parameters**:
  /// - [allMessages]: 검색 대상 메시지 전체 목록 (Domain Entity)
  /// - [query]: 검색어
  ///
  /// **Returns**:
  /// - `Either<ChatFailure, List<Message>>`: 필터링된 메시지 목록 (Domain Entity)
  ///
  /// **검색 로직**:
  /// 1. query가 비어있으면 전체 메시지 반환
  /// 2. 메시지 content에 query가 포함되는지 대소문자 구분 없이 검색
  /// 3. 필터링된 결과 반환
  Either<ChatFailure, List<Message>> execute({
    required List<Message> allMessages,
    required String query,
  }) {
    DevLogger.params({
      'messageCount': allMessages.length,
      'query': query,
      'queryLength': query.length,
    }, tag: 'SearchMessages');

    try {
      // 검색어가 비어있으면 전체 반환
      if (query.trim().isEmpty) {
        DevLogger.checkpoint('Empty query, returning all messages', tag: 'SearchMessages');
        DevLogger.result(
          isSuccess: true,
          data: '${allMessages.length} messages returned (no filter)',
          tag: 'SearchMessages',
        );
        return right(allMessages);
      }

      final lowerQuery = query.toLowerCase();

      // 메시지 content에서 검색
      DevLogger.checkpoint('Filtering messages by query', tag: 'SearchMessages');
      final filtered = allMessages.where((msg) {
        return msg.content.toLowerCase().contains(lowerQuery);
      }).toList();

      DevLogger.result(
        isSuccess: true,
        data: '${filtered.length}/${allMessages.length} messages matched',
        tag: 'SearchMessages',
      );

      return right(filtered);
    } catch (e, stackTrace) {
      DevLogger.error(
        'Search messages failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'SearchMessages',
      );
      return left(const SearchFailed());
    }
  }
}
