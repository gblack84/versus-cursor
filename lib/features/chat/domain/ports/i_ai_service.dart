/// AI 서비스 인터페이스 (Clean Architecture v4.0 Port)
///
/// **Dependency Inversion Principle 적용**:
/// - Domain Layer는 이 인터페이스만 의존
/// - Data Layer의 GeminiAIService가 이 인터페이스 구현 (Adapter)
/// - AI 제공자 교체 시 UseCase 코드 변경 불필요
///
/// **사용 예시**:
/// ```dart
/// class SendAIQueryUseCase {
///   final IAIService _aiService;
///
///   Future<Result<Stream<String>>> execute({required String query}) async {
///     final stream = _aiService.sendQuery(query);
///     return Success(stream);
///   }
/// }
/// ```
abstract class IAIService {
  /// AI에게 질문을 전송하고 스트리밍 응답 받기
  ///
  /// **Parameters**:
  /// - [query]: 사용자 질문
  ///
  /// **Returns**:
  /// - `Stream<String>`: AI 응답의 실시간 스트림 (청크 단위)
  ///
  /// **예외**:
  /// - 네트워크 오류, API 키 오류, 응답 생성 실패 등
  Stream<String> sendQuery(String query);

  /// 현재 AI 응답 생성 중인지 여부
  ///
  /// **Returns**:
  /// - `true`: 현재 스트리밍 중
  /// - `false`: 대기 상태
  bool get isStreaming;

  /// 현재 진행 중인 AI 응답 취소
  ///
  /// **사용 시나리오**:
  /// - 사용자가 Stop 버튼 클릭
  /// - 새로운 쿼리 전송으로 이전 쿼리 중단 필요
  Future<void> cancelCurrentQuery();

  /// AI 서비스 초기화
  ///
  /// **Parameters**:
  /// - [apiKey]: AI API 키 (예: Gemini API Key)
  ///
  /// **호출 시점**: 앱 시작 시 또는 AI 채팅 페이지 진입 시
  void initialize(String apiKey);
}
