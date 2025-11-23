import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../failures/chat_failure.dart';
import '../ports/i_ai_service.dart';

/// AI에게 질문을 전송하는 UseCase (Clean Architecture v4.0)
///
/// **Dependency Inversion Principle 적용**:
/// - IAIService 인터페이스에 의존 (Port)
/// - GeminiAIService 구현체와 분리 (Adapter)
/// - AI 제공자 교체 시 UseCase 코드 변경 불필요
///
/// **책임**: AI 쿼리 전송 비즈니스 로직 (입력 검증 + Service 호출)
/// **위치**: Domain Layer
///
/// **사용 예시**:
/// ```dart
/// final useCase = SendAIQueryUseCase(aiService: aiService);
/// final result = await useCase.execute(query: 'Hello AI');
///
/// result.fold(
///   (failure) => ChatLogger.aiError(error: failure, message: failure.message),
///   (stream) async {
///     await for (final chunk in stream) {
///       ChatLogger.aiResponseChunk(chunk: chunk);
///     }
///   },
/// );
/// ```
class SendAIQueryUseCase {
  final IAIService _aiService;

  SendAIQueryUseCase({required IAIService aiService})
      : _aiService = aiService;

  /// AI 쿼리 실행
  ///
  /// **Parameters**:
  /// - [query]: 사용자 질문 (필수, 비어있으면 안 됨)
  ///
  /// **Returns**:
  /// - `Either<ChatFailure, Stream<String>>`: 성공 시 AI 응답 스트림, 실패 시 Failure
  ///
  /// **Validation**:
  /// - query가 비어있으면 ValidationFailure 반환
  ///
  /// **Error Handling**:
  /// - 모든 예외를 ServerFailure로 변환하여 반환
  Future<Either<ChatFailure, Stream<String>>> execute({
    required String query,
  }) async {
    DevLogger.params({
      'query': query,
      'queryLength': query.length,
    }, tag: 'SendAIQuery');

    try {
      // 입력 검증
      if (query.trim().isEmpty) {
        DevLogger.validation(
          field: 'query',
          reason: 'Query cannot be empty',
          tag: 'SendAIQuery',
        );
        return left(const InvalidMessageContent());
      }

      // AI Service 호출
      DevLogger.checkpoint('Sending query to AI service', tag: 'SendAIQuery');
      final stream = _aiService.sendQuery(query.trim());

      DevLogger.result(
        isSuccess: true,
        data: 'AI stream started',
        tag: 'SendAIQuery',
      );

      return right(stream);
    } catch (e, stackTrace) {
      DevLogger.error(
        'AI query failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'SendAIQuery',
      );
      return left(const AIQueryFailed());
    }
  }

  /// 현재 진행 중인 AI 응답 취소
  ///
  /// **사용 시나리오**:
  /// - 사용자가 Stop 버튼 클릭
  /// - 새로운 쿼리 전송으로 이전 쿼리 중단 필요
  Future<void> cancelCurrentQuery() async {
    DevLogger.checkpoint('Canceling current AI query', tag: 'SendAIQuery');
    await _aiService.cancelCurrentQuery();
    DevLogger.checkpoint('AI query canceled', tag: 'SendAIQuery');
  }

  /// AI 스트리밍 진행 상태 확인
  bool get isStreaming => _aiService.isStreaming;
}
