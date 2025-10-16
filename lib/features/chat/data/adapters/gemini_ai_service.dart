import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/ports/i_ai_service.dart';

/// Gemini AI API 통합 서비스 (Clean Architecture v4.0 Adapter)
///
/// **Adapter Pattern**: Domain Layer의 IAIService 인터페이스 구현
/// **책임**: Google Gemini API 초기화 및 스트리밍 처리
/// **위치**: Data Layer (Infrastructure)
///
/// **Dependency Inversion**:
/// - Domain UseCase → IAIService (Port)
/// - GeminiAIService → IAIService 구현 (Adapter)
/// - AI 제공자 교체 시 이 클래스만 교체하면 됨
///
/// **사용 예시**:
/// ```dart
/// final IAIService aiService = GeminiAIService();
/// aiService.initialize(apiKey);
///
/// final stream = aiService.sendQuery('Hello AI');
/// await for (final chunk in stream) {
///   print('AI Response: $chunk');
/// }
/// ```
class GeminiAIService implements IAIService {
  GenerativeModel? _model;
  StreamSubscription? _currentStreamSubscription;
  bool _isStreaming = false;

  /// Gemini AI 모델 초기화
  ///
  /// **Parameters**:
  /// - [apiKey]: Google AI API 키
  ///
  /// **Configuration**:
  /// - Model: gemini-1.5-flash
  /// - Temperature: 0.7 (창의성)
  /// - MaxOutputTokens: 2048 (최대 응답 길이)
  @override
  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }

  /// AI에게 질문 전송 및 스트리밍 응답 받기
  ///
  /// **Parameters**:
  /// - [query]: 사용자 질문
  ///
  /// **Returns**:
  /// - `Stream<String>`: AI 응답 스트림 (청크 단위)
  ///
  /// **Throws**:
  /// - Exception: API 키 미설정, 스트리밍 중 에러 발생 시
  ///
  /// **Example**:
  /// ```dart
  /// final stream = await aiService.sendQuery('Tell me a joke');
  /// await for (final chunk in stream) {
  ///   print(chunk); // "Why did the...", "chicken cross...", "the road?"
  /// }
  /// ```
  @override
  Stream<String> sendQuery(String query) async* {
    if (_model == null) {
      throw Exception('AI 모델이 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }

    if (_isStreaming) {
      throw Exception('이미 스트리밍이 진행 중입니다.');
    }

    _isStreaming = true;

    try {
      // Gemini API 호출 준비
      final content = [Content.text(query)];
      final response = _model!.generateContentStream(content);

      // 스트리밍 응답 처리
      await for (final chunk in response) {
        if (chunk.text != null && chunk.text!.isNotEmpty) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      _isStreaming = false;
      throw Exception('AI 응답 생성 중 오류 발생: $e');
    } finally {
      _isStreaming = false;
    }
  }

  /// 현재 진행 중인 스트리밍 취소
  ///
  /// **사용 시나리오**:
  /// - 사용자가 응답 중단 요청
  /// - 페이지 이탈 시 리소스 정리
  @override
  Future<void> cancelCurrentQuery() async {
    if (_currentStreamSubscription != null) {
      await _currentStreamSubscription!.cancel();
      _currentStreamSubscription = null;
    }
    _isStreaming = false;
  }

  /// 스트리밍 진행 상태 확인
  @override
  bool get isStreaming => _isStreaming;

  /// 서비스 리소스 정리
  ///
  /// **호출 시점**:
  /// - 위젯 dispose()
  /// - 앱 종료 시
  Future<void> dispose() async {
    await cancelCurrentQuery();
    _model = null;
  }
}
