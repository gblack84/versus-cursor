import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

import '/core/types/result.dart';
import '/features/chat/domain/constants/chat_constants.dart';
import '/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '/features/chat/domain/usecases/load_more_messages_usecase.dart';
import '/features/chat/domain/usecases/search_messages_usecase.dart';
import '/features/chat/domain/usecases/send_ai_query_usecase.dart';
import '/features/chat/domain/entities/message.dart';
import '/features/chat/domain/ports/i_ai_service.dart';
import '/features/chat/presentation/adapters/flutter_chat_adapter.dart';
import '../screens/ai_chat/ai_chat_controller.dart';

/// AI 채팅 상태 열거형
enum AIChatLoadingState {
  /// 초기 상태
  initial,

  /// 로딩 중
  loading,

  /// 성공
  success,

  /// 에러
  error,
}

/// AI Chat Provider - Clean Architecture v4.0
///
/// **기존 코드와의 연결**:
/// - ai_chat_page_v2.dart의 State 로직을 Provider로 이동
/// - 3개 UseCase를 통해 비즈니스 로직 처리
/// - flutter_chat_ui의 core.Message 타입 변환 담당
/// - AIChatController의 AI 스트리밍 로직과 연동
///
/// **Architecture Flow**:
/// ```
/// UI → Provider → UseCase → Repository → Firestore
/// ```
class AIChatProvider extends ChangeNotifier {
  // ========== Dependencies (DI로 주입) ==========
  final GetChatMessagesUseCase _getMessagesUseCase;
  final LoadMoreMessagesUseCase _loadMoreUseCase;
  final SearchMessagesUseCase _searchUseCase;
  final SendAIQueryUseCase _sendAIQueryUseCase;
  final IAIService _aiService; // Clean Architecture v4.0: 인터페이스에 의존

  AIChatProvider({
    required GetChatMessagesUseCase getMessagesUseCase,
    required LoadMoreMessagesUseCase loadMoreUseCase,
    required SearchMessagesUseCase searchUseCase,
    required SendAIQueryUseCase sendAIQueryUseCase,
    required IAIService aiService, // Clean Architecture v4.0: 인터페이스 주입
  })  : _getMessagesUseCase = getMessagesUseCase,
        _loadMoreUseCase = loadMoreUseCase,
        _searchUseCase = searchUseCase,
        _sendAIQueryUseCase = sendAIQueryUseCase,
        _aiService = aiService;

  // ========== State Variables ==========
  AIChatLoadingState _state = AIChatLoadingState.initial;
  String? _errorMessage;

  String? _chatId;
  StreamSubscription<Result<List<Message>>>? _messagesSubscription;

  // 원본 Message Entity 리스트 (캐싱용)
  List<Message> _cachedMessages = [];

  // flutter_chat_ui용 변환된 메시지
  List<core.Message> _displayMessages = [];

  // 검색 관련
  String _searchQuery = '';
  bool get isSearching => _searchQuery.isNotEmpty;

  // 페이지네이션 (Clean Architecture v4.0: messageId 사용)
  String? _lastMessageId;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // ========== Getters ==========
  AIChatLoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  List<core.Message> get messages => _displayMessages;

  // ========== Public Methods ==========

  /// AI 채팅방 초기화 및 실시간 메시지 구독 시작
  ///
  /// **기존 _bootstrap() 로직 대체**
  Future<void> initializeChat(String chatId) async {
    if (_chatId == chatId) return; // 이미 초기화됨

    _chatId = chatId;
    _setState(AIChatLoadingState.loading);

    try {
      // UseCase를 통한 실시간 스트림 구독
      _messagesSubscription = _getMessagesUseCase
          .execute(
        chatId: chatId,
        limit: ChatConstants.initialMessageLoadCount,
      )
          .listen(
        (result) {
          result.fold(
            (failure) {
              _setError(failure.message);
              _setState(AIChatLoadingState.error);
            },
            (messages) {
              _cachedMessages = messages;
              _updateDisplayMessages();

              // 마지막 메시지 ID 저장 (페이지네이션용)
              // Clean Architecture v4.0: messageId 사용
              if (messages.isNotEmpty) {
                _lastMessageId = messages.first.id;
              }

              _setState(AIChatLoadingState.success);
            },
          );
        },
        onError: (error) {
          _setError('실시간 업데이트 오류: $error');
          _setState(AIChatLoadingState.error);
        },
      );
    } catch (e) {
      _setError('AI 채팅 초기화 실패: ${e.toString()}');
      _setState(AIChatLoadingState.error);
    }
  }

  /// 이전 메시지 추가 로드 (페이지네이션)
  ///
  /// **기존 _loadMoreMessages() 로직 대체**
  /// **Clean Architecture v4.0**: messageId 사용 (DocumentSnapshot 제거)
  Future<void> loadMoreMessages() async {
    if (!_hasMore || _lastMessageId == null || _chatId == null) return;

    final result = await _loadMoreUseCase.execute(
      chatId: _chatId!,
      lastMessageId: _lastMessageId!,
      limit: ChatConstants.paginationMessageCount,
    );

    result.fold(
      (failure) {
        // 에러는 무시 (스낵바는 UI에서 처리)
        debugPrint('Load more failed: ${failure.message}');
      },
      (olderMessages) {
        if (olderMessages.isEmpty) {
          _hasMore = false;
        } else {
          _cachedMessages.insertAll(0, olderMessages);

          // 가장 오래된 메시지 ID 업데이트 (페이지네이션용)
          if (olderMessages.isNotEmpty) {
            _lastMessageId = olderMessages.first.id;
          }

          _updateDisplayMessages();
        }
      },
    );
  }

