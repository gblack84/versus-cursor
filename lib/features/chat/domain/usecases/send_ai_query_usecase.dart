import '/core/types/result.dart';
import '/core/errors/failures.dart';
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
///   (failure) => print('AI 쿼리 실패: ${failure.message}'),
///   (stream) async {
///     await for (final chunk in stream) {
///       print('AI 응답: $chunk');
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
  /// - `Result<Stream<String>>`: 성공 시 AI 응답 스트림, 실패 시 Failure
  ///
  /// **Validation**:
  /// - query가 비어있으면 ValidationFailure 반환
  ///
  /// **Error Handling**:
  /// - 모든 예외를 ServerFailure로 변환하여 반환
  Future<Result<Stream<String>>> execute({
    required String query,
  }) async {
    try {
      // 입력 검증
      if (query.trim().isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'AI에게 물어볼 내용을 입력해주세요.'),
        );
      }

      // AI Service 호출
      final stream = _aiService.sendQuery(query.trim());

      return Success(stream);
    } catch (e) {
      return ResultFailure(
        ServerFailure(message: 'AI 쿼리 전송 실패: ${e.toString()}'),
      );
    }
  }

  /// 현재 진행 중인 AI 응답 취소
  ///
  /// **사용 시나리오**:
  /// - 사용자가 Stop 버튼 클릭
  /// - 새로운 쿼리 전송으로 이전 쿼리 중단 필요
  Future<void> cancelCurrentQuery() async {
    await _aiService.cancelCurrentQuery();
  }

  /// AI 스트리밍 진행 상태 확인
  bool get isStreaming => _aiService.isStreaming;
}
