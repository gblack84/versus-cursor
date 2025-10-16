import 'dart:async';
import 'package:flutter/foundation.dart';

import '/core/constants/app_constants.dart';
import '/core/types/result.dart';
import '/features/chat/domain/usecases/get_chat_list_usecase.dart';
import '/features/chat/domain/entities/chat.dart';

/// 채팅 목록 상태 열거형
enum ChatListLoadingState {
  /// 초기 상태
  initial,

  /// 로딩 중
  loading,

  /// 성공
  success,

  /// 에러
  error,
}

/// Chat List Provider - Clean Architecture v4.0
///
/// **기존 코드와의 연결**:
/// - chat_list_widget.dart의 StreamBuilder 로직을 Provider로 이동
/// - GetChatListUseCase를 통해 비즈니스 로직 처리
/// - 실시간 채팅 목록 스트림 관리
///
/// **Architecture Flow**:
/// ```
/// UI → Provider → UseCase → Repository → Firestore
/// ```
class ChatListProvider extends ChangeNotifier {
  // ========== Dependencies (DI로 주입) ==========
  final GetChatListUseCase _getChatListUseCase;

  ChatListProvider({
    required GetChatListUseCase getChatListUseCase,
  }) : _getChatListUseCase = getChatListUseCase;

  // ========== State Variables ==========
  ChatListLoadingState _state = ChatListLoadingState.initial;
  String? _errorMessage;

  String? _userId;
  StreamSubscription<Result<List<Chat>>>? _chatsSubscription;

  // 채팅 목록
  List<Chat> _chats = [];

  // ========== Getters ==========
  ChatListLoadingState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Chat> get chats => _chats;

  /// 읽지 않은 채팅 개수
  int get unreadCount => _chats.where((chat) => !chat.isRead).length;

  /// AI 채팅방 찾기
  Chat? get aiChat => _chats.firstWhere(
        (chat) =>
            chat.participantIds.contains(AppConstants.aiUserId) ||
            chat.chatType == 'aiChat',
        orElse: () => _chats.first, // Fallback to first chat if AI chat not found
      );

  // ========== Public Methods ==========

  /// 채팅 목록 초기화 및 실시간 스트림 구독 시작
  ///
  /// **기존 StreamBuilder 로직 대체**
  Future<void> initializeChatList(String userId) async {
    if (_userId == userId) return; // 이미 초기화됨

    _userId = userId;
    _setState(ChatListLoadingState.loading);

    try {
      // UseCase를 통한 실시간 스트림 구독
      _chatsSubscription = _getChatListUseCase
          .execute(
        userId: userId,
        limit: 50,
      )
          .listen(
        (result) {
          result.fold(
            (failure) {
              _setError(failure.message);
              _setState(ChatListLoadingState.error);
            },
            (chats) {
              _chats = chats;
              _setState(ChatListLoadingState.success);
            },
          );
        },
        onError: (error) {
          _setError('실시간 업데이트 오류: $error');
          _setState(ChatListLoadingState.error);
        },
      );
    } catch (e) {
      _setError('채팅 목록 초기화 실패: ${e.toString()}');
      _setState(ChatListLoadingState.error);
    }
  }

  /// 특정 채팅의 읽음 상태 업데이트 (로컬 상태만, Firestore 업데이트는 별도)
  ///
  /// **Note**: 실제 Firestore 업데이트는 chat_detail 진입 시 처리됨
  void markChatAsRead(String chatId) {
    final index = _chats.indexWhere((chat) => chat.id == chatId);
    if (index != -1) {
      // Chat Entity는 immutable이므로, 새 목록으로 교체
      _chats = List.from(_chats);
      // isRead 필드 업데이트는 Firestore에서 자동으로 스트림을 통해 반영됨
      notifyListeners();
    }
  }

  // ========== Private Methods ==========

  /// 상태 변경
  void _setState(ChatListLoadingState newState) {
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
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