  /// 메시지 검색
  ///
  /// **기존 _performSearch() 로직 대체**
  void searchMessages(String query) {
    _searchQuery = query;
    _updateDisplayMessages();
  }

  /// AI에게 질문 전송 (Clean Architecture v4.0)
  ///
  /// **아키텍처 플로우**:
  /// ```
  /// Provider → SendAIQueryUseCase → GeminiAIService → Gemini API
  ///                      ↓
  ///          Stream<String> 수신
  ///                      ↓
  ///          AIChatController.updateStreamingMessage()
  /// ```
  ///
  /// **Parameters**:
  /// - [query]: 사용자 질문
  /// - [currentUserId]: 현재 사용자 ID
  /// - [controller]: UI State 관리용 Controller
  Future<void> sendAIQuery({
    required String query,
    required String currentUserId,
    required AIChatController controller,
  }) async {
    try {
      // Step 1: 사용자 메시지 추가 (Controller가 UI State 관리)
      await controller.addUserMessage(query, currentUserId);

      // Step 2: AI 스트리밍 플레이스홀더 생성
      final messageId = await controller.addAIStreamingPlaceholder();

      // Step 3: UseCase를 통한 AI 쿼리 실행
      final result = await _sendAIQueryUseCase.execute(query: query);

      result.fold(
        (failure) {
          // 실패 시 에러 메시지 표시
          controller.markStreamingMessageFailed(
            messageId,
            '오류가 발생했습니다: ${failure.message}',
          );
          _setError(failure.message);
        },
        (stream) {
          // 성공 시 스트리밍 처리
          _handleAIStream(stream, messageId, controller);
        },
      );
    } catch (e) {
      _setError('AI 쿼리 전송 실패: ${e.toString()}');
    }
  }

  /// AI 스트림 처리 (Private)
  ///
  /// **책임**: Stream<String>을 구독하여 Controller UI State 업데이트
  void _handleAIStream(
    Stream<String> stream,
    String messageId,
    AIChatController controller,
  ) {
    String accumulatedText = '';

    stream.listen(
      (chunk) {
        // 청크 누적 및 UI 업데이트
        accumulatedText += chunk;
        controller.updateStreamingMessage(messageId, accumulatedText);
      },
      onDone: () {
        // 스트리밍 완료
        if (accumulatedText.isNotEmpty) {
          controller.finalizeStreamingMessage(messageId, accumulatedText);
        }
      },
      onError: (error) {
        // 스트리밍 에러
        controller.markStreamingMessageFailed(
          messageId,
          '오류가 발생했습니다: ${error.toString()}',
        );
        _setError('AI 응답 생성 중 오류: ${error.toString()}');
      },
    );
  }

  /// AI 서비스 초기화
  ///
  /// **호출 시점**: 앱 시작 시 또는 AI 채팅 페이지 진입 시
  void initializeAI(String apiKey) {
    _aiService.initialize(apiKey);
  }

  /// 현재 AI 스트리밍 진행 상태
  bool get isAIStreaming => _aiService.isStreaming;

  /// 현재 진행 중인 AI 응답 취소
  ///
  /// **사용 시나리오**:
  /// - 사용자가 Stop 버튼 클릭
  /// - 새로운 쿼리 전송으로 이전 쿼리 중단 필요
  Future<void> cancelAIQuery() async {
    await _sendAIQueryUseCase.cancelCurrentQuery();
  }

  // ========== Private Methods ==========

  /// 검색 필터 적용 및 flutter_chat_ui 변환
  ///
  /// **MessageMapper 통합 (Clean Architecture v4.0):**
  /// - Message Entity → core.Message 변환을 MessageMapper에 위임
  /// - 투표 카드, 이미지, 시스템 메시지 등 모든 타입 자동 처리
  void _updateDisplayMessages() {
    final result = _searchUseCase.execute(
      allMessages: _cachedMessages,
      query: _searchQuery,
    );

    result.fold(
      (failure) {
        _setError(failure.message);
      },
      (filtered) {
        // ✨ FlutterChatAdapter를 사용한 타입별 자동 변환
        // - TextMessage: 일반 텍스트
        // - CustomMessage: 투표 카드
        // - ImageMessage: 이미지
        // - SystemMessage: 시스템 메시지
        _displayMessages = FlutterChatAdapter.convertEntitiesToMessages(filtered);

        notifyListeners();
      },
    );
  }

  /// 상태 변경
  void _setState(AIChatLoadingState newState) {
    _state = newState;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String message) {
    _errorMessage = message;
  }

  /// 에러 클리어
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
