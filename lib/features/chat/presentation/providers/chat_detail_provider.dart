import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

import '/core/types/result.dart';
import '/features/chat/domain/constants/chat_constants.dart';
import '/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import '/features/chat/domain/usecases/load_more_messages_usecase.dart';
import '/features/chat/domain/usecases/send_message_usecase.dart';
import '/features/chat/domain/usecases/search_messages_usecase.dart';
import '/features/chat/domain/entities/message.dart';
import '/features/chat/data/adapters/chat_message_service.dart';
import '/features/chat/data/adapters/chat_message_lifecycle_service.dart';
import '/features/chat/data/adapters/chat_scroll_service.dart';
import '/features/chat/presentation/screens/chat_detail/chat_detail_controller_v2.dart';

/// 채팅 상태 열거형
enum ChatDetailLoadingState {
  /// 초기 상태
  initial,

  /// 로딩 중
  loading,

  /// 성공
  success,

  /// 에러
  error,
}

/// Chat Detail Provider - Clean Architecture v4.0
///
/// **기존 코드와의 연결**:
/// - chat_detail_widget_v2.dart의 State 로직을 Provider로 이동
/// - 4개 UseCase를 통해 비즈니스 로직 처리
/// - flutter_chat_ui의 core.Message 타입 변환 담당
///
/// **Architecture Flow**:
/// ```
/// UI → Provider → UseCase → Repository → Firestore
/// ```
class ChatDetailProvider extends ChangeNotifier {
  // ========== Dependencies (DI로 주입) ==========
  final GetChatMessagesUseCase _getMessagesUseCase;
  final LoadMoreMessagesUseCase _loadMoreUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final SearchMessagesUseCase _searchUseCase;
  final ChatMessageLifecycleService _lifecycleService;
  final ChatDetailControllerV2 _chatController;

  late final ChatScrollService _scrollService;

  ChatDetailProvider({
    required GetChatMessagesUseCase getMessagesUseCase,
    required LoadMoreMessagesUseCase loadMoreUseCase,
    required SendMessageUseCase sendMessageUseCase,
    required SearchMessagesUseCase searchUseCase,
    required ChatMessageLifecycleService lifecycleService,
    required ChatDetailControllerV2 chatController,
  })  : _getMessagesUseCase = getMessagesUseCase,
        _loadMoreUseCase = loadMoreUseCase,
        _sendMessageUseCase = sendMessageUseCase,
        _searchUseCase = searchUseCase,
        _lifecycleService = lifecycleService,
        _chatController = chatController {
    // ChatScrollService 초기화
    _scrollService = ChatScrollService(_chatController);
  }

  // ========== State Variables ==========
  ChatDetailLoadingState _state = ChatDetailLoadingState.initial;
  String? _errorMessage;

  String? _chatId;
  String? _currentUserId;
  StreamSubscription<Result<List<Message>>>? _messagesSubscription;

  // 원본 Message Entity 리스트 (캐싱용)
  List<Message> _cachedMessages = [];

  // flutter_chat_ui용 변환된 메시지
  List<core.Message> _displayMessages = [];

  // 검색 관련
  String _searchQuery = '';
  bool get isSearching => _searchQuery.isNotEmpty;

  // 검색 결과 추적 (검색 네비게이션용)
  List<String> _searchResultIds = [];
  int _currentSearchIndex = -1;

  // 페이지네이션 (Clean Architecture v4.0: messageId 사용)
  String? _lastMessageId;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // ========== Getters ==========
  ChatDetailLoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  List<core.Message> get messages => _displayMessages;

  // 검색 결과 관련 Getters
  int get searchResultCount => _searchResultIds.length;
  int get currentSearchIndex => _currentSearchIndex;
  bool get hasSearchResults => _searchResultIds.isNotEmpty;
  String? get currentSearchResultId =>
      _currentSearchIndex >= 0 && _currentSearchIndex < _searchResultIds.length
          ? _searchResultIds[_currentSearchIndex]
          : null;

  // ========== Public Methods ==========

