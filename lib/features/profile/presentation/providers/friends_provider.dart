import 'package:flutter/foundation.dart';
import '../../domain/usecases/friends/get_friends_list_usecase.dart';
import '../../domain/usecases/friends/add_friend_usecase.dart';
import '../../domain/usecases/friends/remove_friend_usecase.dart';
import '../../domain/usecases/friends/send_friend_request_usecase.dart';
import '../../domain/usecases/friends/accept_friend_request_usecase.dart';
import '../../domain/usecases/friends/reject_friend_request_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 친구 Provider
///
/// **책임**:
/// - 친구 목록 상태 관리
/// - 친구 요청 관리
/// - UseCase를 통한 친구 관계 처리
class FriendsProvider extends ChangeNotifier {
  final GetFriendsListUseCase _getFriendsListUseCase;
  // ignore: unused_field - 향후 직접 친구 추가 기능에 사용 예정
  final AddFriendUseCase _addFriendUseCase;
  final RemoveFriendUseCase _removeFriendUseCase;
  final SendFriendRequestUseCase _sendFriendRequestUseCase;
  final AcceptFriendRequestUseCase _acceptFriendRequestUseCase;
  final RejectFriendRequestUseCase _rejectFriendRequestUseCase;

  List<UserProfile> _friends = [];
  bool _isLoading = false;
  String? _errorMessage;

  FriendsProvider({
    required GetFriendsListUseCase getFriendsListUseCase,
    required AddFriendUseCase addFriendUseCase,
    required RemoveFriendUseCase removeFriendUseCase,
    required SendFriendRequestUseCase sendFriendRequestUseCase,
    required AcceptFriendRequestUseCase acceptFriendRequestUseCase,
    required RejectFriendRequestUseCase rejectFriendRequestUseCase,
  })  : _getFriendsListUseCase = getFriendsListUseCase,
        _addFriendUseCase = addFriendUseCase,
        _removeFriendUseCase = removeFriendUseCase,
        _sendFriendRequestUseCase = sendFriendRequestUseCase,
        _acceptFriendRequestUseCase = acceptFriendRequestUseCase,
        _rejectFriendRequestUseCase = rejectFriendRequestUseCase;

  // Getters
  List<UserProfile> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 친구 목록 로드
  Future<void> loadFriends(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getFriendsListUseCase.execute(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _friends = [];
      },
      (friendsList) {
        _friends = friendsList;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 친구 요청 전송
  Future<bool> sendFriendRequest(String userId, String targetUserId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _sendFriendRequestUseCase.execute(
      userId,
      targetUserId,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _errorMessage = null;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// 친구 요청 수락
  Future<bool> acceptFriendRequest(String userId, String requesterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _acceptFriendRequestUseCase.execute(
      userId,
      requesterId,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _errorMessage = null;
        success = true;
        // 친구 목록 새로고침
        loadFriends(userId);
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// 친구 요청 거부
  Future<bool> rejectFriendRequest(String userId, String requesterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _rejectFriendRequestUseCase.execute(
      userId,
      requesterId,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _errorMessage = null;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// 친구 삭제
  Future<bool> removeFriend(String userId, String friendId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _removeFriendUseCase.execute(
      userId: userId,
      friendId: friendId,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _errorMessage = null;
        success = true;
        // 친구 목록에서 제거
        _friends.removeWhere((friend) => friend.uid == friendId);
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
