import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_recommended_friends_usecase.dart';
import '../../domain/usecases/search_friends_usecase.dart';
import '../../domain/usecases/send_friend_request_usecase.dart';
import '../../domain/usecases/toggle_follow_usecase.dart';

/// Provider: 친구 관리 (Clean Architecture v4.0)
///
/// **책임**:
/// - 친구 추천 및 검색 상태 관리
/// - 팔로우/언팔로우 액션 처리
/// - 친구 요청 전송
///
/// **Dependencies**:
/// - [GetRecommendedFriendsUseCase]: 친구 추천 비즈니스 로직
/// - [SearchFriendsUseCase]: 친구 검색 비즈니스 로직
/// - [SendFriendRequestUseCase]: 친구 요청 비즈니스 로직
/// - [ToggleFollowUseCase]: 팔로우 토글 비즈니스 로직
///
/// **Usage**:
/// ```dart
/// // DI에서 주입받아 사용
/// final provider = GetIt.instance<FriendsProvider>();
/// await provider.initialize(currentUserId);
///
/// // 검색
/// provider.searchFriends('John');
///
/// // 팔로우 토글
/// final isFollowing = await provider.toggleFollow(targetUserId);
///
/// // 친구 요청
/// await provider.sendFriendRequest(targetUserId);
/// ```
class FriendsProvider extends ChangeNotifier {
  final GetRecommendedFriendsUseCase _getRecommendedUseCase;
  final SearchFriendsUseCase _searchUseCase;
  final SendFriendRequestUseCase _sendRequestUseCase;
  final ToggleFollowUseCase _toggleFollowUseCase;

  FriendsProvider({
    required GetRecommendedFriendsUseCase getRecommendedUseCase,
    required SearchFriendsUseCase searchUseCase,
    required SendFriendRequestUseCase sendRequestUseCase,
    required ToggleFollowUseCase toggleFollowUseCase,
  })  : _getRecommendedUseCase = getRecommendedUseCase,
        _searchUseCase = searchUseCase,
        _sendRequestUseCase = sendRequestUseCase,
        _toggleFollowUseCase = toggleFollowUseCase;

  // State
  String _currentUserId = '';
  String _searchQuery = '';
  List<dynamic> _users = [];
  FriendsState _state = FriendsState.initial;
  String? _errorMessage;

  // StreamSubscription for cleanup
  StreamSubscription<List<dynamic>>? _usersSubscription;

  // Getters
  String get currentUserId => _currentUserId;
  String get searchQuery => _searchQuery;
  List<dynamic> get users => _users;
  FriendsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == FriendsState.loading;
  bool get hasError => _state == FriendsState.error;
  bool get isEmpty => _state == FriendsState.empty;

  /// Initialize: 친구 추천 목록 로드
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID (필수)
  ///
  /// **Implementation**:
  /// 1. 기존 구독 취소
  /// 2. 상태를 loading으로 변경
  /// 3. GetRecommendedFriendsUseCase 실행
  /// 4. Stream 구독 시작
  Future<void> initialize(String currentUserId) async {
    if (currentUserId.isEmpty) {
      _setState(FriendsState.error, errorMessage: 'User ID is required');
      return;
    }

    _currentUserId = currentUserId;
    _searchQuery = '';
    _setState(FriendsState.loading);

    try {
      // Cancel existing subscription
      await _usersSubscription?.cancel();

      // Subscribe to recommended friends
      _usersSubscription = _getRecommendedUseCase
          .execute(currentUserId: currentUserId)
          .listen(
        (users) {
          _users = users;
          _setState(
            users.isEmpty ? FriendsState.empty : FriendsState.success,
          );
        },
        onError: (error) {
          _setState(
            FriendsState.error,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      _setState(FriendsState.error, errorMessage: e.toString());
    }
  }

  /// Search Friends: 친구 검색
  ///
  /// **Parameters**:
  /// - [query]: 검색어 (displayName 검색)
  ///
  /// **Implementation**:
  /// 1. 검색어가 비어있으면 initialize() 호출 (추천 목록)
  /// 2. 검색어가 있으면 SearchFriendsUseCase 실행
  /// 3. Stream 구독 업데이트
  Future<void> searchFriends(String query) async {
    _searchQuery = query;

    // If search query is empty, show recommended friends
    if (query.trim().isEmpty) {
      await initialize(_currentUserId);
      return;
    }

    _setState(FriendsState.loading);

    try {
      // Cancel existing subscription
      await _usersSubscription?.cancel();

      // Subscribe to search results
      _usersSubscription = _searchUseCase
          .execute(
            currentUserId: _currentUserId,
            query: query,
          )
          .listen(
        (users) {
          _users = users;
          _setState(
            users.isEmpty ? FriendsState.empty : FriendsState.success,
          );
        },
        onError: (error) {
          _setState(
            FriendsState.error,
            errorMessage: error.toString(),
          );
        },
      );
    } catch (e) {
      _setState(FriendsState.error, errorMessage: e.toString());
    }
  }

  /// Toggle Follow: 팔로우/언팔로우 토글
  ///
  /// **Parameters**:
  /// - [targetUserId]: 팔로우 대상 사용자 ID (필수)
  ///
  /// **Returns**:
  /// - bool: 변경 후 팔로우 상태 (true: 팔로우 중, false: 언팔로우)
  ///
  /// **Throws**:
  /// - [ArgumentError]: 본인을 팔로우 시도 시
  /// - [Exception]: Firestore 에러
  Future<bool> toggleFollow(String targetUserId) async {
    try {
      final isFollowing = await _toggleFollowUseCase.execute(
        userId: _currentUserId,
        targetUserId: targetUserId,
      );
      return isFollowing;
    } catch (e) {
      _setState(FriendsState.error, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Send Friend Request: 친구 요청 보내기
  ///
  /// **Parameters**:
  /// - [targetUserId]: 요청 받는 사용자 ID (필수)
  ///
  /// **Throws**:
  /// - [ArgumentError]: 본인에게 친구 요청 시
  /// - [Exception]: Firestore 에러
  Future<void> sendFriendRequest(String targetUserId) async {
    try {
      await _sendRequestUseCase.execute(
        fromUserId: _currentUserId,
        toUserId: targetUserId,
      );
    } catch (e) {
      _setState(FriendsState.error, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Set State: 상태 변경 및 알림
  ///
  /// **Private helper method**
  void _setState(FriendsState newState, {String? errorMessage}) {
    _state = newState;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}

/// Friends State: 친구 목록 상태
///
/// **States**:
/// - [initial]: 초기 상태
/// - [loading]: 로딩 중
/// - [success]: 데이터 로드 성공
/// - [empty]: 결과 없음
/// - [error]: 에러 발생
enum FriendsState {
  initial,
  loading,
  success,
  empty,
  error,
}