  /// 채팅방 초기화 및 실시간 메시지 구독 시작
  ///
  /// **기존 _bootstrap() 로직 대체**
  /// **ChatMessageLifecycleService 통합**: 채팅방 진입 시 자동 읽음 처리
  Future<void> initializeChat(String chatId, String currentUserId) async {
    if (_chatId == chatId) return; // 이미 초기화됨

    _chatId = chatId;
    _currentUserId = currentUserId;
    _setState(ChatDetailLoadingState.loading);

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
              _setState(ChatDetailLoadingState.error);
            },
            (messages) {
              _cachedMessages = messages;
              _updateDisplayMessages();

              // 마지막 메시지 ID 저장 (페이지네이션용)
              // Clean Architecture v4.0: messageId 사용
              if (messages.isNotEmpty) {
                _lastMessageId = messages.first.id;
              }

              // ChatMessageLifecycleService: 채팅방 진입 시 자동 읽음 처리
              _lifecycleService.markMessagesAsSeen(
                chatId: chatId,
                currentUserId: currentUserId,
              );

              _setState(ChatDetailLoadingState.success);
            },
          );
        },
        onError: (error) {
          _setError('실시간 업데이트 오류: $error');
          _setState(ChatDetailLoadingState.error);
        },
      );
    } catch (e) {
      _setError('채팅 초기화 실패: ${e.toString()}');
      _setState(ChatDetailLoadingState.error);
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

  /// 메시지 전송
  ///
  /// **기존 _handleSendPressed() 로직 대체**
  ///
  /// **Note**: MessagesModel 생성은 Repository에서 처리되므로
  /// 여기서는 단순히 UseCase 호출만 합니다.
  /// 실제 구현 시 MessagesModel 팩토리 메서드 필요
  Future<void> sendMessage({
    required String content,
    required String senderId,
    Map<String, dynamic>? metadata,
  }) async {
    if (_chatId == null) return;

    // TODO: MessagesModel 팩토리 메서드로 생성
    // 현재는 UseCase가 직접 생성하도록 수정 필요
    // final message = MessagesModel.create(
    //   content: content,
    //   senderId: senderId,
    //   timeStamp: DateTime.now(),
    //   metadata: metadata,
    // );

    // final result = await _sendMessageUseCase.execute(
    //   chatId: _chatId!,
    //   message: message,
    // );

    // result.fold(
    //   (failure) {
    //     _setError(failure.message);
    //   },
    //   (_) {
    //     // 성공 - 실시간 스트림이 자동으로 UI 업데이트
    //   },
    // );

    // 임시: 메시지 전송 기능은 추후 구현
    debugPrint('TODO: sendMessage 구현 필요');
  }

  /// 메시지 검색
  ///
  /// **기존 _performSearch() 로직 대체**
  void searchMessages(String query) {
    _searchQuery = query;
    _updateDisplayMessages();
  }

  // ========== Private Methods ==========

  /// 검색 필터 적용 및 flutter_chat_ui 변환
  ///
  /// **ChatMessageService 통합 (Clean Architecture v4.0):**
  /// - Message Entity → core.Message 변환을 ChatMessageService에 위임
  /// - 투표 카드, 이미지, 시스템 메시지 등 모든 타입 자동 처리
  ///
  /// **검색 결과 추적 (v4.1):**
  /// - 검색 중일 때 필터링된 메시지 ID를 _searchResultIds에 저장
  /// - 첫 번째 검색 결과로 자동 스크롤
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
        // ✨ ChatMessageService를 사용한 타입별 자동 변환
        // - TextMessage: 일반 텍스트
        // - CustomMessage: 투표 카드
        // - ImageMessage: 이미지
        // - SystemMessage: 시스템 메시지
        _displayMessages = ChatMessageService.convertEntitiesToMessages(filtered);

        // 🔍 검색 결과 추적 및 자동 스크롤
        if (isSearching && filtered.isNotEmpty) {
          // 검색 결과 ID 리스트 저장
          _searchResultIds = filtered.map((msg) => msg.id).toList();
          // 첫 번째 결과로 인덱스 설정
          _currentSearchIndex = 0;
          // 첫 번째 검색 결과로 스크롤
          final firstResultId = _searchResultIds.first;
          _chatController.scrollToMessage(firstResultId);
        } else {
          // 검색 종료 시 결과 초기화
          _searchResultIds = [];
          _currentSearchIndex = -1;
        }

        notifyListeners();
      },
    );
  }

  /// 상태 변경
  void _setState(ChatDetailLoadingState newState) {
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

  // ========== 검색 네비게이션 메서드 ==========

  /// 다음 검색 결과로 이동
  void goToNextSearchResult() {
    if (!hasSearchResults) return;

    // 다음 인덱스 계산 (순환)
    _currentSearchIndex = (_currentSearchIndex + 1) % _searchResultIds.length;

    // 다음 검색 결과로 스크롤
    final nextResultId = _searchResultIds[_currentSearchIndex];
    _chatController.scrollToMessage(nextResultId);

    notifyListeners();
  }

  /// 이전 검색 결과로 이동
  void goToPreviousSearchResult() {
    if (!hasSearchResults) return;

    // 이전 인덱스 계산 (순환)
    _currentSearchIndex = (_currentSearchIndex - 1 + _searchResultIds.length) % _searchResultIds.length;

    // 이전 검색 결과로 스크롤
    final previousResultId = _searchResultIds[_currentSearchIndex];
    _chatController.scrollToMessage(previousResultId);

    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _scrollService.dispose();
    super.dispose();
  }
}
